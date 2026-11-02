import { useEffect, useId, useRef, useState } from 'react'
import { useInfiniteQuery, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate } from '@tanstack/react-router'

import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { hasPermission, type AuthenticatedSession } from '@/shared/auth/session'
import { presentError } from '@/shared/errors/error-presentation'
import {
  notificationApi,
  notificationKeys,
  type NotificationDto,
} from '@/shared/notifications/notifications.api'
import {
  notificationDate,
  notificationCategory,
  notificationContextSummary,
  notificationIcon,
  notificationMoneySummary,
  notificationActions,
  notificationPriorityLabel,
  notificationTone,
} from '@/shared/notifications/notification-presentation'
import { NotificationTypeIcon } from '@/shared/notifications/notification-type-icon'
import { notificationToneClasses } from '@/shared/notifications/notification-tone'
import { useToast } from '@/shared/feedback/use-toast'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { ShellIcon } from './shell-icons'

export function NotificationCenter({
  session,
  placement = 'header',
}: {
  session: AuthenticatedSession
  placement?: 'header' | 'sidebar'
}) {
  const queryClient = useQueryClient()
  const navigate = useNavigate()
  const [open, setOpen] = useState(false)
  const [filter, setFilter] = useState<'all' | 'unread'>('all')
  const rootRef = useRef<HTMLDivElement>(null)
  const triggerRef = useRef<HTMLButtonElement>(null)
  const panelId = useId()
  const headingId = useId()
  const summaryId = useId()
  const canViewCount = hasPermission(session.permissions, 'notifications', 'view')
  const canViewDetail = canViewCount
  const canMarkRead = hasPermission(session.permissions, 'notifications', 'mark_read')
  const canMarkAllRead = hasPermission(session.permissions, 'notifications', 'mark_all_read')

  const statsQuery = useQuery({
    queryKey: notificationKeys.stats(session.user.id),
    queryFn: ({ signal }) => notificationApi.stats(signal),
    enabled: canViewCount,
    staleTime: DATA_FRESHNESS_MS.live,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    refetchInterval: () =>
      document.visibilityState === 'visible' ? (open ? 30_000 : 60_000) : false,
    refetchIntervalInBackground: false,
  })
  const notificationsQuery = useInfiniteQuery({
    queryKey: notificationKeys.list(session.user.id, filter, 8),
    queryFn: ({ pageParam, signal }) =>
      notificationApi.list({
        limit: 8,
        offset: pageParam,
        ...(filter === 'unread' ? { isRead: false } : {}),
        signal,
      }),
    initialPageParam: 0,
    getNextPageParam: (lastPage, pages) => {
      const loaded = pages.reduce((total, page) => total + page.items.length, 0)
      return loaded < lastPage.count ? loaded : undefined
    },
    enabled: open,
    staleTime: DATA_FRESHNESS_MS.live,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

  const markReadMutation = useMutation({
    mutationFn: notificationApi.markRead,
    onSuccess: () =>
      queryClient.invalidateQueries({ queryKey: notificationKeys.account(session.user.id) }),
  })
  const markAllReadMutation = useMutation({
    mutationFn: notificationApi.markAllRead,
    onSuccess: () =>
      queryClient.invalidateQueries({ queryKey: notificationKeys.account(session.user.id) }),
  })

  useEffect(() => {
    if (!open) return
    const onPointerDown = (event: PointerEvent) => {
      if (!rootRef.current?.contains(event.target as Node)) setOpen(false)
    }
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        setOpen(false)
        triggerRef.current?.focus()
      }
    }
    document.addEventListener('pointerdown', onPointerDown)
    document.addEventListener('keydown', onKeyDown)
    return () => {
      document.removeEventListener('pointerdown', onPointerDown)
      document.removeEventListener('keydown', onKeyDown)
    }
  }, [open])

  const notifications = notificationsQuery.data?.pages.flatMap((page) => page.items) ?? []
  const unreadCount = canViewCount ? statsQuery.data?.unread_count : undefined
  const listError = notificationsQuery.isError
    ? presentError(notificationsQuery.error, 'section-load')
    : undefined
  const mutationFailure = markReadMutation.isError
    ? markReadMutation.error
    : markAllReadMutation.isError
      ? markAllReadMutation.error
      : undefined
  const mutationError = mutationFailure
    ? presentError(mutationFailure, 'background-action')
    : undefined

  function markRead(notificationId: number) {
    if (canMarkRead) markReadMutation.mutate(notificationId)
  }

  async function openNotification(notification: NotificationDto) {
    const relatedAction = notificationActions(notification, session.permissions)[0]
    setOpen(false)
    if (canViewDetail) {
      void navigate({
        to: '/notifications/$notificationId',
        params: { notificationId: String(notification.id) },
        search: { filter },
      })
      return
    }
    if (!relatedAction) {
      if (!notification.is_read) markRead(notification.id)
      return
    }
    if (!notification.is_read && canMarkRead) {
      try {
        await markReadMutation.mutateAsync(notification.id)
      } catch {
        // Navigation should remain available if read-state updating fails.
      }
    }
    void navigate({ to: relatedAction.href as never })
  }

  async function openRelated(notification: NotificationDto) {
    const relatedAction = notificationActions(notification, session.permissions)[0]
    if (!relatedAction) return
    setOpen(false)
    if (!notification.is_read && canMarkRead) {
      try {
        await markReadMutation.mutateAsync(notification.id)
      } catch {
        // Navigation should remain available if read-state updating fails.
      }
    }
    void navigate({ to: relatedAction.href as never })
  }

  return (
    <div ref={rootRef} className={`relative shrink-0 ${placement === 'header' ? 'ml-auto' : ''}`}>
      <Button
        ref={triggerRef}
        variant="ghost"
        size="icon"
        className={placement === 'sidebar' ? 'relative size-8' : 'relative'}
        aria-label={`Notifications${unreadCount ? `, ${unreadCount} unread` : ''}`}
        aria-haspopup="dialog"
        aria-expanded={open}
        aria-controls={open ? panelId : undefined}
        onClick={() => setOpen((current) => !current)}
      >
        <ShellIcon name="bell" className="size-[19px]" />
        {unreadCount && unreadCount > 0 ? (
          <span className="bg-danger text-text-on-primary absolute -top-0.5 -right-0.5 flex min-h-[18px] min-w-[18px] items-center justify-center rounded-full px-1 text-[10px] font-semibold tabular-nums">
            {unreadCount > 99 ? '99+' : unreadCount}
          </span>
        ) : null}
      </Button>

      {open ? (
        <section
          id={panelId}
          role="dialog"
          aria-labelledby={headingId}
          aria-describedby={summaryId}
          className={`bg-surface border-border-subtle shadow-elevation-lg rounded-surface absolute z-50 flex max-h-[min(72dvh,38rem)] w-[min(24rem,calc(100vw-2rem))] flex-col overflow-hidden border ${placement === 'sidebar' ? 'top-0 left-full ml-2' : 'top-[calc(100%+0.5rem)] right-0'}`}
        >
          <header className="border-border-subtle flex shrink-0 items-start justify-between gap-3 border-b px-4 py-3">
            <div>
              <h2 id={headingId} className="text-label font-semibold">
                Notifications
              </h2>
              <p id={summaryId} className="text-caption text-text-muted mt-0.5" aria-live="polite">
                {unreadCount === undefined
                  ? statsQuery.isError
                    ? 'Unread count unavailable'
                    : 'Your latest updates'
                  : unreadCount === 0
                    ? 'You are all caught up'
                    : `${unreadCount} unread ${unreadCount === 1 ? 'update' : 'updates'}`}
              </p>
            </div>
            <div className="flex shrink-0 items-center gap-1">
              {canMarkAllRead && (unreadCount === undefined || unreadCount > 0) ? (
                <Button
                  variant="ghost"
                  size="sm"
                  className="text-primary min-h-10 px-2"
                  disabled={markAllReadMutation.isPending}
                  onClick={() => markAllReadMutation.mutate()}
                >
                  Mark all read
                </Button>
              ) : null}
            </div>
          </header>

          <div className="border-border-subtle flex shrink-0 gap-2 border-b px-4 py-2">
            {(['all', 'unread'] as const).map((option) => (
              <button
                key={option}
                type="button"
                aria-pressed={filter === option}
                className={`min-h-10 min-w-10 rounded-full px-4 py-2 text-xs font-medium capitalize transition-colors ${filter === option ? 'bg-primary-subtle text-primary' : 'text-text-secondary hover:bg-surface-muted'}`}
                onClick={() => setFilter(option)}
              >
                {option}
              </button>
            ))}
          </div>

          <div className="min-h-0 flex-1 overflow-y-auto overscroll-contain">
            {notificationsQuery.isPending ? (
              <div
                className="text-body-sm text-text-secondary flex items-center justify-center gap-2 px-4 py-8"
                role="status"
              >
                <span
                  aria-hidden="true"
                  className="border-primary size-4 animate-spin rounded-full border-2 border-r-transparent"
                />
                Loading notifications
              </div>
            ) : listError ? (
              <div className="p-4">
                <Alert tone="danger" title={listError.title}>
                  <span className="block">{listError.message}</span>
                  {listError.retryable ? (
                    <Button
                      variant="outline"
                      size="sm"
                      className="mt-3"
                      onClick={() => void notificationsQuery.refetch()}
                    >
                      Try again
                    </Button>
                  ) : null}
                </Alert>
              </div>
            ) : notifications.length === 0 ? (
              <div className="px-5 py-10 text-center">
                <span className="bg-primary-subtle text-primary mx-auto flex size-10 items-center justify-center rounded-full">
                  <ShellIcon name="bell" className="size-5" />
                </span>
                <p className="text-label mt-3 font-medium">
                  {filter === 'unread' ? 'You are all caught up' : 'No notifications yet'}
                </p>
                <p className="text-caption text-text-muted mt-1">New updates will appear here.</p>
              </div>
            ) : (
              <div className="space-y-2 p-2">
                {notifications.map((notification) => {
                  const actions = notificationActions(notification, session.permissions)
                  const canOpen = canViewDetail || actions.length > 0
                  const category = notificationCategory(notification)
                  const summary = notificationContextSummary(notification)
                  const money = notificationMoneySummary(notification)
                  const priority = notificationPriorityLabel(notification.priority)
                  const toneClasses = notificationToneClasses[notificationTone(notification)]
                  return (
                    <article
                      key={notification.id}
                      className={`notification-row rounded-control shadow-elevation-sm relative overflow-hidden border ${toneClasses.surface} ${toneClasses.border}`}
                    >
                      <span
                        className={`absolute inset-y-0 left-0 w-1 ${toneClasses.rail}`}
                        aria-hidden="true"
                      />
                      <div className="flex min-w-0 items-start gap-2 p-2 pl-3">
                        {canOpen ? (
                          <button
                            type="button"
                            aria-label={`${canViewDetail ? 'View notification' : (actions[0]?.label ?? 'Open notification')}: ${notification.title}`}
                            className="group focus-visible:shadow-focus-ring rounded-control flex min-w-0 flex-1 items-start gap-3 p-2 text-left transition-colors focus-visible:outline-none"
                            onClick={() => void openNotification(notification)}
                          >
                            <span
                              className={`rounded-control mt-0.5 flex size-9 shrink-0 items-center justify-center ${toneClasses.icon}`}
                              aria-hidden="true"
                            >
                              <NotificationTypeIcon
                                name={notificationIcon(notification)}
                                className="size-[18px]"
                              />
                            </span>
                            <span className="min-w-0 flex-1">
                              <span className="flex min-w-0 flex-wrap items-center gap-1.5">
                                <span
                                  className={`text-overline rounded-pill truncate px-2 py-0.5 font-medium ${toneClasses.chip}`}
                                >
                                  {category}
                                </span>
                                {!notification.is_read ? (
                                  <span className="text-overline text-primary bg-primary-subtle rounded-pill px-2 py-0.5 font-medium">
                                    Unread
                                  </span>
                                ) : null}
                                {priority ? (
                                  <span
                                    className={`text-overline rounded-pill px-1.5 py-0.5 font-medium ${notification.priority.toLowerCase() === 'critical' ? 'bg-danger-subtle text-danger-foreground' : 'bg-warning-subtle text-warning-foreground'}`}
                                  >
                                    {priority}
                                  </span>
                                ) : null}
                              </span>
                              <span className="text-body-sm text-text-primary group-hover:text-primary mt-1 block leading-5 font-semibold">
                                {notification.title}
                              </span>
                              <span className="text-caption text-text-secondary mt-1 line-clamp-2 block leading-4 whitespace-pre-line">
                                {notification.message}
                              </span>
                              {money ? (
                                <span className="text-caption text-text-primary bg-surface-muted rounded-control mt-2 inline-flex max-w-full items-center gap-2 px-2.5 py-1 font-medium">
                                  <NotificationTypeIcon
                                    name="money"
                                    className="size-3.5 shrink-0"
                                  />
                                  <span className="truncate">
                                    {money.label}: {money.formatted}
                                  </span>
                                </span>
                              ) : summary ? (
                                <span className="text-caption text-text-muted mt-1.5 block truncate">
                                  {summary}
                                </span>
                              ) : null}
                              <span className="text-caption text-text-muted mt-2 flex items-center justify-between gap-2">
                                <time dateTime={notification.created_at}>
                                  {notificationDate(notification.created_at, true)}
                                </time>
                                <span className="text-primary inline-flex shrink-0 items-center gap-1 font-semibold">
                                  {canViewDetail
                                    ? 'View notification'
                                    : (actions[0]?.label ?? 'Open notification')}
                                  <ShellIcon name="chevron" className="size-3.5" />
                                </span>
                              </span>
                            </span>
                          </button>
                        ) : (
                          <div className="rounded-control flex min-w-0 flex-1 items-start gap-3 p-2">
                            <span
                              className="bg-surface-muted text-text-secondary mt-0.5 flex size-9 shrink-0 items-center justify-center rounded-full"
                              aria-hidden="true"
                            >
                              <NotificationTypeIcon
                                name={notificationIcon(notification)}
                                className="size-[18px]"
                              />
                            </span>
                            <span className="min-w-0 flex-1">
                              <span className="text-overline text-text-secondary">{category}</span>
                              <span className="text-body-sm text-text-primary mt-1 block font-semibold">
                                {notification.title}
                              </span>
                              <span className="text-caption text-text-secondary mt-1 line-clamp-2 block">
                                {notification.message}
                              </span>
                              <time
                                className="text-caption text-text-muted mt-2 block"
                                dateTime={notification.created_at}
                              >
                                {notificationDate(notification.created_at, true)}
                              </time>
                            </span>
                          </div>
                        )}
                        {!notification.is_read && canMarkRead ? (
                          <button
                            type="button"
                            aria-label={`Mark ${notification.title} as read`}
                            title="Mark as read"
                            className="notification-read-action focus-visible:shadow-focus-ring text-text-muted hover:text-primary rounded-control size-10 shrink-0 items-center justify-center self-start focus-visible:outline-none"
                            onClick={() => markRead(notification.id)}
                          >
                            <ShellIcon name="read" className="size-4" />
                          </button>
                        ) : null}
                      </div>
                      {canViewDetail && actions[0] ? (
                        <div className="flex justify-end px-3 pb-2">
                          <Button
                            variant="ghost"
                            size="sm"
                            leadingIcon={<ShellIcon name="chevron" className="size-3.5" />}
                            aria-label={`${actions[0].label}: ${notification.title}`}
                            onClick={() => void openRelated(notification)}
                          >
                            {actions[0].label}
                          </Button>
                        </div>
                      ) : null}
                    </article>
                  )
                })}
              </div>
            )}
          </div>

          <footer className="border-border-subtle shrink-0 space-y-2 border-t p-3">
            {notificationsQuery.hasNextPage ? (
              <Button
                variant="ghost"
                className="min-h-10 w-full"
                isLoading={notificationsQuery.isFetchingNextPage}
                onClick={() => void notificationsQuery.fetchNextPage()}
              >
                Load older notifications
              </Button>
            ) : null}
            <Button
              variant="outline"
              className="min-h-11 w-full justify-between px-4"
              onClick={() => {
                setOpen(false)
                void navigate({ to: '/notifications', search: { filter: 'all' } })
              }}
            >
              <span className="inline-flex items-center gap-2">
                <ShellIcon name="bell" className="size-4" />
                View all notifications
              </span>
              <ShellIcon name="chevron" className="size-4" />
            </Button>
          </footer>

          {mutationError ? (
            <div className="border-border-subtle border-t p-3">
              <Alert tone="danger" title={mutationError.title}>
                {mutationError.message}
              </Alert>
            </div>
          ) : null}
        </section>
      ) : null}
    </div>
  )
}

