import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  Check,
  ChevronLeft,
  ChevronRight,
  Clock3,
  FileCheck2,
  FileText,
  Pencil,
  Paperclip,
  Search,
  Trash2,
  X,
} from 'lucide-react'
import { useState, type FormEvent } from 'react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { ApiError } from '@/shared/api/api-error'
import { presentError } from '@/shared/errors'
import { useToast } from '@/shared/feedback/use-toast'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextInput } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'
import {
  workReportDetailQueryOptions,
  workReportsListQueryOptions,
  workReportsQueryKeys,
} from '@/modules/work-reports/work-reports.queries'
import {
  workReportsApi,
  type WorkReport,
  type WorkReportInput,
  type WorkReportStatus,
  type WorkReportStatusFilter,
} from '@/modules/work-reports/work-reports.api'
import { DEFAULT_HR_WORK_REPORT_STATUS, type HRWorkReportsSearch } from '../work-reports.search'
import { HRWorkReportDetailPage } from './hr-work-report-detail-page'
import { HRWorkReportDecisionDialog } from './hr-work-report-decision-dialog'
import { HRWorkReportEditDialog } from './hr-work-report-edit-dialog'

const PAGE_SIZE = 10
const STATUS_OPTIONS = [
  { value: 'all', label: 'All statuses' },
  { value: 'draft', label: 'Draft' },
  { value: 'submitted', label: 'Needs HR review' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Needs revision' },
]
function statusLabel(status: WorkReportStatus): string {
  return {
    draft: 'Draft',
    submitted: 'In review',
    approved: 'Approved',
    rejected: 'Needs revision',
  }[status]
}

function statusTone(status: WorkReportStatus): StatusTone {
  const tones: Record<WorkReportStatus, StatusTone> = {
    draft: 'neutral',
    submitted: 'info',
    approved: 'success',
    rejected: 'danger',
  }
  return tones[status]
}

function formatDate(value: string): string {
  const [year, month, day] = value.slice(0, 10).split('-').map(Number)
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
  const Icon = status === 'approved' ? Check : status === 'rejected' ? X : Clock3
  return (
    <StatusChip
      label={statusLabel(status)}
      tone={statusTone(status)}
      dense
      icon={<Icon className="size-3.5" aria-hidden="true" />}
    />
  )
}

function ReportCard({
  report,
  onOpen,
  onEdit,
  isOwnReport,
  canView,
  canEdit,
  canDelete,
  canApprove,
  canReject,
  onDelete,
  onReview,
}: {
  report: WorkReport
  onOpen: () => void
  onEdit: () => void
  isOwnReport: boolean
  canView: boolean
  canEdit: boolean
  canDelete: boolean
  canApprove: boolean
  canReject: boolean
  onDelete: () => void
  onReview: (decision: 'approve' | 'reject') => void
}) {
  return (
    <article className="border-border-subtle bg-surface shadow-elevation-sm rounded-control hover:border-primary/25 hover:shadow-elevation-md min-w-0 overflow-hidden border transition-[border-color,box-shadow]">
      <header className="phone:p-5 flex min-w-0 items-start gap-3 p-4">
        <span className="bg-primary-subtle text-primary rounded-control flex size-11 shrink-0 items-center justify-center">
          <FileCheck2 className="size-5" aria-hidden="true" />
        </span>
        <div className="flex min-w-0 flex-1 flex-wrap items-start justify-between gap-2">
          <div className="min-w-0">
            <h2 className="text-label text-text-primary font-semibold break-words">
              {report.employeeName?.trim() || `Employee #${report.employeeId}`}
            </h2>
            <p className="text-caption text-text-secondary mt-1">
              Daily work report · {formatDate(report.day)}
            </p>
          </div>
          <div className="flex shrink-0 flex-wrap items-center gap-1.5">
            <ReportStatus status={report.status} />
            {isOwnReport ? <StatusChip label="Your record" tone="neutral" dense /> : null}
          </div>
        </div>
      </header>
      <dl className="border-border-subtle phone:grid-cols-2 desktop:grid-cols-4 phone:px-5 grid min-w-0 grid-cols-1 gap-x-5 gap-y-3 border-t px-4 py-4">
        <div className="min-w-0">
          <dt className="text-overline text-text-muted">Employee ID</dt>
          <dd className="text-body-sm text-text-primary mt-1 font-medium break-words">
            #{report.employeeId}
          </dd>
        </div>
        <div className="min-w-0">
          <dt className="text-overline text-text-muted">Work hours</dt>
          <dd className="text-body-sm text-text-primary mt-1 font-medium tabular-nums">
            {report.hoursWorked.toFixed(1)} hours
          </dd>
        </div>
        <div className="min-w-0">
          <dt className="text-overline text-text-muted">Operational base</dt>
          <dd className="text-body-sm text-text-primary mt-1 font-medium break-words">
            {report.operationalBase?.trim() || 'Not provided'}
          </dd>
        </div>
        <div className="min-w-0">
          <dt className="text-overline text-text-muted">Attachments</dt>
          <dd className="text-body-sm text-text-primary mt-1 inline-flex items-center gap-1.5 font-medium">
            <Paperclip className="size-3.5 shrink-0" aria-hidden="true" />
            {report.attachments.length} {report.attachments.length === 1 ? 'file' : 'files'}
          </dd>
        </div>
      </dl>
      <section className="border-border-subtle phone:px-5 border-t px-4 py-3">
        <p className="text-overline text-text-muted">Work summary</p>
        <p className="text-body-sm text-text-secondary mt-1 line-clamp-2 leading-relaxed break-words">
          {reportSummary(report)}
        </p>
      </section>
      <footer className="border-border-subtle phone:flex-row phone:items-center phone:justify-between phone:px-5 flex min-w-0 flex-col gap-3 border-t px-4 py-3">
        <p className="text-overline text-text-muted min-w-0 break-all">Report ID · #{report.id}</p>
        <div className="phone:justify-end flex min-w-0 flex-wrap items-center justify-end gap-2">
          {canView ? (
            <Button size="sm" variant="outline" onClick={onOpen}>
              {isOwnReport ? 'View report' : 'Details'}
            </Button>
          ) : null}
          {canEdit ? (
            <Button variant="outline" size="sm" onClick={onEdit}>
              <Pencil className="size-4" aria-hidden="true" /> Edit
            </Button>
          ) : null}
          {canDelete ? (
            <Button variant="danger" size="sm" onClick={onDelete}>
              <Trash2 className="size-4" aria-hidden="true" /> Delete
            </Button>
          ) : null}
          {canReject ? (
            <Button variant="danger" size="sm" onClick={() => onReview('reject')}>
              <X className="size-4" aria-hidden="true" /> Reject
            </Button>
          ) : null}
          {canApprove ? (
            <Button size="sm" onClick={() => onReview('approve')}>
              <Check className="size-4" aria-hidden="true" /> Approve
            </Button>
          ) : null}
        </div>
      </footer>
    </article>
  )
}

export function HRWorkReportsPage() {
  const search = useSearch({ from: '/_protected/hr/work-report' }) as HRWorkReportsSearch
  return search.reportId ? <HRWorkReportDetailPage /> : <HRWorkReportsRegisterPage />
}

function HRWorkReportsRegisterPage() {
  const search = useSearch({ from: '/_protected/hr/work-report' }) as HRWorkReportsSearch
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeKey = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canList = hasPermission(permissions, 'work_reports', 'list')
  const canView = hasPermission(permissions, 'work_reports', 'view')
  const canApprove = hasPermission(permissions, 'work_reports', 'approve')
  const canReject = hasPermission(permissions, 'work_reports', 'reject')
  const canUpdate = hasPermission(permissions, 'work_reports', 'update')
  const canDelete = hasPermission(permissions, 'work_reports', 'delete')
  const [searchDraftState, setSearchDraftState] = useState({
    routeValue: search.search,
    value: search.search,
  })
  const [rating, setRating] = useState('')
  const [feedback, setFeedback] = useState('')
  const [actionError, setActionError] = useState('')
  const [deniedDecision, setDeniedDecision] = useState<{
    reportId: number
    decision: 'approve' | 'reject'
  } | null>(null)
  const [decisionTarget, setDecisionTarget] = useState<WorkReport | null>(null)
  const [decisionType, setDecisionType] = useState<'approve' | 'reject' | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<WorkReport | null>(null)
  const [editTarget, setEditTarget] = useState<WorkReport | null>(null)
  const searchDraft =
    searchDraftState.routeValue === search.search ? searchDraftState.value : search.search

  const params = {
    employeeId: 0,
    status: search.status as WorkReportStatusFilter,
    query: search.search,
    dateFrom: '',
    dateTo: '',
    limit: PAGE_SIZE,
    offset: (search.page - 1) * PAGE_SIZE,
  }
  const listQuery = useQuery({
    ...workReportsListQueryOptions(userId, employeeKey, params),
    enabled: Boolean(session && canList),
    placeholderData: keepPreviousData,
  })
  const editQuery = useQuery({
    ...workReportDetailQueryOptions(userId, employeeKey, editTarget?.id ?? 0),
    enabled: Boolean(session && canView && editTarget),
  })
  const decisionMutation = useMutation({
    mutationFn: ({
      id,
      decision,
      rating: chosenRating,
      feedback: chosenFeedback,
    }: {
      id: number
      decision: 'approve' | 'reject'
      rating: number | null
      feedback: string
    }) =>
      decision === 'approve'
        ? workReportsApi.approve(id, {
            rating: chosenRating,
            feedback: chosenFeedback.trim() || null,
          })
        : workReportsApi.reject(id, chosenFeedback.trim()),
    onSuccess: async (updatedReport, variables) => {
      setActionError('')
      setDeniedDecision(null)
      setDecisionTarget(null)
      setDecisionType(null)
      setFeedback('')
      setRating('')
      queryClient.setQueryData(
        workReportsQueryKeys.detail(userId, employeeKey, updatedReport.id),
        updatedReport,
      )
      await queryClient.invalidateQueries({
        queryKey: workReportsQueryKeys.lists(userId, employeeKey),
      })
      showToast({
        title: variables.decision === 'approve' ? 'Work report approved' : 'Work report rejected',
        description:
          variables.decision === 'approve'
            ? 'The employee report is now marked as approved.'
            : 'The report is marked Needs revision and was returned to the employee.',
        tone: 'success',
      })
    },
    onError: (error, variables) => {
      setActionError(presentError(error, 'form-submit').message)
      if (error instanceof ApiError && error.status === 403) {
        setDeniedDecision({ reportId: variables.id, decision: variables.decision })
      }
    },
  })
  const deleteMutation = useMutation({
    mutationFn: (report: WorkReport) => workReportsApi.remove(report.id),
    onSuccess: async (_, report) => {
      await queryClient.invalidateQueries({
        queryKey: workReportsQueryKeys.lists(userId, employeeKey),
      })
      queryClient.removeQueries({
        queryKey: workReportsQueryKeys.detail(userId, employeeKey, report.id),
        exact: true,
      })
      setDeleteTarget(null)
      showToast({
        title: 'Work report deleted',
        description: `The report for ${formatDate(report.day)} was removed.`,
        tone: 'success',
      })
    },
  })
  const editMutation = useMutation({
    mutationFn: ({
      reportId,
      input,
    }: {
      reportId: number
      input: WorkReportInput
      wasReturned: boolean
    }) => workReportsApi.update(reportId, input),
    onSuccess: async (updatedReport, variables) => {
      queryClient.setQueryData(
        workReportsQueryKeys.detail(userId, employeeKey, updatedReport.id),
        updatedReport,
      )
      await queryClient.invalidateQueries({
        queryKey: workReportsQueryKeys.lists(userId, employeeKey),
      })
      setEditTarget(null)
      showToast({
        title: 'Work report updated',
        description: variables.wasReturned
          ? 'The returned report is now a draft; its previous review details were cleared.'
          : 'The employee report changes were saved.',
        tone: 'success',
      })
    },
  })

  const updateSearch = (updates: Partial<HRWorkReportsSearch>) =>
    void navigate({
      to: '/hr/work-report',
      search: (previous: HRWorkReportsSearch) => ({ ...previous, ...updates }),
      resetScroll: false,
    })
  const submitSearch = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    updateSearch({ search: searchDraft.trim(), page: 1 })
  }
  const closeDecision = () => {
    setActionError('')
    setFeedback('')
    setRating('')
    setDecisionTarget(null)
    setDecisionType(null)
  }
  const openDecision = (report: WorkReport, decision: 'approve' | 'reject') => {
    setActionError('')
    setFeedback('')
    setRating('')
    setDecisionTarget(report)
    setDecisionType(decision)
  }
  const submitDecision = (decision: 'approve' | 'reject') => {
    const report = decisionTarget
    if (!report) return
    if (report.employeeId === session?.employee.id) return
    if (decision === 'reject' && !feedback.trim()) {
      setActionError('Add a reason before rejecting this report.')
      return
    }
    setActionError('')
    decisionMutation.mutate({
      id: report.id,
      decision,
      rating: rating ? Number(rating) : null,
      feedback,
    })
  }

  const reports = listQuery.data?.items ?? []
  const resultCount = listQuery.data?.count ?? 0
  const pageCount = Math.max(1, Math.ceil(resultCount / PAGE_SIZE))

  if (sessionQuery.isError) {
    return (
      <PageLayout title="Work reports" subtitle="Review employee daily submissions">
        <ErrorState
          title="Your HR session could not be loaded"
          description="Refresh to retry loading your permissions."
          error={sessionQuery.error}
        />
      </PageLayout>
    )
  }

  if (session && !canList) {
    return (
      <PageLayout title="Work reports" subtitle="Review employee daily submissions">
        <ErrorState
          title="You can’t view the HR review queue"
          description="Your account does not have permission to list employee work reports."
        />
      </PageLayout>
    )
  }

  return (
    <PageLayout
      title="Work reports"
      subtitle="Manage employee daily reports and review submitted work."
      leading={<FileCheck2 className="size-5" aria-hidden="true" />}
    >
      <div className="space-y-5">
        <Card className="tablet:p-5 space-y-4 p-4">
          <div className="flex flex-wrap items-end justify-between gap-3">
            <div>
              <p className="text-overline text-primary font-semibold">HR operations</p>
              <h2 className="text-h3 text-text-primary mt-1 font-semibold">Report register</h2>
              <p className="text-body-sm text-text-secondary mt-1">
                Review employee submissions and manage eligible reports.
              </p>
            </div>
            <p
              className="bg-surface-muted border-border-subtle text-caption text-text-secondary rounded-full border px-2.5 py-1 tabular-nums"
              aria-live="polite"
            >
              {listQuery.isPending && !listQuery.data
                ? 'Loading reports'
                : `${resultCount} ${resultCount === 1 ? 'report' : 'reports'}`}
            </p>
          </div>
          <form
            onSubmit={submitSearch}
            className="grid min-w-0 grid-cols-[minmax(0,1fr)_auto] items-end gap-3"
          >
            <FormControl
              id="hr-work-reports-search"
              label="Find employee ID or report content"
              className="min-w-0"
            >
              <span className="relative block">
                <Search
                  className="text-text-muted absolute top-1/2 left-3 size-4 -translate-y-1/2"
                  aria-hidden="true"
                />
                <TextInput
                  className="pl-10"
                  type="search"
                  aria-label="Find employee ID or report content"
                  maxLength={200}
                  value={searchDraft}
                  onChange={(event) =>
                    setSearchDraftState({
                      routeValue: search.search,
                      value: event.currentTarget.value,
                    })
                  }
                  placeholder="Employee ID, base, task, or activity"
                />
              </span>
            </FormControl>
            <div className="flex items-end gap-2">
              <Button
                type="submit"
                aria-label="Search reports"
                size="icon"
                leadingIcon={<Search className="size-4" aria-hidden="true" />}
                className="phone:h-11 phone:w-auto phone:px-4 shrink-0"
              >
                <span className="phone:inline hidden">Search</span>
              </Button>
              {search.search || search.status !== DEFAULT_HR_WORK_REPORT_STATUS ? (
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  className="h-11 shrink-0"
                  onClick={() => {
                    setSearchDraftState({ routeValue: '', value: '' })
                    updateSearch({
                      search: '',
                      status: DEFAULT_HR_WORK_REPORT_STATUS,
                      page: 1,
                    })
                  }}
                >
                  Clear
                </Button>
              ) : null}
            </div>
          </form>
          <FormControl id="hr-work-reports-status" label="Status">
            <DropdownSelect
              value={search.status}
              options={STATUS_OPTIONS}
              onChange={(status) =>
                updateSearch({ status: status as HRWorkReportsSearch['status'], page: 1 })
              }
              aria-label="Filter work reports by status"
            />
          </FormControl>
        </Card>

        {listQuery.isPending ? (
          <div className="space-y-3" aria-label="Loading work reports">
            {[0, 1, 2].map((item) => (
              <Skeleton key={item} className="h-36 w-full" />
            ))}
          </div>
        ) : listQuery.isError && !listQuery.data ? (
          <Card>
            <SectionErrorState
              title="Work reports could not be loaded"
              description="Retry the request. Your filters will stay in place."
              onRetry={() => void listQuery.refetch()}
            />
          </Card>
        ) : reports.length === 0 ? (
          <Card>
            <EmptyState
              title={
                search.search || search.status !== DEFAULT_HR_WORK_REPORT_STATUS
                  ? 'No reports match these filters'
                  : 'No reports need review'
              }
              description={
                search.search || search.status !== DEFAULT_HR_WORK_REPORT_STATUS
                  ? 'Clear the search or choose another status to see more reports.'
                  : 'Newly submitted employee reports will appear here when they are ready for review.'
              }
              icon={<FileText className="size-6" aria-hidden="true" />}
              action={
                search.search || search.status !== DEFAULT_HR_WORK_REPORT_STATUS ? (
                  <Button
                    variant="outline"
                    onClick={() =>
                      updateSearch({
                        search: '',
                        status: DEFAULT_HR_WORK_REPORT_STATUS,
                        page: 1,
                      })
                    }
                  >
                    Clear filters
                  </Button>
                ) : undefined
              }
            />
          </Card>
        ) : (
          <section aria-label="Employee work reports" className="space-y-3">
            {listQuery.isError ? (
              <SectionErrorState
                title="Showing saved results"
                description="The latest refresh failed. Retry to update the queue."
                onRetry={() => void listQuery.refetch()}
              />
            ) : null}
            {reports.map((report) => {
              const ownReport = Boolean(
                session?.employee.id && report.employeeId === session.employee.id,
              )
              const editableStatus = report.status === 'draft' || report.status === 'rejected'

              return (
                <ReportCard
                  key={report.id}
                  report={report}
                  isOwnReport={ownReport}
                  canView={canView}
                  canEdit={!ownReport && canView && editableStatus && canUpdate}
                  canDelete={!ownReport && editableStatus && canDelete}
                  canApprove={
                    !ownReport &&
                    report.status === 'submitted' &&
                    canApprove &&
                    (deniedDecision?.reportId !== report.id ||
                      deniedDecision.decision !== 'approve')
                  }
                  canReject={
                    !ownReport &&
                    report.status === 'submitted' &&
                    canReject &&
                    (deniedDecision?.reportId !== report.id || deniedDecision.decision !== 'reject')
                  }
                  onDelete={() => setDeleteTarget(report)}
                  onEdit={() => setEditTarget(report)}
                  onReview={(decision) => openDecision(report, decision)}
                  onOpen={() => {
                    setActionError('')
                    setDeniedDecision(null)
                    void navigate({
                      to: '/hr/work-report',
                      search: (previous: HRWorkReportsSearch) => ({
                        ...previous,
                        reportId: report.id,
                      }),
                    })
                  }}
                />
              )
            })}
            <Card className="flex flex-wrap items-center justify-between gap-3">
              <p className="text-caption text-text-secondary tabular-nums">
                Showing {(search.page - 1) * PAGE_SIZE + 1}–
                {Math.min(search.page * PAGE_SIZE, resultCount)} of {resultCount}
              </p>
              <div className="flex items-center gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  disabled={search.page <= 1}
                  onClick={() => updateSearch({ page: search.page - 1 })}
                >
                  <ChevronLeft className="size-4" aria-hidden="true" /> Previous
                </Button>
                <span className="text-caption text-text-secondary tabular-nums">
                  {search.page} / {pageCount}
                </span>
                <Button
                  variant="outline"
                  size="sm"
                  disabled={search.page >= pageCount}
                  onClick={() => updateSearch({ page: search.page + 1 })}
                >
                  Next <ChevronRight className="size-4" aria-hidden="true" />
                </Button>
              </div>
            </Card>
          </section>
        )}
      </div>

      <HRWorkReportDecisionDialog
        report={decisionTarget}
        decision={decisionType}
        rating={rating}
        feedback={feedback}
        busy={decisionMutation.isPending}
        error={actionError}
        confirmAllowed={
          !decisionTarget ||
          !decisionType ||
          !(
            deniedDecision?.reportId === decisionTarget.id &&
            deniedDecision.decision === decisionType
          )
        }
        onRatingChange={setRating}
        onFeedbackChange={(value) => {
          setFeedback(value)
          setActionError('')
        }}
        onConfirm={submitDecision}
        onClose={closeDecision}
      />

      <HRWorkReportEditDialog
        open={editTarget !== null}
        report={editTarget && editQuery.data?.id === editTarget.id ? editQuery.data : null}
        loading={Boolean(editTarget && editQuery.isPending)}
        loadError={
          editTarget && editQuery.isError
            ? presentError(editQuery.error, 'page-load').message
            : undefined
        }
        saving={editMutation.isPending}
        onOpenChange={(open) => {
          if (!open && !editMutation.isPending) setEditTarget(null)
        }}
        onRetry={() => void editQuery.refetch()}
        onSave={async (input) => {
          if (!editTarget) return
          await editMutation.mutateAsync({
            reportId: editTarget.id,
            input,
            wasReturned: editTarget.status === 'rejected',
          })
        }}
      />

      <Dialog
        open={deleteTarget !== null}
        onOpenChange={(open) => {
          if (!open && !deleteMutation.isPending) setDeleteTarget(null)
        }}
        title="Delete work report"
        description="This will permanently remove the selected draft or returned report."
        size="sm"
        fitContent
        compactOnMobile
        dismissDisabled={deleteMutation.isPending}
        footer={
          deleteTarget ? (
            <div className="flex flex-wrap justify-end gap-2">
              <Button
                variant="outline"
                disabled={deleteMutation.isPending}
                onClick={() => setDeleteTarget(null)}
              >
                Cancel
              </Button>
              <Button
                variant="danger"
                isLoading={deleteMutation.isPending}
                onClick={() => deleteMutation.mutate(deleteTarget)}
              >
                Delete report
              </Button>
            </div>
          ) : undefined
        }
      >
        {deleteTarget ? (
          <div className="space-y-3">
            {deleteMutation.isError ? (
              <Alert tone="danger" title="Report was not deleted">
                {presentError(deleteMutation.error, 'form-submit').message}
              </Alert>
            ) : null}
            <p className="text-body-sm text-text-primary">
              Delete this report from{' '}
              {deleteTarget.employeeName?.trim() || `Employee #${deleteTarget.employeeId}`} for{' '}
              {formatDate(deleteTarget.day)}?
            </p>
          </div>
        ) : null}
      </Dialog>
    </PageLayout>
  )
}
