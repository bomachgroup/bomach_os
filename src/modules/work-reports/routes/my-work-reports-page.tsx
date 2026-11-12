import { useCallback, useEffect, useMemo } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Link, useNavigate, useSearch } from '@tanstack/react-router'
import {
  CalendarDays,
  ChevronRight,
  Clock3,
  FilePlus2,
  FileText,
  MapPin,
  Paperclip,
  Star,
} from 'lucide-react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'
import type { MyWorkReport, MyWorkReportType, MyWorkReportTypeFilter } from '../my-work-reports.api'
import { myWorkReportsListOptions } from '../my-work-reports.queries'
import type { WorkReportsSearch } from '../work-reports.search'
import type { WorkReportStatus, WorkReportStatusFilter } from '../work-reports.api'

const PAGE_SIZE = 10

const reportTypeLabels: Record<MyWorkReportType, string> = {
  daily: 'Daily report',
  engineering: 'Engineering site report',
  survey: 'Survey site report',
}

const typeFilterOptions: Array<{ value: MyWorkReportTypeFilter; label: string }> = [
  { value: 'all', label: 'All report types' },
  { value: 'daily', label: 'Daily reports' },
  { value: 'site', label: 'Site reports' },
  { value: 'engineering', label: 'Engineering reports' },
  { value: 'survey', label: 'Survey reports' },
]

