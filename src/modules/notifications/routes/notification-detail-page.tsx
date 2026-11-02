import { useEffect, useRef } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useParams, useSearch } from '@tanstack/react-router'
import { Bell, CheckCheck, Clock3 } from 'lucide-react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import {
  notificationActions,
  notificationCategory,
  notificationDate,
  notificationDetailSections,
  notificationIcon,
  notificationMoneySummary,
  notificationPriorityLabel,
} from '@/shared/notifications/notification-presentation'
import { NotificationTypeIcon } from '@/shared/notifications/notification-type-icon'
import { notificationApi, notificationKeys } from '@/shared/notifications/notifications.api'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Alert } from '@/shared/ui/alert'
import { EmptyState, ErrorState, SectionErrorState } from '@/shared/ui/feedback-states'
import { PageLayout } from '@/shared/ui/page-layout'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'
import { StatusChip } from '@/shared/ui/status-chip'

const notificationToneClassesForMoney = {
  success: {
    surface: 'bg-success-subtle/50',
    foreground: 'text-success-foreground',
    border: 'border-success/30',
  },
  warning: {
    surface: 'bg-warning-subtle/50',
    foreground: 'text-warning-foreground',
    border: 'border-warning/30',
  },
  danger: {
    surface: 'bg-danger-subtle/50',
    foreground: 'text-danger-foreground',
    border: 'border-danger/30',
  },
  neutral: {
    surface: 'bg-surface',
    foreground: 'text-primary',
    border: 'border-border-subtle',
  },
}

