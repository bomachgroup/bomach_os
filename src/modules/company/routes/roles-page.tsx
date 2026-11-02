import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useSearch } from '@tanstack/react-router'
import {
  ArrowDownAZ,
  ArrowDownZA,
  ArrowLeft,
  ArrowRight,
  Building2,
  Check,
  CheckCheck,
  ChevronLeft,
  ChevronRight,
  Edit2,
  Eye,
  Filter,
  ListChecks,
  Plus,
  Search,
  Shield,
  ShieldCheck,
  Trash2,
} from 'lucide-react'
import { useEffect, useMemo, useRef, useState } from 'react'

import {
  rolesApi,
  rolesQueryKeys,
  type RoleDescriptionDto,
  type RoleDto,
  type RoleWriteInput,
} from '@/modules/company/roles.api'
import { branchesApi } from '@/modules/company/branches.api'
import { validateRolesSearch, type RolesSearch } from '@/modules/company/roles.search'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { useToast } from '@/shared/feedback/use-toast'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip } from '@/shared/ui/status-chip'
import { ApiError } from '@/shared/api/api-error'
import { presentError } from '@/shared/errors/error-presentation'
import {
  getPermissionGuidance,
  getPermissionResourceLabel,
  permissionAreas,
} from '@/shared/permissions/permission-guidance'
import { getPermissionAreaPresentation } from '@/shared/permissions/permission-area-presentation'
import {
  getPermissionActionPresentation,
  permissionActionToneClasses,
} from '@/shared/permissions/permission-action-presentation'
import { CreationFlowActions, CreationFlowStepper } from '@/shared/ui/creation-flow'
import { FormSection } from '@/shared/ui/form-section'
import { Tooltip } from '@/shared/ui/tooltip'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { groupRolePermissions } from '@/shared/permissions/role-permission-groups'
import { RolePermissionSummary } from '@/shared/permissions/role-permission-summary'

const PAGE_SIZE = 10
const INITIAL_PERMISSION_RENDER_BATCH_SIZE = 24
const PERMISSION_RENDER_BATCH_SIZE = 36
const emptyDescription: RoleDescriptionDto = {
  purpose: '',
  responsibilities: '',
  job_description: '',
}

type PermissionSort = 'az' | 'za' | 'assigned'
type FlatPermission = {
  areaId: string
  areaLabel: string
  resource: string
  resourceLabel: string
  action: string
  actionLabel: string
}
type PermissionGroup = {
  id: string
  label: string
  description: string
  resources: [string, string[]][]
}
type PermissionResourceGroup = {
  resource: string
  resourceLabel: string
  entries: FlatPermission[]
}

const permissionSortStorageKey = 'company.roles.permission-sort'

function readPermissionSortPreference(): PermissionSort {
  if (typeof window === 'undefined') return 'az'
  try {
    const saved = window.localStorage.getItem(permissionSortStorageKey)
    return saved === 'za' || saved === 'assigned' ? saved : 'az'
  } catch {
    return 'az'
  }
}

function normalizePermissionSearch(value: string) {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, ' ')
    .trim()
}

function matchesPermissionSearch(query: string, value: string) {
  const searchable = normalizePermissionSearch(value)
  return query.split(' ').every((term) => searchable.includes(term))
}

function humanizePermissionAction(value: string) {
  return value.replaceAll('_', ' ').replace(/\b\w/g, (letter) => letter.toUpperCase())
}

function PermissionActionOption({
  resource,
  resourceLabel,
  action,
  checked,
  onToggle,
}: {
  resource: string
  resourceLabel: string
  action: string
  checked: boolean
  onToggle: () => void
}) {
  const actionLabel = humanizePermissionAction(action)
  const actionPresentation = getPermissionActionPresentation(action)
  const ActionIcon = actionPresentation.icon
  return (
    <Tooltip
      placement="top"
      showDelayMs={250}
      content={<span className="block max-w-64">{getPermissionGuidance(resource, action)}</span>}
    >
      <label
        data-permission-option
        data-selected={checked}
        className={`focus-within:shadow-focus-ring text-overline inline-flex min-h-8 max-w-full cursor-pointer items-center gap-1.5 rounded-full border px-2.5 py-1 font-semibold transition-colors focus-within:outline-none ${checked ? permissionActionToneClasses[actionPresentation.tone] : permissionActionToneClasses.neutral}`}
      >
        <input
          type="checkbox"
          aria-label={`${resourceLabel} ${actionLabel}`}
          className="sr-only"
          checked={checked}
          onChange={onToggle}
        />
        <ActionIcon className="size-3.5 shrink-0" aria-hidden="true" />
        <span className="break-words">{actionLabel}</span>
      </label>
    </Tooltip>
  )
}

