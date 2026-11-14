import { useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useParams, useSearch } from '@tanstack/react-router'
import {
  ArrowRight,
  CalendarDays,
  FileCheck2,
  FileText,
  MapPin,
  Plus,
  UserRound,
} from 'lucide-react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { useToast } from '@/shared/feedback/use-toast'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip } from '@/shared/ui/status-chip'
import { myWorkReportsQueryKeys } from '@/modules/work-reports/my-work-reports.queries'
import { siteReportQueryKeys } from '@/modules/work-reports/site-reports.queries'
import type { SiteReport } from '@/modules/work-reports/site-reports.api'
import { operationsRegisterKeys, operationsRegisterQueries } from '../operations-registers.queries'
import { operationsRegistersApi } from '../operations-registers.api'
import { projectQueries } from '../projects.queries'
import type { EngineeringReportsSearch } from '../operations-registers.search'

const PAGE_SIZE = 10
const reportStatuses = [
  { value: 'submitted', label: 'Needs review' },
  { value: 'all', label: 'All reports' },
  { value: 'draft', label: 'Drafts' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Returned' },
]

function statusTone(status: string): 'neutral' | 'info' | 'success' | 'warning' | 'danger' {
  if (status === 'submitted') return 'info'
  if (status === 'approved') return 'success'
  if (status === 'rejected') return 'danger'
  return 'neutral'
}

function formatDate(value: string) {
  const date = new Date(`${value.slice(0, 10)}T00:00:00`)
  return Number.isNaN(date.getTime())
    ? value
    : new Intl.DateTimeFormat(undefined, { dateStyle: 'medium' }).format(date)
}

export function EngineeringSiteReportsPage() {
  const search = useSearch({ strict: false }) as EngineeringReportsSearch
  const navigate = useNavigate()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const params = {
    limit: PAGE_SIZE,
    offset: (search.page - 1) * PAGE_SIZE,
    status: search.status === 'all' ? '' : search.status,
    employee_id: search.employeeId,
    project_id: search.projectId,
    worksite_id: search.worksiteId,
    date_from: search.dateFrom,
    date_to: search.dateTo,
  }
  const reports = useQuery({
    ...operationsRegisterQueries.reports(userId, employeeId, params),
    enabled: Boolean(
      session &&
      (hasPermission(session.permissions, 'engineering_site_reports', 'list') ||
        hasPermission(session.permissions, 'engineering_site_reports', 'list_own')),
    ),
  })
  const projects = useQuery({
    ...projectQueries.list(userId, employeeId, {
      limit: 100,
      offset: 0,
      search: '',
      status: '',
      priority: '',
      archived: false,
    }),
    enabled: Boolean(session && hasPermission(session.permissions, 'projects', 'list')),
  })
  const worksites = useQuery({
    ...operationsRegisterQueries.worksites(userId, employeeId, {
      limit: 100,
      offset: 0,
      search: '',
      status: '',
      project_id: search.projectId,
    }),
    enabled: Boolean(session && hasPermission(session.permissions, 'worksites', 'list')),
  })
  const canCreate = Boolean(
    session &&
    hasPermission(session.permissions, 'engineering_site_reports', 'create') &&
    hasPermission(session.permissions, 'worksites', 'list'),
  )
  const canView = Boolean(
    session &&
    (hasPermission(session.permissions, 'engineering_site_reports', 'view') ||
      hasPermission(session.permissions, 'engineering_site_reports', 'view_own')),
  )
  function change(patch: Partial<EngineeringReportsSearch>) {
    void navigate({
      to: '/works/engineering-site-reports',
      search: (previous: EngineeringReportsSearch) => ({ ...previous, ...patch }),
      resetScroll: false,
    })
  }
  return (
    <PageLayout
      title="Engineering site reports"
      subtitle="Review field activity, costs, materials, and site evidence."
      actionsInline
      actions={
        canCreate ? (
          <Link
            to="/works/engineering-site-reports/create"
            className="rounded-control bg-primary text-text-on-primary hover:bg-primary-hover text-caption inline-flex min-h-9 items-center gap-2 px-3 font-semibold"
          >
            <Plus className="size-4" />
            <span className="hidden min-[480px]:inline">New report</span>
            <span className="min-[480px]:hidden">Add</span>
          </Link>
        ) : null
      }
    >
      <div className="space-y-5">
        <Card className="space-y-4">
          <div className="flex flex-wrap items-end justify-between gap-3">
            <div>
              <p className="text-overline text-primary font-semibold">Field reporting</p>
              <h2 className="text-h2 text-text-primary mt-1 font-semibold">Engineering reports</h2>
              <p className="text-body-sm text-text-secondary mt-1">
                {reports.data?.count ?? '—'}{' '}
                {search.status === 'submitted' ? 'reports need review' : 'reports in this view'}
              </p>
            </div>
            <div className="w-full min-[480px]:w-56">
              <DropdownSelect
                label="Report view"
                value={search.status}
                options={reportStatuses}
                onChange={(status) => change({ status, page: 1 })}
              />
            </div>
          </div>
          <div className="grid gap-3 sm:grid-cols-2">
            <FormControl
              id="report-employee-id"
              label="Employee record ID"
              description="Filter by the employee record number."
            >
              <TextInput
                type="number"
                min="1"
                step="1"
                value={search.employeeId ?? ''}
                onChange={(event) =>
                  change({
                    employeeId: event.target.value ? Number(event.target.value) : null,
                    page: 1,
                  })
                }
              />
            </FormControl>
            <DropdownSelect
              label="Project"
              value={String(search.projectId ?? '')}
              options={[
                { value: '', label: 'All projects' },
                ...(projects.data?.items ?? []).map((project) => ({
                  value: String(project.id),
                  label: `${project.short_code} · ${project.name}`,
                })),
              ]}
              onChange={(value) => change({ projectId: value ? Number(value) : null, page: 1 })}
            />
          </div>
          <div className="grid gap-3 sm:grid-cols-3">
            <DropdownSelect
              label="Worksite"
              value={String(search.worksiteId ?? '')}
              options={[
                { value: '', label: 'All worksites' },
                ...(worksites.data?.items ?? []).map((site) => ({
                  value: String(site.id),
                  label: site.name,
                })),
              ]}
              onChange={(value) => change({ worksiteId: value ? Number(value) : null, page: 1 })}
            />
            <FormControl id="report-date-from" label="From date">
              <TextInput
                type="date"
                value={search.dateFrom}
                onChange={(event) => change({ dateFrom: event.target.value, page: 1 })}
              />
            </FormControl>
            <FormControl id="report-date-to" label="To date">
              <TextInput
                type="date"
                value={search.dateTo}
                onChange={(event) => change({ dateTo: event.target.value, page: 1 })}
              />
            </FormControl>
          </div>
        </Card>
        {reports.isPending ? (
          <div role="status" aria-label="Loading engineering reports" className="space-y-3">
            <Skeleton variant="card" className="h-44" />
            <Skeleton variant="card" className="h-44" />
          </div>
        ) : reports.isError ? (
          <ErrorState
            title="Engineering reports could not load"
            error={reports.error}
            action={
              <Button variant="outline" onClick={() => void reports.refetch()}>
                Try again
              </Button>
            }
          />
        ) : !reports.data?.items.length ? (
          <Card>
            <EmptyState
              title={
                search.status === 'submitted'
                  ? 'No reports are waiting for review'
                  : 'No reports match this view'
              }
              description={
                search.status === 'submitted'
                  ? 'Submitted reports will appear here when employees send their field updates.'
                  : 'Adjust the filters to review other report statuses or dates.'
              }
              action={
                canCreate ? (
                  <Link
                    to="/works/engineering-site-reports/create"
                    className="rounded-control bg-primary text-text-on-primary text-label inline-flex min-h-10 items-center gap-2 px-4 font-semibold"
                  >
                    <Plus className="size-4" />
                    Create a report
                  </Link>
                ) : undefined
              }
            />
          </Card>
        ) : (
          <section className="space-y-3" aria-label="Engineering report records">
            {reports.data.items.map((report) => (
              <ReportCard key={report.id} report={report} canView={canView} />
            ))}
          </section>
        )}
        {reports.data && reports.data.count > PAGE_SIZE ? (
          <Pagination
            count={reports.data.count}
            page={search.page}
            onPage={(page) => change({ page })}
          />
        ) : null}
      </div>
    </PageLayout>
  )
}

function ReportCard({ report, canView }: { report: SiteReport; canView: boolean }) {
  return (
    <Card className="overflow-hidden p-0" elevation="sm">
      <div className="flex flex-wrap items-start justify-between gap-3 p-4">
        <div className="flex min-w-0 items-start gap-3">
          <span className="bg-primary-subtle text-primary rounded-control flex size-11 shrink-0 items-center justify-center">
            <FileCheck2 className="size-5" />
          </span>
          <div className="min-w-0">
            <div className="flex flex-wrap items-center gap-2">
              <h3 className="text-label text-text-primary font-semibold">
                {report.employee_name ?? 'Employee record unavailable'}
              </h3>
              <StatusChip
                dense
                label={report.status.replaceAll('_', ' ')}
                tone={statusTone(report.status)}
              />
            </div>
            <p className="text-body-sm text-text-secondary mt-1">
              {report.worksite_name}
              {report.project_id ? ` · Project #${report.project_id}` : ''}
            </p>
            <p className="text-caption text-text-muted mt-1">
              {formatDate(report.date)} · {report.activities.length}{' '}
              {report.activities.length === 1 ? 'activity' : 'activities'} ·{' '}
              {report.attachments.length} attachments
            </p>
          </div>
        </div>
      </div>
      <p className="text-body-sm text-text-secondary border-border-subtle border-t px-4 py-3 break-words">
        {report.summary || report.activities[0]?.description || 'No report summary provided.'}
      </p>
      <footer className="border-border-subtle flex flex-wrap items-center justify-between gap-2 border-t px-4 py-3">
        <span className="text-caption text-text-muted">Report #{report.id}</span>
        {canView ? (
          <Link
            to="/works/engineering-site-reports/$reportId"
            params={{ reportId: String(report.id) }}
            className="rounded-control border-border-strong bg-surface text-text-primary hover:bg-surface-muted text-caption inline-flex min-h-9 items-center gap-2 border px-3 font-semibold"
          >
            Review details <ArrowRight className="size-4" />
          </Link>
        ) : (
          <StatusChip dense label="Details restricted" tone="neutral" />
        )}
      </footer>
    </Card>
  )
}

export function EngineeringSiteReportDetailPage() {
  const params = useParams({ strict: false }) as { reportId?: string }
  const reportId = Number(params.reportId)
  const client = useQueryClient()
  const toast = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const query = useQuery({
    ...operationsRegisterQueries.report(userId, employeeId, reportId),
    enabled: Boolean(
      session &&
      reportId > 0 &&
      (hasPermission(session.permissions, 'engineering_site_reports', 'view') ||
        hasPermission(session.permissions, 'engineering_site_reports', 'view_own')),
    ),
  })
  const report = query.data
  const isOwner = Boolean(report && report.employee_id === session?.employee.id)
  const canUpdate = Boolean(
    session &&
    report &&
    isOwner &&
    (hasPermission(session.permissions, 'engineering_site_reports', 'update') ||
      hasPermission(session.permissions, 'engineering_site_reports', 'update_own')) &&
    ['draft', 'rejected'].includes(report.status),
  )
  const canSubmit = Boolean(
    session &&
    report &&
    isOwner &&
    (hasPermission(session.permissions, 'engineering_site_reports', 'submit') ||
      hasPermission(session.permissions, 'engineering_site_reports', 'submit_own')) &&
    report.status === 'draft',
  )
  const canDelete = Boolean(
    session &&
    report &&
    isOwner &&
    (hasPermission(session.permissions, 'engineering_site_reports', 'delete') ||
      hasPermission(session.permissions, 'engineering_site_reports', 'delete_own')) &&
    ['draft', 'rejected'].includes(report.status),
  )
  const canApprove = Boolean(
    session &&
    report &&
    report.employee_id !== session.employee.id &&
    report.status === 'submitted' &&
    hasPermission(session.permissions, 'engineering_site_reports', 'approve'),
  )
  const canReject = Boolean(
    session &&
    report &&
    report.employee_id !== session.employee.id &&
    report.status === 'submitted' &&
    hasPermission(session.permissions, 'engineering_site_reports', 'reject'),
  )
  const [dialog, setDialog] = useState<'approve' | 'reject' | 'submit' | 'delete' | null>(null)
  const [rating, setRating] = useState('')
  const [reason, setReason] = useState('')
  const [actionError, setActionError] = useState('')

  async function refreshReportData(updated?: SiteReport) {
    if (updated)
      client.setQueryData(
        operationsRegisterKeys.detail(userId, employeeId, 'report', updated.id),
        updated,
      )
    await Promise.all([
      client.invalidateQueries({
        queryKey: operationsRegisterKeys.lists(userId, employeeId, 'reports'),
      }),
      client.invalidateQueries({ queryKey: siteReportQueryKeys.all }),
      client.invalidateQueries({ queryKey: myWorkReportsQueryKeys.all }),
    ])
  }
  const action = useMutation({
    mutationFn: async () => {
      if (!report || !dialog) throw new Error('Choose a report action first.')
      if (dialog === 'approve')
        return operationsRegistersApi.approveEngineeringReport(
          report.id,
          rating ? Number(rating) : null,
        )
      if (dialog === 'reject')
        return operationsRegistersApi.rejectEngineeringReport(report.id, reason.trim())
      if (dialog === 'submit') return operationsRegistersApi.submitEngineeringReport(report.id)
      await operationsRegistersApi.removeEngineeringReport(report.id)
      return null
    },
    onSuccess: async (updated) => {
      if (updated) await refreshReportData(updated)
      else
        await Promise.all([
          client.invalidateQueries({
            queryKey: operationsRegisterKeys.lists(userId, employeeId, 'reports'),
          }),
          client.invalidateQueries({ queryKey: siteReportQueryKeys.all }),
        ])
      const completed = dialog
      setDialog(null)
      setActionError('')
      toast.showToast({
        title:
          completed === 'approve'
            ? 'Report approved'
            : completed === 'reject'
              ? 'Report returned'
              : completed === 'submit'
                ? 'Report submitted'
                : 'Draft deleted',
        tone: 'success',
      })
      if (completed === 'delete')
        void navigate({
          to: '/works/engineering-site-reports',
          search: {
            status: 'all',
            employeeId: null,
            projectId: null,
            worksiteId: null,
            dateFrom: '',
            dateTo: '',
            page: 1,
          },
        })
    },
    onError: (error) =>
      setActionError(
        error instanceof Error ? error.message : 'The report action could not be completed.',
      ),
  })
  const navigate = useNavigate()
  const listSearch: EngineeringReportsSearch = {
    status: 'submitted',
    employeeId: null,
    projectId: null,
    worksiteId: null,
    dateFrom: '',
    dateTo: '',
    page: 1,
  }
  const dialogTitle =
    dialog === 'approve'
      ? 'Approve engineering report?'
      : dialog === 'reject'
        ? 'Return report for correction?'
        : dialog === 'submit'
          ? 'Submit report for review?'
          : 'Delete report draft?'

  return (
    <PageLayout
      title={report?.worksite_name ?? 'Engineering report'}
      subtitle="Field activity, evidence, inventory use, and review decision."
      backLink={
        <Link
          to="/works/engineering-site-reports"
          search={listSearch}
          className={pageBackLinkClassName}
        >
          <PageBackLinkContent>Engineering reports</PageBackLinkContent>
        </Link>
      }
    >
      {query.isPending ? (
        <Skeleton variant="card" className="h-96" />
      ) : query.isError ? (
        <ErrorState
          title="Engineering report unavailable"
          error={query.error}
          action={
            <Button variant="outline" onClick={() => void query.refetch()}>
              Try again
            </Button>
          }
        />
      ) : report ? (
        <div className="space-y-4">
          <Card>
            <div className="flex flex-wrap items-start justify-between gap-3">
              <div>
                <p className="text-overline text-primary font-semibold">
                  Report #{report.id} · {formatDate(report.date)}
                </p>
                <h2 className="text-h2 text-text-primary mt-1 font-semibold">
                  {report.employee_name ?? 'Employee'}
                </h2>
                <p className="text-body-sm text-text-secondary mt-1">
                  {report.worksite_name}
                  {report.project_id ? ` · Project #${report.project_id}` : ''}
                </p>
              </div>
              <StatusChip
                label={report.status.replaceAll('_', ' ')}
                tone={statusTone(report.status)}
              />
            </div>
            <div className="mt-5 grid gap-3 sm:grid-cols-3">
              <Fact
                icon={<CalendarDays className="size-4" />}
                label="Report date"
                value={formatDate(report.date)}
              />
              <Fact
                icon={<MapPin className="size-4" />}
                label="Worksite"
                value={report.worksite_name}
              />
              <Fact
                icon={<UserRound className="size-4" />}
                label="Author"
                value={report.employee_name ?? `Employee #${report.employee_id ?? '—'}`}
              />
            </div>
            <section className="border-border-subtle mt-5 space-y-3 border-t pt-4">
              <h3 className="text-h3 text-text-primary font-semibold">Work completed</h3>
              {report.activities.length ? (
                report.activities.map((item, index) => (
                  <div key={item.id ?? index} className="bg-surface-muted rounded-control p-3">
                    <p className="text-caption text-primary font-semibold">
                      {item.activity_type.replaceAll('_', ' ')}
                    </p>
                    <p className="text-body-sm text-text-primary mt-1 whitespace-pre-wrap">
                      {item.description}
                    </p>
                  </div>
                ))
              ) : (
                <p className="text-body-sm text-text-secondary">No activities recorded.</p>
              )}
            </section>
            <div className="grid gap-4 sm:grid-cols-2">
              <section className="space-y-2">
                <h3 className="text-label text-text-primary font-semibold">Materials used</h3>
                {report.materials_used.length ? (
                  report.materials_used.map((item, index) => (
                    <Fact
                      key={item.id ?? index}
                      label={item.equipment_name}
                      value={`${item.quantity_used} ${item.unit}`}
                    />
                  ))
                ) : (
                  <p className="text-body-sm text-text-secondary">No inventory used.</p>
                )}
              </section>
              <section className="space-y-2">
                <h3 className="text-label text-text-primary font-semibold">Expenses</h3>
                {report.expenses.length ? (
                  report.expenses.map((item, index) => (
                    <Fact
                      key={item.id ?? index}
                      label={`${item.name} · ${item.expense_category.replaceAll('_', ' ')}`}
                      value={`₦${Number(item.amount).toLocaleString('en-NG', { maximumFractionDigits: 2 })}`}
                    />
                  ))
                ) : (
                  <p className="text-body-sm text-text-secondary">No expenses recorded.</p>
                )}
              </section>
            </div>
            <div className="grid gap-3 sm:grid-cols-2">
              <Fact
                label="Plan for next day"
                value={report.tomorrow_activities || 'Not provided'}
              />
              <Fact
                label="Comments and suggestions"
                value={report.comments_suggestions || 'Not provided'}
              />
            </div>
            {report.attachments.length ? (
              <section className="space-y-2">
                <h3 className="text-label text-text-primary font-semibold">Attachments</h3>
                <ul className="space-y-2">
                  {report.attachments.map((attachment, index) => (
                    <li key={`${attachment}-${index}`}>
                      <a
                        href={safeUrl(attachment)}
                        target="_blank"
                        rel="noreferrer"
                        className="text-body-sm text-primary inline-flex max-w-full items-center gap-2 break-all underline"
                      >
                        <FileText className="size-4 shrink-0" />
                        Attachment {index + 1}
                      </a>
                    </li>
                  ))}
                </ul>
              </section>
            ) : null}
            {report.status === 'rejected' && report.summary ? (
              <div className="border-warning/30 bg-warning-subtle rounded-control border p-3">
                <p className="text-label text-text-primary font-semibold">Returned feedback</p>
                <p className="text-body-sm text-text-secondary mt-1 whitespace-pre-wrap">
                  {report.summary}
                </p>
              </div>
            ) : null}
            {report.employee_id === session?.employee.id ? (
              <p className="text-caption text-text-muted">
                This is your report. You can manage it from this Operations view; employee-owned
                submission remains attributed to you.
              </p>
            ) : null}
            <div className="border-border-subtle flex flex-wrap justify-end gap-2 border-t pt-4">
              {canUpdate ? (
                <Link
                  to="/works/engineering-site-reports/$reportId/edit"
                  params={{ reportId: String(report.id) }}
                  className="rounded-control border-border-strong bg-surface text-text-primary text-label inline-flex min-h-10 items-center gap-2 border px-4 font-semibold"
                >
                  Edit draft
                </Link>
              ) : null}
              {canSubmit ? (
                <Button
                  variant="outline"
                  onClick={() => {
                    setActionError('')
                    setDialog('submit')
                  }}
                >
                  Submit for review
                </Button>
              ) : null}
              {canDelete ? (
                <Button
                  variant="ghost"
                  onClick={() => {
                    setActionError('')
                    setDialog('delete')
                  }}
                >
                  Delete draft
                </Button>
              ) : null}
              {canReject ? (
                <Button
                  variant="danger"
                  onClick={() => {
                    setReason('')
                    setActionError('')
                    setDialog('reject')
                  }}
                >
                  Return for correction
                </Button>
              ) : null}
              {canApprove ? (
                <Button
                  leadingIcon={<FileCheck2 className="size-4" />}
                  onClick={() => {
                    setRating('')
                    setActionError('')
                    setDialog('approve')
                  }}
                >
                  Approve report
                </Button>
              ) : null}
            </div>
            {report.employee_id === session?.employee.id && report.status === 'submitted' ? (
              <p className="text-caption text-text-secondary text-right">
                Self-review is not allowed. A different authorized reviewer must decide this report.
              </p>
            ) : null}
          </Card>
        </div>
      ) : null}
      <Dialog
        open={Boolean(dialog)}
        onOpenChange={(open) => !open && !action.isPending && setDialog(null)}
        title={dialogTitle}
        description={
          report ? `${report.employee_name ?? 'Employee'} · ${formatDate(report.date)}` : undefined
        }
        size="md"
        fitContent
        dismissDisabled={action.isPending}
        footer={
          <div className="flex flex-wrap justify-end gap-2">
            <Button variant="outline" disabled={action.isPending} onClick={() => setDialog(null)}>
              Cancel
            </Button>
            <Button
              variant={dialog === 'reject' || dialog === 'delete' ? 'danger' : 'primary'}
              isLoading={action.isPending}
              disabled={dialog === 'reject' && !reason.trim()}
              onClick={() => action.mutate()}
            >
              {dialog === 'approve'
                ? 'Approve report'
                : dialog === 'reject'
                  ? 'Return report'
                  : dialog === 'submit'
                    ? 'Submit report'
                    : 'Delete draft'}
            </Button>
          </div>
        }
      >
        <div className="space-y-4">
          <div className="bg-primary-subtle/50 rounded-control p-3">
            <p className="text-label text-text-primary font-semibold">
              {report?.employee_name} · {report?.worksite_name}
            </p>
            <p className="text-body-sm text-text-secondary mt-1">
              {report ? `${formatDate(report.date)} · ${report.activities.length} activities` : ''}
            </p>
          </div>
          {dialog === 'approve' ? (
            <>
              <p className="text-body-sm text-text-secondary">
                Approval records the review decision. A rating is optional; the employee’s report
                and supporting evidence remain unchanged.
              </p>
              <FormControl id="report-rating" label="Rating (optional)">
                <DropdownSelect
                  value={rating}
                  options={[
                    { value: '', label: 'No rating' },
                    ...[1, 2, 3, 4, 5].map((value) => ({
                      value: String(value),
                      label: `${value} / 5`,
                    })),
                  ]}
                  onChange={setRating}
                />
              </FormControl>
            </>
          ) : null}
          {dialog === 'reject' ? (
            <>
              <div className="bg-warning-subtle rounded-control p-3">
                <p className="text-label text-text-primary font-semibold">
                  The employee can revise and resubmit
                </p>
                <p className="text-body-sm text-text-secondary mt-1">
                  Returning marks this report as rejected and sends your correction notes to the
                  report owner.
                </p>
              </div>
              <FormControl id="report-rejection-reason" label="Reason for return" required>
                <TextArea
                  value={reason}
                  onChange={(event) => setReason(event.target.value)}
                  rows={5}
                  maxLength={4000}
                  placeholder="Explain what needs to be corrected"
                  required
                />
              </FormControl>
            </>
          ) : null}
          {dialog === 'submit' ? (
            <p className="text-body-sm text-text-secondary">
              This sends the report and its linked inventory and expense entries to the review
              queue. Submitted reports can no longer be edited until returned.
            </p>
          ) : null}
          {dialog === 'delete' ? (
            <p className="text-body-sm text-text-secondary">
              Only draft or rejected reports can be deleted. Submitted and reviewed history is
              retained.
            </p>
          ) : null}
          {actionError ? (
            <p role="alert" className="text-body-sm text-danger">
              {actionError}
            </p>
          ) : null}
        </div>
      </Dialog>
    </PageLayout>
  )
}

function safeUrl(value: string) {
  try {
    const url = new URL(value, window.location.origin)
    return ['http:', 'https:'].includes(url.protocol) ? url.href : undefined
  } catch {
    return undefined
  }
}
function Fact({ label, value, icon }: { label: string; value: string; icon?: React.ReactNode }) {
  return (
    <div className="bg-surface-muted rounded-control min-w-0 p-3">
      <p className="text-caption text-text-secondary flex items-center gap-1.5">
        {icon}
        {label}
      </p>
      <p className="text-body-sm text-text-primary mt-1 break-words whitespace-pre-wrap">{value}</p>
    </div>
  )
}
function Pagination({
  count,
  page,
  onPage,
}: {
  count: number
  page: number
  onPage: (page: number) => void
}) {
  const total = Math.ceil(count / PAGE_SIZE)
  return (
    <Card className="flex flex-wrap items-center justify-between gap-3 py-3">
      <span className="text-body-sm text-text-secondary">
        {(page - 1) * PAGE_SIZE + 1}–{Math.min(page * PAGE_SIZE, count)} of {count}
      </span>
      <div className="flex items-center gap-2">
        <Button variant="outline" size="sm" disabled={page <= 1} onClick={() => onPage(page - 1)}>
          Previous
        </Button>
        <span className="text-caption text-text-secondary">
          Page {page} of {total}
        </span>
        <Button
          variant="outline"
          size="sm"
          disabled={page >= total}
          onClick={() => onPage(page + 1)}
        >
          Next
        </Button>
      </div>
    </Card>
  )
}
