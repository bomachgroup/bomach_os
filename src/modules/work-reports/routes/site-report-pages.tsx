import { useEffect, useRef, useState, type FormEvent, type ReactNode } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useForm } from '@tanstack/react-form'
import { Link, useNavigate, useParams, useSearch } from '@tanstack/react-router'
import {
  CalendarDays,
  ClipboardCheck,
  FileText,
  MapPin,
  Package,
  Paperclip,
  Pencil,
  Ruler,
  Star,
  Trash2,
  Upload,
} from 'lucide-react'

import { presentError } from '@/shared/errors'
import {
  authSessionQueryOptions,
  hasPermission,
  type AuthenticatedSession,
} from '@/shared/auth/session'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { EmptyState, ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'
import { useToast } from '@/shared/feedback/use-toast'
import type {
  BearingDistancePoint,
  SiteReport,
  SiteReportType,
  XyzPoint,
} from '../site-reports.api'
import {
  siteReportsApi,
  type EngineeringSiteReportUpdate,
  type SurveySiteReportUpdate,
} from '../site-reports.api'
import {
  siteEquipmentOptions,
  siteReportDetailOptions,
  siteReportQueryKeys,
} from '../site-reports.queries'
import type { WorkReportsSearch } from '../work-reports.search'
import { DropdownSelect } from '@/shared/ui/dropdown-select'

function reportType(value: string | undefined): SiteReportType | null {
  return value === 'engineering' || value === 'survey' ? value : null
}

function labelForType(type: SiteReportType): string {
  return type === 'engineering' ? 'Engineering site report' : 'Survey site report'
}

function statusTone(status: SiteReport['status']): StatusTone {
  return status === 'approved'
    ? 'success'
    : status === 'submitted'
      ? 'info'
      : status === 'rejected'
        ? 'danger'
        : 'neutral'
}

function formatDate(value: string | null | undefined): string {
  if (!value) return 'Not recorded'
  const date = new Date(`${value.slice(0, 10)}T00:00:00`)
  return Number.isNaN(date.getTime())
    ? value
    : new Intl.DateTimeFormat(undefined, { dateStyle: 'medium' }).format(date)
}

function isValidDateInput(value: string): boolean {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value)
  if (!match) return false
  const [, yearText, monthText, dayText] = match
  const year = Number(yearText)
  const month = Number(monthText)
  const day = Number(dayText)
  const date = new Date(Date.UTC(year, month - 1, day))
  return (
    date.getUTCFullYear() === year && date.getUTCMonth() === month - 1 && date.getUTCDate() === day
  )
}

function safeAttachment(value: string): string | null {
  try {
    const url = new URL(value, window.location.origin)
    return ['http:', 'https:'].includes(url.protocol) ? url.href : null
  } catch {
    return null
  }
}

function reportAccess(session: AuthenticatedSession, type: SiteReportType) {
  const resource = type === 'engineering' ? 'engineering_site_reports' : 'survey_site_reports'
  const has = (action: string) =>
    hasPermission(session.permissions, resource, `${action}_own`) ||
    hasPermission(session.permissions, resource, action)
  return {
    canView: has('view'),
    canUpdate: has('update'),
    canSubmit: has('submit'),
    canDelete: has('delete'),
  }
}

function SiteReportBackLink({ search }: { search: WorkReportsSearch }) {
  return (
    <Link
      to="/dashboard/my-reports"
      search={{ ...search, type: 'site' }}
      className={pageBackLinkClassName}
    >
      <PageBackLinkContent>My Site Reports</PageBackLinkContent>
    </Link>
  )
}