export function RoleEditor({
  open,
  role,
  initialStep = 'details',
  onClose,
  permissions,
  branches,
  branchChoicesLoaded = true,
  branchChoicesLoading = false,
  branchChoicesError,
  onRetryBranches = () => {},
  canEditDescription,
  canViewDescription,
  permissionMapLoaded,
  permissionMapLoading,
  permissionMapError,
  onRetryPermissionMap,
  onSave,
  isSaving,
  error,
}: {
  open: boolean
  role: RoleDto | null
  initialStep?: 'details' | 'permissions'
  onClose: () => void
  permissions: Record<string, string[]>
  branches: Array<{ id: number; branch_name: string }>
  branchChoicesLoaded?: boolean
  branchChoicesLoading?: boolean
  branchChoicesError?: unknown
  onRetryBranches?: () => void
  canEditDescription: boolean
  canViewDescription: boolean
  permissionMapLoaded: boolean
  permissionMapLoading: boolean
  permissionMapError?: unknown
  onRetryPermissionMap: () => void
  onSave: (input: RoleWriteInput) => void
  isSaving: boolean
  error?: unknown
}) {
  const initialStepIndex = initialStep === 'permissions' ? (canEditDescription ? 2 : 1) : 0
  const [name, setName] = useState(role?.name ?? '')
  const [branchIds, setBranchIds] = useState<number[]>(role?.branches.map((item) => item.id) ?? [])
  const [selected, setSelected] = useState<Record<string, string[]>>(role?.permissions ?? {})
  const [descriptionDraft, setDescriptionDraft] = useState<RoleDescriptionDto | null>(null)
  const [currentStep, setCurrentStep] = useState(initialStepIndex)
  const [maxSelectableStep, setMaxSelectableStep] = useState(initialStepIndex)
  const [nameError, setNameError] = useState('')
  const [permissionSearch, setPermissionSearch] = useState('')
  const [permissionAreaFilter, setPermissionAreaFilter] = useState('all')
  const [permissionSort, setPermissionSort] = useState<PermissionSort>(readPermissionSortPreference)
  const [selectedOnly, setSelectedOnly] = useState(false)
  const [renderedPermissionGroupCount, setRenderedPermissionGroupCount] = useState(0)
  const renderedPermissionGroupCountRef = useRef(0)
  const descriptionQuery = useQuery({
    queryKey: ['company', 'roles', 'description-draft', role?.id ?? 'new'],
    queryFn: async ({ signal }) => {
      try {
        return await rolesApi.description(role!.id, signal)
      } catch (error) {
        if (error instanceof ApiError && error.status === 404) return emptyDescription
        throw error
      }
    },
    enabled: open && Boolean(role?.id) && canViewDescription,
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const description = descriptionDraft ?? descriptionQuery.data ?? emptyDescription
  const descriptionEditorAvailable = canEditDescription && (!role || descriptionQuery.isSuccess)
  const steps = useMemo(
    () => [
      {
        id: 'details',
        label: 'Role details',
        compactLabel: 'Details',
        title: 'Role details',
        detail: 'Set the role name and the branches it covers.',
      },
      ...(canEditDescription
        ? [
            {
              id: 'purpose',
              label: 'Responsibilities',
              compactLabel: 'Purpose',
              title: 'Responsibilities',
              detail: 'Describe the role so its scope is clear to your team.',
            },
          ]
        : []),
      {
        id: 'permissions',
        label: 'Permissions',
        compactLabel: 'Access',
        title: 'Permissions',
        detail: 'Choose the work areas and actions this role can access.',
      },
      {
        id: 'review',
        label: 'Review',
        compactLabel: 'Review',
        title: 'Review role',
        detail: 'Confirm the role details and access before saving.',
      },
    ],
    [canEditDescription],
  )
  const permissionGroups = useMemo(() => {
    const grouped: PermissionGroup[] = permissionAreas.map((area) => ({
      ...area,
      resources: area.resources
        .filter((resource) => permissions[resource])
        .map((resource) => [resource, permissions[resource] ?? []] as [string, string[]]),
    }))
    const knownResources = new Set<string>(permissionAreas.flatMap((area) => [...area.resources]))
    const otherResources = Object.entries(permissions)
      .filter(([resource]) => !knownResources.has(resource))
      .map(([resource, actions]) => [resource, actions] as [string, string[]])
    if (otherResources.length) {
      grouped.push({
        id: 'other',
        label: 'Other access',
        description: 'Additional permissions provided by the backend.',
        resources: otherResources,
      })
    }
    return grouped.filter((area) => area.resources.length > 0)
  }, [permissions])
  useEffect(() => {
    try {
      window.localStorage.setItem(permissionSortStorageKey, permissionSort)
    } catch {
      // Sorting is a convenience preference; the editor remains usable if storage is unavailable.
    }
  }, [permissionSort])
  const flatPermissionEntries = useMemo(() => {
    const query = normalizePermissionSearch(permissionSearch)
    const entries = permissionGroups.flatMap((area) => {
      if (permissionAreaFilter !== 'all' && area.id !== permissionAreaFilter) return []
      return area.resources.flatMap(([resource, actions]) => {
        const resourceLabel = getPermissionResourceLabel(resource)
        return actions
          .filter((action) => !selectedOnly || selected[resource]?.includes(action))
          .map((action) => ({
            areaId: area.id,
            areaLabel: area.label,
            resource,
            resourceLabel,
            action,
            actionLabel: humanizePermissionAction(action),
          }))
          .filter((entry) => {
            if (!query) return true
            return matchesPermissionSearch(
              query,
              `${entry.areaLabel} ${area.description} ${entry.resourceLabel} ${entry.resource} ${entry.action} ${entry.actionLabel} ${getPermissionGuidance(entry.resource, entry.action)}`,
            )
          })
      })
    })
    return entries.sort((left, right) => {
      const leftAssigned = selected[left.resource]?.includes(left.action) ?? false
      const rightAssigned = selected[right.resource]?.includes(right.action) ?? false
      if (permissionSort === 'assigned' && leftAssigned !== rightAssigned) {
        return leftAssigned ? -1 : 1
      }
      const resourceComparison = left.resourceLabel.localeCompare(right.resourceLabel)
      const actionComparison = left.actionLabel.localeCompare(right.actionLabel)
      const comparison =
        resourceComparison || actionComparison || left.areaLabel.localeCompare(right.areaLabel)
      return permissionSort === 'za' ? -comparison : comparison
    })
  }, [
    permissionAreaFilter,
    permissionGroups,
    permissionSearch,
    permissionSort,
    selected,
    selectedOnly,
  ])
  const permissionResourceGroups = useMemo(() => {
    const grouped = new Map<string, PermissionResourceGroup>()
    for (const entry of flatPermissionEntries) {
      const key = `${entry.areaId}:${entry.resource}`
      const group = grouped.get(key)
      if (group) group.entries.push(entry)
      else {
        grouped.set(key, {
          resource: entry.resource,
          resourceLabel: entry.resourceLabel,
          entries: [entry],
        })
      }
    }
    return [...grouped.values()]
  }, [flatPermissionEntries])
  const isPermissionsStep = steps[currentStep]?.id === 'permissions'
  useEffect(() => {
    if (
      !isPermissionsStep ||
      !permissionMapLoaded ||
      renderedPermissionGroupCountRef.current >= permissionResourceGroups.length
    ) {
      return
    }

    let active = true
    let timeout: number | undefined
    if (renderedPermissionGroupCountRef.current === 0) {
      const initialCount = Math.min(
        INITIAL_PERMISSION_RENDER_BATCH_SIZE,
        permissionResourceGroups.length,
      )
      renderedPermissionGroupCountRef.current = initialCount
      setRenderedPermissionGroupCount(initialCount)
    }
    const renderNextBatch = () => {
      timeout = window.setTimeout(() => {
        if (!active) return
        const visibleCount = Math.min(
          renderedPermissionGroupCountRef.current + PERMISSION_RENDER_BATCH_SIZE,
          permissionResourceGroups.length,
        )
        renderedPermissionGroupCountRef.current = visibleCount
        setRenderedPermissionGroupCount(visibleCount)
        if (visibleCount < permissionResourceGroups.length) renderNextBatch()
      }, 16)
    }
    renderNextBatch()

    return () => {
      active = false
      if (timeout !== undefined) window.clearTimeout(timeout)
    }
  }, [isPermissionsStep, permissionMapLoaded, permissionResourceGroups.length])
  const permissionOptionsReady = permissionMapLoaded
  const selectedPermissionCount = Object.values(selected).reduce(
    (sum, actions) => sum + actions.length,
    0,
  )
  const visiblePermissionCount = flatPermissionEntries.length
  const selectedPermissionGroups = groupRolePermissions(selected)
  const selectedResourceCount = selectedPermissionGroups.reduce(
    (sum, area) => sum + area.resources.length,
    0,
  )
  const isFinalStep = currentStep === steps.length - 1

  const validateRoleName = () => {
    if (name.trim()) {
      setNameError('')
      return true
    }
    setNameError('Enter a role name before continuing.')
    setCurrentStep(0)
    return false
  }

  const moveToStep = (nextStep: number) => {
    if (isSaving) return
    if (nextStep > currentStep && !validateRoleName()) return
    if (nextStep > currentStep && currentStep === 0 && !branchChoicesLoaded) return
    if (
      nextStep > currentStep &&
      steps[currentStep]?.id === 'permissions' &&
      !permissionOptionsReady
    )
      return
    if (steps[currentStep]?.id === 'permissions' && steps[nextStep]?.id !== 'permissions') {
      const retainedCount = Math.min(
        INITIAL_PERMISSION_RENDER_BATCH_SIZE,
        permissionResourceGroups.length,
      )
      renderedPermissionGroupCountRef.current = retainedCount
      setRenderedPermissionGroupCount(retainedCount)
    }
    if (
      steps[nextStep]?.id === 'permissions' &&
      permissionMapLoaded &&
      renderedPermissionGroupCountRef.current === 0
    ) {
      const initialCount = Math.min(
        INITIAL_PERMISSION_RENDER_BATCH_SIZE,
        permissionResourceGroups.length,
      )
      renderedPermissionGroupCountRef.current = initialCount
      setRenderedPermissionGroupCount(initialCount)
    }
    setCurrentStep(nextStep)
    setMaxSelectableStep((highest) => Math.max(highest, nextStep))
  }

  const togglePermission = (resource: string, action: string) => {
    setSelected((current) => {
      const actions = new Set(current[resource] ?? [])
      if (actions.has(action)) actions.delete(action)
      else actions.add(action)
      const next = { ...current }
      if (actions.size) next[resource] = [...actions].sort()
      else delete next[resource]
      return next
    })
  }
  const updateVisiblePermissionEntries = (entries: FlatPermission[], shouldSelect: boolean) => {
    setSelected((current) => {
      const next = { ...current }
      for (const { resource, action } of entries) {
        const nextActions = new Set(next[resource] ?? [])
        if (shouldSelect) nextActions.add(action)
        else nextActions.delete(action)
        if (nextActions.size) next[resource] = [...nextActions].sort()
        else delete next[resource]
      }
      return next
    })
  }
  const submit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    if (!validateRoleName() || !isFinalStep) return
    onSave({
      name: name.trim(),
      branch_ids: branchIds,
      permissions: selected,
      ...(descriptionEditorAvailable ? { description } : {}),
    })
  }
  return (
    <Dialog
      open={open}
      onOpenChange={(nextOpen) => {
        if (!nextOpen && !isSaving) onClose()
      }}
      title={role ? 'Edit role' : 'Create role'}
      description="Build a clear access role in a few guided steps."
      size="xl"
      className="tablet:h-[90dvh] overflow-clip"
      dismissDisabled={isSaving}
      closeOnBackdrop={!isSaving}
      footer={
        <CreationFlowActions
          className={currentStep === 0 ? 'justify-end' : undefined}
          leading={
            currentStep > 0 ? (
              <Button
                variant="ghost"
                leadingIcon={<ArrowLeft className="size-4" aria-hidden="true" />}
                disabled={isSaving}
                onClick={() => moveToStep(Math.max(0, currentStep - 1))}
              >
                Back
              </Button>
            ) : undefined
          }
        >
          <Button variant="outline" onClick={onClose} disabled={isSaving}>
            Cancel
          </Button>
          {isFinalStep ? (
            <Button
              type="submit"
              form="role-editor-form"
              isLoading={isSaving}
              disabled={
                !permissionOptionsReady ||
                !branchChoicesLoaded ||
                (canEditDescription && role !== null && descriptionQuery.isPending)
              }
            >
              {role ? 'Save changes' : 'Create role'}
            </Button>
          ) : (
            <Button
              type="button"
              leadingIcon={<ArrowRight className="size-4" aria-hidden="true" />}
              disabled={
                isSaving ||
                (currentStep === 0 && !branchChoicesLoaded) ||
                (steps[currentStep]?.id === 'permissions' && !permissionOptionsReady) ||
                (isPermissionsStep &&
                  renderedPermissionGroupCount < permissionResourceGroups.length) ||
                (role !== null &&
                  steps[currentStep]?.id === 'purpose' &&
                  descriptionQuery.isPending)
              }
              onClick={(event) => {
                event.preventDefault()
                event.stopPropagation()
                moveToStep(currentStep + 1)
              }}
            >
              {steps[currentStep]?.id === 'permissions' ? 'Review role' : 'Continue'}
            </Button>
          )}
        </CreationFlowActions>
      }
    >
      <form id="role-editor-form" onSubmit={submit} className="space-y-4">
        <CreationFlowStepper
          ariaLabel="Role setup"
          steps={steps}
          currentStep={currentStep}
          maxSelectableStep={maxSelectableStep}
          onStepSelect={moveToStep}
          variant="horizontal"
          eyebrow={role ? 'Update role' : 'New role'}
          hideDetailBelow480
        />
        {error ? (
          <Alert tone="danger" role="alert" title={presentError(error, 'form-submit').title}>
            {presentError(error, 'form-submit').message} Your changes are still here.
          </Alert>
        ) : null}
        {steps[currentStep]?.id === 'details' ? (
          <div className="space-y-4">
            <FormSection className="tablet:grid-cols-2 grid gap-4">
              <FormControl
                id="role-name"
                label="Role name"
                required
                className="tablet:col-span-2"
                error={nameError}
              >
                <TextInput
                  value={name}
                  onChange={(event) => {
                    setName(event.currentTarget.value)
                    if (event.currentTarget.value.trim()) setNameError('')
                  }}
                  maxLength={120}
                  autoComplete="off"
                  placeholder="e.g. Finance Manager"
                />
              </FormControl>
              <fieldset className="tablet:col-span-2">
                <legend className="text-control-label text-text-secondary mb-2 font-bold">
                  Branch scope
                </legend>
                <p className="text-caption text-text-secondary mb-3">
                  Select branches to limit this role. Leave them all clear for company-wide access.
                </p>
                {branchChoicesLoading && !branchChoicesLoaded ? (
                  <div role="status" className="text-caption text-text-secondary">
                    Loading branch choices…
                  </div>
                ) : null}
                {!branchChoicesLoaded && branchChoicesError ? (
                  <SectionErrorState
                    title="Branch choices could not load"
                    description="Retry before continuing so you can choose the intended role scope."
                    onRetry={onRetryBranches}
                  />
                ) : null}
                {branchChoicesLoaded ? (
                  <div className="grid gap-2 sm:grid-cols-2">
                    {branches.map((branch) => (
                      <label
                        key={branch.id}
                        className="bg-surface border-border-subtle rounded-control text-body-sm hover:border-primary/35 flex min-h-11 cursor-pointer items-center gap-2.5 border px-3 transition-colors"
                      >
                        <input
                          type="checkbox"
                          className="accent-primary size-4"
                          checked={branchIds.includes(branch.id)}
                          onChange={() =>
                            setBranchIds((items) =>
                              items.includes(branch.id)
                                ? items.filter((id) => id !== branch.id)
                                : [...items, branch.id],
                            )
                          }
                        />
                        <span className="text-text-primary min-w-0 truncate font-medium">
                          {branch.branch_name}
                        </span>
                      </label>
                    ))}
                    {!branches.length ? (
                      <p className="text-caption text-text-secondary">
                        No branch choices are available; this role will apply company-wide.
                      </p>
                    ) : null}
                  </div>
                ) : null}
                <p className="text-overline text-text-secondary mt-3">
                  {branchIds.length
                    ? `${branchIds.length} ${branchIds.length === 1 ? 'branch' : 'branches'} selected`
                    : 'Company-wide access'}
                </p>
              </fieldset>
            </FormSection>
          </div>
        ) : null}
        {steps[currentStep]?.id === 'purpose' ? (
          <div className="space-y-4">
            {descriptionQuery.isError ? (
              <SectionErrorState
                title="Role description did not load"
                description="Retry to edit these details, or continue and keep the saved description unchanged."
                onRetry={() => void descriptionQuery.refetch()}
              />
            ) : null}
            {canEditDescription && role && descriptionQuery.isPending ? (
              <div role="status" aria-label="Loading role description">
                <Skeleton variant="card" />
              </div>
            ) : null}
            {descriptionEditorAvailable ? (
              <FormSection className="space-y-4">
                <div className="flex items-start gap-3">
                  <span className="bg-info-subtle text-info-foreground rounded-control flex size-10 shrink-0 items-center justify-center">
                    <ShieldCheck className="size-5" aria-hidden="true" />
                  </span>
                  <div className="min-w-0">
                    <h3 className="text-label font-semibold">Make this role easy to understand</h3>
                    <p className="text-caption text-text-secondary mt-0.5">
                      These details help employees understand the role beyond its access settings.
                    </p>
                  </div>
                </div>
                <FormControl id="role-purpose" label="Purpose">
                  <TextArea
                    rows={2}
                    maxLength={2000}
                    value={description.purpose}
                    onChange={(event) =>
                      setDescriptionDraft({ ...description, purpose: event.currentTarget.value })
                    }
                    placeholder="Why this role exists"
                  />
                </FormControl>
                <FormControl id="role-responsibilities" label="Responsibilities">
                  <TextArea
                    rows={3}
                    maxLength={5000}
                    value={description.responsibilities}
                    onChange={(event) =>
                      setDescriptionDraft({
                        ...description,
                        responsibilities: event.currentTarget.value,
                      })
                    }
                    placeholder="What this role is accountable for"
                  />
                </FormControl>
                <FormControl id="role-description" label="Job description">
                  <TextArea
                    rows={3}
                    maxLength={5000}
                    value={description.job_description}
                    onChange={(event) =>
                      setDescriptionDraft({
                        ...description,
                        job_description: event.currentTarget.value,
                      })
                    }
                    placeholder="Role expectations and qualifications"
                  />
                </FormControl>
              </FormSection>
            ) : null}
          </div>
        ) : null}
        {steps[currentStep]?.id === 'permissions' ? (
          <div className="space-y-4">
            <FormSection className="border-primary/15 from-primary-subtle/60 via-surface to-surface grid gap-3 bg-gradient-to-br sm:grid-cols-[minmax(0,1fr)_auto] sm:items-center">
              <div className="flex min-w-0 items-start gap-3">
                <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
                  <ShieldCheck className="size-5" aria-hidden="true" />
                </span>
                <div className="min-w-0">
                  <p className="text-label font-semibold">Access overview</p>
                  <p className="text-caption text-text-secondary mt-0.5">
                    Review permissions by resource. Filter by work area or sort resource and
                    permission names.
                  </p>
                </div>
              </div>
              <StatusChip label={`${selectedPermissionCount} selected`} tone="info" dense />
            </FormSection>
            <FormSection className="space-y-3">
              <div className="tablet:grid-cols-[minmax(0,1fr)_minmax(12rem,0.8fr)_minmax(10rem,0.65fr)] grid gap-3">
                <label className="min-w-0">
                  <span className="text-control-label text-text-secondary mb-1.5 block font-bold">
                    Search permissions
                  </span>
                  <span className="border-border-subtle bg-surface focus-within:shadow-focus-ring rounded-control flex min-h-11 items-center gap-2 border px-3">
                    <Search className="text-text-muted size-4 shrink-0" aria-hidden="true" />
                    <input
                      type="search"
                      value={permissionSearch}
                      onChange={(event) => setPermissionSearch(event.currentTarget.value)}
                      placeholder="Resource or action"
                      className="text-control-value text-text-primary placeholder:text-text-muted min-w-0 flex-1 bg-transparent outline-none"
                      aria-label="Search permissions"
                    />
                  </span>
                </label>
                <DropdownSelect
                  id="role-permission-area-filter"
                  label="Work area"
                  value={permissionAreaFilter}
                  onChange={setPermissionAreaFilter}
                  options={[
                    {
                      value: 'all',
                      label: 'All work areas',
                      description: 'Show every permission in one list',
                      icon: <Filter className="size-4" aria-hidden="true" />,
                    },
                    ...permissionGroups.map((area) => {
                      const presentation = getPermissionAreaPresentation(area.id)
                      const AreaIcon = presentation.icon
                      return {
                        value: area.id,
                        label: area.label,
                        description: area.description,
                        icon: <AreaIcon className="size-4" aria-hidden="true" />,
                        iconClassName: presentation.tone,
                      }
                    }),
                  ]}
                />
                <DropdownSelect
                  id="role-permission-sort"
                  label="Order"
                  value={permissionSort}
                  onChange={(value) => setPermissionSort(value as PermissionSort)}
                  options={[
                    {
                      value: 'az',
                      label: 'Name A–Z',
                      description: 'Sort resource names and their permissions A–Z',
                      icon: <ArrowDownAZ className="size-4" aria-hidden="true" />,
                    },
                    {
                      value: 'za',
                      label: 'Name Z–A',
                      description: 'Sort resource names and their permissions Z–A',
                      icon: <ArrowDownZA className="size-4" aria-hidden="true" />,
                    },
                    {
                      value: 'assigned',
                      label: 'Assigned first',
                      description: 'Move selected permissions to the top',
                      icon: <CheckCheck className="size-4" aria-hidden="true" />,
                    },
                  ]}
                />
              </div>
              <div className="border-border-subtle flex flex-wrap items-center justify-between gap-2 border-t pt-3">
                <label className="text-caption text-text-secondary flex min-h-10 cursor-pointer items-center gap-2">
                  <input
                    type="checkbox"
                    className="accent-primary size-4"
                    checked={selectedOnly}
                    onChange={(event) => setSelectedOnly(event.currentTarget.checked)}
                  />
                  Show selected permissions only
                </label>
                <div className="flex flex-wrap items-center justify-end gap-2">
                  <Button
                    size="sm"
                    variant="outline"
                    disabled={!visiblePermissionCount}
                    onClick={() => updateVisiblePermissionEntries(flatPermissionEntries, true)}
                  >
                    Select visible
                  </Button>
                  <Button
                    size="sm"
                    variant="ghost"
                    disabled={!visiblePermissionCount || !selectedPermissionCount}
                    onClick={() => updateVisiblePermissionEntries(flatPermissionEntries, false)}
                  >
                    Clear visible
                  </Button>
                </div>
              </div>
              <p className="text-overline text-text-secondary" role="status" aria-live="polite">
                {visiblePermissionCount} visible{' '}
                {visiblePermissionCount === 1 ? 'action' : 'actions'} · {selectedPermissionCount}{' '}
                selected
              </p>
            </FormSection>
            {!permissionMapLoaded && permissionMapLoading ? (
              <div role="status" aria-label="Loading permission choices" className="space-y-3">
                <Skeleton variant="card" />
                <Skeleton variant="card" />
              </div>
            ) : null}
            {!permissionMapLoaded && permissionMapError ? (
              <SectionErrorState
                title="Permission choices could not load"
                description="The role is not ready to save. Retry loading the supported permissions."
                onRetry={onRetryPermissionMap}
              />
            ) : null}
            {!permissionGroups.length ? (
              permissionMapLoaded ? (
                <EmptyState
                  title="No permissions are available"
                  description="The permission catalogue currently has no actions to assign."
                />
              ) : null
            ) : null}
            {permissionGroups.length && !flatPermissionEntries.length ? (
              <EmptyState
                title={selectedOnly ? 'No selected permissions match' : 'No matching permissions'}
                description={
                  selectedOnly
                    ? 'Clear the selected-only filter or choose more permissions.'
                    : 'Try another search term or work area.'
                }
                action={
                  <Button
                    variant="outline"
                    onClick={() => {
                      setPermissionSearch('')
                      setPermissionAreaFilter('all')
                      setSelectedOnly(false)
                    }}
                  >
                    Clear filters
                  </Button>
                }
              />
            ) : null}
            {flatPermissionEntries.length ? (
              <section
                aria-label={
                  permissionAreaFilter === 'all'
                    ? 'All permissions'
                    : `${permissionGroups.find((area) => area.id === permissionAreaFilter)?.label ?? 'Filtered'} permissions`
                }
                className="border-border-subtle bg-surface rounded-surface min-w-0 overflow-hidden border shadow-sm"
              >
                <div className="bg-surface-muted/45 border-border-subtle flex flex-wrap items-center justify-between gap-2 border-b px-4 py-3">
                  <div className="flex min-w-0 items-center gap-2.5">
                    <span className="bg-primary-subtle text-primary rounded-control flex size-9 shrink-0 items-center justify-center">
                      <ListChecks className="size-4" aria-hidden="true" />
                    </span>
                    <div className="min-w-0">
                      <h3 className="text-body-sm text-text-primary font-semibold">
                        {permissionAreaFilter === 'all'
                          ? 'All permissions'
                          : permissionGroups.find((area) => area.id === permissionAreaFilter)
                              ?.label}
                      </h3>
                      <p className="text-overline text-text-secondary mt-0.5">
                        {permissionSort === 'za'
                          ? 'Resources and permissions, Z–A'
                          : permissionSort === 'assigned'
                            ? 'Selected permissions first'
                            : 'Resources and permissions, A–Z'}
                      </p>
                    </div>
                  </div>
                  <StatusChip label={`${flatPermissionEntries.length} visible`} tone="info" dense />
                </div>
                <ul
                  data-rendered-group-count={Math.min(
                    renderedPermissionGroupCount,
                    permissionResourceGroups.length,
                  )}
                  className="grid grid-cols-1 items-start gap-2 p-2 sm:grid-cols-2 sm:gap-2.5 sm:p-3"
                >
                  {permissionResourceGroups.slice(0, renderedPermissionGroupCount).map((group) => (
                    <li key={`${permissionAreaFilter}:${group.resource}`} className="min-w-0">
                      <section
                        data-permission-resource={group.resource}
                        aria-label={`${group.resourceLabel} permissions`}
                        className="bg-surface-muted/35 border-border-subtle rounded-control min-w-0 border p-3"
                      >
                        <h4 className="text-caption text-text-primary font-semibold break-words">
                          {group.resourceLabel}
                        </h4>
                        <div
                          role="group"
                          aria-label={`${group.resourceLabel} permissions`}
                          className="mt-2 flex min-w-0 flex-wrap gap-1.5"
                        >
                          {group.entries.map((entry) => (
                            <PermissionActionOption
                              key={`${entry.areaId}-${entry.action}`}
                              resource={entry.resource}
                              resourceLabel={entry.resourceLabel}
                              action={entry.action}
                              checked={selected[entry.resource]?.includes(entry.action) ?? false}
                              onToggle={() => togglePermission(entry.resource, entry.action)}
                            />
                          ))}
                        </div>
                      </section>
                    </li>
                  ))}
                </ul>
                {permissionMapLoaded &&
                renderedPermissionGroupCount < permissionResourceGroups.length ? (
                  <div
                    role="status"
                    aria-label="Loading permission catalogue"
                    className="space-y-2 px-3 pb-3"
                  >
                    <p className="text-caption text-text-secondary">Loading permission actions…</p>
                    <Skeleton variant="row" />
                    <Skeleton variant="row" />
                  </div>
                ) : null}
              </section>
            ) : null}
          </div>
        ) : null}
        {steps[currentStep]?.id === 'review' ? (
          <section role="region" aria-label="Role review" className="space-y-4">
            <FormSection className="border-primary/15 from-primary-subtle/55 via-surface to-surface bg-gradient-to-br">
              <div className="flex min-w-0 items-start gap-3">
                <span className="bg-primary-subtle text-primary rounded-control flex size-11 shrink-0 items-center justify-center">
                  <Shield className="size-5" aria-hidden="true" />
                </span>
                <div className="min-w-0 flex-1">
                  <p className="text-overline text-primary font-semibold">Ready to save</p>
                  <h3 className="text-h3 mt-1 font-semibold break-words">{name.trim()}</h3>
                  <p className="text-caption text-text-secondary mt-1">
                    Review the scope and access below. You can return to any step to make changes.
                  </p>
                </div>
              </div>
              <div className="mt-4 grid gap-3 sm:grid-cols-2">
                <div className="bg-surface/80 border-border-subtle rounded-control min-w-0 border p-3">
                  <div className="flex items-center gap-2">
                    <Building2 className="text-text-secondary size-4 shrink-0" aria-hidden="true" />
                    <p className="text-overline text-text-secondary font-semibold">Branch scope</p>
                  </div>
                  <p className="text-body-sm text-text-primary mt-2 font-semibold">
                    {branchIds.length
                      ? `${branchIds.length} ${branchIds.length === 1 ? 'branch' : 'branches'}`
                      : 'Company-wide access'}
                  </p>
                  {branchIds.length ? (
                    <p className="text-caption text-text-secondary mt-1 break-words">
                      {branches
                        .filter((branch) => branchIds.includes(branch.id))
                        .map((branch) => branch.branch_name)
                        .join(' · ')}
                    </p>
                  ) : null}
                  <Button
                    size="sm"
                    variant="ghost"
                    className="mt-2 -ml-2"
                    onClick={() => moveToStep(0)}
                  >
                    Edit details
                  </Button>
                </div>
                <div className="bg-surface/80 border-border-subtle rounded-control min-w-0 border p-3">
                  <div className="flex items-center gap-2">
                    <Check className="text-text-secondary size-4 shrink-0" aria-hidden="true" />
                    <p className="text-overline text-text-secondary font-semibold">
                      Access granted
                    </p>
                  </div>
                  <p className="text-body-sm text-text-primary mt-2 font-semibold">
                    {selectedPermissionCount} {selectedPermissionCount === 1 ? 'action' : 'actions'}{' '}
                    across {selectedPermissionGroups.length}{' '}
                    {selectedPermissionGroups.length === 1 ? 'work area' : 'work areas'}
                  </p>
                  <p className="text-caption text-text-secondary mt-1">
                    {selectedResourceCount} {selectedResourceCount === 1 ? 'resource' : 'resources'}{' '}
                    included
                  </p>
                  <Button
                    size="sm"
                    variant="ghost"
                    className="mt-2 -ml-2"
                    onClick={() => moveToStep(steps.findIndex((step) => step.id === 'permissions'))}
                  >
                    Edit permissions
                  </Button>
                </div>
              </div>
            </FormSection>

            {descriptionEditorAvailable ? (
              <FormSection className="space-y-3">
                <div className="flex items-center justify-between gap-3">
                  <div>
                    <p className="text-overline text-primary font-semibold">Role definition</p>
                    <h3 className="text-label mt-0.5 font-semibold">Responsibilities</h3>
                  </div>
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => moveToStep(steps.findIndex((step) => step.id === 'purpose'))}
                  >
                    Edit
                  </Button>
                </div>
                {[
                  ['Purpose', description.purpose],
                  ['Responsibilities', description.responsibilities],
                  ['Job description', description.job_description],
                ].some(([, value]) => String(value).trim()) ? (
                  <dl className="grid gap-3 sm:grid-cols-2">
                    {[
                      ['Purpose', description.purpose],
                      ['Responsibilities', description.responsibilities],
                      ['Job description', description.job_description],
                    ].map(([label, value]) =>
                      String(value).trim() ? (
                        <div
                          key={String(label)}
                          className="bg-surface-muted rounded-control min-w-0 p-3"
                        >
                          <dt className="text-overline text-text-secondary font-semibold">
                            {label}
                          </dt>
                          <dd className="text-body-sm text-text-primary mt-1 break-words whitespace-pre-wrap">
                            {value}
                          </dd>
                        </div>
                      ) : null,
                    )}
                  </dl>
                ) : (
                  <p className="text-caption text-text-secondary">
                    No purpose or responsibilities added.
                  </p>
                )}
              </FormSection>
            ) : null}

            <FormSection className="space-y-3">
              <div className="flex items-center justify-between gap-3">
                <div>
                  <p className="text-overline text-primary font-semibold">Permission summary</p>
                  <h3 className="text-label mt-0.5 font-semibold">Selected access by work area</h3>
                </div>
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => moveToStep(steps.findIndex((step) => step.id === 'permissions'))}
                >
                  Edit
                </Button>
              </div>
              <RolePermissionSummary groups={selectedPermissionGroups} />
            </FormSection>
          </section>
        ) : null}
      </form>
    </Dialog>
  )
}

