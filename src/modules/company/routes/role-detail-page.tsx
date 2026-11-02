import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useParams, useSearch } from '@tanstack/react-router'
import {
  ArrowLeft,
  BriefcaseBusiness,
  ChartNoAxesCombined,
  ClipboardList,
  CircleAlert,
  FileText,
  GraduationCap,
  Network,
  Pencil,
  Plus,
  ShieldCheck,
  Trash2,
} from 'lucide-react'
import { useState, type FormEvent, type ReactNode } from 'react'

import {
  rolesApi,
  rolesQueryKeys,
  unwrapPage,
  type RoleDescriptionDto,
  type RoleReportingNodeDto,
  type SOPChoiceDto,
} from '@/modules/company/roles.api'
import { employeesApi, employeesQueryKeys, type EmployeeDto } from '@/modules/hr/employees.api'
import {
  trainingProgramsApi,
  type TrainingProgramChoiceDto,
} from '@/modules/hr/training-programs.api'
import {
  kpiManagementApi,
  kpiManagementQueryKeys,
  type KpiMetricDto,
} from '@/modules/company/kpi-management.api'
import { branchesApi } from '@/modules/company/branches.api'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { ApiError } from '@/shared/api/api-error'
import { presentError } from '@/shared/errors'
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
import { groupRolePermissions } from '@/shared/permissions/role-permission-groups'
import { RolePermissionSummary } from '@/shared/permissions/role-permission-summary'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { RoleEditor } from './roles-page'
import type { RoleDetailSearch } from '../role-detail.search'

type SectionRecord = Record<string, unknown> & { id: number }
type PerformancePerson = {
  employee: EmployeeDto
  score: number | null
  scoreState: 'available' | 'not-scored' | 'unavailable' | 'restricted'
  reviewState: 'on-file' | 'none' | 'unavailable' | 'restricted'
}
type RoleTabId =
  | 'overview'
  | 'org-chart'
  | 'career-path'
  | 'kpis'
  | 'targets'
  | 'performance-analytics'
  | 'task-templates'
  | 'sops'
  | 'daily-routine'
  | 'training'
  | 'success-playbook'
  | 'resources'
type FieldSpec = {
  name: string
  label: string
  displayLabel?: string
  kind?: 'text' | 'number' | 'time' | 'textarea' | 'select' | 'checkbox'
  required?: boolean
  options?: string[]
  min?: number
  max?: number
  hint?: string
  lookup?: 'kpi-metrics' | 'training-programs' | 'sops'
}
type SectionSpec = {
  tab: RoleTabId
  label: string
  resource?: string
  path?: string
  title: string
  addLabel?: string
  itemName?: string
  fields?: FieldSpec[]
  lookup?: string
}
const EMPTY_PERMISSIONS: Record<string, string[]> = {}

const tabs: Array<{ id: RoleTabId; label: string; icon: ReactNode; resource?: string }> = [
  { id: 'overview', label: 'Overview', icon: <BriefcaseBusiness className="size-4" /> },
  {
    id: 'org-chart',
    label: 'Org Chart',
    icon: <Network className="size-4" />,
    resource: 'role_reporting_lines',
  },
  {
    id: 'career-path',
    label: 'Career Path',
    icon: <BriefcaseBusiness className="size-4" />,
    resource: 'role_career_paths',
  },
  {
    id: 'kpis',
    label: 'KPIs',
    icon: <ChartNoAxesCombined className="size-4" />,
    resource: 'role_kpis',
  },
  {
    id: 'targets',
    label: 'Targets',
    icon: <ChartNoAxesCombined className="size-4" />,
    resource: 'role_target_templates',
  },
  {
    id: 'performance-analytics',
    label: 'Performance Analytics',
    icon: <ChartNoAxesCombined className="size-4" />,
    resource: 'monthly_scorecards',
  },
  {
    id: 'task-templates',
    label: 'Task Templates',
    icon: <ClipboardList className="size-4" />,
    resource: 'role_task_templates',
  },
  { id: 'sops', label: 'SOPs', icon: <FileText className="size-4" />, resource: 'role_sops' },
  {
    id: 'daily-routine',
    label: 'Daily Work Routine',
    icon: <ClipboardList className="size-4" />,
    resource: 'role_daily_routines',
  },
  {
    id: 'training',
    label: 'Training',
    icon: <GraduationCap className="size-4" />,
    resource: 'role_training_requirements',
  },
  {
    id: 'success-playbook',
    label: 'Success Playbook',
    icon: <ShieldCheck className="size-4" />,
    resource: 'role_success_playbook',
  },
  {
    id: 'resources',
    label: 'Resources',
    icon: <FileText className="size-4" />,
    resource: 'role_resources',
  },
]

const sections: Partial<Record<RoleTabId, SectionSpec>> = {
  'org-chart': {
    tab: 'org-chart',
    label: 'Reporting relationships',
    resource: 'role_reporting_lines',
    path: 'reporting-lines',
    title: 'Reporting relationships',
    addLabel: 'Add reporting relationship',
    itemName: 'reporting relationship',
    fields: [
      {
        name: 'reports_to_role_id',
        label: 'Reports to role',
        displayLabel: 'Reports to',
        kind: 'number',
        required: true,
        min: 1,
        hint: 'Choose the manager or escalation role for this position.',
      },
      {
        name: 'relationship_type',
        label: 'Relationship',
        kind: 'select',
        options: ['direct', 'dotted_line', 'escalation'],
        required: true,
      },
      { name: 'branch_id', label: 'Branch ID', kind: 'number', min: 1 },
      { name: 'department_id', label: 'Department ID', kind: 'number', min: 1 },
      { name: 'unit_id', label: 'Unit ID', kind: 'number', min: 1 },
      { name: 'sequence', label: 'Display order', kind: 'number', min: 1 },
      { name: 'is_active', label: 'Active relationship', kind: 'checkbox' },
    ],
  },
  'career-path': {
    tab: 'career-path',
    label: 'Career Path',
    resource: 'role_career_paths',
    path: 'career-path',
    title: 'Career progression',
    addLabel: 'Add career path',
    itemName: 'career path',
    fields: [
      { name: 'to_role_id', label: 'Next role', kind: 'number', required: true, min: 1 },
      { name: 'description', label: 'Progression summary', kind: 'textarea' },
      { name: 'requirements', label: 'Requirements', kind: 'textarea' },
      {
        name: 'estimated_duration_months',
        label: 'Estimated duration (months)',
        kind: 'number',
        min: 1,
      },
      { name: 'sequence', label: 'Display order', kind: 'number', min: 1 },
      { name: 'is_active', label: 'Active progression', kind: 'checkbox' },
    ],
  },
  kpis: {
    tab: 'kpis',
    label: 'KPIs',
    resource: 'role_kpis',
    path: 'kpis',
    title: 'Key performance indicators',
    addLabel: 'Add KPI',
    itemName: 'KPI',
    lookup: 'kpi-metrics',
    fields: [
      {
        name: 'metric_id',
        label: 'Metric',
        displayLabel: 'KPI metric',
        kind: 'number',
        required: true,
        min: 1,
        hint: 'Choose a metric from the shared KPI catalog.',
        lookup: 'kpi-metrics',
      },
      {
        name: 'tracking_mode',
        label: 'Tracking method',
        kind: 'select',
        options: ['manual', 'system', 'automatic', 'semi_automatic'],
        required: true,
      },
      { name: 'target_value', label: 'Target value', kind: 'number', min: 0 },
      { name: 'weight', label: 'Weight', kind: 'number', min: 0, max: 100 },
      {
        name: 'period',
        label: 'Review period',
        kind: 'select',
        options: ['daily', 'weekly', 'monthly', 'quarterly', 'semi_annual', 'annual', 'custom'],
        required: true,
      },
      { name: 'sequence', label: 'Display order', kind: 'number', min: 1 },
      { name: 'is_active', label: 'Active KPI', kind: 'checkbox' },
    ],
  },
  targets: {
    tab: 'targets',
    label: 'Targets',
    resource: 'role_target_templates',
    path: 'target-templates',
    title: 'Target templates',
    addLabel: 'Add target',
    itemName: 'target',
    fields: [
      { name: 'title', label: 'Target name', required: true },
      { name: 'description', label: 'Description', kind: 'textarea' },
      { name: 'target_value', label: 'Target value', kind: 'number', required: true, min: 0 },
      { name: 'unit', label: 'Unit' },
      {
        name: 'period',
        label: 'Period',
        kind: 'select',
        options: ['daily', 'weekly', 'monthly', 'quarterly', 'yearly', 'custom'],
        required: true,
      },
      { name: 'sequence', label: 'Display order', kind: 'number', min: 1 },
      { name: 'is_active', label: 'Active target', kind: 'checkbox' },
    ],
  },
  'task-templates': {
    tab: 'task-templates',
    label: 'Task Templates',
    resource: 'role_task_templates',
    path: 'task-templates',
    title: 'Standard tasks',
    addLabel: 'Add task template',
    itemName: 'task template',
    fields: [
      { name: 'title', label: 'Task name', required: true },
      { name: 'description', label: 'Description', kind: 'textarea' },
      {
        name: 'default_priority',
        label: 'Default priority',
        kind: 'select',
        options: ['low', 'medium', 'high', 'urgent'],
        required: true,
      },
      { name: 'estimated_minutes', label: 'Estimated time (minutes)', kind: 'number', min: 1 },
      { name: 'sequence', label: 'Display order', kind: 'number', min: 1 },
      { name: 'is_active', label: 'Active template', kind: 'checkbox' },
    ],
  },
  sops: {
    tab: 'sops',
    label: 'SOPs',
    resource: 'role_sops',
    path: 'sops',
    title: 'Standard operating procedures',
    addLabel: 'Assign SOP',
    itemName: 'SOP assignment',
    lookup: 'sops',
    fields: [
      {
        name: 'sop_id',
        label: 'Standard operating procedure',
        displayLabel: 'Procedure',
        kind: 'number',
        required: true,
        min: 1,
        lookup: 'sops',
      },
      { name: 'is_active', label: 'Active SOP assignment', kind: 'checkbox' },
    ],
  },
  'daily-routine': {
    tab: 'daily-routine',
    label: 'Daily Work Routine',
    resource: 'role_daily_routines',
    path: 'daily-routine',
    title: 'Daily routine',
    addLabel: 'Add routine item',
    itemName: 'routine item',
    fields: [
      { name: 'title', label: 'Routine activity', required: true },
      { name: 'description', label: 'Description', kind: 'textarea' },
      { name: 'time_of_day', label: 'Time of day', kind: 'time' },
      { name: 'estimated_minutes', label: 'Estimated time (minutes)', kind: 'number', min: 1 },
      { name: 'sequence', label: 'Display order', kind: 'number', min: 1 },
      { name: 'is_active', label: 'Active routine item', kind: 'checkbox' },
    ],
  },
  training: {
    tab: 'training',
    label: 'Training',
    resource: 'role_training_requirements',
    path: 'training-requirements',
    title: 'Training requirements',
    addLabel: 'Add training requirement',
    itemName: 'training requirement',
    lookup: 'training-programs',
    fields: [
      {
        name: 'training_program_id',
        label: 'Training program',
        displayLabel: 'Training program',
        kind: 'number',
        required: true,
        min: 1,
        hint: 'Choose a program from the training catalog.',
        lookup: 'training-programs',
      },
      {
        name: 'requirement_type',
        label: 'Requirement',
        kind: 'select',
        options: ['mandatory', 'continuous'],
        required: true,
      },
      { name: 'sequence', label: 'Display order', kind: 'number', min: 1 },
      { name: 'is_active', label: 'Active requirement', kind: 'checkbox' },
    ],
  },
  'success-playbook': {
    tab: 'success-playbook',
    label: 'Success Playbook',
    resource: 'role_success_playbook',
    path: 'success-playbook',
    title: 'Success practices',
    addLabel: 'Add practice',
    itemName: 'success practice',
    fields: [
      { name: 'title', label: 'Practice title', required: true },
      { name: 'description', label: 'Description', kind: 'textarea' },
      {
        name: 'kind',
        label: 'Practice type',
        kind: 'select',
        options: ['best_practice', 'common_mistake', 'winning_strategy', 'lesson_learned'],
        required: true,
      },
      { name: 'sequence', label: 'Display order', kind: 'number', min: 1 },
      { name: 'is_active', label: 'Active practice', kind: 'checkbox' },
    ],
  },
  resources: {
    tab: 'resources',
    label: 'Resources',
    resource: 'role_resources',
    path: 'resources',
    title: 'Role resources',
    addLabel: 'Add resource',
    itemName: 'role resource',
    fields: [
      { name: 'name', label: 'Resource name', required: true },
      { name: 'description', label: 'Description', kind: 'textarea' },
      {
        name: 'kind',
        label: 'Resource type',
        kind: 'select',
        options: ['physical', 'software', 'document', 'skill'],
        required: true,
      },
      { name: 'sequence', label: 'Display order', kind: 'number', min: 1 },
      { name: 'is_active', label: 'Active resource', kind: 'checkbox' },
    ],
  },
}

