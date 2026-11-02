import { describe, expect, it } from 'vitest'

import {
  matchesRecognitionText,
  validateLeaderboardSearch,
  validateRecognitionSearch,
} from './recognition.search'

describe('recognition search state', () => {
  it('normalizes invalid filters and pagination without dropping supported URL state', () => {
    expect(
      validateRecognitionSearch({
        search: ' review ',
        year: '2026',
        month: '12',
        action: 'termination',
        category: 'misconduct',
        award_id: '4',
        case_id: '9',
        page: '3',
        pageSize: '20',
      }),
    ).toEqual({
      search: ' review ',
      year: '2026',
      month: '12',
      action: 'termination',
      category: 'misconduct',
      award_id: 4,
      case_id: 9,
      page: 3,
      pageSize: 20,
    })
    expect(
      validateRecognitionSearch({ year: '1800', month: '13', page: '0', pageSize: '99' }),
    ).toMatchObject({
      year: 'all',
      month: 'all',
      page: 1,
      pageSize: 10,
    })
  })

  it('keeps month and year shareable and uses a valid current-period default', () => {
    const result = validateLeaderboardSearch({ month: '2', year: '2025' })
    expect(result).toEqual({ month: 2, year: 2025 })
    const defaults = validateLeaderboardSearch({ month: '15', year: '1700' })
    expect(defaults.month).toBeGreaterThanOrEqual(1)
    expect(defaults.month).toBeLessThanOrEqual(12)
    expect(defaults.year).toBe(new Date().getFullYear())
  })

  it('matches multi-word searches across recognition fields without requiring adjacent words', () => {
    expect(
      matchesRecognitionText(['QA award recognition', 'React workflow fixture'], 'react award'),
    ).toBe(true)
    expect(matchesRecognitionText(['QA award recognition'], 'award absent')).toBe(false)
    expect(matchesRecognitionText(['QA award recognition'], '   ')).toBe(true)
  })
})
