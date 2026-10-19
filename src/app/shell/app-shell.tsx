import { useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, Outlet, useNavigate, useRouterState } from '@tanstack/react-router'

import { Dialog } from '@/shared/ui/dialog'
import { Button } from '@/shared/ui/button'
import { Alert } from '@/shared/ui/alert'
import { StatusChip } from '@/shared/ui/status-chip'
import { authApi } from '@/shared/auth/auth.api'
import {
  authSessionQueryOptions,
  hasPermission,
  type AuthenticatedSession,
} from '@/shared/auth/session'
import { SESSION_ESTABLISHED_KEY, SESSION_EXPIRED_NOTICE_KEY } from '@/shared/api/api-client'
import {
  canSeeDestination,
  canVisitDestination,
  destinationForPath,
  NAVIGATION_CATEGORY_IDS,
  NAVIGATION_GROUPS,
  type NavigationCategoryId,
  sidebarDestinationsFor,
  type NavigationGroup,
  type ProtectedDestination,
} from '@/app/navigation/route-manifest'
import { ShellIcon } from './shell-icons'
import { NotificationCenter } from './notification-center'
import { Sidebar, type SidebarPreferences } from './sidebar'
import { handleDrawerKeyDown } from './shell-utils'
import { TwoFactorSettingsPanel } from '@/modules/auth/components/two-factor-settings-panel'
import { displayName, initials } from './account-utils'
import { Breadcrumbs, type BreadcrumbItem } from '@/shared/ui/breadcrumbs'
import { PageLayout } from '@/shared/ui/page-layout'

const PREFERENCES_KEY = 'bomach.sidebar.preferences.v2'
const LEGACY_PREFERENCES_KEY = 'bomach.sidebar.preferences.v1'

const initialPreferences: SidebarPreferences = {
  collapsed: false,
  expandedGroups: ['Dashboard'],
  collapsedGroups: [],
  expandedCategories: [],
  collapsedCategories: [],
  pinnedPaths: [],
}

function loadPreferences(): SidebarPreferences {
  try {
    const currentRaw = window.localStorage.getItem(PREFERENCES_KEY)
    const isLegacyPreferences = currentRaw === null
    const raw = currentRaw ?? window.localStorage.getItem(LEGACY_PREFERENCES_KEY)
    if (!raw) return initialPreferences
    const parsed = JSON.parse(raw) as Partial<SidebarPreferences>
    return {
      collapsed: parsed.collapsed === true,
      expandedGroups: Array.isArray(parsed.expandedGroups)
        ? parsed.expandedGroups.filter((group): group is NavigationGroup =>
            NAVIGATION_GROUPS.includes(group as NavigationGroup),
          )
        : initialPreferences.expandedGroups,
      collapsedGroups: Array.isArray(parsed.collapsedGroups)
        ? parsed.collapsedGroups.filter((group): group is NavigationGroup =>
            NAVIGATION_GROUPS.includes(group as NavigationGroup),
          )
        : [],
      expandedCategories:
        !isLegacyPreferences && Array.isArray(parsed.expandedCategories)
          ? parsed.expandedCategories.filter((category): category is NavigationCategoryId =>
              NAVIGATION_CATEGORY_IDS.includes(category as NavigationCategoryId),
            )
          : [],
      collapsedCategories:
        !isLegacyPreferences && Array.isArray(parsed.collapsedCategories)
          ? parsed.collapsedCategories.filter((category): category is NavigationCategoryId =>
              NAVIGATION_CATEGORY_IDS.includes(category as NavigationCategoryId),
            )
          : [],
      pinnedPaths: Array.isArray(parsed.pinnedPaths)
        ? parsed.pinnedPaths.filter((path): path is string => typeof path === 'string')
        : [],
    }
  } catch {
    return initialPreferences
  }
}

function savePreferences(preferences: SidebarPreferences) {
  try {
    window.localStorage.setItem(PREFERENCES_KEY, JSON.stringify(preferences))
  } catch {
    // The navigation remains usable if browser storage is unavailable.
  }
}

