import { useInfiniteQuery, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useSearch } from '@tanstack/react-router'
import { Bell, CheckCheck, ChevronRight, Clock3 } from 'lucide-react'

import {
  notificationTarget,
  notificationActions,
  notificationCategory,
  notificationContextSummary,
  notificationDate,
  notificationIcon,
  notificationMoneySummary,
  notificationPriorityLabel,
  notificationTone,
} from '@/shared/notifications/notification-presentation'
import { NotificationTypeIcon } from '@/shared/notifications/notification-type-icon'
import { notificationToneClasses } from '@/shared/notifications/notification-tone'
import {
  notificationApi,
  notificationKeys,
  type NotificationDto,
} from '@/shared/notifications/notifications.api'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { EmptyState, ErrorState, SectionErrorState } from '@/shared/ui/feedback-states'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip } from '@/shared/ui/status-chip'

const PAGE_SIZE = 20

function notificationFilterLabel(filter: 'all' | 'unread') {
  return filter === 'all' ? 'All notifications' : 'Unread'
}

function NotificationRow({
  notification,
  filter,
  canViewDetail,
  canMarkRead,
  permissions,
  marking,
  onMarkRead,
  onOpenRelated,
}: {
  notification: NotificationDto
  filter: 'all' | 'unread'
  canViewDetail: boolean
  canMarkRead: boolean
  permissions: Parameters<typeof notificationTarget>[1]
  marking: boolean
  onMarkRead: (id: number) => void
  onOpenRelated: (notification: NotificationDto) => void
}) {
  const relatedAction = notificationActions(notification, permissions)[0]
  const context = notificationContextSummary(notification)
  const money = notificationMoneySummary(notification)
  const priority = notificationPriorityLabel(notification.priority)
  const tone = notificationTone(notification)
  const toneClasses = notificationToneClasses[tone]
  const openLabel = canViewDetail ? 'View notification' : relatedAction?.label

  const content = (
    <>
      <span
        className={`rounded-control mt-0.5 flex size-11 shrink-0 items-center justify-center ${toneClasses.icon}`}
        aria-hidden="true"
      >
        <NotificationTypeIcon name={notificationIcon(notification)} className="size-5" />
      </span>
      <span className="min-w-0 flex-1">
        <span className="flex min-w-0 flex-wrap items-center gap-2">
          <StatusChip
            label={notificationCategory(notification)}
            tone={toneClasses.chipTone}
            dense
          />
          {!notification.is_read ? <StatusChip label="Unread" tone="primary" dense /> : null}
          {priority ? (
            <StatusChip
              label={priority}
              tone={priority === 'Critical' ? 'danger' : 'warning'}
              dense
            />
          ) : null}
        </span>
        <span className="text-label text-text-primary group-hover:text-primary mt-2 block leading-6 font-semibold">
          {notification.title}
        </span>
        <span className="text-body-sm text-text-secondary mt-1 line-clamp-2 block whitespace-pre-line">
          {notification.message}
        </span>
        {money ? (
          <span className="mt-2 inline-flex max-w-full">
            <StatusChip
              label={`${money.label} · ${money.formatted}`}
              tone={money.tone === 'danger' ? 'danger' : money.tone}
            />
          </span>
        ) : context ? (
          <span className="text-caption text-text-muted mt-2 block truncate">{context}</span>
        ) : null}
        <span className="text-caption text-text-muted mt-3 flex flex-wrap items-center justify-between gap-2">
          <time className="inline-flex items-center gap-1.5" dateTime={notification.created_at}>
            <Clock3 className="size-3.5" aria-hidden="true" />
            {notificationDate(notification.created_at, true)}
          </time>
          {openLabel ? (
            <span className="text-primary inline-flex items-center gap-1 font-semibold">
              {openLabel}
              <ChevronRight className="size-4" aria-hidden="true" />
            </span>
          ) : null}
        </span>
      </span>
    </>
  )

  return (
    <article
      className={`notification-row rounded-control shadow-elevation-sm relative min-w-0 overflow-hidden border ${toneClasses.surface} ${toneClasses.border}`}
    >
      <span className={`absolute inset-y-0 left-0 w-1 ${toneClasses.rail}`} aria-hidden="true" />
      <div className="flex min-w-0 items-start gap-1">
        {canViewDetail ? (
          <Link
            to="/notifications/$notificationId"
            params={{ notificationId: String(notification.id) }}
            search={{ filter }}
            aria-label={`Open notification: ${notification.title}`}
            className="group focus-visible:shadow-focus-ring rounded-control flex min-w-0 flex-1 items-start gap-3 p-4 pl-5 text-left transition-colors focus-visible:outline-none"
          >
            {content}
          </Link>
        ) : relatedAction ? (
          <button
            type="button"
            aria-label={`${relatedAction.label}: ${notification.title}`}
            className="group focus-visible:shadow-focus-ring rounded-control flex min-w-0 flex-1 items-start gap-3 p-4 pl-5 text-left transition-colors focus-visible:outline-none"
            onClick={() => onOpenRelated(notification)}
          >
            {content}
          </button>
        ) : (
          <div className="flex min-w-0 flex-1 items-start gap-3 p-4 pl-5">{content}</div>
        )}
        {!notification.is_read && canMarkRead ? (
          <Button
            variant="ghost"
            size="icon"
            className="mt-2 mr-2 size-10 shrink-0"
            aria-label={`Mark ${notification.title} as read`}
            title="Mark as read"
            isLoading={marking}
            onClick={() => onMarkRead(notification.id)}
          >
            <CheckCheck className="size-4" aria-hidden="true" />
          </Button>
        ) : null}
      </div>
      {canViewDetail && relatedAction ? (
        <div className="border-border-subtle mr-3 ml-5 flex justify-end border-t py-2.5">
          <Button
            variant="outline"
            size="sm"
            className="tablet:w-auto w-full"
            leadingIcon={<ChevronRight className="size-4" aria-hidden="true" />}
            aria-label={`${relatedAction.label}: ${notification.title}`}
            onClick={() => onOpenRelated(notification)}
          >
            {relatedAction.label}
          </Button>
        </div>
      ) : null}
    </article>
  )
}

