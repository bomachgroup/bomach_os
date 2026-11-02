import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'

import { employeesApi } from './employees.api'
import { performanceAnalyticsApi } from './performance-analytics.api'

afterEach(() => vi.restoreAllMocks())

describe('performanceAnalyticsApi', () => {
  it('loads the existing scorecard without asking the backend to generate one', async () => {
    const scorecard = {
      id: 9,
      employee_id: 42,
      employee_name: 'Amaka Okafor',
      employee_level: 'Operations Associate',
      month: 10,
      year: 2026,
      attendance_score: '90.25',
      task_delivery_score: '85',
      report_accuracy_score: '88',
      brand_contribution_score: '80',
      training_progress_score: '95',
      overall_score: '87.65',
      target_score: '80',
      target_achievement: '109.56',
      ranking: 2,
      is_auto_generated: true,
      notes: '',
    }
    const get = vi.spyOn(employeesApi, 'scorecard').mockResolvedValue(scorecard)

    await performanceAnalyticsApi.scorecard(42, 10, 2026)

    expect(get).toHaveBeenCalledWith(42, 10, 2026, undefined, false)
  })

  it('maps evaluation details and sends only supported evaluation fields', async () => {
    const dto = {
      id: 12,
      employee_id: 42,
      evaluator_id: 19,
      month: 10,
      year: 2026,
      manager_comments: 'Strong delivery with a clear training focus.',
      promotion_required: false,
      training_required: true,
      salary_increase: false,
      employee_name: 'Amaka Okafor',
      employee_level: 'Operations Associate',
      attendance_score: '90.25',
      task_delivery_score: '85',
      report_accuracy_score: '88',
      training_progress_score: '95',
      brand_contribution_score: '80',
      overall_score: '87.65',
      target_score: '80',
      target_achievement: '109.56',
      ranking: 2,
      created_at: '2026-10-30T10:00:00Z',
      updated_at: '2026-10-30T10:00:00Z',
    }
    const input = {
      employee_id: 42,
      evaluator_id: 19,
      month: 10,
      year: 2026,
      manager_comments: dto.manager_comments,
      promotion_required: dto.promotion_required,
      training_required: dto.training_required,
      salary_increase: dto.salary_increase,
    }
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue(dto)

    const result = await performanceAnalyticsApi.evaluations.create(input)

    expect(post).toHaveBeenCalledWith('/employee-evaluations/', input)
    expect(result).toMatchObject({
      id: 12,
      employeeId: 42,
      evaluatorId: 19,
      managerComments: dto.manager_comments,
      overallScore: 87.65,
      attendanceScore: 90.25,
    })
  })

  it('filters evaluation history by employee and period and maps summary scores', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue([
      {
        id: 12,
        employee_id: 42,
        evaluator_id: 19,
        month: 10,
        year: 2026,
        promotion_required: false,
        training_required: true,
        salary_increase: false,
        overall_score: '87.65',
        created_at: '2026-10-30T10:00:00Z',
        updated_at: '2026-10-30T10:00:00Z',
      },
    ])

    const result = await performanceAnalyticsApi.evaluations.list(42, 10, 2026)

    expect(get).toHaveBeenCalledWith('/employee-evaluations/employee/42?month=10&year=2026', {
      signal: undefined,
    })
    expect(result[0]).toMatchObject({ employeeId: 42, overallScore: 87.65, trainingRequired: true })
  })
})
