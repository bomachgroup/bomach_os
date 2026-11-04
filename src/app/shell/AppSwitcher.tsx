import { Grid2X2 } from 'lucide-react'

import type { PermissionSet } from '@/shared/auth/session'
import { canAccessWorkspaceApp, WORKSPACE_APPS, type WorkspaceApp } from './app-catalog'

interface AppSwitcherProps {
  permissions: PermissionSet
  currentApp: WorkspaceApp['id']
  compact?: boolean
  placement?: 'left' | 'right'
}

export function AppSwitcher({
  permissions,
  currentApp,
  compact = false,
  placement = 'right',
}: AppSwitcherProps) {
  const apps = WORKSPACE_APPS.filter((app) => canAccessWorkspaceApp(app, permissions))

  return (
    <details className="group/app-switcher relative z-40 shrink-0">
      <summary
        aria-label="Switch application"
        title="Switch application"
        className="border-border-subtle bg-surface text-text-secondary focus-visible:shadow-focus-ring hover:bg-surface-muted flex size-9 cursor-pointer list-none items-center justify-center rounded-xl border transition-colors focus-visible:outline-none [&::-webkit-details-marker]:hidden"
      >
        <Grid2X2 aria-hidden="true" className="size-[17px]" />
      </summary>
      <div
        className={`bg-surface border-border-subtle shadow-elevation-lg absolute top-[calc(100%+0.5rem)] w-[min(18rem,calc(100vw-2rem))] rounded-2xl border p-2 ${placement === 'left' ? 'left-0' : 'right-0'}`}
      >
        <p className="text-caption text-text-muted px-3 py-2 font-semibold">Your applications</p>
        <div className="space-y-1">
          {apps.map((app) => {
            const active = app.id === currentApp
            return (
              <a
                key={app.id}
                href={app.href}
                aria-current={active ? 'page' : undefined}
                className={`focus-visible:shadow-focus-ring flex min-h-14 items-center gap-3 rounded-xl px-3 py-2.5 transition-colors outline-none ${active ? 'bg-primary-subtle/70 text-primary' : 'text-text-primary hover:bg-surface-muted'}`}
              >
                <span className="bg-surface border-border-subtle flex size-9 shrink-0 items-center justify-center rounded-xl border">
                  <Grid2X2 aria-hidden="true" className="size-4" />
                </span>
                <span className="min-w-0 flex-1">
                  <span className="text-label block font-semibold">{app.label}</span>
                  {!compact ? (
                    <span className="text-caption text-text-muted block truncate">
                      {app.description}
                    </span>
                  ) : null}
                </span>
                {active ? <span className="text-caption text-text-muted">Current</span> : null}
              </a>
            )
          })}
        </div>
      </div>
    </details>
  )
}
