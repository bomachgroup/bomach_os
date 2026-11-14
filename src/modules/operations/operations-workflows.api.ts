import { apiClient } from '@/shared/api/api-client'
import type { SiteReport } from '@/modules/work-reports/site-reports.api'

export interface ApiPage<T> {
  items: T[]
  count: number
  limit: number
  offset: number
}

export interface ContractRecord {
  id: number
  project_id: number
  name: string
  contract_number: string
  contract_type: string
  status: string
  value: string
  start_date: string
  end_date: string
  renewal_parent_id: number | null
  signed_by_id: number | null
  signed_at: string | null
  terminated_at: string | null
  termination_reason: string
  created_at: string
  updated_at: string
}

export interface ContractDocument {
  id: number
  original_filename: string
  content_type: string
  size: number
  document_type: 'supporting' | 'executed'
  uploaded_by_name: string
  created_at: string
  download_url: string
}

export interface MeetingRecord {
  id: number
  meeting_id: string
  title: string
  project_id: number | null
  project_name: string | null
  project_short_code: string | null
  project_is_archived: boolean
  agenda: string
  meeting_date: string
  meeting_time: string
  duration_minutes: number
  duration_display: string
  status: string
  status_display: string
  location_type: string
  location_type_display: string
  location: string | null
  attendees: Array<{ user_id: number; full_name: string; email: string }>
  attendee_count: number
  organizer_id: number | null
  organizer_name: string | null
  notes: string | null
  file_url: string | null
  created_at: string
  updated_at: string
}

function query(values: Record<string, string | number | boolean | null | undefined>) {
  const params = new URLSearchParams()
  Object.entries(values).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== '') params.set(key, String(value))
  })
  return params.toString()
}

type SurveyReportDto = SiteReport & {
  attachment_details?: Array<{ url: string; description: string }>
  review_history?: Array<{
    outcome: string
    feedback: string
    submission_version: number
    reviewed_at: string
  }>
}

export const operationsWorkflowsApi = {
  surveyReports: (
    params: Record<string, string | number | boolean | null | undefined>,
    signal?: AbortSignal,
  ) => apiClient.get<ApiPage<SurveyReportDto>>(`/survey-site-reports?${query(params)}`, { signal }),
  surveyReport: (id: number, signal?: AbortSignal) =>
    apiClient.get<SurveyReportDto>(`/survey-site-reports/${id}`, { signal }),
  approveSurveyReport: (id: number, input: { rating: number | null; feedback: string }) =>
    apiClient.post(`/survey-site-reports/${id}/approve`, input),
  rejectSurveyReport: (id: number, feedback: string) =>
    apiClient.post(`/survey-site-reports/${id}/reject`, { feedback }),
  contracts: (
    params: Record<string, string | number | boolean | null | undefined>,
    signal?: AbortSignal,
  ) => apiClient.get<ApiPage<ContractRecord>>(`/contracts?${query(params)}`, { signal }),
  contract: (id: number, signal?: AbortSignal) =>
    apiClient.get<ContractRecord>(`/contracts/${id}`, { signal }),
  createContract: (input: Record<string, unknown>) =>
    apiClient.post<ContractRecord>('/contracts', input),
  updateContract: (id: number, input: Record<string, unknown>) =>
    apiClient.put<ContractRecord>(`/contracts/${id}`, input),
  deleteContract: (id: number) => apiClient.delete<{ detail: string }>(`/contracts/${id}`),
  contractDocuments: (id: number, signal?: AbortSignal) =>
    apiClient.get<ContractDocument[]>(`/contracts/${id}/documents`, { signal }),
  contractEvents: (id: number, signal?: AbortSignal) =>
    apiClient.get<
      Array<{
        id: number
        event_type: string
        actor_name: string
        effective_at: string
        details: Record<string, unknown>
      }>
    >(`/contracts/${id}/events`, { signal }),
  uploadContractDocument: (id: number, file: File, documentType: string) => {
    const form = new FormData()
    form.set('file', file)
    form.set('document_type', documentType)
    return apiClient.post<ContractDocument>(`/contracts/${id}/documents`, form)
  },
  deleteContractDocument: (id: number, documentId: number) =>
    apiClient.delete<{ detail: string }>(`/contracts/${id}/documents/${documentId}`),
  signContract: (id: number, input: { signatory_name: string; signing_date: string }) =>
    apiClient.post<ContractRecord>(`/contracts/${id}/sign`, input),
  renewContract: (id: number, input: Record<string, unknown>) =>
    apiClient.post<ContractRecord>(`/contracts/${id}/renew`, input),
  terminateContract: (id: number, reason: string) =>
    apiClient.post<ContractRecord>(`/contracts/${id}/terminate`, { reason }),
  meetings: (
    params: Record<string, string | number | boolean | null | undefined>,
    signal?: AbortSignal,
  ) => apiClient.get<ApiPage<MeetingRecord>>(`/meetings?${query(params)}`, { signal }),
  meeting: (id: number, signal?: AbortSignal) =>
    apiClient.get<MeetingRecord>(`/meetings/${id}`, { signal }),
  meetingAttendees: (search = '', signal?: AbortSignal) =>
    apiClient.get<
      Array<{
        user_id: number
        employee_id: string
        name: string
        email: string
        branch_id: number | null
      }>
    >(`/meetings/attendee-options?${query({ search })}`, { signal }),
  createMeeting: (input: Record<string, unknown>) =>
    apiClient.post<MeetingRecord>('/meetings', input),
  updateMeeting: (id: number, input: Record<string, unknown>) =>
    apiClient.put<MeetingRecord>(`/meetings/${id}`, input),
  cancelMeeting: (id: number) => apiClient.delete<{ detail: string }>(`/meetings/${id}`),
}
