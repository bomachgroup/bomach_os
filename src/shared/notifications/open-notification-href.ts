import {
  isMarketingWorkspaceHref,
  isServicesWorkspaceHref,
} from '@/shared/auth/navigation'
import {
  rememberWorkspaceSwitch,
  WORKSPACE_SWITCH_DELAY_MS,
  type WorkspaceSwitchApp,
} from '@/shared/auth/workspace-switch'

type NavigateFn = (opts: { to: never }) => unknown

function workspaceAppForHref(href: string): WorkspaceSwitchApp | null {
  if (isMarketingWorkspaceHref(href)) return 'marketing'
  if (isServicesWorkspaceHref(href)) return 'services'
  return null
}

/** Open an in-app notification destination, including cross-workspace deep links. */
export function openNotificationHref(href: string, navigate: NavigateFn) {
  const workspace = workspaceAppForHref(href)
  if (workspace) {
    rememberWorkspaceSwitch(workspace, {
      sourceApp: 'os',
      origin: { x: 0.92, y: 0.08 },
    })
    const reducedMotion =
      typeof window !== 'undefined' &&
      window.matchMedia('(prefers-reduced-motion: reduce)').matches
    window.setTimeout(
      () => window.location.assign(href),
      reducedMotion ? 0 : WORKSPACE_SWITCH_DELAY_MS,
    )
    return
  }

  void navigate({ to: href as never })
}
