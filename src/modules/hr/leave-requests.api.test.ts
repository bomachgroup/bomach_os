import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'

import { hrLeaveRequestsApi } from './leave-requests.api'

afterEach(() => vi.restoreAllMocks())

describe('hrLeaveRequestsApi', () => {
  it('serializes employee search, request category, and status filters', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({
      count: 1,
      items: [
        {
          id: 41,
          employee_id: 8,
          employee_name: 'Amina Yusuf',
          employee_code: 'EMP-008',
          branch_name: 'Lagos HQ',
          request_kind: 'leave',
          leave_type: 'annual_leave',
          start_date: '2026-11-02',
          end_date: '2026-11-04',
          reason: 'Family travel',
          status: 'pending',
          approver_id: null,
          approver_name: null,
          approval_date: null,
          rejection_reason: null,
          duration_days: 3,
          created_at: '2026-10-27T10:00:00Z',
          updated_at: '2026-10-27T10:00:00Z',
        },
      ],
    })
    const page = await hrLeaveRequestsApi.list({
      limit: 20,
      offset: 20,
      search: 'Amina Yusuf',
      status: 'pending',
      kind: 'leave',
    })

    expect(get).toHaveBeenCalledWith(
      '/leave-requests/?limit=20&offset=20&search=Amina+Yusuf&status=pending&request_kind=leave',
      { signal: undefined },
    )
    expect(page.items[0]).toMatchObject({
      employeeId: 8,
      employeeName: 'Amina Yusuf',
      employeeCode: 'EMP-008',
      branchName: 'Lagos HQ',
      durationDays: 3,
    })
  })

  it('requires a rejection reason in the exact status decision payload', async () => {
    const patch = vi.spyOn(apiClient, 'patch').mockResolvedValue({
      id: 41,
      employee_id: 8,
      employee_name: 'Amina Yusuf',
      request_kind: 'leave',
      leave_type: 'annual_leave',
      start_date: '2026-11-02',
      end_date: '2026-11-04',
      reason: 'Family travel',
      status: 'rejected',
      approver_name: 'HR Reviewer',
      approval_date: '2026-10-27',
      rejection_reason: 'Coverage is unavailable.',
      duration_days: 3,
      created_at: '2026-10-27T10:00:00Z',
      updated_at: '2026-10-27T11:00:00Z',
    })
    const result = await hrLeaveRequestsApi.review(41, 'rejected', 'Coverage is unavailable.')
    expect(patch).toHaveBeenCalledWith('/leave-requests/41/status', {
      status: 'rejected',
      rejection_reason: 'Coverage is unavailable.',
    })
    expect(result).toMatchObject({ id: 41, status: 'rejected', approverName: 'HR Reviewer' })
  })
})
