import { useMemo } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Link, useNavigate, useSearch } from '@tanstack/react-router'
import {
  CalendarDays,
  CircleAlert,
  CircleCheck,
  ChevronRight,
  Clock3,
  FilePlus2,
  FileText,
  ListChecks,
  MapPin,
  Paperclip,
  Pencil,
  RotateCcw,
  Star,
  type LucideIcon,
} from 'lucide-react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { EmptyState, ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'
import type { WorkReport, WorkReportStatus, WorkReportStatusFilter } from '../work-reports.api'
import { workReportsListQueryOptions } from '../work-reports.queries'
import type { WorkReportsSearch } from '../work-reports.search'
import { localDateInputValue } from '../work-report-time'

const PAGE_SIZE = 10

function statusPresentation(status: WorkReportStatus): { label: string; tone: StatusTone } {
  switch (status) {
    case 'draft':
      return { label: 'Draft', tone: 'neutral' }
    case 'submitted':
      return { label: 'In review', tone: 'info' }
    case 'approved':
      return { label: 'Approved', tone: 'success' }
    case 'rejected':
      return { label: 'Needs revision', tone: 'danger' }
  }
}

function displayDate(value: string): string {
  const [year, month, day] = value.split('-').map(Number)
  if (!year || !month || !day) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(new Date(year, month - 1, day))
}

function reportSummary(report: WorkReport): string {
  return report.summary?.trim() || report.workActivities?.trim() || 'No activity summary provided.'
}

function ReportStatus({ status }: { status: WorkReportStatus }) {
  const presentation = statusPresentation(status)
  const Icon =
    status === 'approved'
      ? CircleCheck
      : status === 'submitted'
        ? Clock3
        : status === 'rejected'
          ? CircleAlert
          : Pencil
  return (
    <StatusChip
      label={presentation.label}
      tone={presentation.tone}
      dense
      icon={<Icon className="size-3.5" />}
    />
  )
}

function ReportListRow({ report, search }: { report: WorkReport; search: WorkReportsSearch }) {
  return (
    <Link
      to="/dashboard/my-reports/$reportId"
      params={{ reportId: String(report.id) }}
      search={search}
      aria-label={`View report for ${displayDate(report.day)}, ${statusPresentation(report.status).label}: ${reportSummary(report)}`}
      className={`group border-border-subtle hover:bg-primary-subtle/35 focus-visible:bg-primary-subtle/35 focus-visible:shadow-focus-ring focus-visible:outline-primary tablet:px-5 grid grid-cols-[minmax(8.5rem,1fr)_minmax(12rem,2fr)_minmax(4.25rem,.6fr)_minmax(6rem,.8fr)_minmax(7.25rem,.9fr)] items-center gap-4 border-b px-4 py-4 no-underline last:border-b-0 focus-visible:outline focus-visible:outline-2 focus-visible:-outline-offset-2 motion-safe:transition-colors motion-safe:duration-150 ${reportCardAccent[report.status]}`}
    >
      <time
        dateTime={report.day}
        className="text-body-sm text-text-secondary inline-flex items-center gap-2"
      >
        <CalendarDays className="text-primary size-4 shrink-0" aria-hidden="true" />
        {displayDate(report.day)}
      </time>
      <div className="min-w-0">
        <p className="text-label text-text-primary line-clamp-2 font-semibold">
          {reportSummary(report)}
        </p>
        <div className="mt-1.5 flex min-w-0 flex-wrap items-center gap-x-3 gap-y-1">
          {report.operationalBase?.trim() ? (
            <span className="text-caption text-text-secondary inline-flex min-w-0 items-center gap-1">
              <MapPin className="text-info-foreground size-3.5 shrink-0" aria-hidden="true" />
              <span className="truncate">{report.operationalBase.trim()}</span>
            </span>
          ) : null}
          {report.taskDetails?.trim() ? (
            <span className="text-caption text-text-secondary inline-flex min-w-0 items-center gap-1">
              <FileText className="text-primary size-3.5 shrink-0" aria-hidden="true" />
              <span className="line-clamp-1">Task: {report.taskDetails.trim()}</span>
            </span>
          ) : null}
          {report.attachments.length > 0 ? (
            <span className="text-caption text-text-secondary inline-flex items-center gap-1">
              <Paperclip className="text-text-muted size-3.5" aria-hidden="true" />
              {report.attachments.length} {report.attachments.length === 1 ? 'file' : 'files'}
            </span>
          ) : null}
          {report.rating !== null ? (
            <span className="text-caption text-warning-foreground inline-flex items-center gap-1 font-medium">
              <Star className="size-3.5" aria-hidden="true" />
              {report.rating}/5
            </span>
          ) : null}
        </div>
        {report.feedback ? (
          <p className="text-caption text-text-secondary mt-1 line-clamp-1">
            Reviewer: {report.feedback}
          </p>
        ) : null}
      </div>
      <span className="bg-primary-subtle text-primary rounded-control text-caption inline-flex min-h-8 w-fit items-center gap-1.5 px-2.5 py-1 font-semibold">
        <Clock3 className="size-4" aria-hidden="true" />
        {report.hoursWorked.toFixed(1)} h
      </span>
      <div>
        <ReportStatus status={report.status} />
      </div>
      <span className="text-label text-primary flex items-center justify-end gap-1 font-semibold group-hover:underline">
        View report
        <ChevronRight className="size-4 shrink-0" aria-hidden="true" />
      </span>
    </Link>
  )
}

