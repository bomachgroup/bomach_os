import { describe, expect, it } from 'vitest'

import {
  validatePartnerAppSearch,
  validatePartnerDeskSearch,
  validatePartnerTwoFactorSearch,
} from './partner.search'

describe('partner workspace URL state', () => {
  it('preserves a bounded staff search and page', () => {
    expect(validatePartnerDeskSearch({ search: '  Ada  ', page: '3' })).toEqual({
      search: '  Ada  ',
      page: 3,
    })
    expect(validatePartnerDeskSearch({ page: '-1' })).toEqual({ search: '', page: 1 })
  })

  it('accepts only the supported partner workspace tabs', () => {
    expect(validatePartnerAppSearch({ tab: 'messages' })).toEqual({ tab: 'messages' })
    expect(validatePartnerAppSearch({ tab: 'messages', conversation: '41' })).toEqual({
      tab: 'messages',
      conversation: 41,
    })
    expect(validatePartnerAppSearch({ tab: 'admin' })).toEqual({ tab: 'home' })
  })

  it('keeps the post-2FA destination within the partner onboarding flow', () => {
    expect(validatePartnerTwoFactorSearch({ next: 'profile' })).toEqual({ next: 'profile' })
    expect(validatePartnerTwoFactorSearch({ next: '/company' })).toEqual({ next: 'home' })
  })
})