function breadcrumbItemsFor(
  destination: ProtectedDestination,
  permissions: AuthenticatedSession['permissions'],
): BreadcrumbItem[] {
  if (destination.path === '/dashboard') return []

  const items: BreadcrumbItem[] = []
  const segments = destination.path.split('/').filter(Boolean)

  for (let length = 1; length < segments.length; length += 1) {
    const parentPath = `/${segments.slice(0, length).join('/')}`
    if (parentPath === '/dashboard') continue

    const parent = destinationForPath(parentPath)
    if (
      !parent ||
      !canVisitDestination(parent, permissions) ||
      !canSeeDestination(parent, permissions)
    ) {
      continue
    }

    const label =
      parent.path === '/company'
        ? 'Company'
        : parent.path === '/hr'
          ? 'HR/Admin'
          : (parent.navigationLabel ?? parent.title)
    items.push({ label, to: parent.path })
  }

  return items
}

export function AppShell({ children }: { children?: ReactNode }) {
  const queryClient = useQueryClient()
  const navigate = useNavigate()
  const pathname = useRouterState({ select: (state) => state.location.pathname })
  const { data: session } = useQuery(authSessionQueryOptions())
  const [preferences, setPreferences] = useState<SidebarPreferences>(loadPreferences)
  const [isDesktop, setIsDesktop] = useState(() => window.matchMedia('(min-width: 1100px)').matches)
  const [drawerOpen, setDrawerOpen] = useState(false)
  const [profileOpen, setProfileOpen] = useState(false)
  const [signOutOpen, setSignOutOpen] = useState(false)
  const [sidebarHoverExpanded, setSidebarHoverExpanded] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const searchFocusRequested = useRef(false)
  const drawerRef = useRef<HTMLDivElement>(null)
  const drawerTriggerRef = useRef<HTMLButtonElement>(null)
  const sidebarRef = useRef<HTMLElement>(null)
  const searchInputRef = useRef<HTMLInputElement>(null)
  const sidebarDestinations = useMemo(
    () => (session ? sidebarDestinationsFor(session.permissions) : []),
    [session],
  )

  useEffect(() => {
    savePreferences(preferences)
  }, [preferences])

  useEffect(() => {
    const media = window.matchMedia('(min-width: 1100px)')
    const closeOnDesktop = (event: MediaQueryListEvent) => {
      setIsDesktop(event.matches)
      if (event.matches) setDrawerOpen(false)
    }
    media.addEventListener('change', closeOnDesktop)
    return () => media.removeEventListener('change', closeOnDesktop)
  }, [])

  useEffect(() => {
    if (!drawerOpen) return
    const previouslyFocused =
      document.activeElement instanceof HTMLElement ? document.activeElement : null
    const previousOverflow = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    drawerRef.current?.querySelector<HTMLElement>('[data-drawer-close]')?.focus()
    return () => {
      document.body.style.overflow = previousOverflow
      if (previouslyFocused?.isConnected) previouslyFocused.focus()
    }
  }, [drawerOpen])

  const updatePreferences = useCallback(
    (updater: (current: SidebarPreferences) => SidebarPreferences) => {
      setPreferences(updater)
    },
    [],
  )

  const focusSidebarSearch = useCallback(() => {
    const desktop = window.matchMedia('(min-width: 1100px)').matches
    if (desktop && preferences.collapsed) {
      searchFocusRequested.current = true
      updatePreferences((current) => ({ ...current, collapsed: false }))
    } else if (desktop || drawerOpen) {
      searchInputRef.current?.focus()
    } else {
      searchFocusRequested.current = true
      setDrawerOpen(true)
    }
  }, [drawerOpen, preferences.collapsed, updatePreferences])

  useEffect(() => {
    if (!searchFocusRequested.current) return
    const desktop = window.matchMedia('(min-width: 1100px)').matches
    if (!desktop && !drawerOpen) return
    if (desktop && preferences.collapsed) return
    searchInputRef.current?.focus()
    searchFocusRequested.current = false
  }, [drawerOpen, preferences.collapsed])

  useEffect(() => {
    const onKeyDown = (event: globalThis.KeyboardEvent) => {
      if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'k') {
        event.preventDefault()
        focusSidebarSearch()
      }
      if (event.key === 'Escape' && drawerOpen) setDrawerOpen(false)
    }
    document.addEventListener('keydown', onKeyDown)
    return () => document.removeEventListener('keydown', onKeyDown)
  }, [drawerOpen, focusSidebarSearch])

  const logoutMutation = useMutation({
    mutationFn: authApi.logout,
    onSuccess: async () => {
      window.sessionStorage.removeItem(SESSION_ESTABLISHED_KEY)
      window.sessionStorage.removeItem(SESSION_EXPIRED_NOTICE_KEY)
      queryClient.clear()
      setSignOutOpen(false)
      setProfileOpen(false)
      await navigate({ to: '/login' })
    },
  })

  const closeDrawer = useCallback(() => setDrawerOpen(false), [])

  if (!session) {
    return (
      <main className="bg-background flex min-h-svh items-center justify-center px-4" role="status">
        <span
          aria-hidden="true"
          className="border-primary size-8 animate-spin rounded-full border-4 border-r-transparent"
        />
        <span className="sr-only">Loading your workspace</span>
      </main>
    )
  }

  return (
    <div className="bg-background text-text-primary flex min-h-svh">
      <aside
        ref={sidebarRef}
        className={`desktop:sticky desktop:top-0 desktop:z-30 desktop:flex desktop:h-svh desktop:shrink-0 hidden transition-[width] duration-200 ease-in-out motion-reduce:transition-none ${preferences.collapsed && !sidebarHoverExpanded ? 'desktop:w-[72px]' : 'desktop:w-[300px]'}`}
        onMouseEnter={() => {
          if (preferences.collapsed && window.matchMedia('(min-width: 1100px)').matches) {
            setSidebarHoverExpanded(true)
          }
        }}
        onMouseLeave={() => {
          if (preferences.collapsed) setSidebarHoverExpanded(false)
        }}
        onBlurCapture={(event) => {
          if (
            !(event.relatedTarget instanceof Node) ||
            !event.currentTarget.contains(event.relatedTarget)
          ) {
            setSidebarHoverExpanded(false)
          }
        }}
      >
        <div className="h-full w-full">
          <Sidebar
            session={session}
            showNotifications={
              isDesktop && hasPermission(session.permissions, 'notifications', 'list')
            }
            activePath={pathname}
            destinations={sidebarDestinations}
            preferences={preferences}
            transientExpanded={preferences.collapsed && sidebarHoverExpanded}
            onKeepExpanded={() => {
              setSidebarHoverExpanded(false)
              updatePreferences((current) => ({ ...current, collapsed: false }))
            }}
            onPreferencesChange={updatePreferences}
            searchQuery={searchQuery}
            onSearchQueryChange={setSearchQuery}
            searchInputRef={searchInputRef}
            onOpenSearch={focusSidebarSearch}
            onOpenProfile={() => setProfileOpen(true)}
            profileOpen={profileOpen}
            onNavigate={closeDrawer}
          />
        </div>
      </aside>

      <div className="flex min-h-svh min-w-0 flex-1 flex-col">
        <header
          aria-label="Workspace header"
          className="bg-surface border-border-subtle phone:px-4 tablet:px-6 desktop:hidden sticky top-0 z-20 flex h-16 shrink-0 items-center gap-2 border-b px-3"
        >
          <Button
            ref={drawerTriggerRef}
            variant="ghost"
            size="icon"
            className="desktop:hidden -ml-1"
            aria-label="Open navigation menu"
            aria-expanded={drawerOpen}
            aria-controls={drawerOpen ? 'workspace-navigation' : undefined}
            onClick={() => setDrawerOpen(true)}
          >
            <ShellIcon name="menu" className="size-5" />
          </Button>
          <img
            src="/bomach-logo.png"
            alt="Bomach OS"
            className="phone:w-[92px] desktop:hidden h-9 w-[76px] shrink-0 object-contain object-left"
          />
          {!isDesktop && hasPermission(session.permissions, 'notifications', 'list') ? (
            <NotificationCenter session={session} />
          ) : null}
        </header>

        <main className="min-w-0 flex-1">{children ?? <Outlet />}</main>
      </div>

      {drawerOpen ? (
        <div className="desktop:hidden fixed inset-0 z-40">
          <button
            type="button"
            aria-label="Close navigation menu"
            className="absolute inset-0 size-full cursor-default bg-neutral-900/45"
            onClick={closeDrawer}
          />
          <div
            ref={drawerRef}
            id="workspace-navigation"
            role="dialog"
            aria-modal="true"
            aria-label="Workspace navigation"
            className="bg-surface shadow-elevation-lg relative flex h-dvh w-[min(300px,calc(100vw-2.5rem))] max-w-full flex-col"
            onKeyDown={handleDrawerKeyDown}
          >
            <Sidebar
              session={session}
              activePath={pathname}
              destinations={sidebarDestinations}
              preferences={{ ...preferences, collapsed: false }}
              onPreferencesChange={updatePreferences}
              searchQuery={searchQuery}
              onSearchQueryChange={setSearchQuery}
              searchInputRef={searchInputRef}
              onOpenSearch={focusSidebarSearch}
              onOpenProfile={() => {
                setProfileOpen(true)
                closeDrawer()
              }}
              profileOpen={profileOpen}
              onNavigate={closeDrawer}
              onCloseDrawer={closeDrawer}
            />
          </div>
        </div>
      ) : null}

      <ProfileDialog
        open={profileOpen}
        onOpenChange={setProfileOpen}
        session={session}
        onSignOut={() => {
          setProfileOpen(false)
          setSignOutOpen(true)
        }}
      />

      <Dialog
        open={signOutOpen}
        onOpenChange={setSignOutOpen}
        title="Sign out of Bomach OS?"
        description="This will close your current session on this device."
        size="sm"
        footer={
          <>
            <Button
              variant="outline"
              onClick={() => setSignOutOpen(false)}
              disabled={logoutMutation.isPending}
            >
              Cancel
            </Button>
            <Button
              variant="danger"
              isLoading={logoutMutation.isPending}
              onClick={() => logoutMutation.mutate()}
            >
              Sign out
            </Button>
          </>
        }
      >
        {logoutMutation.error ? (
          <Alert tone="danger" title="Could not sign out">
            Check your connection and try again.
          </Alert>
        ) : (
          <div className="bg-danger-subtle rounded-surface flex items-start gap-3 p-4">
            <span className="text-danger-foreground mt-0.5 flex size-9 shrink-0 items-center justify-center rounded-full bg-white/70">
              <ShellIcon name="logout" className="size-[18px]" />
            </span>
            <div className="min-w-0">
              <p className="text-label text-danger-foreground font-semibold">End this session?</p>
              <p className="text-body-sm text-text-secondary mt-1">
                You will need to sign in again to access your workspace.
              </p>
              <p className="text-caption text-text-muted mt-2 truncate">{session.user.email}</p>
            </div>
          </div>
        )}
      </Dialog>
    </div>
  )
}