function labelize(value: string) {
  return value.replaceAll('_', ' ').replace(/\b\w/g, (letter) => letter.toLocaleUpperCase())
}

function recordFieldValue(record: SectionRecord, field: FieldSpec) {
  const related = nestedField(record, field.name)
  const value = related ?? record[field.name]
  if (field.kind === 'time' && typeof value === 'string') return value.slice(0, 5)
  if (field.kind === 'select' && typeof value === 'string') return labelize(value)
  if (field.kind === 'number' && value !== null && value !== undefined && value !== '') {
    const numeric = Number(value)
    if (Number.isFinite(numeric)) {
      const formatted = new Intl.NumberFormat(undefined, { maximumFractionDigits: 2 }).format(
        numeric,
      )
      if (field.name === 'target_value' && record.metric && typeof record.metric === 'object') {
        const unit = String((record.metric as Record<string, unknown>).unit ?? '').trim()
        if (['%', 'percent', 'percentage'].includes(unit.toLocaleLowerCase()))
          return `${formatted}%`
        if (unit) return `${formatted} ${unit}`
      }
      return formatted
    }
  }
  return formatValue(value)
}

function formatValue(value: unknown): string {
  if (value === null || value === undefined || value === '') return 'Not set'
  if (typeof value === 'boolean') return value ? 'Active' : 'Inactive'
  if (typeof value === 'object') {
    if (Array.isArray(value)) return value.map((item) => formatValue(item)).join(', ')
    const record = value as Record<string, unknown>
    return String(
      record.name ??
        record.title ??
        record.program_name ??
        record.branch_name ??
        JSON.stringify(record),
    )
  }
  return String(value)
}
function bestRecordLabel(record: SectionRecord, spec: SectionSpec) {
  const candidate = [
    'title',
    'name',
    'to_role',
    'reports_to_role',
    'metric',
    'sop',
    'training_program',
  ]
    .map((key) => record[key])
    .find(Boolean)
  const candidateLabel =
    typeof candidate === 'object' && candidate !== null
      ? formatValue(candidate)
      : candidate
        ? String(candidate)
        : ''
  return candidateLabel || `${spec.label} #${record.id}`
}

function initialResourceDraft(spec: SectionSpec, record: SectionRecord | null) {
  const draft: Record<string, string | boolean> = {}
  for (const field of spec.fields ?? []) {
    const value = record?.[field.name]
    draft[field.name] =
      field.kind === 'checkbox'
        ? typeof value === 'boolean'
          ? value
          : true
        : value == null
          ? ''
          : field.kind === 'time'
            ? String(value).slice(0, 5)
            : String(value)
  }
  return draft
}

