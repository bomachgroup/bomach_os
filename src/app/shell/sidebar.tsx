import {
  useEffect,
  useId,
  useMemo,
  useRef,
  useState,
  type KeyboardEvent as ReactKeyboardEvent,
  type RefObject,
} from 'react'
import { Link, useNavigate } from '@tanstack/react-router'

import { Button } from '@/shared/ui/button'
import { Tooltip } from '@/shared/ui/tooltip'
import { type AuthenticatedSession } from '@/shared/auth/session'
import {
  destinationForPath,
  NAVIGATION_CATEGORIES,
  NAVIGATION_GROUPS,
  type NavigationCategoryId,
  type NavigationGroup,
  type ProtectedDestination,
} from '@/app/navigation/route-manifest'
import { ShellIcon } from './shell-icons'
import { AppSwitcher } from './AppSwitcher'
import { NotificationCenter } from './notification-center'
import { displayName, initials } from './account-utils'
import { navigationCategoryLabel, navigationGroupLabel } from './shell-utils'

export interface SidebarPreferences {
  collapsed: boolean
  expandedGroups: NavigationGroup[]
  collapsedGroups: NavigationGroup[]
  expandedCategories: NavigationCategoryId[]
  collapsedCategories: NavigationCategoryId[]
  pinnedPaths: string[]
}

function navigationTitle(destination: ProtectedDestination) {
  return destination.navigationLabel ?? destination.title
}

