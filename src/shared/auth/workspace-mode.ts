export type WorkspaceMode = 'staff' | 'partner'

export const WORKSPACE_MODE_KEY = 'bomach:workspace-mode'
export const WORKSPACE_MODE_CHANGE_EVENT = 'bomach:workspace-mode-change'

const WORKSPACE_HOSTS: Record<string, WorkspaceMode> = {
  'os.bomachgroup.com': 'staff',
  'partner.bomachgroup.com': 'partner',
}

let volatileMode: WorkspaceMode | null = null

function isWorkspaceMode(value: string | null): value is WorkspaceMode {
  return value === 'staff' || value === 'partner'
}

export function getWorkspaceHostMode(hostname?: string): WorkspaceMode | null {
  const currentHostname =
    hostname ?? (typeof window === 'undefined' ? '' : window.location.hostname)
  return WORKSPACE_HOSTS[currentHostname.toLowerCase()] ?? null
}

export function getWorkspaceMode(hostname?: string): WorkspaceMode | null {
  if (typeof window === 'undefined') return volatileMode

  const hostMode = getWorkspaceHostMode(hostname)
  if (hostMode) {
    volatileMode = hostMode
    try {
      if (window.localStorage.getItem(WORKSPACE_MODE_KEY) !== hostMode) {
        window.localStorage.setItem(WORKSPACE_MODE_KEY, hostMode)
      }
    } catch {
      // The host boundary still applies when browser storage is unavailable.
    }
    return hostMode
  }

  try {
    const storedMode = window.localStorage.getItem(WORKSPACE_MODE_KEY)
    volatileMode = isWorkspaceMode(storedMode) ? storedMode : null
    return volatileMode
  } catch {
    return volatileMode
  }
}

function announceModeChange(mode: WorkspaceMode | null): void {
  if (typeof window === 'undefined') return
  window.dispatchEvent(
    new CustomEvent<WorkspaceMode | null>(WORKSPACE_MODE_CHANGE_EVENT, { detail: mode }),
  )
}

export function setWorkspaceMode(mode: WorkspaceMode): void {
  const effectiveMode = getWorkspaceHostMode() ?? mode
  volatileMode = effectiveMode
  try {
    window.localStorage.setItem(WORKSPACE_MODE_KEY, effectiveMode)
  } catch {
    // Keep the current tab's route boundary usable when browser storage is unavailable.
  }
  announceModeChange(effectiveMode)
}

export function clearWorkspaceMode(): void {
  const hostMode = getWorkspaceHostMode()
  volatileMode = hostMode
  try {
    if (hostMode) {
      window.localStorage.setItem(WORKSPACE_MODE_KEY, hostMode)
    } else {
      window.localStorage.removeItem(WORKSPACE_MODE_KEY)
    }
  } catch {
    // The backend session is still revoked independently of this presentation hint.
  }
  announceModeChange(hostMode)
}

export function isPartnerWorkspacePath(pathname: string): boolean {
  const normalizedPath = pathname.replace(/\/+$/, '') || '/'
  return [
    '/',
    '/partner',
    '/partners',
    '/partners/login',
    '/partners/setup',
    '/partners/two-factor',
    '/partners/app',
    '/partners/not-found',
  ].includes(normalizedPath)
}

export function isPartnerFacingPath(pathname: string): boolean {
  const normalizedPath = pathname.replace(/\/+$/, '') || '/'
  return normalizedPath !== '/' && isPartnerWorkspacePath(normalizedPath)
}
