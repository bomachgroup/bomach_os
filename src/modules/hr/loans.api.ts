import { apiClient } from '@/shared/api/api-client'

export type LoanStatus = 'pending' | 'approved' | 'rejected'

export interface LoanListItem {
  id: number
  employee_user_id: number
  employee_name: string
  job_title: string
  loan_amount: string
  repayment_date: string
  reason: string
  status: LoanStatus | string
  created_at: string
  updated_at: string
}

export interface LoanRequest extends LoanListItem {
  emergency_contact_name: string
  emergency_contact_phone: string
  attachment: string
}

export interface LoanPage {
  count: number
  items: LoanListItem[]
  limit?: number
  offset?: number
}

export interface LoanListParams {
  limit: number
  offset: number
  search: string
  status: string
}

export interface LoanCreateInput {
  loan_amount: number
  repayment_date: string
  reason: string
  emergency_contact_name: string
  emergency_contact_phone: string
  attachment?: string
  employee_user_id?: number
}

export type LoanUpdateInput = Partial<
  Pick<
    LoanCreateInput,
    | 'loan_amount'
    | 'repayment_date'
    | 'reason'
    | 'emergency_contact_name'
    | 'emergency_contact_phone'
    | 'attachment'
  >
>

export const loansApi = {
  uploadAttachment: (file: File) => {
    const formData = new FormData()
    formData.set('file', file)
    return apiClient.post<{ url: string }>('/others/upload-file', formData)
  },
  list: (params: LoanListParams, signal?: AbortSignal) => {
    const query = new URLSearchParams({
      limit: String(params.limit),
      offset: String(params.offset),
    })
    if (params.search.trim()) query.set('search', params.search.trim())
    if (params.status !== 'all') query.set('status', params.status)
    return apiClient.get<LoanPage>(`/loans?${query}`, { signal })
  },
  get: (id: number, signal?: AbortSignal) => apiClient.get<LoanRequest>(`/loans/${id}`, { signal }),
  create: (input: LoanCreateInput) => apiClient.post<LoanRequest>('/loans', input),
  update: (id: number, input: LoanUpdateInput) => apiClient.put<LoanRequest>(`/loans/${id}`, input),
  approve: (id: number) => apiClient.post<LoanRequest>(`/loans/${id}/approve`),
  reject: (id: number) => apiClient.post<LoanRequest>(`/loans/${id}/reject`),
}
