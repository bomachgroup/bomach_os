import { apiClient } from '@/shared/api/api-client'
import { ApiError } from '@/shared/api/api-error'

export interface NotificationDto {
  id: number
  title: string
  message: string
  notification_type: string
  is_read: boolean
  link: string
  metadata: Record<string, unknown>
  created_at: string
  event_type: string | null
  priority: string
  action: string
  entity_type: string
  entity_id: string
}

export interface NotificationPageDto {
  count: number
  items: NotificationDto[]
}

export interface NotificationStatsDto {
  unread_count: number
}

export interface NotificationListParams {
  limit: number
  offset: number
  isRead?: boolean
  signal?: AbortSignal
}

export const notificationKeys = {
  all: ['notifications'] as const,
  account: (userId: number) => ['notifications', userId] as const,
  stats: (userId: number) => ['notifications', userId, 'stats'] as const,
  lists: (userId: number) => ['notifications', userId, 'list'] as const,
  overview: (userId: number) => ['notifications', userId, 'overview'] as const,
  list: (userId: number, filter: 'all' | 'unread', limit: number) =>
    ['notifications', userId, 'list', filter, limit] as const,
  arrivals: (userId: number) => ['notifications', userId, 'arrivals'] as const,
  detail: (userId: number, notificationId: number) =>
    ['notifications', userId, 'detail', notificationId] as const,
}

export const notificationApi = {
  list: async ({ limit, offset, isRead, signal }: NotificationListParams) => {
    const query = new URLSearchParams({ limit: String(limit), offset: String(offset) })
    if (isRead !== undefined) query.set('is_read', String(isRead))
    const page = await apiClient.get<unknown>(`/notifications/?${query.toString()}`, { signal })
    if (
      !page ||
      typeof page !== 'object' ||
      !('items' in page) ||
      !Array.isArray(page.items) ||
      !('count' in page) ||
      typeof page.count !== 'number'
    ) {
      throw new ApiError('The server returned an invalid notification list.', {
        status: 200,
        code: 'INVALID_RESPONSE',
      })
    }
    return page as NotificationPageDto
  },

  stats: (signal?: AbortSignal) =>
    apiClient.get<NotificationStatsDto>('/notifications/stats', { signal }),

  get: (notificationId: number, signal?: AbortSignal) =>
    apiClient.get<NotificationDto>(`/notifications/${notificationId}`, { signal }),

  markRead: (notificationId: number) =>
    apiClient.patch<NotificationDto>(`/notifications/${notificationId}/read`),

  markAllRead: () => apiClient.post<{ detail: string }>('/notifications/read-all'),
}