const statusFilterOptions: Array<{ value: WorkReportStatusFilter; label: string }> = [
  { value: 'all', label: 'All statuses' },
  { value: 'draft', label: 'Draft' },
  { value: 'submitted', label: 'In review' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Needs revision' },
]

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

function formatDate(value: string): string {
  const [year, month, day] = value.split('-').map(Number)
  if (!year || !month || !day) return value || 'Date not recorded'
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(new Date(year, month - 1, day))
}

function detailHref(report: MyWorkReport):
  | { to: '/dashboard/my-reports/$reportId'; params: { reportId: string } }
  | {
      to: '/dashboard/my-reports/site/$reportType/$reportId'
      params: { reportType: 'engineering' | 'survey'; reportId: string }
    } {
  if (report.type === 'daily') {
    return {
      to: '/dashboard/my-reports/$reportId',
      params: { reportId: String(report.reportId) },
    }
  }
  return {
    to: '/dashboard/my-reports/site/$reportType/$reportId',
    params: { reportType: report.type, reportId: String(report.reportId) },
  }
}

function ReportCard({ report, search }: { report: MyWorkReport; search: WorkReportsSearch }) {
  const href = detailHref(report)
  const status = statusPresentation(report.status)
  const isRejected = report.status === 'rejected'
  const summary = report.summary.trim() || 'No activity summary provided.'

  return (
    <Link
      {...href}
      search={search}
      aria-label={`View ${reportTypeLabels[report.type]} from ${formatDate(report.date)}, ${status.label}: ${summary}`}
      className="group rounded-control focus-visible:shadow-focus-ring block no-underline focus-visible:outline-none"
    >
      <Card
        className={`group-hover:border-primary/35 group-hover:shadow-elevation-md group-focus-visible:border-primary space-y-3 p-4 transition-[border-color,box-shadow,transform] group-active:translate-y-px motion-safe:duration-150 ${
          isRejected
            ? 'border-l-danger border-l-4'
            : report.status === 'submitted'
              ? 'border-l-info border-l-4'
              : report.status === 'approved'
                ? 'border-l-success border-l-4'
                : 'border-l-border-strong border-l-4'
        }`}
      >
        <div className="flex min-w-0 flex-wrap items-start gap-3">
          <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
            <FileText className="size-5" aria-hidden="true" />
          </span>
          <div className="min-w-0 flex-1">
            <div className="flex min-w-0 flex-wrap items-center gap-2">
              <h3 className="text-label text-text-primary min-w-0 flex-1 font-semibold break-words">
                {reportTypeLabels[report.type]}
              </h3>
              <StatusChip label={status.label} tone={status.tone} dense />
            </div>
            <p className="text-caption text-text-secondary mt-1 flex min-w-0 flex-wrap items-center gap-x-3 gap-y-1">
              <span className="inline-flex items-center gap-1.5">
                <CalendarDays className="size-4 shrink-0" aria-hidden="true" />
                <time dateTime={report.date}>{formatDate(report.date)}</time>
              </span>
              {report.worksiteName ? (
                <span className="inline-flex min-w-0 items-center gap-1.5">
                  <MapPin className="size-4 shrink-0" aria-hidden="true" />
                  <span className="truncate">{report.worksiteName}</span>
                </span>
              ) : null}
            </p>
          </div>
        </div>

        <p className="text-body-sm text-text-secondary whitespace-pre-wrap">{summary}</p>

        <div className="border-border-subtle flex flex-wrap items-center gap-x-4 gap-y-2 border-t pt-3">
          {report.hoursWorked !== null ? (
            <span className="text-caption text-text-secondary inline-flex items-center gap-1.5">
              <Clock3 className="size-4" aria-hidden="true" />
              {report.hoursWorked.toFixed(1)} hours
            </span>
          ) : null}
          {report.taskId !== null ? (
            <span className="text-caption text-text-secondary">Task #{report.taskId}</span>
          ) : null}
          {report.attachments.length ? (
            <span className="text-caption text-text-secondary inline-flex items-center gap-1.5">
              <Paperclip className="size-4" aria-hidden="true" />
              {report.attachments.length}{' '}
              {report.attachments.length === 1 ? 'attachment' : 'attachments'}
            </span>
          ) : null}
          {report.rating !== null ? (
            <span className="text-caption text-warning-foreground inline-flex items-center gap-1.5 font-semibold">
              <Star className="size-4" aria-hidden="true" /> {report.rating}/5
            </span>
          ) : null}
          {report.reviewedAt ? (
            <span className="text-caption text-text-secondary">
              Reviewed {formatDate(report.reviewedAt.slice(0, 10))}
            </span>
          ) : null}
          <span className="text-label text-primary ml-auto inline-flex min-h-9 items-center gap-1 font-semibold group-hover:underline">
            View report <ChevronRight className="size-4" aria-hidden="true" />
          </span>
        </div>
      </Card>
    </Link>
  )
}

function NewReportActions({
  search,
  choices,
}: {
  search: WorkReportsSearch
  choices: Array<{ id: MyWorkReportType; label: string; href: string }>
}) {
  if (!choices.length) return null
  const choice = choices[0]
  if (choices.length === 1 && choice) {
    return (
      <Link
        to={
          choice.href as
            '/dashboard/my-reports/create' | '/dashboard/my-reports/create-site/$reportType'
        }
        params={choice.id === 'daily' ? undefined : { reportType: choice.id }}
        search={search}
        aria-label="New report"
        className="rounded-control bg-primary text-text-on-primary hover:bg-primary-hover active:bg-primary-pressed focus-visible:shadow-focus-ring text-label max-[479px]:text-caption inline-flex min-h-11 items-center justify-center gap-2 px-4 py-2 font-semibold focus-visible:outline-none max-[479px]:min-h-9 max-[479px]:px-3"
      >
        <FilePlus2 className="size-4" aria-hidden="true" />
        <span>New report</span>
      </Link>
    )
  }

  return (
    <details className="group relative">
      <summary className="rounded-control bg-primary text-text-on-primary hover:bg-primary-hover active:bg-primary-pressed focus-visible:shadow-focus-ring text-label max-[479px]:text-caption inline-flex min-h-11 cursor-pointer list-none items-center justify-center gap-2 px-4 py-2 font-semibold focus-visible:outline-none max-[479px]:min-h-9 max-[479px]:px-3 [&::-webkit-details-marker]:hidden">
        <FilePlus2 className="size-4" aria-hidden="true" />
        <span>New report</span>
      </summary>
      <div className="border-border-subtle bg-surface shadow-elevation-lg rounded-control absolute right-0 z-30 mt-2 min-w-56 border p-1.5">
        <p className="text-overline text-text-muted px-2.5 py-2 font-semibold">
          Choose report type
        </p>
        {choices.map((item) => (
          <Link
            key={item.id}
            to={
              item.href as
                '/dashboard/my-reports/create' | '/dashboard/my-reports/create-site/$reportType'
            }
            params={item.id === 'daily' ? undefined : { reportType: item.id }}
            search={search}
            className="text-label text-text-primary hover:bg-primary-subtle focus-visible:bg-primary-subtle rounded-control flex min-h-10 items-center px-2.5 py-2 font-medium no-underline focus-visible:outline-none"
          >
            {item.label}
          </Link>
        ))}
      </div>
    </details>
  )
}

export function MyWorkReportsPage() {
  const search = useSearch({ from: '/_protected/dashboard/my-reports' }) as WorkReportsSearch
  const routeSearch = useMemo<WorkReportsSearch>(
    () => ({ type: search.type, status: search.status, page: search.page }),
    [search.page, search.status, search.type],
  )
  const navigate = useNavigate()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeKey = session?.employee.employee_id ?? ''
  const employeeId = session?.employee.id ?? 0
  const permissions = session?.permissions ?? {}

  const canReadDaily =
    hasPermission(permissions, 'work_reports', 'list') ||
    hasPermission(permissions, 'work_reports', 'list_own')
  const canReadEngineering =
    hasPermission(permissions, 'engineering_site_reports', 'list') ||
    hasPermission(permissions, 'engineering_site_reports', 'list_own')
  const canReadSurvey =
    hasPermission(permissions, 'survey_site_reports', 'list') ||
    hasPermission(permissions, 'survey_site_reports', 'list_own')
  const canRead = canReadDaily || canReadEngineering || canReadSurvey
  const hasWorksiteList = hasPermission(permissions, 'worksites', 'list')

  const choices: Array<{ id: MyWorkReportType; label: string; href: string }> = []
  if (hasPermission(permissions, 'work_reports', 'create')) {
    choices.push({ id: 'daily', label: 'Daily work report', href: '/dashboard/my-reports/create' })
  }
  if (hasWorksiteList && hasPermission(permissions, 'engineering_site_reports', 'create')) {
    choices.push({
      id: 'engineering',
      label: 'Engineering site report',
      href: '/dashboard/my-reports/create-site/$reportType',
    })
  }
  if (hasWorksiteList && hasPermission(permissions, 'survey_site_reports', 'create')) {
    choices.push({
      id: 'survey',
      label: 'Survey site report',
      href: '/dashboard/my-reports/create-site/$reportType',
    })
  }

  const availableTypeFilters = useMemo(
    () =>
      typeFilterOptions.filter(({ value }) => {
        if (value === 'all') return canRead
        if (value === 'daily') return canReadDaily
        if (value === 'site') return canReadEngineering || canReadSurvey
        if (value === 'engineering') return canReadEngineering
        return canReadSurvey
      }),
    [canRead, canReadDaily, canReadEngineering, canReadSurvey],
  )

  const updateSearch = useCallback(
    (updates: Partial<WorkReportsSearch>, replace = false) =>
      void navigate({
        to: '/dashboard/my-reports',
        search: () => ({ ...routeSearch, ...updates }),
        replace,
        resetScroll: false,
      }),
    [navigate, routeSearch],
  )

  const typeIsAvailable = availableTypeFilters.some((item) => item.value === search.type)
  useEffect(() => {
    if (session && canRead && !typeIsAvailable) updateSearch({ type: 'all', page: 1 }, true)
  }, [canRead, search.type, session, typeIsAvailable, updateSearch])

  const params = useMemo(
    () => ({
      type: search.type,
      status: search.status,
      limit: PAGE_SIZE,
      offset: (search.page - 1) * PAGE_SIZE,
    }),
    [search.page, search.status, search.type],
  )
  const listQuery = useQuery({
    ...myWorkReportsListOptions(userId, employeeKey, params),
    enabled: Boolean(session && canRead && employeeId > 0),
  })

  if (session && !canRead) {
    return (
      <PageLayout title="My Work Reports" subtitle="Your work report history">
        <ErrorState
          title="You can’t view these reports"
          description="Your account does not have access to personal work report history."
          error={sessionQuery.error}
        />
      </PageLayout>
    )
  }

  const items = listQuery.data?.items ?? []
  const count = listQuery.data?.count ?? 0
  const pageCount = Math.max(1, Math.ceil(count / PAGE_SIZE))
  const typeOptions = availableTypeFilters.map(({ value, label }) => ({ value, label }))

  return (
    <PageLayout
      title="My Work Reports"
      subtitle="Your daily, engineering, and survey reports in one register."
      leading={<FileText className="size-[18px]" aria-hidden="true" />}
      actionsInline
      actions={<NewReportActions choices={choices} search={routeSearch} />}
      contentClassName="space-y-5"
    >
      <Card className="space-y-4">
        <div className="flex flex-wrap items-end justify-between gap-3">
          <div>
            <p className="text-overline text-primary font-semibold">My work</p>
            <h2 className="text-h3 text-text-primary mt-1 font-semibold">Report register</h2>
            <p className="text-body-sm text-text-secondary mt-1">
              Review your accessible work reports, newest report dates first.
            </p>
          </div>
          <p className="text-label text-text-secondary" aria-live="polite">
            {listQuery.isPending && !listQuery.data
              ? 'Loading reports'
              : `${count} ${count === 1 ? 'report' : 'reports'}`}
          </p>
        </div>

        <div className="grid grid-cols-1 gap-3 min-[340px]:grid-cols-2">
          <DropdownSelect
            aria-label="Filter by report type"
            value={search.type}
            options={typeOptions}
            onChange={(value) => updateSearch({ type: value as MyWorkReportTypeFilter, page: 1 })}
          />
          <DropdownSelect
            aria-label="Filter by report status"
            value={search.status}
            options={statusFilterOptions}
            onChange={(value) => updateSearch({ status: value as WorkReportStatusFilter, page: 1 })}
          />
        </div>
      </Card>

      {listQuery.isError && listQuery.data ? (
        <Alert tone="warning" title="Showing saved results">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <span>The latest refresh failed. Your reports already loaded are still shown.</span>
            <Button variant="outline" size="sm" onClick={() => void listQuery.refetch()}>
              Retry refresh
            </Button>
          </div>
        </Alert>
      ) : null}

      {!employeeId && session ? (
        <Card>
          <ErrorState
            title="Employee profile needs attention"
            description="Your profile is missing the identifier needed to load report history securely."
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
            description="Your work report history is available to retry."
            error={listQuery.error}
            action={
              <Button variant="outline" onClick={() => void listQuery.refetch()}>
                Try again
              </Button>
            }
          />
        </Card>
      ) : items.length === 0 ? (
        <Card>
          <EmptyState
            title={search.status === 'all' ? 'No work reports yet' : 'No reports match this status'}
            description={
              search.status === 'all'
                ? 'Reports you can access will appear here after they are created.'
                : 'Choose another status to see more reports.'
            }
            action={
              choices.length ? (
                <NewReportActions choices={choices} search={routeSearch} />
              ) : undefined
            }
          />
        </Card>
      ) : (
        <section aria-labelledby="report-list-heading" className="space-y-3">
          <h2 id="report-list-heading" className="sr-only">
            Work reports
          </h2>
          {items.map((report) => (
            <ReportCard
              key={`${report.type}-${report.reportId}`}
              report={report}
              search={routeSearch}
            />
          ))}
        </section>
      )}

      {!listQuery.isPending && count > 0 ? (
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
    </PageLayout>
  )
}
