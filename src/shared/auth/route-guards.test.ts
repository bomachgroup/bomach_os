import { beforeEach, describe, expect, it } from 'vitest'

import { requirePartnerWorkspaceHost, requireStaffWorkspaceMode } from './route-guards'
import { clearWorkspaceMode, setWorkspaceMode } from './workspace-mode'

describe('staff workspace route guard', () => {
  beforeEach(() => {
    window.localStorage.clear()
    clearWorkspaceMode()
  })

  it('redirects partner mode to the partner-safe not-found route', () => {
    setWorkspaceMode('partner')
    let caught: unknown

    try {
      requireStaffWorkspaceMode()
    } catch (error) {
      caught = error
    }

    expect(caught).toMatchObject({
      options: { to: '/partners/not-found', replace: true },
    })
  })

  it('allows staff and unresolved modes through to normal authentication checks', () => {
    expect(() => requireStaffWorkspaceMode()).not.toThrow()
    setWorkspaceMode('staff')
    expect(() => requireStaffWorkspaceMode()).not.toThrow()
  })

  it('returns a not-found boundary for partner routes opened on the staff host', () => {
    let caught: unknown

    try {
      requirePartnerWorkspaceHost('os.bomachgroup.com')
    } catch (error) {
      caught = error
    }

    expect(caught).toMatchObject({ isNotFound: true })
  })

  it('preserves localStorage routing on other hosts and allows partner routes on the partner host', () => {
    expect(() => requirePartnerWorkspaceHost('partner.bomachgroup.com')).not.toThrow()
    expect(() => requirePartnerWorkspaceHost('preview-bomach.vercel.app')).not.toThrow()
  })
})
