export type WorkspaceMode = 'staff' | 'partner'

export const WORKSPACE_MODE_KEY = 'bomach:workspace-mode'
export const WORKSPACE_MODE_CHANGE_EVENT = 'bomach:workspace-mode-change'

let volatileMode: WorkspaceMode | null = null

function isWorkspaceMode(value: string | null): value is WorkspaceMode {
  return value === 'staff' || value === 'partner'
}

export function getWorkspaceMode(): WorkspaceMode | null {
  if (typeof window === 'undefined') return volatileMode

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
  volatileMode = mode
  try {
    window.localStorage.setItem(WORKSPACE_MODE_KEY, mode)
  } catch {
    // Keep the current tab's route boundary usable when browser storage is unavailable.
  }
  announceModeChange(mode)
}

export function clearWorkspaceMode(): void {
  volatileMode = null
  try {
    window.localStorage.removeItem(WORKSPACE_MODE_KEY)
  } catch {
    // The backend session is still revoked independently of this presentation hint.
  }
  announceModeChange(null)
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