const ANNOUNCED_IDS_KEY = 'bomach.notifications.announced.v1'

function announcedIdsStorageKey(userId: number) {
  return `${ANNOUNCED_IDS_KEY}.${userId}`
}

function readAnnouncedIds(userId: number): number[] {
  try {
    const raw = window.localStorage.getItem(announcedIdsStorageKey(userId))
    if (!raw) return []
    const parsed: unknown = JSON.parse(raw)
    return Array.isArray(parsed)
      ? parsed.filter((id): id is number => Number.isSafeInteger(id) && id > 0)
      : []
  } catch {
    return []
  }
}

function claimUnannouncedIds(userId: number, ids: number[]) {
  const storedIds = readAnnouncedIds(userId)
  const stored = new Set(storedIds)
  const claimed = ids.filter((id) => !stored.has(id))
  if (!claimed.length) return claimed
  try {
    window.localStorage.setItem(
      announcedIdsStorageKey(userId),
      JSON.stringify([...storedIds, ...claimed].slice(-100)),
    )
  } catch {
    // In-app alerts still work when browser storage is unavailable.
  }
  return claimed
}

interface ArrivalTracker {
  userId: number
  ready: boolean
  ids: Set<number>
}

/** Polls only while the authenticated app is visible; this is in-app delivery, not Web Push. */
export function NotificationDeliveryBridge({ session }: { session: AuthenticatedSession }) {
  const queryClient = useQueryClient()
  const navigate = useNavigate()
  const { showToast } = useToast()
  const userId = session.user.id
  const canList = hasPermission(session.permissions, 'notifications', 'list')
  const canViewDetail = hasPermission(session.permissions, 'notifications', 'view')
  const trackerRef = useRef<ArrivalTracker>({ userId, ready: false, ids: new Set() })
  const channelRef = useRef<BroadcastChannel | null>(null)

  const arrivalsQuery = useQuery({
    queryKey: notificationKeys.arrivals(userId),
    queryFn: ({ signal }) => notificationApi.list({ limit: 20, offset: 0, signal }),
    enabled: canList,
    staleTime: DATA_FRESHNESS_MS.live,
    refetchOnWindowFocus: 'always',
    refetchOnReconnect: true,
    refetchInterval: () => (document.visibilityState === 'visible' ? 60_000 : false),
    refetchIntervalInBackground: false,
  })
  const refetchArrivals = arrivalsQuery.refetch

  useEffect(() => {
    trackerRef.current = { userId, ready: false, ids: new Set() }
  }, [userId])

  useEffect(() => {
    if (!canList) return
    const channelName = `bomach-notification-arrivals-${userId}`
    let channel: BroadcastChannel | null = null
    if ('BroadcastChannel' in window) {
      try {
        channel = new BroadcastChannel(channelName)
        channelRef.current = channel
        channel.onmessage = (event: MessageEvent<unknown>) => {
          if (
            !event.data ||
            typeof event.data !== 'object' ||
            !('ids' in event.data) ||
            !Array.isArray(event.data.ids)
          ) {
            return
          }
          for (const id of event.data.ids) {
            if (Number.isSafeInteger(id) && id > 0) trackerRef.current.ids.add(id)
          }
          void queryClient.invalidateQueries({ queryKey: notificationKeys.lists(userId) })
          void queryClient.invalidateQueries({ queryKey: notificationKeys.overview(userId) })
          void queryClient.invalidateQueries({ queryKey: notificationKeys.stats(userId) })
        }
      } catch {
        channel = null
        channelRef.current = null
      }
    }

    const onStorage = (event: StorageEvent) => {
      if (event.key !== announcedIdsStorageKey(userId) || !event.newValue) return
      try {
        const parsed: unknown = JSON.parse(event.newValue)
        if (Array.isArray(parsed)) {
          for (const id of parsed) {
            if (Number.isSafeInteger(id) && id > 0) trackerRef.current.ids.add(id)
          }
        }
      } catch {
        // Ignore an invalid cross-tab cache notice; the user-facing query remains authoritative.
      }
    }
    const onVisibilityChange = () => {
      if (document.visibilityState === 'visible') void refetchArrivals()
    }

    window.addEventListener('storage', onStorage)
    document.addEventListener('visibilitychange', onVisibilityChange)
    return () => {
      window.removeEventListener('storage', onStorage)
      document.removeEventListener('visibilitychange', onVisibilityChange)
      channel?.close()
      if (channelRef.current === channel) channelRef.current = null
    }
  }, [canList, queryClient, refetchArrivals, userId])

  useEffect(() => {
    const page = arrivalsQuery.data
    if (!canList || !page || !Array.isArray(page.items)) return
    const tracker = trackerRef.current
    const ordered = [...page.items].sort(
      (left, right) => new Date(right.created_at).getTime() - new Date(left.created_at).getTime(),
    )

    if (!tracker.ready) {
      ordered.forEach(({ id }) => tracker.ids.add(id))
      tracker.ready = true
      return
    }

    const unseen = ordered.filter(({ id }) => !tracker.ids.has(id))
    if (!unseen.length) return
    unseen.forEach(({ id }) => tracker.ids.add(id))
    const claimedIds = claimUnannouncedIds(
      userId,
      unseen.map(({ id }) => id),
    )
    if (!claimedIds.length) return

    const latest = unseen.find(({ id }) => id === claimedIds[0]) ?? unseen[0]!
    const relatedAction = notificationActions(latest, session.permissions)[0]
    const actionLabel =
      relatedAction?.label ?? (canViewDetail ? 'View notification' : 'View notifications')

    channelRef.current?.postMessage({ ids: claimedIds })
    void queryClient.invalidateQueries({ queryKey: notificationKeys.lists(userId) })
    void queryClient.invalidateQueries({ queryKey: notificationKeys.overview(userId) })
    void queryClient.invalidateQueries({ queryKey: notificationKeys.stats(userId) })
    showToast({
      title:
        claimedIds.length === 1 ? 'New notification' : `${claimedIds.length} new notifications`,
      description:
        claimedIds.length === 1
          ? latest.title
          : `${latest.title} and ${claimedIds.length - 1} more updates`,
      tone: 'info',
      action: {
        label: actionLabel,
        onClick: () => {
          if (relatedAction) {
            void navigate({ to: relatedAction.href as never })
          } else if (canViewDetail) {
            void navigate({
              to: '/notifications/$notificationId',
              params: { notificationId: String(latest.id) },
              search: { filter: 'all' },
            })
          } else {
            void navigate({ to: '/notifications', search: { filter: 'all' } })
          }
        },
      },
    })
  }, [
    arrivalsQuery.data,
    canList,
    canViewDetail,
    navigate,
    queryClient,
    session.permissions,
    showToast,
    userId,
  ])

  return null
}