function ProfileDialog({
  open,
  onOpenChange,
  session,
  onSignOut,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  session: AuthenticatedSession
  onSignOut: () => void
}) {
  const name = displayName(session)
  const personalFields = [
    ['Username', session.employee.username || session.user.username],
    ['Phone', session.user.phone_number],
  ].filter((item): item is [string, string] => Boolean(item[1]))
  const employmentFields = [
    ['Employee ID', session.employee.employee_id],
    ['Designation', session.employee.designation],
    ['Employment status', session.employee.employment_status],
  ].filter((item): item is [string, string] => Boolean(item[1]))
  const roleNames = session.roles.map((role) => role.name).filter(Boolean)

  return (
    <Dialog
      open={open}
      onOpenChange={onOpenChange}
      title="Your profile"
      description="Account details and profile access"
      size="lg"
      footer={
        <div className="tablet:flex-row tablet:justify-between flex w-full flex-col gap-2">
          <Link
            to="/dashboard/my-profile"
            className="border-border-strong bg-surface text-primary focus-visible:shadow-focus-ring rounded-control text-label hover:bg-surface-muted tablet:w-auto inline-flex min-h-11 w-full items-center justify-center gap-2 border px-4 font-semibold transition-colors focus-visible:outline-none"
            onClick={() => onOpenChange(false)}
          >
            <ShellIcon name="user" className="size-4" />
            View full profile
          </Link>
          <Button
            variant="danger"
            leadingIcon={<ShellIcon name="logout" className="size-4" />}
            className="tablet:w-auto w-full"
            onClick={() => {
              onOpenChange(false)
              onSignOut()
            }}
          >
            Sign out
          </Button>
        </div>
      }
    >
      <div className="bg-surface-muted/35 border-border-strong rounded-surface flex items-center gap-4 border p-4">
        <span
          className="bg-primary-subtle text-primary text-h2 ring-primary/15 flex size-14 shrink-0 items-center justify-center rounded-full font-semibold ring-1"
          aria-hidden="true"
        >
          {initials(session)}
        </span>
        <div className="min-w-0">
          <p className="text-h3 truncate font-semibold">{name}</p>
          <p className="text-body-sm text-text-secondary mt-0.5 truncate">{session.user.email}</p>
          <p className="text-body-sm text-text-secondary mt-1 truncate">
            {session.employee.designation || 'Bomach OS account'}
          </p>
          <div className="mt-2 flex flex-wrap gap-1.5">
            <StatusChip
              label={session.user.is_verified ? 'Verified' : 'Not verified'}
              tone={session.user.is_verified ? 'success' : 'warning'}
              dense
            />
            {typeof session.employee.is_active === 'boolean' ? (
              <StatusChip
                label={session.employee.is_active ? 'Active' : 'Inactive'}
                tone={session.employee.is_active ? 'success' : 'danger'}
                dense
              />
            ) : null}
          </div>
        </div>
      </div>
      {roleNames.length > 0 ? (
        <section className="mt-5" aria-labelledby="account-roles-heading">
          <div className="mb-2 flex items-center justify-between gap-3">
            <h3 id="account-roles-heading" className="text-label font-semibold">
              Access roles
            </h3>
            <span className="text-caption text-text-secondary">
              {roleNames.length} {roleNames.length === 1 ? 'role' : 'roles'}
            </span>
          </div>
          <div className="flex flex-wrap gap-2">
            {roleNames.map((role) => (
              <span
                key={role}
                className="bg-primary-subtle text-primary rounded-pill text-caption ring-primary/15 px-3 py-1 ring-1"
              >
                {role}
              </span>
            ))}
          </div>
        </section>
      ) : null}
      {personalFields.length > 0 ? (
        <ProfileDetailsSection
          id="account-personal-heading"
          title="Personal information"
          fields={personalFields}
        />
      ) : null}
      {employmentFields.length > 0 ? (
        <ProfileDetailsSection
          id="account-employment-heading"
          title="Employment details"
          fields={employmentFields}
        />
      ) : null}
      {open ? (
        <section className="border-border-strong mt-5 border-t pt-5">
          <TwoFactorSettingsPanel />
        </section>
      ) : null}
    </Dialog>
  )
}

