import { apiClient } from '@/shared/api/api-client'

export type PartnerRole = 'realtor' | 'surveyor' | 'lawyer' | 'consultant'

export interface PartnerAdminDto {
  id: number
  code: string | null
  name: string
  email: string
  phone: string
  address: string
  category: string
  status: string
  status_display: string
  kyc_status: string
  kyc_status_display: string
  commission_rate: number
  partner_role: PartnerRole
  partner_role_display: string
  primary_branch_id: number | null
  primary_branch_name: string | null
  authorized_branch_ids: number[]
  has_login: boolean
  created_at: string
  updated_at: string
}

export interface PartnerInvitationDto {
  id: number
  partner_id?: number
  partner_name?: string
  partner_role?: PartnerRole
  email: string
  status: 'sent' | 'accepted' | 'expired' | 'revoked' | string
  delivery_status?: 'pending' | 'sent' | 'failed' | string
  delivery_error?: string
  expires_at: string
  setup_completed_at?: string | null
  last_sent_at?: string | null
  created_at?: string
}

export interface PartnerPage<T> {
  count: number
  items: T[]
}

export interface PartnerInvitationChoices {
  branches: Array<{ id: number; name: string; code: string }>
  roles: Array<{ value: PartnerRole; label: string }>
}

export interface PartnerInvitationInput {
  name?: string
  email: string
  phone?: string
  partner_role: PartnerRole
  branch_id: number
  commission_rate?: number
  territory?: string
  contact_employee_ids?: number[]
  primary_contact_employee_id?: number | null
}

export interface PartnerContactCandidate {
  employee_id: number
  staff_user_id: number
  name: string
  email: string
  designation: string
}

export interface PartnerContactDto extends PartnerContactCandidate {
  is_primary: boolean
  assigned_at?: string
  removed_at?: string | null
}

export interface PartnerEffectiveContact {
  staff_user_id: number
  name: string
  designation: string
  is_primary: boolean
  source: 'assigned' | 'inviter' | string
}

export interface PartnerConversationDto {
  id: number
  partner_id: number
  kind: 'direct' | 'unassigned' | 'legacy' | string
  status: 'active' | 'queued' | 'read_only' | 'merged' | string
  staff_user_id: number | null
  staff_name: string
  last_message_at: string | null
  can_reply: boolean
  can_claim?: boolean
  merged_into_id: number | null
  partner_name?: string
  partner_code?: string | null
}

export interface PartnerConversationList {
  contacts: Array<{
    staff_user_id: number
    name: string
    designation: string
    is_primary: boolean
    source: 'assigned' | 'inviter' | string
  }>
  conversations: PartnerConversationDto[]
  primary_staff_user_id: number | null
  support_available: boolean
}

export interface PartnerProfileDto {
  id: number
  code: string
  name: string
  email: string
  phone: string
  address: string
  category: string
  partner_role: PartnerRole
  status: string
  kyc_status: string
  commission_rate: number
  territory: string
  primary_branch_id: number | null
  branches: Array<{ id: number; branch_name: string; branch_id?: string }>
  profile_completed: boolean
  profile_completed_at: string | null
  capabilities: Record<string, boolean>
}

export interface PartnerLeadPreview {
  id: number
  full_name: string
  status: string
  status_display: string
  branch_name: string | null
  next_action: string
  next_follow_up_at: string | null
  created_at: string
}

export interface PartnerJobPreview {
  id: number
  code: string
  workflow_type: string
  title: string
  scope: string
  due_date: string | null
  approved_fee: number | string
  status: string
  report_status: string | null
  deliverables: Array<{ id: number; title: string; status: string }>
}

export interface PartnerNotificationDto {
  id: number
  title: string
  message: string
  notification_type: string
  is_read: boolean
  link: string
  metadata: Record<string, unknown>
  priority: string
  action: string
  entity_type: string
  entity_id: string
  created_at: string
}

export interface PartnerMessageDto {
  id: number
  subject: string
  body: string
  is_from_partner: boolean
  is_read: boolean
  created_at: string
  conversation_id?: number | null
  sender_name?: string
  sender_type?: 'partner' | 'staff' | string
  attachments?: Array<{
    id: number
    original_filename: string
    content_type: string
    size: number
    download_url: string
    preview_url?: string
  }>
}

function buildMessageRequest(input: { body: string; files?: File[] }) {
  if (!input.files?.length) return { subject: '', body: input.body }
  const form = new FormData()
  form.append('subject', '')
  form.append('body', input.body)
  input.files.forEach((file) => form.append('files', file, file.name))
  return form
}