export function Sidebar({
  session,
  activePath,
  expandedPath = activePath,
  destinations,
  preferences,
  onPreferencesChange,
  searchQuery,
  onSearchQueryChange,
  searchInputRef,
  onOpenSearch,
  onOpenProfile,
  profileOpen = false,
  showNotifications = false,
  onNavigate,
  onCloseDrawer,
  transientExpanded = false,
  onKeepExpanded,
}: {
  session: AuthenticatedSession
  activePath: string
  expandedPath?: string
  destinations: ProtectedDestination[]
  preferences: SidebarPreferences
  onPreferencesChange: (updater: (current: SidebarPreferences) => SidebarPreferences) => void
  searchQuery: string
  onSearchQueryChange: (query: string) => void
  searchInputRef: RefObject<HTMLInputElement | null>
  onOpenSearch: () => void
  onOpenProfile: () => void
  profileOpen?: boolean
  showNotifications?: boolean
  onNavigate: () => void
  onCloseDrawer?: () => void
  transientExpanded?: boolean
  onKeepExpanded?: () => void
}) {
  const collapsed = preferences.collapsed && !onCloseDrawer && !transientExpanded
  const currentDestination = destinationForPath(expandedPath)
  const activeDestination = destinationForPath(activePath)
  const pinned = destinations.filter((item) => preferences.pinnedPaths.includes(item.path))

  function toggleGroup(group: NavigationGroup) {
    if (collapsed) {
      onPreferencesChange((current) => ({
        ...current,
        collapsed: false,
        expandedGroups: [...new Set([...current.expandedGroups, group])],
        collapsedGroups: current.collapsedGroups.filter((item) => item !== group),
      }))
      return
    }
    const isOpen =
      preferences.expandedGroups.includes(group) ||
      (currentDestination?.group === group && !preferences.collapsedGroups.includes(group))
    onPreferencesChange((current) => ({
      ...current,
      expandedGroups: isOpen
        ? current.expandedGroups.filter((item) => item !== group)
        : [...current.expandedGroups, group],
      collapsedGroups: isOpen
        ? [...new Set([...current.collapsedGroups, group])]
        : current.collapsedGroups.filter((item) => item !== group),
    }))
  }

  function togglePin(path: string) {
    onPreferencesChange((current) => ({
      ...current,
      pinnedPaths: current.pinnedPaths.includes(path)
        ? current.pinnedPaths.filter((item) => item !== path)
        : [...current.pinnedPaths, path],
    }))
  }

  function activateDestination(item: ProtectedDestination) {
    onPreferencesChange((current) => ({
      ...current,
      expandedGroups: [...new Set([...current.expandedGroups, item.group])],
      collapsedGroups: current.collapsedGroups.filter((group) => group !== item.group),
      ...(item.navigationCategory
        ? {
            expandedCategories: [
              ...new Set([...current.expandedCategories, item.navigationCategory]),
            ],
            collapsedCategories: current.collapsedCategories.filter(
              (category) => category !== item.navigationCategory,
            ),
          }
        : {}),
    }))
    onNavigate()
  }

  function toggleCategory(category: NavigationCategoryId) {
    const isOpen =
      preferences.expandedCategories.includes(category) ||
      (currentDestination?.navigationCategory === category &&
        !preferences.collapsedCategories.includes(category))
    onPreferencesChange((current) => ({
      ...current,
      expandedCategories: isOpen
        ? current.expandedCategories.filter((item) => item !== category)
        : [...current.expandedCategories, category],
      collapsedCategories: isOpen
        ? [...new Set([...current.collapsedCategories, category])]
        : current.collapsedCategories.filter((item) => item !== category),
    }))
  }

  const sidebarToggle = (
    <Button
      variant="ghost"
      size="icon"
      className={collapsed ? 'size-8' : undefined}
      aria-label={
        transientExpanded
          ? 'Keep sidebar expanded'
          : collapsed
            ? 'Expand sidebar'
            : 'Collapse sidebar'
      }
      title={
        transientExpanded
          ? 'Keep sidebar expanded'
          : collapsed
            ? 'Expand sidebar'
            : 'Collapse sidebar'
      }
      onClick={() => {
        if (transientExpanded) {
          onKeepExpanded?.()
          return
        }
        onPreferencesChange((current) => ({ ...current, collapsed: !current.collapsed }))
      }}
    >
      <ShellIcon
        name={collapsed && !transientExpanded ? 'expand' : 'collapse'}
        className="size-5"
      />
    </Button>
  )

  return (
    <div className="bg-surface border-border-subtle flex h-full min-h-0 w-full flex-col border-r">
      <div
        className={`border-border-subtle flex shrink-0 border-b ${onCloseDrawer ? 'h-[70px] items-center justify-between px-4' : collapsed ? 'h-20 flex-col justify-center gap-1 px-1' : 'h-20 items-center justify-between px-4'}`}
      >
        <Link
          to="/dashboard"
          onClick={onNavigate}
          aria-label="Bomach OS home"
          className="focus-visible:shadow-focus-ring rounded-control flex min-w-0 items-center focus-visible:outline-none"
        >
          <img
            src="/bomach-logo.png"
            alt="Bomach OS"
            className={
              collapsed ? 'h-9 w-9 object-contain' : 'h-10 w-[145px] object-contain object-left'
            }
          />
        </Link>
        {onCloseDrawer ? (
          <div className="flex items-center gap-2">
            <AppSwitcher
              permissions={session.permissions}
              userId={session.user.id}
              currentApp="os"
              compact
              placement="right"
            />
            <Button
              data-drawer-close
              variant="ghost"
              size="icon"
              aria-label="Close navigation menu"
              onClick={onCloseDrawer}
            >
              <ShellIcon name="close" className="size-5" />
            </Button>
          </div>
        ) : collapsed ? (
          <div className="flex items-center justify-center gap-0">
            <AppSwitcher
              permissions={session.permissions}
              userId={session.user.id}
              currentApp="os"
              compact
              placement="left"
            />
            {showNotifications ? (
              <NotificationCenter session={session} placement="sidebar" />
            ) : null}
            {sidebarToggle}
          </div>
        ) : (
          <div className="flex items-center gap-1">
            <AppSwitcher
              permissions={session.permissions}
              userId={session.user.id}
              currentApp="os"
              placement="left"
            />
            {showNotifications ? (
              <NotificationCenter session={session} placement="sidebar" />
            ) : null}
            {sidebarToggle}
          </div>
        )}
      </div>

      <div className={`relative z-30 shrink-0 px-3 pt-3 ${collapsed ? 'flex justify-center' : ''}`}>
        {collapsed ? (
          <Button
            variant="outline"
            size="icon"
            aria-label="Search pages"
            title="Search pages"
            onClick={onOpenSearch}
            leadingIcon={<ShellIcon name="search" className="size-[18px] shrink-0" />}
          />
        ) : (
          <SidebarSearch
            query={searchQuery}
            onQueryChange={onSearchQueryChange}
            inputRef={searchInputRef}
            destinations={destinations}
            onSelect={activateDestination}
          />
        )}
      </div>

      <nav
        aria-label="Main navigation"
        className="min-h-0 flex-1 overflow-y-auto overscroll-contain px-2 pt-3 pb-4"
      >
        {pinned.length > 0 && !collapsed ? (
          <section
            aria-label="Pinned destinations"
            className="bg-surface-muted/35 border-border-subtle rounded-surface mb-5 border p-2"
          >
            <h2 className="text-overline text-text-muted flex items-center gap-2 px-2 pt-1 pb-2">
              <ShellIcon name="pin" className="size-3.5" />
              PINNED
            </h2>
            <div className="space-y-1">
              {pinned.map((item) => (
                <NavigationLink
                  key={`pinned-${item.path}`}
                  destination={item}
                  activePath={activePath}
                  collapsed={false}
                  onNavigate={() => activateDestination(item)}
                  pinned
                  onTogglePin={togglePin}
                />
              ))}
            </div>
          </section>
        ) : null}

        {(['Workspace', 'People', 'Operations'] as const).map((section) => {
          const sectionDestinations = destinations.filter((item) => item.section === section)
          const primaryDestinations = sectionDestinations.filter(
            (item) => item.path === '/dashboard',
          )
          const groups = NAVIGATION_GROUPS.filter((group) =>
            sectionDestinations.some((item) => item.group === group && item.path !== '/dashboard'),
          )
          if (groups.length === 0 && primaryDestinations.length === 0) return null
          return (
            <section
              key={section}
              aria-label={section}
              className={
                section !== 'Workspace' ? 'border-border-subtle mt-4 mb-4 border-t pt-4' : 'mb-4'
              }
            >
              {!collapsed ? (
                <h2 className="text-overline text-text-muted flex items-center gap-2 px-3 pt-1 pb-2">
                  <span>{section.toUpperCase()}</span>
                  <span className="bg-border-subtle h-px flex-1" aria-hidden="true" />
                </h2>
              ) : null}
              <div className="space-y-1">
                {primaryDestinations.map((item) => (
                  <NavigationLink
                    key={item.path}
                    destination={item}
                    activePath={activePath}
                    collapsed={collapsed}
                    onNavigate={() => activateDestination(item)}
                    pinned={preferences.pinnedPaths.includes(item.path)}
                    onTogglePin={togglePin}
                  />
                ))}
                {groups.map((group) => {
                  const entries = sectionDestinations.filter(
                    (item) => item.group === group && item.path !== '/dashboard',
                  )
                  const expanded =
                    preferences.expandedGroups.includes(group) ||
                    (currentDestination?.group === group &&
                      currentDestination.path !== '/dashboard' &&
                      !preferences.collapsedGroups.includes(group)) ||
                    (Boolean(onCloseDrawer) &&
                      currentDestination?.group === group &&
                      currentDestination.path !== '/dashboard')
                  const groupLabel = navigationGroupLabel(group)
                  const groupIcon =
                    group === 'Dashboard'
                      ? 'task'
                      : group === 'Company'
                        ? 'building'
                        : group === 'Operations'
                          ? 'briefcase'
                          : 'people'
                  const activeGroup =
                    activeDestination?.group === group && activeDestination.path !== '/dashboard'
                  const categories = NAVIGATION_CATEGORIES[group]
                    .map((category) => ({
                      ...category,
                      entries: entries.filter((item) => item.navigationCategory === category.id),
                    }))
                    .filter((category) => category.entries.length > 0)
                  const directEntries = entries.filter((item) => !item.navigationCategory)
                  return (
                    <div key={group}>
                      <button
                        type="button"
                        className={`nav-group-trigger focus-visible:shadow-focus-ring rounded-control text-label flex min-h-11 w-full items-center gap-3 border px-3 text-left font-semibold transition-colors focus-visible:outline-none ${activeGroup ? 'border-primary/15 bg-primary-subtle/70 text-primary' : 'text-text-secondary hover:border-border-subtle hover:bg-surface-muted hover:text-text-primary border-transparent'} ${collapsed ? 'justify-center px-0' : ''}`}
                        aria-label={`${groupLabel} navigation group`}
                        aria-expanded={!collapsed && expanded}
                        title={collapsed ? groupLabel : undefined}
                        onClick={() => toggleGroup(group)}
                      >
                        <ShellIcon name={groupIcon} className="size-[19px] shrink-0" />
                        {!collapsed ? (
                          <>
                            <span className="min-w-0 flex-1 truncate">{groupLabel}</span>
                            <ShellIcon
                              name={expanded ? 'chevron-down' : 'chevron'}
                              className="size-4 transition-transform"
                            />
                          </>
                        ) : null}
                      </button>
                      {expanded && !collapsed ? (
                        <div className="border-border-subtle mt-1 ml-5 space-y-1 border-l pl-2">
                          {directEntries.map((item) => (
                            <div key={item.path} className="relative">
                              <span
                                className="bg-border-subtle absolute top-1/2 -left-2 h-px w-[18px]"
                                aria-hidden="true"
                              />
                              <NavigationLink
                                destination={item}
                                activePath={activePath}
                                collapsed={false}
                                onNavigate={() => activateDestination(item)}
                                pinned={preferences.pinnedPaths.includes(item.path)}
                                onTogglePin={togglePin}
                              />
                            </div>
                          ))}
                          {categories.map((category) => {
                            const categoryCurrent =
                              currentDestination?.navigationCategory === category.id
                            const categoryActive =
                              activeDestination?.navigationCategory === category.id
                            const firstCategoryDefaultsOpen =
                              category.id === categories[0]?.id &&
                              preferences.expandedCategories.length === 0 &&
                              !preferences.collapsedCategories.includes(category.id)
                            const categoryExpanded =
                              preferences.expandedCategories.includes(category.id) ||
                              firstCategoryDefaultsOpen ||
                              (Boolean(onCloseDrawer) && categoryCurrent) ||
                              (categoryCurrent &&
                                !preferences.collapsedCategories.includes(category.id))
                            return (
                              <div key={category.id} className="relative">
                                <span
                                  className="bg-border-subtle absolute top-[22px] -left-2 h-px w-[18px]"
                                  aria-hidden="true"
                                />
                                <Tooltip
                                  content={category.label}
                                  placement="top"
                                  showDelayMs={1000}
                                  className="min-w-0 flex-1"
                                >
                                  <button
                                    type="button"
                                    className={`nav-category-trigger focus-visible:shadow-focus-ring rounded-control text-caption flex min-h-9 w-full items-center gap-2 px-2.5 text-left font-semibold transition-colors focus-visible:outline-none ${categoryActive ? 'text-primary' : 'text-text-muted hover:bg-surface-muted hover:text-text-primary'}`}
                                    aria-label={`${category.label} navigation subgroup`}
                                    aria-expanded={categoryExpanded}
                                    onClick={() => toggleCategory(category.id)}
                                  >
                                    <span className="min-w-0 flex-1 leading-snug whitespace-normal">
                                      {category.label}
                                    </span>
                                    <ShellIcon
                                      name={categoryExpanded ? 'chevron-down' : 'chevron'}
                                      className="size-3.5 shrink-0 transition-transform"
                                    />
                                  </button>
                                </Tooltip>
                                {categoryExpanded ? (
                                  <div className="border-border-subtle/80 mt-0.5 ml-2 space-y-1 border-l pl-2">
                                    {category.entries.map((item) => (
                                      <div key={item.path} className="relative">
                                        <span
                                          className="bg-border-subtle absolute top-1/2 -left-2 h-px w-[18px]"
                                          aria-hidden="true"
                                        />
                                        <NavigationLink
                                          destination={item}
                                          activePath={activePath}
                                          collapsed={false}
                                          onNavigate={() => activateDestination(item)}
                                          pinned={preferences.pinnedPaths.includes(item.path)}
                                          onTogglePin={togglePin}
                                        />
                                      </div>
                                    ))}
                                  </div>
                                ) : null}
                              </div>
                            )
                          })}
                        </div>
                      ) : null}
                    </div>
                  )
                })}
              </div>
            </section>
          )
        })}

        {collapsed ? (
          <div className="border-border-subtle mt-3 space-y-1 border-t pt-3">
            {pinned.map((item) => (
              <NavigationLink
                key={`pinned-collapsed-${item.path}`}
                destination={item}
                activePath={activePath}
                collapsed
                onNavigate={() => activateDestination(item)}
                pinned
                onTogglePin={togglePin}
              />
            ))}
          </div>
        ) : null}
      </nav>

      <div
        className={`border-border-subtle shrink-0 border-t p-2.5 ${collapsed ? 'space-y-1' : 'space-y-2'}`}
      >
        <button
          type="button"
          className={`focus-visible:shadow-focus-ring rounded-surface flex min-h-[3.5rem] w-full items-center gap-3 p-2 text-left transition-colors focus-visible:outline-none ${collapsed ? 'justify-center' : 'border-border-subtle bg-surface-muted/40 hover:bg-surface-muted border'}`}
          aria-label={`Open profile for ${displayName(session)}`}
          aria-haspopup="dialog"
          aria-expanded={profileOpen}
          title={collapsed ? displayName(session) : undefined}
          onClick={onOpenProfile}
        >
          <span
            className="bg-primary-subtle text-primary text-label flex size-9 shrink-0 items-center justify-center rounded-full font-semibold"
            aria-hidden="true"
          >
            {initials(session)}
          </span>
          {!collapsed ? (
            <span className="min-w-0 flex-1">
              <span className="text-label block truncate font-semibold">
                {displayName(session)}
              </span>
              <span className="text-caption text-text-muted block truncate">
                {session.user.email}
              </span>
            </span>
          ) : null}
          {!collapsed ? (
            <ShellIcon name="chevron-down" className="text-text-muted size-4 shrink-0" />
          ) : null}
        </button>
      </div>
    </div>
  )
}

