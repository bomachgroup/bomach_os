import { useId, useState } from 'react'
import { ChevronDown, Search, ShieldCheck, X } from 'lucide-react'

import { Tooltip } from '@/shared/ui/tooltip'
import { CONTROL_SIZE_CLASSES } from '@/shared/ui/control-sizing'
import { getPermissionAreaPresentation } from '@/shared/permissions/permission-area-presentation'
import {
  getPermissionActionPresentation,
  permissionActionToneClasses,
} from '@/shared/permissions/permission-action-presentation'
import {
  getPermissionAreaId,
  getPermissionGuidance,
  getPermissionResourceLabel,
  permissionAreas,
} from '@/shared/permissions/permission-guidance'

function humanize(value: string) {
  return value.replaceAll('_', ' ').replace(/\b\w/g, (letter) => letter.toUpperCase())
}

function useSearchDisclosure(searchQuery: string) {
  const [state, setState] = useState({ query: '', open: false })
  const open = state.query === searchQuery ? state.open : searchQuery.length > 0
  const toggle = () => setState({ query: searchQuery, open: !open })
  return [open, toggle] as const
}

function normalizeSearchText(value: string) {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, ' ')
    .trim()
}

function matchesSearch(query: string, searchableText: string) {
  return query.split(' ').every((term) => searchableText.includes(term))
}

function ResourcePermissionSet({
  resource,
  actions,
  searchQuery,
}: {
  resource: string
  actions: string[]
  searchQuery: string
}) {
  const [open, toggleOpen] = useSearchDisclosure(searchQuery)
  const panelId = useId()
  const resourceLabel = getPermissionResourceLabel(resource)

  return (
    <li className="border-border-subtle bg-surface rounded-control shadow-elevation-sm min-w-0 overflow-hidden border">
      <h5>
        <button
          type="button"
          aria-label={`${resourceLabel} permission set`}
          aria-expanded={open}
          aria-controls={panelId}
          onClick={toggleOpen}
          className="hover:bg-surface-muted/70 focus-visible:shadow-focus-ring phone:px-3.5 flex min-h-12 w-full min-w-0 items-center gap-2.5 px-3 py-2.5 text-left transition-colors focus-visible:outline-none"
        >
          <span className="bg-primary-subtle text-primary rounded-control flex size-8 shrink-0 items-center justify-center">
            <ShieldCheck className="size-4" aria-hidden="true" />
          </span>
          <span className="text-caption text-text-primary min-w-0 flex-1 font-semibold">
            {resourceLabel}
          </span>
          <span className="bg-surface-muted text-overline text-text-secondary shrink-0 rounded-full px-2 py-1 tabular-nums">
            {actions.length} {actions.length === 1 ? 'action' : 'actions'}
          </span>
          <ChevronDown
            aria-hidden="true"
            className={`text-text-muted size-4 shrink-0 transition-transform motion-reduce:transition-none ${open ? 'rotate-180' : ''}`}
          />
        </button>
      </h5>
      <div id={panelId} hidden={!open} className="border-border-subtle phone:p-3 border-t p-2.5">
        {open ? (
          <ul
            className="phone:grid-cols-2 grid min-w-0 grid-cols-1 gap-1.5"
            aria-label={`${resourceLabel} actions`}
          >
            {actions.map((action) => {
              const label = humanize(action)
              const explanation = getPermissionGuidance(resource, action)
              const presentation = getPermissionActionPresentation(action)
              const ActionIcon = presentation.icon

              return (
                <li key={action} className="min-w-0">
                  <Tooltip
                    showDelayMs={1000}
                    placement="top"
                    content={<span className="block max-w-64">{explanation}</span>}
                  >
                    <span
                      tabIndex={0}
                      aria-label={`${label} permission for ${resourceLabel}`}
                      className="group border-border-subtle bg-surface hover:border-primary/25 hover:bg-primary-subtle/30 focus-visible:shadow-focus-ring rounded-control flex min-h-10 w-full min-w-0 cursor-help items-center gap-2 border px-2 py-1.5 transition-colors focus-visible:outline-none"
                    >
                      <span
                        className={`flex size-6 shrink-0 items-center justify-center rounded-md border ${permissionActionToneClasses[presentation.tone]}`}
                      >
                        <ActionIcon className="size-3.5" aria-hidden="true" />
                      </span>
                      <span className="text-caption text-text-secondary group-hover:text-text-primary min-w-0 leading-tight font-medium break-words">
                        {label}
                      </span>
                    </span>
                  </Tooltip>
                </li>
              )
            })}
          </ul>
        ) : null}
      </div>
    </li>
  )
}

