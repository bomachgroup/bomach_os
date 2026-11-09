import { beforeEach, describe, expect, it } from 'vitest'

import {
  clearWorkspaceMemory,
  lastVisitedWorkspaceHref,
  rememberedWorkspaceHref,
  saveWorkspaceLocation,
  WORKSPACE_MEMORY_KEY,
} from './workspace-memory'

describe('workspace location memory', () => {
  beforeEach(() => window.localStorage.clear())

  it('remembers the last location and a separate last location for each app', () => {
    saveWorkspaceLocation(42, 'os', '/hr/employees?status=active&search=private-name')
    saveWorkspaceLocation(42, 'services', '/app/calculator-library?tab=recent')
    saveWorkspaceLocation(42, 'marketing', '/marketing/campaigns?tab=active')

    expect(lastVisitedWorkspaceHref(42)).toBe('/marketing/campaigns?tab=active')
    expect(rememberedWorkspaceHref('42', 'os')).toBe('/hr/employees?status=active')
    expect(rememberedWorkspaceHref(42, 'services')).toBe(
      '/services/app/calculator-library?tab=recent',
    )
    expect(rememberedWorkspaceHref(42, 'marketing')).toBe('/marketing/campaigns?tab=active')
  })

  it('does not restore one user’s saved location for another user', () => {
    saveWorkspaceLocation(42, 'services', '/app/calculator-library')

    expect(lastVisitedWorkspaceHref(43)).toBeNull()
    expect(rememberedWorkspaceHref(43, 'services')).toBeNull()
  })

  it('rejects public, cross-app, and external locations', () => {
    saveWorkspaceLocation(42, 'os', '/login?returnTo=/services/app/dashboard')
    saveWorkspaceLocation(42, 'os', '/services/app/dashboard')
    saveWorkspaceLocation(42, 'services', 'https://attacker.example/')
    saveWorkspaceLocation(42, 'marketing', '/services/app/dashboard')

    expect(window.localStorage.getItem(WORKSPACE_MEMORY_KEY)).toBeNull()
  })

  it('clears only the matching user’s saved location', () => {
    saveWorkspaceLocation(42, 'os', '/dashboard')
    clearWorkspaceMemory(43)
    expect(lastVisitedWorkspaceHref(42)).toBe('/dashboard')

    clearWorkspaceMemory(42)
    expect(window.localStorage.getItem(WORKSPACE_MEMORY_KEY)).toBeNull()
  })
})
