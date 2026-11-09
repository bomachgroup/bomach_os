import { describe, expect, it } from 'vitest'

import {
  canAccessMarketingApp,
  canAccessServicesApp,
  MARKETING_APP_ACCESS_ANY_OF,
  SERVICES_APP_ACCESS_ANY_OF,
  WORKSPACE_APPS,
} from './app-catalog'

describe('Services app access', () => {
  it('opens Services at the canonical prefixed root path', () => {
    expect(WORKSPACE_APPS.find((app) => app.id === 'services')?.href).toBe('/services/')
  })

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

describe('Marketing app access', () => {
  it('uses the shared /marketing entry and requires a permission used by Marketing navigation', () => {
    expect(WORKSPACE_APPS.find((app) => app.id === 'marketing')?.href).toBe('/marketing/dashboard')
    for (const grant of MARKETING_APP_ACCESS_ANY_OF) {
      const separator = grant.lastIndexOf('.')
      expect(
        canAccessMarketingApp({ [grant.slice(0, separator)]: [grant.slice(separator + 1)] }),
        grant,
      ).toBe(true)
    }
  })

  it('does not show Marketing for unrelated permissions', () => {
    expect(canAccessMarketingApp({ hr_employees: ['list'], service_requests: ['approve'] })).toBe(false)
  })
})