export interface PartnerCatalogueDto {
  estates: Array<{ id: number; name: string; code: string; city_town: string; state: string }>
  properties: Array<{
    id: number
    name: string
    estate_name: string | null
    price: number | string
  }>
  brokerage_listings: Array<{ id: number; title: string; location: string; price: number | string }>
}

function params(values: Record<string, string | number | undefined>) {
  const search = new URLSearchParams()
  Object.entries(values).forEach(([key, value]) => {
    if (value !== undefined && value !== '') search.set(key, String(value))
  })
  return search.toString()
}

export const partnerAdminApi = {
  partners: (input: { limit: number; offset: number; search?: string }, signal?: AbortSignal) =>
    apiClient.get<PartnerPage<PartnerAdminDto>>(`/partners/?${params(input)}`, { signal }),
  partner: (id: number, signal?: AbortSignal) =>
    apiClient.get<PartnerAdminDto>(`/partners/${id}`, { signal }),
  invitations: (
    input: { limit: number; offset: number; search?: string; status?: string },
    signal?: AbortSignal,
  ) =>
    apiClient.get<PartnerPage<PartnerInvitationDto>>(`/partners/invitations?${params(input)}`, {
      signal,
    }),
  invitationChoices: (signal?: AbortSignal) =>
    apiClient.get<PartnerInvitationChoices>('/partners/invitations/choices', { signal }),
  invitationContacts: (branchId: number, signal?: AbortSignal) =>
    apiClient.get<{ items: PartnerContactCandidate[] }>(
      `/partners/invitations/contacts?branch_id=${branchId}`,
      { signal },
    ),
  invite: (input: PartnerInvitationInput) =>
    apiClient.post<{ partner: PartnerAdminDto; invitation: PartnerInvitationDto }>(
      '/partners/invitations',
      input,
    ),
  resend: (id: number) =>
    apiClient.post<{ partner: PartnerAdminDto; invitation: PartnerInvitationDto }>(
      `/partners/invitations/${id}/resend`,
    ),
  revoke: (id: number) =>
    apiClient.post<{ id: number; status: string }>(`/partners/invitations/${id}/revoke`),
  contacts: (partnerId: number, signal?: AbortSignal) =>
    apiClient.get<{
      contacts: PartnerContactDto[]
      history: PartnerContactDto[]
      effective_contacts: PartnerEffectiveContact[]
      eligible_staff: PartnerContactCandidate[]
    }>(`/partners/${partnerId}/contacts`, { signal }),
  updateContacts: (
    partnerId: number,
    input: { employee_ids: number[]; primary_employee_id: number | null },
  ) => apiClient.put<{ contacts: PartnerContactDto[] }>(`/partners/${partnerId}/contacts`, input),
  conversations: (partnerId: number, signal?: AbortSignal) =>
    apiClient.get<PartnerConversationDto[]>(`/partners/${partnerId}/conversations`, { signal }),
  staffConversationMessages: (partnerId: number, conversationId: number, signal?: AbortSignal) =>
    apiClient.get<PartnerMessageDto[]>(
      `/partners/${partnerId}/conversations/${conversationId}/messages?limit=100&offset=0`,
      { signal },
    ),
  startStaffConversation: (partnerId: number) =>
    apiClient.post<PartnerConversationDto>(`/partners/${partnerId}/conversations`),
  claimConversation: (partnerId: number, conversationId: number) =>
    apiClient.post<PartnerConversationDto>(
      `/partners/${partnerId}/conversations/${conversationId}/claim`,
    ),
  sendStaffConversationMessage: (
    partnerId: number,
    conversationId: number,
    input: { body: string; files?: File[] },
  ) => {
    const path = `/partners/${partnerId}/conversations/${conversationId}/messages`
    const request = buildMessageRequest(input)
    return input.files?.length
      ? apiClient.post<PartnerMessageDto>(`${path}/with-attachments`, request)
      : apiClient.post<PartnerMessageDto>(path, request)
  },
  markStaffConversationRead: (partnerId: number, conversationId: number) =>
    apiClient.post<{ conversation_id: number; updated_count: number }>(
      `/partners/${partnerId}/conversations/${conversationId}/read`,
    ),
  unassignedConversations: (signal?: AbortSignal) =>
    apiClient.get<PartnerConversationDto[]>('/partners/message-queue/unassigned', { signal }),
}

