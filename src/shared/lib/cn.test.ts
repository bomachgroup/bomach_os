import { describe, expect, it } from 'vitest'

import { cn } from './cn'

describe('cn', () => {
  it('merges semantic font sizes without removing text colors', () => {
    expect(cn('text-body-sm text-text-secondary', 'text-body-lg')).toBe(
      'text-text-secondary text-body-lg',
    )
  })

  it('keeps the last semantic text color while retaining the font size', () => {
    expect(cn('text-body-sm text-danger', 'text-text-primary')).toBe(
      'text-body-sm text-text-primary',
    )
  })
})
