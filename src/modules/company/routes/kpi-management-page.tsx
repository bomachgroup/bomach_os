import {
  keepPreviousData,
  useMutation,
  useQuery,
  useQueryClient,
  type UseQueryResult,
} from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  Building2,
  ChartNoAxesCombined,
  ChevronLeft,
  ChevronRight,
  Pencil,
  Plus,
  Search,
  Trash2,
} from 'lucide-react'
import { useCallback, useEffect, useState, type FormEvent } from 'react'

import {
  kpiManagementApi,
  kpiManagementQueryKeys,
  type KpiMetricDto,
  type KpiRoleDto,
  type RoleKpiDto,
  type RoleKpiWriteInput,
} from '@/modules/company/kpi-management.api'
import { isApiError } from '@/shared/api/api-error'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { useToast } from '@/shared/feedback/use-toast'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip } from '@/shared/ui/status-chip'

import type { KpiManagementSearch } from '../kpi-management.search'

const PAGE_SIZE = 50

type EditorDraft = {
  roleId: string
  metricId: string
  trackingMode: string
  period: string
  targetValue: string
  weight: string
  sequence: string
  isActive: boolean
}

const trackingOptions = ['manual', 'system', 'automatic', 'semi_automatic']
const periodOptions = ['daily', 'weekly', 'monthly', 'quarterly', 'semi_annual', 'annual', 'custom']
const metricUnitOptions = [
  { value: 'percentage', label: 'Percentage' },
  { value: 'count', label: 'Count' },
  { value: 'currency', label: 'Currency' },
  { value: 'rating', label: 'Rating' },
]

function presentKpiSaveError(error: unknown): string {
  if (isApiError(error) && error.status === 409 && /already assigned/i.test(error.message)) {
    return 'This metric is already assigned to this role. Choose another metric or edit the existing assignment.'
  }
  return presentError(error, 'form-submit').message
}

const labelize = (value: string) =>
  value.replaceAll('_', ' ').replace(/\b\w/g, (character) => character.toLocaleUpperCase())

function numberText(value: string | number | null | undefined, fractionDigits = 1): string {
  if (value == null || value === '') return 'Not set'
  const parsed = Number(value)
  if (!Number.isFinite(parsed)) return String(value)
  return new Intl.NumberFormat(undefined, { maximumFractionDigits: fractionDigits }).format(parsed)
}

function targetLabel(kpi: RoleKpiDto): string {
  if (kpi.target_value == null) return 'Not set'
  const value = numberText(kpi.target_value)
  const unit = kpi.metric.unit.trim()
  if (['%', 'percent', 'percentage'].includes(unit.toLocaleLowerCase())) return `${value}%`
  return unit ? `${value} ${unit}` : value
}

function draftFor(record: RoleKpiDto | null, presetRoleId?: number): EditorDraft {
  return {
    roleId: String(record?.role_id ?? presetRoleId ?? ''),
    metricId: record ? String(record.metric_id) : '',
    trackingMode: record?.tracking_mode ?? 'manual',
    period: record?.period === 'yearly' ? 'annual' : (record?.period ?? 'monthly'),
    targetValue: record?.target_value == null ? '' : String(record.target_value),
    weight: record?.weight == null ? '' : String(record.weight),
    sequence: record ? String(record.sequence) : '',
    isActive: record?.is_active ?? true,
  }
}

function SearchControl({ value, onCommit }: { value: string; onCommit: (value: string) => void }) {
  const [searchState, setSearchState] = useState(() => ({ source: value, draft: value }))
  if (searchState.source !== value) setSearchState({ source: value, draft: value })
  const draft = searchState.draft

  useEffect(() => {
    const normalized = draft.trim()
    if (normalized === value) return
    const timer = window.setTimeout(() => onCommit(normalized), 250)
    return () => window.clearTimeout(timer)
  }, [draft, onCommit, value])

  return (
    <FormControl id="kpi-management-search" label="Search KPIs">
      <div className="relative">
        <Search
          aria-hidden="true"
          className="text-text-muted absolute top-1/2 left-3.5 size-4 -translate-y-1/2"
        />
        <TextInput
          id="kpi-management-search"
          type="search"
          maxLength={200}
          value={draft}
          onChange={(event) => {
            const nextDraft = event.currentTarget.value
            setSearchState((previous) => ({ ...previous, draft: nextDraft }))
          }}
          placeholder="Search by metric name or description"
          className="pl-10"
        />
      </div>
    </FormControl>
  )
}

