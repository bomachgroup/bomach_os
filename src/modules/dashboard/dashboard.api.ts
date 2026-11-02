import { apiClient } from '@/shared/api/api-client'

export interface PersonalOverviewDto {
  attendance: {
    required_workdays: number
    attended_workdays: number
    attendance_rate_percent: number | null
    on_time_arrivals: number
    late_arrivals: number
    punctuality_rate_percent: number | null
    completed_shifts: number
  } | null
  work_reports: {
    reports_submitted: number
    approved_reports: number
    average_rating: number | null
    score_percent: number | null
  } | null
}

export const personalOverviewQueryKey = (userId: number, employeeId: string) =>
  ['dashboard', 'personal-overview', userId, employeeId] as const

export const dashboardApi = {
  personalOverview: (signal?: AbortSignal) =>
    apiClient.get<PersonalOverviewDto>('/dashboard/personal-overview', { signal }),
}
