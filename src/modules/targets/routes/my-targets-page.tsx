import { useState, type FormEvent } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useForm } from '@tanstack/react-form'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  ArrowRight,
  CalendarDays,
  CircleAlert,
  CircleMinus,
  CheckCircle2,
  ChevronLeft,
  ChevronRight,
  Clock3,
  Flag,
  Target as TargetIcon,
  type LucideIcon,
} from 'lucide-react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'
import { PageLayout } from '@/shared/ui/page-layout'
import { ProgressBar } from '@/shared/ui/progress-bar'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'
import { useToast } from '@/shared/feedback/use-toast'

import {
  targetsApi,
  type EmployeeTarget,
  type TargetPeriod,
  type TargetReport,
  type TargetReportStatus,
} from '../targets.api'
import {
  assignedTargetsQueryOptions,
  targetReportDetailQueryOptions,
  targetReportsQueryOptions,
  targetsQueryKeys,
} from '../targets.queries'
import type { MyTargetsSearch } from '../targets.search'

const PAGE_SIZE = 10

const periods: { value: MyTargetsSearch['period']; label: string }[] = [
  { value: 'all', label: 'All periods' },
  { value: 'daily', label: 'Daily' },
  { value: 'weekly', label: 'Weekly' },
  { value: 'monthly', label: 'Monthly' },
  { value: 'quarterly', label: 'Quarterly' },
  { value: 'yearly', label: 'Yearly' },
  { value: 'custom', label: 'Custom' },
]

const targetScopeOptions = [
  { value: 'active', label: 'Active targets' },
  { value: 'all', label: 'All targets' },
]

const reportStatuses: {
  value: MyTargetsSearch['status']
  label: string
  tone: StatusTone
  icon: LucideIcon
  accent: string
}[] = [
  { value: 'all', label: 'All reports', tone: 'primary', icon: TargetIcon, accent: 'text-primary' },
  {
    value: 'submitted',
    label: 'In review',
    tone: 'info',
    icon: Clock3,
    accent: 'text-info-foreground',
  },
  {
    value: 'approved',
    label: 'Approved',
    tone: 'success',
    icon: CheckCircle2,
    accent: 'text-success-foreground',
  },
  {
    value: 'rejected',
    label: 'Needs revision',
    tone: 'danger',
    icon: CircleAlert,
    accent: 'text-danger-foreground',
  },
]

function dateLabel(value: string): string {
  const [year, month, day] = value.split('-').map(Number)
  if (!year || !month || !day) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(new Date(year, month - 1, day))
}

function amountLabel(value: number, unit: string): string {
  const amount = new Intl.NumberFormat(undefined, { maximumFractionDigits: 2 }).format(value)
  if (!unit) return amount

  const normalizedUnit = unit.trim()
  let displayedUnit = normalizedUnit
  if (Math.abs(value) === 1) {
    const lowerUnit = normalizedUnit.toLocaleLowerCase()
    const irregularUnits: Record<string, string> = {
      gas: 'gas',
      news: 'news',
      series: 'series',
      status: 'status',
      statuses: 'status',
    }
    displayedUnit =
      irregularUnits[lowerUnit] ??
      (/ies$/i.test(normalizedUnit)
        ? `${normalizedUnit.slice(0, -3)}y`
        : /sses$/i.test(normalizedUnit)
          ? normalizedUnit.slice(0, -2)
          : /s$/i.test(normalizedUnit) && !/(ss|us|is)$/i.test(normalizedUnit)
            ? normalizedUnit.slice(0, -1)
            : normalizedUnit)
  }
  return `${amount} ${displayedUnit}`
}

function periodLabel(period: TargetPeriod): string {
  return period.charAt(0).toUpperCase() + period.slice(1)
}

type TargetAvailability = 'inactive' | 'upcoming' | 'ended' | 'open'