function MetricCard({
  kpi,
  roleName,
  canUpdate,
  canDelete,
  onEdit,
  onDelete,
}: {
  kpi: RoleKpiDto
  roleName: string
  canUpdate: boolean
  canDelete: boolean
  onEdit: () => void
  onDelete: () => void
}) {
  return (
    <article className="rounded-control shadow-elevation-sm border-border-subtle bg-surface tablet:p-5 flex min-w-0 flex-col gap-4 border p-4">
      <div className="flex min-w-0 items-start gap-3">
        <span
          aria-hidden="true"
          className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center"
        >
          <ChartNoAxesCombined className="size-5" />
        </span>
        <div className="min-w-0 flex-1">
          <h2 className="text-h3 text-text-primary line-clamp-2 font-semibold">
            {kpi.metric.name}
          </h2>
          {kpi.metric.description ? (
            <p className="text-body-sm text-text-secondary mt-1 line-clamp-2">
              {kpi.metric.description}
            </p>
          ) : null}
        </div>
        <StatusChip
          label={kpi.is_active ? 'Active' : 'Inactive'}
          tone={kpi.is_active ? 'success' : 'neutral'}
          className="shrink-0"
        />
      </div>

      <div className="text-body-sm text-text-secondary flex min-w-0 items-center gap-2">
        <Building2 aria-hidden="true" className="size-4 shrink-0" />
        <span className="truncate">{roleName}</span>
        <span aria-hidden="true">·</span>
        <span className="shrink-0">Role KPI</span>
      </div>

      <dl className="border-border-subtle grid min-w-0 grid-cols-2 border-y">
        <div className="border-border-subtle min-w-0 border-r border-b py-3 pr-3">
          <dt className="text-caption text-text-secondary">Target</dt>
          <dd className="text-label text-text-primary mt-1 leading-snug font-semibold break-words">
            {targetLabel(kpi)}
          </dd>
        </div>
        <div className="border-border-subtle min-w-0 border-b py-3 pl-3">
          <dt className="text-caption text-text-secondary">Review period</dt>
          <dd className="text-label text-text-primary mt-1 leading-snug font-semibold break-words">
            {labelize(kpi.period === 'yearly' ? 'annual' : kpi.period)}
          </dd>
        </div>
        <div className="border-border-subtle min-w-0 border-r py-3 pr-3">
          <dt className="text-caption text-text-secondary">Tracking</dt>
          <dd className="text-label text-text-primary mt-1 leading-snug font-semibold break-words">
            {labelize(kpi.tracking_mode)}
          </dd>
        </div>
        <div className="min-w-0 py-3 pl-3">
          <dt className="text-caption text-text-secondary">Weight</dt>
          <dd className="text-label text-text-primary mt-1 leading-snug font-semibold break-words">
            {kpi.weight == null ? 'Not set' : numberText(kpi.weight)}
          </dd>
        </div>
      </dl>

      {kpi.tracking_mode === 'automatic' || kpi.tracking_mode === 'semi_automatic' ? (
        <p className="text-caption text-text-muted">
          Tracking mode is saved as configuration; automatic calculations are not configured.
        </p>
      ) : null}

      {canUpdate || canDelete ? (
        <div className="border-border-subtle flex flex-wrap items-center justify-end gap-2 border-t pt-3">
          {canUpdate ? (
            <Button
              variant="outline"
              size="sm"
              leadingIcon={<Pencil className="size-4" />}
              onClick={onEdit}
            >
              Edit
            </Button>
          ) : null}
          {canDelete ? (
            <Button
              variant="ghost"
              size="sm"
              leadingIcon={<Trash2 className="size-4" />}
              onClick={onDelete}
              className="text-danger hover:text-danger"
            >
              Remove
            </Button>
          ) : null}
        </div>
      ) : null}
    </article>
  )
}

function KpiEditorDialog({
  open,
  sessionScope,
  permissions,
  record,
  recordRoleName,
  editorKey,
  saving,
  onClose,
  onSave,
}: {
  open: boolean
  sessionScope: { userId: number; employeeId: string }
  permissions: Record<string, string[]>
  record: RoleKpiDto | null
  recordRoleName: string
  editorKey: number
  saving: boolean
  onClose: () => void
  onSave: (roleId: number, recordId: number | null, input: RoleKpiWriteInput) => Promise<void>
}) {
  return (
    <Dialog
      open={open}
      onOpenChange={(nextOpen) => !nextOpen && onClose()}
      title={record ? 'Edit KPI' : 'Add KPI'}
      description={
        record
          ? 'Update this role’s KPI target, tracking method, and review period.'
          : 'Define a reusable performance measure for a role.'
      }
      size="lg"
      closeOnBackdrop
      footer={
        open ? (
          <>
            <Button variant="outline" onClick={onClose} disabled={saving}>
              Cancel
            </Button>
            <Button type="submit" form="role-kpi-editor-form" isLoading={saving} disabled={saving}>
              {record ? 'Save changes' : 'Add KPI'}
            </Button>
          </>
        ) : null
      }
    >
      {open ? (
        <KpiEditorForm
          key={editorKey}
          sessionScope={sessionScope}
          permissions={permissions}
          record={record}
          recordRoleName={recordRoleName}
          onSave={onSave}
        />
      ) : null}
    </Dialog>
  )
}

