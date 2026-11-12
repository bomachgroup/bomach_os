import { useEffect, useLayoutEffect, useRef, useState, type MouseEvent } from 'react'
import { createPortal } from 'react-dom'
import {
  ArrowRight,
  Building2,
  Check,
  ChevronDown,
  ExternalLink,
  Grid2X2,
  Layers3,
  Megaphone,
} from 'lucide-react'

import type { PermissionSet } from '@/shared/auth/session'
import { rememberedWorkspaceHref } from '@/shared/auth/workspace-memory'
import {
  consumeWorkspaceSwitch,
  rememberWorkspaceSwitch,
  WORKSPACE_ARRIVAL_MS,
  WORKSPACE_SWITCH_DELAY_MS,
} from '@/shared/auth/workspace-switch'
import { canAccessWorkspaceApp, WORKSPACE_APPS, type WorkspaceApp } from './app-catalog'
import './app-switcher.css'

interface AppSwitcherProps {
  permissions: PermissionSet
  userId: string | number
  currentApp: WorkspaceApp['id']
  compact?: boolean
  placement?: 'left' | 'right'
}

function AppGlyph({ appId }: { appId: WorkspaceApp['id'] }) {
  const Icon = appId === 'os' ? Building2 : appId === 'services' ? Layers3 : Megaphone
  return <Icon aria-hidden="true" className="size-[18px]" />
}

function SwitchTransition({ app, phase }: { app: WorkspaceApp; phase: 'switching' | 'arriving' }) {
  return (
    <div
      className="workspace-switch-overlay"
      data-phase={phase}
      role="status"
      aria-live="polite"
      aria-label={`${phase === 'switching' ? 'Switching to' : 'Opening'} ${app.label}`}
    >
      <div className="workspace-switch-card">
        <div className="workspace-switch-brand" aria-hidden="true">
          <span className="workspace-switch-brand__letter">B</span>
          <span className="workspace-switch-brand__orbit" />
        </div>
        <div className="workspace-switch-route" aria-hidden="true">
          <span className="workspace-switch-route__app">
            <Grid2X2 className="size-[18px]" />
          </span>
          <span className="workspace-switch-route__line" />
          <span className="workspace-switch-route__arrow">
            <ArrowRight className="size-4" />
          </span>
          <span className="workspace-switch-route__destination">
            <AppGlyph appId={app.id} />
          </span>
        </div>
        <p className="workspace-switch-eyebrow">BOMACH WORKSPACE</p>
        <p className="workspace-switch-title">
          {phase === 'switching' ? 'Switching to' : 'Welcome to'} {app.label}
        </p>
        <p className="workspace-switch-description">{app.description}</p>
        <div className="workspace-switch-progress" aria-hidden="true">
          <span />
        </div>
      </div>
    </div>
  )
}