export function SiteReportDetailPage() {
  const params = useParams({ strict: false }) as { reportType?: string; reportId?: string }
  const search = useSearch({ strict: false }) as WorkReportsSearch
  const type = reportType(params.reportType)
  const reportId = Number(params.reportId)
  const navigate = useNavigate()
  const client = useQueryClient()
  const toast = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const access = session && type ? reportAccess(session, type) : null
  const query = useQuery({
    ...siteReportDetailOptions(type ?? 'engineering', userId, employeeId, reportId),
    enabled: Boolean(
      session && access?.canView && type && Number.isSafeInteger(reportId) && reportId > 0,
    ),
  })
  const [confirmation, setConfirmation] = useState<'submit' | 'delete' | null>(null)
  const [actionError, setActionError] = useState('')
  const report = query.data
  const canEdit = Boolean(
    access?.canUpdate && report && ['draft', 'rejected'].includes(report.status),
  )
  const canSubmit = Boolean(access?.canSubmit && report?.status === 'draft')
  const canDelete = Boolean(
    access?.canDelete && report && ['draft', 'rejected'].includes(report.status),
  )

  const refreshLists = async () => {
    if (!type || !session) return
    await client.invalidateQueries({
      queryKey: siteReportQueryKeys.lists(type, userId, employeeId),
    })
  }
  const submitMutation = useMutation({
    mutationFn: () => siteReportsApi.submit(type!, reportId),
    onSuccess: async (updated) => {
      client.setQueryData(siteReportQueryKeys.detail(type!, userId, employeeId, reportId), updated)
      await refreshLists()
      setConfirmation(null)
      setActionError('')
      toast.showToast({
        title: 'Report submitted',
        description: 'Your report was sent for review.',
        tone: 'success',
      })
    },
    onError: (error) => setActionError(presentError(error, 'form-submit').message),
  })
  const deleteMutation = useMutation({
    mutationFn: () => siteReportsApi.remove(type!, reportId),
    onSuccess: async () => {
      client.removeQueries({
        queryKey: siteReportQueryKeys.detail(type!, userId, employeeId, reportId),
      })
      await refreshLists()
      setConfirmation(null)
      toast.showToast({
        title: 'Report deleted',
        description: 'The site report was removed.',
        tone: 'success',
      })
      await navigate({ to: '/dashboard/my-reports', search: { ...search, type: 'site' } })
    },
    onError: (error) => setActionError(presentError(error, 'destructive-action').message),
  })

  if (!type || !Number.isSafeInteger(reportId) || reportId < 1 || (session && !access?.canView)) {
    return (
      <PageLayout title="Site report" backLink={<SiteReportBackLink search={search} />}>
        <ErrorState
          title="You can’t view this report"
          description="Your account does not have permission to view this site report."
        />
      </PageLayout>
    )
  }
  if (query.isPending) {
    return (
      <PageLayout
        title={type === 'engineering' ? 'Engineering report' : 'Survey report'}
        backLink={<SiteReportBackLink search={search} />}
      >
        <div className="space-y-4" aria-busy="true">
          <Skeleton variant="card" className="h-32" />
          <Skeleton variant="card" className="h-72" />
        </div>
      </PageLayout>
    )
  }
  if (!report) {
    return (
      <PageLayout
        title={type === 'engineering' ? 'Engineering report' : 'Survey report'}
        backLink={<SiteReportBackLink search={search} />}
      >
        <ErrorState
          title="Report could not load"
          description="The report may have been removed or you may no longer have access."
          error={query.error}
          action={
            <Button variant="outline" onClick={() => void query.refetch()}>
              Try again
            </Button>
          }
        />
      </PageLayout>
    )
  }

  return (
    <PageLayout
      title={type === 'engineering' ? 'Engineering report' : 'Survey report'}
      subtitle={report.worksite_name}
      leading={<MapPin className="size-[18px]" aria-hidden="true" />}
      backLink={<SiteReportBackLink search={search} />}
      actionsInline={canEdit}
      actions={
        canEdit ? (
          <Link
            to="/dashboard/my-reports/site/$reportType/$reportId/edit"
            params={{ reportType: type, reportId: String(report.id) }}
            search={{ ...search, type: 'site' }}
            aria-label="Edit report"
            className="rounded-control bg-primary text-text-on-primary hover:bg-primary-hover focus-visible:shadow-focus-ring text-caption inline-flex min-h-9 items-center justify-center gap-2 px-3 font-semibold focus-visible:outline-none max-[479px]:px-2.5"
          >
            <Pencil className="size-4" aria-hidden="true" />
            <span className="max-[479px]:hidden">Edit report</span>
            <span className="hidden max-[479px]:inline max-[361px]:hidden">Edit</span>
          </Link>
        ) : undefined
      }
      contentClassName="space-y-5"
    >
      {query.isError ? (
        <Alert tone="warning" title="Showing saved report">
          The latest refresh failed. The details below may be out of date.{' '}
          <Button variant="outline" size="sm" onClick={() => void query.refetch()}>
            Retry refresh
          </Button>
        </Alert>
      ) : null}
      <Card className="overflow-hidden p-0">
        <div className="bg-primary-subtle/60 border-border-subtle tablet:px-6 tablet:py-6 border-b px-4 py-5">
          <div className="flex flex-wrap items-start justify-between gap-3">
            <div className="flex min-w-0 flex-1 items-start gap-3">
              <span className="text-primary bg-surface rounded-control shadow-elevation-sm flex size-11 shrink-0 items-center justify-center">
                <ClipboardCheck className="size-5" aria-hidden="true" />
              </span>
              <div className="min-w-0">
                <p className="text-overline text-primary font-semibold">Report overview</p>
                <h2 className="text-h2 tablet:text-h3 text-text-primary mt-1 font-semibold break-words">
                  {report.summary.trim() || labelForType(type)}
                </h2>
                <p className="text-body-sm text-text-secondary mt-1">
                  {type === 'engineering' ? 'Engineering' : 'Survey'} site report · Report{' '}
                  {report.id}
                </p>
              </div>
            </div>
            <StatusChip
              label={
                report.status === 'rejected'
                  ? 'Needs revision'
                  : report.status === 'submitted'
                    ? 'In review'
                    : report.status[0]!.toUpperCase() + report.status.slice(1)
              }
              tone={statusTone(report.status)}
            />
          </div>
        </div>
        <dl className="phone:grid-cols-2 tablet:gap-3 tablet:p-4 desktop:grid-cols-4 grid grid-cols-2 gap-2.5 p-3 max-[359px]:grid-cols-1">
          <OverviewMetric
            icon={<MapPin className="size-4" aria-hidden="true" />}
            label="Worksite"
            value={report.worksite_name}
          />
          <OverviewMetric
            icon={<CalendarDays className="size-4" aria-hidden="true" />}
            label="Report date"
            value={formatDate(report.date)}
          />
          <OverviewMetric
            icon={<Star className="text-warning-foreground size-4" aria-hidden="true" />}
            label="Rating"
            value={report.rating === null ? 'Not rated' : `${report.rating}/5`}
          />
          <OverviewMetric
            icon={<ClipboardCheck className="size-4" aria-hidden="true" />}
            label="Reviewed"
            value={report.reviewed_at ? formatDate(report.reviewed_at) : 'Not reviewed'}
          />
        </dl>
        {report.status === 'rejected' ? (
          <div className="tablet:px-4 tablet:pb-4 px-3 pb-3">
            <Alert tone="warning" title="Reviewer feedback">
              {report.summary || 'The reviewer did not leave a written note.'}
            </Alert>
          </div>
        ) : null}
      </Card>

      <Card className="overflow-hidden p-0">
        <div className="border-border-subtle tablet:px-6 tablet:py-5 flex items-center gap-3 border-b px-4 py-4">
          <span className="text-primary bg-primary-subtle rounded-control flex size-10 shrink-0 items-center justify-center">
            {type === 'engineering' ? (
              <FileText className="size-5" aria-hidden="true" />
            ) : (
              <Ruler className="size-5" aria-hidden="true" />
            )}
          </span>
          <div className="min-w-0">
            <p className="text-overline text-primary font-semibold">Report record</p>
            <h2 className="text-h3 text-text-primary font-semibold">
              {type === 'engineering' ? 'Engineering details' : 'Survey details'}
            </h2>
          </div>
        </div>
        <div className="tablet:p-6 space-y-4 p-4">
          {type === 'engineering' ? (
            <EngineeringDetails report={report} />
          ) : (
            <SurveyDetails report={report} />
          )}
        </div>
      </Card>

      {report.attachments.length ? (
        <Card className="tablet:p-5 space-y-4 p-4">
          <div className="flex items-center gap-3">
            <span className="text-primary bg-primary-subtle rounded-control flex size-10 shrink-0 items-center justify-center">
              <Paperclip className="size-5" aria-hidden="true" />
            </span>
            <div>
              <h2 className="text-h3 text-text-primary font-semibold">Attachments</h2>
              <p className="text-body-sm text-text-secondary">
                {report.attachments.length} {report.attachments.length === 1 ? 'file' : 'files'}
              </p>
            </div>
          </div>
          <ul className="phone:grid-cols-2 desktop:grid-cols-3 grid gap-2">
            {report.attachments.map((attachment, index) => {
              const href = safeAttachment(attachment)
              return (
                <li
                  key={`${attachment}-${index}`}
                  className="rounded-control border-border-subtle bg-surface-muted/60 min-w-0 border p-3"
                >
                  {href ? (
                    <a
                      href={href}
                      target="_blank"
                      rel="noreferrer"
                      className="focus-visible:shadow-focus-ring text-primary rounded-control inline-flex min-h-10 max-w-full items-center gap-2 font-medium underline focus-visible:outline-none"
                    >
                      <FileText className="size-4 shrink-0" aria-hidden="true" />
                      <span className="text-body-sm truncate">Attachment {index + 1}</span>
                    </a>
                  ) : (
                    <span className="text-body-sm text-text-muted">
                      Attachment {index + 1} has an unsupported link.
                    </span>
                  )}
                </li>
              )
            })}
          </ul>
        </Card>
      ) : null}
      {actionError && !confirmation ? (
        <Alert tone="danger" role="alert" title="Action not completed">
          {actionError}
        </Alert>
      ) : null}
      {canSubmit || canDelete ? (
        <Card className="tablet:flex-row tablet:items-center tablet:justify-between flex flex-col gap-3">
          <div>
            <h2 className="text-label text-text-primary font-semibold">Report actions</h2>
            <p className="text-body-sm text-text-secondary mt-1">
              Only draft and returned reports can be changed or removed.
            </p>
          </div>
          <div
            className={
              canSubmit && canDelete
                ? 'tablet:flex tablet:w-auto tablet:flex-nowrap grid w-full grid-cols-2 gap-2'
                : 'tablet:w-auto flex w-full gap-2'
            }
          >
            {canSubmit ? (
              <Button
                aria-label="Submit for review"
                onClick={() => {
                  setActionError('')
                  setConfirmation('submit')
                }}
                leadingIcon={<Upload className="size-4" />}
                className="tablet:w-auto w-full min-w-0"
              >
                <span className="tablet:hidden">Submit</span>
                <span className="tablet:inline hidden">Submit for review</span>
              </Button>
            ) : null}
            {canDelete ? (
              <Button
                variant="danger"
                aria-label="Delete report"
                onClick={() => {
                  setActionError('')
                  setConfirmation('delete')
                }}
                leadingIcon={<Trash2 className="size-4" />}
                className="tablet:w-auto w-full min-w-0"
              >
                <span className="tablet:hidden">Delete</span>
                <span className="tablet:inline hidden">Delete report</span>
              </Button>
            ) : null}
          </div>
        </Card>
      ) : null}
      <Dialog
        open={confirmation !== null}
        onOpenChange={(open) => {
          if (!open && !submitMutation.isPending && !deleteMutation.isPending) setConfirmation(null)
        }}
        title={confirmation === 'submit' ? 'Submit site report?' : 'Delete site report?'}
        description={
          confirmation === 'submit'
            ? 'This report will be sent to the operational review workflow.'
            : 'This permanently removes the draft or returned report.'
        }
        fitContent
        compactOnMobile
        size="sm"
        dismissDisabled={submitMutation.isPending || deleteMutation.isPending}
        footer={
          <div className="flex justify-end gap-2">
            <Button
              variant="outline"
              disabled={submitMutation.isPending || deleteMutation.isPending}
              onClick={() => setConfirmation(null)}
            >
              Cancel
            </Button>
            <Button
              variant={confirmation === 'delete' ? 'danger' : 'primary'}
              disabled={submitMutation.isPending || deleteMutation.isPending}
              onClick={() =>
                confirmation === 'submit' ? submitMutation.mutate() : deleteMutation.mutate()
              }
            >
              {submitMutation.isPending || deleteMutation.isPending
                ? 'Working…'
                : confirmation === 'submit'
                  ? 'Submit report'
                  : 'Delete report'}
            </Button>
          </div>
        }
      >
        {actionError ? (
          <Alert tone="danger" title="Action not completed">
            {actionError}
          </Alert>
        ) : (
          <p className="text-body-sm text-text-secondary">{report.summary || labelForType(type)}</p>
        )}
      </Dialog>
    </PageLayout>
  )
}