export function NotificationDetailPage() {
  const queryClient = useQueryClient()
  const navigate = useNavigate()
  const params = useParams({ from: '/_protected/notifications/$notificationId' })
  const search = useSearch({ from: '/_protected/notifications/$notificationId' })
  const notificationId = Number(params.notificationId)
  const validId = Number.isSafeInteger(notificationId) && notificationId > 0
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const permissions = session?.permissions ?? {}
  const userId = session?.user.id ?? 0
  const canViewDetail = hasPermission(permissions, 'notifications', 'view')
  const canMarkRead = hasPermission(permissions, 'notifications', 'mark_read')
  const notificationQuery = useQuery({
    queryKey: notificationKeys.detail(userId, notificationId),
    queryFn: ({ signal }) => notificationApi.get(notificationId, signal),
    enabled: Boolean(session && validId && canViewDetail),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const handledReadId = useRef<number | null>(null)
  const markReadMutation = useMutation({
    mutationFn: notificationApi.markRead,
    onSuccess: (updated) => {
      queryClient.setQueryData(notificationKeys.detail(userId, notificationId), updated)
      void queryClient.invalidateQueries({ queryKey: notificationKeys.account(userId) })
    },
  })
  const markRead = markReadMutation.mutate

  useEffect(() => {
    const item = notificationQuery.data
    if (!item || item.is_read || !canMarkRead || handledReadId.current === item.id) return
    handledReadId.current = item.id
    markRead(item.id)
  }, [canMarkRead, markRead, notificationQuery.data])

  const notification = notificationQuery.data
  const category = notification ? notificationCategory(notification) : undefined
  const actions = notification ? notificationActions(notification, permissions) : []
  const money = notification ? notificationMoneySummary(notification) : undefined
  const priority = notification ? notificationPriorityLabel(notification.priority) : undefined
  const sections = notification ? notificationDetailSections(notification) : []
  const listPresentation = notificationQuery.isError
    ? presentError(notificationQuery.error, 'page-load')
    : undefined
  const markReadPresentation = markReadMutation.isError
    ? presentError(markReadMutation.error, 'background-action')
    : undefined

  if (sessionQuery.isPending) {
    return (
      <PageLayout title="Notification details" subtitle="Loading the selected update.">
        <div
          className="bg-surface-muted rounded-control mx-auto h-64 max-w-4xl animate-pulse"
          role="status"
        >
          <span className="sr-only">Loading notification details</span>
        </div>
      </PageLayout>
    )
  }

  if (sessionQuery.isError || !session || !canViewDetail) {
    return (
      <PageLayout
        title="Notification details"
        subtitle="Review the update and available next steps."
      >
        <ErrorState
          title="Notification details are unavailable"
          description={
            canViewDetail
              ? 'Your account could not be verified. Try again.'
              : 'Your account cannot view notification details.'
          }
          error={sessionQuery.error}
          action={
            sessionQuery.isError ? (
              <Button onClick={() => void sessionQuery.refetch()}>Try again</Button>
            ) : undefined
          }
        />
      </PageLayout>
    )
  }

  const backLink = (
    <Link to="/notifications" search={{ filter: search.filter }} className={pageBackLinkClassName}>
      <PageBackLinkContent>Notifications</PageBackLinkContent>
    </Link>
  )

  if (!validId) {
    return (
      <PageLayout
        title="Notification details"
        subtitle="Review the update and available next steps."
        backLink={backLink}
      >
        <Card className="mx-auto max-w-4xl">
          <EmptyState
            title="Notification not found"
            description="This notification link is invalid. Return to your inbox to choose an update."
            icon={<Bell className="size-6" aria-hidden="true" />}
            action={
              <Button
                variant="outline"
                onClick={() =>
                  void navigate({ to: '/notifications', search: { filter: search.filter } })
                }
              >
                Back to notifications
              </Button>
            }
          />
        </Card>
      </PageLayout>
    )
  }

  const refreshing = notificationQuery.isFetching && Boolean(notification)

  return (
    <PageLayout
      title="Notification details"
      subtitle={
        category
          ? `Review this ${category.toLowerCase()} update and its next steps.`
          : 'Review the update and its next steps.'
      }
      backLink={backLink}
      leading={
        <NotificationTypeIcon
          name={notification ? notificationIcon(notification) : 'bell'}
          className="size-[18px]"
        />
      }
      actionsInline
      actions={
        notification ? (
          <>
            {canMarkRead && !notification.is_read ? (
              <Button
                aria-label="Mark notification as read"
                variant="outline"
                className="max-[479px]:text-caption max-[479px]:min-h-9 max-[479px]:px-3"
                leadingIcon={<CheckCheck className="size-4" aria-hidden="true" />}
                isLoading={markReadMutation.isPending}
                onClick={() => markReadMutation.mutate(notification.id)}
              >
                <span className="max-[479px]:hidden">Mark as read</span>
                <span className="hidden max-[479px]:inline max-[361px]:hidden">Read</span>
              </Button>
            ) : null}
          </>
        ) : undefined
      }
    >
      <div className="tablet:space-y-5 mx-auto max-w-4xl space-y-4">
        {notificationQuery.isPending && !notification ? (
          <div className="space-y-4" role="status" aria-label="Loading notification details">
            <div className="bg-surface-muted rounded-control h-48 animate-pulse" />
            <div className="bg-surface-muted rounded-control h-32 animate-pulse" />
          </div>
        ) : listPresentation && !notification ? (
          <ErrorState
            title={listPresentation.title}
            description={listPresentation.message}
            action={
              listPresentation.retryable ? (
                <Button onClick={() => void notificationQuery.refetch()}>Try again</Button>
              ) : undefined
            }
          />
        ) : notification ? (
          <>
            {listPresentation ? (
              <SectionErrorState
                title={listPresentation.title}
                description={listPresentation.message}
                onRetry={
                  listPresentation.retryable ? () => void notificationQuery.refetch() : undefined
                }
              />
            ) : null}
            {refreshing ? (
              <p
                className="text-caption text-text-muted inline-flex items-center gap-2"
                role="status"
              >
                <span className="border-primary size-3 animate-spin rounded-full border-2 border-r-transparent" />
                Updating notification…
              </p>
            ) : null}
            {markReadPresentation ? (
              <SectionErrorState
                title={markReadPresentation.title}
                description={markReadPresentation.message}
                onRetry={
                  markReadPresentation.retryable
                    ? () => markReadMutation.mutate(notification.id)
                    : undefined
                }
              />
            ) : null}

            <Card className="overflow-hidden p-0">
              <div
                className={`from-primary-subtle/70 via-surface to-surface border-border-subtle tablet:px-8 tablet:py-8 border-b bg-gradient-to-br px-5 py-6`}
              >
                <div className="flex flex-wrap items-center gap-2">
                  {category ? <StatusChip label={category} tone="neutral" /> : null}
                  <StatusChip
                    label={notification.is_read ? 'Read' : 'Unread'}
                    tone={notification.is_read ? 'success' : 'primary'}
                  />
                  {priority ? (
                    <StatusChip
                      label={priority}
                      tone={priority === 'Critical' ? 'danger' : 'warning'}
                    />
                  ) : null}
                </div>
                <h2 className="text-h2 text-text-primary mt-4 max-w-3xl font-semibold tracking-tight">
                  {notification.title}
                </h2>
                <p className="text-body-md text-text-secondary mt-3 max-w-3xl whitespace-pre-line">
                  {notification.message}
                </p>
                <p className="text-caption text-text-muted mt-5 inline-flex items-center gap-2">
                  <Clock3 className="size-4" aria-hidden="true" />
                  <time dateTime={notification.created_at}>
                    {notificationDate(notification.created_at)}
                  </time>
                  <span aria-hidden="true">·</span>
                  <span>{notificationDate(notification.created_at, true)}</span>
                </p>
              </div>
            </Card>

            {money ? (
              <Card
                className={`${money.tone === 'neutral' ? 'border-border-subtle bg-surface' : notificationToneClassesForMoney[money.tone].border + ' ' + notificationToneClassesForMoney[money.tone].surface} flex items-center gap-4`}
              >
                <span
                  className={`bg-surface ${money.tone === 'neutral' ? 'text-primary' : notificationToneClassesForMoney[money.tone].foreground} rounded-control flex size-12 shrink-0 items-center justify-center`}
                >
                  <NotificationTypeIcon name="money" className="size-6" />
                </span>
                <span className="min-w-0">
                  <span className="text-caption text-text-secondary block">{money.label}</span>
                  <span
                    className={`text-h3 ${money.tone === 'neutral' ? 'text-text-primary' : notificationToneClassesForMoney[money.tone].foreground} mt-0.5 block font-semibold tabular-nums`}
                  >
                    {money.formatted}
                  </span>
                </span>
              </Card>
            ) : null}

            {sections.map((section) => (
              <Card key={section.title} className="p-0">
                <div className="border-border-subtle tablet:px-5 flex items-center gap-3 border-b px-4 py-4">
                  <span className="bg-primary-subtle text-primary rounded-control flex size-9 shrink-0 items-center justify-center">
                    <NotificationTypeIcon name={section.icon} className="size-4" />
                  </span>
                  <h3 className="text-label text-text-primary font-semibold">{section.title}</h3>
                </div>
                <dl className="divide-border-subtle tablet:px-5 divide-y px-4">
                  {section.rows.map((row) => (
                    <div
                      key={`${section.title}-${row.label}`}
                      className="phone:flex-row phone:items-center flex flex-col justify-between gap-1 py-3"
                    >
                      <dt className="text-body-sm text-text-secondary">{row.label}</dt>
                      <dd className="text-body-sm text-text-primary phone:text-right min-w-0 font-medium break-words">
                        {row.money ? (
                          <StatusChip label={row.money.formatted} tone={row.money.tone} />
                        ) : row.tone && row.value ? (
                          <StatusChip label={row.value} tone={row.tone} />
                        ) : (
                          row.value
                        )}
                      </dd>
                    </div>
                  ))}
                </dl>
              </Card>
            ))}
            {actions.length ? (
              <Card className="space-y-4">
                <div className="flex items-start gap-3">
                  <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
                    <NotificationTypeIcon name="approvals" className="size-5" />
                  </span>
                  <span>
                    <span className="text-label text-text-primary block font-semibold">
                      Next steps
                    </span>
                    <span className="text-caption text-text-secondary mt-1 block">
                      Continue to the relevant page for this update.
                    </span>
                  </span>
                </div>
                <div className="phone:flex-row flex flex-col gap-2">
                  {actions.map((action, index) => (
                    <Button
                      key={`${action.href}-${action.label}`}
                      variant={index === 0 ? 'primary' : 'outline'}
                      className="phone:w-auto min-h-11 w-full"
                      leadingIcon={<NotificationTypeIcon name="approvals" className="size-4" />}
                      onClick={() => void navigate({ to: action.href as never })}
                    >
                      {action.label}
                    </Button>
                  ))}
                </div>
              </Card>
            ) : null}
            {!sections.length && !actions.length ? (
              <Alert tone="info" className="text-caption">
                This update has no extra details or in-app destination.
              </Alert>
            ) : null}
          </>
        ) : null}
      </div>
    </PageLayout>
  )
}
