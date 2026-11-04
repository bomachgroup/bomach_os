import { describe, expect, it } from 'vitest'

import { canAccessServicesApp, SERVICES_APP_ACCESS_ANY_OF } from './app-catalog'

describe('Services app access', () => {
  it('is granted by any permission used by a real top-level Services destination', () => {
    for (const grant of SERVICES_APP_ACCESS_ANY_OF) {
      const separator = grant.lastIndexOf('.')
      expect(
        canAccessServicesApp({ [grant.slice(0, separator)]: [grant.slice(separator + 1)] }),
        grant,
      ).toBe(true)
    }
  })

  it('does not show Services for permissions unrelated to its navigation', () => {
    expect(canAccessServicesApp({ employees: ['list'], clients: ['list'] })).toBe(false)
  })
})
