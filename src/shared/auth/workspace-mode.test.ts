import { beforeEach, describe, expect, it, vi } from 'vitest'

import {
  clearWorkspaceMode,
  getWorkspaceMode,
  isPartnerWorkspacePath,
  setWorkspaceMode,
  WORKSPACE_MODE_CHANGE_EVENT,
  WORKSPACE_MODE_KEY,
} from './workspace-mode'

describe('workspace mode', () => {
  beforeEach(() => {
    window.localStorage.clear()
  })

  it('persists only supported workspace modes', () => {
    setWorkspaceMode('partner')
    expect(window.localStorage.getItem(WORKSPACE_MODE_KEY)).toBe('partner')
    expect(getWorkspaceMode()).toBe('partner')

    window.localStorage.setItem(WORKSPACE_MODE_KEY, 'admin')
    expect(getWorkspaceMode()).toBeNull()
  })

  it('announces mode updates and clears the marker on sign out', () => {
    const listener = vi.fn()
    window.addEventListener(WORKSPACE_MODE_CHANGE_EVENT, listener)

    setWorkspaceMode('staff')
    clearWorkspaceMode()

    expect(listener).toHaveBeenNthCalledWith(1, expect.objectContaining({ detail: 'staff' }))
    expect(listener).toHaveBeenNthCalledWith(2, expect.objectContaining({ detail: null }))
    expect(getWorkspaceMode()).toBeNull()
    window.removeEventListener(WORKSPACE_MODE_CHANGE_EVENT, listener)
  })

  it('recognizes only partner portal routes', () => {
    expect(isPartnerWorkspacePath('/')).toBe(true)
    expect(isPartnerWorkspacePath('/partner')).toBe(true)
    expect(isPartnerWorkspacePath('/partners')).toBe(true)
    expect(isPartnerWorkspacePath('/partners/app')).toBe(true)
    expect(isPartnerWorkspacePath('/partners/setup/')).toBe(true)
    expect(isPartnerWorkspacePath('/partners/invitations')).toBe(false)
    expect(isPartnerWorkspacePath('/dashboard')).toBe(false)
  })
})
