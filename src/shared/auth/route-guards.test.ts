import { beforeEach, describe, expect, it } from 'vitest'

import { requireStaffWorkspaceMode } from './route-guards'
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
})