export const partnerPortalApi = {
  completeSetup: (input: { setup_token: string; new_password: string }) =>
    apiClient.post<{
      success: true
      detail: string
      partner_id: number
      user_id: number
      email: string
    }>('/auth/partner-setup/complete', input, { skipRefresh: true }),
  me: (signal?: AbortSignal) => apiClient.get<PartnerProfileDto>('/partner/me', { signal }),
  updateProfile: (input: { name: string; phone: string; address?: string }) =>
    apiClient.patch<
      Pick<
        PartnerProfileDto,
        'id' | 'name' | 'email' | 'phone' | 'address' | 'profile_completed' | 'profile_completed_at'
      >
    >('/partner/profile', input),
  leads: (signal?: AbortSignal) =>
    apiClient.get<PartnerLeadPreview[]>('/partner/leads', { signal }),
  catalogue: (signal?: AbortSignal) =>
    apiClient.get<PartnerCatalogueDto>('/partner/catalogue', { signal }),
  earnings: (signal?: AbortSignal) =>
    apiClient.get<Array<{ id: number; status: string; commission_due: number | string }>>(
      '/partner/earnings',
      { signal },
    ),
  jobs: (signal?: AbortSignal) => apiClient.get<PartnerJobPreview[]>('/partner/jobs', { signal }),
  notifications: (signal?: AbortSignal) =>
    apiClient.get<PartnerNotificationDto[]>('/partner/notifications?limit=50&offset=0', { signal }),
  markNotificationRead: (id: number) =>
    apiClient.post<{ id: number; is_read: boolean }>(`/partner/notifications/${id}/read`),
  markAllNotificationsRead: () =>
    apiClient.post<{ updated_count: number }>('/partner/notifications/read-all'),
  unreadNotificationCount: (signal?: AbortSignal) =>
    apiClient.get<{ unread_count: number }>('/partner/notifications/unread-count', { signal }),
  messages: (signal?: AbortSignal) =>
    apiClient.get<PartnerMessageDto[]>('/partner/messages?limit=50&offset=0', { signal }),
  sendMessage: (input: { subject: string; body: string }) =>
    apiClient.post<PartnerMessageDto>('/partner/messages', input),
  conversations: (signal?: AbortSignal) =>
    apiClient.get<PartnerConversationList>('/partner/conversations', { signal }),
  startConversation: (staffUserId?: number) =>
    apiClient.post<PartnerConversationDto>(
      '/partner/conversations',
      staffUserId === undefined ? {} : { staff_user_id: staffUserId },
    ),
  conversationMessages: (conversationId: number, signal?: AbortSignal) =>
    apiClient.get<PartnerMessageDto[]>(
      `/partner/conversations/${conversationId}/messages?limit=100&offset=0`,
      { signal },
    ),
  sendConversationMessage: (conversationId: number, input: { body: string; files?: File[] }) => {
    const path = `/partner/conversations/${conversationId}/messages`
    const request = buildMessageRequest(input)
    return input.files?.length
      ? apiClient.post<PartnerMessageDto>(`${path}/with-attachments`, request)
      : apiClient.post<PartnerMessageDto>(path, request)
  },
  markConversationRead: (conversationId: number) =>
    apiClient.post<{ conversation_id: number; updated_count: number }>(
      `/partner/conversations/${conversationId}/read`,
    ),
  markMessageRead: (id: number) =>
    apiClient.post<{ id: number; is_read: boolean }>(`/partner/messages/${id}/read`),
  unreadMessageCount: (signal?: AbortSignal) =>
    apiClient.get<{ unread_count: number }>('/partner/messages/unread-count', { signal }),
}

const PARTNER_QUERY_ROOT = ['partner-workspace'] as const

export const partnerQueryKeys = {
  all: PARTNER_QUERY_ROOT,
  directory: (search: string) => [...PARTNER_QUERY_ROOT, 'directory', search] as const,
  invitations: (search: string) => [...PARTNER_QUERY_ROOT, 'invitations', search] as const,
  me: [...PARTNER_QUERY_ROOT, 'me'] as const,
  leads: [...PARTNER_QUERY_ROOT, 'leads'] as const,
  catalogue: [...PARTNER_QUERY_ROOT, 'catalogue'] as const,
  earnings: [...PARTNER_QUERY_ROOT, 'earnings'] as const,
  jobs: [...PARTNER_QUERY_ROOT, 'jobs'] as const,
  notifications: [...PARTNER_QUERY_ROOT, 'notifications'] as const,
  messages: [...PARTNER_QUERY_ROOT, 'messages'] as const,
  unassignedConversations: (userId: number) =>
    [...PARTNER_QUERY_ROOT, 'unassigned-conversations', userId] as const,
  conversations: [...PARTNER_QUERY_ROOT, 'conversations'] as const,
  conversationMessages: (conversationId: number | null) =>
    [...PARTNER_QUERY_ROOT, 'conversation-messages', conversationId] as const,
  unreadNotifications: [...PARTNER_QUERY_ROOT, 'unread-notifications'] as const,
  unreadMessages: [...PARTNER_QUERY_ROOT, 'unread-messages'] as const,
}
