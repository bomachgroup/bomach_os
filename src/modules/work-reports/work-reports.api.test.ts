import { beforeEach, describe, expect, it, vi } from 'vitest'

vi.mock('@/shared/api/api-client', () => ({
  apiClient: {
    get: vi.fn(),
    post: vi.fn(),
    put: vi.fn(),
    delete: vi.fn(),
  },
}))

import { apiClient } from '@/shared/api/api-client'
import { workReportsApi } from './work-reports.api'

describe('workReportsApi', () => {
  beforeEach(() => vi.clearAllMocks())

  it('uses server pagination and maps URL filters to the existing endpoint contract', async () => {
    vi.mocked(apiClient.get).mockResolvedValue({ count: 2, items: [] })
    await workReportsApi.list({
      employeeId: 23,
      status: 'rejected',
      query: 'pump repair',
      dateFrom: '2026-10-01',
      dateTo: '2026-10-15',
      limit: 10,
      offset: 10,
    })

    expect(apiClient.get).toHaveBeenCalledWith(
      '/work-reports/?employee_id=23&limit=10&offset=10&status=rejected&search=pump+repair&date_from=2026-10-01&date_to=2026-10-15',
      { signal: undefined },
    )
  })

  it('omits the employee filter for the authorized HR-wide review queue', async () => {
    vi.mocked(apiClient.get).mockResolvedValue({ count: 0, items: [] })
    await workReportsApi.list({
      employeeId: 0,
      status: 'submitted',
      query: 'Lagos',
      dateFrom: '',
      dateTo: '',
      limit: 10,
      offset: 0,
    })

    expect(apiClient.get).toHaveBeenCalledWith(
      '/work-reports/?limit=10&offset=0&status=submitted&search=Lagos',
      { signal: undefined },
    )
  })

  it('posts approval and required rejection feedback to the review endpoints', async () => {
    vi.mocked(apiClient.post).mockResolvedValue({
      id: 42,
      employee_id: 23,
      day: '2026-10-19',
      hours_worked: '7.5',
      status: 'approved',
      created_at: '2026-10-19T12:00:00Z',
      updated_at: '2026-10-19T12:00:00Z',
    })
    await workReportsApi.approve(42, { rating: 4, feedback: 'Clear, complete record.' })
    expect(apiClient.post).toHaveBeenCalledWith('/work-reports/42/approve', {
      rating: 4,
      feedback: 'Clear, complete record.',
    })

    vi.mocked(apiClient.post).mockResolvedValue({
      id: 42,
      employee_id: 23,
      day: '2026-10-19',
      hours_worked: '7.5',
      status: 'rejected',
      created_at: '2026-10-19T12:00:00Z',
      updated_at: '2026-10-19T12:00:00Z',
    })
    await workReportsApi.reject(42, 'Please add the customer follow-up.')
    expect(apiClient.post).toHaveBeenLastCalledWith('/work-reports/42/reject', {
      feedback: 'Please add the customer follow-up.',
    })
  })

  it('maps reviewer and attachment response fields into the feature model', async () => {
    vi.mocked(apiClient.get).mockResolvedValue({
      id: 4,
      employee_id: 23,
      day: '2026-10-19',
      hours_worked: '7.5',
      work_activities: 'Inspected the site pump',
      work_summary: 'Inspected the site pump',
      status: 'rejected',
      reviewed_by: { first_name: 'Mira', last_name: 'Okafor' },
      feedback: 'Add the follow-up plan.',
      rating: null,
      attachments: [{ file_url: 'https://example.test/report.pdf' }],
      created_at: '2026-10-19T12:00:00Z',
      updated_at: '2026-10-19T12:00:00Z',
    })

    await expect(workReportsApi.detail(4)).resolves.toMatchObject({
      employeeId: 23,
      hoursWorked: 7.5,
      summary: 'Inspected the site pump',
      reviewedBy: 'Mira Okafor',
      attachments: ['https://example.test/report.pdf'],
    })
  })
})