function ProfileDetailsSection({
  id,
  title,
  fields,
}: {
  id: string
  title: string
  fields: [string, string][]
}) {
  return (
    <section className="mt-5" aria-labelledby={id}>
      <h3 id={id} className="text-label mb-2 font-semibold">
        {title}
      </h3>
      <dl className="border-border-strong divide-border-strong rounded-control divide-y border px-3">
        {fields.map(([label, value]) => (
          <div
            key={label}
            className="grid grid-cols-[minmax(6.5rem,0.8fr)_minmax(0,1.2fr)] gap-3 py-3"
          >
            <dt className="text-body-sm text-text-secondary">{label}</dt>
            <dd className="text-body-sm min-w-0 text-right font-medium break-words">{value}</dd>
          </div>
        ))}
      </dl>
    </section>
  )
}

export function ComingSoonPage({ destination }: { destination: ProtectedDestination }) {
  const { data: session } = useQuery(authSessionQueryOptions())
  const breadcrumbs = session ? breadcrumbItemsFor(destination, session.permissions) : []

  return (
    <PageLayout title={destination.title} breadcrumbs={<Breadcrumbs items={breadcrumbs} />}>
      <section
        className="bg-surface border-border-subtle shadow-elevation-sm rounded-surface phone:p-6 flex items-center gap-4 border p-5"
        aria-labelledby="coming-soon-title"
      >
        <div className="bg-primary-subtle text-primary rounded-control flex size-11 shrink-0 items-center justify-center">
          <ShellIcon name={destination.icon} className="size-5" />
        </div>
        <h2 id="coming-soon-title" className="text-label font-semibold">
          This page is coming soon
        </h2>
      </section>
    </PageLayout>
  )
}

export function NoAccessContent() {
  return (
    <PageLayout title="No available workspace page" eyebrow="Workspace access">
      <div className="mx-auto max-w-2xl">
        <section className="bg-surface border-border-subtle shadow-elevation-sm rounded-surface phone:p-6 tablet:p-8 border p-5">
          <div className="bg-warning-subtle text-warning-foreground rounded-control mb-5 flex size-11 items-center justify-center">
            <ShellIcon name="shield" className="size-5" />
          </div>
          <p className="text-body-sm text-text-secondary">
            Your account is signed in, but none of the React workspace pages are available for your
            permissions yet. Contact an administrator if you believe this is unexpected.
          </p>
        </section>
      </div>
    </PageLayout>
  )
}
