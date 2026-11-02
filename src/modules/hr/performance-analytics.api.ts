import { apiClient } from '@/shared/api/api-client'

import { employeesApi, type EmployeeScorecardDto } from './employees.api'

export interface EmployeeEvaluationSummary {
  id: number
  employeeId: number
  evaluatorId: number
  month: number
  year: number
  promotionRequired: boolean
  trainingRequired: boolean
  salaryIncrease: boolean
  overallScore: number | null
  createdAt: string
  updatedAt: string
}

export interface EmployeeEvaluation extends EmployeeEvaluationSummary {
  managerComments: string
  employeeName: string | null
  employeeLevel: string | null
  attendanceScore: number | null
  taskDeliveryScore: number | null
  reportAccuracyScore: number | null
  trainingProgressScore: number | null
  brandContributionScore: number | null
  targetScore: number | null
  targetAchievement: number | null
  ranking: number | null
}

export interface EmployeeEvaluationInput {
  employee_id: number
  evaluator_id: number
  month: number
  year: number
  manager_comments: string
  promotion_required: boolean
  training_required: boolean
  salary_increase: boolean
}

export interface EmployeeEvaluationUpdateInput {
  manager_comments: string
  promotion_required: boolean
  training_required: boolean
  salary_increase: boolean
}

interface EmployeeEvaluationDto {
  id: number
  employee_id: number
  evaluator_id: number
  month: number
  year: number
  manager_comments?: string
  promotion_required: boolean
  training_required: boolean
  salary_increase: boolean
  employee_name?: string | null
  employee_level?: string | null
  attendance_score?: number | string | null
  task_delivery_score?: number | string | null
  report_accuracy_score?: number | string | null
  training_progress_score?: number | string | null
  brand_contribution_score?: number | string | null
  overall_score?: number | string | null
  target_score?: number | string | null
  target_achievement?: number | string | null
  ranking?: number | null
  created_at: string
  updated_at: string
}

interface EmployeeEvaluationSummaryDto extends Omit<EmployeeEvaluationDto, 'manager_comments'> {
  overall_score?: number | string | null
}

function optionalNumber(value: number | string | null | undefined): number | null {
  return value == null ? null : Number(value)
}

function mapSummary(dto: EmployeeEvaluationSummaryDto): EmployeeEvaluationSummary {
  return {
    id: dto.id,
    employeeId: dto.employee_id,
    evaluatorId: dto.evaluator_id,
    month: dto.month,
    year: dto.year,
    promotionRequired: dto.promotion_required,
    trainingRequired: dto.training_required,
    salaryIncrease: dto.salary_increase,
    overallScore: optionalNumber(dto.overall_score),
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  }
}

function mapEvaluation(dto: EmployeeEvaluationDto): EmployeeEvaluation {
  return {
    ...mapSummary(dto),
    managerComments: dto.manager_comments ?? '',
    employeeName: dto.employee_name ?? null,
    employeeLevel: dto.employee_level ?? null,
    attendanceScore: optionalNumber(dto.attendance_score),
    taskDeliveryScore: optionalNumber(dto.task_delivery_score),
    reportAccuracyScore: optionalNumber(dto.report_accuracy_score),
    trainingProgressScore: optionalNumber(dto.training_progress_score),
    brandContributionScore: optionalNumber(dto.brand_contribution_score),
    targetScore: optionalNumber(dto.target_score),
    targetAchievement: optionalNumber(dto.target_achievement),
    ranking: dto.ranking ?? null,
  }
}

export const performanceAnalyticsApi = {
  scorecard: (
    employeeRecordId: number,
    month: number,
    year: number,
    signal?: AbortSignal,
  ): Promise<EmployeeScorecardDto> =>
    employeesApi.scorecard(employeeRecordId, month, year, signal, false),

  evaluations: {
    list: async (
      employeeRecordId: number,
      month: number,
      year: number,
      signal?: AbortSignal,
    ): Promise<EmployeeEvaluationSummary[]> => {
      const query = new URLSearchParams({ month: String(month), year: String(year) })
      const rows = await apiClient.get<EmployeeEvaluationSummaryDto[]>(
        `/employee-evaluations/employee/${employeeRecordId}?${query}`,
        { signal },
      )
      return rows.map(mapSummary)
    },
    get: async (id: number, signal?: AbortSignal): Promise<EmployeeEvaluation> =>
      mapEvaluation(
        await apiClient.get<EmployeeEvaluationDto>(`/employee-evaluations/${id}`, { signal }),
      ),
    create: async (input: EmployeeEvaluationInput): Promise<EmployeeEvaluation> =>
      mapEvaluation(await apiClient.post<EmployeeEvaluationDto>('/employee-evaluations/', input)),
    update: async (id: number, input: EmployeeEvaluationUpdateInput): Promise<EmployeeEvaluation> =>
      mapEvaluation(
        await apiClient.put<EmployeeEvaluationDto>(`/employee-evaluations/${id}`, input),
      ),
  },
}
