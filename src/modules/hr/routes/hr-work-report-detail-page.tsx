import { useState, type ReactNode } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useSearch } from '@tanstack/react-router'
import {
  CalendarDays,
  Check,
  Clock3,
  FileCheck2,
  FileText,
  Pencil,
  Paperclip,
  Star,
  Trash2,
  UserRound,
  X,
} from 'lucide-react'

import {
  workReportsQueryKeys,
  workReportDetailQueryOptions,
} from '@/modules/work-reports/work-reports.queries'
import {
  ReportContentSummary,
  ReportEvidenceList,
  ReportOverviewSummary,
  type ReportEvidenceItem,
} from '@/modules/work-reports/components/report-summary'
import {
  workReportsApi,
  type WorkReport,
  type WorkReportInput,
  type WorkReportStatus,
} from '@/modules/work-reports/work-reports.api'
import { ApiError } from '@/shared/api/api-error'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { useToast } from '@/shared/feedback/use-toast'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'
import { PageLayout } from '@/shared/ui/page-layout'
import type { StatusTone } from '@/shared/ui/status-chip'
import { StatusChip } from '@/shared/ui/status-chip'
import { HRWorkReportDecisionDialog } from './hr-work-report-decision-dialog'
import { HRWorkReportEditDialog } from './hr-work-report-edit-dialog'
import type { HRWorkReportsSearch } from '../work-reports.search'

function formatDate(value: string): string {
  const [year, month, day] = value.slice(0, 10).split('-').map(Number)
  if (!year || !month || !day) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(new Date(year, month - 1, day))
}

