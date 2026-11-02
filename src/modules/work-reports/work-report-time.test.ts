import { describe, expect, it } from 'vitest'

import { calculateWorkHours } from './work-report-time'

describe('calculateWorkHours', () => {
  it('calculates and rounds a same-day shift', () => {
    expect(calculateWorkHours('08:00', '16:20')).toBe(8.3)
  })

  it('supports an overnight shift', () => {
    expect(calculateWorkHours('22:30', '06:00')).toBe(7.5)
  })

  it('rejects missing, invalid, identical, and too-short ranges', () => {
    expect(calculateWorkHours('', '16:00')).toBeNull()
    expect(calculateWorkHours('08:00', '08:00')).toBeNull()
    expect(calculateWorkHours('27:00', '08:00')).toBeNull()
    expect(calculateWorkHours('08:00', '08:02')).toBeNull()
  })
})
