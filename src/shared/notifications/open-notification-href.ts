import { isMarketingWorkspaceHref, isServicesWorkspaceHref } from '@/shared/auth/navigation'

type NavigateFn = (opts: { to: never }) => unknown

/** Open an in-app notification destination, including cross-workspace deep links. */
export function openNotificationHref(href: string, navigate: NavigateFn) {
  if (isMarketingWorkspaceHref(href) || isServicesWorkspaceHref(href)) {
    // Notification navigation should feel like following a link, not switching
    // workspaces. Keep the browser history entry so Back returns to its source.
    window.location.assign(href)
    return
  }

  void navigate({ to: href as never })
}
