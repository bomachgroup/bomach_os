import { apiClient } from '@/shared/api/api-client'

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

export const notificationApi = {
  list: ({ limit, offset, isRead, signal }: NotificationListParams) => {
    const query = new URLSearchParams({ limit: String(limit), offset: String(offset) })
    if (isRead !== undefined) query.set('is_read', String(isRead))
    return apiClient.get<NotificationPageDto>(`/notifications/?${query.toString()}`, { signal })
  },

  stats: (signal?: AbortSignal) =>
    apiClient.get<NotificationStatsDto>('/notifications/stats', { signal }),

  markRead: (notificationId: number) =>
    apiClient.patch<NotificationDto>(`/notifications/${notificationId}/read`),

  markAllRead: () => apiClient.post<{ detail: string }>('/notifications/read-all'),
}
