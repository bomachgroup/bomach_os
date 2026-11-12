import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'
import { myWorkReportsApi } from './my-work-reports.api'

afterEach(() => vi.restoreAllMocks())

describe('myWorkReportsApi', () => {
  it('uses the permission-scoped combined endpoint without a client employee ID', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({
      count: 2,
      items: [
        {
          id: 105,
          report_type: 'daily_work',
          status: 'submitted',
          rating: null,
          reviewed_at: null,
          summary: 'Daily summary from register',
          payload: {
            work_report_id: 42,
            day: '2026-11-02',
            work_activities: 'Daily activities',
            hours_worked: '7.5',
            attachments: [],
          },
        },
        {
          id: 106,
          report_type: 'survey_site',
          status: 'rejected',
          rating: null,
          reviewed_at: '2026-11-03T09:30:00Z',
          summary: 'Clarify the boundary reading.',
          payload: {
            date: '2026-11-03',
            worksite_name: 'North worksite',
            activities: [{ description: 'Measured the boundary.' }],
            attachments: ['https://files.example.test/report.pdf'],
          },
        },
      ],
    })

    const controller = new AbortController()
    const page = await myWorkReportsApi.list(
      { type: 'site', status: 'rejected', limit: 10, offset: 10 },
      controller.signal,
    )

    expect(get).toHaveBeenCalledWith(
      '/my-work-reports?report_type=site&limit=10&offset=10&status=rejected',
      { signal: controller.signal },
    )
    expect(get.mock.calls[0]?.[0]).not.toContain('employee_id')
    expect(page).toMatchObject({
      count: 2,
      items: [
        {
          id: 105,
          reportId: 42,
          type: 'daily',
          date: '2026-11-02',
          summary: 'Daily summary from register',
          hoursWorked: 7.5,
        },
        {
          id: 106,
          reportId: 106,
          type: 'survey',
          date: '2026-11-03',
          summary: 'Clarify the boundary reading.',
          worksiteName: 'North worksite',
          attachments: ['https://files.example.test/report.pdf'],
          reviewedAt: '2026-11-03T09:30:00Z',
        },
      ],
    })
  })

  it('omits an all-status parameter', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })

    await myWorkReportsApi.list({ type: 'all', status: 'all', limit: 10, offset: 0 })

    expect(get).toHaveBeenCalledWith('/my-work-reports?report_type=all&limit=10&offset=0', {
      signal: undefined,
    })
  })
})
