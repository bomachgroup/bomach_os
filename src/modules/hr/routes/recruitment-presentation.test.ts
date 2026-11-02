import { describe, expect, it } from 'vitest'

import { formatRecruitmentMoney } from './recruitment-presentation'

describe('Recruitment presentation formatters', () => {
  it('formats naira amounts with grouped thousands and preserves decimals', () => {
    expect(formatRecruitmentMoney('1250000')).toBe('₦1,250,000')
    expect(formatRecruitmentMoney('1250000.5')).toBe('₦1,250,000.5')
    expect(formatRecruitmentMoney('0')).toBe('₦0')
  })

  it('keeps missing and non-numeric salary values explicit', () => {
    expect(formatRecruitmentMoney(null)).toBe('Not specified')
    expect(formatRecruitmentMoney('')).toBe('Not specified')
    expect(formatRecruitmentMoney('Negotiable')).toBe('Negotiable')
  })
})
