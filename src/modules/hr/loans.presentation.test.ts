import { describe, expect, it } from 'vitest'

import {
  formatLoanAmountInput,
  formatLoanCurrency,
  formatLoanDate,
  groupedLoanCaretPosition,
  loanStatusTone,
} from './loans.presentation'

describe('loan presentation helpers', () => {
  it('formats Naira values with grouped thousands and bounded decimals', () => {
    expect(formatLoanCurrency('125000.5')).toBe('₦125,000.50')
    expect(formatLoanCurrency('125000.50')).toBe('₦125,000.50')
    expect(formatLoanCurrency('100000000')).toBe('₦100,000,000.00')
    expect(formatLoanCurrency('not-a-number')).toBe('not-a-number')
  })

  it('formats date-only values without shifting their calendar day', () => {
    expect(formatLoanDate('2026-10-30')).toMatch(/Oct 30, 2026/)
    expect(formatLoanDate('2026-02-30')).toBe('2026-02-30')
    expect(formatLoanDate(null)).toBe('Not scheduled')
  })

  it('groups an amount while keeping incomplete decimals editable', () => {
    expect(formatLoanAmountInput('125000')).toBe('125,000')
    expect(formatLoanAmountInput('125000.')).toBe('125,000.')
    expect(formatLoanAmountInput('125000.50')).toBe('125,000.50')
    expect(formatLoanAmountInput('1e4')).toBeNull()
    expect(groupedLoanCaretPosition('125,000.50', 4)).toBe(5)
    expect(groupedLoanCaretPosition('125,000.50', 0)).toBe(0)
  })

  it('maps known statuses to semantic tones and unknown statuses safely', () => {
    expect(loanStatusTone('Approved')).toBe('success')
    expect(loanStatusTone('pending')).toBe('warning')
    expect(loanStatusTone('rejected')).toBe('danger')
    expect(loanStatusTone('unknown')).toBe('neutral')
  })
})
