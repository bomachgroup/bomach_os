import { apiClient } from '@/shared/api/api-client'

export interface TrainingProgramChoiceDto {
  id: number
  program_name: string
  provider: string
}

export type TrainingProgramStatus = 'pending' | 'in_progress' | 'completed' | 'cancelled'

export type TrainingAudience =
  | 'all_employees'
  | 'management'
  | 'new_hires'
  | 'department_specific'
  | 'leadership_team'
  | 'technical_staff'
  | 'sales_team'
  | 'customer_service'

export interface TrainingProgram extends TrainingProgramChoiceDto {
  description: string
  start_date: string
  end_date: string
  cost: string
  target_audience: TrainingAudience | string
  status: TrainingProgramStatus | string
  duration_days: number
  is_ongoing: boolean
  is_upcoming: boolean
  created_at: string
  updated_at: string
}

export type TrainingProgramListItem = Pick<
  TrainingProgram,
  | 'id'
  | 'program_name'
  | 'provider'
  | 'start_date'
  | 'end_date'
  | 'cost'
  | 'target_audience'
  | 'status'
  | 'duration_days'
>

export interface TrainingProgramInput {
  program_name: string
  provider: string
  description: string
  start_date: string
  end_date: string
  cost: number
  target_audience: TrainingAudience
  status: TrainingProgramStatus
}

export interface TrainingProgramListParams {
  limit: number
  offset: number
  search: string
  provider?: string
  status: string
  audience: string
}

export interface TrainingProgramPageDto<T> {
  count: number
  items: T[]
  limit?: number
  offset?: number
}

export const trainingProgramsApi = {
  list: (params: TrainingProgramListParams, signal?: AbortSignal) => {
    const query = new URLSearchParams({
      limit: String(params.limit),
      offset: String(params.offset),
    })
    if (params.search.trim()) query.set('search', params.search.trim())
    if (params.provider?.trim()) query.set('provider', params.provider.trim())
    if (params.status !== 'all') query.set('status', params.status)
    if (params.audience !== 'all') query.set('target_audience', params.audience)
    return apiClient.get<TrainingProgramPageDto<TrainingProgramListItem>>(
      `/training-programs/?${query}`,
      { signal },
    )
  },
  get: (id: number, signal?: AbortSignal) =>
    apiClient.get<TrainingProgram>(`/training-programs/${id}`, { signal }),
  create: (input: TrainingProgramInput) =>
    apiClient.post<TrainingProgram>('/training-programs/', input),
  update: (id: number, input: TrainingProgramInput) =>
    apiClient.put<TrainingProgram>(`/training-programs/${id}`, input),
  delete: (id: number) => apiClient.delete<void>(`/training-programs/${id}`),
  choices: async (signal?: AbortSignal) => {
    const limit = 100
    const items: TrainingProgramChoiceDto[] = []
    let offset = 0
    let count: number
    do {
      if (signal?.aborted) throw new DOMException('The request was aborted.', 'AbortError')
      const params = new URLSearchParams({ limit: String(limit), offset: String(offset) })
      const page = await apiClient.get<TrainingProgramPageDto<TrainingProgramChoiceDto>>(
        `/training-programs/?${params}`,
        { signal },
      )
      items.push(...page.items)
      count = page.count
      if (!page.items.length) break
      offset += page.items.length
    } while (offset < count)
    return items
  },
}