function PermissionAreaGroup({
  area,
  searchQuery,
}: {
  area: {
    id: string
    label: string
    description: string
    resources: [string, string[]][]
  }
  searchQuery: string
}) {
  const [open, toggleOpen] = useSearchDisclosure(searchQuery)
  const panelId = useId()
  const actionsCount = area.resources.reduce((count, [, actions]) => count + actions.length, 0)
  const presentation = getPermissionAreaPresentation(area.id)
  const AreaIcon = presentation.icon

  return (
    <section
      aria-labelledby={`${panelId}-heading`}
      className="border-border-subtle bg-surface rounded-surface shadow-elevation-sm min-w-0 overflow-hidden border"
    >
      <h4 id={`${panelId}-heading`}>
        <button
          type="button"
          aria-label={`${area.label} permission subgroup`}
          aria-expanded={open}
          aria-controls={panelId}
          onClick={toggleOpen}
          className="hover:bg-surface-muted/70 focus-visible:shadow-focus-ring phone:px-4 flex min-h-[4.5rem] w-full min-w-0 items-center gap-3 px-3 py-3 text-left transition-colors focus-visible:outline-none"
        >
          <span
            className={`${presentation.tone} rounded-control flex size-10 shrink-0 items-center justify-center`}
          >
            <AreaIcon className="size-5" aria-hidden="true" />
          </span>
          <span className="min-w-0 flex-1">
            <span className="text-caption text-text-primary block font-semibold">{area.label}</span>
            <span className="text-overline text-text-secondary tablet:block mt-0.5 hidden leading-snug">
              {area.description}
            </span>
          </span>
          <span
            id={`${panelId}-summary`}
            aria-label={`${area.resources.length} ${area.resources.length === 1 ? 'resource' : 'resources'}, ${actionsCount} ${actionsCount === 1 ? 'action' : 'actions'}`}
            className="border-border-subtle bg-surface-muted phone:flex hidden shrink-0 items-center gap-2 rounded-full border px-2.5 py-1.5"
          >
            <span className="flex items-baseline gap-1">
              <span className="text-caption text-text-primary font-semibold tabular-nums">
                {area.resources.length}
              </span>
              <span className="text-overline text-text-secondary">
                {area.resources.length === 1 ? 'resource' : 'resources'}
              </span>
            </span>
            <span className="bg-border-strong/60 h-4 w-px" aria-hidden="true" />
            <span className="flex items-baseline gap-1">
              <span className="text-caption text-text-primary font-semibold tabular-nums">
                {actionsCount}
              </span>
              <span className="text-overline text-text-secondary">
                {actionsCount === 1 ? 'action' : 'actions'}
              </span>
            </span>
          </span>
          <ChevronDown
            aria-hidden="true"
            className={`text-text-muted size-4 shrink-0 transition-transform motion-reduce:transition-none ${open ? 'rotate-180' : ''}`}
          />
        </button>
      </h4>
      <div id={panelId} hidden={!open} className="border-border-subtle phone:p-4 border-t p-3">
        {open ? (
          <ul
            className="wide:grid-cols-3 desktop:grid-cols-2 tablet:grid-cols-2 grid min-w-0 gap-2"
            aria-label={`${area.label} permissions`}
          >
            {area.resources.map(([resource, actions]) => (
              <ResourcePermissionSet
                key={resource}
                resource={resource}
                actions={actions}
                searchQuery={searchQuery}
              />
            ))}
          </ul>
        ) : null}
      </div>
    </section>
  )
}