export function RolesPage() {
  const search = useSearch({ from: '/_protected/company/roles' }) as RolesSearch
  const navigate = useNavigate({ from: '/company/roles' })
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canCreate = hasPermission(permissions, 'roles', 'create')
  const canUpdate = hasPermission(permissions, 'roles', 'update')
  const canDelete = hasPermission(permissions, 'roles', 'delete')
  const [editorOpen, setEditorOpen] = useState(false)
  const [editing, setEditing] = useState<RoleDto | null>(null)
  const [deleting, setDeleting] = useState<RoleDto | null>(null)
  const listParams = {
    limit: PAGE_SIZE,
    offset: (search.page - 1) * PAGE_SIZE,
    search: search.search,
  }
  const listQuery = useQuery({
    queryKey: rolesQueryKeys.list(userId, employeeId, listParams),
    queryFn: ({ signal }) => rolesApi.list(listParams, signal),
    enabled: Boolean(session),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    placeholderData: keepPreviousData,
  })
  const mapQuery = useQuery({
    queryKey: rolesQueryKeys.permissions,
    queryFn: ({ signal }) => rolesApi.permissionMap(signal),
    enabled: Boolean(session && (canCreate || canUpdate)),
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const branchQuery = useQuery({
    queryKey: ['company', 'roles', 'branch-choices', userId, employeeId],
    queryFn: ({ signal }) =>
      branchesApi.list(
        {
          limit: 100,
          offset: 0,
          search: '',
          operationalStatus: 'all',
          branchRole: 'all',
          recordState: 'active',
        },
        signal,
      ),
    enabled: Boolean(session && (canCreate || canUpdate)),
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const saveMutation = useMutation({
    mutationFn: ({ role, input }: { role: RoleDto | null; input: RoleWriteInput }) =>
      role ? rolesApi.update(role.id, input) : rolesApi.create(input),
    onSuccess: async (_result, variables) => {
      await queryClient.invalidateQueries({ queryKey: rolesQueryKeys.all })
      showToast({
        tone: 'success',
        title: variables.role ? 'Role updated' : 'Role created',
        description: `${variables.input.name} is ready.`,
      })
      setEditorOpen(false)
      setEditing(null)
    },
  })
  const deleteMutation = useMutation({
    mutationFn: (role: RoleDto) => rolesApi.remove(role.id),
    onSuccess: async (_result, role) => {
      await queryClient.invalidateQueries({ queryKey: rolesQueryKeys.all })
      showToast({
        tone: 'success',
        title: 'Role deleted',
        description: `${role.name} was removed.`,
      })
      setDeleting(null)
    },
  })
  const pageCount = Math.max(1, Math.ceil((listQuery.data?.count ?? 0) / PAGE_SIZE))
  useEffect(() => {
    if (!listQuery.data || listQuery.isPlaceholderData || search.page <= pageCount) return
    void navigate({
      search: (previous: Record<string, unknown>) => ({
        ...validateRolesSearch(previous),
        page: pageCount,
      }),
      replace: true,
    })
  }, [listQuery.data, listQuery.isPlaceholderData, navigate, pageCount, search.page])
  const openEditor = (role: RoleDto | null) => {
    saveMutation.reset()
    setEditing(role)
    setEditorOpen(true)
  }
  const updateSearch = (patch: Partial<RolesSearch>) =>
    void navigate({
      search: (previous: Record<string, unknown>) => ({
        ...validateRolesSearch(previous),
        ...patch,
        ...(patch.search !== undefined || patch.page !== undefined
          ? { page: patch.page ?? 1 }
          : {}),
      }),
      replace: true,
    })
  return (
    <PageLayout
      title="Roles & Permissions"
      actionsInline
      actions={
        canCreate ? (
          <Button
            aria-label="New role"
            leadingIcon={<Plus className="size-4" aria-hidden="true" />}
            className="max-[479px]:text-caption max-[479px]:min-h-9 max-[479px]:px-3"
            onClick={() => openEditor(null)}
          >
            <span className="max-[479px]:hidden">New role</span>
            <span className="hidden max-[479px]:inline max-[361px]:hidden">New</span>
          </Button>
        ) : null
      }
    >
      <div className="space-y-5">
        <Card className="tablet:p-5 space-y-4 p-4">
          <div className="flex min-w-0 items-center gap-3">
            <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
              <ShieldCheck className="size-5" aria-hidden="true" />
            </span>
            <div className="min-w-0">
              <h2 className="text-h2 font-semibold">Access roles</h2>
              <p className="text-caption text-text-secondary">
                Manage branch scope and permissions. Select a role to inspect its responsibilities
                and role standards.
              </p>
            </div>
          </div>
          <label
            className="text-control-label text-text-secondary block font-bold"
            htmlFor="role-search"
          >
            Search roles
          </label>
          <div className="relative">
            <Search
              className="text-text-muted absolute top-1/2 left-3 size-4 -translate-y-1/2"
              aria-hidden="true"
            />
            <TextInput
              id="role-search"
              value={search.search}
              onChange={(event) => updateSearch({ search: event.currentTarget.value })}
              placeholder="Search by role name"
              className="pl-10"
            />
          </div>
        </Card>
        {listQuery.isPending && !listQuery.data ? (
          <div className="space-y-3" role="status" aria-label="Loading roles">
            {[1, 2, 3].map((key) => (
              <Skeleton key={key} variant="card" />
            ))}
          </div>
        ) : null}
        {listQuery.isError && !listQuery.data ? (
          <ErrorState
            title="Roles could not load"
            description="Try again to reload the role directory."
            error={listQuery.error}
            action={
              <Button variant="outline" onClick={() => void listQuery.refetch()}>
                Try again
              </Button>
            }
          />
        ) : null}
        {listQuery.isError && listQuery.data ? (
          <SectionErrorState
            title="Role refresh failed"
            description="Showing the last loaded results."
            onRetry={() => void listQuery.refetch()}
          />
        ) : null}
        {listQuery.data?.items.length ? (
          <section aria-label="Role results" className="space-y-3">
            {listQuery.data.items.map((role) => (
              <Card
                key={role.id}
                className="tablet:p-5 group hover:shadow-elevation-md space-y-4 p-4 transition-shadow"
              >
                <div className="tablet:flex-row tablet:items-center tablet:justify-between flex min-w-0 flex-col gap-4">
                  {hasPermission(permissions, 'roles', 'view') ? (
                    <Link
                      to="/company/roles/$roleId"
                      params={{ roleId: String(role.id) }}
                      aria-label={`View ${role.name}`}
                      className="rounded-control focus-visible:shadow-focus-ring flex min-w-0 flex-1 items-center gap-3 focus-visible:outline-none"
                    >
                      <span className="from-primary-subtle to-info-subtle text-primary rounded-surface ring-primary/10 flex size-12 shrink-0 items-center justify-center bg-gradient-to-br ring-1">
                        <ShieldCheck className="size-5" strokeWidth={2.2} aria-hidden="true" />
                      </span>
                      <span className="min-w-0">
                        <span className="text-label text-text-primary group-hover:text-primary tablet:line-clamp-1 line-clamp-2 block font-semibold break-words transition-colors">
                          {role.name}
                        </span>
                        <span className="text-caption text-text-secondary mt-1 block break-words">
                          {role.branches.length
                            ? role.branches.map((branch) => branch.branch_name).join(' · ')
                            : 'Company-wide access'}
                        </span>
                      </span>
                    </Link>
                  ) : (
                    <div className="flex min-w-0 flex-1 items-center gap-3">
                      <span className="from-primary-subtle to-info-subtle text-primary rounded-surface ring-primary/10 flex size-12 shrink-0 items-center justify-center bg-gradient-to-br ring-1">
                        <ShieldCheck className="size-5" strokeWidth={2.2} aria-hidden="true" />
                      </span>
                      <span className="min-w-0">
                        <span className="text-label text-text-primary tablet:line-clamp-1 line-clamp-2 block font-semibold break-words">
                          {role.name}
                        </span>
                        <span className="text-caption text-text-secondary mt-1 block break-words">
                          {role.branches.length
                            ? role.branches.map((branch) => branch.branch_name).join(' · ')
                            : 'Company-wide access'}
                        </span>
                      </span>
                    </div>
                  )}
                  <div className="tablet:justify-end flex min-w-0 flex-wrap items-center justify-between gap-3">
                    <StatusChip
                      label={`${Object.values(role.permissions).reduce((sum, actions) => sum + actions.length, 0)} permissions`}
                      tone="info"
                      dense
                    />
                    <div className="ml-auto flex flex-wrap items-center justify-end gap-2 max-[479px]:grid max-[479px]:w-full max-[479px]:grid-cols-3 max-[479px]:gap-1.5">
                      {hasPermission(permissions, 'roles', 'view') ? (
                        <Button
                          variant="outline"
                          size="sm"
                          className="max-[479px]:w-full max-[479px]:gap-1 max-[479px]:px-2"
                          leadingIcon={<Eye className="size-4" aria-hidden="true" />}
                          aria-label={`View ${role.name}`}
                          onClick={() =>
                            void navigate({
                              to: '/company/roles/$roleId',
                              params: { roleId: String(role.id) },
                            })
                          }
                        >
                          View
                        </Button>
                      ) : null}
                      {canUpdate ? (
                        <Button
                          variant="outline"
                          size="sm"
                          className="max-[479px]:w-full max-[479px]:gap-1 max-[479px]:px-2"
                          leadingIcon={<Edit2 className="size-4" aria-hidden="true" />}
                          aria-label={`Edit ${role.name}`}
                          onClick={() => openEditor(role)}
                        >
                          Edit
                        </Button>
                      ) : null}
                      {canDelete ? (
                        <Button
                          variant="danger"
                          size="sm"
                          className="max-[479px]:w-full max-[479px]:gap-1 max-[479px]:px-2"
                          leadingIcon={<Trash2 className="size-4" aria-hidden="true" />}
                          aria-label={`Delete ${role.name}`}
                          onClick={() => {
                            deleteMutation.reset()
                            setDeleting(role)
                          }}
                        >
                          Delete
                        </Button>
                      ) : null}
                    </div>
                  </div>
                </div>
              </Card>
            ))}
            <div className="border-border-subtle flex flex-col gap-3 border-t pt-4 sm:flex-row sm:items-center sm:justify-between">
              <p className="text-caption text-text-secondary">
                Page {search.page} of {pageCount} · {listQuery.data.count} roles
              </p>
              <div className="flex gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  disabled={search.page <= 1}
                  leadingIcon={<ChevronLeft className="size-4" aria-hidden="true" />}
                  onClick={() => updateSearch({ page: search.page - 1 })}
                >
                  Previous
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  disabled={search.page >= pageCount}
                  onClick={() => updateSearch({ page: search.page + 1 })}
                >
                  Next
                  <ChevronRight className="size-4" aria-hidden="true" />
                </Button>
              </div>
            </div>
          </section>
        ) : null}
        {!listQuery.isPending && !listQuery.isError && listQuery.data?.items.length === 0 ? (
          <Card>
            <EmptyState
              title={search.search ? 'No roles match this search' : 'No roles yet'}
              description={
                search.search
                  ? 'Try a shorter name or clear the search.'
                  : 'Create a role to define a reusable permission set.'
              }
              action={
                search.search ? (
                  <Button variant="outline" onClick={() => updateSearch({ search: '' })}>
                    Clear search
                  </Button>
                ) : canCreate ? (
                  <Button
                    leadingIcon={<Plus className="size-4" />}
                    onClick={() => openEditor(null)}
                  >
                    Create first role
                  </Button>
                ) : undefined
              }
            />
          </Card>
        ) : null}
      </div>
      {editorOpen ? (
        <RoleEditor
          key={editing?.id ?? 'new'}
          open={editorOpen}
          role={editing}
          onClose={() => {
            if (!saveMutation.isPending) {
              setEditorOpen(false)
              setEditing(null)
            }
          }}
          permissions={mapQuery.data?.permissions_map ?? {}}
          branches={branchQuery.data?.items ?? []}
          branchChoicesLoaded={branchQuery.data !== undefined}
          branchChoicesLoading={branchQuery.isPending}
          branchChoicesError={branchQuery.error}
          onRetryBranches={() => void branchQuery.refetch()}
          canEditDescription={
            hasPermission(permissions, 'role_descriptions', editing ? 'update' : 'create') &&
            (!editing || hasPermission(permissions, 'role_descriptions', 'view'))
          }
          canViewDescription={hasPermission(permissions, 'role_descriptions', 'view')}
          permissionMapLoaded={mapQuery.data !== undefined}
          permissionMapLoading={mapQuery.isPending}
          permissionMapError={mapQuery.error}
          onRetryPermissionMap={() => void mapQuery.refetch()}
          onSave={(input) => saveMutation.mutate({ role: editing, input })}
          isSaving={saveMutation.isPending}
          error={saveMutation.error}
        />
      ) : null}
      <Dialog
        open={Boolean(deleting)}
        onOpenChange={(open) => {
          if (!open && !deleteMutation.isPending) setDeleting(null)
        }}
        title="Delete role"
        description="This permanently removes the role and its role-linked standards. Employees assigned to it may need another role."
        size="sm"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button
              variant="outline"
              onClick={() => setDeleting(null)}
              disabled={deleteMutation.isPending}
            >
              Keep role
            </Button>
            <Button
              variant="danger"
              onClick={() => deleting && deleteMutation.mutate(deleting)}
              isLoading={deleteMutation.isPending}
            >
              Delete role
            </Button>
          </>
        }
      >
        {deleteMutation.error ? (
          <Alert tone="danger" role="alert" title="Role could not be deleted">
            The role may still be assigned or referenced. Resolve that first and retry.
          </Alert>
        ) : (
          <p className="text-body-sm text-text-secondary">
            Delete <strong className="text-text-primary">{deleting?.name}</strong>?
          </p>
        )}
      </Dialog>
    </PageLayout>
  )
}
