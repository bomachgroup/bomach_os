import { beforeEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'
import { approvalWorkflowsApi } from './approval-workflows.api'

describe('approvalWorkflowsApi', () => {
  beforeEach(() => vi.restoreAllMocks())

  it('uses server-approved actions and levels from the choices endpoint', async () => {
    const get = vi
      .spyOn(apiClient, 'get')
      .mockResolvedValue({ action_types: [], required_levels: [] })
    await approvalWorkflowsApi.choices()
    expect(get).toHaveBeenCalledWith('/approvals/flows/choices', { signal: undefined })
  })

  it('creates steps in an ordered backend-compatible shape', async () => {
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue({ id: 1 })
    const input = {
      name: 'Expense review',
      description: 'Two-stage spend approval',
      action_type: 'expense_claim',
      steps: [
        { step_order: 1, step_name: 'Manager review', required_level: 'manager' },
        { step_order: 2, step_name: 'Finance review', required_level: 'head_finance' },
      ],
    }

    await approvalWorkflowsApi.create(input)

    expect(post).toHaveBeenCalledWith('/approvals/flows', input)
    expect(input).not.toHaveProperty('is_active')
  })
})
