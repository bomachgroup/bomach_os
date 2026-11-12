import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'
import { siteReportsApi } from './site-reports.api'

afterEach(() => vi.restoreAllMocks())

describe('siteReportsApi', () => {
  it('uses the dedicated paginated endpoint with the signed-in employee and selected status', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 11, items: [] })
    await siteReportsApi.list('engineering', {
      employeeId: 23,
      status: 'rejected',
      limit: 10,
      offset: 10,
    })
    expect(get).toHaveBeenCalledWith(
      '/engineering-site-reports?employee_id=23&limit=10&offset=10&status=rejected',
      { signal: undefined },
    )
  })

  it('uses the survey register endpoint and omits an all-status filter', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })
    await siteReportsApi.list('survey', {
      employeeId: 42,
      status: 'all',
      limit: 10,
      offset: 0,
    })
    expect(get).toHaveBeenCalledWith('/survey-site-reports?employee_id=42&limit=10&offset=0', {
      signal: undefined,
    })
  })

  it('preserves the registry summary and typed survey data from the response', async () => {
    vi.spyOn(apiClient, 'get').mockResolvedValue({
      id: 9,
      employee_id: 23,
      employee_name: 'Sam Staff',
      status: 'rejected',
      rating: null,
      reviewed_by_id: 2,
      reviewed_at: '2026-10-29T09:00:00Z',
      worksite_id: 4,
      worksite_name: 'North site',
      project_id: null,
      task_id: null,
      date: '2026-10-28',
      summary: 'Please include the control point readings.',
      work_data_type: 'bearing_distance',
      measurement_unit: 'metres',
      coordinate_system: 'UTM',
      datum: 'WGS84',
      coordinate_zone: '32N',
      gps_latitude: '6.500000',
      gps_longitude: '3.400000',
      submission_version: 1,
      activities: [{ id: 3, activity_type: 'general_survey', description: 'Surveyed boundary.' }],
      expenses: [],
      materials_used: [],
      attachments: ['https://files.example.test/site.pdf'],
      bearing_distance_points: [
        {
          point_number: 1,
          azimuth_degrees: 30,
          azimuth_minutes: 10,
          azimuth_seconds: '5',
          distance: '12.4',
        },
      ],
      xyz_points: [],
      created_at: '2026-10-28T09:00:00Z',
      updated_at: '2026-10-29T09:00:00Z',
    })

    await expect(siteReportsApi.detail('survey', 9)).resolves.toMatchObject({
      id: 9,
      summary: 'Please include the control point readings.',
      worksite_name: 'North site',
      work_data_type: 'bearing_distance',
      bearing_distance_points: [{ point_number: 1, distance: '12.4' }],
    })
  })

  it('loads all inventory pages for the original worksite when the caller has inventory-list access', async () => {
    const get = vi
      .spyOn(apiClient, 'get')
      .mockResolvedValueOnce({
        count: 101,
        items: Array.from({ length: 100 }, (_, index) => ({
          id: index + 1,
          worksite_id: 6,
          name: `Item ${index + 1}`,
          unit: 'hours',
          quantity: '12.000',
        })),
      })
      .mockResolvedValueOnce({
        count: 101,
        items: [{ id: 101, worksite_id: 6, name: 'Item 101', unit: 'hours', quantity: '8.000' }],
      })

    const items = await siteReportsApi.listEquipment(6)

    expect(items).toHaveLength(101)
    expect(get).toHaveBeenNthCalledWith(1, '/site-equipment?worksite_id=6&limit=100&offset=0', {
      signal: undefined,
    })
    expect(get).toHaveBeenNthCalledWith(2, '/site-equipment?worksite_id=6&limit=100&offset=100', {
      signal: undefined,
    })
  })

  it('updates, submits, and deletes only the chosen site-report family record', async () => {
    const put = vi.spyOn(apiClient, 'put').mockResolvedValue({})
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue({})
    const remove = vi.spyOn(apiClient, 'delete').mockResolvedValue({ detail: 'Deleted' })
    const input = { comments_suggestions: 'Revised notes' }
    await siteReportsApi.update('engineering', 12, input)
    await siteReportsApi.submit('engineering', 12)
    await siteReportsApi.remove('engineering', 12)

    expect(put).toHaveBeenCalledWith('/engineering-site-reports/12', input)
    expect(post).toHaveBeenCalledWith('/engineering-site-reports/12/submit', {})
    expect(remove).toHaveBeenCalledWith('/engineering-site-reports/12')
  })

  it('creates both site report types through their type-specific endpoints', async () => {
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue({ id: 51 })
    const engineeringInput = {
      worksite_id: 6,
      project_id: 4,
      date: '2026-11-03',
      activities: [{ activity_type: 'concrete_work', description: 'Poured the footing.' }],
      expenses: [],
      attachments: [],
    }
    const surveyInput = {
      worksite_id: 6,
      project_id: 4,
      date: '2026-11-03',
      work_data_type: 'bearing_distance' as const,
      measurement_unit: 'metres',
      activities: [{ description: 'Checked the boundary.' }],
      bearing_distance_points: [
        {
          point_number: 1,
          azimuth_degrees: 40,
          azimuth_minutes: 12,
          azimuth_seconds: '4',
          distance: '15.5',
        },
      ],
    }

    await siteReportsApi.create('engineering', engineeringInput)
    await siteReportsApi.create('survey', surveyInput)

    expect(post).toHaveBeenNthCalledWith(1, '/engineering-site-reports', engineeringInput)
    expect(post).toHaveBeenNthCalledWith(2, '/survey-site-reports', surveyInput)
    expect(JSON.stringify(post.mock.calls)).not.toContain('employee_id')
  })
})
