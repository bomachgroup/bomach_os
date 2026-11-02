import { useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useParams, useSearch } from '@tanstack/react-router'
import { FileText, Pencil, Trash2, Undo2 } from 'lucide-react'

import { personalOverviewQueryKey } from '@/modules/dashboard/dashboard.api'
import { personalWorkQueryKeys } from '@/modules/dashboard/personal-work.api'
import { presentError } from '@/shared/errors'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { PageLayout } from '@/shared/ui/page-layout'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'
import type { StatusTone } from '@/shared/ui/status-chip'
import { useToast } from '@/shared/feedback/use-toast'

import { workReportsApi, type WorkReport, type WorkReportStatus } from '../work-reports.api'
import { workReportDetailQueryOptions, workReportsQueryKeys } from '../work-reports.queries'
import type { WorkReportsSearch } from '../work-reports.search'
import {
  ReportContentSummary,
  ReportEvidenceList,
  ReportOverviewSummary,
  type ReportEvidenceItem,
} from '../components/report-summary'

function ReportHistoryBackLink({ search }: { search: WorkReportsSearch }) {
  return (
    <Link to="/dashboard/my-reports" search={search} className={pageBackLinkClassName}>
      <PageBackLinkContent>My Work Reports</PageBackLinkContent>
    </Link>
  )
}

function presentation(status: WorkReportStatus): {
  label: string
  tone: StatusTone
  description: string
} {
  switch (status) {
    case 'draft':
      return {
        label: 'Draft',
        tone: 'neutral',
        description: 'Only you can see this draft until you submit it for review.',
      }
    case 'submitted':
      return {
        label: 'In review',
        tone: 'info',
        description: 'Your report has been submitted and is waiting for review.',
      }
    case 'approved':
      return {
        label: 'Approved',
        tone: 'success',
        description: 'This report has been reviewed and approved. It is now read-only.',
      }
    case 'rejected':
      return {
        label: 'Needs revision',
        tone: 'danger',
        description: 'Review the feedback, update the report, and resubmit it.',
      }
  }
}

function safeUrl(value: string): string | null {
  try {
    const url = new URL(value, window.location.origin)
    return ['http:', 'https:'].includes(url.protocol) ? url.href : null
  } catch {
    return null
  }
}

function fileLabel(value: string): string {
  try {
    return decodeURIComponent(new URL(value).pathname.split('/').pop() || 'Attachment')
  } catch {
    return 'Attachment'
  }
}

function mediaTypeFor(value: string): string | undefined {
  const extension = value.split('?')[0]?.split('.').pop()?.toLowerCase()
  if (extension && /^(png|jpe?g|gif|webp|avif|heic)$/.test(extension)) return 'image/*'
  if (extension && /^(mp4|mov|webm|m4v)$/.test(extension)) return 'video/*'
  if (extension && /^(mp3|wav|m4a|aac|ogg)$/.test(extension)) return 'audio/*'
  return undefined
}

