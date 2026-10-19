import { useEffect, useId, useRef, useState } from 'react'
import { useInfiniteQuery, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate } from '@tanstack/react-router'

import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { hasPermission, type AuthenticatedSession } from '@/shared/auth/session'
import { canVisitDestination, destinationForPath } from '@/app/navigation/route-manifest'
import { notificationApi, type NotificationDto } from '@/shared/notifications/notifications.api'
import { ShellIcon } from './shell-icons'

function notificationTarget(link: string, permissions: AuthenticatedSession['permissions']) {
  if (!link) return undefined
  try {
    const url = new URL(link, window.location.origin)
    if (url.origin !== window.location.origin) return undefined
    const destination = destinationForPath(url.pathname)
    if (!destination || !canVisitDestination(destination, permissions)) return undefined
    return `${url.pathname}${url.search}${url.hash}`
  } catch {
    return undefined
  }
}

function notificationDate(value: string) {
  const date = new Date(value)
  if (!Number.isFinite(date.getTime())) return 'Recently'
  return new Intl.DateTimeFormat(undefined, {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(date)
}

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
  const canMarkRead = hasPermission(session.permissions, 'notifications', 'mark_read')
  const canMarkAllRead = hasPermission(session.permissions, 'notifications', 'mark_all_read')

  const statsQuery = useQuery({
    queryKey: ['notifications', 'stats'],
    queryFn: ({ signal }) => notificationApi.stats(signal),
    enabled: canViewCount,
    staleTime: 30_000,
    refetchInterval: open ? 30_000 : 60_000,
  })
  const notificationsQuery = useInfiniteQuery({
    queryKey: ['notifications', 'list', filter],
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
    staleTime: 30_000,
  })

  const markReadMutation = useMutation({
    mutationFn: notificationApi.markRead,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['notifications'] }),
  })
  const markAllReadMutation = useMutation({
    mutationFn: notificationApi.markAllRead,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['notifications'] }),
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

  function markRead(notificationId: number) {
    if (canMarkRead) markReadMutation.mutate(notificationId)
  }

  async function openNotification(notification: NotificationDto) {
    const target = notificationTarget(notification.link, session.permissions)
    if (!target) {
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
    setOpen(false)
    void navigate({ to: target as never })
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
          className={`bg-surface border-border-subtle shadow-elevation-lg rounded-surface absolute z-50 flex max-h-[min(72dvh,38rem)] w-[min(24rem,calc(100vw-1rem))] flex-col overflow-hidden border ${placement === 'sidebar' ? 'top-0 left-full ml-2' : 'top-[calc(100%+0.5rem)] right-0'}`}
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
            {canMarkAllRead && (unreadCount ?? 0) > 0 ? (
              <Button
                variant="ghost"
                size="sm"
                className="text-primary shrink-0"
                disabled={markAllReadMutation.isPending}
                onClick={() => markAllReadMutation.mutate()}
              >
                Mark all read
              </Button>
            ) : null}
          </header>

          <div className="border-border-subtle flex shrink-0 gap-2 border-b px-4 py-2">
            {(['all', 'unread'] as const).map((option) => (
              <button
                key={option}
                type="button"
                aria-pressed={filter === option}
                className={`rounded-full px-3 py-1.5 text-xs font-medium capitalize transition-colors ${filter === option ? 'bg-primary-subtle text-primary' : 'text-text-secondary hover:bg-surface-muted'}`}
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
            ) : notificationsQuery.isError ? (
              <div className="p-4">
                <Alert tone="danger" title="Notifications could not be loaded">
                  <span className="block">Check your connection and try again.</span>
                  <Button
                    variant="outline"
                    size="sm"
                    className="mt-3"
                    onClick={() => void notificationsQuery.refetch()}
                  >
                    Try again
                  </Button>
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
              <div className="divide-border-subtle divide-y">
                {notifications.map((notification) => {
                  const target = notificationTarget(notification.link, session.permissions)
                  return (
                    <article
                      key={notification.id}
                      className={`notification-row flex gap-3 px-4 py-3 ${notification.is_read ? '' : 'bg-primary-subtle/35'}`}
                    >
                      <span
                        className={`mt-0.5 flex size-8 shrink-0 items-center justify-center rounded-full ${notification.is_read ? 'bg-surface-muted text-text-secondary' : 'bg-primary-subtle text-primary'}`}
                        aria-hidden="true"
                      >
                        <ShellIcon name="bell" className="size-4" />
                      </span>
                      <div className="min-w-0 flex-1">
                        {target ? (
                          <button
                            type="button"
                            className="focus-visible:shadow-focus-ring text-left focus-visible:outline-none"
                            onClick={() => void openNotification(notification)}
                          >
                            <span className="text-label block font-semibold">
                              {notification.title}
                            </span>
                          </button>
                        ) : (
                          <p className="text-label font-semibold">{notification.title}</p>
                        )}
                        <p className="text-body-sm text-text-secondary mt-1 line-clamp-3">
                          {notification.message}
                        </p>
                        <time
                          className="text-caption text-text-muted mt-1.5 block"
                          dateTime={notification.created_at}
                        >
                          {notificationDate(notification.created_at)}
                        </time>
                      </div>
                      {!notification.is_read && canMarkRead ? (
                        <button
                          type="button"
                          aria-label={`Mark ${notification.title} as read`}
                          title="Mark as read"
                          className="notification-read-action focus-visible:shadow-focus-ring text-text-muted hover:text-primary rounded-control size-8 shrink-0 items-center justify-center focus-visible:outline-none"
                          onClick={() => markRead(notification.id)}
                        >
                          <ShellIcon name="read" className="size-4" />
                        </button>
                      ) : null}
                    </article>
                  )
                })}
              </div>
            )}
          </div>

          {notificationsQuery.hasNextPage ? (
            <footer className="border-border-subtle shrink-0 border-t p-2">
              <Button
                variant="ghost"
                className="w-full"
                isLoading={notificationsQuery.isFetchingNextPage}
                onClick={() => void notificationsQuery.fetchNextPage()}
              >
                Load older notifications
              </Button>
            </footer>
          ) : null}

          {markReadMutation.isError || markAllReadMutation.isError ? (
            <div className="border-border-subtle border-t p-3">
              <Alert tone="danger" title="Could not update notification">
                Try again in a moment.
              </Alert>
            </div>
          ) : null}
        </section>
      ) : null}
    </div>
  )
}
