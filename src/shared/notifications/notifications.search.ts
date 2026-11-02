export type NotificationFilter = 'all' | 'unread'

export function validateNotificationsSearch(search: Record<string, unknown>) {
  return { filter: search.filter === 'unread' ? 'unread' : 'all' } as const
}