const reportCardAccent: Record<WorkReportStatus, string> = {
  draft: 'border-l-4 border-l-border-strong',
  submitted: 'border-l-4 border-l-info',
  approved: 'border-l-4 border-l-success',
  rejected: 'border-l-4 border-l-danger',
}

function ReportHistoryCard({ report, search }: { report: WorkReport; search: WorkReportsSearch }) {
  return (
    <Link
      to="/dashboard/my-reports/$reportId"
      params={{ reportId: String(report.id) }}
      search={search}
      aria-label={`View report for ${displayDate(report.day)}, ${statusPresentation(report.status).label}: ${reportSummary(report)}`}
      className="group rounded-control focus-visible:shadow-focus-ring block focus-visible:outline-none"
    >
      <Card
        className={`group-hover:border-primary/35 group-hover:shadow-elevation-md group-focus-visible:border-primary space-y-3 p-4 group-active:translate-y-px motion-safe:transition-[border-color,box-shadow,transform] motion-safe:duration-150 ${reportCardAccent[report.status]}`}
      >
        <div className="flex min-w-0 items-center gap-3">
          <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
            <CalendarDays className="size-4" aria-hidden="true" />
          </span>
          <div className="min-w-0 flex-1">
            <time
              dateTime={report.day}
              className="text-label text-text-primary block font-semibold"
            >
              {displayDate(report.day)}
            </time>
            <span className="text-caption text-text-muted">Daily work report</span>
          </div>
          <ReportStatus status={report.status} />
        </div>

        <div className="bg-primary-subtle/70 border-primary-soft/60 rounded-control flex items-start gap-2.5 border px-3 py-2.5">
          <FileText className="text-primary mt-0.5 size-4 shrink-0" aria-hidden="true" />
          <div className="min-w-0">
            <p className="text-overline text-primary mb-0.5 font-semibold">Work completed</p>
            <p className="text-body-sm text-text-primary line-clamp-3 leading-relaxed">
              {reportSummary(report)}
            </p>
            {report.taskDetails?.trim() ? (
              <p className="text-caption text-text-secondary mt-1 line-clamp-2">
                <span className="font-semibold">Task details:</span> {report.taskDetails.trim()}
              </p>
            ) : null}
          </div>
        </div>

        {report.operationalBase?.trim() ? (
          <p className="text-caption text-text-secondary flex min-w-0 items-center gap-1.5">
            <MapPin className="text-info-foreground size-4 shrink-0" aria-hidden="true" />
            <span className="text-text-muted shrink-0">Base</span>
            <span className="truncate font-medium">{report.operationalBase.trim()}</span>
          </p>
        ) : null}

        {report.status === 'rejected' && report.feedback ? (
          <div className="border-danger/15 bg-danger-subtle/50 rounded-control border px-3 py-2">
            <p className="text-overline text-danger-foreground font-semibold">Reviewer feedback</p>
            <p className="text-caption text-text-secondary mt-0.5 line-clamp-2">
              {report.feedback}
            </p>
          </div>
        ) : null}

        <div className="border-border-subtle flex flex-wrap items-center gap-2 border-t pt-3">
          <span className="bg-primary-subtle text-primary rounded-control text-caption inline-flex min-h-8 items-center gap-1.5 px-2.5 py-1 font-semibold">
            <Clock3 className="size-4" aria-hidden="true" />
            {report.hoursWorked.toFixed(1)} hrs
          </span>
          {report.attachments.length > 0 ? (
            <span className="bg-surface-muted text-text-secondary rounded-control text-caption inline-flex min-h-8 items-center gap-1.5 px-2.5 py-1 font-medium">
              <Paperclip className="text-text-muted size-4" aria-hidden="true" />
              {report.attachments.length} {report.attachments.length === 1 ? 'file' : 'files'}
            </span>
          ) : null}
          {report.rating !== null ? (
            <span className="bg-warning-subtle text-warning-foreground rounded-control text-caption inline-flex min-h-8 items-center gap-1.5 px-2.5 py-1 font-semibold">
              <Star className="text-warning-foreground size-4" aria-hidden="true" />
              {report.rating}/5
            </span>
          ) : null}
          <span className="text-label text-primary ml-auto inline-flex min-h-8 items-center gap-1 font-semibold group-hover:underline">
            View report
            <ChevronRight className="size-4" aria-hidden="true" />
          </span>
        </div>
      </Card>
    </Link>
  )
}