function KpiEditorForm({
  sessionScope,
  permissions,
  record,
  recordRoleName,
  onSave,
}: {
  sessionScope: { userId: number; employeeId: string }
  permissions: Record<string, string[]>
  record: RoleKpiDto | null
  recordRoleName: string
  onSave: (roleId: number, recordId: number | null, input: RoleKpiWriteInput) => Promise<void>
}) {
  const { showToast } = useToast()
  const queryClient = useQueryClient()
  const [draft, setDraft] = useState(() => draftFor(record))
  const [formError, setFormError] = useState('')
  const [metricDialogOpen, setMetricDialogOpen] = useState(false)
  const canListMetrics = hasPermission(permissions, 'kpis', 'list')
  const canCreateMetrics = canListMetrics && hasPermission(permissions, 'kpis', 'create')
  const canListRoles = hasPermission(permissions, 'roles', 'list')
  const rolesQuery = useQuery({
    queryKey: kpiManagementQueryKeys.roles(sessionScope.userId, sessionScope.employeeId),
    queryFn: ({ signal }) => kpiManagementApi.roles(signal),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    enabled: !record && canListRoles,
  })
  const metricsQuery = useQuery({
    queryKey: kpiManagementQueryKeys.metrics(sessionScope.userId, sessionScope.employeeId),
    queryFn: ({ signal }) => kpiManagementApi.metrics(signal),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    enabled: canListMetrics,
  })
  const roleId = Number(draft.roleId)
  const assignmentsQuery = useQuery({
    queryKey: kpiManagementQueryKeys.assignments(
      sessionScope.userId,
      sessionScope.employeeId,
      roleId,
    ),
    queryFn: ({ signal }) => kpiManagementApi.roleAssignments(roleId, signal),
    staleTime: 0,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    enabled: Number.isInteger(roleId) && roleId > 0,
  })
  const metricMutation = useMutation({ mutationFn: kpiManagementApi.createMetric })
  const metrics = [...(metricsQuery.data ?? [])]
  if (record && !metrics.some((metric) => metric.id === record.metric_id)) {
    metrics.unshift(record.metric)
  }
  const assignedIds = new Set(
    (assignmentsQuery.data ?? []).map((assignment) => assignment.metric_id),
  )
  const metricOptions = metrics
    .filter((metric) => !assignedIds.has(metric.id) || metric.id === record?.metric_id)
    .map((metric) => ({
      value: String(metric.id),
      label: metric.name,
      description: [metric.unit, metric.description].filter(Boolean).join(' · '),
    }))
  const roleOptions = (rolesQuery.data ?? []).map((role) => ({
    value: String(role.id),
    label: role.name,
  }))

  async function createMetric(input: { name: string; unit: string; description: string }) {
    const created = await metricMutation.mutateAsync(input)
    const key = kpiManagementQueryKeys.metrics(sessionScope.userId, sessionScope.employeeId)
    queryClient.setQueryData<KpiMetricDto[]>(key, (previous) => [...(previous ?? []), created])
    setDraft((previous) => ({ ...previous, metricId: String(created.id) }))
    setMetricDialogOpen(false)
    showToast({ tone: 'success', title: 'Shared metric created', description: created.name })
  }

  async function submit() {
    setFormError('')
    if (!Number.isInteger(roleId) || roleId < 1) {
      setFormError('Choose a role to continue.')
      return
    }
    const metricId = Number(draft.metricId)
    if (!Number.isInteger(metricId) || metricId < 1) {
      setFormError('Choose a metric to continue.')
      return
    }
    if (!record && !canListRoles) {
      setFormError('Role access is required to create a KPI assignment.')
      return
    }
    if (canListMetrics && metricsQuery.isError) {
      setFormError('Load the KPI metric catalog before saving.')
      return
    }
    if (canListMetrics && metricsQuery.isPending) {
      setFormError('Wait for the KPI metric catalog to finish loading before saving.')
      return
    }
    if (assignmentsQuery.isPending || assignmentsQuery.isError) {
      setFormError('Confirm this role’s existing metrics before saving.')
      return
    }
    const target = draft.targetValue.trim() ? Number(draft.targetValue) : null
    if (target !== null && (!Number.isFinite(target) || target < 0)) {
      setFormError('Target value must be a number greater than or equal to zero.')
      return
    }
    const weight = draft.weight.trim() ? Number(draft.weight) : null
    if (weight !== null && (!Number.isFinite(weight) || weight < 0 || weight > 100)) {
      setFormError('Weight must be a number between 0 and 100.')
      return
    }
    const sequenceText = draft.sequence.trim()
    const sequence = sequenceText ? Number(sequenceText) : undefined
    if (
      sequence !== undefined &&
      (!Number.isInteger(sequence) || sequence < 1 || sequence > 2_147_483_647)
    ) {
      setFormError('Display order must be a whole number from 1 to 2,147,483,647.')
      return
    }
    const input: RoleKpiWriteInput = {
      metric_id: metricId,
      tracking_mode: draft.trackingMode,
      target_value: target,
      weight,
      period: draft.period,
      ...(sequence === undefined ? {} : { sequence }),
      is_active: draft.isActive,
    }
    try {
      await onSave(roleId, record?.id ?? null, input)
    } catch (cause) {
      setFormError(presentKpiSaveError(cause))
    }
  }

  return (
    <KpiEditorBody
      record={record}
      recordRoleName={recordRoleName}
      draft={draft}
      setDraft={setDraft}
      formError={formError}
      canListMetrics={canListMetrics}
      canCreateMetrics={canCreateMetrics}
      canListRoles={canListRoles}
      rolesQuery={rolesQuery}
      metricsQuery={metricsQuery}
      assignmentsQuery={assignmentsQuery}
      roleOptions={roleOptions}
      metricOptions={metricOptions}
      metrics={metrics}
      createMetric={createMetric}
      metricDialogOpen={metricDialogOpen}
      setMetricDialogOpen={setMetricDialogOpen}
      metricSaving={metricMutation.isPending}
      onSubmit={submit}
    />
  )
}