export function NotificationsPage() {
  const queryClient = useQueryClient()
  const navigate = useNavigate()
  const search = useSearch({ from: '/_protected/notifications' })
  const filter = search.filter
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const permissions = session?.permissions ?? {}
  const canList = hasPermission(permissions, 'notifications', 'list')
  const canViewDetail = hasPermission(permissions, 'notifications', 'view')
  const canViewCount = canViewDetail
  const canMarkRead = hasPermission(permissions, 'notifications', 'mark_read')
  const canMarkAllRead = hasPermission(permissions, 'notifications', 'mark_all_read')

  const listQuery = useInfiniteQuery({
    queryKey: notificationKeys.list(userId, filter, PAGE_SIZE),
    queryFn: ({ pageParam, signal }) =>
      notificationApi.list({
        limit: PAGE_SIZE,
        offset: pageParam,
        ...(filter === 'unread' ? { isRead: false } : {}),
        signal,
      }),
    initialPageParam: 0,
    getNextPageParam: (lastPage, pages) => {
      const loaded = pages.reduce((count, page) => count + page.items.length, 0)
      return loaded < lastPage.count ? loaded : undefined
    },
    enabled: Boolean(session && canList),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const statsQuery = useQuery({
    queryKey: notificationKeys.stats(userId),
    queryFn: ({ signal }) => notificationApi.stats(signal),
    enabled: Boolean(session && canViewCount),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const markReadMutation = useMutation({
    mutationFn: notificationApi.markRead,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: notificationKeys.account(userId) }),
  })
  const markAllReadMutation = useMutation({
    mutationFn: notificationApi.markAllRead,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: notificationKeys.account(userId) }),
  })

  const notifications = listQuery.data?.pages.flatMap((page) => page.items) ?? []
  const totalCount = listQuery.data?.pages[0]?.count
  const unreadCount = canViewCount ? statsQuery.data?.unread_count : undefined
  const listPresentation = listQuery.isError
    ? presentError(listQuery.error, 'section-load')
    : undefined
  const mutationFailure = markAllReadMutation.isError
    ? markAllReadMutation.error
    : markReadMutation.isError
      ? markReadMutation.error
      : undefined
  const mutationPresentation = mutationFailure
    ? presentError(mutationFailure, 'background-action')
    : undefined

  if (sessionQuery.isPending) {
    return (
      <PageLayout title="Notifications" subtitle="Your important updates and actions.">
        <div className="space-y-3" role="status" aria-label="Loading notifications">
          {[0, 1, 2].map((item) => (
            <div
              key={item}
              className="rounded-control border-border-subtle bg-surface flex gap-4 border p-5"
            >
              <span className="bg-surface-muted size-10 animate-pulse rounded-full" />
              <div className="min-w-0 flex-1 space-y-3">
                <span className="bg-surface-muted block h-4 w-28 animate-pulse rounded" />
                <span className="bg-surface-muted block h-4 w-2/3 animate-pulse rounded" />
                <span className="bg-surface-muted block h-3 w-1/3 animate-pulse rounded" />
              </div>
            </div>
          ))}
        </div>
      </PageLayout>
    )
  }

  if (sessionQuery.isError || !session || !canList) {
    return (
      <PageLayout title="Notifications" subtitle="Your important updates and actions.">
        <ErrorState
          title={canList ? 'Notifications could not load' : 'Notifications are unavailable'}
          description={
            canList ? 'Try again to continue.' : 'Your account cannot view notifications.'
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

  const hasUnreadInLoadedPages = notifications.some(({ is_read }) => !is_read)
  const showMarkAllRead =
    canMarkAllRead && (unreadCount === undefined || unreadCount > 0 || hasUnreadInLoadedPages)

  async function openRelated(notification: NotificationDto) {
    const target = notificationActions(notification, permissions)[0]?.href
    if (!target) return
    if (!notification.is_read && canMarkRead) {
      try {
        await markReadMutation.mutateAsync(notification.id)
      } catch {
        // Opening the authorized related page should remain available after a read update fails.
      }
    }
    void navigate({ to: target as never })
  }

  function changeFilter(nextFilter: 'all' | 'unread') {
    void navigate({ to: '/notifications', search: { filter: nextFilter } })
  }

  function retryMutation() {
    if (markAllReadMutation.isError) markAllReadMutation.mutate()
    else if (markReadMutation.isError && markReadMutation.variables) {
      markReadMutation.mutate(markReadMutation.variables)
    }
  }

  return (
    <PageLayout
      title="Notifications"
      subtitle="Review updates that matter to your work and account."
      leading={<Bell className="size-[18px]" aria-hidden="true" />}
      actionsInline
      actions={
        <>
          {showMarkAllRead ? (
            <Button
              aria-label="Mark all read"
              variant="outline"
              className="max-[479px]:text-caption max-[479px]:min-h-9 max-[479px]:px-3"
              leadingIcon={<CheckCheck className="size-4" aria-hidden="true" />}
              isLoading={markAllReadMutation.isPending}
              onClick={() => markAllReadMutation.mutate()}
            >
              <span className="max-[479px]:hidden">Mark all read</span>
              <span className="hidden max-[479px]:inline max-[361px]:hidden">Mark read</span>
            </Button>
          ) : null}
        </>
      }
    >
      <div className="mx-auto max-w-5xl space-y-5">
        <Card className="tablet:p-5 space-y-4 p-4">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <div>
              <h2 className="text-h3 text-text-primary font-semibold">Your updates</h2>
              <p className="text-caption text-text-secondary mt-1">
                {totalCount === undefined
                  ? 'Updates are shown newest first.'
                  : `${totalCount} ${totalCount === 1 ? 'notification' : 'notifications'}${unreadCount === undefined ? '' : ` · ${unreadCount} unread`}`}
              </p>
            </div>
            <div
              className="bg-surface-muted rounded-control flex gap-1 p-1"
              aria-label="Filter notifications"
            >
              {(['all', 'unread'] as const).map((option) => (
                <button
                  key={option}
                  type="button"
                  aria-pressed={filter === option}
                  className={`rounded-control text-body-sm min-h-10 px-3 font-medium transition-colors ${filter === option ? 'bg-surface text-primary shadow-elevation-sm' : 'text-text-secondary hover:text-text-primary'}`}
                  onClick={() => changeFilter(option)}
                >
                  {notificationFilterLabel(option)}
                </button>
              ))}
            </div>
          </div>
        </Card>

        {mutationPresentation ? (
          <SectionErrorState
            title={mutationPresentation.title}
            description={mutationPresentation.message}
            onRetry={mutationPresentation.retryable ? retryMutation : undefined}
          />
        ) : null}

        {listQuery.isPending && !listQuery.data ? (
          <div className="space-y-3" role="status" aria-label="Loading notifications">
            {[0, 1, 2].map((item) => (
              <div
                key={item}
                className="rounded-control border-border-subtle bg-surface flex gap-4 border p-5"
              >
                <span className="bg-surface-muted size-10 animate-pulse rounded-full" />
                <div className="min-w-0 flex-1 space-y-3">
                  <span className="bg-surface-muted block h-4 w-28 animate-pulse rounded" />
                  <span className="bg-surface-muted block h-4 w-2/3 animate-pulse rounded" />
                  <span className="bg-surface-muted block h-3 w-1/3 animate-pulse rounded" />
                </div>
              </div>
            ))}
          </div>
        ) : listPresentation && !listQuery.data ? (
          <ErrorState
            title={listPresentation.title}
            description={listPresentation.message}
            action={
              listPresentation.retryable ? (
                <Button onClick={() => void listQuery.refetch()}>Try again</Button>
              ) : undefined
            }
          />
        ) : listQuery.data && notifications.length === 0 ? (
          <Card>
            <EmptyState
              title={filter === 'unread' ? 'You are all caught up' : 'No notifications yet'}
              description={
                filter === 'unread'
                  ? 'There are no unread updates in your account.'
                  : 'New updates will appear here when they are available.'
              }
              icon={<Bell className="size-6" aria-hidden="true" />}
            />
          </Card>
        ) : (
          <Card className="overflow-hidden p-0">
            {listPresentation ? (
              <div className="tablet:p-5 p-4">
                <SectionErrorState
                  title={listPresentation.title}
                  description={listPresentation.message}
                  onRetry={listPresentation.retryable ? () => void listQuery.refetch() : undefined}
                />
              </div>
            ) : null}
            <div className="tablet:p-4 space-y-3 p-3">
              {[...notifications]
                .sort((left, right) => {
                  const createdAtDifference =
                    new Date(right.created_at).getTime() - new Date(left.created_at).getTime()
                  return createdAtDifference || right.id - left.id
                })
                .map((notification) => (
                  <NotificationRow
                    key={notification.id}
                    notification={notification}
                    filter={filter}
                    canViewDetail={canViewDetail}
                    canMarkRead={canMarkRead}
                    permissions={permissions}
                    marking={
                      markReadMutation.isPending && markReadMutation.variables === notification.id
                    }
                    onMarkRead={(id) => markReadMutation.mutate(id)}
                    onOpenRelated={(item) => void openRelated(item)}
                  />
                ))}
            </div>
            {listQuery.hasNextPage ? (
              <div className="border-border-subtle flex justify-center border-t p-4">
                <Button
                  variant="outline"
                  isLoading={listQuery.isFetchingNextPage}
                  onClick={() => void listQuery.fetchNextPage()}
                >
                  Load older notifications
                </Button>
              </div>
            ) : null}
          </Card>
        )}
      </div>
    </PageLayout>
  )
}
