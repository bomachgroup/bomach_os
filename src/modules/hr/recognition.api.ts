import { apiClient } from '@/shared/api/api-client'

export interface AwardsPage<T> {
  count: number
  items: T[]
  limit?: number
  offset?: number
}

export interface Award {
  id: number
  title: string
  category: string
  dateAwarded: string
  rankLevel: string
  description: string | null
  createdAt: string
  updatedAt: string
}

interface AwardDto {
  id: number
  title: string
  category: string
  date_awarded: string
  rank_level: string
  description?: string | null
  created_at: string
  updated_at: string
}

export interface AwardInput {
  title: string
  category: string
  date_awarded: string
  rank_level: string
  description: string | null
}

export interface DisciplinaryCase {
  id: number
  employeeId: number
  actionType: string
  violationCategory: string
  violationTitle: string
  violationDescription: string
  dateOfViolation: string
  actionDate: string
  investigationDetails: string | null
  severancePaymentDue: boolean
  severanceAmount: string | null
  daysSinceViolation: number | null
  isSeveranceApplicable: boolean
  actionTypeColor: string
  createdAt: string
  updatedAt: string
}

interface DisciplinaryCaseDto {
  id: number
  employee_id: number
  action_type: string
  violation_category: string
  violation_title: string
  violation_description: string
  date_of_violation: string
  action_date: string
  investigation_details?: string | null
  severance_payment_due: boolean
  severance_amount?: string | number | null
  days_since_violation: number | null
  is_severance_applicable: boolean
  action_type_color: string
  created_at: string
  updated_at: string
}

export interface DisciplinaryCaseInput {
  employee_id: number
  action_type: string
  violation_category: string
  violation_title: string
  violation_description: string
  date_of_violation: string
  action_date: string
  investigation_details: string | null
  severance_payment_due: boolean
  severance_amount: number | null
}

export interface DisciplinaryListParams {
  actionType: string
  violationCategory: string
}

export interface LeaderboardEntry {
  rank: number
  employeeId: number
  employeeName: string | null
  branch: string | null
  score: number
  award: string | null
}

export interface LeaderboardResponse {
  month: number
  year: number
  entries: LeaderboardEntry[]
  averageScore: number
  totalParticipants: number
}

interface LeaderboardDto {
  rank: number
  employee_id: number
  employee_name: string | null
  branch: string | null
  score: number | string
  award: string | null
}

interface LeaderboardResponseDto {
  month: number
  year: number
  entries: LeaderboardDto[]
  avg_score: number | string
  total_participants: number
}

function mapAward(dto: AwardDto): Award {
  return {
    id: dto.id,
    title: dto.title,
    category: dto.category,
    dateAwarded: dto.date_awarded,
    rankLevel: dto.rank_level,
    description: dto.description ?? null,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  }
}

function mapCase(dto: DisciplinaryCaseDto): DisciplinaryCase {
  return {
    id: dto.id,
    employeeId: dto.employee_id,
    actionType: dto.action_type,
    violationCategory: dto.violation_category,
    violationTitle: dto.violation_title,
    violationDescription: dto.violation_description,
    dateOfViolation: dto.date_of_violation,
    actionDate: dto.action_date,
    investigationDetails: dto.investigation_details ?? null,
    severancePaymentDue: dto.severance_payment_due,
    severanceAmount: dto.severance_amount == null ? null : String(dto.severance_amount),
    daysSinceViolation: dto.days_since_violation,
    isSeveranceApplicable: dto.is_severance_applicable,
    actionTypeColor: dto.action_type_color,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  }
}

async function getAllPages<Dto, Model>(
  path: string,
  signal: AbortSignal | undefined,
  map: (item: Dto) => Model,
  queryParams: URLSearchParams,
): Promise<{ count: number; items: Model[] }> {
  const limit = 100
  let offset = 0
  let count: number
  const items: Model[] = []
  do {
    if (signal?.aborted) throw new DOMException('The request was aborted.', 'AbortError')
    const query = new URLSearchParams(queryParams)
    query.set('limit', String(limit))
    query.set('offset', String(offset))
    const page = await apiClient.get<AwardsPage<Dto>>(`${path}?${query}`, { signal })
    count = page.count
    items.push(...page.items.map(map))
    if (!page.items.length) break
    offset += page.items.length
  } while (offset < count)
  return { count, items }
}

export const recognitionApi = {
  awards: {
    listAll: async (year: number | null, signal?: AbortSignal) => {
      const query = new URLSearchParams()
      if (year) query.set('year', String(year))
      return getAllPages<AwardDto, Award>('/awards/', signal, mapAward, query)
    },
    get: async (id: number, signal?: AbortSignal) =>
      mapAward(await apiClient.get<AwardDto>(`/awards/${id}`, { signal })),
    create: async (input: AwardInput) =>
      mapAward(await apiClient.post<AwardDto>('/awards/', input)),
    update: async (id: number, input: AwardInput) =>
      mapAward(await apiClient.put<AwardDto>(`/awards/${id}`, input)),
    remove: (id: number) => apiClient.delete<{ detail: string }>(`/awards/${id}`),
  },
  leaderboard: {
    get: async (
      month: number,
      year: number,
      signal?: AbortSignal,
    ): Promise<LeaderboardResponse> => {
      const query = new URLSearchParams({ month: String(month), year: String(year) })
      const dto = await apiClient.get<LeaderboardResponseDto>(
        `/monthly-scorecards/leaderboard?${query}`,
        { signal },
      )
      return {
        month: dto.month,
        year: dto.year,
        entries: dto.entries.map((entry) => ({
          rank: entry.rank,
          employeeId: entry.employee_id,
          employeeName: entry.employee_name,
          branch: entry.branch,
          score: Number(entry.score),
          award: entry.award,
        })),
        averageScore: Number(dto.avg_score),
        totalParticipants: dto.total_participants,
      }
    },
  },
  disciplinary: {
    listAll: async (
      params: DisciplinaryListParams,
      signal?: AbortSignal,
    ): Promise<{ count: number; items: DisciplinaryCase[] }> => {
      const query = new URLSearchParams()
      if (params.actionType !== 'all') query.set('action_type', params.actionType)
      if (params.violationCategory !== 'all') {
        query.set('violation_category', params.violationCategory)
      }
      return getAllPages<DisciplinaryCaseDto, DisciplinaryCase>(
        '/disciplinary-cases/',
        signal,
        mapCase,
        query,
      )
    },
    get: async (id: number, signal?: AbortSignal) =>
      mapCase(await apiClient.get<DisciplinaryCaseDto>(`/disciplinary-cases/${id}`, { signal })),
    create: async (input: DisciplinaryCaseInput) =>
      mapCase(await apiClient.post<DisciplinaryCaseDto>('/disciplinary-cases/', input)),
    update: async (id: number, input: DisciplinaryCaseInput) =>
      mapCase(await apiClient.put<DisciplinaryCaseDto>(`/disciplinary-cases/${id}`, input)),
    remove: (id: number) => apiClient.delete<{ detail: string }>(`/disciplinary-cases/${id}`),
  },
}