function OverviewMetric({
  icon,
  label,
  value,
  valueIcon,
}: {
  icon: ReactNode
  label: string
  value: ReactNode
  valueIcon?: ReactNode
}) {
  return (
    <div className="rounded-control border-border-subtle bg-surface tablet:p-4 min-w-0 border p-3">
      <div className="flex items-center gap-2">
        <span className="text-primary bg-primary-subtle rounded-control flex size-8 shrink-0 items-center justify-center">
          {icon}
        </span>
        <dt className="text-caption text-text-secondary">{label}</dt>
      </div>
      <dd className="text-label text-text-primary mt-2 flex min-w-0 items-start gap-2 font-semibold break-words">
        {valueIcon ? (
          <span className="text-warning-foreground mt-0.5 shrink-0">{valueIcon}</span>
        ) : null}
        <span className="min-w-0">{value}</span>
      </dd>
    </div>
  )
}

function DetailSection({ title, children }: { title: string; children: ReactNode }) {
  return (
    <section className="border-border-subtle border-t pt-4 first:border-0 first:pt-0">
      <h3 className="text-h4 text-text-primary mb-3 font-semibold">{title}</h3>
      {children}
    </section>
  )
}

function EngineeringDetails({ report }: { report: SiteReport }) {
  return (
    <div className="space-y-4">
      <DetailSection title="Activities">
        <TextList
          values={report.activities.map(
            (item) => `${item.activity_type.replaceAll('_', ' ')}: ${item.description}`,
          )}
        />
      </DetailSection>
      <DetailSection title="Tomorrow’s activities">
        <p className="text-body-sm text-text-secondary whitespace-pre-wrap">
          {report.tomorrow_activities || 'None recorded.'}
        </p>
      </DetailSection>
      <DetailSection title="Comments and suggestions">
        <p className="text-body-sm text-text-secondary whitespace-pre-wrap">
          {report.comments_suggestions || 'None recorded.'}
        </p>
      </DetailSection>
      <DetailSection title="Expenses">
        <ExpenseList report={report} />
      </DetailSection>
      <DetailSection title="Materials used">
        <MaterialList report={report} />
      </DetailSection>
    </div>
  )
}

function SurveyDetails({ report }: { report: SiteReport }) {
  return (
    <div className="space-y-4">
      <dl className="phone:grid-cols-2 tablet:gap-3 desktop:grid-cols-3 grid grid-cols-2 gap-2.5 max-[359px]:grid-cols-1">
        <Info label="Measurement format">
          {report.work_data_type === 'bearing_distance'
            ? 'Bearing and distance'
            : 'Site points NEZ/XYZ'}
        </Info>
        <Info label="Measurement unit">{report.measurement_unit || 'Not recorded'}</Info>
        <Info label="Coordinate system">{report.coordinate_system || 'Not recorded'}</Info>
        <Info label="Datum and zone">
          {[report.datum, report.coordinate_zone].filter(Boolean).join(' · ') || 'Not recorded'}
        </Info>
        <Info label="GPS coordinates">
          {report.gps_latitude != null && report.gps_longitude != null
            ? `${report.gps_latitude}, ${report.gps_longitude}`
            : 'Not recorded'}
        </Info>
      </dl>
      <DetailSection title="Activities">
        <TextList values={report.activities.map((item) => item.description)} />
      </DetailSection>
      <DetailSection title="Measurement points">
        {report.work_data_type === 'bearing_distance' ? (
          <ul className="phone:grid-cols-2 desktop:grid-cols-3 grid grid-cols-1 gap-2.5">
            {(report.bearing_distance_points ?? []).map((point) => (
              <li
                key={point.id ?? point.point_number}
                className="rounded-control border-border-subtle bg-surface-muted/60 min-w-0 border p-3"
              >
                <div className="flex items-center justify-between gap-2">
                  <span className="text-caption text-text-secondary">Measurement point</span>
                  <span className="bg-primary-subtle text-caption text-primary rounded-full px-2.5 py-1 font-semibold">
                    {point.point_number}
                  </span>
                </div>
                <dl className="mt-3 grid grid-cols-2 gap-x-3 gap-y-2">
                  <PointValue
                    label="Bearing"
                    value={`${point.azimuth_degrees}° ${point.azimuth_minutes}′ ${point.azimuth_seconds}″`}
                  />
                  <PointValue
                    label="Distance"
                    value={`${point.distance} ${report.measurement_unit ?? ''}`.trim()}
                  />
                </dl>
              </li>
            ))}
            {!report.bearing_distance_points?.length ? (
              <li className="text-body-sm text-text-muted rounded-control bg-surface-muted/60 col-span-full p-3">
                No measurement points recorded.
              </li>
            ) : null}
          </ul>
        ) : (
          <ul className="phone:grid-cols-2 desktop:grid-cols-3 grid grid-cols-1 gap-2.5">
            {(report.xyz_points ?? []).map((point) => (
              <li
                key={point.id ?? point.point_number}
                className="rounded-control border-border-subtle bg-surface-muted/60 min-w-0 border p-3"
              >
                <div className="flex items-center justify-between gap-2">
                  <span className="text-caption text-text-secondary">Survey point</span>
                  <span className="bg-primary-subtle text-caption text-primary rounded-full px-2.5 py-1 font-semibold">
                    {point.point_number}
                  </span>
                </div>
                <dl className="mt-3 grid grid-cols-3 gap-2">
                  <PointValue label="Northing" value={point.northing} />
                  <PointValue label="Easting" value={point.easting} />
                  <PointValue label="Elevation" value={point.elevation} />
                </dl>
              </li>
            ))}
            {!report.xyz_points?.length ? (
              <li className="text-body-sm text-text-muted rounded-control bg-surface-muted/60 col-span-full p-3">
                No measurement points recorded.
              </li>
            ) : null}
          </ul>
        )}
      </DetailSection>
      <DetailSection title="Expenses">
        <ExpenseList report={report} />
      </DetailSection>
      <DetailSection title="Materials used">
        <MaterialList report={report} />
      </DetailSection>
    </div>
  )
}