function NavigationLink({
  destination,
  activePath,
  collapsed,
  onNavigate,
  pinned,
  onTogglePin,
}: {
  destination: ProtectedDestination
  activePath: string
  collapsed: boolean
  onNavigate: () => void
  pinned: boolean
  onTogglePin: (path: string) => void
}) {
  const active =
    activePath === destination.path ||
    (destination.path === '/works/projects' && activePath.startsWith('/works/projects/')) ||
    (destination.path.includes('$') &&
      destination.path.split('/').length === activePath.split('/').length &&
      destination.path
        .split('/')
        .every(
          (segment, index) => segment.startsWith('$') || segment === activePath.split('/')[index],
        ))
  const [touchMenuOpen, setTouchMenuOpen] = useState(false)
  const touchMenuId = useId()
  const navRowRef = useRef<HTMLDivElement>(null)
  const touchMenuTriggerRef = useRef<HTMLButtonElement>(null)
  const label = navigationTitle(destination)

  useEffect(() => {
    if (!touchMenuOpen) return
    const onPointerDown = (event: PointerEvent) => {
      if (!navRowRef.current?.contains(event.target as Node)) setTouchMenuOpen(false)
    }
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        event.stopPropagation()
        setTouchMenuOpen(false)
        touchMenuTriggerRef.current?.focus()
      }
    }
    document.addEventListener('pointerdown', onPointerDown)
    document.addEventListener('keydown', onKeyDown)
    return () => {
      document.removeEventListener('pointerdown', onPointerDown)
      document.removeEventListener('keydown', onKeyDown)
    }
  }, [touchMenuOpen])

  return (
    <div
      ref={navRowRef}
      className={`nav-row rounded-control group relative flex min-w-0 items-center transition-colors ${active ? 'bg-primary-subtle/75 text-primary' : 'text-text-secondary hover:bg-surface-muted hover:text-text-primary'}`}
    >
      {active ? (
        <span
          className="bg-primary absolute top-2 bottom-2 left-0 w-[3px] rounded-r-full"
          aria-hidden="true"
        />
      ) : null}
      <Tooltip
        content={label}
        placement={collapsed ? 'right' : 'top'}
        showDelayMs={1000}
        className="min-w-0 flex-1"
      >
        <Link
          to={destination.path as never}
          aria-current={active ? 'page' : undefined}
          onClick={onNavigate}
          className={`focus-visible:shadow-focus-ring rounded-control text-label flex min-h-10 w-full min-w-0 flex-1 items-center gap-3 px-3 focus-visible:outline-none ${collapsed ? 'justify-center px-0' : ''}`}
        >
          <ShellIcon name={destination.icon} className="size-[17px] shrink-0" />
          {!collapsed ? <span className="min-w-0 flex-1 truncate">{label}</span> : null}
        </Link>
      </Tooltip>
      {collapsed && pinned ? (
        <span
          className="bg-surface text-primary absolute top-1 right-1 z-10 flex size-4 items-center justify-center rounded-full shadow-sm"
          title="Pinned"
          aria-hidden="true"
        >
          <ShellIcon name="pin" className="size-2.5 fill-current" />
        </span>
      ) : null}
      {!collapsed ? (
        <>
          {pinned ? (
            <button
              type="button"
              className="nav-pinned-toggle focus-visible:shadow-focus-ring text-primary hover:text-primary-strong rounded-control mr-1 size-8 shrink-0 items-center justify-center focus-visible:outline-none"
              aria-label={`Unpin ${label}`}
              title="Remove from Pinned"
              onClick={() => onTogglePin(destination.path)}
            >
              <ShellIcon name="pin" className="size-4 fill-current" />
            </button>
          ) : (
            <>
              <button
                type="button"
                className="nav-row-action nav-row-action--desktop focus-visible:shadow-focus-ring text-text-muted hover:text-primary rounded-control mr-1 size-8 shrink-0 items-center justify-center focus-visible:outline-none"
                aria-label={`Pin ${label}`}
                title="Add to Pinned"
                onClick={() => onTogglePin(destination.path)}
              >
                <ShellIcon name="pin" className="size-4" />
              </button>
              <button
                ref={touchMenuTriggerRef}
                type="button"
                className="nav-row-action nav-row-action--touch focus-visible:shadow-focus-ring text-text-secondary hover:bg-surface-muted rounded-control mr-1 size-8 shrink-0 items-center justify-center focus-visible:outline-none"
                aria-label={`More actions for ${label}`}
                aria-haspopup="menu"
                aria-expanded={touchMenuOpen}
                aria-controls={touchMenuOpen ? touchMenuId : undefined}
                onClick={() => setTouchMenuOpen((open) => !open)}
              >
                <ShellIcon name="more" className="size-4" />
              </button>
              {touchMenuOpen ? (
                <div
                  id={touchMenuId}
                  role="menu"
                  aria-label={`Actions for ${label}`}
                  className="bg-surface border-border-subtle shadow-elevation-md rounded-control absolute top-full right-1 z-40 min-w-48 border p-1"
                >
                  <button
                    type="button"
                    role="menuitem"
                    className="focus-visible:shadow-focus-ring rounded-control text-label hover:bg-surface-muted flex min-h-10 w-full items-center gap-2 px-3 text-left focus-visible:outline-none"
                    onClick={() => {
                      onTogglePin(destination.path)
                      setTouchMenuOpen(false)
                    }}
                  >
                    <ShellIcon name="pin" className="size-4" />
                    Add to Pinned
                  </button>
                </div>
              ) : null}
            </>
          )}
        </>
      ) : null}
    </div>
  )
}