function ResourceEditor({
  open,
  spec,
  record,
  roleChoices,
  currentRoleId,
  roleChoicesLoading,
  roleChoicesError,
  onRetryRoleChoices,
  kpiMetricChoices,
  kpiMetricChoicesLoading,
  kpiMetricChoicesError,
  assignedMetricIds,
  canListKpiMetrics,
  onRetryKpiMetricChoices,
  trainingProgramChoices,
  trainingProgramChoicesLoading,
  trainingProgramChoicesError,
  canListTrainingPrograms,
  onRetryTrainingProgramChoices,
  sopChoices,
  sopChoicesLoading,
  sopChoicesError,
  canListSops,
  onRetrySopChoices,
  onClose,
  onSave,
  saving,
  error,
}: {
  open: boolean
  spec: SectionSpec
  record: SectionRecord | null
  roleChoices: Array<{ id: number; name: string }>
  currentRoleId: number
  roleChoicesLoading: boolean
  roleChoicesError?: unknown
  onRetryRoleChoices: () => void
  kpiMetricChoices: KpiMetricDto[]
  kpiMetricChoicesLoading: boolean
  kpiMetricChoicesError?: unknown
  assignedMetricIds: number[]
  canListKpiMetrics: boolean
  onRetryKpiMetricChoices: () => void
  trainingProgramChoices: TrainingProgramChoiceDto[]
  trainingProgramChoicesLoading: boolean
  trainingProgramChoicesError?: unknown
  canListTrainingPrograms: boolean
  onRetryTrainingProgramChoices: () => void
  sopChoices: SOPChoiceDto[]
  sopChoicesLoading: boolean
  sopChoicesError?: unknown
  canListSops: boolean
  onRetrySopChoices: () => void
  onClose: () => void
  onSave: (value: Record<string, unknown>) => void
  saving: boolean
  error?: unknown
}) {
  const [draft, setDraft] = useState<Record<string, string | boolean>>(() =>
    initialResourceDraft(spec, record),
  )
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({})
  const update = (key: string, value: string | boolean) => {
    setDraft((current) => ({ ...current, [key]: value }))
    setFieldErrors((current) => {
      if (!current[key]) return current
      const next = { ...current }
      delete next[key]
      return next
    })
  }
  const roleChoiceFields = (spec.fields ?? []).filter((field) =>
    ['reports_to_role_id', 'to_role_id'].includes(field.name),
  )
  const kpiMetricField = (spec.fields ?? []).find((field) => field.lookup === 'kpi-metrics')
  const trainingProgramField = (spec.fields ?? []).find(
    (field) => field.lookup === 'training-programs',
  )
  const sopField = (spec.fields ?? []).find((field) => field.lookup === 'sops')
  const selectableRoles = roleChoices.filter((item) => item.id !== currentRoleId)
  const existingMetricId = Number(draft.metric_id)
  const selectableMetrics = kpiMetricChoices.filter(
    (metric) => !assignedMetricIds.includes(metric.id) || metric.id === existingMetricId,
  )
  const existingMetric = record?.metric as KpiMetricDto | undefined
  if (existingMetric && !selectableMetrics.some((metric) => metric.id === existingMetric.id)) {
    selectableMetrics.unshift(existingMetric)
  }
  const selectableTrainingPrograms = [...trainingProgramChoices]
  const existingTrainingProgram = record?.training_program as TrainingProgramChoiceDto | undefined
  if (
    existingTrainingProgram &&
    !selectableTrainingPrograms.some((program) => program.id === existingTrainingProgram.id)
  ) {
    selectableTrainingPrograms.unshift(existingTrainingProgram)
  }
  const selectableSops = [...sopChoices]
  const existingSop = record?.sop as SOPChoiceDto | undefined
  if (existingSop && !selectableSops.some((sop) => sop.id === existingSop.id)) {
    selectableSops.unshift(existingSop)
  }
  const roleChoicesUnavailable = Boolean(
    roleChoiceFields.length && (roleChoicesLoading || roleChoicesError || !selectableRoles.length),
  )
  const kpiMetricChoicesUnavailable = Boolean(
    kpiMetricField &&
    (kpiMetricChoicesLoading || kpiMetricChoicesError || !selectableMetrics.length),
  )
  const trainingProgramChoicesUnavailable = Boolean(
    trainingProgramField &&
    (trainingProgramChoicesLoading ||
      trainingProgramChoicesError ||
      !selectableTrainingPrograms.length),
  )
  const sopChoicesUnavailable = Boolean(
    sopField && (sopChoicesLoading || sopChoicesError || !selectableSops.length),
  )
  const lookupChoicesUnavailable =
    roleChoicesUnavailable ||
    kpiMetricChoicesUnavailable ||
    trainingProgramChoicesUnavailable ||
    sopChoicesUnavailable
  const editorName = spec.itemName ?? spec.label
  const submit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    const nextErrors: Record<string, string> = {}
    for (const field of spec.fields ?? []) {
      const value = draft[field.name]
      if (field.required && (value === undefined || String(value).trim() === '')) {
        nextErrors[field.name] =
          field.kind === 'select' ||
          field.lookup ||
          ['reports_to_role_id', 'to_role_id'].includes(field.name)
            ? `Select ${field.label.toLocaleLowerCase()}.`
            : `${field.label} is required.`
        continue
      }
      if (field.kind === 'number' && value !== '' && value !== undefined) {
        const number = Number(value)
        if (!Number.isFinite(number))
          nextErrors[field.name] = `Enter a valid ${field.label.toLocaleLowerCase()}.`
        else if (field.min !== undefined && number < field.min) {
          nextErrors[field.name] = `${field.label} must be at least ${field.min}.`
        } else if (field.max !== undefined && number > field.max) {
          nextErrors[field.name] = `${field.label} must be no more than ${field.max}.`
        }
      }
    }
    if (roleChoiceFields.length && roleChoicesUnavailable) {
      for (const field of roleChoiceFields) {
        nextErrors[field.name] = roleChoicesLoading
          ? 'Role choices are still loading.'
          : roleChoicesError
            ? 'Role choices could not be loaded. Retry before saving.'
            : 'There are no other roles to choose from.'
      }
    }
    if (kpiMetricField && kpiMetricChoicesUnavailable) {
      nextErrors[kpiMetricField.name] = kpiMetricChoicesLoading
        ? 'The KPI catalog is still loading.'
        : kpiMetricChoicesError
          ? 'The KPI catalog could not be loaded. Retry before saving.'
          : kpiMetricChoices.length &&
              selectableMetrics.length === 0 &&
              assignedMetricIds.length >= kpiMetricChoices.length
            ? 'All KPI metrics in the catalog are already assigned to this role.'
            : canListKpiMetrics
              ? 'There are no KPI metrics available to assign.'
              : 'KPI catalog access is required to choose a metric.'
    }
    if (trainingProgramField && trainingProgramChoicesUnavailable) {
      nextErrors[trainingProgramField.name] = trainingProgramChoicesLoading
        ? 'Training programs are still loading.'
        : trainingProgramChoicesError
          ? 'Training programs could not be loaded. Retry before saving.'
          : canListTrainingPrograms
            ? 'There are no training programs available to assign.'
            : 'Training catalog access is required to choose a program.'
    }
    if (sopField && sopChoicesUnavailable) {
      nextErrors[sopField.name] = sopChoicesLoading
        ? 'SOP choices are still loading.'
        : sopChoicesError
          ? 'SOP choices could not be loaded. Retry before saving.'
          : canListSops
            ? 'There are no procedures available to assign.'
            : 'SOP catalog access is required to choose a procedure.'
    }
    setFieldErrors(nextErrors)
    if (Object.keys(nextErrors).length) return

    const payload: Record<string, unknown> = {}
    for (const field of spec.fields ?? []) {
      const value = draft[field.name]
      if (field.kind === 'checkbox') payload[field.name] = Boolean(value)
      else if (field.kind === 'number') payload[field.name] = value === '' ? null : Number(value)
      else payload[field.name] = String(value ?? '').trim()
    }
    onSave(payload)
  }
  return (
    <Dialog
      open={open}
      onOpenChange={(value) => {
        if (!value && !saving) onClose()
      }}
      title={record ? `Edit ${editorName}` : `Add ${editorName}`}
      description={
        record ? 'Update the values assigned to this role.' : 'Add a standard for this role.'
      }
      size="lg"
      footer={
        <>
          <Button variant="outline" onClick={onClose} disabled={saving}>
            Cancel
          </Button>
          <Button
            type="submit"
            form="role-section-editor"
            isLoading={saving}
            disabled={lookupChoicesUnavailable}
          >
            {record ? 'Save changes' : (spec.addLabel ?? 'Add item')}
          </Button>
        </>
      }
    >
      <form id="role-section-editor" onSubmit={submit} noValidate className="space-y-4">
        {error ? (
          <Alert tone="danger" role="alert" title="Changes could not be saved">
            Review the values and try again. Your current draft is preserved.
          </Alert>
        ) : null}
        <section className="bg-surface-muted border-border-subtle rounded-control grid gap-4 border p-4 sm:grid-cols-2">
          {(spec.fields ?? []).map((field) => {
            const id = `role-section-${field.name}`
            if (field.kind === 'checkbox')
              return (
                <label
                  key={field.name}
                  className="text-body-sm text-text-primary flex min-h-11 items-center gap-2 sm:col-span-2"
                >
                  <input
                    id={id}
                    type="checkbox"
                    checked={Boolean(draft[field.name])}
                    onChange={(event) => update(field.name, event.currentTarget.checked)}
                  />
                  {field.label}
                </label>
              )
            const roleChoiceField = ['reports_to_role_id', 'to_role_id'].includes(field.name)
            const metricChoiceField = field.lookup === 'kpi-metrics'
            const trainingProgramChoiceField = field.lookup === 'training-programs'
            const sopChoiceField = field.lookup === 'sops'
            const choiceField =
              roleChoiceField || metricChoiceField || trainingProgramChoiceField || sopChoiceField
            const options = roleChoiceField
              ? selectableRoles.map((item) => ({ value: String(item.id), label: item.name }))
              : metricChoiceField
                ? selectableMetrics.map((item) => ({
                    value: String(item.id),
                    label: item.name,
                    description: [item.unit, item.description].filter(Boolean).join(' · '),
                  }))
                : trainingProgramChoiceField
                  ? selectableTrainingPrograms.map((item) => ({
                      value: String(item.id),
                      label: item.program_name,
                      description: item.provider,
                    }))
                  : sopChoiceField
                    ? selectableSops.map((item) => ({
                        value: String(item.id),
                        label: item.title,
                        description: [item.version, item.department, item.unit]
                          .filter(Boolean)
                          .join(' · '),
                      }))
                    : (field.options ?? []).map((option) => ({
                        value: option,
                        label: labelize(option),
                      }))
            const fieldError =
              fieldErrors[field.name] ??
              (roleChoiceField && roleChoicesError
                ? 'Role choices could not be loaded.'
                : roleChoiceField && !roleChoicesLoading && !selectableRoles.length
                  ? 'There are no other roles to choose from.'
                  : metricChoiceField && kpiMetricChoicesError
                    ? 'The KPI catalog could not be loaded.'
                    : metricChoiceField && !kpiMetricChoicesLoading && !selectableMetrics.length
                      ? assignedMetricIds.length >= kpiMetricChoices.length &&
                        kpiMetricChoices.length > 0
                        ? 'All KPI metrics in the catalog are already assigned to this role.'
                        : canListKpiMetrics
                          ? 'There are no KPI metrics available to assign.'
                          : 'KPI catalog access is required to choose a metric.'
                      : trainingProgramChoiceField && trainingProgramChoicesError
                        ? 'Training programs could not be loaded.'
                        : trainingProgramChoiceField &&
                            !trainingProgramChoicesLoading &&
                            !selectableTrainingPrograms.length
                          ? canListTrainingPrograms
                            ? 'There are no training programs available to assign.'
                            : 'Training catalog access is required to choose a program.'
                          : sopChoiceField && sopChoicesError
                            ? 'SOP choices could not be loaded.'
                            : sopChoiceField && !sopChoicesLoading && !selectableSops.length
                              ? canListSops
                                ? 'There are no procedures available to assign.'
                                : 'SOP catalog access is required to choose a procedure.'
                              : undefined)
            const choiceLoadingDescription = roleChoiceField
              ? roleChoicesLoading
                ? 'Loading available roles…'
                : undefined
              : metricChoiceField
                ? kpiMetricChoicesLoading
                  ? 'Loading KPI metrics…'
                  : !canListKpiMetrics && !selectableMetrics.length
                    ? 'KPI catalog access is required to choose a metric.'
                    : undefined
                : trainingProgramChoiceField
                  ? trainingProgramChoicesLoading
                    ? 'Loading training programs…'
                    : !canListTrainingPrograms && !selectableTrainingPrograms.length
                      ? 'Training catalog access is required to choose a program.'
                      : undefined
                  : sopChoiceField
                    ? sopChoicesLoading
                      ? 'Loading procedures…'
                      : !canListSops && !selectableSops.length
                        ? 'SOP catalog access is required to choose a procedure.'
                        : undefined
                    : undefined
            return (
              <div key={field.name} className={field.kind === 'textarea' ? 'sm:col-span-2' : ''}>
                <FormControl
                  id={id}
                  label={field.label}
                  required={field.required}
                  description={choiceLoadingDescription ?? field.hint}
                  error={fieldError}
                >
                  {choiceField || field.kind === 'select' ? (
                    <DropdownSelect
                      id={id}
                      value={String(draft[field.name] ?? '')}
                      onChange={(value) => update(field.name, value)}
                      options={options}
                      placeholder={
                        roleChoiceField
                          ? 'Select a role'
                          : sopChoiceField
                            ? 'Select a procedure'
                            : `Select ${field.label.toLocaleLowerCase()}`
                      }
                      required={field.required}
                      disabled={
                        (roleChoiceField &&
                          (roleChoicesLoading ||
                            Boolean(roleChoicesError) ||
                            !selectableRoles.length)) ||
                        (metricChoiceField && kpiMetricChoicesUnavailable) ||
                        (trainingProgramChoiceField && trainingProgramChoicesUnavailable) ||
                        (sopChoiceField && sopChoicesUnavailable)
                      }
                      searchable={choiceField && options.length >= 7}
                      searchPlaceholder={
                        roleChoiceField
                          ? 'Search roles'
                          : metricChoiceField
                            ? 'Search KPI metrics'
                            : trainingProgramChoiceField
                              ? 'Search training programs'
                              : sopChoiceField
                                ? 'Search procedures'
                                : undefined
                      }
                      emptyMessage={
                        roleChoiceField
                          ? 'No matching roles.'
                          : metricChoiceField
                            ? 'No matching KPI metrics.'
                            : trainingProgramChoiceField
                              ? 'No matching training programs.'
                              : sopChoiceField
                                ? 'No matching procedures.'
                                : undefined
                      }
                      aria-invalid={fieldError ? 'true' : undefined}
                    />
                  ) : field.kind === 'textarea' ? (
                    <TextArea
                      id={id}
                      value={String(draft[field.name] ?? '')}
                      onChange={(event) => update(field.name, event.currentTarget.value)}
                      rows={3}
                      maxLength={5000}
                      required={field.required}
                    />
                  ) : (
                    <TextInput
                      id={id}
                      type={
                        field.kind === 'number' ? 'number' : field.kind === 'time' ? 'time' : 'text'
                      }
                      min={field.min}
                      max={field.max}
                      step={
                        field.kind === 'number' ? 'any' : field.kind === 'time' ? '60' : undefined
                      }
                      value={String(draft[field.name] ?? '')}
                      onChange={(event) => update(field.name, event.currentTarget.value)}
                      required={field.required}
                      placeholder={field.hint ? 'Enter a valid ID' : undefined}
                      autoComplete="off"
                    />
                  )}
                </FormControl>
                {roleChoiceField && roleChoicesError ? (
                  <Button
                    type="button"
                    size="sm"
                    variant="outline"
                    className="mt-2"
                    onClick={onRetryRoleChoices}
                  >
                    Retry roles
                  </Button>
                ) : null}
                {metricChoiceField && kpiMetricChoicesError ? (
                  <Button
                    type="button"
                    size="sm"
                    variant="outline"
                    className="mt-2"
                    onClick={onRetryKpiMetricChoices}
                  >
                    Retry KPI metrics
                  </Button>
                ) : null}
                {trainingProgramChoiceField && trainingProgramChoicesError ? (
                  <Button
                    type="button"
                    size="sm"
                    variant="outline"
                    className="mt-2"
                    onClick={onRetryTrainingProgramChoices}
                  >
                    Retry training programs
                  </Button>
                ) : null}
                {sopChoiceField && sopChoicesError ? (
                  <Button
                    type="button"
                    size="sm"
                    variant="outline"
                    className="mt-2"
                    onClick={onRetrySopChoices}
                  >
                    Retry procedures
                  </Button>
                ) : null}
              </div>
            )
          })}
        </section>
      </form>
    </Dialog>
  )
}