function Info({ label, children }: { label: string; children: ReactNode }) {
  return (
    <div className="rounded-control border-border-subtle bg-surface-muted/60 tablet:p-4 min-w-0 border p-3">
      <dt className="text-caption text-text-secondary">{label}</dt>
      <dd className="text-body-sm text-text-primary mt-1 font-medium break-words">{children}</dd>
    </div>
  )
}

function PointValue({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div className="min-w-0">
      <dt className="text-caption text-text-muted">{label}</dt>
      <dd className="text-body-sm text-text-primary mt-0.5 font-medium break-words">{value}</dd>
    </div>
  )
}
function TextList({ values }: { values: string[] }) {
  return values.length ? (
    <ul className="text-body-sm text-text-secondary list-disc space-y-1 pl-5">
      {values.map((value, index) => (
        <li key={`${index}-${value}`}>{value}</li>
      ))}
    </ul>
  ) : (
    <p className="text-body-sm text-text-muted">No activities recorded.</p>
  )
}
function ExpenseList({ report }: { report: SiteReport }) {
  return report.expenses.length ? (
    <div className="space-y-2">
      {report.expenses.map((item, index) => (
        <div
          key={item.id ?? index}
          className="rounded-control border-border-subtle bg-surface-muted/60 tablet:p-4 flex min-w-0 flex-wrap justify-between gap-3 border p-3"
        >
          <div className="min-w-0 flex-1">
            <p className="text-body-sm text-text-primary font-medium">
              {item.name} · {item.expense_category}
            </p>
            <p className="text-caption text-text-secondary mt-1 break-words">{item.description}</p>
          </div>
          <span className="text-label text-text-primary shrink-0 font-semibold">
            ₦{Number(item.amount).toLocaleString()}
          </span>
        </div>
      ))}
    </div>
  ) : (
    <p className="text-body-sm text-text-muted">No expenses recorded.</p>
  )
}
function MaterialList({ report }: { report: SiteReport }) {
  return report.materials_used.length ? (
    <ul className="space-y-2">
      {report.materials_used.map((item, index) => (
        <li
          key={item.id ?? index}
          className="rounded-control border-border-subtle bg-surface-muted/60 flex min-w-0 items-center gap-3 border p-3"
        >
          <span className="text-primary bg-primary-subtle rounded-control flex size-9 shrink-0 items-center justify-center">
            <Package className="size-4" aria-hidden="true" />
          </span>
          <span className="text-body-sm text-text-primary min-w-0 font-medium break-words">
            {item.equipment_name}: {item.quantity_used} {item.unit}
          </span>
        </li>
      ))}
    </ul>
  ) : (
    <p className="text-body-sm text-text-muted">No materials recorded.</p>
  )
}

type EditValues = {
  date: string
  tomorrow: string
  comments: string
  attachments: string
  measurementUnit: string
  coordinateSystem: string
  datum: string
  coordinateZone: string
  latitude: string
  longitude: string
}

type ActivityDraft = { activity_type: string; description: string }
type ExpenseDraft = { expense_category: string; name: string; amount: string; description: string }
type MaterialDraft = {
  equipment_id: string
  equipment_name: string
  unit: string
  quantity_used: string
}
type BearingPointDraft = {
  azimuth_degrees: string
  azimuth_minutes: string
  azimuth_seconds: string
  distance: string
}
type XyzPointDraft = { northing: string; easting: string; elevation: string }

const activityTypes = [
  { value: 'concrete_work', label: 'Concrete work' },
  { value: 'carpentry_work', label: 'Carpentry work' },
  { value: 'water_supply', label: 'Water supply' },
]
const expenseCategories = [
  { value: 'labour', label: 'Labour' },
  { value: 'material_equipment', label: 'Material / equipment' },
]
const measurementUnits = [
  { value: 'metres', label: 'Metres' },
  { value: 'feet', label: 'Feet' },
]

function pointAsBearingDraft(point: BearingDistancePoint): BearingPointDraft {
  return {
    azimuth_degrees: String(point.azimuth_degrees),
    azimuth_minutes: String(point.azimuth_minutes),
    azimuth_seconds: String(point.azimuth_seconds),
    distance: String(point.distance),
  }
}

function pointAsXyzDraft(point: XyzPoint): XyzPointDraft {
  return {
    northing: String(point.northing),
    easting: String(point.easting),
    elevation: String(point.elevation),
  }
}