/** Shared, read-only view of a role's resource/action grants. */
export function PermissionActionGroups({ permissions }: { permissions: Record<string, string[]> }) {
  const [searchQuery, setSearchQuery] = useState('')
  const searchInputId = useId()
  const resources = Object.entries(permissions)
    .filter(([, actions]) => actions.length > 0)
    .sort(([left], [right]) => left.localeCompare(right))

  if (!resources.length) {
    return (
      <p className="text-caption text-text-secondary rounded-control bg-surface-muted px-3 py-3">
        No permissions are assigned to this role.
      </p>
    )
  }

  const grantsCount = resources.reduce((count, [, actions]) => count + actions.length, 0)
  const resourcesByArea = new Map<string, typeof resources>()
  resources.forEach(([resource, actions]) => {
    const areaId = getPermissionAreaId(resource)
    const currentResources = resourcesByArea.get(areaId) ?? []
    currentResources.push([resource, actions])
    resourcesByArea.set(areaId, currentResources)
  })

  const areas = [
    ...permissionAreas
      .filter((area) => resourcesByArea.has(area.id))
      .map((area) => ({ ...area, resources: resourcesByArea.get(area.id) ?? [] })),
    ...(resourcesByArea.has('other')
      ? [
          {
            id: 'other',
            label: 'Other access',
            description: 'Additional permissions provided by the backend.',
            resources: resourcesByArea.get('other') ?? [],
          },
        ]
      : []),
  ]
  const normalizedQuery = normalizeSearchText(searchQuery)
  const filteredAreas = areas
    .map((area) => ({
      ...area,
      resources: area.resources.flatMap(([resource, actions]) => {
        if (!normalizedQuery) return [[resource, actions] as [string, string[]]]

        const resourceText = normalizeSearchText(
          `${getPermissionResourceLabel(resource)} ${area.label} ${area.description}`,
        )
        if (matchesSearch(normalizedQuery, resourceText)) {
          return [[resource, actions] as [string, string[]]]
        }

        const matchingActions = actions.filter((action) => {
          const actionText = normalizeSearchText(
            `${humanize(action)} ${getPermissionGuidance(resource, action)}`,
          )
          return matchesSearch(normalizedQuery, actionText)
        })
        return matchingActions.length ? [[resource, matchingActions] as [string, string[]]] : []
      }),
    }))
    .filter((area) => area.resources.length > 0)
  const resultResourceCount = filteredAreas.reduce(
    (count, area) => count + area.resources.length,
    0,
  )
  const resultActionCount = filteredAreas.reduce(
    (count, area) =>
      count + area.resources.reduce((areaCount, [, actions]) => areaCount + actions.length, 0),
    0,
  )

  return (
    <div className="space-y-5">
      <div className="border-primary/15 from-primary-subtle/70 via-surface to-surface rounded-surface tablet:grid-cols-[minmax(0,1fr)_auto] tablet:items-center tablet:p-4 grid min-w-0 gap-3 border bg-gradient-to-br p-3">
        <div>
          <p className="text-label text-text-primary font-semibold">Access overview</p>
          <p className="text-caption text-text-secondary mt-0.5">
            Permissions assigned to this role, organized by work area.
          </p>
        </div>
        <dl className="phone:min-w-56 grid grid-cols-2 gap-2">
          <div className="bg-surface/80 rounded-control border-border-subtle min-w-0 border px-3 py-2">
            <dt className="text-overline text-text-secondary">Actions</dt>
            <dd className="text-h3 text-text-primary tabular-nums">{grantsCount}</dd>
          </div>
          <div className="bg-surface/80 rounded-control border-border-subtle min-w-0 border px-3 py-2">
            <dt className="text-overline text-text-secondary">Resources</dt>
            <dd className="text-h3 text-text-primary tabular-nums">{resources.length}</dd>
          </div>
        </dl>
      </div>

      <div>
        <label
          htmlFor={searchInputId}
          className="text-control-label text-text-primary mb-1.5 block font-bold"
        >
          Search permissions
        </label>
        <div
          className={`border-border-strong bg-surface focus-within:shadow-focus-ring rounded-control flex min-w-0 items-center gap-2 border ${CONTROL_SIZE_CLASSES}`}
        >
          <Search className="text-text-muted size-4 shrink-0" aria-hidden="true" />
          <input
            id={searchInputId}
            type="text"
            role="searchbox"
            value={searchQuery}
            onChange={(event) => setSearchQuery(event.target.value)}
            placeholder="Search resources, actions, or descriptions"
            className="text-control-value placeholder:text-text-muted text-text-primary min-h-[38px] min-w-0 flex-1 bg-transparent py-[9px] outline-none"
          />
          {searchQuery ? (
            <button
              type="button"
              onClick={() => setSearchQuery('')}
              className="text-text-secondary hover:bg-surface-muted focus-visible:shadow-focus-ring rounded-control flex size-8 shrink-0 items-center justify-center focus-visible:outline-none"
              aria-label="Clear permission search"
            >
              <X className="size-4" aria-hidden="true" />
            </button>
          ) : null}
        </div>
        {normalizedQuery ? (
          <p role="status" className="text-caption text-text-secondary mt-2">
            {resultResourceCount} {resultResourceCount === 1 ? 'resource' : 'resources'} ·{' '}
            {resultActionCount} {resultActionCount === 1 ? 'action' : 'actions'} found
          </p>
        ) : null}
      </div>

      {filteredAreas.length === 0 ? (
        <div className="border-border-subtle bg-surface-muted rounded-surface border px-4 py-8 text-center">
          <span className="bg-surface text-text-muted mx-auto flex size-10 items-center justify-center rounded-full">
            <Search className="size-5" aria-hidden="true" />
          </span>
          <p className="text-body-sm text-text-primary mt-3 font-semibold">
            No matching permissions
          </p>
          <p className="text-caption text-text-secondary mt-1">
            Try a resource name, an action, or a phrase that describes what you need to do.
          </p>
        </div>
      ) : null}

      {filteredAreas.map((area) => (
        <PermissionAreaGroup key={area.id} area={area} searchQuery={normalizedQuery} />
      ))}
    </div>
  )
}