export function AppSwitcher({
  permissions,
  userId,
  currentApp,
  compact = false,
  placement = 'right',
}: AppSwitcherProps) {
  const apps = WORKSPACE_APPS.filter((app) => canAccessWorkspaceApp(app, permissions))
  const detailsRef = useRef<HTMLDetailsElement>(null)
  const menuRef = useRef<HTMLDivElement>(null)
  const [menuOpen, setMenuOpen] = useState(false)
  const [switchingTo, setSwitchingTo] = useState<WorkspaceApp | null>(null)
  const [arriving, setArriving] = useState(false)
  const currentWorkspace = WORKSPACE_APPS.find((app) => app.id === currentApp)

  useEffect(() => {
    const timer = window.setTimeout(() => {
      if (consumeWorkspaceSwitch(currentApp)) setArriving(true)
    }, 0)
    return () => window.clearTimeout(timer)
  }, [currentApp])

  useEffect(() => {
    if (!arriving) return
    const timer = window.setTimeout(() => setArriving(false), WORKSPACE_ARRIVAL_MS)
    return () => window.clearTimeout(timer)
  }, [arriving])

  useLayoutEffect(() => {
    if (!menuOpen || !detailsRef.current || !menuRef.current) return

    const details = detailsRef.current
    const menu = menuRef.current
    const positionMenu = () => {
      const anchor = details.getBoundingClientRect()
      const width = Math.min(320, window.innerWidth - 24)
      const desiredLeft = placement === 'left' ? anchor.left : anchor.right - width
      const viewportLeft = Math.min(Math.max(12, desiredLeft), window.innerWidth - width - 12)
      menu.style.left = `${viewportLeft - anchor.left}px`
      menu.style.right = 'auto'
      menu.style.width = `${width}px`
    }

    positionMenu()
    window.addEventListener('resize', positionMenu)
    return () => {
      window.removeEventListener('resize', positionMenu)
      menu.style.left = ''
      menu.style.right = ''
      menu.style.width = ''
    }
  }, [menuOpen, placement])

  function navigateToApp(event: MouseEvent<HTMLAnchorElement>, app: WorkspaceApp, href: string) {
    if (
      app.id === currentApp ||
      event.button !== 0 ||
      event.metaKey ||
      event.ctrlKey ||
      event.shiftKey ||
      event.altKey
    ) {
      return
    }

    event.preventDefault()
    rememberWorkspaceSwitch(app.id)
    detailsRef.current?.removeAttribute('open')
    setSwitchingTo(app)

    const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    window.setTimeout(
      () => window.location.assign(href),
      reducedMotion ? 0 : WORKSPACE_SWITCH_DELAY_MS,
    )
  }

  return (
    <>
      <details
        ref={detailsRef}
        className="group/app-switcher relative z-40 shrink-0"
        onToggle={(event) => setMenuOpen(event.currentTarget.open)}
      >
        <summary
          aria-label="Switch workspace"
          title="Switch workspace"
          className="workspace-switch-trigger border-border-subtle bg-surface text-text-secondary focus-visible:shadow-focus-ring hover:bg-surface-muted flex size-10 cursor-pointer list-none items-center justify-center rounded-xl border transition-colors focus-visible:outline-none [&::-webkit-details-marker]:hidden"
        >
          <Grid2X2
            aria-hidden="true"
            className="size-[17px] transition-transform duration-200 group-open/app-switcher:rotate-45 motion-reduce:transition-none"
          />
          <ChevronDown aria-hidden="true" className="workspace-switch-trigger__chevron" />
        </summary>
        <div
          ref={menuRef}
          className={`workspace-switch-menu border-border-subtle bg-surface shadow-elevation-lg absolute top-[calc(100%+0.65rem)] w-[min(20rem,calc(100vw-1.5rem))] rounded-[1.35rem] border p-2 ${placement === 'left' ? 'left-0' : 'right-0'}`}
          aria-label="Available workspaces"
        >
          <div className="workspace-switch-menu__header">
            <span className="workspace-switch-menu__title">Switch workspace</span>
          </div>
          <div className="workspace-switch-menu__list">
            {apps.map((app) => {
              const active = app.id === currentApp
              const href = rememberedWorkspaceHref(userId, app.id) ?? app.href
              const itemClassName = `workspace-switch-option ${active ? 'is-current' : ''}`
              const content = (
                <>
                  <span
                    className={`workspace-switch-option__icon workspace-switch-option__icon--${app.id}`}
                  >
                    <AppGlyph appId={app.id} />
                  </span>
                  <span className="workspace-switch-option__copy">
                    <span className="workspace-switch-option__name">{app.label}</span>
                    {!compact ? (
                      <span className="workspace-switch-option__description">
                        {app.description}
                      </span>
                    ) : null}
                  </span>
                  {active ? (
                    <span className="workspace-switch-option__state">
                      <Check aria-hidden="true" className="size-3.5" />
                      Current
                    </span>
                  ) : (
                    <ArrowRight aria-hidden="true" className="workspace-switch-option__arrow" />
                  )}
                </>
              )

              return (
                <div key={app.id} className={itemClassName}>
                  {active ? (
                    <span className="workspace-switch-option__main" aria-current="page">
                      {content}
                    </span>
                  ) : (
                    <a
                      href={href}
                      className="workspace-switch-option__main"
                      onClick={(event) => navigateToApp(event, app, href)}
                    >
                      {content}
                    </a>
                  )}
                  <a
                    href={href}
                    className="workspace-switch-option__open"
                    target="_blank"
                    rel="noopener noreferrer"
                    aria-label={`Open ${app.label} in a new tab`}
                    title={`Open ${app.label} in a new tab`}
                  >
                    <ExternalLink aria-hidden="true" className="size-4" />
                  </a>
                </div>
              )
            })}
          </div>
        </div>
      </details>
      {switchingTo
        ? createPortal(<SwitchTransition app={switchingTo} phase="switching" />, document.body)
        : null}
      {!switchingTo && arriving && currentWorkspace
        ? createPortal(<SwitchTransition app={currentWorkspace} phase="arriving" />, document.body)
        : null}
    </>
  )
}
