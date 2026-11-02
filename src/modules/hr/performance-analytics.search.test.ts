import { describe, expect, it } from 'vitest'

import { validateEvaluationSearch, validateScorecardSearch } from './performance-analytics.search'

describe('performance analytics search state', () => {
  it('keeps valid scorecard periods and defaults malformed values', () => {
    expect(validateScorecardSearch({ month: '10', year: '2026' })).toEqual({
      month: 10,
      year: 2026,
    })
    expect(validateScorecardSearch({ month: '13', year: 'nope' })).toEqual({
      month: expect.any(Number),
      year: expect.any(Number),
    })
  })

  it('accepts an optional positive employee id and drops invalid ids', () => {
    expect(validateEvaluationSearch({ month: '10', year: '2026', employee_id: '42' })).toEqual({
      month: 10,
      year: 2026,
      employee_id: 42,
    })
    expect(validateEvaluationSearch({ employee_id: '-1' }).employee_id).toBeUndefined()
  })
})
