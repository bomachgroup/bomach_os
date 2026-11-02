import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useParams, useSearch } from '@tanstack/react-router'
import {
  Activity,
  ArrowUpRight,
  BriefcaseBusiness,
  CalendarClock,
  CalendarDays,
  Check,
  CircleDollarSign,
  ClipboardList,
  FileText,
  HeartPulse,
  MoreHorizontal,
  Pencil,
  Plus,
  Shield,
  Trash2,
  Upload,
  UserRound,
  Wallet,
} from 'lucide-react'
import { isValidElement, useMemo, useState, type FormEvent } from 'react'

import { auditLogApi, auditLogQueryKeys } from '@/modules/company/audit-log.api'
import {
  employeesApi,
  employeesQueryKeys,
  type EmployeeWriteInput,
  type EmployeeDocumentDto,
  type EmployeeLeavePeriodCreateInput,
  type EmployeeLeavePeriodDto,
  type EmployeeLeaveReturnInput,
  type EmployeePerformancePlanDto,
  type PerformancePlanItemDto,
  type EmployeeReviewDto,
} from '@/modules/hr/employees.api'
import { EmployeeEditor } from '@/modules/hr/routes/employees-page'
import { type EmployeeProfileSearch } from '@/modules/hr/employees.search'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { useToast } from '@/shared/feedback/use-toast'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { PageLayout } from '@/shared/ui/page-layout'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'
import { workReportsApi } from '@/modules/work-reports/work-reports.api'
import { workReportsQueryKeys } from '@/modules/work-reports/work-reports.queries'
import { EmployeeLeaveFormDialog } from '@/modules/hr/routes/employee-leave-form-dialog'

const DOCUMENT_MAX_BYTES = 15 * 1024 * 1024
const DOCUMENT_EXTENSIONS = new Set(['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'])
const REVIEW_RATINGS = [
  'job_knowledge',
  'communication',
  'problem_solving',
  'teamwork',
  'initiative',
  'quality_of_work',
] as const

function display(value: unknown): string {
  if (value === null || value === undefined || value === '') return 'Not provided'
  if (typeof value === 'boolean') return value ? 'Yes' : 'No'
  if (typeof value === 'object') return JSON.stringify(value, null, 2)
  return String(value)
}