function KpiEditorBody({
  record,
  recordRoleName,
  draft,
  setDraft,
  formError,
  canListMetrics,
  canCreateMetrics,
  canListRoles,
  rolesQuery,
  metricsQuery,
  assignmentsQuery,
  roleOptions,
  metricOptions,
  metrics,
  createMetric,
  metricDialogOpen,
  setMetricDialogOpen,
  metricSaving,
  onSubmit,
}: {
  record: RoleKpiDto | null
  recordRoleName: string
  draft: EditorDraft
  setDraft: React.Dispatch<React.SetStateAction<EditorDraft>>
  formError: string
  canListMetrics: boolean
  canCreateMetrics: boolean
  canListRoles: boolean
  rolesQuery: UseQueryResult<KpiRoleDto[], Error>
  metricsQuery: UseQueryResult<KpiMetricDto[], Error>
  assignmentsQuery: UseQueryResult<RoleKpiDto[], Error>
  roleOptions: Array<{ value: string; label: string }>
  metricOptions: Array<{ value: string; label: string; description: string }>
  metrics: KpiMetricDto[]
  createMetric: (input: { name: string; unit: string; description: string }) => Promise<void>
  metricDialogOpen: boolean
  setMetricDialogOpen: (open: boolean) => void
  metricSaving: boolean
  onSubmit: () => Promise<void>
}) {
  const selectedMetric =
    metrics.find((metric) => String(metric.id) === draft.metricId) ?? record?.metric
  const noAvailableMetrics = metricOptions.length === 0 && !record

  return (
    <>
      <form
        id="role-kpi-editor-form"
        noValidate
        onSubmit={(event) => {
          event.preventDefault()
          void onSubmit()
        }}
        className="space-y-5"
      >
        {formError ? (
          <Alert tone="danger" role="alert">
            {formError}
          </Alert>
        ) : null}

        {!record ? (
          <FormSection className="space-y-4">
            <div>
              <h3 className="text-label font-semibold">Role assignment</h3>
              <p className="text-caption text-text-secondary mt-1">
                Each metric can be assigned once to a role.
              </p>
            </div>
            {!canListRoles ? (
              <Alert tone="warning" role="status">
                Role list access is required to create a role KPI. Ask an administrator to grant
                roles list permission.
              </Alert>
            ) : rolesQuery.isError ? (
              <SectionErrorState
                error={rolesQuery.error}
                title="Roles could not be loaded"
                onRetry={() => void rolesQuery.refetch()}
              />
            ) : rolesQuery.isPending ? (
              <Skeleton className="h-12 w-full" />
            ) : roleOptions.length === 0 ? (
              <Alert tone="info" role="status">
                No roles are available for a KPI assignment.
              </Alert>
            ) : (
              <FormControl id="role-kpi-role" label="Role" required>
                <DropdownSelect
                  id="role-kpi-role"
                  value={draft.roleId}
                  options={roleOptions}
                  onChange={(roleId) =>
                    setDraft((previous) => ({ ...previous, roleId, metricId: '' }))
                  }
                  placeholder="Select a role"
                  searchable
                  disabled={!roleOptions.length}
                />
              </FormControl>
            )}
          </FormSection>
        ) : (
          <FormSection className="flex items-center gap-3">
            <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
              <Building2 className="size-5" aria-hidden="true" />
            </span>
            <div className="min-w-0">
              <p className="text-caption text-text-secondary">Role</p>
              <p className="text-label text-text-primary truncate font-semibold">
                {recordRoleName}
              </p>
            </div>
          </FormSection>
        )}

        <FormSection className="space-y-4">
          <div className="flex flex-wrap items-start justify-between gap-2">
            <div className="min-w-0">
              <h3 className="text-label font-semibold">Metric</h3>
              <p className="text-caption text-text-secondary mt-1">
                Choose an existing measure or add one to the shared catalog.
              </p>
            </div>
            {canCreateMetrics ? (
              <Button
                variant="outline"
                size="sm"
                leadingIcon={<Plus className="size-4" />}
                onClick={() => setMetricDialogOpen(true)}
              >
                Create metric
              </Button>
            ) : null}
          </div>

          {!canListMetrics && !record ? (
            <Alert tone="warning" role="status">
              KPI catalog list access is required to add an assignment.
            </Alert>
          ) : metricsQuery.isError && canListMetrics ? (
            <SectionErrorState
              error={metricsQuery.error}
              title="KPI metrics could not be loaded"
              onRetry={() => void metricsQuery.refetch()}
            />
          ) : metricsQuery.isPending && canListMetrics ? (
            <Skeleton className="h-12 w-full" />
          ) : record && !canListMetrics ? (
            <div className="border-border-subtle bg-surface rounded-control border px-3.5 py-3">
              <p className="text-label font-semibold">{record.metric.name}</p>
              <p className="text-caption text-text-secondary mt-0.5">
                {record.metric.unit} · This assignment can be edited without changing its metric.
              </p>
            </div>
          ) : (
            <FormControl id="role-kpi-metric" label="Shared metric" required>
              <DropdownSelect
                id="role-kpi-metric"
                value={draft.metricId}
                options={metricOptions}
                onChange={(metricId) => setDraft((previous) => ({ ...previous, metricId }))}
                placeholder={draft.roleId ? 'Select a metric' : 'Select a role first'}
                searchable
                disabled={!draft.roleId || assignmentsQuery.isPending || assignmentsQuery.isError}
                emptyMessage="All metrics are already assigned to this role."
                aria-describedby="role-kpi-metric-help"
              />
            </FormControl>
          )}
          <p id="role-kpi-metric-help" className="text-caption text-text-muted">
            {assignmentsQuery.isError
              ? 'Retry the role assignment check before choosing a metric.'
              : assignmentsQuery.isPending && draft.roleId
                ? 'Checking the selected role’s existing metrics…'
                : noAvailableMetrics
                  ? canCreateMetrics
                    ? 'There are no available metrics for this role. Create a metric or remove another role assignment first.'
                    : 'There are no available metrics for this role. Ask an administrator to add a shared metric.'
                  : selectedMetric
                    ? `${selectedMetric.unit}${selectedMetric.description ? ` · ${selectedMetric.description}` : ''}`
                    : 'Assigned metrics are filtered out to prevent duplicate role assignments.'}
          </p>
        </FormSection>

        {(record || draft.metricId) && selectedMetric ? (
          <FormSection className="space-y-4">
            <div>
              <h3 className="text-label font-semibold">Target and review</h3>
              <p className="text-caption text-text-secondary mt-1">
                Define how this measure is tracked and reviewed.
              </p>
            </div>
            <div className="tablet:grid-cols-2 grid gap-4">
              <FormControl id="role-kpi-tracking" label="Tracking mode" required>
                <DropdownSelect
                  id="role-kpi-tracking"
                  value={draft.trackingMode}
                  options={trackingOptions.map((option) => ({
                    value: option,
                    label: labelize(option),
                  }))}
                  onChange={(trackingMode) =>
                    setDraft((previous) => ({ ...previous, trackingMode }))
                  }
                />
              </FormControl>
              <FormControl id="role-kpi-period" label="Review period" required>
                <DropdownSelect
                  id="role-kpi-period"
                  value={draft.period}
                  options={periodOptions.map((option) => ({
                    value: option,
                    label: labelize(option),
                  }))}
                  onChange={(period) => setDraft((previous) => ({ ...previous, period }))}
                />
              </FormControl>
              <FormControl
                id="role-kpi-target"
                label={`Target value${selectedMetric.unit ? ` (${selectedMetric.unit})` : ''}`}
                description="Leave blank if this metric has no fixed target."
              >
                <TextInput
                  id="role-kpi-target"
                  type="number"
                  min="0"
                  step="any"
                  inputMode="decimal"
                  value={draft.targetValue}
                  onChange={(event) => {
                    const targetValue = event.currentTarget.value
                    setDraft((previous) => ({ ...previous, targetValue }))
                  }}
                  placeholder="e.g. 95"
                />
              </FormControl>
              <FormControl
                id="role-kpi-weight"
                label="Weight"
                description="Optional weighting from 0 to 100."
              >
                <TextInput
                  id="role-kpi-weight"
                  type="number"
                  min="0"
                  max="100"
                  step="any"
                  inputMode="decimal"
                  value={draft.weight}
                  onChange={(event) => {
                    const weight = event.currentTarget.value
                    setDraft((previous) => ({ ...previous, weight }))
                  }}
                  placeholder="e.g. 20"
                />
              </FormControl>
            </div>
            {draft.trackingMode === 'automatic' || draft.trackingMode === 'semi_automatic' ? (
              <Alert tone="info" role="status">
                This mode is stored as configuration; automatic calculations are not configured.
              </Alert>
            ) : null}
          </FormSection>
        ) : null}

        {(record || draft.metricId) && selectedMetric ? (
          <details className="border-border-subtle rounded-control border px-4 py-3">
            <summary className="text-label cursor-pointer font-semibold">
              Assignment settings
            </summary>
            <p className="text-caption text-text-secondary mt-1 mb-4">
              Display order and whether dashboards should include this KPI.
            </p>
            <div className="tablet:grid-cols-2 grid items-end gap-4">
              <FormControl id="role-kpi-sequence" label="Display order">
                <TextInput
                  id="role-kpi-sequence"
                  type="number"
                  min="1"
                  max="2147483647"
                  step="1"
                  inputMode="numeric"
                  value={draft.sequence}
                  onChange={(event) => {
                    const sequence = event.currentTarget.value
                    setDraft((previous) => ({ ...previous, sequence }))
                  }}
                  placeholder="Assigned automatically"
                />
              </FormControl>
              <label className="border-border-subtle bg-surface rounded-control flex min-h-11 items-center justify-between gap-3 border px-3.5 py-2">
                <span className="min-w-0">
                  <span className="text-label block font-semibold">Active for this role</span>
                  <span className="text-caption text-text-secondary block">
                    Inactive KPIs are hidden from dashboards.
                  </span>
                </span>
                <input
                  type="checkbox"
                  checked={draft.isActive}
                  onChange={(event) => {
                    const isActive = event.currentTarget.checked
                    setDraft((previous) => ({ ...previous, isActive }))
                  }}
                  className="accent-primary size-5 shrink-0"
                />
              </label>
            </div>
          </details>
        ) : null}
      </form>

      <MetricEditorDialog
        open={metricDialogOpen}
        onClose={() => setMetricDialogOpen(false)}
        onCreate={createMetric}
        saving={metricSaving}
      />
    </>
  )
}