function localDateKey(date = new Date()): string {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

function targetAvailability(target: EmployeeTarget): TargetAvailability {
  if (!target.isActive) return 'inactive'
  const today = localDateKey()
  if (today < target.periodStart) return 'upcoming'
  if (today > target.periodEnd) return 'ended'
  return 'open'
}

function targetCanAcceptProgress(target: EmployeeTarget): boolean {
  return targetAvailability(target) === 'open' && !target.isCompleted && !target.hasPendingReport
}

function followUpMessage(
  target: EmployeeTarget | undefined,
  options: { isPending: boolean; isError: boolean },
): string {
  if (!target) {
    if (options.isPending) return 'Checking whether this target can accept another report.'
    if (options.isError) return 'Target availability could not be confirmed. Refresh and try again.'
    return 'This target is no longer available in your assigned targets.'
  }
  if (target.hasPendingReport) {
    return 'Another progress report is already in review. Wait for that decision before submitting again.'
  }
  if (target.isCompleted) return 'This target is complete, so no further progress can be submitted.'
  switch (targetAvailability(target)) {
    case 'inactive':
      return 'This target is inactive. Ask your manager to reactivate it before submitting corrected progress.'
    case 'upcoming':
      return `This target opens on ${dateLabel(target.periodStart)}. Submit corrected progress during its reporting period.`
    case 'ended':
      return 'This target period has ended. Ask your manager to extend or reactivate it before submitting corrected progress.'
    case 'open':
      return 'Correct the reviewer feedback and submit a new progress report. The rejected report remains in your history.'
  }
}

function reportStatus(status: TargetReportStatus): {
  label: string
  tone: StatusTone
  icon: LucideIcon
} {
  switch (status) {
    case 'submitted':
      return { label: 'In review', tone: 'info', icon: Clock3 }
    case 'approved':
      return { label: 'Approved', tone: 'success', icon: CheckCircle2 }
    case 'rejected':
      return { label: 'Needs revision', tone: 'danger', icon: CircleAlert }
  }
}

function TargetReportStatusChip({
  status,
  dense = false,
}: {
  status: TargetReportStatus
  dense?: boolean
}) {
  const state = reportStatus(status)
  const StatusIcon = state.icon
  return (
    <StatusChip
      label={state.label}
      tone={state.tone}
      dense={dense}
      icon={<StatusIcon className={dense ? 'size-3' : 'size-3.5'} />}
    />
  )
}

function TargetState({ target }: { target: EmployeeTarget }) {
  const availability = targetAvailability(target)
  if (target.isCompleted) {
    return (
      <StatusChip
        label="Completed"
        tone="success"
        dense
        icon={<CheckCircle2 className="size-3" />}
      />
    )
  }
  if (target.hasPendingReport) {
    return (
      <StatusChip
        label="Progress in review"
        tone="info"
        dense
        icon={<Clock3 className="size-3" />}
      />
    )
  }
  if (availability === 'inactive') {
    return (
      <StatusChip label="Inactive" tone="neutral" dense icon={<CircleMinus className="size-3" />} />
    )
  }
  if (availability === 'upcoming') {
    return (
      <StatusChip
        label="Upcoming"
        tone="neutral"
        dense
        icon={<CalendarDays className="size-3" />}
      />
    )
  }
  if (availability === 'ended') {
    return (
      <StatusChip
        label="Period ended"
        tone="neutral"
        dense
        icon={<CircleMinus className="size-3" />}
      />
    )
  }
  return <StatusChip label="Active" tone="primary" dense icon={<Flag className="size-3" />} />
}

function ProgressValue({ target }: { target: EmployeeTarget }) {
  const percentage = Math.min(100, Math.max(0, target.progressPercentage))
  return (
    <div className="min-w-0 space-y-1.5">
      <div className="flex items-baseline justify-between gap-3">
        <span className="text-body-sm text-text-primary font-semibold">
          {amountLabel(target.approvedProgressValue, target.unit)}
          <span className="text-text-secondary font-normal">
            {' '}
            / {amountLabel(target.targetValue, target.unit)}
          </span>
        </span>
        <span className="text-caption text-text-secondary shrink-0 font-semibold tabular-nums">
          {percentage.toFixed(0)}%
        </span>
      </div>
      <ProgressBar value={percentage} label={`${target.title} approved progress`} />
      <p className="text-caption text-text-secondary leading-snug">
        {target.isCompleted
          ? 'Target reached'
          : `${amountLabel(target.remainingValue, target.unit)} remaining`}
      </p>
    </div>
  )
}

function TargetRow({
  target,
  canSubmit,
  onSubmit,
  onView,
}: {
  target: EmployeeTarget
  canSubmit: boolean
  onSubmit: (target: EmployeeTarget) => void
  onView: (target: EmployeeTarget) => void
}) {
  const canReportProgress = canSubmit && targetCanAcceptProgress(target)

  return (
    <>
      <div className="target-table-row hover:bg-surface-muted/55 border-border-subtle desktop:px-5 min-w-0 grid-cols-[minmax(12rem,1.4fr)_minmax(8rem,.7fr)_minmax(12rem,1.2fr)_minmax(9rem,.8fr)_minmax(9rem,.9fr)] gap-3 border-b px-4 py-4 last:border-b-0">
        <div className="min-w-0">
          <p className="text-label text-text-primary font-semibold">{target.title}</p>
          {target.description ? (
            <p className="text-caption text-text-secondary mt-1 line-clamp-2">
              {target.description}
            </p>
          ) : null}
        </div>
        <div className="min-w-0">
          <p className="text-body-sm text-text-primary">{periodLabel(target.period)}</p>
          <p className="text-caption text-text-secondary mt-1">
            {dateLabel(target.periodStart)} – {dateLabel(target.periodEnd)}
          </p>
        </div>
        <ProgressValue target={target} />
        <TargetState target={target} />
        <div className="flex flex-wrap justify-end gap-1.5">
          <Button
            variant="ghost"
            size="sm"
            aria-label={`View details for ${target.title}`}
            onClick={() => onView(target)}
          >
            Details <ChevronRight className="size-4" />
          </Button>
          {target.hasPendingReport ? (
            <Button
              variant="outline"
              size="sm"
              disabled
              className="cursor-not-allowed"
              leadingIcon={<Clock3 className="text-info-foreground size-4" />}
            >
              Review pending
            </Button>
          ) : canReportProgress ? (
            <Button
              variant="primary"
              size="sm"
              onClick={() => onSubmit(target)}
              leadingIcon={<Flag className="size-4" />}
            >
              Report progress
            </Button>
          ) : null}
        </div>
      </div>

      <Card className="target-card-row space-y-3 p-4">
        <div className="grid grid-cols-[minmax(0,1fr)_auto] items-start gap-x-3 gap-y-2">
          <div className="min-w-0">
            <p className="text-label text-text-primary font-semibold">{target.title}</p>
            {target.description ? (
              <p className="text-body-sm text-text-secondary mt-1 line-clamp-2">
                {target.description}
              </p>
            ) : null}
          </div>
          <div className="justify-self-end">
            <TargetState target={target} />
          </div>
        </div>
        <div className="text-caption text-text-secondary flex flex-wrap items-center gap-x-4 gap-y-1">
          <span className="inline-flex items-center gap-1.5">
            <CalendarDays className="text-primary size-3.5" aria-hidden="true" />
            {periodLabel(target.period)}
          </span>
          <span>
            {dateLabel(target.periodStart)} – {dateLabel(target.periodEnd)}
          </span>
        </div>
        <ProgressValue target={target} />
        <div className="border-border-subtle flex flex-wrap gap-2 border-t pt-3">
          <Button
            variant="outline"
            size="sm"
            className="min-w-28 flex-1"
            aria-label={`View details for ${target.title}`}
            onClick={() => onView(target)}
          >
            View details <ChevronRight className="size-4" />
          </Button>
          {target.hasPendingReport ? (
            <Button
              variant="outline"
              size="sm"
              className="min-w-28 flex-1"
              disabled
              leadingIcon={<Clock3 className="text-info-foreground size-4" />}
            >
              Review pending
            </Button>
          ) : canReportProgress ? (
            <Button
              variant="primary"
              size="sm"
              className="min-w-28 flex-1"
              onClick={() => onSubmit(target)}
              leadingIcon={<Flag className="size-4" />}
            >
              Report progress
            </Button>
          ) : null}
        </div>
      </Card>
    </>
  )
}

function TargetReportRow({
  report,
  canViewDetail,
  followUpTarget,
  onCorrect,
  onView,
}: {
  report: TargetReport
  canViewDetail: boolean
  followUpTarget?: EmployeeTarget
  onCorrect: (target: EmployeeTarget) => void
  onView: (report: TargetReport) => void
}) {
  return (
    <>
      <div className="desktop:grid desktop:grid-cols-[6.5rem_minmax(13rem,1.5fr)_7rem_minmax(12rem,1fr)] desktop:items-center desktop:gap-4 desktop:px-5 border-border-subtle hidden min-w-0 gap-3 border-b px-4 py-4 last:border-b-0">
        <time className="text-body-sm text-text-secondary" dateTime={report.createdAt}>
          {dateLabel(report.createdAt.slice(0, 10))}
        </time>
        <div className="min-w-0">
          <p className="text-label text-text-primary font-semibold">{report.target.title}</p>
          <p className="text-caption text-text-secondary mt-1 line-clamp-2">{report.summary}</p>
        </div>
        <span className="text-body-sm text-text-primary font-medium tabular-nums">
          {amountLabel(report.progressValue, report.target.unit)}
        </span>
        <div className="flex min-w-0 flex-col items-start gap-1.5">
          <TargetReportStatusChip status={report.status} dense />
          {report.status === 'rejected' && followUpTarget ? (
            <Button
              variant="ghost"
              size="sm"
              className="-ml-2 text-left whitespace-normal"
              onClick={() => onCorrect(followUpTarget)}
            >
              Submit corrected progress <ChevronRight className="size-4 shrink-0" />
            </Button>
          ) : canViewDetail ? (
            <Button
              variant="ghost"
              size="sm"
              aria-label={`${report.status === 'rejected' ? 'Review feedback for' : 'View'} ${report.target.title} report`}
              onClick={() => onView(report)}
            >
              {report.status === 'rejected' ? 'Review feedback' : 'View details'}{' '}
              <ChevronRight className="size-4" />
            </Button>
          ) : null}
        </div>
        {report.status === 'rejected' && report.rejectionReason ? (
          <div className="desktop:col-span-4 border-border-subtle border-t pt-3">
            <Alert tone="danger" title="Reviewer feedback" className="py-2.5">
              {report.rejectionReason}
            </Alert>
          </div>
        ) : null}
      </div>

      <Card className="desktop:hidden space-y-3 p-4">
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0">
            <p className="text-caption text-text-secondary">
              {dateLabel(report.createdAt.slice(0, 10))}
            </p>
            <p className="text-label text-text-primary mt-1 font-semibold">{report.target.title}</p>
          </div>
          <TargetReportStatusChip status={report.status} dense />
        </div>
        <p className="text-body-sm text-text-secondary line-clamp-3">{report.summary}</p>
        <div className="border-border-subtle flex items-center justify-between gap-3 border-t pt-3">
          <span className="text-label text-text-primary font-semibold">
            {amountLabel(report.progressValue, report.target.unit)} submitted
          </span>
          {report.status === 'rejected' && followUpTarget ? (
            <Button
              variant="ghost"
              size="sm"
              className="text-right whitespace-normal"
              onClick={() => onCorrect(followUpTarget)}
            >
              Submit corrected progress <ChevronRight className="size-4 shrink-0" />
            </Button>
          ) : canViewDetail ? (
            <Button
              variant="ghost"
              size="sm"
              aria-label={`${report.status === 'rejected' ? 'Review feedback for' : 'View'} ${report.target.title} report`}
              onClick={() => onView(report)}
            >
              {report.status === 'rejected' ? 'Review feedback' : 'Details'}{' '}
              <ChevronRight className="size-4" />
            </Button>
          ) : null}
        </div>
        {report.status === 'rejected' && report.rejectionReason ? (
          <Alert tone="danger" title="Reviewer feedback" className="py-2.5">
            {report.rejectionReason}
          </Alert>
        ) : null}
      </Card>
    </>
  )
}

function Pagination({
  page,
  count,
  onPage,
}: {
  page: number
  count: number
  onPage: (page: number) => void
}) {
  const pageCount = Math.max(1, Math.ceil(count / PAGE_SIZE))
  return (
    <div className="border-border-subtle tablet:px-5 flex items-center justify-between gap-3 border-t px-4 py-3">
      <p className="text-caption text-text-secondary">
        Page {page} of {pageCount} <span className="phone:inline hidden">· {count} total</span>
      </p>
      <div className="flex items-center gap-2">
        <Button
          variant="outline"
          size="sm"
          disabled={page <= 1}
          onClick={() => onPage(page - 1)}
          leadingIcon={<ChevronLeft className="size-4" />}
        >
          Previous
        </Button>
        <Button
          variant="outline"
          size="sm"
          disabled={page >= pageCount}
          onClick={() => onPage(page + 1)}
        >
          Next <ChevronRight className="size-4" />
        </Button>
      </div>
    </div>
  )
}

interface ProgressValues {
  amount: string
  summary: string
}

export function MyTargetsPage() {
  const search = useSearch({ from: '/_protected/dashboard/my-target-reports' })
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const toast = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const canReadTargets = Boolean(
    session &&
    (hasPermission(session.permissions, 'employee_targets', 'list_own') ||
      hasPermission(session.permissions, 'employee_targets', 'list')),
  )
  const canReadReports = Boolean(
    session &&
    (hasPermission(session.permissions, 'target_reports', 'list_own') ||
      hasPermission(session.permissions, 'target_reports', 'list')),
  )
  const canCreateReport = Boolean(
    session && hasPermission(session.permissions, 'target_reports', 'create'),
  )
  const canViewReportDetail = Boolean(
    session &&
    (hasPermission(session.permissions, 'target_reports', 'view_own') ||
      hasPermission(session.permissions, 'target_reports', 'view')),
  )
  const canSubmit = canReadTargets && canCreateReport

  const targetParams = {
    scope: search.scope,
    period: search.period,
    limit: PAGE_SIZE,
    offset: (search.targetsPage - 1) * PAGE_SIZE,
  } as const
  const reportParams = {
    status: search.status,
    limit: PAGE_SIZE,
    offset: (search.reportsPage - 1) * PAGE_SIZE,
  } as const
  const targetQuery = useQuery({
    ...assignedTargetsQueryOptions(userId, employeeId, targetParams),
    enabled: canReadTargets,
  })
  const reportQuery = useQuery({
    ...targetReportsQueryOptions(userId, employeeId, reportParams),
    enabled: canReadReports,
  })
  const reportItems = reportQuery.data?.items ?? []
  const needsFollowUpTargets =
    canSubmit && reportItems.some((report) => report.status === 'rejected')
  const followUpTargetsQuery = useQuery({
    ...assignedTargetsQueryOptions(userId, employeeId, {
      scope: 'all',
      period: 'all',
      limit: 100,
      offset: 0,
    }),
    enabled: needsFollowUpTargets,
  })
  const [selectedTarget, setSelectedTarget] = useState<EmployeeTarget | null>(null)
  const [isCorrection, setIsCorrection] = useState(false)
  const [targetForDetails, setTargetForDetails] = useState<EmployeeTarget | null>(null)
  const [progressOpen, setProgressOpen] = useState(false)
  const [formError, setFormError] = useState<string | null>(null)
  const [openReport, setOpenReport] = useState<TargetReport | null>(null)
  const reportDetailQuery = useQuery({
    ...targetReportDetailQueryOptions(userId, employeeId, openReport?.id ?? 0),
    enabled: Boolean(openReport && canViewReportDetail),
  })
  const followUpTargets = followUpTargetsQuery.data?.items ?? targetQuery.data?.items ?? []
  function eligibleFollowUpTarget(report: TargetReport): EmployeeTarget | undefined {
    const target = followUpTargets.find((candidate) => candidate.id === report.employeeTargetId)
    return canSubmit && target && targetCanAcceptProgress(target) ? target : undefined
  }

  const createMutation = useMutation({ mutationFn: targetsApi.createReport })
  const progressForm = useForm({
    defaultValues: { amount: '', summary: '' } as ProgressValues,
    onSubmit: async ({ value }) => {
      if (!selectedTarget) return
      setFormError(null)
      try {
        const created = await createMutation.mutateAsync({
          employee_target_id: selectedTarget.id,
          progress_value: Number(value.amount),
          summary: value.summary.trim(),
        })
        await Promise.all([
          queryClient.invalidateQueries({
            queryKey: targetsQueryKeys.assigned(userId, employeeId),
          }),
          queryClient.invalidateQueries({ queryKey: targetsQueryKeys.reports(userId, employeeId) }),
        ])
        toast.showToast({
          title: isCorrection ? 'Corrected progress submitted' : 'Progress submitted',
          description: isCorrection
            ? 'Your corrected progress has been sent as a new report for review.'
            : 'Your target progress has been sent for review.',
          tone: 'success',
        })
        setProgressOpen(false)
        setSelectedTarget(null)
        setIsCorrection(false)
        progressForm.reset()
        setFormError(null)
        void created
      } catch (error) {
        setFormError(presentError(error, 'form-submit').message)
      }
    },
  })

  function updateSearch(updates: Partial<MyTargetsSearch>) {
    void navigate({
      to: '/dashboard/my-target-reports',
      search: (previous: MyTargetsSearch) => ({ ...previous, ...updates }),
      resetScroll: false,
    })
  }

  function openProgress(target: EmployeeTarget, correction = false) {
    setSelectedTarget(target)
    setIsCorrection(correction)
    setFormError(null)
    progressForm.reset({ amount: '', summary: '' })
    setProgressOpen(true)
  }

  function submitProgress(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setFormError(null)
    void progressForm.handleSubmit()
  }

  if (sessionQuery.isPending) {
    return (
      <PageLayout title="My Targets" subtitle="Track assigned goals and report approved progress.">
        <div className="space-y-5" aria-label="Loading targets" role="status">
          <Skeleton variant="title" />
          <Skeleton variant="card" />
          <Skeleton variant="title" />
          <Skeleton variant="card" />
        </div>
      </PageLayout>
    )
  }

  if (sessionQuery.isError || !session) {
    return (
      <PageLayout title="My Targets" subtitle="Track assigned goals and report approved progress.">
        <SectionErrorState
          title="Targets could not be opened"
          description="Your employee access could not be confirmed. Reload the page and try again."
          error={sessionQuery.error}
          onRetry={() => void sessionQuery.refetch()}
        />
      </PageLayout>
    )
  }

  const canViewAnySection = canReadTargets || canReadReports
  const targetItems = targetQuery.data?.items ?? []
  const reportDetail = reportDetailQuery.data
  const rejectedTargetForFollowUp =
    reportDetail?.status === 'rejected'
      ? followUpTargets.find((target) => target.id === reportDetail.employeeTargetId)
      : undefined
  const canSubmitFollowUp = Boolean(
    canSubmit && rejectedTargetForFollowUp && targetCanAcceptProgress(rejectedTargetForFollowUp),
  )
  const formSubmitting = progressForm.state.isSubmitting || createMutation.isPending

  return (
    <>
      <PageLayout
        title="My Targets"
        subtitle="Track assigned goals and report approved progress."
        leading={<TargetIcon className="size-[18px]" aria-hidden="true" />}
      >
        {!canViewAnySection ? (
          <EmptyState
            icon={<TargetIcon className="size-6" />}
            title="Target access is unavailable"
            description="Your role does not include access to assigned targets or target progress history."
          />
        ) : (
          <div className="space-y-8">
            {canReadTargets ? (
              <section aria-labelledby="assigned-targets-heading" className="space-y-4">
                <div className="tablet:flex-row tablet:items-end tablet:justify-between flex flex-col gap-3">
                  <div>
                    <h2 id="assigned-targets-heading" className="text-h2 font-semibold">
                      Assigned targets
                    </h2>
                    <p className="text-body-sm text-text-secondary mt-1">
                      Approved progress is cumulative. Each report below remains a separate review
                      record.
                    </p>
                  </div>
                  <p className="text-caption text-text-secondary shrink-0">
                    {targetQuery.data ? `${targetQuery.data.count} targets` : 'Your assigned goals'}
                  </p>
                </div>

                <div className="rounded-control border-border-subtle bg-surface tablet:p-4 border p-3">
                  <div className="phone:grid-cols-2 tablet:flex tablet:items-end grid grid-cols-1 gap-3">
                    <DropdownSelect
                      id="target-scope"
                      label="Target scope"
                      value={search.scope}
                      options={targetScopeOptions}
                      onChange={(scope) =>
                        updateSearch({ scope: scope as MyTargetsSearch['scope'], targetsPage: 1 })
                      }
                      className="tablet:w-44"
                    />
                    <DropdownSelect
                      id="target-period"
                      label="Period"
                      value={search.period}
                      options={periods}
                      onChange={(period) =>
                        updateSearch({
                          period: period as MyTargetsSearch['period'],
                          targetsPage: 1,
                        })
                      }
                      className="tablet:w-44"
                    />
                  </div>
                </div>

                {targetQuery.isError && !targetQuery.data ? (
                  <SectionErrorState
                    description="Assigned targets could not be loaded. Try again."
                    error={targetQuery.error}
                    onRetry={() => void targetQuery.refetch()}
                  />
                ) : null}
                {targetQuery.isError && targetQuery.data ? (
                  <Alert tone="warning" title="Showing saved target data">
                    The latest refresh failed. Your last loaded targets remain available.
                    <Button variant="ghost" size="sm" onClick={() => void targetQuery.refetch()}>
                      Retry
                    </Button>
                  </Alert>
                ) : null}
                {targetQuery.isPending ? (
                  <div className="space-y-2" aria-label="Loading assigned targets" role="status">
                    <Skeleton variant="row" />
                    <Skeleton variant="row" />
                    <Skeleton variant="row" />
                  </div>
                ) : targetItems.length === 0 && !targetQuery.isError ? (
                  <Card className="p-1">
                    <EmptyState
                      icon={<TargetIcon className="size-6" />}
                      title={
                        search.scope === 'active' || search.period !== 'all'
                          ? 'No targets match these filters'
                          : 'No targets assigned yet'
                      }
                      description={
                        search.scope === 'active' || search.period !== 'all'
                          ? 'Change the scope or period to view other assigned targets.'
                          : 'Assigned goals will appear here when they are set for your role.'
                      }
                    />
                  </Card>
                ) : targetItems.length > 0 ? (
                  <div className="target-list-container rounded-control border-border-subtle bg-surface overflow-hidden border">
                    <div className="target-table-header bg-surface-muted text-overline text-text-secondary grid-cols-[minmax(12rem,1.4fr)_minmax(8rem,.7fr)_minmax(12rem,1.2fr)_minmax(9rem,.8fr)_minmax(9rem,.9fr)] gap-4 px-5 py-3 font-semibold">
                      <span>Target</span>
                      <span>Period</span>
                      <span>Approved progress</span>
                      <span>Status</span>
                      <span className="text-right">Actions</span>
                    </div>
                    <div className="divide-border-subtle desktop:divide-y-0 divide-y">
                      {targetItems.map((target) => (
                        <TargetRow
                          key={target.id}
                          target={target}
                          canSubmit={canSubmit}
                          onSubmit={openProgress}
                          onView={setTargetForDetails}
                        />
                      ))}
                    </div>
                    <Pagination
                      page={search.targetsPage}
                      count={targetQuery.data?.count ?? 0}
                      onPage={(targetsPage) => updateSearch({ targetsPage })}
                    />
                  </div>
                ) : null}
              </section>
            ) : null}

            {canReadReports ? (
              <section aria-labelledby="progress-history-heading" className="space-y-4">
                <div className="tablet:flex-row tablet:items-end tablet:justify-between flex flex-col gap-3">
                  <div>
                    <h2 id="progress-history-heading" className="text-h2 font-semibold">
                      Progress history
                    </h2>
                    <p className="text-body-sm text-text-secondary mt-1">
                      Review each submission and its decision. Pending and rejected amounts do not
                      add to approved progress.
                    </p>
                  </div>
                  <p className="text-caption text-text-secondary shrink-0">
                    {reportQuery.data
                      ? `${reportQuery.data.count} reports`
                      : 'Your submitted updates'}
                  </p>
                </div>

                <div className="rounded-control border-border-subtle bg-surface tablet:p-3 border p-2">
                  <div
                    className="horizontal-scrollbar bg-surface-muted rounded-control overflow-x-auto p-1"
                    role="group"
                    aria-label="Filter progress reports by status"
                  >
                    <div className="tablet:w-full flex w-[38rem] gap-1">
                      {reportStatuses.map((status) => (
                        <button
                          key={status.value}
                          type="button"
                          aria-pressed={search.status === status.value}
                          onClick={() => updateSearch({ status: status.value, reportsPage: 1 })}
                          className={`focus-visible:shadow-focus-ring text-caption rounded-control flex min-h-10 min-w-0 flex-1 items-center justify-center gap-1.5 px-2 py-2 font-medium whitespace-nowrap focus-visible:outline-none motion-safe:transition-colors motion-safe:duration-150 ${search.status === status.value ? 'bg-surface text-text-primary shadow-elevation-sm ring-border-subtle ring-1' : 'text-text-secondary hover:bg-surface/75 hover:text-text-primary'}`}
                        >
                          <status.icon
                            className={`size-4 shrink-0 ${status.accent}`}
                            aria-hidden="true"
                          />
                          {status.label}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>

                {reportQuery.isError && !reportQuery.data ? (
                  <SectionErrorState
                    description="Progress history could not be loaded. Try again."
                    error={reportQuery.error}
                    onRetry={() => void reportQuery.refetch()}
                  />
                ) : null}
                {reportQuery.isError && reportQuery.data ? (
                  <Alert tone="warning" title="Showing saved progress history">
                    The latest refresh failed. Your last loaded reports remain available.
                    <Button variant="ghost" size="sm" onClick={() => void reportQuery.refetch()}>
                      Retry
                    </Button>
                  </Alert>
                ) : null}
                {reportQuery.isPending ? (
                  <div className="space-y-2" aria-label="Loading progress history" role="status">
                    <Skeleton variant="row" />
                    <Skeleton variant="row" />
                    <Skeleton variant="row" />
                  </div>
                ) : reportItems.length === 0 && !reportQuery.isError ? (
                  <Card className="p-1">
                    <EmptyState
                      icon={<Clock3 className="size-6" />}
                      title={
                        search.status === 'all'
                          ? 'No progress reports yet'
                          : `No ${reportStatuses.find(({ value }) => value === search.status)?.label.toLowerCase()} reports`
                      }
                      description={
                        search.status === 'all'
                          ? 'Submitted progress and review decisions will appear here.'
                          : 'Choose another status to see other progress reports.'
                      }
                    />
                  </Card>
                ) : reportItems.length > 0 ? (
                  <div className="rounded-control border-border-subtle bg-surface overflow-hidden border">
                    <div className="desktop:grid desktop:grid-cols-[6.5rem_minmax(13rem,1.5fr)_7rem_minmax(12rem,1fr)] desktop:gap-4 bg-surface-muted text-overline text-text-secondary hidden px-5 py-3 font-semibold">
                      <span>Submitted</span>
                      <span>Target and summary</span>
                      <span>Amount</span>
                      <span>Status and next step</span>
                    </div>
                    <div className="desktop:space-y-0 desktop:p-0 space-y-3 p-3">
                      {reportItems.map((report) => (
                        <TargetReportRow
                          key={report.id}
                          report={report}
                          canViewDetail={canViewReportDetail}
                          followUpTarget={
                            report.status === 'rejected'
                              ? eligibleFollowUpTarget(report)
                              : undefined
                          }
                          onCorrect={(target) => openProgress(target, true)}
                          onView={setOpenReport}
                        />
                      ))}
                    </div>
                    <Pagination
                      page={search.reportsPage}
                      count={reportQuery.data?.count ?? 0}
                      onPage={(reportsPage) => updateSearch({ reportsPage })}
                    />
                  </div>
                ) : null}
              </section>
            ) : null}
          </div>
        )}
      </PageLayout>

      <Dialog
        open={progressOpen}
        onOpenChange={(open) => {
          if (!formSubmitting) setProgressOpen(open)
          if (!open && !formSubmitting) setFormError(null)
        }}
        title={isCorrection ? 'Submit corrected progress' : 'Submit target progress'}
        description={
          isCorrection
            ? 'This creates a new report for review. The rejected report stays in your history.'
            : 'Your update will be sent for review.'
        }
        size="md"
        fitContent
        closeOnBackdrop={!formSubmitting}
        footer={
          <>
            <Button
              variant="outline"
              disabled={formSubmitting}
              onClick={() => setProgressOpen(false)}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              form="target-progress-form"
              isLoading={formSubmitting}
              leadingIcon={<ArrowRight className="size-4" />}
            >
              Submit for review
            </Button>
          </>
        }
      >
        {selectedTarget ? (
          <form
            id="target-progress-form"
            className="space-y-5"
            noValidate
            onSubmit={submitProgress}
          >
            {formError ? (
              <Alert tone="danger" title="Progress was not submitted">
                {formError}
              </Alert>
            ) : null}
            <FormSection className="space-y-4">
              <div>
                <h3 className="text-label font-semibold">Progress details</h3>
                <p className="text-caption text-text-secondary mt-1">
                  Record the work completed against this target.
                </p>
              </div>
              <div className="rounded-control border-border-subtle bg-surface border p-4">
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <p className="text-overline text-text-secondary">Assigned target</p>
                    <p className="text-label text-text-primary mt-1 font-semibold">
                      {selectedTarget.title}
                    </p>
                  </div>
                  <TargetState target={selectedTarget} />
                </div>
                <div className="border-border-subtle mt-4 grid grid-cols-2 gap-4 border-t pt-3">
                  <div>
                    <p className="text-caption text-text-secondary">Approved so far</p>
                    <p className="text-body-sm text-text-primary mt-1 font-semibold">
                      {amountLabel(selectedTarget.approvedProgressValue, selectedTarget.unit)}
                    </p>
                  </div>
                  <div>
                    <p className="text-caption text-text-secondary">Remaining</p>
                    <p className="text-body-sm text-primary mt-1 font-semibold">
                      {amountLabel(selectedTarget.remainingValue, selectedTarget.unit)}
                    </p>
                  </div>
                </div>
              </div>

              <progressForm.Field
                name="amount"
                validators={{
                  onSubmit: ({ value }) => {
                    const amount = Number(value)
                    if (!value.trim() || !Number.isFinite(amount) || amount <= 0) {
                      return 'Enter a progress amount greater than zero.'
                    }
                    if (amount > selectedTarget.remainingValue) {
                      return `The amount cannot exceed ${amountLabel(selectedTarget.remainingValue, selectedTarget.unit)} remaining.`
                    }
                    return undefined
                  },
                }}
              >
                {(field) => (
                  <FormControl
                    id="target-progress-amount"
                    label="Progress achieved"
                    required
                    error={field.state.meta.errors[0]}
                  >
                    <TextInput
                      type="number"
                      inputMode="decimal"
                      min="0.01"
                      max={selectedTarget.remainingValue}
                      step="0.01"
                      placeholder="Enter amount completed"
                      value={field.state.value}
                      onBlur={field.handleBlur}
                      onChange={(event) => field.handleChange(event.target.value)}
                    />
                  </FormControl>
                )}
              </progressForm.Field>

              <progressForm.Field
                name="summary"
                validators={{
                  onSubmit: ({ value }) =>
                    value.trim().length < 3 ? 'Add a short summary of the progress.' : undefined,
                }}
              >
                {(field) => (
                  <FormControl
                    id="target-progress-summary"
                    label="Progress summary"
                    required
                    error={field.state.meta.errors[0]}
                  >
                    <TextArea
                      rows={4}
                      placeholder="Describe the work completed"
                      value={field.state.value}
                      onBlur={field.handleBlur}
                      onChange={(event) => field.handleChange(event.target.value)}
                    />
                  </FormControl>
                )}
              </progressForm.Field>
            </FormSection>
          </form>
        ) : null}
      </Dialog>

      <Dialog
        open={Boolean(targetForDetails)}
        onOpenChange={(open) => {
          if (!open) setTargetForDetails(null)
        }}
        title={targetForDetails?.title ?? 'Target details'}
        description={
          targetForDetails
            ? `${periodLabel(targetForDetails.period)} · ${dateLabel(targetForDetails.periodStart)} – ${dateLabel(targetForDetails.periodEnd)}`
            : undefined
        }
        size="md"
        fitContent
      >
        {targetForDetails ? (
          <div className="space-y-4">
            <div className="rounded-control border-border-subtle bg-surface-muted space-y-4 border p-4">
              <div className="flex flex-wrap items-start justify-between gap-3">
                <p className="text-caption text-text-secondary">Assigned target</p>
                <TargetState target={targetForDetails} />
              </div>
              {targetForDetails.description ? (
                <p className="text-body-sm text-text-primary whitespace-pre-wrap">
                  {targetForDetails.description}
                </p>
              ) : null}
              <ProgressValue target={targetForDetails} />
            </div>

            <dl className="grid grid-cols-2 gap-3">
              <div className="rounded-control border-border-subtle bg-surface border p-3">
                <dt className="text-caption text-text-secondary">Target amount</dt>
                <dd className="text-label text-text-primary mt-1 font-semibold">
                  {amountLabel(targetForDetails.targetValue, targetForDetails.unit)}
                </dd>
              </div>
              <div className="rounded-control border-border-subtle bg-surface border p-3">
                <dt className="text-caption text-text-secondary">Approved progress</dt>
                <dd className="text-label text-text-primary mt-1 font-semibold">
                  {amountLabel(targetForDetails.approvedProgressValue, targetForDetails.unit)}
                </dd>
              </div>
              <div className="rounded-control border-border-subtle bg-surface border p-3">
                <dt className="text-caption text-text-secondary">Remaining</dt>
                <dd className="text-label text-text-primary mt-1 font-semibold">
                  {targetForDetails.isCompleted
                    ? 'Target reached'
                    : amountLabel(targetForDetails.remainingValue, targetForDetails.unit)}
                </dd>
              </div>
              <div className="rounded-control border-border-subtle bg-surface border p-3">
                <dt className="text-caption text-text-secondary">Reporting period</dt>
                <dd className="text-label text-text-primary mt-1 font-semibold">
                  {periodLabel(targetForDetails.period)}
                </dd>
              </div>
            </dl>
            <p className="text-caption text-text-secondary">
              Approved reports contribute to this total. Reports still in review or marked for
              revision do not.
            </p>
          </div>
        ) : null}
      </Dialog>

      <Dialog
        open={Boolean(openReport)}
        onOpenChange={(open) => {
          if (!open) setOpenReport(null)
        }}
        title="Progress report"
        description={openReport ? openReport.target.title : undefined}
        size="md"
        fitContent
        footer={
          openReport?.status === 'rejected' ? (
            <>
              <Button variant="outline" onClick={() => setOpenReport(null)}>
                Close
              </Button>
              {canSubmitFollowUp && rejectedTargetForFollowUp ? (
                <Button
                  onClick={() => {
                    setOpenReport(null)
                    window.setTimeout(() => openProgress(rejectedTargetForFollowUp, true), 0)
                  }}
                  leadingIcon={<ArrowRight className="size-4" />}
                >
                  Submit corrected progress
                </Button>
              ) : null}
            </>
          ) : null
        }
      >
        {openReport ? (
          reportDetailQuery.isPending ? (
            <div className="space-y-3" role="status" aria-label="Loading report details">
              <Skeleton variant="row" />
              <Skeleton variant="card" />
            </div>
          ) : reportDetailQuery.isError ? (
            <SectionErrorState
              description="This report could not be loaded. Your history remains available."
              error={reportDetailQuery.error}
              onRetry={() => void reportDetailQuery.refetch()}
            />
          ) : reportDetailQuery.data ? (
            <div className="space-y-5">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div>
                  <p className="text-caption text-text-secondary">
                    Submitted {dateLabel(reportDetailQuery.data.createdAt.slice(0, 10))}
                  </p>
                  <p className="text-h3 text-text-primary mt-1 font-semibold">
                    {amountLabel(
                      reportDetailQuery.data.progressValue,
                      reportDetailQuery.data.target.unit,
                    )}{' '}
                    submitted
                  </p>
                </div>
                <TargetReportStatusChip status={reportDetailQuery.data.status} />
              </div>
              <div className="rounded-control border-border-subtle border p-4">
                <p className="text-overline text-text-secondary">Progress summary</p>
                <p className="text-body-sm text-text-primary mt-2 whitespace-pre-wrap">
                  {reportDetailQuery.data.summary}
                </p>
              </div>
              {reportDetailQuery.data.status === 'rejected' &&
              reportDetailQuery.data.rejectionReason ? (
                <Alert tone="danger" title="Reviewer feedback">
                  {reportDetailQuery.data.rejectionReason}
                </Alert>
              ) : null}
              {reportDetailQuery.data.status === 'rejected' ? (
                <Alert tone="info" title="What to do next">
                  {followUpMessage(rejectedTargetForFollowUp, {
                    isPending: followUpTargetsQuery.isPending,
                    isError: followUpTargetsQuery.isError,
                  })}
                </Alert>
              ) : null}
              <p className="text-caption text-text-secondary">
                This amount is the value on this report. The assigned target’s approved progress
                only changes after approval.
              </p>
            </div>
          ) : null
        ) : null}
      </Dialog>
    </>
  )
}