function formatNaira(value: unknown): string {
  const amount = typeof value === 'number' ? value : Number(value)
  if (value === null || value === undefined || value === '' || !Number.isFinite(amount)) {
    return display(value)
  }
  return new Intl.NumberFormat('en-NG', {
    style: 'currency',
    currency: 'NGN',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amount)
}

function allowanceLabel(value: string): string {
  return value
    .replaceAll(/[_-]+/g, ' ')
    .replace(/\b\w/g, (character) => character.toLocaleUpperCase())
}

function allowanceEntries(value: Record<string, unknown> | null) {
  return Object.entries(value ?? {}).filter(([, amount]) => amount !== null && amount !== '')
}

function formatAllowance(value: unknown): string {
  if (typeof value === 'number' || (typeof value === 'string' && value.trim() !== '')) {
    const amount = Number(value)
    if (Number.isFinite(amount)) return formatNaira(amount)
  }
  return display(value)
}

function formatPercent(value: unknown): string {
  if (value === null || value === undefined || value === '') return 'Not provided'
  const numericValue = Number(value)
  return Number.isFinite(numericValue) ? `${numericValue}%` : String(value)
}

function formatDocumentDate(value: string): string {
  const date = new Date(value)
  return Number.isNaN(date.getTime())
    ? 'Date unavailable'
    : new Intl.DateTimeFormat('en-NG', { dateStyle: 'medium' }).format(date)
}

function formatDateOnly(value: string | null): string {
  if (!value) return 'Not scheduled'
  const date = new Date(`${value}T12:00:00`)
  return Number.isNaN(date.getTime())
    ? 'Date unavailable'
    : new Intl.DateTimeFormat('en-NG', { dateStyle: 'medium' }).format(date)
}

function formatStatus(value: string) {
  return value
    .replaceAll(/[-_]+/g, ' ')
    .replace(/\b\w/g, (character) => character.toLocaleUpperCase())
}

function salaryFrequencyPeriod(value: string): string {
  const normalized = value.toLowerCase().replaceAll(/[-_\s]+/g, '')
  const periods: Record<string, string> = {
    monthly: 'month',
    weekly: 'week',
    biweekly: 'two weeks',
    fortnightly: 'fortnight',
    daily: 'day',
    hourly: 'hour',
    annual: 'year',
    annually: 'year',
    yearly: 'year',
  }
  return periods[normalized] ?? 'pay period'
}

function taskStatusPresentation(status: string): { label: string; tone: StatusTone } {
  switch (status) {
    case 'pending':
      return { label: 'Pending', tone: 'warning' }
    case 'in_progress':
      return { label: 'In progress', tone: 'info' }
    case 'completed':
      return { label: 'Completed', tone: 'success' }
    case 'cancelled':
      return { label: 'Cancelled', tone: 'neutral' }
    default:
      return { label: formatStatus(status), tone: 'neutral' }
  }
}

function taskPriorityPresentation(priority: string): { label: string; tone: StatusTone } {
  switch (priority) {
    case 'high':
      return { label: 'High', tone: 'danger' }
    case 'medium':
      return { label: 'Medium', tone: 'warning' }
    case 'low':
      return { label: 'Low', tone: 'neutral' }
    case 'normal':
      return { label: 'Normal', tone: 'neutral' }
    default:
      return { label: priority ? formatStatus(priority) : 'Not set', tone: 'neutral' }
  }
}

function formatTaskDueDate(value: string | null): string {
  if (!value) return 'No due date'
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value)
  if (!match) return value
  const [, year, month, day] = match
  const date = new Date(Number(year), Number(month) - 1, Number(day))
  if (
    date.getFullYear() !== Number(year) ||
    date.getMonth() !== Number(month) - 1 ||
    date.getDate() !== Number(day)
  ) {
    return value
  }
  return new Intl.DateTimeFormat('en-NG', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(date)
}

function isTaskOverdue(task: { due_date: string | null; status: string }): boolean {
  if (!task.due_date || task.status === 'completed' || task.status === 'cancelled') return false
  const today = new Date()
  const todayKey = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`
  return /^\d{4}-\d{2}-\d{2}$/.test(task.due_date) && task.due_date < todayKey
}

function planItemTitle(item: PerformancePlanItemDto) {
  return item.config.name || item.config.title || 'Untitled performance item'
}

function planNumber(value: unknown) {
  if (value === null || value === undefined || value === '') return 'Not set'
  const numericValue = Number(value)
  return Number.isFinite(numericValue)
    ? new Intl.NumberFormat(undefined, { maximumFractionDigits: 2 }).format(numericValue)
    : String(value)
}

function planTarget(item: PerformancePlanItemDto) {
  const value = item.config.target_value
  if (value === null || value === undefined || value === '') return 'Not set'
  const formattedValue = planNumber(value)
  const unit = item.config.unit?.trim()
  const unitLabel = unit === 'percentage' ? '%' : unit ? ` ${unit}` : ''
  return `${formattedValue}${unitLabel}`
}

function planPeriodLabel(value: unknown) {
  if (typeof value !== 'string' || !value) return 'Not set'
  return value.replaceAll('_', ' ').replace(/\b\w/g, (character) => character.toLocaleUpperCase())
}

function PerformancePlanGroup({
  title,
  description,
  items,
  kind,
}: {
  title: string
  description: string
  items: PerformancePlanItemDto[]
  kind: 'kpi' | 'target'
}) {
  return (
    <section aria-label={title} className="min-w-0 space-y-3">
      <div className="flex flex-wrap items-start justify-between gap-2">
        <div>
          <h3 className="text-h3 font-semibold">{title}</h3>
          <p className="text-caption text-text-secondary mt-1">{description}</p>
        </div>
        <span className="bg-surface-muted text-caption text-text-secondary rounded-full px-2.5 py-1">
          {items.length} {items.length === 1 ? 'item' : 'items'}
        </span>
      </div>
      {items.length ? (
        <div className="grid min-w-0 gap-3">
          {items.map((item) => (
            <article
              key={item.item_key}
              className="bg-surface border-border-subtle rounded-control min-w-0 border p-4"
            >
              <div className="flex min-w-0 items-start justify-between gap-3">
                <div className="min-w-0">
                  <h4 className="text-body font-semibold break-words">{planItemTitle(item)}</h4>
                  {item.config.description ? (
                    <p className="text-caption text-text-secondary mt-1 break-words">
                      {item.config.description}
                    </p>
                  ) : null}
                </div>
                <StatusChip
                  label={item.config.is_active === false ? 'Inactive' : 'Active'}
                  tone={item.config.is_active === false ? 'neutral' : 'success'}
                  dense
                />
              </div>
              <dl className="mt-4 grid min-w-0 grid-cols-2 gap-3 sm:grid-cols-3">
                <DataField label="Target" value={planTarget(item)} />
                {kind === 'kpi' ? (
                  <DataField
                    label="Tracking"
                    value={
                      item.config.tracking_mode ? formatStatus(item.config.tracking_mode) : null
                    }
                  />
                ) : null}
                <DataField label="Review period" value={planPeriodLabel(item.config.period)} />
                {kind === 'kpi' ? (
                  <DataField label="Weight" value={planNumber(item.config.weight)} />
                ) : null}
              </dl>
            </article>
          ))}
        </div>
      ) : (
        <EmptyState
          title={`No ${kind === 'kpi' ? 'KPIs' : 'targets'} in this period`}
          description="Items assigned to this employee's role will appear here."
        />
      )}
    </section>
  )
}

function PerformancePlanView({ plan }: { plan: EmployeePerformancePlanDto }) {
  const startYear = plan.period_start.slice(0, 4)
  const endYear = plan.period_end.slice(0, 4)
  const periodLabel = startYear === endYear ? startYear : `${startYear}–${endYear}`
  const sourceLabel =
    plan.source === 'role_default'
      ? 'Role defaults'
      : plan.source === 'period_snapshot'
        ? 'Period snapshot'
        : 'Employee plan'

  return (
    <div className="space-y-5">
      <div className="bg-surface-muted border-border-subtle rounded-control flex min-w-0 flex-wrap items-center justify-between gap-3 border p-4">
        <div className="min-w-0">
          <p className="text-caption text-text-secondary">Plan period</p>
          <p className="text-body font-semibold">{periodLabel}</p>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <StatusChip label={sourceLabel} tone="primary" dense />
          {plan.revision !== null ? (
            <span className="bg-surface text-caption text-text-secondary border-border-subtle rounded-full border px-2.5 py-1">
              Revision {plan.revision}
            </span>
          ) : null}
        </div>
      </div>
      <div className="grid min-w-0 gap-6 xl:grid-cols-2">
        <PerformancePlanGroup
          title="Key performance indicators"
          description="Measures and review targets assigned to the employee's role."
          items={plan.kpis}
          kind="kpi"
        />
        <PerformancePlanGroup
          title="Performance targets"
          description="Outcome targets for the selected performance period."
          items={plan.targets}
          kind="target"
        />
      </div>
    </div>
  )
}

function DataField({ label, value }: { label: string; value: unknown }) {
  return (
    <div className="min-w-0">
      <dt className="text-caption text-text-secondary">{label}</dt>
      <dd className="text-body-sm text-text-primary mt-1 break-words">
        {isValidElement(value) ? value : display(value)}
      </dd>
    </div>
  )
}

function AllowanceBreakdown({ value }: { value: Record<string, unknown> | null }) {
  const entries = allowanceEntries(value)
  if (!entries.length) return <span>Not provided</span>

  return (
    <div className="grid min-w-0 grid-cols-1 gap-2 min-[560px]:grid-cols-2 2xl:grid-cols-3">
      {entries.map(([key, amount]) => (
        <div
          key={key}
          className="bg-surface-muted border-border-subtle rounded-control flex min-w-0 flex-col gap-1.5 border px-3 py-2.5"
        >
          <span className="text-caption text-text-secondary inline-flex min-w-0 items-center gap-1.5">
            <CircleDollarSign className="size-3.5 shrink-0" aria-hidden="true" />
            <span className="min-w-0 break-words">{allowanceLabel(key)}</span>
          </span>
          <span className="text-caption text-text-primary font-semibold tabular-nums">
            {formatAllowance(amount)}
          </span>
        </div>
      ))}
    </div>
  )
}

function ReviewEditor({
  open,
  review,
  onClose,
  onSave,
  saving,
  error,
}: {
  open: boolean
  review: EmployeeReviewDto | null
  onClose: () => void
  onSave: (input: Record<string, unknown>) => void
  saving: boolean
  error?: unknown
}) {
  const [quarter, setQuarter] = useState(
    review?.quarter ?? `Q${Math.ceil((new Date().getMonth() + 1) / 3)}`,
  )
  const [year, setYear] = useState(String(review?.year ?? new Date().getFullYear()))
  const [fields, setFields] = useState<Record<string, string>>(() =>
    Object.fromEntries(
      REVIEW_RATINGS.map((key) => [key, review?.[key] == null ? '' : String(review[key])]),
    ),
  )
  const [achievements, setAchievements] = useState(review?.key_achievements ?? '')
  const [improvements, setImprovements] = useState(review?.areas_for_improvement ?? '')
  const [plan, setPlan] = useState(review?.development_plan ?? '')
  const submit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    const input: Record<string, unknown> = {
      quarter,
      year: Number(year),
      key_achievements: achievements,
      areas_for_improvement: improvements,
      development_plan: plan,
    }
    for (const key of REVIEW_RATINGS) input[key] = fields[key] ? Number(fields[key]) : null
    onSave(input)
  }
  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next && !saving) onClose()
      }}
      title={review ? 'Edit review' : 'Add review'}
      description="Record a structured quarterly review for this employee."
      size="lg"
      footer={
        <>
          <Button variant="outline" disabled={saving} onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form="employee-review-form" isLoading={saving}>
            {review ? 'Save changes' : 'Save review'}
          </Button>
        </>
      }
    >
      <form id="employee-review-form" onSubmit={submit} className="space-y-4">
        {error ? (
          <Alert tone="danger" role="alert" title="Review could not be saved">
            Check the review period and ratings. Your draft is preserved.
          </Alert>
        ) : null}
        <section className="bg-surface-muted border-border-subtle rounded-control grid gap-4 border p-4 sm:grid-cols-2">
          <FormControl id="review-quarter" label="Quarter" required>
            <DropdownSelect
              id="review-quarter"
              value={quarter}
              onChange={setQuarter}
              options={['Q1', 'Q2', 'Q3', 'Q4'].map((value) => ({ value, label: value }))}
              required
            />
          </FormControl>
          <FormControl id="review-year" label="Year" required>
            <TextInput
              id="review-year"
              type="number"
              min="2000"
              max="2100"
              value={year}
              onChange={(event) => setYear(event.currentTarget.value)}
              required
            />
          </FormControl>
          {REVIEW_RATINGS.map((key) => (
            <FormControl key={key} id={`review-${key}`} label={key.replaceAll('_', ' ')}>
              <DropdownSelect
                id={`review-${key}`}
                value={fields[key]}
                onChange={(value) => setFields((current) => ({ ...current, [key]: value }))}
                options={[
                  { value: '', label: 'Not rated' },
                  ...[1, 2, 3, 4, 5].map((value) => ({
                    value: String(value),
                    label: `${value} / 5`,
                  })),
                ]}
              />
            </FormControl>
          ))}
          <FormControl id="review-achievements" label="Key achievements" className="sm:col-span-2">
            <TextArea
              value={achievements}
              onChange={(event) => setAchievements(event.currentTarget.value)}
              rows={3}
              maxLength={5000}
            />
          </FormControl>
          <FormControl
            id="review-improvements"
            label="Areas for improvement"
            className="sm:col-span-2"
          >
            <TextArea
              value={improvements}
              onChange={(event) => setImprovements(event.currentTarget.value)}
              rows={3}
              maxLength={5000}
            />
          </FormControl>
          <FormControl
            id="review-development-plan"
            label="Development plan"
            className="sm:col-span-2"
          >
            <TextArea
              value={plan}
              onChange={(event) => setPlan(event.currentTarget.value)}
              rows={3}
              maxLength={5000}
            />
          </FormControl>
        </section>
      </form>
    </Dialog>
  )
}

export function EmployeeProfilePage() {
  const { userId: userIdParam } = useParams({ from: '/_protected/hr/employees/$userId' })
  const search = useSearch({ from: '/_protected/hr/employees/$userId' }) as EmployeeProfileSearch
  const navigate = useNavigate({ from: '/hr/employees/$userId' })
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const currentUserId = session?.user.id ?? 0
  const currentEmployeeId = session?.employee.employee_id ?? ''
  const targetUserId = Number(userIdParam)
  const permissions = useMemo(() => session?.permissions ?? {}, [session?.permissions])
  const canUpdate = hasPermission(permissions, 'employees', 'update')
  const canExit = hasPermission(permissions, 'employees', 'exit')
  const employeeQuery = useQuery({
    queryKey: employeesQueryKeys.detail(currentUserId, currentEmployeeId, targetUserId),
    queryFn: ({ signal }) => employeesApi.get(targetUserId, signal),
    enabled: Boolean(session && Number.isSafeInteger(targetUserId) && targetUserId > 0),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const employee = employeeQuery.data
  const leaveQuery = useQuery({
    queryKey: employeesQueryKeys.leavePeriods(currentUserId, currentEmployeeId, targetUserId),
    queryFn: ({ signal }) => employeesApi.leavePeriods(targetUserId, signal),
    enabled: Boolean(employee && canUpdate),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const activeLeavePeriod = leaveQuery.data?.find((period) => period.status === 'active') ?? null
  const hasLeaveRecord = Boolean(activeLeavePeriod)
  const isLegacyLeave = employee?.employment_status === 'on-leave' && !hasLeaveRecord
  const selectedSection = search.section
  const setSection = (section: EmployeeProfileSearch['section']) =>
    void navigate({ search: (previous: Record<string, unknown>) => ({ ...previous, section }) })
  const [editorOpen, setEditorOpen] = useState(false)
  const [reviewEditorOpen, setReviewEditorOpen] = useState(false)
  const [reviewTarget, setReviewTarget] = useState<EmployeeReviewDto | null>(null)
  const [deleteReview, setDeleteReview] = useState<EmployeeReviewDto | null>(null)
  const [documentToDelete, setDocumentToDelete] = useState<EmployeeDocumentDto | null>(null)
  const [deactivateOpen, setDeactivateOpen] = useState(false)
  const [exitOpen, setExitOpen] = useState(false)
  const [leaveDialogMode, setLeaveDialogMode] = useState<'start' | 'return' | null>(null)
  const [exitDate, setExitDate] = useState(new Date().toISOString().slice(0, 10))
  const [exitReason, setExitReason] = useState('')
  const [documentError, setDocumentError] = useState('')
  const now = new Date()
  const periodStart = `${now.getFullYear()}-01-01`
  const periodEnd = `${now.getFullYear()}-12-31`
  const documentsPermission = hasPermission(permissions, 'employee_documents', 'view')
  const reviewsPermission = hasPermission(permissions, 'employee_reviews', 'list')
  const planPermission =
    hasPermission(permissions, 'employee_kpis', 'list') &&
    hasPermission(permissions, 'employee_targets', 'list')
  const activityPermission = hasPermission(permissions, 'audit_logs', 'list')
  const tasksPermission = hasPermission(permissions, 'tasks', 'list')
  const workReportsPermission = hasPermission(permissions, 'work_reports', 'list')
  const sectionAccess: Record<EmployeeProfileSearch['section'], boolean> = {
    profile: true,
    documents: documentsPermission,
    reviews: reviewsPermission || hasPermission(permissions, 'employee_reviews', 'create'),
    benefits: true,
    'performance-plan': planPermission,
    activity: activityPermission || hasPermission(permissions, 'monthly_scorecards', 'view'),
    tasks: tasksPermission,
    'work-reports': workReportsPermission,
    leave: canUpdate,
  }
  const activeSection = sectionAccess[selectedSection] ? selectedSection : 'profile'

  const documentQuery = useQuery({
    queryKey: employeesQueryKeys.documents(currentUserId, currentEmployeeId, targetUserId),
    queryFn: ({ signal }) => employeesApi.documents(targetUserId, signal),
    enabled: Boolean(employee && activeSection === 'documents' && documentsPermission),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const reviewsQuery = useQuery({
    queryKey: employeesQueryKeys.reviews(currentUserId, currentEmployeeId, targetUserId),
    queryFn: ({ signal }) => employeesApi.reviews(targetUserId, signal),
    enabled: Boolean(employee && activeSection === 'reviews' && reviewsPermission),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    placeholderData: keepPreviousData,
  })
  const planQuery = useQuery({
    queryKey: employeesQueryKeys.plan(
      currentUserId,
      currentEmployeeId,
      targetUserId,
      periodStart,
      periodEnd,
    ),
    queryFn: ({ signal }) =>
      employeesApi.performancePlan(targetUserId, periodStart, periodEnd, signal),
    enabled: Boolean(employee?.role_id && activeSection === 'performance-plan' && planPermission),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const activityParams = {
    search: '',
    userId: String(targetUserId),
    auditType: '',
    auditStatus: '',
    startDate: '',
    endDate: '',
    limit: 100,
    offset: 0,
  }
  const activityQuery = useQuery({
    queryKey: auditLogQueryKeys.list(currentUserId, currentEmployeeId, activityParams),
    queryFn: ({ signal }) => auditLogApi.list(activityParams, signal),
    enabled: Boolean(employee && activeSection === 'activity' && activityPermission),
    staleTime: DATA_FRESHNESS_MS.history,
  })
  const tasksQuery = useQuery({
    queryKey: employeesQueryKeys.tasks(currentUserId, currentEmployeeId, targetUserId),
    queryFn: ({ signal }) => employeesApi.tasks(targetUserId, signal),
    enabled: Boolean(employee && activeSection === 'tasks' && tasksPermission),
    staleTime: DATA_FRESHNESS_MS.history,
  })
  const reportParams = {
    employeeId: employee?.id ?? 0,
    status: 'all' as const,
    query: '',
    dateFrom: '',
    dateTo: '',
    limit: 100,
    offset: 0,
  }
  const workReportsQuery = useQuery({
    queryKey: workReportsQueryKeys.list(currentUserId, currentEmployeeId, reportParams),
    queryFn: ({ signal }) => workReportsApi.list(reportParams, signal),
    enabled: Boolean(employee && activeSection === 'work-reports' && workReportsPermission),
    staleTime: DATA_FRESHNESS_MS.history,
  })
  const scorecardQuery = useQuery({
    queryKey: employeesQueryKeys.scorecard(
      currentUserId,
      currentEmployeeId,
      employee?.id ?? 0,
      now.getMonth() + 1,
      now.getFullYear(),
    ),
    queryFn: ({ signal }) =>
      employeesApi.scorecard(employee!.id, now.getMonth() + 1, now.getFullYear(), signal),
    enabled: Boolean(
      employee &&
      activeSection === 'activity' &&
      hasPermission(permissions, 'monthly_scorecards', 'view'),
    ),
    staleTime: DATA_FRESHNESS_MS.standard,
  })
  const performanceReviewsQuery = useQuery({
    queryKey: employeesQueryKeys.legacyReviews(currentUserId, currentEmployeeId, employee?.id ?? 0),
    queryFn: ({ signal }) => employeesApi.performanceReviews(employee!.id, signal),
    enabled: Boolean(
      employee &&
      activeSection === 'reviews' &&
      hasPermission(permissions, 'performance_reviews', 'list'),
    ),
    staleTime: DATA_FRESHNESS_MS.history,
  })

  const updateMutation = useMutation({
    mutationFn: async ({
      input,
      profileImage,
    }: {
      input: EmployeeWriteInput
      profileImage: File | null
    }) => {
      const profilePicture = profileImage
        ? (await employeesApi.uploadProfilePicture(profileImage)).url
        : input.profile_picture
      return employeesApi.update(targetUserId, { ...input, profile_picture: profilePicture })
    },
    onSuccess: async (updated) => {
      queryClient.setQueryData(
        employeesQueryKeys.detail(currentUserId, currentEmployeeId, targetUserId),
        updated,
      )
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: employeesQueryKeys.all }),
        queryClient.invalidateQueries({ queryKey: ['hr', 'dashboard'] }),
      ])
      showToast({
        tone: 'success',
        title: 'Employee profile updated',
        description: 'The latest details have been saved.',
      })
      setEditorOpen(false)
    },
  })
  const statusMutation = useMutation({
    mutationFn: (status: string) =>
      employeesApi.update(targetUserId, { employment_status: status }),
    onSuccess: async (updated) => {
      queryClient.setQueryData(
        employeesQueryKeys.detail(currentUserId, currentEmployeeId, targetUserId),
        updated,
      )
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: employeesQueryKeys.all }),
        queryClient.invalidateQueries({ queryKey: ['hr', 'dashboard'] }),
      ])
      showToast({
        tone: 'success',
        title: 'Employment status updated',
        description: `Status is now ${updated.employment_status.replaceAll('-', ' ')}.`,
      })
      if (updated.employment_status === 'inactive') setDeactivateOpen(false)
    },
  })
  const leaveStartMutation = useMutation({
    mutationFn: (input: EmployeeLeavePeriodCreateInput) =>
      employeesApi.createLeavePeriod(targetUserId, input),
    onSuccess: async () => {
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: employeesQueryKeys.all }),
        queryClient.invalidateQueries({
          queryKey: employeesQueryKeys.detail(currentUserId, currentEmployeeId, targetUserId),
        }),
        queryClient.invalidateQueries({ queryKey: ['hr', 'dashboard'] }),
      ])
      await Promise.all([employeeQuery.refetch(), leaveQuery.refetch()])
      showToast({ tone: 'success', title: 'Leave record created' })
      setLeaveDialogMode(null)
    },
  })
  const leaveReturnMutation = useMutation({
    mutationFn: (input: EmployeeLeaveReturnInput) =>
      employeesApi.returnFromLeave(targetUserId, input),
    onSuccess: async () => {
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: employeesQueryKeys.all }),
        queryClient.invalidateQueries({
          queryKey: employeesQueryKeys.detail(currentUserId, currentEmployeeId, targetUserId),
        }),
        queryClient.invalidateQueries({ queryKey: ['hr', 'dashboard'] }),
      ])
      await Promise.all([employeeQuery.refetch(), leaveQuery.refetch()])
      showToast({
        tone: 'success',
        title: 'Return from leave recorded',
        description: 'Login access was left unchanged.',
      })
      setLeaveDialogMode(null)
    },
  })
  const exitMutation = useMutation({
    mutationFn: () =>
      employeesApi.exit(targetUserId, { exit_date: exitDate, reason: exitReason.trim() }),
    onSuccess: async () => {
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: employeesQueryKeys.all }),
        queryClient.invalidateQueries({
          queryKey: employeesQueryKeys.detail(currentUserId, currentEmployeeId, targetUserId),
        }),
        queryClient.invalidateQueries({ queryKey: ['hr', 'dashboard'] }),
      ])
      await employeeQuery.refetch()
      showToast({
        tone: 'success',
        title: 'Employee exited',
        description: 'Access has been disabled and the exit was recorded.',
      })
      setExitOpen(false)
      setExitReason('')
    },
  })
  const uploadMutation = useMutation({
    mutationFn: (file: File) => employeesApi.uploadDocument(targetUserId, file),
    onSuccess: async () => {
      await queryClient.invalidateQueries({
        queryKey: employeesQueryKeys.documents(currentUserId, currentEmployeeId, targetUserId),
      })
      showToast({ tone: 'success', title: 'Document uploaded' })
    },
  })
  const deleteDocumentMutation = useMutation({
    mutationFn: (document: EmployeeDocumentDto) =>
      employeesApi.deleteDocument(targetUserId, document.id),
    onSuccess: async () => {
      await queryClient.invalidateQueries({
        queryKey: employeesQueryKeys.documents(currentUserId, currentEmployeeId, targetUserId),
      })
      showToast({ tone: 'success', title: 'Document removed' })
      setDocumentToDelete(null)
    },
  })
  const reviewSaveMutation = useMutation({
    mutationFn: ({
      review,
      input,
    }: {
      review: EmployeeReviewDto | null
      input: Record<string, unknown>
    }) =>
      review
        ? employeesApi.updateReview(review.id, input)
        : employeesApi.createReview(targetUserId, input),
    onSuccess: async (_result, variables) => {
      await queryClient.invalidateQueries({
        queryKey: employeesQueryKeys.reviews(currentUserId, currentEmployeeId, targetUserId),
      })
      showToast({ tone: 'success', title: variables.review ? 'Review updated' : 'Review added' })
      setReviewEditorOpen(false)
      setReviewTarget(null)
    },
  })
  const reviewDeleteMutation = useMutation({
    mutationFn: (review: EmployeeReviewDto) => employeesApi.deleteReview(review.id),
    onSuccess: async () => {
      await queryClient.invalidateQueries({
        queryKey: employeesQueryKeys.reviews(currentUserId, currentEmployeeId, targetUserId),
      })
      showToast({ tone: 'success', title: 'Review deleted' })
      setDeleteReview(null)
    },
  })

  const tabs = useMemo(
    () =>
      [
        {
          id: 'profile' as const,
          label: 'Profile',
          icon: <UserRound className="size-4" aria-hidden="true" />,
          visible: true,
        },
        {
          id: 'documents' as const,
          label: 'Documents',
          icon: <FileText className="size-4" aria-hidden="true" />,
          visible: documentsPermission,
        },
        {
          id: 'reviews' as const,
          label: 'Reviews',
          icon: <Check className="size-4" aria-hidden="true" />,
          visible: reviewsPermission || hasPermission(permissions, 'employee_reviews', 'create'),
        },
        {
          id: 'benefits' as const,
          label: 'Benefits',
          icon: <Wallet className="size-4" aria-hidden="true" />,
          visible: true,
        },
        {
          id: 'performance-plan' as const,
          label: 'Performance plan',
          icon: <Shield className="size-4" aria-hidden="true" />,
          visible: planPermission,
        },
        {
          id: 'activity' as const,
          label: 'Activity',
          icon: <Activity className="size-4" aria-hidden="true" />,
          visible: activityPermission || hasPermission(permissions, 'monthly_scorecards', 'view'),
        },
        {
          id: 'tasks' as const,
          label: 'Tasks',
          icon: <BriefcaseBusiness className="size-4" aria-hidden="true" />,
          visible: tasksPermission,
        },
        {
          id: 'work-reports' as const,
          label: 'Work reports',
          icon: <CalendarDays className="size-4" aria-hidden="true" />,
          visible: workReportsPermission,
        },
        {
          id: 'leave' as const,
          label: 'Leave',
          icon: <CalendarClock className="size-4" aria-hidden="true" />,
          visible: canUpdate,
        },
      ].filter((tab) => tab.visible),
    [
      activityPermission,
      canUpdate,
      documentsPermission,
      permissions,
      planPermission,
      reviewsPermission,
      tasksPermission,
      workReportsPermission,
    ],
  )

  const uploadDocument = (file?: File) => {
    if (!file) return
    const extension = file.name.split('.').pop()?.toLowerCase() ?? ''
    if (!DOCUMENT_EXTENSIONS.has(extension)) {
      setDocumentError('Choose a PDF, Word document, PNG, or JPEG file.')
      return
    }
    if (file.size > DOCUMENT_MAX_BYTES) {
      setDocumentError('Files must be 15 MB or smaller.')
      return
    }
    setDocumentError('')
    uploadMutation.mutate(file)
  }
  const title = employee
    ? [employee.first_name, employee.middle_name, employee.last_name].filter(Boolean).join(' ')
    : 'Employee profile'
  const tasks = tasksQuery.data?.items ?? []
  const reviews = reviewsQuery.data?.items ?? []
  const isOwnProfile = employee?.user_id === currentUserId
  const today = new Date().toISOString().slice(0, 10)

  return (
    <PageLayout
      title={title || 'Employee profile'}
      actionsInline
      backLink={
        <Link
          to="/hr/employees"
          search={{ search: '', page: 1, view: 'active', branchId: 'all', departmentId: 'all' }}
          className={pageBackLinkClassName}
        >
          <PageBackLinkContent>employees</PageBackLinkContent>
        </Link>
      }
      actions={
        employee && canUpdate ? (
          <Button
            aria-label="Edit employee profile"
            variant="outline"
            leadingIcon={<Pencil className="size-4" aria-hidden="true" />}
            onClick={() => {
              updateMutation.reset()
              setEditorOpen(true)
            }}
            className="max-[479px]:text-caption max-[479px]:min-h-9 max-[479px]:px-3"
          >
            <span className="max-[479px]:hidden">Edit profile</span>
            <span className="hidden max-[479px]:inline max-[361px]:hidden">Edit</span>
          </Button>
        ) : null
      }
    >
      <div className="space-y-5">
        {employeeQuery.isPending && !employee ? (
          <div className="space-y-3" role="status" aria-label="Loading employee profile">
            <Skeleton variant="card" />
            <Skeleton variant="card" />
          </div>
        ) : null}
        {employeeQuery.isError && !employee ? (
          <ErrorState
            title="Employee profile could not load"
            description="The record may be unavailable in your branch or permission scope."
            error={employeeQuery.error}
            action={
              <Button variant="outline" onClick={() => void employeeQuery.refetch()}>
                Try again
              </Button>
            }
          />
        ) : null}
        {employeeQuery.isError && employee ? (
          <SectionErrorState
            title="Profile refresh failed"
            description="Showing the last loaded employee details."
            onRetry={() => void employeeQuery.refetch()}
          />
        ) : null}
        {employee ? (
          <>
            <Card className="from-primary-subtle/30 via-surface to-surface relative z-10 bg-gradient-to-br p-0">
              <div className="tablet:flex-row tablet:items-center tablet:justify-between flex min-w-0 flex-col gap-4 p-4 sm:p-5">
                <div className="flex min-w-0 items-center gap-4">
                  <div className="bg-primary-subtle text-primary rounded-control flex size-14 shrink-0 items-center justify-center overflow-hidden">
                    {employee.profile_picture ? (
                      <img
                        src={employee.profile_picture}
                        alt=""
                        className="size-full object-cover"
                      />
                    ) : (
                      <UserRound className="size-7" aria-hidden="true" />
                    )}
                  </div>
                  <div className="min-w-0">
                    <p className="text-label text-text-primary truncate font-semibold">
                      {employee.designation || 'Position not set'}
                    </p>
                    <p className="text-caption text-text-secondary mt-1 break-words">
                      {employee.employee_id} · {employee.department_name ?? 'No department'}
                      {employee.branch_name ? ` · ${employee.branch_name}` : ''}
                    </p>
                  </div>
                </div>
                <div className="tablet:justify-end flex shrink-0 flex-wrap gap-2">
                  <StatusChip
                    label={formatStatus(employee.employment_status)}
                    tone={
                      employee.employment_status === 'active'
                        ? 'success'
                        : employee.employment_status === 'on-leave' ||
                            employee.employment_status === 'on-probation'
                          ? 'warning'
                          : employee.employment_status === 'terminated' ||
                              employee.employment_status === 'suspended'
                            ? 'danger'
                            : 'neutral'
                    }
                  />
                  <StatusChip
                    label={employee.account_is_active ? 'Login enabled' : 'Login disabled'}
                    tone={employee.account_is_active ? 'info' : 'neutral'}
                    dense
                  />
                </div>
              </div>
              {canUpdate || canExit ? (
                <div className="border-border-subtle flex min-w-0 flex-wrap items-center justify-end gap-2 border-t px-4 py-3 sm:px-5">
                  {canUpdate &&
                  employee.employment_status !== 'terminated' &&
                  (hasLeaveRecord ||
                    isLegacyLeave ||
                    ['active', 'on-probation', 'suspended'].includes(
                      employee.employment_status,
                    )) ? (
                    <Button
                      variant={hasLeaveRecord || isLegacyLeave ? 'outline' : 'primary'}
                      size="sm"
                      leadingIcon={<CalendarClock className="size-4" aria-hidden="true" />}
                      disabled={leaveQuery.isPending && !leaveQuery.data}
                      onClick={() => {
                        leaveStartMutation.reset()
                        leaveReturnMutation.reset()
                        setLeaveDialogMode(hasLeaveRecord || isLegacyLeave ? 'return' : 'start')
                      }}
                    >
                      {hasLeaveRecord || isLegacyLeave ? 'Return from leave' : 'Place on leave'}
                    </Button>
                  ) : null}
                  {canUpdate &&
                  employee.account_is_active &&
                  employee.employment_status !== 'suspended' ? (
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => statusMutation.mutate('suspended')}
                      isLoading={statusMutation.isPending}
                    >
                      Suspend access
                    </Button>
                  ) : null}
                  {canUpdate &&
                  !employee.account_is_active &&
                  !hasLeaveRecord &&
                  !isLegacyLeave &&
                  employee.employment_status !== 'terminated' ? (
                    <Button
                      variant="outline"
                      size="sm"
                      leadingIcon={<Check className="size-4" aria-hidden="true" />}
                      onClick={() => statusMutation.mutate('active')}
                      isLoading={statusMutation.isPending}
                    >
                      Enable login
                    </Button>
                  ) : null}
                  {canUpdate &&
                  employee.employment_status !== 'inactive' &&
                  employee.employment_status !== 'terminated' ? (
                    <details className="group relative">
                      <summary
                        role="button"
                        aria-label="More employee actions"
                        className="border-border-subtle text-text-secondary hover:bg-surface-muted focus-visible:shadow-focus-ring rounded-control flex size-9 cursor-pointer list-none items-center justify-center border focus-visible:outline-none [&::-webkit-details-marker]:hidden"
                      >
                        <MoreHorizontal className="size-4" aria-hidden="true" />
                      </summary>
                      <div className="border-border-subtle bg-surface shadow-overlay rounded-control absolute top-[calc(100%+0.25rem)] right-0 z-30 grid min-w-44 gap-1 border p-1.5">
                        {employee.employment_status !== 'terminated' ? (
                          <Button
                            variant="ghost"
                            size="sm"
                            className="justify-start"
                            onClick={(event) => {
                              event.currentTarget.closest('details')?.removeAttribute('open')
                              statusMutation.reset()
                              setDeactivateOpen(true)
                            }}
                          >
                            Deactivate
                          </Button>
                        ) : null}
                        {canExit && employee.employment_status !== 'terminated' ? (
                          <Button
                            variant="ghost"
                            size="sm"
                            className="text-danger justify-start"
                            leadingIcon={
                              <BriefcaseBusiness className="size-4" aria-hidden="true" />
                            }
                            onClick={(event) => {
                              event.currentTarget.closest('details')?.removeAttribute('open')
                              exitMutation.reset()
                              setExitDate(today)
                              setExitOpen(true)
                            }}
                          >
                            Exit employee
                          </Button>
                        ) : null}
                      </div>
                    </details>
                  ) : canExit && employee.employment_status !== 'terminated' ? (
                    <Button
                      variant="danger"
                      size="sm"
                      leadingIcon={<BriefcaseBusiness className="size-4" />}
                      onClick={() => {
                        exitMutation.reset()
                        setExitDate(today)
                        setExitOpen(true)
                      }}
                    >
                      Exit employee
                    </Button>
                  ) : null}
                </div>
              ) : null}
            </Card>
            {statusMutation.error && !deactivateOpen ? (
              <Alert role="alert" tone="danger" title="Status could not be changed">
                The profile remains in its previous state. Retry the action.
              </Alert>
            ) : null}
            <Card className="overflow-hidden p-0">
              <nav
                className="bg-surface-muted desktop:grid-cols-4 tablet:grid-cols-3 grid min-w-0 grid-cols-2 gap-1.5 p-2"
                role="tablist"
                aria-label="Employee profile sections"
              >
                {tabs.map((tab, index) => (
                  <button
                    key={tab.id}
                    type="button"
                    id={`employee-profile-tab-${tab.id}`}
                    role="tab"
                    aria-selected={activeSection === tab.id}
                    aria-controls="employee-profile-panel"
                    tabIndex={activeSection === tab.id ? 0 : -1}
                    onClick={() => setSection(tab.id)}
                    onKeyDown={(event) => {
                      let nextIndex: number | null = null
                      if (event.key === 'ArrowRight' || event.key === 'ArrowDown') {
                        nextIndex = (index + 1) % tabs.length
                      }
                      if (event.key === 'ArrowLeft' || event.key === 'ArrowUp') {
                        nextIndex = (index + tabs.length - 1) % tabs.length
                      }
                      if (event.key === 'Home') nextIndex = 0
                      if (event.key === 'End') nextIndex = tabs.length - 1
                      if (nextIndex === null) return
                      event.preventDefault()
                      const nextTab = tabs[nextIndex]
                      setSection(nextTab.id)
                      document.getElementById(`employee-profile-tab-${nextTab.id}`)?.focus()
                    }}
                    className={`rounded-control focus-visible:shadow-focus-ring flex min-h-10 min-w-0 items-center gap-2 px-2 py-2 text-left font-semibold transition-colors focus-visible:outline-none sm:px-3 ${activeSection === tab.id ? 'bg-surface text-primary shadow-elevation-sm' : 'text-text-secondary hover:bg-surface/70'}`}
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
              id="employee-profile-panel"
              role="tabpanel"
              aria-labelledby={`employee-profile-tab-${activeSection}`}
              tabIndex={0}
              className="space-y-5 focus-visible:outline-none"
            >
              {activeSection === 'profile' ? (
                <div className="desktop:grid-cols-2 grid min-w-0 gap-5">
                  <ProfileSection
                    title="Personal information"
                    icon={<UserRound className="size-4" />}
                    fields={[
                      [
                        'Full name',
                        [employee.first_name, employee.middle_name, employee.last_name]
                          .filter(Boolean)
                          .join(' '),
                      ],
                      ['Work email', employee.email],
                      ['Personal email', employee.personal_email],
                      ['Date of birth', employee.date_of_birth],
                      ['Gender', employee.gender],
                      ['Marital status', employee.marital_status],
                      ['Nationality', employee.nationality],
                      ['Phone', employee.phone_number],
                      ['Alternate phone', employee.other_phone],
                    ]}
                  />
                  <ProfileSection
                    title="Contact and emergency"
                    icon={<Activity className="size-4" />}
                    fields={[
                      ['Address', employee.address],
                      ['City', employee.city],
                      ['State / region', employee.state],
                      ['Postal code', employee.zip_code],
                      ['Country', employee.country],
                      ['Emergency contact', employee.emergency_contact_name],
                      ['Relationship', employee.emergency_contact_relationship],
                      ['Emergency phone', employee.emergency_contact_phone],
                    ]}
                  />
                  <ProfileSection
                    title="Employment"
                    icon={<BriefcaseBusiness className="size-4" />}
                    fields={[
                      ['Employment type', employee.employment_type],
                      ['Start date', employee.start_date],
                      ['Role', employee.role_name],
                      ['Reports to', employee.reporting_to_id ? 'Manager assigned' : null],
                      ['Work location', employee.location],
                      ['Work schedule', employee.work_schedule],
                      ['Probation (months)', employee.probation_period],
                      [
                        'Department units',
                        employee.department_units.map((unit) => unit.name).join(', '),
                      ],
                    ]}
                  />
                </div>
              ) : null}
              {activeSection === 'benefits' ? (
                <div className="desktop:grid-cols-2 grid min-w-0 gap-5">
                  <Card className="desktop:col-span-2 tablet:p-5 min-w-0 space-y-5 overflow-hidden p-4">
                    <div className="flex flex-wrap items-start justify-between gap-3">
                      <div className="flex items-center gap-2">
                        <span className="text-primary" aria-hidden="true">
                          <Wallet className="size-4" />
                        </span>
                        <div>
                          <h2 className="text-h2 font-semibold">Compensation</h2>
                          <p className="text-caption text-text-secondary mt-1">
                            Pay and recurring allowances
                          </p>
                        </div>
                      </div>
                      <StatusChip
                        dense
                        label={formatStatus(employee.salary_frequency || 'monthly')}
                        tone="neutral"
                      />
                    </div>
                    <div className="grid min-w-0 gap-4 sm:grid-cols-[minmax(0,0.9fr)_minmax(0,1.6fr)]">
                      <div className="from-primary-subtle/70 to-surface border-primary/15 rounded-surface flex min-w-0 flex-col justify-center border bg-gradient-to-br p-4 sm:p-5">
                        <p className="text-caption text-text-secondary">Gross salary</p>
                        <p className="text-h2 text-text-primary mt-2 font-semibold break-words tabular-nums">
                          {employee.gross_salary !== null && employee.gross_salary !== ''
                            ? formatNaira(employee.gross_salary)
                            : 'Not provided'}
                        </p>
                        <p className="text-caption text-text-muted mt-1">
                          per {salaryFrequencyPeriod(employee.salary_frequency || '')}
                        </p>
                      </div>
                      <section
                        aria-label="Allowances"
                        className="bg-surface-muted/50 border-border-subtle rounded-surface min-w-0 border p-4"
                      >
                        <div className="mb-3 flex items-center justify-between gap-2">
                          <h3 className="text-label font-semibold">Allowances</h3>
                          <span className="text-caption text-text-muted">
                            {allowanceEntries(employee.allowances).length} items
                          </span>
                        </div>
                        <AllowanceBreakdown value={employee.allowances} />
                      </section>
                    </div>
                  </Card>
                  <ProfileSection
                    title="Bank and statutory details"
                    icon={<Shield className="size-4" />}
                    fields={[
                      ['Bank', employee.bank_name],
                      ['Account number', employee.account_number],
                      ['Tax ID', employee.tax_id],
                      ['Pension number', employee.pension_number],
                      ['Pension provider', employee.pfa_provider],
                      ['RSA number', employee.rsa_number],
                      ['Employer contribution', formatPercent(employee.employer_contribution)],
                    ]}
                  />
                  <ProfileSection
                    title="Health cover"
                    icon={<HeartPulse className="size-4" />}
                    fields={[
                      ['HMO plan', employee.hmo_current_plan],
                      ['Member ID', employee.hmo_id_number],
                      ['Covered dependants', employee.hmo_dependents_covered],
                    ]}
                  />
                </div>
              ) : null}
              {activeSection === 'documents' ? (
                <Card className="tablet:p-5 space-y-5 p-4">
                  <div className="flex flex-wrap items-start justify-between gap-3">
                    <div className="min-w-0">
                      <div className="flex flex-wrap items-center gap-2">
                        <h2 className="text-h2 font-semibold">Employee documents</h2>
                        {documentQuery.data ? (
                          <StatusChip
                            dense
                            label={`${documentQuery.data.length} ${documentQuery.data.length === 1 ? 'file' : 'files'}`}
                          />
                        ) : null}
                      </div>
                      <p className="text-caption text-text-secondary mt-1">
                        Securely stored employee files · PDF, Word, PNG, or JPEG up to 15 MB.
                      </p>
                    </div>
                    {hasPermission(permissions, 'employee_documents', 'upload') ? (
                      <label className="bg-primary text-text-on-primary hover:bg-primary-hover focus-within:shadow-focus-ring rounded-control text-caption inline-flex min-h-10 cursor-pointer items-center gap-2 px-3 font-semibold">
                        <Upload className="size-4" aria-hidden="true" />
                        Upload document
                        <input
                          type="file"
                          accept=".pdf,.doc,.docx,.png,.jpg,.jpeg"
                          className="sr-only"
                          onChange={(event) => {
                            const input = event.currentTarget
                            uploadDocument(input.files?.[0])
                            input.value = ''
                          }}
                          disabled={uploadMutation.isPending}
                          aria-label="Choose employee document"
                        />
                      </label>
                    ) : null}
                  </div>
                  {documentError ? (
                    <Alert role="alert" tone="danger" title="File not accepted">
                      {documentError}
                    </Alert>
                  ) : null}
                  {uploadMutation.error ? (
                    <Alert role="alert" tone="danger" title="Upload failed">
                      The file was not saved. You can choose it again and retry.
                    </Alert>
                  ) : null}
                  {documentQuery.isPending && !documentQuery.data ? (
                    <Skeleton variant="card" />
                  ) : null}
                  {documentQuery.isError && !documentQuery.data ? (
                    <SectionErrorState
                      title="Documents could not load"
                      error={documentQuery.error}
                      onRetry={() => void documentQuery.refetch()}
                    />
                  ) : null}
                  {documentQuery.data?.length ? (
                    <div className="grid min-w-0 gap-3 sm:grid-cols-2 2xl:grid-cols-3">
                      {documentQuery.data.map((document) => (
                        <article
                          key={document.id}
                          className="bg-surface-muted/50 border-border-subtle rounded-control flex min-w-0 flex-col justify-between gap-4 border p-4"
                        >
                          <div className="flex min-w-0 items-start gap-3">
                            <span className="text-primary bg-primary-subtle rounded-control flex size-10 shrink-0 items-center justify-center">
                              <FileText className="size-5" aria-hidden="true" />
                            </span>
                            <div className="min-w-0 flex-1">
                              <p className="text-body-sm text-text-primary font-semibold break-words">
                                {document.name}
                              </p>
                              <p className="text-caption text-text-secondary mt-1">
                                {document.file_type.toUpperCase()} <span aria-hidden="true">·</span>{' '}
                                {formatDocumentDate(document.uploaded_at)}
                              </p>
                            </div>
                          </div>
                          <div className="border-border-subtle flex items-center justify-end gap-2 border-t pt-3">
                            <a
                              className="text-primary text-caption rounded-control hover:bg-surface focus-visible:shadow-focus-ring inline-flex min-h-9 items-center gap-1.5 border border-transparent px-3 font-semibold focus-visible:outline-none"
                              href={document.file_url}
                              target="_blank"
                              rel="noreferrer"
                            >
                              Open file <ArrowUpRight className="size-3.5" aria-hidden="true" />
                            </a>
                            {hasPermission(permissions, 'employee_documents', 'delete') ? (
                              <Button
                                variant="ghost"
                                size="icon"
                                aria-label={`Delete ${document.name}`}
                                title="Remove document"
                                onClick={() => {
                                  deleteDocumentMutation.reset()
                                  setDocumentToDelete(document)
                                }}
                              >
                                <Trash2 className="text-danger size-4" />
                              </Button>
                            ) : null}
                          </div>
                        </article>
                      ))}
                    </div>
                  ) : null}
                  {!documentQuery.isPending &&
                  !documentQuery.isError &&
                  documentQuery.data?.length === 0 ? (
                    <EmptyState
                      title="No documents uploaded"
                      description="Documents added here remain attached to this employee profile."
                    />
                  ) : null}
                </Card>
              ) : null}
              {activeSection === 'reviews' ? (
                <Card className="tablet:p-5 space-y-4 p-4">
                  <div className="flex flex-wrap items-start justify-between gap-3">
                    <div>
                      <h2 className="text-h2 font-semibold">Performance reviews</h2>
                      <p className="text-caption text-text-secondary mt-1">
                        Quarterly ratings, achievements, and development plans.
                      </p>
                    </div>
                    {hasPermission(permissions, 'employee_reviews', 'create') ? (
                      <Button
                        size="sm"
                        leadingIcon={<Plus className="size-4" />}
                        onClick={() => {
                          reviewSaveMutation.reset()
                          setReviewTarget(null)
                          setReviewEditorOpen(true)
                        }}
                      >
                        Add review
                      </Button>
                    ) : null}
                  </div>
                  {reviewSaveMutation.error || reviewDeleteMutation.error ? (
                    <Alert role="alert" tone="danger" title="Review action failed">
                      The review list has not changed. Check your permission and input, then retry.
                    </Alert>
                  ) : null}
                  {reviewsQuery.isPending && !reviewsQuery.data ? (
                    <Skeleton variant="card" />
                  ) : null}
                  {reviewsQuery.isError && !reviewsQuery.data ? (
                    <SectionErrorState
                      title="Reviews could not load"
                      error={reviewsQuery.error}
                      onRetry={() => void reviewsQuery.refetch()}
                    />
                  ) : null}
                  {reviews.length ? (
                    <div className="space-y-3">
                      {reviews.map((review) => (
                        <article
                          key={review.id}
                          className="bg-surface-muted/40 border-border-subtle rounded-control min-w-0 border p-4 sm:p-5"
                        >
                          <div className="grid min-w-0 gap-3 sm:grid-cols-[minmax(0,1fr)_auto] sm:items-start">
                            <div className="min-w-0">
                              <h3 className="text-body font-semibold">
                                {review.quarter} {review.year} review
                              </h3>
                              <p className="text-caption text-text-secondary mt-1">
                                {review.review_period} <span aria-hidden="true">·</span>{' '}
                                {review.review_date}
                                {review.reviewer_name ? (
                                  <>
                                    {' '}
                                    <span aria-hidden="true">·</span> {review.reviewer_name}
                                  </>
                                ) : null}
                              </p>
                            </div>
                            <div className="flex flex-wrap items-center justify-end gap-2 sm:pl-4">
                              {review.overall_rating == null ? (
                                <StatusChip label="Not rated" />
                              ) : (
                                <StatusChip
                                  label={`${review.overall_rating.toFixed(1)} / 5`}
                                  tone="info"
                                />
                              )}
                            </div>
                          </div>
                          <div className="mt-4 grid min-w-0 gap-3 sm:grid-cols-2">
                            {review.key_achievements ? (
                              <div className="bg-surface border-border-subtle rounded-control min-w-0 border p-3.5">
                                <h4 className="text-caption text-text-primary font-semibold">
                                  Achievements
                                </h4>
                                <p className="text-body-sm text-text-secondary mt-1.5 break-words">
                                  {review.key_achievements}
                                </p>
                              </div>
                            ) : null}
                            {review.areas_for_improvement ? (
                              <div className="bg-surface border-border-subtle rounded-control min-w-0 border p-3.5">
                                <h4 className="text-caption text-text-primary font-semibold">
                                  Growth areas
                                </h4>
                                <p className="text-body-sm text-text-secondary mt-1.5 break-words">
                                  {review.areas_for_improvement}
                                </p>
                              </div>
                            ) : null}
                            {review.development_plan ? (
                              <div className="bg-surface border-border-subtle rounded-control min-w-0 border p-3.5 sm:col-span-2">
                                <h4 className="text-caption text-text-primary font-semibold">
                                  Development plan
                                </h4>
                                <p className="text-body-sm text-text-secondary mt-1.5 break-words">
                                  {review.development_plan}
                                </p>
                              </div>
                            ) : null}
                          </div>
                          {hasPermission(permissions, 'employee_reviews', 'update') ||
                          hasPermission(permissions, 'employee_reviews', 'delete') ? (
                            <div className="border-border-subtle mt-4 flex flex-wrap justify-end gap-2 border-t pt-3">
                              {hasPermission(permissions, 'employee_reviews', 'update') ? (
                                <Button
                                  variant="outline"
                                  size="sm"
                                  onClick={() => {
                                    reviewSaveMutation.reset()
                                    setReviewTarget(review)
                                    setReviewEditorOpen(true)
                                  }}
                                >
                                  Edit review
                                </Button>
                              ) : null}
                              {hasPermission(permissions, 'employee_reviews', 'delete') ? (
                                <Button
                                  variant="ghost"
                                  size="sm"
                                  className="text-danger"
                                  onClick={() => setDeleteReview(review)}
                                >
                                  Delete
                                </Button>
                              ) : null}
                            </div>
                          ) : null}
                        </article>
                      ))}
                    </div>
                  ) : null}
                  {!reviewsQuery.isPending && !reviewsQuery.isError && reviews.length === 0 ? (
                    <EmptyState
                      title="No reviews recorded"
                      description="Reviews will appear here as they are completed."
                    />
                  ) : null}
                  {performanceReviewsQuery.data?.items.length ? (
                    <p className="text-caption text-text-muted">
                      {performanceReviewsQuery.data.items.length} additional performance record(s)
                      are available in the performance review system.
                    </p>
                  ) : null}
                </Card>
              ) : null}
              {activeSection === 'performance-plan' ? (
                <Card className="tablet:p-5 space-y-4 p-4">
                  <div>
                    <h2 className="text-h2 font-semibold">Performance plan</h2>
                    <p className="text-caption text-text-secondary mt-1">
                      Current calendar-year role targets and KPI assignments.
                    </p>
                  </div>
                  {employee && !employee.role_id ? (
                    <EmptyState
                      title="No role assigned"
                      description="Assign a role to this employee to create a performance plan."
                    />
                  ) : null}
                  {employee?.role_id && planQuery.isPending && !planQuery.data ? (
                    <Skeleton variant="card" />
                  ) : null}
                  {employee?.role_id && planQuery.isError && !planQuery.data ? (
                    <SectionErrorState
                      title="Performance plan could not load"
                      error={planQuery.error}
                      onRetry={() => void planQuery.refetch()}
                    />
                  ) : null}
                  {planQuery.data ? <PerformancePlanView plan={planQuery.data} /> : null}
                </Card>
              ) : null}
              {activeSection === 'activity' ? (
                <div className="space-y-4">
                  {hasPermission(permissions, 'monthly_scorecards', 'view') ? (
                    <Card className="tablet:p-5 p-4">
                      <div className="flex items-center gap-2">
                        <CalendarDays className="text-primary size-4" />
                        <h2 className="text-h2 font-semibold">Current month scorecard</h2>
                      </div>
                      {scorecardQuery.isPending && !scorecardQuery.data ? (
                        <Skeleton variant="card" className="mt-4" />
                      ) : null}
                      {scorecardQuery.isError && !scorecardQuery.data ? (
                        <SectionErrorState
                          className="mt-4"
                          title="Scorecard unavailable"
                          error={scorecardQuery.error}
                          onRetry={() => void scorecardQuery.refetch()}
                        />
                      ) : null}
                      {scorecardQuery.data ? (
                        <div className="tablet:grid-cols-3 mt-4 grid gap-3 sm:grid-cols-2">
                          {[
                            ['Overall score', scorecardQuery.data.overall_score],
                            ['Target achievement', scorecardQuery.data.target_achievement],
                            ['Attendance', scorecardQuery.data.attendance_score],
                            ['Task delivery', scorecardQuery.data.task_delivery_score],
                            ['Report accuracy', scorecardQuery.data.report_accuracy_score],
                            ['Training progress', scorecardQuery.data.training_progress_score],
                          ].map(([label, value]) => (
                            <div
                              key={String(label)}
                              className="bg-surface-muted rounded-control p-3"
                            >
                              <p className="text-caption text-text-secondary">{label}</p>
                              <p className="text-h3 mt-1 font-semibold">{value}%</p>
                            </div>
                          ))}
                        </div>
                      ) : null}
                    </Card>
                  ) : null}
                  <Card className="tablet:p-5 space-y-3 p-4">
                    <div className="flex items-center gap-2">
                      <Activity className="text-primary size-4" />
                      <h2 className="text-h2 font-semibold">Employee activity</h2>
                    </div>
                    {activityQuery.isPending && !activityQuery.data ? (
                      <Skeleton variant="card" />
                    ) : null}
                    {activityQuery.isError && !activityQuery.data ? (
                      <SectionErrorState
                        title="Activity could not load"
                        error={activityQuery.error}
                        onRetry={() => void activityQuery.refetch()}
                      />
                    ) : null}
                    {activityQuery.data?.items.length ? (
                      <div className="divide-border-subtle divide-y">
                        {activityQuery.data.items.map((item) => (
                          <div className="py-3" key={item.id}>
                            <p className="text-body-sm text-text-primary">{item.activity}</p>
                            <p className="text-caption text-text-secondary mt-1">
                              {item.audit_type_display} · {item.audit_status_display} ·{' '}
                              {new Date(item.created_at).toLocaleString()}
                            </p>
                          </div>
                        ))}
                      </div>
                    ) : null}
                    {activityQuery.data?.items.length === 0 ? (
                      <EmptyState
                        title="No activity recorded"
                        description="Employee activity appears here when recorded by the system."
                      />
                    ) : null}
                  </Card>
                </div>
              ) : null}
              {activeSection === 'tasks' ? (
                <Card className="tablet:p-5 space-y-4 p-4">
                  <div className="flex flex-wrap items-start justify-between gap-3">
                    <div className="min-w-0">
                      <div className="flex flex-wrap items-center gap-2">
                        <h2 className="text-h2 font-semibold">Assigned tasks</h2>
                        {tasksQuery.data ? (
                          <StatusChip dense label={`${tasksQuery.data.count} total`} />
                        ) : null}
                      </div>
                      <p className="text-caption text-text-secondary mt-1">
                        Tasks assigned to this employee, with status and due-date context.
                      </p>
                    </div>
                    {isOwnProfile ? (
                      <Link
                        to="/dashboard/my-tasks"
                        search={{
                          status: 'all',
                          priority: 'all',
                          sort: 'due_date',
                          page: 1,
                        }}
                        className="text-primary text-caption rounded-control hover:bg-primary-subtle/60 focus-visible:shadow-focus-ring inline-flex min-h-9 items-center gap-1.5 px-3 font-semibold focus-visible:outline-none"
                      >
                        Open My Tasks <ArrowUpRight className="size-3.5" aria-hidden="true" />
                      </Link>
                    ) : null}
                  </div>
                  {tasksQuery.isPending && !tasksQuery.data ? <Skeleton variant="card" /> : null}
                  {tasksQuery.isError && !tasksQuery.data ? (
                    <SectionErrorState
                      title="Tasks could not load"
                      error={tasksQuery.error}
                      onRetry={() => void tasksQuery.refetch()}
                    />
                  ) : null}
                  {tasks.length ? (
                    <div className="space-y-3">
                      {tasks.map((task) => {
                        const status = taskStatusPresentation(task.status)
                        const priority = taskPriorityPresentation(task.priority)
                        const overdue = isTaskOverdue(task)
                        return (
                          <article
                            key={task.id}
                            className="border-border-subtle from-surface via-surface to-surface-muted/50 shadow-elevation-sm hover:border-border-strong rounded-surface min-w-0 border bg-gradient-to-br p-4 transition-colors sm:p-5"
                          >
                            <div className="flex min-w-0 flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                              <div className="flex min-w-0 items-start gap-3">
                                <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
                                  <ClipboardList className="size-5" aria-hidden="true" />
                                </span>
                                <div className="min-w-0">
                                  <h3 className="text-body-sm text-text-primary font-semibold [overflow-wrap:anywhere] break-words">
                                    {task.name}
                                  </h3>
                                  {task.description?.trim() ? (
                                    <p className="text-caption text-text-secondary mt-1.5 [overflow-wrap:anywhere] break-words">
                                      {task.description}
                                    </p>
                                  ) : null}
                                </div>
                              </div>
                              <StatusChip
                                label={status.label}
                                tone={status.tone}
                                className="max-w-full self-end sm:shrink-0 sm:self-start"
                              />
                            </div>
                            <dl className="border-border-subtle mt-4 grid grid-cols-1 gap-2 border-t pt-4 min-[420px]:grid-cols-2 sm:grid-cols-3">
                              <div className="bg-surface-muted/70 rounded-control min-w-0 p-3">
                                <dt className="text-caption text-text-muted">Project</dt>
                                <dd className="text-body-sm text-text-primary mt-1 font-medium [overflow-wrap:anywhere] break-words">
                                  {task.project_name || task.project?.name || 'No project'}
                                </dd>
                              </div>
                              <div className="bg-surface-muted/70 rounded-control min-w-0 p-3">
                                <dt className="text-caption text-text-muted">Due date</dt>
                                <dd
                                  className={`text-body-sm mt-1 flex items-start gap-1.5 font-medium ${overdue ? 'text-danger' : 'text-text-primary'}`}
                                >
                                  <CalendarClock
                                    className="mt-0.5 size-4 shrink-0"
                                    aria-hidden="true"
                                  />
                                  <span className="[overflow-wrap:anywhere] break-words">
                                    {overdue ? 'Overdue · ' : ''}
                                    {formatTaskDueDate(task.due_date)}
                                  </span>
                                </dd>
                              </div>
                              <div className="bg-surface-muted/70 rounded-control min-w-0 p-3 min-[420px]:col-span-2 sm:col-span-1">
                                <dt className="text-caption text-text-muted">Priority</dt>
                                <dd className="mt-1">
                                  <StatusChip dense label={priority.label} tone={priority.tone} />
                                </dd>
                              </div>
                            </dl>
                            <div className="border-border-subtle mt-4 flex flex-wrap items-center justify-between gap-2 border-t pt-3">
                              <p className="text-caption text-text-muted">
                                Assigned task · #{task.id}
                              </p>
                              {isOwnProfile ? (
                                <Link
                                  to="/dashboard/my-tasks"
                                  search={{
                                    status: 'all',
                                    priority: 'all',
                                    sort: 'due_date',
                                    page: 1,
                                    task: task.id,
                                  }}
                                  aria-label={`Open task ${task.name}`}
                                  className="text-primary text-caption rounded-control hover:bg-primary-subtle/60 focus-visible:shadow-focus-ring inline-flex min-h-10 items-center gap-1.5 px-3 font-semibold focus-visible:outline-none"
                                >
                                  Open task <ArrowUpRight className="size-3.5" aria-hidden="true" />
                                </Link>
                              ) : null}
                            </div>
                          </article>
                        )
                      })}
                    </div>
                  ) : null}
                  {tasksQuery.data && !tasks.length ? (
                    <EmptyState
                      title="No assigned tasks"
                      description="There are no management tasks assigned to this employee."
                    />
                  ) : null}
                </Card>
              ) : null}
              {activeSection === 'work-reports' ? (
                <Card className="tablet:p-5 space-y-4 p-4">
                  <div className="flex flex-wrap items-start justify-between gap-3">
                    <div className="min-w-0">
                      <div className="flex flex-wrap items-center gap-2">
                        <h2 className="text-h2 font-semibold">Work reports</h2>
                        {workReportsQuery.data ? (
                          <StatusChip
                            dense
                            label={`${workReportsQuery.data.count} ${workReportsQuery.data.count === 1 ? 'report' : 'reports'}`}
                          />
                        ) : null}
                      </div>
                      <p className="text-caption text-text-secondary mt-1">
                        Daily submissions associated with this employee record.
                      </p>
                    </div>
                    <Link
                      to="/hr/work-report"
                      search={{ reportId: undefined, search: '', status: 'all', page: 1 }}
                      className="text-primary text-caption rounded-control hover:bg-primary-subtle/60 focus-visible:shadow-focus-ring inline-flex min-h-9 items-center gap-1.5 px-3 font-semibold focus-visible:outline-none"
                    >
                      Open HR review <ArrowUpRight className="size-3.5" aria-hidden="true" />
                    </Link>
                  </div>
                  {workReportsQuery.isPending && !workReportsQuery.data ? (
                    <Skeleton variant="card" />
                  ) : null}
                  {workReportsQuery.isError && !workReportsQuery.data ? (
                    <SectionErrorState
                      title="Work reports could not load"
                      error={workReportsQuery.error}
                      onRetry={() => void workReportsQuery.refetch()}
                    />
                  ) : null}
                  {workReportsQuery.data?.items.length ? (
                    <div className="space-y-2">
                      {workReportsQuery.data.items.map((report) => (
                        <article
                          key={report.id}
                          className="border-border-subtle from-surface via-surface to-surface-muted/50 shadow-elevation-sm rounded-surface min-w-0 border bg-gradient-to-br p-4 sm:p-5"
                        >
                          <div className="flex min-w-0 flex-col gap-3 min-[480px]:flex-row min-[480px]:items-start min-[480px]:justify-between">
                            <div className="flex min-w-0 items-start gap-3">
                              <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
                                <CalendarDays className="size-5" aria-hidden="true" />
                              </span>
                              <div className="min-w-0">
                                <h3 className="text-body font-semibold">
                                  {formatDateOnly(report.day)}
                                </h3>
                                <p className="text-caption text-text-secondary mt-1">
                                  {report.hoursWorked} reported hours
                                </p>
                              </div>
                            </div>
                            <StatusChip
                              label={formatStatus(report.status)}
                              tone={
                                report.status === 'approved'
                                  ? 'success'
                                  : report.status === 'rejected'
                                    ? 'danger'
                                    : report.status === 'submitted'
                                      ? 'info'
                                      : 'neutral'
                              }
                              className="max-w-full self-end min-[480px]:shrink-0 min-[480px]:self-start"
                            />
                          </div>
                          <div className="bg-surface-muted/60 border-border-subtle rounded-control mt-4 border p-3.5 sm:p-4">
                            <p className="text-body-sm text-text-secondary [overflow-wrap:anywhere]">
                              {report.summary || 'No summary provided'}
                            </p>
                            {report.feedback ? (
                              <p className="text-caption text-text-secondary border-border-subtle mt-3 border-t pt-3 [overflow-wrap:anywhere]">
                                <span className="text-text-primary font-semibold">
                                  Review feedback
                                </span>
                                <span aria-hidden="true"> · </span>
                                {report.feedback}
                              </p>
                            ) : null}
                          </div>
                          <div className="border-border-subtle mt-4 flex flex-wrap items-center justify-between gap-2 border-t pt-3">
                            <p className="text-caption text-text-muted">
                              Work report · #{report.id}
                            </p>
                            <Link
                              to="/hr/work-report"
                              search={{ reportId: report.id, search: '', status: 'all', page: 1 }}
                              aria-label={`Open work report from ${report.day} for HR review`}
                              className="text-primary text-caption rounded-control hover:bg-primary-subtle/60 focus-visible:shadow-focus-ring inline-flex min-h-10 items-center gap-1.5 px-3 font-semibold focus-visible:outline-none"
                            >
                              Review report <ArrowUpRight className="size-3.5" aria-hidden="true" />
                            </Link>
                          </div>
                        </article>
                      ))}
                    </div>
                  ) : null}
                  {workReportsQuery.data && workReportsQuery.data.items.length === 0 ? (
                    <EmptyState
                      title="No work reports"
                      description="No work reports are recorded for this employee."
                    />
                  ) : null}
                </Card>
              ) : null}
              {activeSection === 'leave' ? (
                <Card className="tablet:p-5 space-y-4 p-4">
                  <div className="flex flex-wrap items-start justify-between gap-3">
                    <div>
                      <div className="flex flex-wrap items-center gap-2">
                        <h2 className="text-h2 font-semibold">Leave history</h2>
                        {leaveQuery.data ? (
                          <StatusChip
                            dense
                            label={`${leaveQuery.data.length} ${leaveQuery.data.length === 1 ? 'record' : 'records'}`}
                          />
                        ) : null}
                      </div>
                      <p className="text-caption text-text-secondary mt-1">
                        Leave periods, expected returns, and confirmed dates.
                      </p>
                    </div>
                    {activeLeavePeriod || isLegacyLeave ? (
                      <Button
                        size="sm"
                        variant="outline"
                        leadingIcon={<CalendarClock className="size-4" aria-hidden="true" />}
                        onClick={() => {
                          leaveReturnMutation.reset()
                          setLeaveDialogMode('return')
                        }}
                      >
                        Return from leave
                      </Button>
                    ) : null}
                  </div>
                  {leaveQuery.isPending && !leaveQuery.data ? <Skeleton variant="card" /> : null}
                  {leaveQuery.isError && !leaveQuery.data ? (
                    <SectionErrorState
                      title="Leave history could not load"
                      error={leaveQuery.error}
                      onRetry={() => void leaveQuery.refetch()}
                    />
                  ) : null}
                  {isLegacyLeave && !hasLeaveRecord ? (
                    <Alert tone="warning" title="This is a legacy leave status">
                      No dated leave record exists yet. On return, enter the known original leave
                      details; the system will not invent a start date or reason.
                    </Alert>
                  ) : null}
                  {leaveQuery.data?.length ? (
                    <div className="space-y-3">
                      {leaveQuery.data.map((period: EmployeeLeavePeriodDto) => {
                        const reminderDue =
                          period.status === 'active' &&
                          period.review_reminder_date !== null &&
                          period.review_reminder_date <= today
                        const expectedReturnDue =
                          period.status === 'active' &&
                          period.expected_return_date !== null &&
                          period.expected_return_date <= today
                        return (
                          <article
                            key={period.id}
                            className="border-border-subtle from-surface via-surface to-surface-muted/50 shadow-elevation-sm rounded-surface min-w-0 border bg-gradient-to-br p-4 sm:p-5"
                          >
                            <div className="flex min-w-0 flex-col gap-3 min-[480px]:flex-row min-[480px]:items-start min-[480px]:justify-between">
                              <div className="min-w-0">
                                <p className="text-caption text-text-muted">
                                  {formatDateOnly(period.start_date)}
                                </p>
                                <h3 className="text-body mt-1 font-semibold">
                                  {period.leave_type_label}
                                </h3>
                              </div>
                              <StatusChip
                                label={formatStatus(period.status)}
                                tone={
                                  period.status === 'active'
                                    ? 'warning'
                                    : period.status === 'returned'
                                      ? 'success'
                                      : 'neutral'
                                }
                                className="self-start min-[480px]:shrink-0"
                              />
                            </div>
                            {reminderDue || expectedReturnDue ? (
                              <Alert
                                className="mt-4"
                                tone="warning"
                                title={
                                  reminderDue
                                    ? 'Leave review reminder is due'
                                    : 'Expected return needs confirmation'
                                }
                              >
                                {reminderDue
                                  ? `Review this leave record. The reminder date was ${formatDateOnly(period.review_reminder_date)}.`
                                  : `The expected return date was ${formatDateOnly(period.expected_return_date)}. Confirm with HR; no automatic status change was made.`}
                              </Alert>
                            ) : null}
                            <p className="text-body-sm text-text-secondary mt-3 break-words">
                              {period.reason}
                            </p>
                            <dl className="border-border-subtle mt-4 grid min-w-0 grid-cols-1 gap-3 border-t pt-4 min-[480px]:grid-cols-2 xl:grid-cols-4">
                              <DataField
                                label="Leave started"
                                value={formatDateOnly(period.start_date)}
                              />
                              <DataField
                                label="Expected return"
                                value={formatDateOnly(period.expected_return_date)}
                              />
                              {period.review_reminder_date ? (
                                <DataField
                                  label="HR review reminder"
                                  value={formatDateOnly(period.review_reminder_date)}
                                />
                              ) : null}
                              {period.actual_return_date ? (
                                <DataField
                                  label="Actual return"
                                  value={formatDateOnly(period.actual_return_date)}
                                />
                              ) : null}
                              <DataField label="Recorded by" value={period.created_by_name} />
                              {period.returned_by_name ? (
                                <DataField
                                  label="Return recorded by"
                                  value={period.returned_by_name}
                                />
                              ) : null}
                            </dl>
                            {period.status === 'active' ? (
                              <div className="border-border-subtle mt-4 flex justify-end border-t pt-3">
                                <Button
                                  size="sm"
                                  variant="outline"
                                  onClick={() => {
                                    leaveReturnMutation.reset()
                                    setLeaveDialogMode('return')
                                  }}
                                >
                                  Record return
                                </Button>
                              </div>
                            ) : null}
                          </article>
                        )
                      })}
                    </div>
                  ) : null}
                  {leaveQuery.data && leaveQuery.data.length === 0 && !isLegacyLeave ? (
                    <EmptyState
                      title="No leave history"
                      description="A dated record will appear here when HR places the employee on leave."
                    />
                  ) : null}
                </Card>
              ) : null}
            </div>
          </>
        ) : null}
      </div>
      {employee ? (
        <EmployeeEditor
          open={editorOpen}
          employee={employee}
          onClose={() => {
            if (!updateMutation.isPending) setEditorOpen(false)
          }}
          onSave={(input, profileImage) => updateMutation.mutate({ input, profileImage })}
          isSaving={updateMutation.isPending}
          error={updateMutation.error}
        />
      ) : null}
      {reviewEditorOpen ? (
        <ReviewEditor
          key={reviewTarget?.id ?? 'new'}
          open={reviewEditorOpen}
          review={reviewTarget}
          onClose={() => {
            if (!reviewSaveMutation.isPending) {
              setReviewEditorOpen(false)
              setReviewTarget(null)
            }
          }}
          onSave={(input) => reviewSaveMutation.mutate({ review: reviewTarget, input })}
          saving={reviewSaveMutation.isPending}
          error={reviewSaveMutation.error}
        />
      ) : null}
      {employee && leaveDialogMode === 'start' ? (
        <EmployeeLeaveFormDialog
          key="start-leave"
          mode="start"
          employee={employee}
          isPending={leaveStartMutation.isPending}
          error={leaveStartMutation.error}
          onClose={() => {
            if (!leaveStartMutation.isPending) setLeaveDialogMode(null)
          }}
          onConfirm={(input) => leaveStartMutation.mutate(input)}
        />
      ) : null}
      {employee && leaveDialogMode === 'return' ? (
        <EmployeeLeaveFormDialog
          key={`return-leave-${activeLeavePeriod?.id ?? 'legacy'}`}
          mode="return"
          employee={employee}
          period={activeLeavePeriod}
          isPending={leaveReturnMutation.isPending}
          error={leaveReturnMutation.error}
          onClose={() => {
            if (!leaveReturnMutation.isPending) setLeaveDialogMode(null)
          }}
          onConfirm={(input) => leaveReturnMutation.mutate(input)}
        />
      ) : null}
      <Dialog
        open={Boolean(deleteReview)}
        onOpenChange={(open) => {
          if (!open && !reviewDeleteMutation.isPending) setDeleteReview(null)
        }}
        title="Delete review"
        description="This review will be permanently removed from the employee record."
        size="sm"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button variant="outline" onClick={() => setDeleteReview(null)}>
              Keep review
            </Button>
            <Button
              variant="danger"
              onClick={() => deleteReview && reviewDeleteMutation.mutate(deleteReview)}
              isLoading={reviewDeleteMutation.isPending}
            >
              Delete review
            </Button>
          </>
        }
      >
        {reviewDeleteMutation.error ? (
          <Alert tone="danger" role="alert" title="Review could not be deleted">
            Retry the action or keep the review.
          </Alert>
        ) : (
          <p className="text-body-sm text-text-secondary">
            Delete {deleteReview?.quarter} {deleteReview?.year} review?
          </p>
        )}
      </Dialog>
      <Dialog
        open={Boolean(documentToDelete)}
        onOpenChange={(open) => {
          if (!open && !deleteDocumentMutation.isPending) setDocumentToDelete(null)
        }}
        title="Delete document"
        description="This file will be removed from the employee record."
        size="sm"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button
              variant="outline"
              disabled={deleteDocumentMutation.isPending}
              onClick={() => setDocumentToDelete(null)}
            >
              Keep document
            </Button>
            <Button
              variant="danger"
              isLoading={deleteDocumentMutation.isPending}
              onClick={() => documentToDelete && deleteDocumentMutation.mutate(documentToDelete)}
            >
              Delete document
            </Button>
          </>
        }
      >
        {deleteDocumentMutation.error ? (
          <Alert tone="danger" role="alert" title="Document could not be deleted">
            The file is still attached. Retry or keep the document.
          </Alert>
        ) : (
          <p className="text-body-sm text-text-secondary">Delete {documentToDelete?.name}?</p>
        )}
      </Dialog>
      <Dialog
        open={deactivateOpen}
        onOpenChange={(open) => {
          if (!open && !statusMutation.isPending) setDeactivateOpen(false)
        }}
        title="Deactivate employee"
        description="The employee record will be retained and their login access will be disabled."
        size="sm"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button
              variant="outline"
              disabled={statusMutation.isPending}
              onClick={() => setDeactivateOpen(false)}
            >
              Cancel
            </Button>
            <Button
              variant="danger"
              isLoading={statusMutation.isPending}
              onClick={() => statusMutation.mutate('inactive')}
            >
              Deactivate
            </Button>
          </>
        }
      >
        {statusMutation.error ? (
          <Alert tone="danger" role="alert" title="Employee could not be deactivated">
            No changes were saved. Retry the action.
          </Alert>
        ) : (
          <p className="text-body-sm text-text-secondary">
            Deactivate {title}? They can be reactivated later.
          </p>
        )}
      </Dialog>
      <Dialog
        open={exitOpen}
        onOpenChange={(open) => {
          if (!open && !exitMutation.isPending) setExitOpen(false)
        }}
        title="Exit employee"
        description="This action is immediate. It records an exit date and disables the employee account."
        size="md"
        footer={
          <>
            <Button
              variant="outline"
              disabled={exitMutation.isPending}
              onClick={() => setExitOpen(false)}
            >
              Cancel
            </Button>
            <Button
              variant="danger"
              isLoading={exitMutation.isPending}
              disabled={!exitReason.trim() || !exitDate || exitDate > today}
              onClick={() => exitMutation.mutate()}
            >
              Confirm exit
            </Button>
          </>
        }
      >
        <div className="space-y-4">
          {exitMutation.error ? (
            <Alert tone="danger" role="alert" title="Exit could not be recorded">
              The employee is still active. Correct the details and retry.
            </Alert>
          ) : null}
          <FormControl id="employee-exit-date" label="Exit date" required>
            <DatePickerField
              id="employee-exit-date"
              value={exitDate}
              max={today}
              onValueChange={setExitDate}
              required
            />
          </FormControl>
          <FormControl id="employee-exit-reason" label="Reason for exit" required>
            <TextArea
              rows={4}
              maxLength={2000}
              value={exitReason}
              onChange={(event) => setExitReason(event.currentTarget.value)}
              placeholder="Provide a concise reason"
              required
            />
          </FormControl>
          {exitDate > today ? (
            <p className="text-caption text-danger" role="alert">
              Exit date must be today or earlier.
            </p>
          ) : null}
        </div>
      </Dialog>
    </PageLayout>
  )
}

function ProfileSection({
  title,
  icon,
  fields,
}: {
  title: string
  icon: React.ReactNode
  fields: Array<[string, unknown]>
}) {
  return (
    <Card className="tablet:p-5 space-y-4 p-4">
      <div className="flex items-center gap-2">
        <span className="text-primary" aria-hidden="true">
          {icon}
        </span>
        <h2 className="text-h2 font-semibold">{title}</h2>
      </div>
      <dl className="grid min-w-0 gap-4 sm:grid-cols-2">
        {fields.map(([label, value]) => (
          <DataField key={label} label={label} value={value} />
        ))}
      </dl>
    </Card>
  )
}