function SidebarSearch({
  query,
  onQueryChange,
  inputRef,
  destinations,
  onSelect,
}: {
  query: string
  onQueryChange: (query: string) => void
  inputRef: RefObject<HTMLInputElement | null>
  destinations: ProtectedDestination[]
  onSelect: (destination: ProtectedDestination) => void
}) {
  const navigate = useNavigate()
  const searchId = useId()
  const rootRef = useRef<HTMLDivElement>(null)
  const [focused, setFocused] = useState(false)
  const [activeIndex, setActiveIndex] = useState(0)
  const normalizedQuery = query.trim().toLowerCase()
  const results = useMemo(() => {
    if (!normalizedQuery) return []
    return destinations
      .filter((item) =>
        `${navigationTitle(item)} ${item.title} ${navigationGroupLabel(item.group)} ${navigationCategoryLabel(item) ?? ''} ${item.section} ${item.path}`
          .toLowerCase()
          .includes(normalizedQuery),
      )
      .slice(0, 8)
  }, [destinations, normalizedQuery])
  const listboxId = `${searchId}-results`
  const activeOptionId = results.length ? `${listboxId}-${activeIndex}` : undefined
  const showResults = focused && normalizedQuery.length > 0

  useEffect(() => {
    if (!showResults) return
    const onPointerDown = (event: PointerEvent) => {
      if (!rootRef.current?.contains(event.target as Node)) setFocused(false)
    }
    document.addEventListener('pointerdown', onPointerDown)
    return () => document.removeEventListener('pointerdown', onPointerDown)
  }, [showResults])

  function selectResult(item: ProtectedDestination) {
    onSelect(item)
    onQueryChange('')
    setFocused(false)
    void navigate({ to: item.path as never })
  }

  function handleKeyDown(event: ReactKeyboardEvent<HTMLInputElement>) {
    if (event.key === 'ArrowDown' && results.length > 0) {
      event.preventDefault()
      setActiveIndex((index) => (index + 1) % results.length)
    } else if (event.key === 'ArrowUp' && results.length > 0) {
      event.preventDefault()
      setActiveIndex((index) => (index - 1 + results.length) % results.length)
    } else if (event.key === 'Enter' && results.length > 0) {
      event.preventDefault()
      selectResult(results[activeIndex] ?? results[0]!)
    } else if (event.key === 'Escape') {
      if (showResults) {
        event.stopPropagation()
        setFocused(false)
      }
    }
  }

  return (
    <div ref={rootRef} className="relative">
      <label htmlFor={searchId} className="sr-only">
        Search workspace pages
      </label>
      <div className="border-border-strong bg-surface focus-within:shadow-focus-ring rounded-control flex min-h-10 items-center gap-2 border px-3">
        <ShellIcon name="search" className="text-text-muted size-[18px] shrink-0" />
        <input
          ref={inputRef}
          id={searchId}
          role="combobox"
          aria-label="Search pages"
          aria-autocomplete="list"
          aria-expanded={showResults}
          aria-controls={showResults ? listboxId : undefined}
          aria-activedescendant={showResults ? activeOptionId : undefined}
          className="text-body-sm text-text-primary placeholder:text-text-muted min-w-0 flex-1 bg-transparent py-2 outline-none"
          type="text"
          value={query}
          onChange={(event) => {
            setActiveIndex(0)
            onQueryChange(event.target.value)
          }}
          onFocus={() => setFocused(true)}
          onBlur={(event) => {
            if (!rootRef.current?.contains(event.relatedTarget as Node)) setFocused(false)
          }}
          onKeyDown={handleKeyDown}
          placeholder="Search pages"
          autoComplete="off"
          aria-describedby={query ? undefined : `${searchId}-hint`}
        />
        {query ? (
          <button
            type="button"
            aria-label="Clear search"
            className="focus-visible:shadow-focus-ring text-text-muted hover:text-text-primary flex size-7 shrink-0 items-center justify-center rounded-xs focus-visible:outline-none"
            onClick={() => {
              onQueryChange('')
              inputRef.current?.focus()
            }}
          >
            <ShellIcon name="close" className="size-4" />
          </button>
        ) : (
          <kbd
            id={`${searchId}-hint`}
            className="bg-surface-muted text-text-muted shrink-0 rounded-xs px-1.5 py-0.5 text-[10px]"
          >
            Ctrl/⌘ K
          </kbd>
        )}
      </div>
      {showResults ? (
        <div
          id={listboxId}
          role="listbox"
          aria-label="Matching workspace pages"
          className="bg-surface border-border-subtle shadow-elevation-md rounded-surface absolute top-[calc(100%+0.5rem)] right-0 left-0 z-50 max-h-[min(55dvh,24rem)] overflow-y-auto border p-1"
        >
          {results.length > 0 ? (
            results.map((item, index) => (
              <button
                type="button"
                role="option"
                tabIndex={-1}
                id={`${listboxId}-${index}`}
                aria-selected={index === activeIndex}
                key={item.path}
                className={`focus-visible:shadow-focus-ring rounded-control flex min-h-12 w-full items-center gap-3 px-3 text-left focus-visible:outline-none ${index === activeIndex ? 'bg-primary-subtle text-primary' : 'hover:bg-surface-muted'}`}
                onMouseDown={(event) => event.preventDefault()}
                onMouseEnter={() => setActiveIndex(index)}
                onClick={() => selectResult(item)}
              >
                <ShellIcon name={item.icon} className="size-[18px] shrink-0" />
                <span className="min-w-0 flex-1">
                  <span className="text-label block truncate font-medium">
                    {navigationTitle(item)}
                  </span>
                  <span className="text-caption text-text-muted block truncate">
                    {[navigationGroupLabel(item.group), navigationCategoryLabel(item)]
                      .filter(Boolean)
                      .join(' · ')}
                  </span>
                </span>
                <ShellIcon name="chevron" className="text-text-muted size-4 shrink-0" />
              </button>
            ))
          ) : (
            <p className="text-body-sm text-text-secondary px-3 py-5 text-center" role="status">
              No available pages match “{query}”.
            </p>
          )}
        </div>
      ) : null}
    </div>
  )
}