export function WorkReportDetailPage() {
  const params = useParams({ strict: false }) as { reportId?: string }
  const search = useSearch({ strict: false }) as WorkReportsSearch
  const reportId = Number(params.reportId)
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const toast = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canView =
    hasPermission(permissions, 'work_reports', 'view_own') ||
    hasPermission(permissions, 'work_reports', 'view')
  const reportQuery = useQuery({
    ...workReportDetailQueryOptions(userId, employeeId, reportId),
    enabled: Boolean(session && canView && Number.isSafeInteger(reportId) && reportId > 0),
  })
  const [confirmation, setConfirmation] = useState<'withdraw' | 'delete' | null>(null)
  const [actionError, setActionError] = useState<string | null>(null)
  const report = reportQuery.data
  const reportEvidence: ReportEvidenceItem[] = (report?.attachments ?? []).flatMap(
    (attachment, index) => {
      const url = safeUrl(attachment)
      return url
        ? [
            {
              id: `report-attachment-${index}`,
              name: fileLabel(url),
              detail: 'Report attachment',
              href: url,
              mediaType: mediaTypeFor(url),
              status: 'attached' as const,
            },
          ]
        : []
    },
  )
  const canUpdate =
    hasPermission(permissions, 'work_reports', 'update_own') ||
    hasPermission(permissions, 'work_reports', 'update')
  const canDelete =
    hasPermission(permissions, 'work_reports', 'delete_own') ||
    hasPermission(permissions, 'work_reports', 'delete')

  const invalidateAfterChange = async (updated?: WorkReport) => {
    if (updated)
      queryClient.setQueryData(workReportsQueryKeys.detail(userId, employeeId, updated.id), updated)
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: workReportsQueryKeys.lists(userId, employeeId) }),
      queryClient.invalidateQueries({
        queryKey: personalWorkQueryKeys.reports(userId, employeeId),
      }),
      queryClient.invalidateQueries({
        queryKey: personalOverviewQueryKey(userId, employeeId),
      }),
    ])
  }
  const withdrawMutation = useMutation({
    mutationFn: () => workReportsApi.withdraw(reportId),
    onSuccess: async (updated) => {
      await invalidateAfterChange(updated)
      setConfirmation(null)
      setActionError(null)
      toast.showToast({
        title: 'Report withdrawn',
        description: 'You can now edit and resubmit the report.',
        tone: 'success',
      })
      await navigate({
        to: '/dashboard/my-reports/$reportId/edit',
        params: { reportId: String(reportId) },
        search,
      })
    },
    onError: (error) => setActionError(presentError(error, 'form-submit').message),
  })
  const deleteMutation = useMutation({
    mutationFn: () => workReportsApi.remove(reportId),
    onSuccess: async () => {
      queryClient.removeQueries({
        queryKey: workReportsQueryKeys.detail(userId, employeeId, reportId),
      })
      await invalidateAfterChange()
      setConfirmation(null)
      toast.showToast({
        title: 'Report deleted',
        description: 'The work report was removed.',
        tone: 'success',
      })
      await navigate({ to: '/dashboard/my-reports', search })
    },
    onError: (error) => setActionError(presentError(error, 'destructive-action').message),
  })

  if (session && !canView)
    return (
      <PageLayout title="Work report" backLink={<ReportHistoryBackLink search={search} />}>
        <ErrorState
          title="You can’t view this report"
          description="Your account does not have permission to view work report details."
          error={sessionQuery.error}
        />
      </PageLayout>
    )
  if (reportQuery.isPending)
    return (
      <PageLayout title="Work report" backLink={<ReportHistoryBackLink search={search} />}>
        <div className="space-y-4" aria-busy="true">
          <Skeleton variant="card" className="h-32" />
          <Skeleton variant="card" className="h-72" />
        </div>
      </PageLayout>
    )
  if (!report)
    return (
      <PageLayout
        title="Work report"
        backLink={
          <Link to="/dashboard/my-reports" search={search} className={pageBackLinkClassName}>
            <PageBackLinkContent>My Work Reports</PageBackLinkContent>
          </Link>
        }
      >
        <ErrorState
          title="Report could not load"
          description="The report may have been removed or you may no longer have access."
          error={reportQuery.error}
          action={
            <Button variant="outline" onClick={() => void reportQuery.refetch()}>
              Try again
            </Button>
          }
        />
      </PageLayout>
    )

  const status = presentation(report.status)
  const canEdit = canUpdate && (report.status === 'draft' || report.status === 'rejected')
  const canWithdraw = canUpdate && report.status === 'submitted'
  const canRemove = canDelete && (report.status === 'draft' || report.status === 'rejected')

  return (
    <PageLayout
      title="Work report"
      subtitle="Daily work record and review history"
      backLink={<ReportHistoryBackLink search={search} />}
      leading={<FileText className="size-[18px]" aria-hidden="true" />}
      actionsInline={canEdit}
      actions={
        canEdit ? (
          <Link
            aria-label="Edit work report"
            className="rounded-control bg-primary text-text-on-primary hover:bg-primary-hover active:bg-primary-pressed focus-visible:shadow-focus-ring text-caption inline-flex min-h-9 items-center justify-center gap-2 px-3 font-semibold focus-visible:outline-none max-[479px]:px-2.5"
            to="/dashboard/my-reports/$reportId/edit"
            params={{ reportId: String(report.id) }}
            search={search}
          >
            <Pencil className="size-4" aria-hidden="true" />
            <span className="max-[479px]:hidden">Edit report</span>
            <span className="hidden max-[479px]:inline max-[361px]:hidden">Edit</span>
          </Link>
        ) : null
      }
      contentClassName="space-y-5"
    >
      {reportQuery.isError ? (
        <Alert tone="warning" title="Showing the saved report">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <span>The latest refresh failed. The report details below are still available.</span>
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
        status={{ label: status.label, tone: status.tone }}
      />
      <Card className="tablet:p-5 p-4">
        <Alert
          tone={
            status.tone === 'success' ? 'success' : status.tone === 'danger' ? 'warning' : 'info'
          }
        >
          {status.description}
        </Alert>
      </Card>

      {report.status === 'rejected' ? (
        <Card className="border-danger/30">
          <h2 className="text-label text-text-primary font-semibold">Reviewer feedback</h2>
          <p className="text-body-md text-text-secondary mt-2 whitespace-pre-wrap">
            {report.feedback || 'The reviewer did not leave a written comment.'}
          </p>
          {report.reviewedBy ? (
            <p className="text-caption text-text-muted mt-3">
              Reviewed by {report.reviewedBy}
              {report.reviewedAt ? ` · ${new Date(report.reviewedAt).toLocaleString()}` : ''}
            </p>
          ) : null}
        </Card>
      ) : null}
      {report.status === 'approved' && (report.feedback || report.rating !== null) ? (
        <Card>
          <div className="flex flex-wrap items-start justify-between gap-4">
            <div className="min-w-0 flex-1">
              <h2 className="text-label text-text-primary font-semibold">Review feedback</h2>
              <p className="text-body-md text-text-secondary mt-2 whitespace-pre-wrap">
                {report.feedback || 'No written feedback was provided.'}
              </p>
              {report.reviewedBy ? (
                <p className="text-caption text-text-muted mt-3">
                  Reviewed by {report.reviewedBy}
                  {report.reviewedAt ? ` · ${new Date(report.reviewedAt).toLocaleString()}` : ''}
                </p>
              ) : null}
            </div>
            {report.rating !== null ? (
              <div className="bg-success-subtle text-success-foreground rounded-control px-3 py-2">
                <p className="text-caption">Rating</p>
                <p className="text-h3 font-semibold">{report.rating}/5</p>
              </div>
            ) : null}
          </div>
        </Card>
      ) : null}

      <ReportContentSummary
        workActivities={report.workActivities}
        taskDetails={report.taskDetails}
        planNextDay={report.planNextDay}
      />

      {reportEvidence.length ? (
        <Card className="tablet:p-5 space-y-3 p-4">
          <div>
            <h2 className="text-h3 text-text-primary font-semibold">Supporting evidence</h2>
          </div>
          <ReportEvidenceList items={reportEvidence} previewImages />
        </Card>
      ) : null}

      {actionError && !confirmation ? (
        <Alert tone="danger" role="alert" title="Action not completed">
          {actionError}
        </Alert>
      ) : null}
      {canWithdraw || canRemove ? (
        <Card className="tablet:flex-row tablet:items-center tablet:justify-between flex flex-col gap-3">
          <div>
            <h2 className="text-label text-text-primary font-semibold">Report actions</h2>
            <p className="text-body-sm text-text-secondary mt-1">
              {canWithdraw
                ? 'Withdraw a submitted report to make corrections.'
                : 'Delete this draft or returned report.'}
            </p>
          </div>
          <div className="flex flex-wrap gap-2">
            {canWithdraw ? (
              <Button
                variant="outline"
                onClick={() => {
                  setActionError(null)
                  setConfirmation('withdraw')
                }}
                leadingIcon={<Undo2 className="size-4" />}
              >
                Withdraw for editing
              </Button>
            ) : null}
            {canRemove ? (
              <Button
                variant="danger"
                onClick={() => {
                  setActionError(null)
                  setConfirmation('delete')
                }}
                leadingIcon={<Trash2 className="size-4" />}
              >
                Delete report
              </Button>
            ) : null}
          </div>
        </Card>
      ) : null}

      <Dialog
        open={confirmation !== null}
        onOpenChange={(open) => {
          if (!open && !withdrawMutation.isPending && !deleteMutation.isPending) {
            setConfirmation(null)
            setActionError(null)
          }
        }}
        title={confirmation === 'withdraw' ? 'Withdraw this report?' : 'Delete this report?'}
        description={
          confirmation === 'withdraw'
            ? 'The report will return to draft status so you can make changes and submit it again.'
            : 'This permanently removes the draft or returned work report.'
        }
        size="sm"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button
              variant="outline"
              disabled={withdrawMutation.isPending || deleteMutation.isPending}
              onClick={() => setConfirmation(null)}
            >
              Cancel
            </Button>
            <Button
              variant={confirmation === 'delete' ? 'danger' : 'primary'}
              isLoading={withdrawMutation.isPending || deleteMutation.isPending}
              onClick={() =>
                confirmation === 'withdraw' ? withdrawMutation.mutate() : deleteMutation.mutate()
              }
            >
              {confirmation === 'withdraw' ? 'Withdraw report' : 'Delete report'}
            </Button>
          </>
        }
      >
        {actionError ? (
          <Alert tone="danger" role="alert">
            {actionError}
          </Alert>
        ) : (
          <p className="text-body-sm text-text-secondary">
            {confirmation === 'withdraw'
              ? 'You will be taken to the edit form after withdrawal completes.'
              : 'This action cannot be undone.'}
          </p>
        )}
      </Dialog>
    </PageLayout>
  )
}
