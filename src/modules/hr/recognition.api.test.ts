import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'

import { recognitionApi } from './recognition.api'

afterEach(() => vi.restoreAllMocks())

describe('recognitionApi', () => {
  it('maps award DTO fields and omits an empty year filter', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({
      count: 1,
      items: [
        {
          id: 2,
          title: 'Service award',
          category: 'dependable_team_member',
          date_awarded: '2026-10-20',
          rank_level: 'branch',
          description: null,
          created_at: '2026-10-20T10:00:00Z',
          updated_at: '2026-10-20T10:00:00Z',
        },
      ],
    })

    const result = await recognitionApi.awards.listAll(null)

    expect(get).toHaveBeenCalledWith('/awards/?limit=100&offset=0', { signal: undefined })
    expect(result.items[0]).toMatchObject({ id: 2, dateAwarded: '2026-10-20', rankLevel: 'branch' })
  })

  it('loads every page when the record count exceeds one backend page', async () => {
    const get = vi
      .spyOn(apiClient, 'get')
      .mockResolvedValueOnce({
        count: 101,
        items: Array.from({ length: 100 }, (_, i) => ({
          id: i + 1,
          title: `Award ${i + 1}`,
          category: 'other',
          date_awarded: '2026-10-20',
          rank_level: 'branch',
          created_at: '',
          updated_at: '',
        })),
      })
      .mockResolvedValueOnce({
        count: 101,
        items: [
          {
            id: 101,
            title: 'Award 101',
            category: 'other',
            date_awarded: '2026-10-20',
            rank_level: 'branch',
            created_at: '',
            updated_at: '',
          },
        ],
      })

    const result = await recognitionApi.awards.listAll(2026)

    expect(get).toHaveBeenNthCalledWith(1, '/awards/?year=2026&limit=100&offset=0', {
      signal: undefined,
    })
    expect(get).toHaveBeenNthCalledWith(2, '/awards/?year=2026&limit=100&offset=100', {
      signal: undefined,
    })
    expect(result.items).toHaveLength(101)
  })

  it('uses the supported create, detail, update and delete API contracts', async () => {
    const input = {
      title: 'Outstanding teamwork',
      category: 'dependable_team_member',
      date_awarded: '2026-10-20',
      rank_level: 'branch',
      description: null,
    }
    const dto = { id: 8, ...input, created_at: '', updated_at: '' }
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue(dto)
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue(dto)
    const put = vi.spyOn(apiClient, 'put').mockResolvedValue(dto)
    const remove = vi.spyOn(apiClient, 'delete').mockResolvedValue({ detail: 'Deleted' })

    await recognitionApi.awards.create(input)
    await recognitionApi.awards.get(8)
    await recognitionApi.awards.update(8, input)
    await recognitionApi.awards.remove(8)

    expect(post).toHaveBeenCalledWith('/awards/', input)
    expect(get).toHaveBeenCalledWith('/awards/8', { signal: undefined })
    expect(put).toHaveBeenCalledWith('/awards/8', input)
    expect(remove).toHaveBeenCalledWith('/awards/8')
  })

  it('requests the selected leaderboard period and maps missing optional details', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({
      month: 10,
      year: 2026,
      entries: [
        {
          rank: 1,
          employee_id: 44,
          employee_name: null,
          branch: null,
          score: '89.25',
          award: null,
        },
      ],
      avg_score: '89.25',
      total_participants: 1,
    })

    const result = await recognitionApi.leaderboard.get(10, 2026)

    expect(get).toHaveBeenCalledWith('/monthly-scorecards/leaderboard?month=10&year=2026', {
      signal: undefined,
    })
    expect(result).toMatchObject({ averageScore: 89.25, totalParticipants: 1 })
    expect(result.entries[0]).toMatchObject({
      employeeId: 44,
      employeeName: null,
      branch: null,
      score: 89.25,
    })
  })

  it('passes only supported disciplinary filters and maps case dates and money', async () => {
    const dto = {
      id: 7,
      employee_id: 33,
      action_type: 'written_warning',
      violation_category: 'misconduct',
      violation_title: 'Late reporting',
      violation_description: 'Synthetic case details',
      date_of_violation: '2026-10-10',
      action_date: '2026-10-12',
      investigation_details: null,
      severance_payment_due: false,
      severance_amount: null,
      days_since_violation: 20,
      is_severance_applicable: false,
      action_type_color: '#F5A623',
      created_at: '',
      updated_at: '',
    }
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 1, items: [dto] })

    const result = await recognitionApi.disciplinary.listAll({
      actionType: 'written_warning',
      violationCategory: 'all',
    })

    expect(get).toHaveBeenCalledWith(
      '/disciplinary-cases/?action_type=written_warning&limit=100&offset=0',
      { signal: undefined },
    )
    expect(result.items[0]).toMatchObject({
      employeeId: 33,
      dateOfViolation: '2026-10-10',
      severanceAmount: null,
    })
  })
})