export function SiteReportEditPage({ operationsMode = false }: { operationsMode?: boolean } = {}) {
  const params = useParams({ strict: false }) as { reportType?: string; reportId?: string }
  const search = useSearch({ strict: false }) as WorkReportsSearch
  const type = operationsMode ? 'engineering' : reportType(params.reportType)
  const reportId = Number(params.reportId)
  const navigate = useNavigate()
  const client = useQueryClient()
  const toast = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const access = session && type ? reportAccess(session, type) : null
  const canListEquipment = Boolean(
    session && hasPermission(session.permissions, 'site_equipment', 'list'),
  )
  const listBackLink = operationsMode ? (
    <Link
      to="/works/engineering-site-reports/$reportId"
      params={{ reportId: String(reportId) }}
      className={pageBackLinkClassName}
    >
      <PageBackLinkContent>Report details</PageBackLinkContent>
    </Link>
  ) : (
    <SiteReportBackLink search={search} />
  )
  const query = useQuery({
    ...siteReportDetailOptions(type ?? 'engineering', userId, employeeId, reportId),
    enabled: Boolean(session && access?.canUpdate && type && reportId > 0),
  })
  const report = query.data
  const equipmentQuery = useQuery({
    ...siteEquipmentOptions(userId, report?.worksite_id ?? 0),
    enabled: Boolean(report && canListEquipment),
  })
  const [formError, setFormError] = useState('')
  const [activities, setActivities] = useState<ActivityDraft[]>([])
  const [expenses, setExpenses] = useState<ExpenseDraft[]>([])
  const [materials, setMaterials] = useState<MaterialDraft[]>([])
  const [bearingPoints, setBearingPoints] = useState<BearingPointDraft[]>([])
  const [xyzPoints, setXyzPoints] = useState<XyzPointDraft[]>([])
  const valuesFor = (current?: SiteReport): EditValues => ({
    date: current?.date ?? '',
    tomorrow: current?.tomorrow_activities ?? '',
    comments: current?.comments_suggestions ?? '',
    attachments: current?.attachments.join('\n') ?? '',
    measurementUnit: current?.measurement_unit ?? 'metres',
    coordinateSystem: current?.coordinate_system ?? '',
    datum: current?.datum ?? '',
    coordinateZone: current?.coordinate_zone ?? '',
    latitude: current?.gps_latitude == null ? '' : String(current.gps_latitude),
    longitude: current?.gps_longitude == null ? '' : String(current.gps_longitude),
  })
  const activitiesFor = (current: SiteReport): ActivityDraft[] =>
    current.activities.map((item) => ({
      activity_type: item.activity_type || 'concrete_work',
      description: item.description,
    }))
  const expensesFor = (current: SiteReport): ExpenseDraft[] =>
    current.expenses.map((item) => ({
      expense_category: item.expense_category,
      name: item.name,
      amount: String(item.amount),
      description: item.description,
    }))
  const materialsFor = (current: SiteReport): MaterialDraft[] =>
    current.materials_used.map((item) => ({
      equipment_id: item.equipment_id == null ? '' : String(item.equipment_id),
      equipment_name: item.equipment_name,
      unit: item.unit,
      quantity_used: String(item.quantity_used),
    }))
  const bearingPointsFor = (current: SiteReport): BearingPointDraft[] =>
    (current.bearing_distance_points ?? []).map(pointAsBearingDraft)
  const xyzPointsFor = (current: SiteReport): XyzPointDraft[] =>
    (current.xyz_points ?? []).map(pointAsXyzDraft)
  const hasLegacyMaterials = Boolean(
    report?.materials_used.some((item) => item.equipment_id == null),
  )
  const hydratedReportId = useRef<number | null>(null)
  const form = useForm({
    defaultValues: valuesFor(),
    onSubmit: async ({ value }) => {
      if (!report || !type) return
      setFormError('')
      if (!activities.length || activities.some((item) => !item.description.trim())) {
        setFormError('Add at least one activity before saving.')
        document.getElementById('site-edit-activities')?.focus()
        return
      }
      if (!isValidDateInput(value.date)) {
        setFormError('Choose a valid report date.')
        document.getElementById('site-edit-date')?.focus()
        return
      }
      const latitude = value.latitude === '' ? null : Number(value.latitude)
      const longitude = value.longitude === '' ? null : Number(value.longitude)
      if (
        (latitude !== null && (!Number.isFinite(latitude) || latitude < -90 || latitude > 90)) ||
        (longitude !== null && (!Number.isFinite(longitude) || longitude < -180 || longitude > 180))
      ) {
        setFormError('GPS latitude must be between -90 and 90, and longitude between -180 and 180.')
        document.getElementById('site-edit-latitude')?.focus()
        return
      }
      if (type === 'survey' && report.work_data_type === 'bearing_distance') {
        const invalidPoint = bearingPoints.some((point) => {
          const degrees = Number(point.azimuth_degrees)
          const minutes = Number(point.azimuth_minutes)
          const seconds = Number(point.azimuth_seconds)
          const distance = Number(point.distance)
          return (
            point.azimuth_degrees === '' ||
            point.azimuth_minutes === '' ||
            point.azimuth_seconds === '' ||
            point.distance === '' ||
            !Number.isInteger(degrees) ||
            degrees < 0 ||
            degrees > 359 ||
            !Number.isInteger(minutes) ||
            minutes < 0 ||
            minutes > 59 ||
            !Number.isFinite(seconds) ||
            seconds < 0 ||
            seconds >= 60 ||
            !Number.isFinite(distance) ||
            distance <= 0
          )
        })
        if (invalidPoint) {
          setFormError(
            'Complete each bearing point with a valid angle and distance greater than zero.',
          )
          document.getElementById('site-bearing-degrees-0')?.focus()
          return
        }
      }
      if (type === 'survey' && report.work_data_type === 'site_points_xyz') {
        const invalidPoint = xyzPoints.some((point) =>
          [point.northing, point.easting, point.elevation].some(
            (coordinate) => coordinate.trim() === '' || !Number.isFinite(Number(coordinate)),
          ),
        )
        if (invalidPoint) {
          setFormError(
            'Complete each survey point with valid northing, easting, and elevation values.',
          )
          document.getElementById('site-xyz-northing-0')?.focus()
          return
        }
      }
      const invalidExpense = expenses.find(
        (item) =>
          !item.expense_category ||
          !item.name.trim() ||
          !item.description.trim() ||
          !Number.isFinite(Number(item.amount)) ||
          Number(item.amount) <= 0,
      )
      if (invalidExpense) {
        setFormError('Complete each expense and enter an amount greater than zero.')
        document.getElementById('site-expense-name-0')?.focus()
        return
      }
      if (
        !hasLegacyMaterials &&
        materials.some(
          (item) =>
            !Number.isSafeInteger(Number(item.equipment_id)) ||
            Number(item.equipment_id) < 1 ||
            !Number.isFinite(Number(item.quantity_used)) ||
            Number(item.quantity_used) <= 0,
        )
      ) {
        setFormError('Choose an inventory item and enter a quantity greater than zero.')
        document.getElementById('site-material-equipment-0')?.focus()
        return
      }
      const attachments = value.attachments
        .split('\n')
        .map((line) => line.trim())
        .filter(Boolean)
      if (attachments.some((item) => !safeAttachment(item))) {
        setFormError('Attachments must be valid HTTP or HTTPS links.')
        document.getElementById('site-edit-attachments')?.focus()
        return
      }
      const expensePayload = expenses.map((item) => ({
        expense_category: item.expense_category,
        name: item.name.trim(),
        amount: item.amount,
        description: item.description.trim(),
      }))
      const materialPayload = materials.map((item) => ({
        equipment_id: Number(item.equipment_id),
        quantity_used: item.quantity_used,
      }))
      const input: EngineeringSiteReportUpdate | SurveySiteReportUpdate =
        type === 'engineering'
          ? {
              date: value.date,
              tomorrow_activities: value.tomorrow,
              comments_suggestions: value.comments,
              activities: activities.map((item) => ({
                activity_type: item.activity_type,
                description: item.description.trim(),
              })),
              expenses: expensePayload,
              ...(hasLegacyMaterials ? {} : { materials_used: materialPayload }),
              attachments,
            }
          : {
              date: value.date,
              measurement_unit: value.measurementUnit,
              coordinate_system: value.coordinateSystem,
              datum: value.datum,
              coordinate_zone: value.coordinateZone,
              gps_latitude: latitude === null ? null : String(latitude),
              gps_longitude: longitude === null ? null : String(longitude),
              activities: activities.map((item) => ({ description: item.description.trim() })),
              expenses: expensePayload,
              ...(hasLegacyMaterials ? {} : { materials_used: materialPayload }),
              attachments,
              ...(report.work_data_type === 'bearing_distance'
                ? {
                    bearing_distance_points: bearingPoints.map((point, index) => ({
                      point_number: index + 1,
                      azimuth_degrees: Number(point.azimuth_degrees),
                      azimuth_minutes: Number(point.azimuth_minutes),
                      azimuth_seconds: point.azimuth_seconds,
                      distance: point.distance,
                    })),
                  }
                : {
                    xyz_points: xyzPoints.map((point, index) => ({
                      point_number: index + 1,
                      northing: point.northing,
                      easting: point.easting,
                      elevation: point.elevation,
                    })),
                  }),
            }
      try {
        const updated = await siteReportsApi.update(type, report.id, input)
        client.setQueryData(
          siteReportQueryKeys.detail(type, userId, employeeId, updated.id),
          updated,
        )
        await client.invalidateQueries({
          queryKey: siteReportQueryKeys.lists(type, userId, employeeId),
        })
        if (operationsMode) {
          await client.invalidateQueries({
            queryKey: ['operations-registers', userId, employeeId, 'reports', 'list'],
          })
        }
        toast.showToast({
          title: 'Report saved',
          description: 'Your site report changes were saved.',
          tone: 'success',
        })
        if (operationsMode) {
          await navigate({ href: `/works/engineering-site-reports/${report.id}` })
        } else {
          await navigate({
            to: '/dashboard/my-reports/site/$reportType/$reportId',
            params: { reportType: type, reportId: String(report.id) },
            search: { ...search, type: 'site' },
          })
        }
      } catch (error) {
        setFormError(`${presentError(error, 'form-submit').message} Your entries are still here.`)
      }
    },
  })

  useEffect(() => {
    if (!report || hydratedReportId.current === report.id) return
    const timeout = window.setTimeout(() => {
      const values = valuesFor(report)
      form.reset(values)
      form.setFieldValue('date', values.date)
      form.setFieldValue('tomorrow', values.tomorrow)
      form.setFieldValue('comments', values.comments)
      form.setFieldValue('attachments', values.attachments)
      form.setFieldValue('measurementUnit', values.measurementUnit)
      form.setFieldValue('coordinateSystem', values.coordinateSystem)
      form.setFieldValue('datum', values.datum)
      form.setFieldValue('coordinateZone', values.coordinateZone)
      form.setFieldValue('latitude', values.latitude)
      form.setFieldValue('longitude', values.longitude)
      setActivities(activitiesFor(report))
      setExpenses(expensesFor(report))
      setMaterials(materialsFor(report))
      setBearingPoints(bearingPointsFor(report))
      setXyzPoints(xyzPointsFor(report))
      // Mark only after hydration completes. In React StrictMode, the first
      // effect setup is cleaned up immediately; marking before the timeout
      // caused that cleanup to cancel hydration and the second setup to skip.
      hydratedReportId.current = report.id
    }, 0)
    return () => window.clearTimeout(timeout)
  }, [form, report])

  if (!type || !reportId || (session && !access?.canUpdate))
    return (
      <PageLayout title="Edit site report" backLink={listBackLink}>
        <ErrorState
          title="You can’t edit this report"
          description="Your account does not have permission to update this site report."
        />
      </PageLayout>
    )
  if (query.isPending)
    return (
      <PageLayout title="Edit site report" backLink={listBackLink}>
        <Skeleton variant="card" className="h-80" />
      </PageLayout>
    )
  if (!report)
    return (
      <PageLayout title="Edit site report" backLink={listBackLink}>
        <ErrorState
          title="Report could not load"
          description="The report may have been removed or you may no longer have access."
          error={query.error}
          action={
            <Button variant="outline" onClick={() => void query.refetch()}>
              Try again
            </Button>
          }
        />
      </PageLayout>
    )
  if (!['draft', 'rejected'].includes(report.status))
    return (
      <PageLayout title="Edit site report" backLink={listBackLink}>
        <Card>
          <EmptyState
            title="This report can’t be edited"
            description="Only draft or returned site reports can be changed."
          />
        </Card>
      </PageLayout>
    )

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setFormError('')
    void form.handleSubmit()
  }
  return (
    <PageLayout
      title={`Edit ${labelForType(type).toLocaleLowerCase()}`}
      subtitle={`${report.worksite_name} · ${formatDate(report.date)}`}
      leading={<Pencil className="size-[18px]" aria-hidden="true" />}
      backLink={
        operationsMode ? (
          listBackLink
        ) : (
          <Link
            to="/dashboard/my-reports/site/$reportType/$reportId"
            params={{ reportType: type, reportId: String(report.id) }}
            search={{ ...search, type: 'site' }}
            className={pageBackLinkClassName}
          >
            <PageBackLinkContent>Report details</PageBackLinkContent>
          </Link>
        )
      }
      contentClassName="space-y-5"
    >
      {report.status === 'rejected' ? (
        <Alert tone="warning" title="Returned for revision">
          Saving your changes returns this report to Draft. Review feedback is shown in report
          details.
        </Alert>
      ) : null}
      {formError ? (
        <Alert tone="danger" role="alert" title="Changes not saved">
          {formError}
        </Alert>
      ) : null}
      <form onSubmit={handleSubmit} className="space-y-5">
        <Card className="space-y-4">
          <div>
            <h2 className="text-h3 text-text-primary font-semibold">Report content</h2>
            <p className="text-body-sm text-text-secondary mt-1">
              Worksite and project context stay linked to the original report.
            </p>
          </div>
          <form.Field name="date">
            {(field) => (
              <FormControl id="site-edit-date" label="Report date" required>
                <DatePickerField
                  required
                  value={field.state.value}
                  onValueChange={(value) => field.handleChange(value)}
                />
              </FormControl>
            )}
          </form.Field>
          <section className="border-border-subtle space-y-3 border-t pt-4">
            <div className="flex flex-wrap items-start justify-between gap-2">
              <div>
                <h3 className="text-label text-text-primary font-semibold">Activities</h3>
                <p className="text-caption text-text-secondary mt-1">
                  Record the work completed for this report.
                </p>
              </div>
              <Button
                variant="outline"
                size="sm"
                onClick={() =>
                  setActivities((current) => [
                    ...current,
                    {
                      activity_type: type === 'engineering' ? 'concrete_work' : 'general_survey',
                      description: '',
                    },
                  ])
                }
              >
                Add activity
              </Button>
            </div>
            {activities.map((activity, index) => (
              <div
                key={index}
                className="bg-surface-muted rounded-control grid gap-3 p-3 sm:grid-cols-2"
              >
                {type === 'engineering' ? (
                  <FormControl
                    id={`site-edit-activity-type-${index}`}
                    label="Activity type"
                    required
                  >
                    <DropdownSelect
                      aria-label={`Activity ${index + 1} type`}
                      value={activity.activity_type}
                      options={activityTypes}
                      onChange={(activity_type) =>
                        setActivities((current) =>
                          current.map((item, row) =>
                            row === index ? { ...item, activity_type } : item,
                          ),
                        )
                      }
                    />
                  </FormControl>
                ) : (
                  <div className="flex items-end">
                    <p className="text-caption text-text-secondary pb-3">Survey activity</p>
                  </div>
                )}
                <FormControl
                  id={index === 0 ? 'site-edit-activities' : `site-edit-activity-${index}`}
                  label={`Activity ${index + 1}`}
                  required
                >
                  <TextArea
                    rows={2}
                    value={activity.description}
                    onChange={(event) =>
                      setActivities((current) =>
                        current.map((item, row) =>
                          row === index ? { ...item, description: event.target.value } : item,
                        ),
                      )
                    }
                  />
                </FormControl>
                <div className="flex justify-end sm:col-span-2">
                  <Button
                    variant="ghost"
                    size="sm"
                    disabled={activities.length === 1}
                    onClick={() =>
                      setActivities((current) => current.filter((_, row) => row !== index))
                    }
                    aria-label={`Remove activity ${index + 1}`}
                  >
                    Remove
                  </Button>
                </div>
              </div>
            ))}
          </section>
          <section className="border-border-subtle space-y-3 border-t pt-4">
            <div className="flex flex-wrap items-start justify-between gap-2">
              <div>
                <h3 className="text-label text-text-primary font-semibold">Expenses</h3>
                <p className="text-caption text-text-secondary mt-1">
                  Optional expense records for this report.
                </p>
              </div>
              <Button
                variant="outline"
                size="sm"
                onClick={() =>
                  setExpenses((current) => [
                    ...current,
                    { expense_category: 'labour', name: '', amount: '', description: '' },
                  ])
                }
              >
                Add expense
              </Button>
            </div>
            {expenses.map((expense, index) => (
              <div
                key={index}
                className="bg-surface-muted rounded-control grid gap-3 p-3 sm:grid-cols-2"
              >
                <FormControl
                  id={`site-edit-expense-category-${index}`}
                  label="Expense category"
                  required
                >
                  <DropdownSelect
                    aria-label={`Expense ${index + 1} category`}
                    value={expense.expense_category}
                    options={expenseCategories}
                    onChange={(expense_category) =>
                      setExpenses((current) =>
                        current.map((item, row) =>
                          row === index ? { ...item, expense_category } : item,
                        ),
                      )
                    }
                  />
                </FormControl>
                <FormControl id={`site-expense-name-${index}`} label="Expense name" required>
                  <TextInput
                    value={expense.name}
                    onChange={(event) =>
                      setExpenses((current) =>
                        current.map((item, row) =>
                          row === index ? { ...item, name: event.target.value } : item,
                        ),
                      )
                    }
                  />
                </FormControl>
                <FormControl id={`site-edit-expense-amount-${index}`} label="Amount (NGN)" required>
                  <TextInput
                    inputMode="decimal"
                    value={expense.amount}
                    onChange={(event) =>
                      setExpenses((current) =>
                        current.map((item, row) =>
                          row === index ? { ...item, amount: event.target.value } : item,
                        ),
                      )
                    }
                  />
                </FormControl>
                <FormControl
                  id={`site-edit-expense-description-${index}`}
                  label="Description"
                  required
                >
                  <TextInput
                    value={expense.description}
                    onChange={(event) =>
                      setExpenses((current) =>
                        current.map((item, row) =>
                          row === index ? { ...item, description: event.target.value } : item,
                        ),
                      )
                    }
                  />
                </FormControl>
                <div className="flex justify-end sm:col-span-2">
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() =>
                      setExpenses((current) => current.filter((_, row) => row !== index))
                    }
                    aria-label={`Remove expense ${index + 1}`}
                  >
                    Remove
                  </Button>
                </div>
              </div>
            ))}
            {!expenses.length ? (
              <p className="text-caption text-text-muted">No expenses added.</p>
            ) : null}
          </section>
          <section className="border-border-subtle space-y-3 border-t pt-4">
            <div className="flex flex-wrap items-start justify-between gap-2">
              <div>
                <h3 className="text-label text-text-primary font-semibold">Materials used</h3>
                <p className="text-caption text-text-secondary mt-1">
                  Material use is checked against the original worksite inventory when saved.
                </p>
              </div>
              {canListEquipment && !hasLegacyMaterials ? (
                <Button
                  variant="outline"
                  size="sm"
                  disabled={!equipmentQuery.data?.length}
                  onClick={() =>
                    setMaterials((current) => [
                      ...current,
                      { equipment_id: '', equipment_name: '', unit: '', quantity_used: '' },
                    ])
                  }
                >
                  Add material
                </Button>
              ) : null}
            </div>
            {hasLegacyMaterials ? (
              <Alert tone="info" title="Inventory-linked materials are read-only">
                This report contains a legacy material without a linked inventory item. It will be
                preserved as-is while you edit the other report fields.
              </Alert>
            ) : null}
            {canListEquipment && equipmentQuery.isError ? (
              <Alert tone="warning" title="Worksite inventory could not load">
                Existing material quantities can still be edited. Retry from this page before adding
                a new inventory item.
                <Button variant="outline" size="sm" onClick={() => void equipmentQuery.refetch()}>
                  Retry inventory
                </Button>
              </Alert>
            ) : null}
            {materials.map((material, index) => {
              const options = (equipmentQuery.data ?? []).map((item) => ({
                value: String(item.id),
                label: `${item.name} · ${item.unit}`,
                description: `Available: ${item.quantity} ${item.unit}`,
              }))
              if (
                material.equipment_id &&
                !options.some((option) => option.value === material.equipment_id)
              ) {
                options.unshift({
                  value: material.equipment_id,
                  label: `${material.equipment_name} · ${material.unit}`,
                  description: 'Previously selected for this report',
                })
              }
              return (
                <div
                  key={index}
                  className="bg-surface-muted rounded-control grid gap-3 p-3 sm:grid-cols-[minmax(0,1fr)_10rem_auto] sm:items-end"
                >
                  <FormControl
                    id={`site-material-equipment-${index}`}
                    label="Worksite inventory item"
                    required
                  >
                    {canListEquipment ? (
                      <DropdownSelect
                        aria-label={`Material ${index + 1} inventory item`}
                        value={material.equipment_id}
                        options={options}
                        searchable
                        disabled={hasLegacyMaterials}
                        onChange={(equipment_id) => {
                          const selected = (equipmentQuery.data ?? []).find(
                            (item) => String(item.id) === equipment_id,
                          )
                          setMaterials((current) =>
                            current.map((item, row) =>
                              row === index
                                ? {
                                    ...item,
                                    equipment_id,
                                    equipment_name: selected?.name ?? item.equipment_name,
                                    unit: selected?.unit ?? item.unit,
                                  }
                                : item,
                            ),
                          )
                        }}
                      />
                    ) : (
                      <TextInput value={material.equipment_name} readOnly />
                    )}
                  </FormControl>
                  <FormControl
                    id={`site-material-quantity-${index}`}
                    label={`Quantity${material.unit ? ` (${material.unit})` : ''}`}
                    required
                  >
                    <TextInput
                      inputMode="decimal"
                      value={material.quantity_used}
                      onChange={(event) =>
                        setMaterials((current) =>
                          current.map((item, row) =>
                            row === index ? { ...item, quantity_used: event.target.value } : item,
                          ),
                        )
                      }
                    />
                  </FormControl>
                  {canListEquipment && !hasLegacyMaterials ? (
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() =>
                        setMaterials((current) => current.filter((_, row) => row !== index))
                      }
                      aria-label={`Remove material ${index + 1}`}
                    >
                      Remove
                    </Button>
                  ) : null}
                </div>
              )
            })}
            {!materials.length ? (
              <p className="text-caption text-text-muted">No materials added.</p>
            ) : null}
          </section>
          {type === 'engineering' ? (
            <>
              <form.Field name="tomorrow">
                {(field) => (
                  <FormControl id="site-edit-tomorrow" label="Tomorrow’s activities">
                    <TextArea
                      rows={3}
                      value={field.state.value}
                      onChange={(event) => field.handleChange(event.target.value)}
                    />
                  </FormControl>
                )}
              </form.Field>
              <form.Field name="comments">
                {(field) => (
                  <FormControl id="site-edit-comments" label="Comments and suggestions">
                    <TextArea
                      rows={3}
                      value={field.state.value}
                      onChange={(event) => field.handleChange(event.target.value)}
                    />
                  </FormControl>
                )}
              </form.Field>
            </>
          ) : (
            <div className="grid gap-4 sm:grid-cols-2">
              <form.Field name="measurementUnit">
                {(field) => (
                  <FormControl id="site-edit-unit" label="Measurement unit">
                    <DropdownSelect
                      value={field.state.value}
                      options={
                        measurementUnits.some((option) => option.value === field.state.value)
                          ? measurementUnits
                          : [
                              ...measurementUnits,
                              { value: field.state.value, label: field.state.value },
                            ]
                      }
                      onChange={field.handleChange}
                    />
                  </FormControl>
                )}
              </form.Field>
              <form.Field name="coordinateSystem">
                {(field) => (
                  <FormControl id="site-edit-coordinate-system" label="Coordinate system">
                    <TextInput
                      value={field.state.value}
                      onChange={(event) => field.handleChange(event.target.value)}
                    />
                  </FormControl>
                )}
              </form.Field>
              <form.Field name="datum">
                {(field) => (
                  <FormControl id="site-edit-datum" label="Datum">
                    <TextInput
                      value={field.state.value}
                      onChange={(event) => field.handleChange(event.target.value)}
                    />
                  </FormControl>
                )}
              </form.Field>
              <form.Field name="coordinateZone">
                {(field) => (
                  <FormControl id="site-edit-coordinate-zone" label="Coordinate zone">
                    <TextInput
                      value={field.state.value}
                      onChange={(event) => field.handleChange(event.target.value)}
                    />
                  </FormControl>
                )}
              </form.Field>
              <form.Field name="latitude">
                {(field) => (
                  <FormControl id="site-edit-latitude" label="GPS latitude">
                    <TextInput
                      inputMode="decimal"
                      value={field.state.value}
                      onChange={(event) => field.handleChange(event.target.value)}
                    />
                  </FormControl>
                )}
              </form.Field>
              <form.Field name="longitude">
                {(field) => (
                  <FormControl id="site-edit-longitude" label="GPS longitude">
                    <TextInput
                      inputMode="decimal"
                      value={field.state.value}
                      onChange={(event) => field.handleChange(event.target.value)}
                    />
                  </FormControl>
                )}
              </form.Field>
            </div>
          )}
          {type === 'survey' ? (
            <section className="border-border-subtle space-y-3 border-t pt-4">
              <div className="flex flex-wrap items-start justify-between gap-2">
                <div>
                  <h3 className="text-label text-text-primary font-semibold">Measurement points</h3>
                  <p className="text-caption text-text-secondary mt-1">
                    Point format stays{' '}
                    {report.work_data_type === 'bearing_distance'
                      ? 'bearing and distance'
                      : 'site points (XYZ)'}{' '}
                    for this report.
                  </p>
                </div>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() =>
                    report.work_data_type === 'bearing_distance'
                      ? setBearingPoints((current) => [
                          ...current,
                          {
                            azimuth_degrees: '',
                            azimuth_minutes: '',
                            azimuth_seconds: '',
                            distance: '',
                          },
                        ])
                      : setXyzPoints((current) => [
                          ...current,
                          { northing: '', easting: '', elevation: '' },
                        ])
                  }
                >
                  Add point
                </Button>
              </div>
              {report.work_data_type === 'bearing_distance'
                ? bearingPoints.map((point, index) => (
                    <div key={index} className="bg-surface-muted rounded-control space-y-3 p-3">
                      <p className="text-caption text-text-secondary font-semibold">
                        Point {index + 1}
                      </p>
                      <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
                        {(
                          [
                            ['azimuth_degrees', 'Degrees', 'site-bearing-degrees-'],
                            ['azimuth_minutes', 'Minutes', 'site-bearing-minutes-'],
                            ['azimuth_seconds', 'Seconds', 'site-bearing-seconds-'],
                            [
                              'distance',
                              `Distance (${form.state.values.measurementUnit})`,
                              'site-bearing-distance-',
                            ],
                          ] as const
                        ).map(([key, label, idPrefix]) => (
                          <FormControl key={key} id={`${idPrefix}${index}`} label={label} required>
                            <TextInput
                              inputMode="decimal"
                              value={point[key]}
                              onChange={(event) =>
                                setBearingPoints((current) =>
                                  current.map((item, row) =>
                                    row === index ? { ...item, [key]: event.target.value } : item,
                                  ),
                                )
                              }
                            />
                          </FormControl>
                        ))}
                      </div>
                      <div className="flex justify-end">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() =>
                            setBearingPoints((current) => current.filter((_, row) => row !== index))
                          }
                          aria-label={`Remove point ${index + 1}`}
                        >
                          Remove point
                        </Button>
                      </div>
                    </div>
                  ))
                : xyzPoints.map((point, index) => (
                    <div key={index} className="bg-surface-muted rounded-control space-y-3 p-3">
                      <p className="text-caption text-text-secondary font-semibold">
                        Point {index + 1}
                      </p>
                      <div className="grid gap-3 sm:grid-cols-3">
                        {(
                          [
                            ['northing', 'Northing', 'site-xyz-northing-'],
                            ['easting', 'Easting', 'site-xyz-easting-'],
                            ['elevation', 'Elevation', 'site-xyz-elevation-'],
                          ] as const
                        ).map(([key, label, idPrefix]) => (
                          <FormControl key={key} id={`${idPrefix}${index}`} label={label} required>
                            <TextInput
                              inputMode="decimal"
                              value={point[key]}
                              onChange={(event) =>
                                setXyzPoints((current) =>
                                  current.map((item, row) =>
                                    row === index ? { ...item, [key]: event.target.value } : item,
                                  ),
                                )
                              }
                            />
                          </FormControl>
                        ))}
                      </div>
                      <div className="flex justify-end">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() =>
                            setXyzPoints((current) => current.filter((_, row) => row !== index))
                          }
                          aria-label={`Remove point ${index + 1}`}
                        >
                          Remove point
                        </Button>
                      </div>
                    </div>
                  ))}
              {report.work_data_type === 'bearing_distance' && bearingPoints.length === 0 ? (
                <p className="text-caption text-text-muted">No measurement points added.</p>
              ) : null}
              {report.work_data_type === 'site_points_xyz' && xyzPoints.length === 0 ? (
                <p className="text-caption text-text-muted">No measurement points added.</p>
              ) : null}
            </section>
          ) : null}
          <form.Field name="attachments">
            {(field) => (
              <FormControl
                id="site-edit-attachments"
                label="Attachment links"
                description="Keep one HTTPS or HTTP link per line; new file uploads require the operational report workflow."
              >
                <TextArea
                  rows={3}
                  value={field.state.value}
                  onChange={(event) => field.handleChange(event.target.value)}
                />
              </FormControl>
            )}
          </form.Field>
        </Card>
        <div className="flex flex-wrap justify-end gap-2">
          <Link
            to={
              operationsMode
                ? '/works/engineering-site-reports/$reportId'
                : '/dashboard/my-reports/site/$reportType/$reportId'
            }
            params={
              operationsMode
                ? { reportId: String(report.id) }
                : { reportType: type, reportId: String(report.id) }
            }
            search={operationsMode ? undefined : { ...search, type: 'site' }}
            className="rounded-control border-border-subtle bg-surface text-label inline-flex min-h-11 items-center justify-center border px-4 font-semibold"
          >
            Cancel
          </Link>
          <Button type="submit" disabled={form.state.isSubmitting}>
            Save changes
          </Button>
        </div>
      </form>
    </PageLayout>
  )
}

export function OperationsEngineeringSiteReportEditPage() {
  return <SiteReportEditPage operationsMode />
}