function DataGrid({
  records,
  spec,
  canEdit,
  canDelete,
  onEdit,
  onDelete,
}: {
  records: SectionRecord[]
  spec: SectionSpec
  canEdit: boolean
  canDelete: boolean
  onEdit: (record: SectionRecord) => void
  onDelete: (record: SectionRecord) => void
}) {
  const fields = spec.fields ?? []
  return (
    <div className={`grid min-w-0 gap-3 ${records.length > 1 ? 'tablet:grid-cols-2' : ''}`}>
      {records.map((record) => (
        <article
          key={record.id}
          className="border-border-subtle bg-surface rounded-control shadow-elevation-sm min-w-0 border p-4"
        >
          <div className="flex min-w-0 items-start justify-between gap-3">
            <div className="flex min-w-0 items-start gap-3">
              <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
                <FileText className="size-5" aria-hidden="true" />
              </span>
              <div className="min-w-0">
                <h3 className="text-label text-text-primary line-clamp-2 font-semibold">
                  {bestRecordLabel(record, spec)}
                </h3>
                <p className="text-caption text-text-secondary mt-1">
                  {record.is_active === false ? 'Inactive' : 'Active'} · {spec.label}
                </p>
              </div>
            </div>
            <StatusChip
              label={record.is_active === false ? 'Inactive' : 'Active'}
              tone={record.is_active === false ? 'neutral' : 'success'}
              dense
            />
          </div>
          <dl className="mt-4 grid min-w-0 gap-3 sm:grid-cols-2">
            {fields
              .filter((field) => field.name !== 'is_active')
              .map((field) => (
                <div key={field.name} className="min-w-0">
                  <dt className="text-caption text-text-secondary">
                    {field.displayLabel ?? field.label}
                  </dt>
                  <dd className="text-body-sm text-text-primary mt-1 break-words">
                    {recordFieldValue(record, field)}
                  </dd>
                </div>
              ))}
          </dl>
          {canEdit || canDelete ? (
            <div className="border-border-subtle mt-4 flex flex-wrap justify-end gap-2 border-t pt-3">
              {canEdit ? (
                <Button variant="outline" size="sm" onClick={() => onEdit(record)}>
                  Edit
                </Button>
              ) : null}
              {canDelete ? (
                <Button
                  variant="ghost"
                  size="sm"
                  className="text-danger"
                  leadingIcon={<Trash2 className="size-4" />}
                  onClick={() => onDelete(record)}
                >
                  Delete
                </Button>
              ) : null}
            </div>
          ) : null}
        </article>
      ))}
    </div>
  )
}
function nestedField(record: SectionRecord, field: string) {
  const mapping: Record<string, string> = {
    to_role_id: 'to_role',
    reports_to_role_id: 'reports_to_role',
    metric_id: 'metric',
    sop_id: 'sop',
    training_program_id: 'training_program',
  }
  return mapping[field] ? record[mapping[field]] : undefined
}