const reportStatusFilters: {
  value: WorkReportStatusFilter
  label: string
  icon: LucideIcon
  accent: string
}[] = [
  { value: 'all', label: 'All reports', icon: ListChecks, accent: 'text-primary' },
  { value: 'draft', label: 'Draft', icon: Pencil, accent: 'text-text-muted' },
  { value: 'submitted', label: 'In review', icon: Clock3, accent: 'text-info-foreground' },
  { value: 'approved', label: 'Approved', icon: CircleCheck, accent: 'text-success-foreground' },
  { value: 'rejected', label: 'Needs revision', icon: RotateCcw, accent: 'text-danger-foreground' },
]

export function MyWorkReportsPage() {
  const search = useSearch({ from: '/_protected/dashboard/my-reports' }) as WorkReportsSearch
  const navigate = useNavigate()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const employeePk = session?.employee.id
  const permissions = session?.permissions ?? {}
  const canRead =
    hasPermission(permissions, 'work_reports', 'list_own') ||
    hasPermission(permissions, 'work_reports', 'list')
  const canCreate = hasPermission(permissions, 'work_reports', 'create')
  const today = localDateInputValue()

  const params = useMemo(
    () => ({
      employeeId: employeePk ?? 0,
      status: search.status as WorkReportStatusFilter,
      query: '',
      dateFrom: '',
      dateTo: '',
      limit: PAGE_SIZE,
      offset: (search.page - 1) * PAGE_SIZE,
    }),
    [employeePk, search.page, search.status],
  )
  const listQuery = useQuery({
    ...workReportsListQueryOptions(userId, employeeId, params),
    enabled: Boolean(session && canRead && employeePk),
  })
  const todayQuery = useQuery({
    ...workReportsListQueryOptions(userId, employeeId, {
      employeeId: employeePk ?? 0,
      status: 'all',
      query: '',
      dateFrom: today,
      dateTo: today,
      limit: 1,
      offset: 0,
    }),
    enabled: Boolean(session && canRead && employeePk),
  })

  const updateSearch = (updates: Partial<WorkReportsSearch>, replace = false) =>
    void navigate({
      to: '/dashboard/my-reports',
      search: (previous: WorkReportsSearch) => ({ ...previous, ...updates }),
      replace,
      resetScroll: false,
    })
  const resultCount = listQuery.data?.count ?? 0
  const pageCount = Math.max(1, Math.ceil(resultCount / PAGE_SIZE))
  const reports = listQuery.data?.items ?? []
  const todayReport = todayQuery.data?.items[0]

  if (session && !canRead) {
    return (
      <PageLayout title="My Work Reports" subtitle="Your daily work record and review history">
        <ErrorState
          title="You can’t view these reports"
          description="Your account does not have access to your personal work reports."
          error={sessionQuery.error}
        />
      </PageLayout>
    )
  }

  const todayPanel = (
    <Card className="space-y-3">
      <div className="tablet:flex-row tablet:items-center tablet:justify-between flex flex-col gap-3">
        <div className="flex min-w-0 items-start gap-3">
          <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
            <CalendarDays className="size-5" aria-hidden="true" />
          </span>
          <div className="min-w-0">
            <p className="text-label text-text-primary font-semibold">Today’s report</p>
            {todayQuery.isPending ? (
              <Skeleton className="mt-2 h-4 w-48" />
            ) : todayQuery.isError && !todayQuery.data ? (
              <p className="text-body-sm text-text-secondary mt-1">
                Today’s report status could not load.
              </p>
            ) : todayReport ? (
              <div className="text-body-sm text-text-secondary mt-1 flex flex-wrap items-center gap-2">
                <span>{todayReport.hoursWorked.toFixed(1)} hours recorded</span>
                <ReportStatus status={todayReport.status} />
              </div>
            ) : (
              <p className="text-body-sm text-text-secondary mt-1">
                No report has been created for today.
              </p>
            )}
          </div>
        </div>
        <div className="flex shrink-0 flex-wrap gap-2">
          {todayQuery.isError && !todayQuery.data ? (
            <Button variant="outline" size="sm" onClick={() => void todayQuery.refetch()}>
              Retry status
            </Button>
          ) : null}
          {todayReport ? (
            <Link
              className="text-label text-primary rounded-control px-3 py-2 font-semibold hover:underline"
              to="/dashboard/my-reports/$reportId"
              params={{ reportId: String(todayReport.id) }}
              search={search}
            >
              Open today’s report
            </Link>
          ) : canCreate ? (
            <Link
              className="text-label text-primary rounded-control px-3 py-2 font-semibold hover:underline"
              to="/dashboard/my-reports/create"
              search={search}
            >
              Create today’s report
            </Link>
          ) : null}
        </div>
      </div>
      {todayQuery.isError && todayQuery.data ? (
        <div className="flex flex-wrap items-center justify-between gap-2">
          <p className="text-caption text-warning-foreground">
            Today’s status may be out of date. The saved result is still shown.
          </p>
          <Button variant="ghost" size="sm" onClick={() => void todayQuery.refetch()}>
            Retry status
          </Button>
        </div>
      ) : null}
    </Card>
  )

  return (
    <PageLayout
      title="My Work Reports"
      subtitle="Record your daily work and track its review status."
      leading={<FileText className="size-[18px]" aria-hidden="true" />}
      actionsInline
      actions={
        canCreate ? (
          <Link
            to="/dashboard/my-reports/create"
            search={search}
            aria-label="New work report"
            className="rounded-control bg-primary text-text-on-primary hover:bg-primary-hover active:bg-primary-pressed focus-visible:shadow-focus-ring text-label max-[479px]:text-caption inline-flex min-h-11 items-center justify-center gap-2 px-4 py-2 font-semibold focus-visible:outline-none max-[479px]:min-h-9 max-[479px]:px-3"
          >
            <FilePlus2 className="size-4" aria-hidden="true" />
            <span className="max-[479px]:hidden">New report</span>
            <span className="hidden max-[479px]:inline max-[361px]:hidden">New</span>
          </Link>
        ) : undefined
      }
      contentClassName="space-y-5"
    >
      {todayPanel}

      <section aria-labelledby="report-history-heading" className="space-y-3">
        <div className="flex flex-wrap items-end justify-between gap-3">
          <div>
            <h2 id="report-history-heading" className="text-h3 text-text-primary font-semibold">
              Report history
            </h2>
            <p className="text-body-sm text-text-secondary mt-1">
              Your daily records and their review progress.
            </p>
          </div>
        </div>
        <div className="rounded-control border-border-subtle bg-surface shadow-elevation-sm border p-3">
          <div className="space-y-2">
            <div className="flex items-center justify-between gap-3">
              <p className="text-caption text-text-secondary font-semibold">Filter by status</p>
              <p className="text-caption text-text-muted" aria-live="polite">
                {listQuery.isPending && !listQuery.data
                  ? 'Loading reports'
                  : `${resultCount} ${resultCount === 1 ? 'report' : 'reports'}`}
              </p>
            </div>
            <div
              role="group"
              aria-label="Filter reports by status"
              className="horizontal-scrollbar bg-surface-muted rounded-control overflow-x-auto p-1"
            >
              <div className="tablet:w-full flex w-[38rem] gap-1">
                {reportStatusFilters.map((filter) => {
                  const active = search.status === filter.value
                  const Icon = filter.icon
                  return (
                    <button
                      key={filter.value}
                      type="button"
                      aria-pressed={active}
                      onClick={() => updateSearch({ status: filter.value, page: 1 })}
                      className={`focus-visible:shadow-focus-ring text-caption rounded-control inline-flex min-h-10 min-w-0 flex-1 items-center justify-center gap-1.5 px-2 py-2 font-medium whitespace-nowrap focus-visible:outline-none motion-safe:transition-colors motion-safe:duration-150 ${
                        active
                          ? 'bg-surface text-text-primary shadow-elevation-sm ring-border-subtle ring-1'
                          : 'text-text-secondary hover:bg-surface/75 hover:text-text-primary'
                      }`}
                    >
                      <Icon className={`size-4 shrink-0 ${filter.accent}`} aria-hidden="true" />
                      {filter.label}
                    </button>
                  )
                })}
              </div>
            </div>
          </div>
        </div>

        {listQuery.isError && listQuery.data ? (
          <Alert tone="warning" title="Showing saved results">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <span>
                The latest refresh failed. You can continue with the reports already loaded.
              </span>
              <Button variant="outline" size="sm" onClick={() => void listQuery.refetch()}>
                Retry refresh
              </Button>
            </div>
          </Alert>
        ) : null}

        {!employeePk && session ? (
          <Card>
            <ErrorState
              title="Employee profile needs attention"
              description="Your employee record is missing its internal identifier, so reports cannot be safely scoped to you."
            />
          </Card>
        ) : listQuery.isPending ? (
          <Card className="space-y-3" aria-label="Loading reports" aria-busy="true">
            {Array.from({ length: 4 }, (_, index) => (
              <Skeleton key={index} variant="row" />
            ))}
          </Card>
        ) : listQuery.isError && !listQuery.data ? (
          <Card>
            <ErrorState
              title="Reports could not load"
              description="Your report history is still available to retry."
              error={listQuery.error}
              action={
                <Button variant="outline" onClick={() => void listQuery.refetch()}>
                  Try again
                </Button>
              }
            />
          </Card>
        ) : reports.length === 0 ? (
          <Card>
            <EmptyState
              title={
                search.status !== 'all' ? 'No reports match this status' : 'No work reports yet'
              }
              description={
                search.status !== 'all'
                  ? 'Choose another status to see more reports.'
                  : 'A daily report keeps your completed work and review feedback in one place.'
              }
              action={
                canCreate && search.status === 'all' ? (
                  <Link
                    className="rounded-control bg-primary text-text-on-primary hover:bg-primary-hover active:bg-primary-pressed focus-visible:shadow-focus-ring text-label inline-flex min-h-11 items-center justify-center gap-2 px-4 py-2 font-semibold focus-visible:outline-none"
                    to="/dashboard/my-reports/create"
                    search={search}
                  >
                    <FilePlus2 className="size-4" aria-hidden="true" />
                    Create a report
                  </Link>
                ) : undefined
              }
            />
          </Card>
        ) : (
          <>
            <div className="reports-responsive-list">
              <div className="reports-compact-list space-y-3">
                {reports.map((report) => (
                  <ReportHistoryCard key={report.id} report={report} search={search} />
                ))}
              </div>
              <Card className="reports-table-list overflow-hidden p-0">
                <div className="border-border-subtle text-overline text-text-secondary tablet:px-5 grid grid-cols-[minmax(8.5rem,1fr)_minmax(12rem,2fr)_minmax(4.25rem,.6fr)_minmax(6rem,.8fr)_minmax(7.25rem,.9fr)] items-center gap-4 border-b px-4 py-3">
                  <span>Report date</span>
                  <span>Work completed</span>
                  <span>Hours</span>
                  <span>Status</span>
                  <span className="text-right">Action</span>
                </div>
                {reports.map((report) => (
                  <ReportListRow key={report.id} report={report} search={search} />
                ))}
              </Card>
            </div>
          </>
        )}

        {!listQuery.isPending && resultCount > 0 ? (
          <Card className="p-3">
            <nav
              aria-label="Report pages"
              className="flex flex-wrap items-center justify-between gap-3"
            >
              <p className="text-caption text-text-secondary">
                Page {search.page} of {pageCount}
              </p>
              <div className="flex gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  disabled={search.page <= 1}
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
                </Button>
              </div>
            </nav>
          </Card>
        ) : null}
      </section>
    </PageLayout>
  )
}
