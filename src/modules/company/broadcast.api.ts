import { apiClient } from '@/shared/api/api-client'

export interface ChoiceDto {
  value: string
  label: string
}

export interface ApiPage<T> {
  count: number
  items: T[]
  limit?: number
  offset?: number
}

export interface BroadcastListParams {
  limit: number
  offset: number
  search: string
  isActive?: boolean
}

export interface AnnouncementDto {
  id: number
  announcement_id: string
  title: string
  content: string
  announcement_type: string
  announcement_type_display: string
  priority: string
  priority_display: string
  branches: { id: number; branch_name: string; branch_id: string }[]
  departments: { id: number; name: string }[]
  targets_all_branches: boolean
  targets_all_departments: boolean
  created_by_id: number | null
  created_by_name: string | null
  is_active: boolean
  publish_at: string | null
  expires_at: string | null
  created_at: string
  updated_at: string
}

export interface AnnouncementInput {
  title: string
  content: string
  announcement_type: string
  priority: string
  branch_ids: number[]
  department_ids: number[]
  is_active: boolean
  publish_at: string | null
  expires_at: string | null
}

export interface AnnouncementChoicesDto {
  announcement_types: ChoiceDto[]
  priorities: ChoiceDto[]
}

export interface EventDto {
  id: number
  event_id: string
  title: string
  event_type: string
  event_type_display: string
  event_time_from: string
  event_time_to: string
  event_time_from_iso: string
  event_time_to_iso: string
  meeting_location: string | null
  target_audience: string[]
  target_all_branches: boolean
  target_all_departments: boolean
  target_associates: boolean
  target_investors: boolean
  target_partners: boolean
  status: string
  reminder_offset: string
  is_recurring: boolean
  recurrence: string
  organizer_id: number | null
  organizer_name: string
  date_sent: string
  created_at: string
  updated_at: string
}

export interface EventInput {
  title: string
  event_type: string
  event_time_from: string
  event_time_to: string
  meeting_location: string | null
  target_all_branches: boolean
  target_all_departments: boolean
  target_associates: boolean
  target_investors: boolean
  target_partners: boolean
  reminder_offset: number | null
  recurrence: string | null
}

export interface EventChoicesDto {
  event_types: ChoiceDto[]
}

function listParams(params: BroadcastListParams) {
  const query = new URLSearchParams({ limit: String(params.limit), offset: String(params.offset) })
  if (params.search.trim()) query.set('search', params.search.trim())
  if (params.isActive !== undefined) query.set('is_active', String(params.isActive))
  return query
}

export const broadcastApi = {
  announcementChoices: (signal?: AbortSignal) =>
    apiClient.get<AnnouncementChoicesDto>('/announcements/choices', { signal }),
  announcements: (params: BroadcastListParams, signal?: AbortSignal) =>
    apiClient.get<ApiPage<AnnouncementDto>>(`/announcements/?${listParams(params)}`, { signal }),
  announcement: (id: number, signal?: AbortSignal) =>
    apiClient.get<AnnouncementDto>(`/announcements/${id}`, { signal }),
  createAnnouncement: (input: AnnouncementInput) =>
    apiClient.post<AnnouncementDto>('/announcements/', input),
  updateAnnouncement: (id: number, input: Partial<AnnouncementInput>) =>
    apiClient.put<AnnouncementDto>(`/announcements/${id}`, input),
  deactivateAnnouncement: (id: number) =>
    apiClient.delete<{ detail: string }>(`/announcements/${id}`),
  eventChoices: (signal?: AbortSignal) =>
    apiClient.get<EventChoicesDto>('/events/choices', { signal }),
  events: (params: BroadcastListParams, signal?: AbortSignal) =>
    apiClient.get<ApiPage<EventDto>>(`/events/?${listParams(params)}`, { signal }),
  event: (id: number, signal?: AbortSignal) => apiClient.get<EventDto>(`/events/${id}`, { signal }),
  createEvent: (input: EventInput) => apiClient.post<EventDto>('/events/', input),
  updateEvent: (id: number, input: Partial<EventInput>) =>
    apiClient.put<EventDto>(`/events/${id}`, input),
  deleteEvent: (id: number) => apiClient.delete<void>(`/events/${id}`),
}

export const broadcastQueryKeys = {
  all: ['company', 'broadcast'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...broadcastQueryKeys.all, userId, employeeId] as const,
  announcements: (userId: number, employeeId: string) =>
    [...broadcastQueryKeys.scoped(userId, employeeId), 'announcements'] as const,
  announcementList: (userId: number, employeeId: string, params: BroadcastListParams) =>
    [...broadcastQueryKeys.announcements(userId, employeeId), 'list', params] as const,
  announcementChoices: (userId: number, employeeId: string) =>
    [...broadcastQueryKeys.announcements(userId, employeeId), 'choices'] as const,
  events: (userId: number, employeeId: string) =>
    [...broadcastQueryKeys.scoped(userId, employeeId), 'events'] as const,
  eventList: (userId: number, employeeId: string, params: BroadcastListParams) =>
    [...broadcastQueryKeys.events(userId, employeeId), 'list', params] as const,
  eventChoices: (userId: number, employeeId: string) =>
    [...broadcastQueryKeys.events(userId, employeeId), 'choices'] as const,
}