export function RoleDetailPage() {
  const { roleId: roleIdParam } = useParams({ from: '/_protected/company/roles/$roleId' })
  const search = useSearch({ from: '/_protected/company/roles/$roleId' }) as RoleDetailSearch
  const navigate = useNavigate({ from: '/company/roles/$roleId' })
  const roleId = Number(roleIdParam)
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const permissions = session?.permissions ?? EMPTY_PERMISSIONS
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const [editorOpen, setEditorOpen] = useState(false)
  const [itemDraft, setItemDraft] = useState<SectionRecord | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<SectionRecord | null>(null)
  const [editRoleOpen, setEditRoleOpen] = useState(false)
  const [editRoleInitialStep, setEditRoleInitialStep] = useState<'details' | 'permissions'>(
    'details',
  )
  const [deleteRoleOpen, setDeleteRoleOpen] = useState(false)
  const canView = hasPermission(permissions, 'roles', 'view')
  const canEditRole = hasPermission(permissions, 'roles', 'update')
  const canDeleteRole = hasPermission(permissions, 'roles', 'delete')
  const visibleTabs = tabs.filter(
    (tab) =>
      !tab.resource ||
      hasPermission(permissions, tab.resource, 'list') ||
      (tab.id === 'performance-analytics' && hasPermission(permissions, 'employees', 'list')),
  )
  const activeTab = visibleTabs.some((tab) => tab.id === search.tab) ? search.tab : 'overview'
  const selectTab = (tab: RoleTabId) =>
    void navigate({ search: (previous: Record<string, unknown>) => ({ ...previous, tab }) })
  const roleQuery = useQuery({
    queryKey: rolesQueryKeys.detail(userId, employeeId, roleId),
    queryFn: ({ signal }) => rolesApi.get(roleId, signal),
    enabled: Boolean(session && canView && Number.isSafeInteger(roleId) && roleId > 0),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const role = roleQuery.data
  const descriptionQuery = useQuery<RoleDescriptionDto | null>({
    queryKey: [...rolesQueryKeys.detail(userId, employeeId, roleId), 'description'],
    queryFn: async ({ signal }) => {
      try {
        return await rolesApi.description(roleId, signal)
      } catch (error) {
        // A role description is optional. The backend returns 404 when it has not been added.
        if (error instanceof ApiError && error.status === 404) return null
        throw error
      }
    },
    enabled: Boolean(role && hasPermission(permissions, 'role_descriptions', 'view')),
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const descriptionHasContent = Boolean(
    descriptionQuery.data &&
    [
      descriptionQuery.data.purpose,
      descriptionQuery.data.responsibilities,
      descriptionQuery.data.job_description,
    ].some((value) => value.trim()),
  )
  const canEditRoleDescription = Boolean(
    role &&
    canEditRole &&
    descriptionQuery.isSuccess &&
    hasPermission(permissions, 'role_descriptions', descriptionQuery.data ? 'update' : 'create'),
  )
  const permissionQuery = useQuery({
    queryKey: rolesQueryKeys.permissions,
    queryFn: ({ signal }) => rolesApi.permissionMap(signal),
    enabled: Boolean(role && canEditRole),
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
    enabled: Boolean(role && canEditRole),
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const spec = sections[activeTab]
  const tabPermission = tabs.find((tab) => tab.id === activeTab)?.resource
  const canReadSection = !tabPermission || hasPermission(permissions, tabPermission, 'list')
  const sectionQuery = useQuery({
    queryKey: rolesQueryKeys.section(userId, employeeId, roleId, spec?.path ?? ''),
    queryFn: ({ signal }) => rolesApi.listSection<SectionRecord>(roleId, spec!.path!, signal),
    enabled: Boolean(role && spec && canReadSection),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const roleListQuery = useQuery({
    queryKey: ['company', 'roles', 'choices', userId, employeeId],
    queryFn: ({ signal }) => rolesApi.list({ limit: 100, offset: 0, search: '' }, signal),
    enabled: Boolean(role && ['org-chart', 'career-path'].includes(activeTab)),
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const canListKpiMetrics = hasPermission(permissions, 'kpis', 'list')
  const kpiMetricChoicesQuery = useQuery({
    queryKey: kpiManagementQueryKeys.metrics(userId, employeeId),
    queryFn: ({ signal }) => kpiManagementApi.metrics(signal),
    enabled: Boolean(role && spec?.lookup === 'kpi-metrics' && editorOpen && canListKpiMetrics),
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const canListTrainingPrograms = hasPermission(permissions, 'training_programs', 'list')
  const trainingProgramChoicesQuery = useQuery({
    queryKey: ['hr', 'training-programs', 'choices', userId, employeeId],
    queryFn: ({ signal }) => trainingProgramsApi.choices(signal),
    enabled: Boolean(
      role && spec?.lookup === 'training-programs' && editorOpen && canListTrainingPrograms,
    ),
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const canListSops = hasPermission(permissions, 'role_sops', 'list')
  const sopChoicesQuery = useQuery({
    queryKey: rolesQueryKeys.sopChoices(userId, employeeId),
    queryFn: ({ signal }) => rolesApi.sopChoices(signal),
    enabled: Boolean(role && spec?.lookup === 'sops' && editorOpen && canListSops),
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const reportingChartQuery = useQuery({
    queryKey: rolesQueryKeys.reportingChart(userId, employeeId, roleId),
    queryFn: async ({ signal }) =>
      Promise.all([
        rolesApi.reportingChain(roleId, signal),
        rolesApi.reportingTree(roleId, signal),
      ]),
    enabled: Boolean(role && activeTab === 'org-chart' && canReadSection),
    staleTime: DATA_FRESHNESS_MS.history,
  })
  const canReadScorecards = hasPermission(permissions, 'monthly_scorecards', 'view')
  const canReadReviews = hasPermission(permissions, 'performance_reviews', 'list')
  const employeeAnalyticsQuery = useQuery({
    queryKey: [
      ...employeesQueryKeys.all,
      userId,
      employeeId,
      'role-performance',
      roleId,
      canReadScorecards,
      canReadReviews,
    ],
    queryFn: async ({ signal }) => {
      const employeePage = await employeesApi.list(
        { limit: 500, offset: 0, search: '', view: 'active', branchId: 'all', departmentId: 'all' },
        signal,
      )
      const collator = new Intl.Collator(undefined, { sensitivity: 'base', numeric: true })
      const assigned = employeePage.items
        .filter((employee) => employee.role_id === roleId)
        .sort((left, right) =>
          collator.compare(
            `${left.first_name} ${left.last_name}`.trim(),
            `${right.first_name} ${right.last_name}`.trim(),
          ),
        )
      const people: PerformancePerson[] = []
      for (let offset = 0; offset < assigned.length; offset += 8) {
        const batch = assigned.slice(offset, offset + 8)
        const batchResults = await Promise.all(
          batch.map(async (employee) => {
            const [scoreResult, reviewResult] = await Promise.allSettled([
              canReadScorecards
                ? employeesApi.scorecard(
                    employee.id,
                    new Date().getMonth() + 1,
                    new Date().getFullYear(),
                    signal,
                    false,
                  )
                : Promise.resolve(null),
              canReadReviews
                ? employeesApi.performanceReviews(employee.id, signal)
                : Promise.resolve(null),
            ])
            const score =
              scoreResult.status === 'fulfilled' && scoreResult.value
                ? Number(scoreResult.value.overall_score)
                : null
            const scoreState: PerformancePerson['scoreState'] = !canReadScorecards
              ? 'restricted'
              : scoreResult.status === 'rejected'
                ? scoreResult.reason instanceof ApiError && scoreResult.reason.status === 404
                  ? 'not-scored'
                  : 'unavailable'
                : score != null && Number.isFinite(score)
                  ? 'available'
                  : 'not-scored'
            const reviewPage = reviewResult.status === 'fulfilled' ? reviewResult.value : null
            const reviewState: PerformancePerson['reviewState'] = !canReadReviews
              ? 'restricted'
              : reviewResult.status === 'rejected'
                ? 'unavailable'
                : reviewPage?.items.length
                  ? 'on-file'
                  : 'none'
            return {
              employee,
              score: Number.isFinite(score) ? score : null,
              scoreState,
              reviewState,
            }
          }),
        )
        people.push(...batchResults)
      }
      return {
        people,
        count: assigned.length,
        hasPartialFailure: people.some(
          (person) => person.scoreState === 'unavailable' || person.reviewState === 'unavailable',
        ),
      }
    },
    enabled: Boolean(
      role &&
      activeTab === 'performance-analytics' &&
      hasPermission(permissions, 'employees', 'list'),
    ),
    staleTime: DATA_FRESHNESS_MS.standard,
  })
  const saveSection = useMutation({
    mutationFn: ({
      record,
      input,
    }: {
      record: SectionRecord | null
      input: Record<string, unknown>
    }) =>
      record
        ? rolesApi.updateSection(roleId, spec!.path!, record.id, input)
        : rolesApi.createSection(roleId, spec!.path!, input),
    onSuccess: async () => {
      await queryClient.invalidateQueries({
        queryKey: rolesQueryKeys.section(userId, employeeId, roleId, spec?.path ?? ''),
      })
      if (spec?.tab === 'org-chart') {
        await queryClient.invalidateQueries({
          queryKey: rolesQueryKeys.reportingChart(userId, employeeId, roleId),
        })
      }
      showToast({
        tone: 'success',
        title: itemDraft ? 'Role item updated' : 'Role item added',
        description: 'The role standard is up to date.',
      })
      setEditorOpen(false)
      setItemDraft(null)
    },
  })
  const removeSection = useMutation({
    mutationFn: (record: SectionRecord) => rolesApi.removeSection(roleId, spec!.path!, record.id),
    onSuccess: async () => {
      await queryClient.invalidateQueries({
        queryKey: rolesQueryKeys.section(userId, employeeId, roleId, spec?.path ?? ''),
      })
      if (spec?.tab === 'org-chart') {
        await queryClient.invalidateQueries({
          queryKey: rolesQueryKeys.reportingChart(userId, employeeId, roleId),
        })
      }
      showToast({ tone: 'success', title: 'Role item removed' })
      setDeleteTarget(null)
    },
  })
  const saveRole = useMutation({
    mutationFn: (input: Parameters<typeof rolesApi.update>[1]) => rolesApi.update(roleId, input),
    onSuccess: async (updated) => {
      queryClient.setQueryData(rolesQueryKeys.detail(userId, employeeId, roleId), updated)
      await queryClient.invalidateQueries({ queryKey: rolesQueryKeys.all })
      showToast({
        tone: 'success',
        title: 'Role updated',
        description: `${updated.name} was saved.`,
      })
      setEditRoleOpen(false)
    },
  })
  const removeRole = useMutation({
    mutationFn: () => rolesApi.remove(roleId),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: rolesQueryKeys.all })
      showToast({ tone: 'success', title: 'Role deleted' })
      await navigate({ to: '/company/roles' })
    },
  })
  const records = sectionQuery.data ? unwrapPage(sectionQuery.data) : []

  if (!canView)
    return (
      <PageLayout title="Role details" actionsInline>
        <Card>
          <EmptyState
            title="Role details are restricted"
            description="Your account can manage the role directory, but it does not have permission to view role details."
            action={
              <Link to="/company/roles" className="text-primary text-caption font-semibold">
                Back to roles
              </Link>
            }
          />
        </Card>
      </PageLayout>
    )

  return (
    <PageLayout
      title={role?.name ?? 'Role details'}
      actionsInline
      backLink={
        <Link
          to="/company/roles"
          aria-label="Back to roles"
          className="text-text-secondary hover:text-primary rounded-control focus-visible:shadow-focus-ring inline-flex size-9 items-center justify-center focus-visible:outline-none"
        >
          <ArrowLeft className="size-4" aria-hidden="true" />
        </Link>
      }
      actions={
        role ? (
          <div className="flex gap-2">
            {canEditRole ? (
              <Button
                variant="outline"
                aria-label="Edit role"
                onClick={() => {
                  saveRole.reset()
                  setEditRoleInitialStep('details')
                  setEditRoleOpen(true)
                }}
                className="max-[479px]:text-caption max-[479px]:min-h-9 max-[479px]:px-3"
              >
                <span className="max-[479px]:hidden">Edit role</span>
                <span className="hidden max-[479px]:inline max-[361px]:hidden">Edit</span>
              </Button>
            ) : null}
            {canDeleteRole ? (
              <Button
                variant="danger"
                aria-label="Delete role"
                onClick={() => {
                  removeRole.reset()
                  setDeleteRoleOpen(true)
                }}
                className="max-[479px]:text-caption max-[479px]:min-h-9 max-[479px]:px-3"
              >
                <span className="max-[479px]:hidden">Delete role</span>
                <span className="hidden max-[479px]:inline max-[361px]:hidden">Delete</span>
              </Button>
            ) : null}
          </div>
        ) : null
      }
    >
      <div className="space-y-5">
        {roleQuery.isPending && !role ? (
          <div role="status" aria-label="Loading role details" className="space-y-3">
            <Skeleton variant="card" />
            <Skeleton variant="card" />
          </div>
        ) : null}
        {roleQuery.isError && !role ? (
          <ErrorState
            title="Role details could not load"
            description="Try again, or return to the role directory."
            error={roleQuery.error}
            action={
              <Button variant="outline" onClick={() => void roleQuery.refetch()}>
                Try again
              </Button>
            }
          />
        ) : null}
        {roleQuery.isError && role ? (
          <SectionErrorState
            title="Role refresh failed"
            description="Showing the last loaded role details."
            onRetry={() => void roleQuery.refetch()}
          />
        ) : null}
        {role ? (
          <>
            <Card className="p-0">
              <nav
                aria-label="Role detail sections"
                role="tablist"
                className="bg-surface-muted desktop:grid-cols-4 tablet:grid-cols-3 grid min-w-0 grid-cols-2 gap-1.5 p-2"
              >
                {visibleTabs.map((tab, index) => (
                  <button
                    key={tab.id}
                    id={`role-detail-tab-${tab.id}`}
                    type="button"
                    role="tab"
                    aria-selected={activeTab === tab.id}
                    aria-controls="role-detail-panel"
                    tabIndex={activeTab === tab.id ? 0 : -1}
                    onClick={() => selectTab(tab.id)}
                    onKeyDown={(event) => {
                      let nextIndex: number | null = null
                      if (event.key === 'ArrowRight' || event.key === 'ArrowDown') {
                        nextIndex = (index + 1) % visibleTabs.length
                      }
                      if (event.key === 'ArrowLeft' || event.key === 'ArrowUp') {
                        nextIndex = (index + visibleTabs.length - 1) % visibleTabs.length
                      }
                      if (event.key === 'Home') nextIndex = 0
                      if (event.key === 'End') nextIndex = visibleTabs.length - 1
                      if (nextIndex === null) return
                      event.preventDefault()
                      const nextTab = visibleTabs[nextIndex]
                      selectTab(nextTab.id)
                      document.getElementById(`role-detail-tab-${nextTab.id}`)?.focus()
                    }}
                    className={`rounded-control focus-visible:shadow-focus-ring flex min-h-11 min-w-0 items-center gap-2 px-2 py-2 text-left font-semibold transition-colors focus-visible:outline-none sm:px-3 ${activeTab === tab.id ? 'bg-surface text-primary shadow-elevation-sm' : 'text-text-secondary hover:bg-surface/70'}`}
                  >
                    <span className="text-primary rounded-control bg-primary-subtle flex size-7 shrink-0 items-center justify-center">
                      {tab.icon}
                    </span>
                    <span className="text-caption min-w-0 flex-1 leading-snug break-words">
                      {tab.label}
                    </span>
                  </button>
                ))}
              </nav>
            </Card>
            <div
              id="role-detail-panel"
              role="tabpanel"
              aria-labelledby={`role-detail-tab-${activeTab}`}
              tabIndex={0}
              className="min-w-0 space-y-5 focus-visible:outline-none"
            >
              {activeTab === 'overview' ? (
                <div className="desktop:grid-cols-2 grid min-w-0 gap-5">
                  <Card className="tablet:p-5 space-y-4 p-4">
                    <div className="flex items-center gap-3">
                      <span className="bg-primary-subtle text-primary rounded-control flex size-10 items-center justify-center">
                        <BriefcaseBusiness className="size-5" />
                      </span>
                      <div>
                        <p className="text-caption text-primary font-semibold">Role overview</p>
                        <h2 className="text-h2 font-semibold">{role.name}</h2>
                      </div>
                    </div>
                    <p className="text-body-sm text-text-secondary">
                      {role.branches.length
                        ? `Applies to ${role.branches.map((branch) => branch.branch_name).join(', ')}.`
                        : 'Applies company-wide.'}
                    </p>
                    <div className="grid gap-3 sm:grid-cols-2">
                      <Summary
                        label="Permission areas"
                        value={Object.keys(role.permissions).length}
                      />
                      <Summary
                        label="Granted actions"
                        value={Object.values(role.permissions).reduce(
                          (sum, actions) => sum + actions.length,
                          0,
                        )}
                      />
                    </div>
                  </Card>
                  {hasPermission(permissions, 'role_descriptions', 'view') ? (
                    <Card className="tablet:p-5 space-y-4 p-4">
                      <div>
                        <p className="text-caption text-primary font-semibold">Role definition</p>
                        <h2 className="text-h2 font-semibold">Purpose and responsibilities</h2>
                      </div>
                      {descriptionQuery.isPending && !descriptionQuery.data ? (
                        <Skeleton variant="card" />
                      ) : null}
                      {descriptionQuery.isError ? (
                        <RoleDescriptionLoadState
                          error={descriptionQuery.error}
                          onRetry={() => void descriptionQuery.refetch()}
                        />
                      ) : null}
                      {descriptionHasContent && descriptionQuery.data ? (
                        <div className="space-y-4">
                          {descriptionQuery.data.purpose.trim() ? (
                            <Definition label="Purpose" value={descriptionQuery.data.purpose} />
                          ) : null}
                          {descriptionQuery.data.responsibilities.trim() ? (
                            <Definition
                              label="Responsibilities"
                              value={descriptionQuery.data.responsibilities}
                            />
                          ) : null}
                          {descriptionQuery.data.job_description.trim() ? (
                            <Definition
                              label="Job description"
                              value={descriptionQuery.data.job_description}
                            />
                          ) : null}
                        </div>
                      ) : null}
                      {descriptionQuery.isSuccess && !descriptionHasContent ? (
                        <EmptyState
                          title="No role description yet"
                          description="Purpose and responsibilities have not been added for this role."
                          className="min-h-0 px-1 py-2"
                          action={
                            canEditRoleDescription ? (
                              <Button
                                size="sm"
                                variant="outline"
                                onClick={() => {
                                  saveRole.reset()
                                  setEditRoleInitialStep('details')
                                  setEditRoleOpen(true)
                                }}
                              >
                                Add role description
                              </Button>
                            ) : undefined
                          }
                        />
                      ) : null}
                    </Card>
                  ) : null}
                  <Card className="tablet:p-5 desktop:col-span-2 space-y-4 p-4">
                    <div className="flex min-w-0 items-start justify-between gap-3">
                      <div className="min-w-0">
                        <p className="text-caption text-primary font-semibold">Access design</p>
                        <h2 className="text-h2 font-semibold">Permissions by area</h2>
                      </div>
                      {canEditRole ? (
                        <Button
                          size="sm"
                          variant="outline"
                          aria-label="Edit permissions"
                          leadingIcon={<Pencil className="size-4" aria-hidden="true" />}
                          onClick={() => {
                            saveRole.reset()
                            setEditRoleInitialStep('permissions')
                            setEditRoleOpen(true)
                          }}
                          className="max-[479px]:text-caption max-[479px]:min-h-9 max-[479px]:px-2.5"
                        >
                          <span className="max-[479px]:hidden">Edit permissions</span>
                          <span className="hidden max-[479px]:inline">Edit</span>
                        </Button>
                      ) : null}
                    </div>
                    <RolePermissionSummary groups={groupRolePermissions(role.permissions)} />
                  </Card>
                </div>
              ) : null}
              {activeTab === 'performance-analytics' ? (
                <Card className="tablet:p-5 space-y-4 p-4">
                  <div>
                    <p className="text-caption text-primary font-semibold">Performance Analytics</p>
                    <h2 className="text-h2 font-semibold">Team performance</h2>
                    <p className="text-caption text-text-secondary mt-1">
                      Monthly scorecards and recorded performance reviews for employees in this
                      role.
                    </p>
                  </div>
                  {!hasPermission(permissions, 'employees', 'list') ? (
                    <EmptyState
                      title="Employee analytics are restricted"
                      description="Your role does not include employee directory access."
                    />
                  ) : null}
                  {employeeAnalyticsQuery.isPending && !employeeAnalyticsQuery.data ? (
                    <div className="space-y-3" role="status" aria-label="Loading role analytics">
                      <Skeleton variant="card" />
                      <Skeleton variant="card" />
                    </div>
                  ) : null}
                  {employeeAnalyticsQuery.isError && !employeeAnalyticsQuery.data ? (
                    <SectionErrorState
                      title="Role analytics could not load"
                      error={employeeAnalyticsQuery.error}
                      onRetry={() => void employeeAnalyticsQuery.refetch()}
                    />
                  ) : null}
                  {employeeAnalyticsQuery.isError && employeeAnalyticsQuery.data ? (
                    <SectionErrorState
                      title="Performance details could not refresh"
                      description="Showing the last loaded results."
                      onRetry={() => void employeeAnalyticsQuery.refetch()}
                    />
                  ) : null}
                  {employeeAnalyticsQuery.data ? (
                    <PerformancePeople
                      records={employeeAnalyticsQuery.data.people}
                      count={employeeAnalyticsQuery.data.count}
                      canViewEmployees={hasPermission(permissions, 'employees', 'view')}
                      canReadScorecards={canReadScorecards}
                      canReadReviews={canReadReviews}
                      hasPartialFailure={employeeAnalyticsQuery.data.hasPartialFailure}
                      onRetry={() => void employeeAnalyticsQuery.refetch()}
                    />
                  ) : null}
                </Card>
              ) : null}
              {activeTab === 'org-chart' && canReadSection ? (
                <Card className="tablet:p-5 space-y-4 p-4">
                  <div>
                    <p className="text-caption text-primary font-semibold">Reporting structure</p>
                    <h2 className="text-h2 font-semibold">Where this role sits</h2>
                  </div>
                  {reportingChartQuery.isPending && !reportingChartQuery.data ? (
                    <Skeleton variant="card" />
                  ) : null}
                  {reportingChartQuery.isError && !reportingChartQuery.data ? (
                    <SectionErrorState
                      title="Reporting structure could not load"
                      error={reportingChartQuery.error}
                      onRetry={() => void reportingChartQuery.refetch()}
                    />
                  ) : null}
                  {reportingChartQuery.data ? (
                    <ReportingStructure
                      chain={reportingChartQuery.data[0].chain}
                      directReports={reportingChartQuery.data[1].direct_reports}
                    />
                  ) : null}
                </Card>
              ) : null}
              {spec ? (
                <Card className="tablet:p-5 space-y-4 p-4">
                  <div className="flex flex-wrap items-start justify-between gap-3">
                    <div className="min-w-0">
                      <p className="text-caption text-primary font-semibold">Role standards</p>
                      <h2 className="text-h2 font-semibold">{spec.title}</h2>
                      <p className="text-caption text-text-secondary mt-1">
                        {spec.tab === 'org-chart'
                          ? `Reporting lines for ${role.name}.`
                          : `Standards assigned to ${role.name}.`}
                      </p>
                    </div>
                    {hasPermission(permissions, spec.resource!, 'create') ? (
                      <Button
                        aria-label={spec.addLabel ?? `Add ${spec.label.toLocaleLowerCase()}`}
                        leadingIcon={<Plus className="size-4" />}
                        onClick={() => {
                          saveSection.reset()
                          setItemDraft(null)
                          setEditorOpen(true)
                        }}
                        className="max-[479px]:text-caption max-[479px]:min-h-9 max-[479px]:px-3"
                      >
                        <span className="max-[479px]:hidden">
                          {spec.addLabel ?? `Add ${spec.label.toLocaleLowerCase()}`}
                        </span>
                        <span className="hidden max-[479px]:inline max-[361px]:hidden">New</span>
                      </Button>
                    ) : null}
                  </div>
                  {!canReadSection ? (
                    <EmptyState
                      title="This section is restricted"
                      description={`Your account does not have permission to list ${spec.label.toLocaleLowerCase()}.`}
                    />
                  ) : null}
                  {sectionQuery.isPending && !sectionQuery.data && canReadSection ? (
                    <div className="space-y-3" role="status" aria-label={`Loading ${spec.label}`}>
                      <Skeleton variant="card" />
                      <Skeleton variant="card" />
                    </div>
                  ) : null}
                  {sectionQuery.isError && !sectionQuery.data ? (
                    <SectionErrorState
                      title={`${spec.label} could not load`}
                      error={sectionQuery.error}
                      onRetry={() => void sectionQuery.refetch()}
                    />
                  ) : null}
                  {sectionQuery.isError && sectionQuery.data ? (
                    <SectionErrorState
                      title={`${spec.label} refresh failed`}
                      description="Showing the last loaded items."
                      onRetry={() => void sectionQuery.refetch()}
                    />
                  ) : null}
                  {records.length ? (
                    <DataGrid
                      records={records}
                      spec={spec}
                      canEdit={hasPermission(permissions, spec.resource!, 'update')}
                      canDelete={hasPermission(permissions, spec.resource!, 'delete')}
                      onEdit={(record) => {
                        saveSection.reset()
                        setItemDraft(record)
                        setEditorOpen(true)
                      }}
                      onDelete={(record) => {
                        removeSection.reset()
                        setDeleteTarget(record)
                      }}
                    />
                  ) : null}
                  {canReadSection &&
                  !sectionQuery.isPending &&
                  !sectionQuery.isError &&
                  records.length === 0 ? (
                    <EmptyState
                      title={`No ${spec.itemName ? `${spec.itemName}s` : spec.label.toLocaleLowerCase()} yet`}
                      description={`This role has no assigned ${spec.itemName ?? spec.label.toLocaleLowerCase()}${spec.itemName ? 's' : ''}.`}
                      className="min-h-0 px-2 py-5"
                    />
                  ) : null}
                  {records.length ? (
                    <div className="border-border-subtle text-caption text-text-secondary border-t pt-3">
                      {records.length} {records.length === 1 ? 'item' : 'items'}
                    </div>
                  ) : null}
                </Card>
              ) : null}
            </div>
          </>
        ) : null}
      </div>
      {role && spec && editorOpen ? (
        <ResourceEditor
          key={`${spec.path}:${itemDraft?.id ?? 'new'}`}
          open={editorOpen}
          spec={spec}
          record={itemDraft}
          roleChoices={(roleListQuery.data?.items ?? []).map(({ id, name }) => ({ id, name }))}
          currentRoleId={role.id}
          roleChoicesLoading={roleListQuery.isPending}
          roleChoicesError={roleListQuery.error}
          onRetryRoleChoices={() => void roleListQuery.refetch()}
          kpiMetricChoices={kpiMetricChoicesQuery.data ?? []}
          kpiMetricChoicesLoading={canListKpiMetrics && kpiMetricChoicesQuery.isPending}
          kpiMetricChoicesError={kpiMetricChoicesQuery.error}
          assignedMetricIds={records
            .map((record) => Number(record.metric_id))
            .filter(Number.isFinite)}
          canListKpiMetrics={canListKpiMetrics}
          onRetryKpiMetricChoices={() => void kpiMetricChoicesQuery.refetch()}
          trainingProgramChoices={trainingProgramChoicesQuery.data ?? []}
          trainingProgramChoicesLoading={
            canListTrainingPrograms && trainingProgramChoicesQuery.isPending
          }
          trainingProgramChoicesError={trainingProgramChoicesQuery.error}
          canListTrainingPrograms={canListTrainingPrograms}
          onRetryTrainingProgramChoices={() => void trainingProgramChoicesQuery.refetch()}
          sopChoices={sopChoicesQuery.data ?? []}
          sopChoicesLoading={sopChoicesQuery.isPending}
          sopChoicesError={sopChoicesQuery.error}
          canListSops={canListSops}
          onRetrySopChoices={() => void sopChoicesQuery.refetch()}
          onClose={() => {
            if (!saveSection.isPending) {
              setEditorOpen(false)
              setItemDraft(null)
            }
          }}
          onSave={(input) => saveSection.mutate({ record: itemDraft, input })}
          saving={saveSection.isPending}
          error={saveSection.error}
        />
      ) : null}
      {role && canEditRole && editRoleOpen ? (
        <RoleEditor
          key={role.id}
          open={editRoleOpen}
          role={role}
          initialStep={editRoleInitialStep}
          onClose={() => {
            if (!saveRole.isPending) setEditRoleOpen(false)
          }}
          permissions={permissionQuery.data?.permissions_map ?? EMPTY_PERMISSIONS}
          branches={branchQuery.data?.items ?? []}
          branchChoicesLoaded={branchQuery.data !== undefined}
          branchChoicesLoading={branchQuery.isPending}
          branchChoicesError={branchQuery.error}
          onRetryBranches={() => void branchQuery.refetch()}
          canEditDescription={
            hasPermission(permissions, 'role_descriptions', 'update') &&
            hasPermission(permissions, 'role_descriptions', 'view')
          }
          canViewDescription={hasPermission(permissions, 'role_descriptions', 'view')}
          permissionMapLoaded={permissionQuery.data !== undefined}
          permissionMapLoading={permissionQuery.isPending}
          permissionMapError={permissionQuery.error}
          onRetryPermissionMap={() => void permissionQuery.refetch()}
          onSave={(input) => saveRole.mutate(input)}
          isSaving={saveRole.isPending}
          error={saveRole.error}
        />
      ) : null}
      <Dialog
        open={Boolean(deleteTarget)}
        onOpenChange={(open) => {
          if (!open && !removeSection.isPending) setDeleteTarget(null)
        }}
        title="Remove role item"
        description="This removes the item from this role's standards."
        size="sm"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button
              variant="outline"
              onClick={() => setDeleteTarget(null)}
              disabled={removeSection.isPending}
            >
              Keep item
            </Button>
            <Button
              variant="danger"
              onClick={() => deleteTarget && removeSection.mutate(deleteTarget)}
              isLoading={removeSection.isPending}
            >
              Remove item
            </Button>
          </>
        }
      >
        {removeSection.error ? (
          <Alert tone="danger" role="alert" title="Item could not be removed">
            Try again, or keep this item assigned.
          </Alert>
        ) : (
          <p className="text-body-sm text-text-secondary">
            Remove{' '}
            <strong className="text-text-primary">
              {deleteTarget && spec ? bestRecordLabel(deleteTarget, spec) : 'this item'}
            </strong>
            ?
          </p>
        )}
      </Dialog>
      <Dialog
        open={deleteRoleOpen}
        onOpenChange={(open) => {
          if (!open && !removeRole.isPending) setDeleteRoleOpen(false)
        }}
        title="Delete role"
        description="This removes the role and its linked role standards. Employees assigned to it may need a replacement role."
        size="sm"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button
              variant="outline"
              onClick={() => setDeleteRoleOpen(false)}
              disabled={removeRole.isPending}
            >
              Keep role
            </Button>
            <Button
              variant="danger"
              onClick={() => removeRole.mutate()}
              isLoading={removeRole.isPending}
            >
              Delete role
            </Button>
          </>
        }
      >
        {removeRole.error ? (
          <Alert tone="danger" role="alert" title="Role could not be deleted">
            It may still be assigned or referenced. Resolve that first and retry.
          </Alert>
        ) : (
          <p className="text-body-sm text-text-secondary">
            Delete <strong className="text-text-primary">{role?.name}</strong>?
          </p>
        )}
      </Dialog>
    </PageLayout>
  )
}

function RoleDescriptionLoadState({ error, onRetry }: { error: unknown; onRetry: () => void }) {
  const presentation = presentError(error, 'section-load')
  const forbidden = error instanceof ApiError && error.status === 403

  return (
    <div
      role="status"
      className="border-border-subtle bg-surface-muted/40 rounded-control flex flex-wrap items-center justify-between gap-3 border p-3"
    >
      <div className="flex min-w-0 items-start gap-3">
        <span
          className={`${forbidden ? 'bg-info-subtle text-info-foreground' : 'bg-warning-subtle text-warning-foreground'} rounded-control flex size-9 shrink-0 items-center justify-center`}
        >
          <CircleAlert className="size-4" aria-hidden="true" />
        </span>
        <div className="min-w-0">
          <p className="text-label font-semibold">
            {forbidden ? 'Role definition is restricted' : 'Role definition could not load'}
          </p>
          <p className="text-caption text-text-secondary mt-0.5">{presentation.message}</p>
        </div>
      </div>
      {!forbidden && presentation.retryable ? (
        <Button variant="outline" size="sm" onClick={onRetry} className="shrink-0">
          Try again
        </Button>
      ) : null}
    </div>
  )
}

function Summary({ label, value }: { label: string; value: number | string }) {
  return (
    <div className="bg-surface-muted rounded-control p-3">
      <p className="text-caption text-text-secondary">{label}</p>
      <p className="text-h3 mt-1 font-semibold">{value}</p>
    </div>
  )
}
function Definition({ label, value }: { label: string; value?: string }) {
  return (
    <div>
      <h3 className="text-label font-semibold">{label}</h3>
      <p className="text-body-sm text-text-secondary mt-1 whitespace-pre-wrap">
        {value?.trim() || 'Not provided'}
      </p>
    </div>
  )
}
function PerformancePeople({
  records,
  count,
  canViewEmployees,
  canReadScorecards,
  canReadReviews,
  hasPartialFailure,
  onRetry,
}: {
  records: PerformancePerson[]
  count: number
  canViewEmployees: boolean
  canReadScorecards: boolean
  canReadReviews: boolean
  hasPartialFailure: boolean
  onRetry: () => void
}) {
  const scored = records.filter((item) => item.scoreState === 'available' && item.score != null)
  const scoreUnavailableCount = records.filter((item) => item.scoreState === 'unavailable').length
  const reviewUnavailableCount = records.filter((item) => item.reviewState === 'unavailable').length
  const currentMonth = new Intl.DateTimeFormat(undefined, {
    month: 'long',
    year: 'numeric',
  }).format(new Date())
  const average = scored.length
    ? Math.round(scored.reduce((total, item) => total + (item.score ?? 0), 0) / scored.length)
    : null
  const reviewCount = records.filter((item) => item.reviewState === 'on-file').length
  return count ? (
    <div className="space-y-5">
      <div className="desktop:grid-cols-2 phone:grid-cols-2 wide:grid-cols-4 grid gap-3">
        <PerformanceMetric
          icon={<BriefcaseBusiness className="size-4" aria-hidden="true" />}
          label="Employees in role"
          value={count}
          detail="Active team members"
        />
        <PerformanceMetric
          icon={<ClipboardList className="size-4" aria-hidden="true" />}
          label="Scored this month"
          value={canReadScorecards ? `${scored.length} / ${count}` : 'Restricted'}
          detail={
            canReadScorecards
              ? scoreUnavailableCount
                ? `${scoreUnavailableCount} scorecards unavailable`
                : `Scorecards · ${currentMonth}`
              : 'Scorecard access required'
          }
        />
        <PerformanceMetric
          icon={<ChartNoAxesCombined className="size-4" aria-hidden="true" />}
          label="Average score"
          value={canReadScorecards ? (average == null ? '—' : `${average}%`) : 'Restricted'}
          detail={
            canReadScorecards ? `${scored.length} scored team members` : 'Scorecard access required'
          }
        />
        <PerformanceMetric
          icon={<ShieldCheck className="size-4" aria-hidden="true" />}
          label="Reviews on file"
          value={canReadReviews ? `${reviewCount} / ${count}` : 'Restricted'}
          detail={
            canReadReviews
              ? reviewUnavailableCount
                ? `${reviewUnavailableCount} review records unavailable`
                : 'Latest recorded reviews'
              : 'Review access required'
          }
        />
      </div>
      {hasPartialFailure ? (
        <SectionErrorState
          title="Some performance details could not load"
          description="Other employee results are still available. Retry to refresh the missing details."
          onRetry={onRetry}
        />
      ) : null}
      <section className="border-border-subtle bg-surface rounded-control overflow-hidden border">
        <header className="bg-surface-muted border-border-subtle flex flex-wrap items-center justify-between gap-3 border-b px-4 py-3">
          <div className="min-w-0">
            <h3 className="text-label font-semibold">Individual performance</h3>
            <p className="text-caption text-text-secondary mt-0.5">
              Current month · {currentMonth}
            </p>
          </div>
          <StatusChip
            label={`${count} ${count === 1 ? 'employee' : 'employees'}`}
            tone="primary"
            dense
          />
        </header>
        <div className="divide-border-subtle divide-y">
          {records.map(({ employee, score, scoreState, reviewState }) => {
            const name = canViewEmployees
              ? `${employee.first_name} ${employee.last_name}`.trim()
              : 'Assigned employee'
            const initials = name
              .split(/\s+/)
              .filter(Boolean)
              .slice(0, 2)
              .map((part) => part[0]?.toLocaleUpperCase())
              .join('')
            const scoreTone =
              score == null
                ? 'neutral'
                : score >= 85
                  ? 'success'
                  : score >= 70
                    ? 'warning'
                    : 'danger'
            return (
              <article
                key={employee.user_id}
                className="desktop:grid-cols-[minmax(0,1fr)_minmax(150px,0.55fr)_auto] desktop:items-center grid min-w-0 gap-4 p-4"
              >
                <div className="flex min-w-0 items-center gap-3">
                  <span className="bg-primary-subtle text-primary rounded-pill text-caption flex size-10 shrink-0 items-center justify-center font-semibold">
                    {canViewEmployees ? initials || '—' : '•'}
                  </span>
                  <div className="min-w-0">
                    <p className="text-label truncate font-semibold">{name}</p>
                    <p className="text-caption text-text-secondary mt-0.5 truncate">
                      {canViewEmployees
                        ? `${employee.designation || 'Position not set'} · ${employee.employee_id}`
                        : 'Role performance record'}
                    </p>
                    {canViewEmployees && (employee.department_name || employee.branch_name) ? (
                      <p className="text-overline text-text-muted mt-1 truncate">
                        {[employee.department_name, employee.branch_name]
                          .filter(Boolean)
                          .join(' · ')}
                      </p>
                    ) : null}
                  </div>
                </div>
                <div className="min-w-0">
                  <div className="mb-1.5 flex items-center justify-between gap-2">
                    <span className="text-caption text-text-secondary">Monthly score</span>
                    {canReadScorecards ? (
                      <StatusChip
                        label={
                          scoreState === 'unavailable'
                            ? 'Unavailable'
                            : score == null
                              ? 'Not scored'
                              : `${Math.round(score)}%`
                        }
                        tone={scoreTone}
                        dense
                      />
                    ) : (
                      <StatusChip label="Restricted" tone="neutral" dense />
                    )}
                  </div>
                  {canReadScorecards && score != null ? (
                    <div
                      role="progressbar"
                      aria-label={`${name} monthly score`}
                      aria-valuemin={0}
                      aria-valuemax={100}
                      aria-valuenow={Math.min(100, Math.max(0, score))}
                      className="bg-surface-muted h-1.5 overflow-hidden rounded-full"
                    >
                      <span
                        className={`block h-full rounded-full ${scoreTone === 'success' ? 'bg-success' : scoreTone === 'warning' ? 'bg-warning' : 'bg-danger'}`}
                        style={{ width: `${Math.min(100, Math.max(0, score))}%` }}
                      />
                    </div>
                  ) : (
                    <p className="text-overline text-text-muted">
                      {canReadScorecards
                        ? scoreState === 'unavailable'
                          ? 'Scorecard could not be loaded'
                          : 'No scorecard for this month'
                        : 'Scorecard access required'}
                    </p>
                  )}
                </div>
                <div className="desktop:justify-end flex min-w-0 flex-wrap items-center justify-between gap-3">
                  {canReadReviews ? (
                    <StatusChip
                      label={
                        reviewState === 'unavailable'
                          ? 'Review unavailable'
                          : reviewState === 'on-file'
                            ? 'Review on file'
                            : 'No review on file'
                      }
                      tone={reviewState === 'on-file' ? 'success' : 'neutral'}
                      dense
                    />
                  ) : null}
                  {canViewEmployees ? (
                    <Link
                      className="text-primary text-caption inline-flex min-h-10 items-center font-semibold"
                      to="/hr/employees/$userId"
                      params={{ userId: String(employee.user_id) }}
                    >
                      View profile
                    </Link>
                  ) : null}
                </div>
              </article>
            )
          })}
        </div>
      </section>
    </div>
  ) : (
    <EmptyState
      title="No active employees in this role"
      description="Employees assigned to this role will appear here."
    />
  )
}

function PerformanceMetric({
  icon,
  label,
  value,
  detail,
}: {
  icon: ReactNode
  label: string
  value: number | string
  detail: string
}) {
  return (
    <div className="border-border-subtle bg-surface rounded-control shadow-elevation-sm flex min-w-0 items-start gap-3 border p-3">
      <span className="bg-primary-subtle text-primary rounded-control flex size-9 shrink-0 items-center justify-center">
        {icon}
      </span>
      <div className="min-w-0">
        <p className="text-caption text-text-secondary">{label}</p>
        <p className="text-h3 mt-0.5 font-semibold tabular-nums">{value}</p>
        <p className="text-overline text-text-muted mt-1 leading-snug break-words">{detail}</p>
      </div>
    </div>
  )
}

function ReportingStructure({
  chain,
  directReports,
}: {
  chain: RoleReportingNodeDto[]
  directReports: RoleReportingNodeDto[]
}) {
  return chain.length || directReports.length ? (
    <div className="tablet:grid-cols-2 grid min-w-0 gap-4">
      <section className="bg-surface-muted border-border-subtle rounded-control min-w-0 border p-4">
        <h3 className="text-label font-semibold">Reports to</h3>
        <p className="text-caption text-text-secondary mt-1">
          Management and escalation path for this role.
        </p>
        {chain.length ? (
          <ol className="mt-3 space-y-2">
            {chain.map((line) => (
              <li
                key={line.id}
                className="bg-surface border-border-subtle rounded-control border p-3"
              >
                <p className="text-body-sm font-semibold">{line.reports_to_role.name}</p>
                <p className="text-caption text-text-secondary mt-1">
                  {labelize(line.relationship_type)} relationship
                </p>
                {line.cycle_detected ? (
                  <StatusChip className="mt-2" label="Cycle detected" tone="danger" dense />
                ) : null}
              </li>
            ))}
          </ol>
        ) : (
          <p className="text-body-sm text-text-secondary mt-3">No reporting manager is defined.</p>
        )}
      </section>
      <section className="bg-surface-muted border-border-subtle rounded-control min-w-0 border p-4">
        <h3 className="text-label font-semibold">Direct reports</h3>
        <p className="text-caption text-text-secondary mt-1">
          Roles reporting directly to this position.
        </p>
        {directReports.length ? (
          <ul className="mt-3 space-y-2">
            {directReports.map((node) => (
              <ReportingNode key={node.id} node={node} />
            ))}
          </ul>
        ) : (
          <p className="text-body-sm text-text-secondary mt-3">No direct reports are defined.</p>
        )}
      </section>
    </div>
  ) : (
    <EmptyState
      title="No reporting relationships"
      description="No management or direct-report links are assigned to this role."
      className="min-h-0 px-2 py-5"
    />
  )
}

function ReportingNode({ node, depth = 0 }: { node: RoleReportingNodeDto; depth?: number }) {
  return (
    <li className="space-y-2">
      <div
        className="bg-surface border-border-subtle rounded-control border p-3"
        style={{ marginInlineStart: `${Math.min(depth, 4) * 12}px` }}
      >
        <p className="text-body-sm font-semibold">{node.role.name}</p>
        <p className="text-caption text-text-secondary mt-1">
          {labelize(node.relationship_type)} relationship
          {node.cycle_detected ? ' · Cycle detected' : ''}
        </p>
      </div>
      {node.children?.length ? (
        <ul className="space-y-2">
          {node.children.map((child) => (
            <ReportingNode key={child.id} node={child} depth={depth + 1} />
          ))}
        </ul>
      ) : null}
    </li>
  )
}