function formatDateTime(value: string): string {
  const parsed = new Date(value)
  if (Number.isNaN(parsed.getTime())) return value
  return new Intl.DateTimeFormat(undefined, {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(parsed)
}

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

function reportStatusDescription(status: WorkReportStatus): string {
  return {
    draft: 'This employee report is saved as a draft and is not awaiting a review decision.',
    submitted: 'This report has been submitted and is waiting for an authorized review.',
    approved: 'This report has been reviewed and approved.',
    rejected: 'This report was returned to the employee with feedback and can be revised.',
  }[status]
}

function safeAttachmentUrl(value: string): string | null {
  try {
    const url = new URL(value, window.location.origin)
    return ['http:', 'https:'].includes(url.protocol) ? url.href : null
  } catch {
    return null
  }
}

function attachmentName(value: string, index: number): string {
  try {
    return decodeURIComponent(new URL(value).pathname.split('/').pop() || `Attachment ${index + 1}`)
  } catch {
    return `Attachment ${index + 1}`
  }
}

function ReportBackLink({ search }: { search: HRWorkReportsSearch }) {
  return (
    <Link
      to="/hr/work-report"
      search={(previous: HRWorkReportsSearch) => ({ ...previous, ...search, reportId: undefined })}
      className={pageBackLinkClassName}
    >
      <PageBackLinkContent>Work reports</PageBackLinkContent>
    </Link>
  )
}

function DetailFact({ icon, label, value }: { icon: ReactNode; label: string; value: string }) {
  return (
    <div className="border-border-subtle bg-surface-muted/70 rounded-control flex min-w-0 items-start gap-3 border p-3">
      <span className="bg-primary-subtle text-primary rounded-control flex size-8 shrink-0 items-center justify-center">
        {icon}
      </span>
      <div className="min-w-0">
        <p className="text-caption text-text-secondary">{label}</p>
        <p className="text-body-sm text-text-primary mt-1 font-medium break-words">{value}</p>
      </div>
    </div>
  )
}

export function HRWorkReportDetailPage() {
  const search = useSearch({ from: '/_protected/hr/work-report' }) as HRWorkReportsSearch
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeKey = session?.employee.employee_id ?? ''
  const reportId = search.reportId ?? 0
  const permissions = session?.permissions ?? {}
  const canView = hasPermission(permissions, 'work_reports', 'view')
  const canApprove = hasPermission(permissions, 'work_reports', 'approve')
  const canReject = hasPermission(permissions, 'work_reports', 'reject')
  const canUpdate = hasPermission(permissions, 'work_reports', 'update')
  const canDelete = hasPermission(permissions, 'work_reports', 'delete')
  const [decision, setDecision] = useState<'approve' | 'reject' | null>(null)
  const [decisionFeedback, setDecisionFeedback] = useState('')
  const [rating, setRating] = useState('')
  const [decisionError, setDecisionError] = useState('')
  const [deniedDecision, setDeniedDecision] = useState<'approve' | 'reject' | null>(null)
  const [editOpen, setEditOpen] = useState(false)
  const [deleteOpen, setDeleteOpen] = useState(false)
  const reportQuery = useQuery({
    ...workReportDetailQueryOptions(userId, employeeKey, reportId),
    enabled: Boolean(session && canView && Number.isSafeInteger(reportId) && reportId > 0),
  })
  const report = reportQuery.data
  const ownReport = Boolean(report && report.employeeId === session?.employee.id)

  const invalidateReports = async (updated?: WorkReport) => {
    if (updated) {
      queryClient.setQueryData(
        workReportsQueryKeys.detail(userId, employeeKey, updated.id),
        updated,
      )
    }
    await queryClient.invalidateQueries({
      queryKey: workReportsQueryKeys.lists(userId, employeeKey),
    })
  }

  const reviewMutation = useMutation({
    mutationFn: ({
      action,
      feedback,
      rating: selectedRating,
    }: {
      action: 'approve' | 'reject'
      feedback: string
      rating: number | null
    }) =>
      action === 'approve'
        ? workReportsApi.approve(reportId, {
            rating: selectedRating,
            feedback: feedback.trim() || null,
          })
        : workReportsApi.reject(reportId, feedback.trim()),
    onSuccess: async (updated, variables) => {
      await invalidateReports(updated)
      setDecision(null)
      setDecisionError('')
      setDecisionFeedback('')
      setRating('')
      setDeniedDecision(null)
      showToast({
        title: variables.action === 'approve' ? 'Work report approved' : 'Work report rejected',
        description:
          variables.action === 'approve'
            ? 'The employee report is now marked as approved.'
            : 'The report is marked Needs revision and was returned to the employee.',
        tone: 'success',
      })
    },
    onError: (error, variables) => {
      setDecisionError(presentError(error, 'form-submit').message)
      if (error instanceof ApiError && error.status === 403) setDeniedDecision(variables.action)
    },
  })
  const editMutation = useMutation({
    mutationFn: (input: WorkReportInput) => workReportsApi.update(reportId, input),
    onSuccess: async (updated) => {
      await invalidateReports(updated)
      setEditOpen(false)
      showToast({
        title: 'Work report updated',
        description:
          report?.status === 'rejected'
            ? 'The returned report is now a draft; its previous review details were cleared.'
            : 'The employee report changes were saved.',
        tone: 'success',
      })
    },
  })
  const deleteMutation = useMutation({
    mutationFn: () => workReportsApi.remove(reportId),
    onSuccess: async () => {
      await invalidateReports()
      queryClient.removeQueries({
        queryKey: workReportsQueryKeys.detail(userId, employeeKey, reportId),
        exact: true,
      })
      setDeleteOpen(false)
      showToast({
        title: 'Work report deleted',
        description: 'The employee report was removed.',
        tone: 'success',
      })
      void navigate({
        to: '/hr/work-report',
        search: (previous: HRWorkReportsSearch) => ({
          ...previous,
          ...search,
          reportId: undefined,
        }),
      })
    },
  })

  const openDecision = (action: 'approve' | 'reject') => {
    setDecisionError('')
    setDecisionFeedback('')
    setRating('')
    setDecision(action)
  }
  const closeDecision = () => {
    if (reviewMutation.isPending) return
    setDecision(null)
    setDecisionError('')
    setDecisionFeedback('')
    setRating('')
  }
  const confirmDecision = (action: 'approve' | 'reject') => {
    if (!report || ownReport || report.status !== 'submitted') return
    if (action === 'reject' && !decisionFeedback.trim()) {
      setDecisionError('Add a reason before rejecting this report.')
      return
    }
    setDecisionError('')
    reviewMutation.mutate({
      action,
      feedback: decisionFeedback,
      rating: rating ? Number(rating) : null,
    })
  }

  const backLink = <ReportBackLink search={search} />
  if (sessionQuery.isError) {
    return (
      <PageLayout title="Work report" backLink={backLink}>
        <ErrorState
          title="Your HR session could not be loaded"
          description="Return to the register and refresh to retry loading your permissions."
          error={sessionQuery.error}
        />
      </PageLayout>
    )
  }
  if (session && !canView) {
    return (
      <PageLayout title="Work report" backLink={backLink}>
        <ErrorState
          title="You can’t view this work report"
          description="Your account does not have permission to open report details."
        />
      </PageLayout>
    )
  }
  if (reportQuery.isPending) {
    return (
      <PageLayout title="Work report" backLink={backLink} contentClassName="space-y-4">
        <div className="space-y-4" aria-busy="true" aria-label="Loading work report details">
          <Skeleton variant="card" className="h-36" />
          <Skeleton variant="card" className="h-60" />
        </div>
      </PageLayout>
    )
  }
  if (!report) {
    return (
      <PageLayout title="Work report" backLink={backLink}>
        <ErrorState
          title="Report could not load"
          description="The report may have been removed or you may no longer have access to it."
          error={reportQuery.error}
          action={
            <Button variant="outline" onClick={() => void reportQuery.refetch()}>
              Try again
            </Button>
          }
        />
      </PageLayout>
    )
  }

  const canReview = report.status === 'submitted' && !ownReport
  const canEdit =
    !ownReport && canUpdate && (report.status === 'draft' || report.status === 'rejected')
  const canRemove =
    !ownReport && canDelete && (report.status === 'draft' || report.status === 'rejected')
  const evidence: ReportEvidenceItem[] = report.attachments.flatMap((attachment, index) => {
    const href = safeAttachmentUrl(attachment)
    return href
      ? [
          {
            id: `report-${report.id}-attachment-${index}`,
            name: attachmentName(href, index),
            detail: 'Supporting report file',
            href,
            status: 'attached' as const,
          },
        ]
      : []
  })
  return (
    <PageLayout
      title="Work report"
      backLink={backLink}
      leading={<FileCheck2 className="size-5" aria-hidden="true" />}
      actions={
        canEdit ? (
          <Button
            onClick={() => setEditOpen(true)}
            leadingIcon={<Pencil className="size-4" aria-hidden="true" />}
          >
            Edit report
          </Button>
        ) : undefined
      }
      actionsInline={canEdit}
      contentClassName="space-y-5"
    >
      {reportQuery.isError ? (
        <Alert tone="warning" title="Showing saved report details">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <span>The latest refresh failed. The report below may be out of date.</span>
            <Button variant="outline" size="sm" onClick={() => void reportQuery.refetch()}>
              Retry refresh
            </Button>
          </div>
        </Alert>
      ) : null}
      <ReportOverviewSummary
        day={report.day}
        hoursWorked={report.hoursWorked}
        operationalBase={report.operationalBase}
        status={{ label: statusLabel(report.status), tone: statusTone(report.status) }}
      />
      <Card className="tablet:p-5 space-y-4 p-4">
        <div className="flex min-w-0 flex-wrap items-center justify-between gap-3">
          <div className="flex min-w-0 items-center gap-3">
            <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
              <UserRound className="size-5" aria-hidden="true" />
            </span>
            <div className="min-w-0">
              <h2 className="text-label text-text-primary font-semibold break-words">
                {report.employeeName?.trim() || `Employee #${report.employeeId}`}
              </h2>
              <p className="text-caption text-text-secondary mt-0.5">
                Employee #{report.employeeId}
              </p>
            </div>
          </div>
          {ownReport ? <StatusChip label="Your record" tone="neutral" dense /> : null}
        </div>
        <dl className="phone:grid-cols-2 grid min-w-0 grid-cols-1 gap-3">
          <DetailFact
            icon={<CalendarDays className="size-4" aria-hidden="true" />}
            label="Submitted"
            value={formatDateTime(report.createdAt)}
          />
          <DetailFact
            icon={<Clock3 className="size-4" aria-hidden="true" />}
            label="Last updated"
            value={formatDateTime(report.updatedAt)}
          />
        </dl>
        <Alert tone={report.status === 'rejected' ? 'warning' : 'info'}>
          {reportStatusDescription(report.status)}
        </Alert>
        {canRemove ? (
          <div className="border-border-subtle flex flex-wrap items-center justify-between gap-3 border-t pt-3">
            <p className="text-caption text-text-muted">Report ID · #{report.id}</p>
            <Button
              variant="danger"
              size="sm"
              onClick={() => setDeleteOpen(true)}
              leadingIcon={<Trash2 className="size-4" aria-hidden="true" />}
            >
              Delete report
            </Button>
          </div>
        ) : null}
      </Card>
      <ReportContentSummary
        workActivities={
          report.workActivities?.trim() || report.summary || 'No work activities provided.'
        }
        taskDetails={report.taskDetails}
        planNextDay={report.planNextDay}
      />
      {evidence.length ? (
        <Card className="tablet:p-5 space-y-3 p-4">
          <div className="flex items-center gap-3">
            <span className="bg-primary-subtle text-primary rounded-control flex size-9 shrink-0 items-center justify-center">
              <Paperclip className="size-4" aria-hidden="true" />
            </span>
            <div>
              <h2 className="text-label text-text-primary font-semibold">Supporting evidence</h2>
              <p className="text-caption text-text-secondary mt-0.5">
                {evidence.length} {evidence.length === 1 ? 'file' : 'files'} attached to this report
              </p>
            </div>
          </div>
          <ReportEvidenceList items={evidence} />
        </Card>
      ) : null}
      {report.feedback || report.reviewedBy || report.reviewedAt || report.rating !== null ? (
        <Card className="tablet:p-5 space-y-3 p-4">
          <div className="flex flex-wrap items-start justify-between gap-3">
            <div className="flex min-w-0 items-center gap-3">
              <span className="bg-surface-muted text-text-secondary rounded-control flex size-9 shrink-0 items-center justify-center">
                <FileText className="size-4" aria-hidden="true" />
              </span>
              <div>
                <h2 className="text-label text-text-primary font-semibold">
                  {report.status === 'rejected' ? 'Reason for rejection' : 'Review history'}
                </h2>
                {report.reviewedBy ? (
                  <p className="text-caption text-text-secondary mt-0.5">
                    Reviewed by {report.reviewedBy}
                    {report.reviewedAt ? ` · ${formatDateTime(report.reviewedAt)}` : ''}
                  </p>
                ) : null}
              </div>
            </div>
            {report.rating !== null ? (
              <span className="bg-warning-subtle text-warning-foreground rounded-control inline-flex items-center gap-1.5 px-2.5 py-1 text-sm font-semibold tabular-nums">
                <Star className="size-4" aria-hidden="true" /> {report.rating}/5
              </span>
            ) : null}
          </div>
          <p className="text-body-sm text-text-secondary whitespace-pre-wrap">
            {report.feedback || 'No written feedback was provided.'}
          </p>
        </Card>
      ) : null}
      {canReview ? (
        canApprove || canReject ? (
          <Card className="tablet:p-5 space-y-4 p-4">
            <div>
              <p className="text-overline text-primary font-semibold">Manager action</p>
              <h2 className="text-h3 text-text-primary mt-1 font-semibold">Review decision</h2>
              <p className="text-body-sm text-text-secondary mt-1">
                Approve the submitted report or reject it with clear feedback for revision.
              </p>
            </div>
            <div className="phone:flex-row flex flex-col justify-end gap-2">
              {canReject && deniedDecision !== 'reject' ? (
                <Button
                  variant="danger"
                  onClick={() => openDecision('reject')}
                  leadingIcon={<X className="size-4" aria-hidden="true" />}
                >
                  Reject report
                </Button>
              ) : null}
              {canApprove && deniedDecision !== 'approve' ? (
                <Button
                  onClick={() => openDecision('approve')}
                  leadingIcon={<Check className="size-4" aria-hidden="true" />}
                >
                  Approve report
                </Button>
              ) : null}
              {deniedDecision ? (
                <Alert tone="warning" title="Review permission unavailable">
                  Your account cannot perform this review action. The report remains unchanged.
                </Alert>
              ) : null}
            </div>
          </Card>
        ) : (
          <Alert tone="info" title="View-only access">
            Your account can view this submitted report but cannot approve or reject it.
          </Alert>
        )
      ) : report.status === 'submitted' && ownReport ? (
        <Alert tone="info" title="Self-review is not allowed">
          Your personal report is available here for reference. Manage your submission from My Work.
        </Alert>
      ) : null}
      <HRWorkReportDecisionDialog
        report={report}
        decision={decision}
        rating={rating}
        feedback={decisionFeedback}
        busy={reviewMutation.isPending}
        error={decisionError}
        confirmAllowed={
          decision === 'approve'
            ? canApprove && deniedDecision !== 'approve'
            : canReject && deniedDecision !== 'reject'
        }
        onRatingChange={setRating}
        onFeedbackChange={(value) => {
          setDecisionFeedback(value)
          setDecisionError('')
        }}
        onConfirm={confirmDecision}
        onClose={closeDecision}
      />
      <HRWorkReportEditDialog
        open={editOpen}
        report={report}
        loading={false}
        saving={editMutation.isPending}
        onOpenChange={(open) => {
          if (!open && !editMutation.isPending) setEditOpen(false)
        }}
        onRetry={() => void reportQuery.refetch()}
        onSave={async (input) => {
          await editMutation.mutateAsync(input)
        }}
      />
      <Dialog
        open={deleteOpen}
        onOpenChange={(open) => {
          if (!open && !deleteMutation.isPending) setDeleteOpen(false)
        }}
        title="Delete work report?"
        description="This permanently removes the selected draft or returned report."
        size="sm"
        fitContent
        compactOnMobile
        dismissDisabled={deleteMutation.isPending}
        footer={
          <div className="flex flex-wrap justify-end gap-2">
            <Button
              variant="outline"
              disabled={deleteMutation.isPending}
              onClick={() => setDeleteOpen(false)}
            >
              Cancel
            </Button>
            <Button
              variant="danger"
              isLoading={deleteMutation.isPending}
              onClick={() => deleteMutation.mutate()}
            >
              Delete report
            </Button>
          </div>
        }
      >
        <div className="space-y-3">
          {deleteMutation.isError ? (
            <Alert tone="danger" title="Report was not deleted" role="alert">
              {presentError(deleteMutation.error, 'form-submit').message}
            </Alert>
          ) : null}
          <p className="text-body-sm text-text-primary">
            Delete {report.employeeName?.trim() || `Employee #${report.employeeId}`}’s report for{' '}
            {formatDate(report.day)}?
          </p>
        </div>
      </Dialog>
    </PageLayout>
  )
}