function MetricEditorDialog({
  open,
  onClose,
  onCreate,
  saving,
}: {
  open: boolean
  onClose: () => void
  onCreate: (input: { name: string; unit: string; description: string }) => Promise<void>
  saving: boolean
}) {
  const [name, setName] = useState('')
  const [unit, setUnit] = useState('percentage')
  const [description, setDescription] = useState('')
  const [error, setError] = useState('')

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setError('')
    const nameValue = name.trim()
    const unitValue = unit.trim()
    const descriptionValue = description.trim()
    if (!nameValue) {
      setError('Enter a metric name.')
      return
    }
    if (nameValue.length > 200) {
      setError('Metric names must be 200 characters or fewer.')
      return
    }
    if (!unitValue) {
      setError('Enter a unit.')
      return
    }
    if (unitValue.length > 20) {
      setError('Units must be 20 characters or fewer.')
      return
    }
    if (descriptionValue.length > 500) {
      setError('Descriptions must be 500 characters or fewer.')
      return
    }
    try {
      await onCreate({ name: nameValue, unit: unitValue, description: descriptionValue })
      setName('')
      setUnit('percentage')
      setDescription('')
    } catch (cause) {
      setError(presentError(cause, 'form-submit').message)
    }
  }

  return (
    <Dialog
      open={open}
      onOpenChange={(nextOpen) => !nextOpen && onClose()}
      title="Create shared metric"
      description="Add a reusable measure to the KPI catalog."
      size="md"
      fitContent
      compactOnMobile
      footer={
        <>
          <Button variant="outline" onClick={onClose} disabled={saving}>
            Cancel
          </Button>
          <Button type="submit" form="shared-kpi-metric-form" isLoading={saving}>
            Create metric
          </Button>
        </>
      }
    >
      <form
        id="shared-kpi-metric-form"
        noValidate
        onSubmit={(event) => void submit(event)}
        className="space-y-4"
      >
        {error ? (
          <Alert tone="danger" role="alert">
            {error}
          </Alert>
        ) : null}
        <FormSection className="space-y-4">
          <FormControl id="shared-kpi-metric-name" label="Metric name" required>
            <TextInput
              id="shared-kpi-metric-name"
              value={name}
              maxLength={200}
              onChange={(event) => setName(event.currentTarget.value)}
              placeholder="e.g. Client follow-ups completed"
            />
          </FormControl>
          <FormControl id="shared-kpi-metric-unit" label="Unit" required>
            <DropdownSelect
              id="shared-kpi-metric-unit"
              value={unit}
              options={metricUnitOptions}
              onChange={setUnit}
            />
          </FormControl>
          <FormControl id="shared-kpi-metric-description" label="Description">
            <TextArea
              id="shared-kpi-metric-description"
              value={description}
              maxLength={500}
              onChange={(event) => setDescription(event.currentTarget.value)}
              placeholder="What does this metric measure?"
              rows={3}
            />
          </FormControl>
        </FormSection>
      </form>
    </Dialog>
  )
}

