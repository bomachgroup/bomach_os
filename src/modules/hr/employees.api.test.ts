import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'

import { employeesApi } from './employees.api'

afterEach(() => vi.restoreAllMocks())

describe('employeesApi', () => {
  it('uses employment status for the active and past directory views', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })

    await employeesApi.list({
      limit: 10,
      offset: 20,
      search: '',
      view: 'active',
      branchId: 'all',
      departmentId: 'all',
    })
    await employeesApi.list({
      limit: 10,
      offset: 0,
      search: '',
      view: 'past',
      branchId: 'all',
      departmentId: 'all',
    })

    expect(get).toHaveBeenNthCalledWith(
      1,
      '/employees/employees?limit=10&offset=20&is_active=true',
      {
        signal: undefined,
      },
    )
    expect(get).toHaveBeenNthCalledWith(
      2,
      '/employees/employees?limit=10&offset=0&is_active=false',
      {
        signal: undefined,
      },
    )
  })

  it('preserves search and branch filters in the directory query', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })

    await employeesApi.list({
      limit: 10,
      offset: 10,
      search: '  Amina Yusuf  ',
      view: 'past',
      branchId: '4',
      departmentId: '8',
    })

    expect(get).toHaveBeenCalledWith(
      '/employees/employees?limit=10&offset=10&is_active=false&search=Amina+Yusuf&branch_id=4&department_id=8',
      { signal: undefined },
    )
  })

  it('loads assigned tasks through the employee-scoped endpoint', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })

    await employeesApi.tasks(42)

    expect(get).toHaveBeenCalledWith('/employees/employees/42/tasks?limit=100&offset=0', {
      signal: undefined,
    })
  })

  it('uses dedicated employee leave period and return endpoints', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue([])
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue({})
    const input = {
      leave_type: 'annual_leave',
      reason: 'Annual break',
      start_date: '2026-10-29',
      expected_return_date: '2026-11-05',
      review_reminder_date: null,
    }

    await employeesApi.leavePeriods(42)
    await employeesApi.createLeavePeriod(42, input)
    await employeesApi.returnFromLeave(42, { actual_return_date: '2026-11-05' })

    expect(get).toHaveBeenCalledWith('/employees/employees/42/leave-periods', {
      signal: undefined,
    })
    expect(post).toHaveBeenNthCalledWith(1, '/employees/employees/42/leave-periods', input)
    expect(post).toHaveBeenNthCalledWith(2, '/employees/employees/42/leave-periods/return', {
      actual_return_date: '2026-11-05',
    })
  })

  it('uploads profile pictures through the shared file endpoint', async () => {
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue({ url: 'https://media.test/qa.png' })
    const file = new File(['synthetic image'], 'qa-profile.png', { type: 'image/png' })

    await employeesApi.uploadProfilePicture(file)

    expect(post).toHaveBeenCalledWith('/others/upload-file', expect.any(FormData))
    const payload = post.mock.calls[0]?.[1]
    expect(payload).toBeInstanceOf(FormData)
    expect((payload as FormData).get('file')).toBe(file)
  })

  it('uses the existing employee update and exit contracts for lifecycle actions', async () => {
    const put = vi.spyOn(apiClient, 'put').mockResolvedValue({ employment_status: 'suspended' })
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue({ detail: 'Employee exited.' })

    await employeesApi.update(42, { employment_status: 'suspended' })
    await employeesApi.exit(42, { exit_date: '2026-10-27', reason: 'Contract ended' })

    expect(put).toHaveBeenCalledWith('/employees/employees/42', {
      employment_status: 'suspended',
    })
    expect(post).toHaveBeenCalledWith('/employees/exit/42', {
      exit_date: '2026-10-27',
      reason: 'Contract ended',
    })
  })
})