export function KpiManagementPage() {
  const search = useSearch({ from: '/_protected/company/kpi-management' }) as KpiManagementSearch
  const navigate = useNavigate({ from: '/company/kpi-management' })
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? 'unavailable'
  const sessionScope = { userId, employeeId }
  const permissions = session?.permissions ?? {}
  const canListRoles = hasPermission(permissions, 'roles', 'list')
  const canCreate =
    hasPermission(permissions, 'role_kpis', 'create') &&
    hasPermission(permissions, 'roles', 'list') &&
    hasPermission(permissions, 'kpis', 'list')
  const canUpdate = hasPermission(permissions, 'role_kpis', 'update')
  const canDelete = hasPermission(permissions, 'role_kpis', 'delete')
  const [editorOpen, setEditorOpen] = useState(false)
  const [editorRecord, setEditorRecord] = useState<RoleKpiDto | null>(null)
  const [editorKey, setEditorKey] = useState(0)
  const [deleteTarget, setDeleteTarget] = useState<RoleKpiDto | null>(null)
  const listParams = {
    limit: PAGE_SIZE,
    offset: (search.page - 1) * PAGE_SIZE,
    search: search.search,
  }
  const listQuery = useQuery({
    queryKey: kpiManagementQueryKeys.list(userId, employeeId, listParams),
    queryFn: ({ signal }) => kpiManagementApi.list(listParams, signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    placeholderData: keepPreviousData,
    enabled: Boolean(session),
  })
  const rolesQuery = useQuery({
    queryKey: kpiManagementQueryKeys.roles(userId, employeeId),
    queryFn: ({ signal }) => kpiManagementApi.roles(signal),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    enabled: Boolean(session && canListRoles),
  })
  const saveMutation = useMutation({
    mutationFn: ({
      roleId,
      recordId,
      input,
    }: {
      roleId: number
      recordId: number | null
      input: RoleKpiWriteInput
    }) =>
      recordId === null
        ? kpiManagementApi.create(roleId, input)
        : kpiManagementApi.update(roleId, recordId, input),
    onSuccess: (_result, variables) => {
      void queryClient.invalidateQueries({
        queryKey: kpiManagementQueryKeys.lists(userId, employeeId),
      })
      void queryClient.invalidateQueries({
        queryKey: kpiManagementQueryKeys.assignments(userId, employeeId, variables.roleId),
      })
    },
  })
  const deleteMutation = useMutation({
    mutationFn: (record: RoleKpiDto) => kpiManagementApi.remove(record.role_id, record.id),
    onSuccess: (_result, record) => {
      void queryClient.invalidateQueries({
        queryKey: kpiManagementQueryKeys.lists(userId, employeeId),
      })
      void queryClient.invalidateQueries({
        queryKey: kpiManagementQueryKeys.assignments(userId, employeeId, record.role_id),
      })
    },
  })
  const roleNames = new Map((rolesQuery.data ?? []).map((role) => [role.id, role.name]))
  const resultCount = listQuery.data?.count ?? 0
  const pageCount = Math.max(1, Math.ceil(resultCount / PAGE_SIZE))
  const currentPage = Math.min(search.page, pageCount)

  useEffect(() => {
    if (!listQuery.data || search.page <= pageCount) return
    void navigate({
      to: '/company/kpi-management',
      search: (previous: KpiManagementSearch) => ({ ...previous, page: pageCount }),
      replace: true,
    })
  }, [listQuery.data, navigate, pageCount, search.page])

  const commitSearch = useCallback(
    (value: string) => {
      void navigate({
        to: '/company/kpi-management',
        search: (previous: KpiManagementSearch) => ({ ...previous, search: value, page: 1 }),
      })
    },
    [navigate],
  )

  function openEditor(record: RoleKpiDto | null) {
    setEditorRecord(record)
    setEditorKey((key) => key + 1)
    setEditorOpen(true)
  }

  async function saveKpi(roleId: number, recordId: number | null, input: RoleKpiWriteInput) {
    await saveMutation.mutateAsync({ roleId, recordId, input })
    setEditorOpen(false)
    showToast({
      tone: 'success',
      title: recordId === null ? 'KPI added' : 'KPI updated',
      description: 'The role KPI assignment has been saved.',
    })
  }

  async function removeKpi() {
    if (!deleteTarget) return
    try {
      await deleteMutation.mutateAsync(deleteTarget)
      setDeleteTarget(null)
      showToast({
        tone: 'success',
        title: 'KPI removed',
        description: 'The assignment was removed from this role.',
      })
    } catch {
      // Keep the confirmation open so the user can read the error and retry.
    }
  }

  const retryList = () => void listQuery.refetch()

  return (
    <PageLayout
      title="KPI Management"
      actionsInline
      actions={
        canCreate ? (
          <Button
            aria-label="Add KPI"
            leadingIcon={<Plus className="size-4" />}
            onClick={() => openEditor(null)}
            className="max-[479px]:text-caption max-[479px]:min-h-9 max-[479px]:px-3"
          >
            <span className="phone:hidden max-[361px]:hidden">New</span>
            <span className="phone:inline hidden">Add KPI</span>
          </Button>
        ) : null
      }
    >
      <div className="space-y-5">
        <Card className="from-primary-subtle/35 via-surface to-surface tablet:flex-row tablet:items-end tablet:justify-between tablet:p-5 flex min-w-0 flex-col gap-4 bg-gradient-to-br p-4">
          <div className="min-w-0">
            <p className="text-overline text-primary font-semibold tracking-wide">
              Role performance
            </p>
            <h2 className="text-h2 mt-1 font-semibold">KPI assignments</h2>
          </div>
          {listQuery.data ? (
            <div className="shrink-0">
              <StatusChip
                label={`${resultCount} ${resultCount === 1 ? 'assignment' : 'assignments'}`}
                tone="info"
              />
            </div>
          ) : null}
        </Card>

        <Card className="tablet:p-5 space-y-4 p-4">
          <SearchControl value={search.search} onCommit={commitSearch} />
          {rolesQuery.isError ? (
            <Alert tone="info" role="status">
              Role names are temporarily unavailable. KPI assignments remain visible by role ID.
            </Alert>
          ) : null}
        </Card>

        {listQuery.isError && !listQuery.data ? (
          <SectionErrorState
            error={listQuery.error}
            title="KPI assignments could not be loaded"
            onRetry={retryList}
          />
        ) : null}
        {listQuery.isError && listQuery.data ? (
          <SectionErrorState
            error={listQuery.error}
            title="Showing saved KPI assignments"
            onRetry={retryList}
            className="py-2"
          />
        ) : null}
        {listQuery.isFetching && listQuery.data ? (
          <p className="text-caption text-text-secondary" role="status" aria-live="polite">
            Updating KPI assignments…
          </p>
        ) : null}
        {listQuery.isPending ? (
          <div className="tablet:grid-cols-2 grid gap-4">
            {Array.from({ length: 6 }, (_, index) => (
              <Skeleton key={index} className="h-64 w-full" />
            ))}
          </div>
        ) : null}
        {listQuery.data && listQuery.data.items.length === 0 ? (
          <Card>
            <EmptyState
              icon={<ChartNoAxesCombined className="size-6" />}
              title={search.search ? 'No matching KPIs' : 'No role KPIs yet'}
              description={
                search.search
                  ? 'Try another metric name or description, or clear the search.'
                  : 'Create shared performance measures for roles. These assignments can be tailored later in employee plans.'
              }
              action={
                !search.search && canCreate ? (
                  <Button
                    leadingIcon={<Plus className="size-4" />}
                    onClick={() => openEditor(null)}
                  >
                    Add KPI
                  </Button>
                ) : undefined
              }
            />
          </Card>
        ) : null}
        {listQuery.data && listQuery.data.items.length > 0 ? (
          <div className="tablet:grid-cols-2 grid min-w-0 gap-4">
            {listQuery.data.items.map((kpi) => (
              <MetricCard
                key={`${kpi.role_id}-${kpi.id}`}
                kpi={kpi}
                roleName={roleNames.get(kpi.role_id) ?? `Role #${kpi.role_id}`}
                canUpdate={canUpdate}
                canDelete={canDelete}
                onEdit={() => openEditor(kpi)}
                onDelete={() => {
                  deleteMutation.reset()
                  setDeleteTarget(kpi)
                }}
              />
            ))}
          </div>
        ) : null}

        {resultCount > PAGE_SIZE ? (
          <Card className="phone:flex-row phone:items-center phone:justify-between flex flex-col gap-3 p-4">
            <p className="text-caption text-text-secondary">
              Page {currentPage} of {pageCount} · {resultCount} role KPI assignments
            </p>
            <nav aria-label="KPI assignment pages" className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                leadingIcon={<ChevronLeft className="size-4" />}
                disabled={currentPage <= 1 || listQuery.isFetching}
                onClick={() =>
                  void navigate({
                    to: '/company/kpi-management',
                    search: (previous: KpiManagementSearch) => ({
                      ...previous,
                      page: Math.max(1, currentPage - 1),
                    }),
                  })
                }
              >
                Previous
              </Button>
              <Button
                variant="outline"
                size="sm"
                leadingIcon={<ChevronRight className="size-4" />}
                disabled={currentPage >= pageCount || listQuery.isFetching}
                onClick={() =>
                  void navigate({
                    to: '/company/kpi-management',
                    search: (previous: KpiManagementSearch) => ({
                      ...previous,
                      page: currentPage + 1,
                    }),
                  })
                }
              >
                Next
              </Button>
            </nav>
          </Card>
        ) : null}
      </div>

      <KpiEditorDialog
        open={editorOpen}
        editorKey={editorKey}
        record={editorRecord}
        recordRoleName={
          editorRecord
            ? (roleNames.get(editorRecord.role_id) ?? `Role #${editorRecord.role_id}`)
            : ''
        }
        sessionScope={sessionScope}
        permissions={permissions}
        saving={saveMutation.isPending}
        onClose={() => setEditorOpen(false)}
        onSave={saveKpi}
      />
      <Dialog
        open={deleteTarget !== null}
        onOpenChange={(open) => !open && !deleteMutation.isPending && setDeleteTarget(null)}
        title="Remove KPI from role?"
        description="This only changes the selected role assignment."
        size="sm"
        fitContent
        compactOnMobile
        dismissDisabled={deleteMutation.isPending}
        footer={
          <>
            <Button
              variant="outline"
              onClick={() => setDeleteTarget(null)}
              disabled={deleteMutation.isPending}
            >
              Cancel
            </Button>
            <Button
              variant="danger"
              onClick={() => void removeKpi()}
              isLoading={deleteMutation.isPending}
            >
              Remove from role
            </Button>
          </>
        }
      >
        {deleteTarget ? (
          <div className="space-y-4">
            {deleteMutation.isError ? (
              <Alert tone="danger" role="alert">
                {presentError(deleteMutation.error, 'form-submit').message}
              </Alert>
            ) : null}
            <p className="text-body-sm text-text-secondary">
              Remove <strong className="text-text-primary">{deleteTarget.metric.name}</strong> from{' '}
              {roleNames.get(deleteTarget.role_id) ?? `Role #${deleteTarget.role_id}`}?
            </p>
            <Alert tone="info" role="status">
              The shared metric and historical employee KPI data will remain.
            </Alert>
          </div>
        ) : null}
      </Dialog>
    </PageLayout>
  )
}
