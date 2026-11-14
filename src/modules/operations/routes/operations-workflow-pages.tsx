import { useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useSearch } from '@tanstack/react-router'
import {
  ArrowDownToLine,
  ArrowRight,
  Check,
  FileText,
  MapPin,
  Plus,
  Search,
  ShieldCheck,
  Users,
  X,
} from 'lucide-react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { useToast } from '@/shared/feedback/use-toast'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip } from '@/shared/ui/status-chip'
import { TimePickerField } from '@/shared/ui/time-picker-field'
import { projectQueries } from '@/modules/operations/projects.queries'
import {
  operationsWorkflowsApi,
  type ContractRecord,
  type MeetingRecord,
} from '../operations-workflows.api'
import type {
  ContractWorkflowSearch,
  MeetingWorkflowSearch,
  SurveyWorkflowSearch,
} from '../operations-workflows.search'

const PAGE_SIZE = 10
const queryDefaults = {
  staleTime: 45_000,
  refetchOnWindowFocus: true,
  refetchOnReconnect: true,
  retry: 1,
} as const

function money(value: string | number | null | undefined) {
  if (value == null || value === '') return 'Not specified'
  const amount = Number(value)
  return Number.isFinite(amount)
    ? new Intl.NumberFormat('en-NG', {
        style: 'currency',
        currency: 'NGN',
        maximumFractionDigits: 0,
      }).format(amount)
    : String(value)
}

function prettyDate(value: string | null | undefined) {
  if (!value) return 'Not scheduled'
  const date = new Date(`${value.slice(0, 10)}T00:00:00`)
  return Number.isNaN(date.getTime())
    ? value
    : new Intl.DateTimeFormat('en-NG', { day: 'numeric', month: 'short', year: 'numeric' }).format(
        date,
      )
}

function tone(status: string): 'success' | 'warning' | 'danger' | 'info' | 'neutral' {
  if (['approved', 'completed', 'active', 'signed'].includes(status)) return 'success'
  if (['submitted', 'scheduled', 'in_progress', 'ongoing'].includes(status)) return 'info'
  if (['rejected', 'cancelled', 'terminated'].includes(status)) return 'danger'
  if (['postponed', 'pending', 'renewed'].includes(status)) return 'warning'
  return 'neutral'
}

function Status({ value }: { value: string }) {
  return <StatusChip label={value.replaceAll('_', ' ')} tone={tone(value)} />
}

function PageControls({
  page,
  count,
  onChange,
}: {
  page: number
  count: number
  onChange: (page: number) => void
}) {
  const pages = Math.max(1, Math.ceil(count / PAGE_SIZE))
  return (
    <div className="border-border-subtle flex flex-wrap items-center justify-between gap-3 border-t px-4 py-3">
      <p className="text-caption text-text-secondary">
        {count
          ? `${(page - 1) * PAGE_SIZE + 1}-${Math.min(page * PAGE_SIZE, count)} of ${count}`
          : 'No records'}
      </p>
      <div className="flex gap-2">
        <Button variant="outline" size="sm" disabled={page <= 1} onClick={() => onChange(page - 1)}>
          Previous
        </Button>
        <Button
          variant="outline"
          size="sm"
          disabled={page >= pages}
          onClick={() => onChange(page + 1)}
        >
          Next
        </Button>
      </div>
    </div>
  )
}

function SearchBox({
  value,
  onChange,
  label,
}: {
  value: string
  onChange: (value: string) => void
  label: string
}) {
  return (
    <FormControl id="workflow-search" label={label}>
      <div className="relative">
        <Search
          aria-hidden="true"
          className="text-text-muted absolute top-1/2 left-3 size-4 -translate-y-1/2"
        />
        <TextInput
          value={value}
          onChange={(event) => onChange(event.target.value)}
          className="pl-9"
          placeholder="Search"
        />
      </div>
    </FormControl>
  )
}

function useProjectOptions(userId: number, employeeId: string) {
  return useQuery({
    ...projectQueries.list(userId, employeeId, {
      limit: 100,
      offset: 0,
      search: '',
      status: '',
      priority: '',
      archived: false,
    }),
    enabled: userId > 0,
  })
}

export function SurveySiteReportsPage() {
  const search = useSearch({ strict: false }) as SurveyWorkflowSearch
  const navigate = useNavigate()
  const client = useQueryClient()
  const toast = useToast()
  const session = useQuery(authSessionQueryOptions()).data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const canReview = Boolean(
    session && hasPermission(session.permissions, 'survey_site_reports', 'approve'),
  )
  const canReject = Boolean(
    session && hasPermission(session.permissions, 'survey_site_reports', 'reject'),
  )
  const canCreate = Boolean(
    session && hasPermission(session.permissions, 'survey_site_reports', 'create'),
  )
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
  const reportsQuery = useQuery({
    queryKey: ['operations', 'survey-reports', userId, employeeId, params],
    queryFn: ({ signal }) => operationsWorkflowsApi.surveyReports(params, signal),
    enabled: Boolean(session),
    ...queryDefaults,
    placeholderData: (previous) => previous,
  })
  const projectOptions = useProjectOptions(userId, employeeId)
  const [selectedId, setSelectedId] = useState<number | null>(null)
  const selected = reportsQuery.data?.items.find((report) => report.id === selectedId) ?? null
  const [reviewOpen, setReviewOpen] = useState(false)
  const [reviewFeedback, setReviewFeedback] = useState('')
  const [rating, setRating] = useState('')
  const [reviewAction, setReviewAction] = useState<'approve' | 'reject'>('approve')
  const reviewMutation = useMutation({
    mutationFn: () =>
      reviewAction === 'approve'
        ? operationsWorkflowsApi.approveSurveyReport(selectedId!, {
            rating: rating ? Number(rating) : null,
            feedback: reviewFeedback,
          })
        : operationsWorkflowsApi.rejectSurveyReport(selectedId!, reviewFeedback),
    onSuccess: async () => {
      await client.invalidateQueries({ queryKey: ['operations', 'survey-reports'] })
      setReviewOpen(false)
      setReviewFeedback('')
      toast.showToast({
        title: reviewAction === 'approve' ? 'Survey report approved' : 'Report returned',
        tone: 'success',
      })
    },
    onError: (error) =>
      toast.showToast({
        title: 'Review could not be saved',
        description: error instanceof Error ? error.message : undefined,
        tone: 'danger',
      }),
  })
  function change(patch: Partial<SurveyWorkflowSearch>) {
    void navigate({
      to: '/works/survey-site-reports',
      search: (previous: Record<string, unknown>) => ({ ...previous, ...patch }),
      resetScroll: false,
    })
  }
  function openReview(action: 'approve' | 'reject') {
    setReviewAction(action)
    setReviewFeedback('')
    setRating('')
    setReviewOpen(true)
  }
  return (
    <PageLayout
      title="Survey site reports"
      subtitle="Review survey measurements, field notes, materials, and supporting evidence."
      actionsInline
      actions={
        canCreate ? (
          <Link
            to="/dashboard/my-reports/create-site/$reportType"
            params={{ reportType: 'survey' }}
            className="rounded-control bg-primary text-text-on-primary text-caption inline-flex min-h-9 items-center gap-2 px-3 font-semibold"
          >
            <Plus className="size-4" />
            <span className="hidden min-[480px]:inline">New survey report</span>
            <span className="min-[480px]:hidden">Add</span>
          </Link>
        ) : null
      }
    >
      <div className="space-y-4">
        <Card className="bg-surface-muted/60 space-y-4">
          <div className="flex flex-wrap items-end justify-between gap-3">
            <div>
              <p className="text-overline text-primary font-semibold">Field reporting</p>
              <h2 className="text-h2 text-text-primary mt-1 font-semibold">Survey register</h2>
              <p className="text-body-sm text-text-secondary mt-1">
                {reportsQuery.data?.count ?? '—'} reports in this view
              </p>
            </div>
            <div className="w-full min-[480px]:w-56">
              <DropdownSelect
                label="Report status"
                value={search.status}
                options={[
                  { value: 'submitted', label: 'Needs review' },
                  { value: 'all', label: 'All reports' },
                  { value: 'draft', label: 'Drafts' },
                  { value: 'approved', label: 'Approved' },
                  { value: 'rejected', label: 'Returned' },
                ]}
                onChange={(value) => change({ status: value, page: 1 })}
              />
            </div>
          </div>
          <div className="tablet:grid-cols-2 grid gap-3">
            <SearchBox
              label="Employee record ID"
              value={search.employeeId ? String(search.employeeId) : ''}
              onChange={(value) => change({ employeeId: value ? Number(value) : null, page: 1 })}
            />
            <DropdownSelect
              label="Project"
              value={String(search.projectId ?? '')}
              options={[
                { value: '', label: 'All projects' },
                ...(projectOptions.data?.items ?? []).map((p) => ({
                  value: String(p.id),
                  label: `${p.short_code} · ${p.name}`,
                })),
              ]}
              onChange={(value) => change({ projectId: value ? Number(value) : null, page: 1 })}
              searchable
            />
          </div>
          <div className="grid gap-3 min-[700px]:grid-cols-2">
            <FormControl id="survey-from" label="From date">
              <DatePickerField
                value={search.dateFrom}
                onValueChange={(dateFrom) => change({ dateFrom, page: 1 })}
                clearable
              />
            </FormControl>
            <FormControl id="survey-to" label="To date">
              <DatePickerField
                value={search.dateTo}
                onValueChange={(dateTo) => change({ dateTo, page: 1 })}
                clearable
              />
            </FormControl>
          </div>
        </Card>
        {reportsQuery.isPending ? (
          <div className="space-y-3" role="status" aria-label="Loading survey reports">
            <Skeleton variant="card" className="h-36" />
            <Skeleton variant="card" className="h-36" />
          </div>
        ) : reportsQuery.isError ? (
          <ErrorState
            title="Survey reports could not load"
            description="Retry to reconnect to the report register."
            action={
              <Button variant="outline" onClick={() => void reportsQuery.refetch()}>
                Try again
              </Button>
            }
            error={reportsQuery.error}
          />
        ) : !reportsQuery.data?.items.length ? (
          <Card>
            <EmptyState
              title="No survey reports found"
              description="Try a different status or date filter, or start a new survey report."
            />
          </Card>
        ) : (
          <Card className="overflow-hidden p-0">
            <div className="divide-border-subtle divide-y">
              {reportsQuery.data.items.map((report) => (
                <article
                  key={report.id}
                  className="tablet:grid-cols-[minmax(0,1fr)_auto] tablet:items-center grid min-w-0 gap-4 p-4"
                >
                  <button
                    className="min-w-0 text-left"
                    onClick={() => setSelectedId(report.id)}
                    aria-label={`View survey report ${report.id}`}
                  >
                    <div className="flex min-w-0 flex-wrap items-center gap-2">
                      <h3 className="text-label text-text-primary font-semibold">
                        {report.worksite_name}
                      </h3>
                      <Status value={report.status} />
                    </div>
                    <p className="text-body-sm text-text-secondary mt-1 break-words">
                      {report.employee_name ?? 'External surveyor'} · {prettyDate(report.date)} ·{' '}
                      {report.work_data_type === 'site_points_xyz'
                        ? 'NEZ / XYZ points'
                        : 'Bearing & distance'}
                    </p>
                    <p className="text-caption text-text-secondary mt-1 line-clamp-2">
                      {report.summary}
                    </p>
                  </button>
                  <div className="tablet:justify-end flex flex-wrap items-center gap-2">
                    <Button variant="outline" size="sm" onClick={() => setSelectedId(report.id)}>
                      Review details
                    </Button>
                    {report.status === 'submitted' && canReview ? (
                      <Button
                        size="sm"
                        leadingIcon={<Check className="size-4" />}
                        onClick={() => {
                          setSelectedId(report.id)
                          setReviewAction('approve')
                          setReviewOpen(true)
                        }}
                      >
                        Approve
                      </Button>
                    ) : null}
                    {report.status === 'submitted' && canReject ? (
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => {
                          setSelectedId(report.id)
                          setReviewAction('reject')
                          setReviewOpen(true)
                        }}
                      >
                        Return
                      </Button>
                    ) : null}
                  </div>
                </article>
              ))}
            </div>
            <PageControls
              page={search.page}
              count={reportsQuery.data.count}
              onChange={(page) => change({ page })}
            />
          </Card>
        )}
      </div>
      <Dialog
        open={Boolean(selectedId) && !reviewOpen}
        onOpenChange={(open) => {
          if (!open) setSelectedId(null)
        }}
        title="Survey report details"
        description="Measurements, review history, and evidence for this submission."
        size="lg"
        fitContent
        bodyClassName="bg-surface-muted"
      >
        {selected ? (
          <div className="space-y-4">
            <Card className="bg-surface">
              <div className="flex flex-wrap items-start justify-between gap-3">
                <div>
                  <p className="text-overline text-primary font-semibold">
                    {selected.work_data_type === 'site_points_xyz'
                      ? 'NEZ / XYZ survey'
                      : 'Bearing and distance survey'}
                  </p>
                  <h3 className="text-h3 text-text-primary mt-1 font-semibold">
                    {selected.worksite_name}
                  </h3>
                  <p className="text-body-sm text-text-secondary mt-1">
                    {selected.employee_name ?? 'External surveyor'} · {prettyDate(selected.date)} ·
                    Version {selected.submission_version}
                  </p>
                </div>
                <Status value={selected.status} />
              </div>
              <p className="text-body-sm text-text-primary mt-4">{selected.summary}</p>
              <div className="mt-4 grid gap-3 min-[700px]:grid-cols-3">
                <div className="rounded-control bg-surface-muted p-3">
                  <p className="text-caption text-text-secondary">Project</p>
                  <p className="text-label text-text-primary mt-1">
                    {selected.project_id ? `Project #${selected.project_id}` : 'Not linked'}
                  </p>
                </div>
                <div className="rounded-control bg-surface-muted p-3">
                  <p className="text-caption text-text-secondary">Measurement unit</p>
                  <p className="text-label text-text-primary mt-1">
                    {selected.measurement_unit ?? 'Metres'}
                  </p>
                </div>
                <div className="rounded-control bg-surface-muted p-3">
                  <p className="text-caption text-text-secondary">GPS</p>
                  <p className="text-label text-text-primary mt-1">
                    {selected.gps_latitude && selected.gps_longitude
                      ? `${selected.gps_latitude}, ${selected.gps_longitude}`
                      : 'Not recorded'}
                  </p>
                </div>
              </div>
            </Card>
            <Card className="bg-surface">
              <h3 className="text-label text-text-primary font-semibold">Activities</h3>
              <ul className="mt-3 space-y-2">
                {selected.activities.map((item, index) => (
                  <li
                    key={item.id ?? index}
                    className="rounded-control bg-surface-muted text-body-sm text-text-primary p-3"
                  >
                    {item.description}
                  </li>
                ))}
              </ul>
            </Card>
            {selected.bearing_distance_points?.length ? (
              <Card className="bg-surface">
                <h3 className="text-label text-text-primary font-semibold">
                  Bearing and distance points
                </h3>
                <div className="mt-3 space-y-2">
                  {selected.bearing_distance_points.map((point) => (
                    <p
                      key={point.id ?? point.point_number}
                      className="text-body-sm text-text-secondary"
                    >
                      Point {point.point_number} · {point.azimuth_degrees}° {point.azimuth_minutes}'{' '}
                      {point.azimuth_seconds}" · {point.distance} {selected.measurement_unit}
                    </p>
                  ))}
                </div>
              </Card>
            ) : null}
            {selected.xyz_points?.length ? (
              <Card className="bg-surface">
                <h3 className="text-label text-text-primary font-semibold">NEZ / XYZ points</h3>
                <div className="mt-3 space-y-2">
                  {selected.xyz_points.map((point) => (
                    <p
                      key={point.id ?? point.point_number}
                      className="text-body-sm text-text-secondary"
                    >
                      Point {point.point_number} · N {point.northing} · E {point.easting} · Z{' '}
                      {point.elevation}
                    </p>
                  ))}
                </div>
              </Card>
            ) : null}
            {selected.attachment_details?.length || selected.attachments?.length ? (
              <Card className="bg-surface">
                <h3 className="text-label text-text-primary font-semibold">Attachments</h3>
                <ul className="mt-3 space-y-2">
                  {(
                    selected.attachment_details ??
                    selected.attachments.map((url) => ({ url, description: '' }))
                  ).map((file) => (
                    <li
                      key={file.url}
                      className="rounded-control bg-surface-muted flex min-w-0 flex-wrap items-center justify-between gap-2 p-3"
                    >
                      <span className="text-body-sm text-text-primary min-w-0 break-all">
                        {file.description || file.url}
                      </span>
                      <a
                        className="text-caption text-primary inline-flex items-center gap-1 font-semibold"
                        href={file.url}
                        target="_blank"
                        rel="noreferrer"
                      >
                        Open <ArrowRight className="size-3" />
                      </a>
                    </li>
                  ))}
                </ul>
              </Card>
            ) : null}
            {selected.review_history?.length ? (
              <Card className="bg-surface">
                <h3 className="text-label text-text-primary font-semibold">Review history</h3>
                <div className="mt-3 space-y-3">
                  {selected.review_history.map((item, index) => (
                    <div
                      key={`${item.submission_version}-${index}`}
                      className="border-border-subtle border-l-2 pl-3"
                    >
                      <p className="text-caption text-text-secondary">
                        Version {item.submission_version} · {item.outcome} ·{' '}
                        {prettyDate(item.reviewed_at)}
                      </p>
                      <p className="text-body-sm text-text-primary mt-1">
                        {item.feedback || 'No written feedback.'}
                      </p>
                    </div>
                  ))}
                </div>
              </Card>
            ) : null}
            <div className="flex flex-wrap justify-between gap-2">
              <Link
                className="text-caption text-primary inline-flex items-center gap-1 font-semibold"
                to="/dashboard/my-reports/site/$reportType/$reportId"
                params={{ reportType: 'survey', reportId: String(selected.id) }}
              >
                Open full report <ArrowRight className="size-4" />
              </Link>
              {selected.status === 'submitted' && (canReview || canReject) ? (
                <div className="flex gap-2">
                  {canReject ? (
                    <Button variant="outline" onClick={() => openReview('reject')}>
                      Return report
                    </Button>
                  ) : null}
                  {canReview ? (
                    <Button onClick={() => openReview('approve')}>Approve report</Button>
                  ) : null}
                </div>
              ) : null}
            </div>
          </div>
        ) : (
          <Skeleton variant="card" className="h-44" />
        )}
      </Dialog>
      <Dialog
        open={reviewOpen}
        onOpenChange={setReviewOpen}
        title={reviewAction === 'approve' ? 'Approve survey report' : 'Return survey report'}
        description={`Review the current submission${selected ? `, version ${selected.submission_version}` : ''}.`}
        size="sm"
        fitContent
        bodyClassName="bg-surface-muted"
        footer={
          <div className="flex flex-wrap justify-end gap-2">
            <Button variant="outline" onClick={() => setReviewOpen(false)}>
              Cancel
            </Button>
            <Button
              variant={reviewAction === 'reject' ? 'danger' : 'primary'}
              isLoading={reviewMutation.isPending}
              disabled={reviewAction === 'reject' && !reviewFeedback.trim()}
              onClick={() => reviewMutation.mutate()}
            >
              {reviewAction === 'approve' ? 'Approve report' : 'Return report'}
            </Button>
          </div>
        }
      >
        <div className="rounded-control bg-surface space-y-4 p-4">
          {reviewAction === 'approve' ? (
            <DropdownSelect
              label="Quality rating (optional)"
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
          ) : null}
          <FormControl
            id="survey-review-feedback"
            label={reviewAction === 'approve' ? 'Reviewer feedback (optional)' : 'Return reason'}
            required={reviewAction === 'reject'}
          >
            <TextArea
              value={reviewFeedback}
              onChange={(event) => setReviewFeedback(event.target.value)}
              rows={4}
              placeholder={
                reviewAction === 'approve'
                  ? 'Add a note for the submitter'
                  : 'Explain what needs correction'
              }
            />
          </FormControl>
        </div>
      </Dialog>
    </PageLayout>
  )
}

const contractTypes = [
  { value: 'fixed_price', label: 'Fixed price' },
  { value: 'time_materials', label: 'Time & materials' },
  { value: 'retainer', label: 'Retainer' },
  { value: 'specialist', label: 'Specialist' },
  { value: 'project_management', label: 'Project management' },
  { value: 'consulting', label: 'Consulting' },
]

type ContractDraft = {
  project_id: string
  name: string
  contract_number: string
  contract_type: string
  value: string
  start_date: string
  end_date: string
}
const emptyContract: ContractDraft = {
  project_id: '',
  name: '',
  contract_number: '',
  contract_type: 'fixed_price',
  value: '',
  start_date: '',
  end_date: '',
}

export function ContractsPage() {
  const search = useSearch({ strict: false }) as ContractWorkflowSearch
  const navigate = useNavigate()
  const client = useQueryClient()
  const toast = useToast()
  const session = useQuery(authSessionQueryOptions()).data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const canCreate = Boolean(session && hasPermission(session.permissions, 'contracts', 'create'))
  const canUpdate = Boolean(session && hasPermission(session.permissions, 'contracts', 'update'))
  const canDelete = Boolean(session && hasPermission(session.permissions, 'contracts', 'delete'))
  const params = {
    limit: PAGE_SIZE,
    offset: (search.page - 1) * PAGE_SIZE,
    search: search.search,
    status: search.status,
    contract_type: search.contractType,
  }
  const contractsQuery = useQuery({
    queryKey: ['operations', 'contracts', userId, employeeId, params],
    queryFn: ({ signal }) => operationsWorkflowsApi.contracts(params, signal),
    enabled: Boolean(session),
    ...queryDefaults,
    placeholderData: (previous) => previous,
  })
  const projects = useProjectOptions(userId, employeeId)
  const [formOpen, setFormOpen] = useState(false)
  const [editing, setEditing] = useState<ContractRecord | null>(null)
  const [draft, setDraft] = useState<ContractDraft>(emptyContract)
  const [selected, setSelected] = useState<ContractRecord | null>(null)
  const [signOpen, setSignOpen] = useState(false)
  const [signatory, setSignatory] = useState('')
  const [signingDate, setSigningDate] = useState(new Date().toISOString().slice(0, 10))
  const [terminateOpen, setTerminateOpen] = useState(false)
  const [terminationReason, setTerminationReason] = useState('')
  const [renewOpen, setRenewOpen] = useState(false)
  const [fieldError, setFieldError] = useState('')
  const detailDocuments = useQuery({
    queryKey: ['operations', 'contract-documents', selected?.id],
    queryFn: ({ signal }) => operationsWorkflowsApi.contractDocuments(selected!.id, signal),
    enabled: Boolean(selected),
    ...queryDefaults,
  })
  const detailEvents = useQuery({
    queryKey: ['operations', 'contract-events', selected?.id],
    queryFn: ({ signal }) => operationsWorkflowsApi.contractEvents(selected!.id, signal),
    enabled: Boolean(selected),
    ...queryDefaults,
  })
  function change(patch: Partial<ContractWorkflowSearch>) {
    void navigate({
      to: '/works/contracts',
      search: (previous: Record<string, unknown>) => ({ ...previous, ...patch }),
      resetScroll: false,
    })
  }
  function startCreate() {
    setEditing(null)
    setDraft(emptyContract)
    setFieldError('')
    setFormOpen(true)
  }
  function startEdit(contract: ContractRecord) {
    setEditing(contract)
    setDraft({
      project_id: String(contract.project_id),
      name: contract.name,
      contract_number: contract.contract_number,
      contract_type: contract.contract_type,
      value: contract.value,
      start_date: contract.start_date,
      end_date: contract.end_date,
    })
    setFieldError('')
    setFormOpen(true)
  }
  const saveMutation = useMutation({
    mutationFn: () => {
      if (!draft.project_id) throw new Error('Select the owning project.')
      if (
        !draft.name.trim() ||
        !draft.contract_number.trim() ||
        !draft.value ||
        !draft.start_date ||
        !draft.end_date
      )
        throw new Error('Complete all required fields.')
      if (draft.end_date < draft.start_date)
        throw new Error('End date must be on or after the start date.')
      const input = {
        project_id: Number(draft.project_id),
        name: draft.name.trim(),
        contract_number: draft.contract_number.trim(),
        contract_type: draft.contract_type,
        value: draft.value,
        start_date: draft.start_date,
        end_date: draft.end_date,
      }
      return editing
        ? operationsWorkflowsApi.updateContract(editing.id, input)
        : operationsWorkflowsApi.createContract({ ...input, status: 'pending' })
    },
    onSuccess: async () => {
      await client.invalidateQueries({ queryKey: ['operations', 'contracts'] })
      setFormOpen(false)
      toast.showToast({ title: editing ? 'Contract updated' : 'Contract created', tone: 'success' })
    },
    onError: (error) =>
      setFieldError(error instanceof Error ? error.message : 'Contract could not be saved.'),
  })
  const deleteMutation = useMutation({
    mutationFn: (id: number) => operationsWorkflowsApi.deleteContract(id),
    onSuccess: async () => {
      await client.invalidateQueries({ queryKey: ['operations', 'contracts'] })
      setSelected(null)
      toast.showToast({ title: 'Contract permanently deleted', tone: 'success' })
    },
    onError: (error) =>
      toast.showToast({
        title: 'Contract could not be deleted',
        description: error instanceof Error ? error.message : undefined,
        tone: 'danger',
      }),
  })
  const signMutation = useMutation({
    mutationFn: () =>
      operationsWorkflowsApi.signContract(selected!.id, {
        signatory_name: signatory,
        signing_date: signingDate,
      }),
    onSuccess: async (contract) => {
      await client.invalidateQueries({ queryKey: ['operations', 'contracts'] })
      setSelected(contract)
      setSignOpen(false)
      toast.showToast({ title: 'Contract marked as signed', tone: 'success' })
    },
    onError: (error) =>
      toast.showToast({
        title: 'Contract could not be signed',
        description: error instanceof Error ? error.message : undefined,
        tone: 'danger',
      }),
  })
  const terminateMutation = useMutation({
    mutationFn: () => operationsWorkflowsApi.terminateContract(selected!.id, terminationReason),
    onSuccess: async (contract) => {
      await client.invalidateQueries({ queryKey: ['operations', 'contracts'] })
      setSelected(contract)
      setTerminateOpen(false)
      toast.showToast({ title: 'Contract terminated', tone: 'success' })
    },
    onError: (error) =>
      toast.showToast({
        title: 'Contract could not be terminated',
        description: error instanceof Error ? error.message : undefined,
        tone: 'danger',
      }),
  })
  const renewMutation = useMutation({
    mutationFn: () =>
      operationsWorkflowsApi.renewContract(selected!.id, {
        ...draft,
        project_id: selected!.project_id,
        value: draft.value,
      }),
    onSuccess: async () => {
      await client.invalidateQueries({ queryKey: ['operations', 'contracts'] })
      setRenewOpen(false)
      setSelected(null)
      toast.showToast({ title: 'Renewal contract created', tone: 'success' })
    },
    onError: (error) =>
      setFieldError(error instanceof Error ? error.message : 'Renewal could not be created.'),
  })
  const uploadMutation = useMutation({
    mutationFn: ({ file, type }: { file: File; type: string }) =>
      operationsWorkflowsApi.uploadContractDocument(selected!.id, file, type),
    onSuccess: async () => {
      await client.invalidateQueries({
        queryKey: ['operations', 'contract-documents', selected?.id],
      })
      toast.showToast({ title: 'Contract document uploaded', tone: 'success' })
    },
    onError: (error) =>
      toast.showToast({
        title: 'Document upload failed',
        description: error instanceof Error ? error.message : undefined,
        tone: 'danger',
      }),
  })
  const removeDocument = useMutation({
    mutationFn: (id: number) => operationsWorkflowsApi.deleteContractDocument(selected!.id, id),
    onSuccess: async () => {
      await client.invalidateQueries({
        queryKey: ['operations', 'contract-documents', selected?.id],
      })
    },
    onError: (error) =>
      toast.showToast({
        title: 'Document could not be removed',
        description: error instanceof Error ? error.message : undefined,
        tone: 'danger',
      }),
  })
  return (
    <PageLayout
      title="Contracts"
      subtitle="Manage project agreements, private documents, signatures, and renewal history."
      actionsInline
      actions={
        canCreate ? (
          <Button size="sm" leadingIcon={<Plus className="size-4" />} onClick={startCreate}>
            <span className="hidden min-[480px]:inline">New contract</span>
            <span className="min-[480px]:hidden">Add</span>
          </Button>
        ) : null
      }
    >
      <div className="space-y-4">
        <Card className="bg-surface-muted/60 space-y-4">
          <div className="flex flex-wrap items-end justify-between gap-3">
            <div>
              <p className="text-overline text-primary font-semibold">Commercial records</p>
              <h2 className="text-h2 text-text-primary mt-1 font-semibold">Contract register</h2>
              <p className="text-body-sm text-text-secondary mt-1">
                {contractsQuery.data?.count ?? '—'} contracts visible in your scope
              </p>
            </div>
            <div className="w-full min-[480px]:w-52">
              <DropdownSelect
                label="Status"
                value={search.status}
                options={[
                  { value: '', label: 'All statuses' },
                  { value: 'pending', label: 'Pending' },
                  { value: 'active', label: 'Active' },
                  { value: 'renewed', label: 'Renewed' },
                  { value: 'terminated', label: 'Terminated' },
                  { value: 'completed', label: 'Completed' },
                  { value: 'cancelled', label: 'Cancelled' },
                ]}
                onChange={(status) => change({ status, page: 1 })}
              />
            </div>
          </div>
          <div className="tablet:grid-cols-2 grid gap-3">
            <SearchBox
              label="Search name or contract number"
              value={search.search}
              onChange={(value) => change({ search: value, page: 1 })}
            />
            <DropdownSelect
              label="Contract type"
              value={search.contractType}
              options={[{ value: '', label: 'All contract types' }, ...contractTypes]}
              onChange={(contractType) => change({ contractType, page: 1 })}
            />
          </div>
        </Card>
        {contractsQuery.isPending ? (
          <div role="status" aria-label="Loading contracts" className="space-y-3">
            <Skeleton variant="card" className="h-36" />
            <Skeleton variant="card" className="h-36" />
          </div>
        ) : contractsQuery.isError ? (
          <ErrorState
            title="Contracts could not load"
            description="Retry to reconnect to the contract register."
            action={
              <Button variant="outline" onClick={() => void contractsQuery.refetch()}>
                Try again
              </Button>
            }
            error={contractsQuery.error}
          />
        ) : !contractsQuery.data?.items.length ? (
          <Card>
            <EmptyState
              title="No contracts found"
              description="Change the filters or create a contract linked to a project."
              action={
                canCreate ? <Button onClick={startCreate}>Create contract</Button> : undefined
              }
            />
          </Card>
        ) : (
          <Card className="overflow-hidden p-0">
            <div className="divide-border-subtle divide-y">
              {contractsQuery.data.items.map((contract) => (
                <article
                  key={contract.id}
                  className="tablet:grid-cols-[minmax(0,1fr)_auto] tablet:items-center grid min-w-0 gap-4 p-4"
                >
                  <button className="min-w-0 text-left" onClick={() => setSelected(contract)}>
                    <div className="flex flex-wrap items-center gap-2">
                      <h3 className="text-label text-text-primary font-semibold">
                        {contract.name}
                      </h3>
                      <Status value={contract.status} />
                    </div>
                    <p className="text-body-sm text-text-secondary mt-1 break-all">
                      {contract.contract_number} · {contract.contract_type.replaceAll('_', ' ')} ·
                      Project #{contract.project_id}
                    </p>
                    <p className="text-caption text-text-secondary mt-1">
                      {prettyDate(contract.start_date)} – {prettyDate(contract.end_date)}
                    </p>
                  </button>
                  <div className="tablet:justify-end flex flex-wrap items-center gap-3">
                    <span className="text-label text-text-primary font-semibold">
                      {money(contract.value)}
                    </span>
                    <Button variant="outline" size="sm" onClick={() => setSelected(contract)}>
                      Details
                    </Button>
                    {canUpdate ? (
                      <Button variant="ghost" size="sm" onClick={() => startEdit(contract)}>
                        Edit
                      </Button>
                    ) : null}
                  </div>
                </article>
              ))}
            </div>
            <PageControls
              page={search.page}
              count={contractsQuery.data.count}
              onChange={(page) => change({ page })}
            />
          </Card>
        )}
      </div>
      <Dialog
        open={formOpen}
        onOpenChange={setFormOpen}
        title={editing ? 'Edit contract' : 'Create contract'}
        description="Every contract must be linked to a project in your branch scope."
        size="lg"
        fitContent
        bodyClassName="bg-surface-muted"
        footer={
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setFormOpen(false)}>
              Cancel
            </Button>
            <Button isLoading={saveMutation.isPending} onClick={() => saveMutation.mutate()}>
              {editing ? 'Save changes' : 'Create contract'}
            </Button>
          </div>
        }
      >
        <div className="rounded-control bg-surface space-y-4 p-4">
          <FormControl
            id="contract-project"
            label="Project"
            required
            error={fieldError && !draft.project_id ? fieldError : undefined}
          >
            <DropdownSelect
              value={draft.project_id}
              options={(projects.data?.items ?? []).map((p) => ({
                value: String(p.id),
                label: `${p.short_code} · ${p.name}`,
              }))}
              onChange={(project_id) => setDraft({ ...draft, project_id })}
              placeholder="Choose a project"
              searchable
            />
          </FormControl>
          <div className="grid gap-3 min-[700px]:grid-cols-2">
            <FormControl id="contract-name" label="Contract name" required>
              <TextInput
                value={draft.name}
                onChange={(e) => setDraft({ ...draft, name: e.target.value })}
              />
            </FormControl>
            <FormControl id="contract-number" label="Contract number" required>
              <TextInput
                value={draft.contract_number}
                onChange={(e) => setDraft({ ...draft, contract_number: e.target.value })}
              />
            </FormControl>
            <DropdownSelect
              label="Contract type"
              value={draft.contract_type}
              options={contractTypes}
              onChange={(contract_type) => setDraft({ ...draft, contract_type })}
            />
            <FormControl id="contract-value" label="Value (NGN)" required>
              <TextInput
                type="number"
                min="0"
                step="0.01"
                value={draft.value}
                onChange={(e) => setDraft({ ...draft, value: e.target.value })}
              />
            </FormControl>
            <FormControl id="contract-start" label="Start date" required>
              <DatePickerField
                value={draft.start_date}
                onValueChange={(start_date) => setDraft({ ...draft, start_date })}
              />
            </FormControl>
            <FormControl
              id="contract-end"
              label="End date"
              required
              error={
                draft.start_date && draft.end_date && draft.end_date < draft.start_date
                  ? 'End date must be on or after start date.'
                  : undefined
              }
            >
              <DatePickerField
                value={draft.end_date}
                onValueChange={(end_date) => setDraft({ ...draft, end_date })}
                min={draft.start_date}
              />
            </FormControl>
          </div>
          {fieldError ? (
            <p role="status" className="text-body-sm text-danger">
              {fieldError}
            </p>
          ) : null}
        </div>
      </Dialog>
      <Dialog
        open={Boolean(selected)}
        onOpenChange={(open) => {
          if (!open) setSelected(null)
        }}
        title={selected?.name ?? 'Contract details'}
        description={selected?.contract_number}
        size="lg"
        fitContent
        bodyClassName="bg-surface-muted"
      >
        {selected ? (
          <div className="space-y-4">
            <Card className="bg-surface">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div>
                  <p className="text-overline text-primary font-semibold">
                    {selected.contract_type.replaceAll('_', ' ')}
                  </p>
                  <p className="text-h2 text-text-primary mt-1 font-semibold">
                    {money(selected.value)}
                  </p>
                  <p className="text-body-sm text-text-secondary mt-1">
                    Project #{selected.project_id} · {prettyDate(selected.start_date)} –{' '}
                    {prettyDate(selected.end_date)}
                  </p>
                </div>
                <Status value={selected.status} />
              </div>
              <div className="mt-4 flex flex-wrap gap-2">
                {canUpdate && selected.status === 'pending' ? (
                  <Button
                    size="sm"
                    leadingIcon={<ShieldCheck className="size-4" />}
                    onClick={() => setSignOpen(true)}
                  >
                    Record signing
                  </Button>
                ) : null}
                {canUpdate && ['active', 'in_progress', 'completed'].includes(selected.status) ? (
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      setDraft({
                        ...emptyContract,
                        project_id: String(selected.project_id),
                        name: `${selected.name} renewal`,
                        contract_type: selected.contract_type,
                        value: selected.value,
                      })
                      setRenewOpen(true)
                      setFieldError('')
                    }}
                  >
                    Renew
                  </Button>
                ) : null}
                {canUpdate && ['active', 'in_progress'].includes(selected.status) ? (
                  <Button variant="outline" size="sm" onClick={() => setTerminateOpen(true)}>
                    Terminate
                  </Button>
                ) : null}
                {canDelete ? (
                  <Button
                    variant="danger"
                    size="sm"
                    onClick={() => {
                      if (
                        window.confirm(
                          'Permanently delete this pending, unexecuted contract? This cannot be undone.',
                        )
                      )
                        deleteMutation.mutate(selected.id)
                    }}
                  >
                    Delete
                  </Button>
                ) : null}
              </div>
              {selected.renewal_parent_id ? (
                <p className="text-caption text-text-secondary mt-3">
                  Renewal successor of contract #{selected.renewal_parent_id}
                </p>
              ) : null}
              {selected.signed_at ? (
                <p className="text-caption text-text-secondary mt-2">
                  Signed {prettyDate(selected.signed_at)} by user #{selected.signed_by_id}
                </p>
              ) : null}
              {selected.termination_reason ? (
                <p className="text-body-sm text-danger mt-3">
                  Termination reason: {selected.termination_reason}
                </p>
              ) : null}
            </Card>
            <Card className="bg-surface">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div>
                  <h3 className="text-label text-text-primary font-semibold">Private documents</h3>
                  <p className="text-caption text-text-secondary mt-1">
                    Only users with access to the linked project can open these files.
                  </p>
                </div>
                {canUpdate && selected.status === 'pending' ? (
                  <label className="rounded-control bg-primary text-text-on-primary text-caption inline-flex min-h-9 cursor-pointer items-center gap-2 px-3 font-semibold">
                    <Plus className="size-4" />
                    Upload
                    <input
                      className="sr-only"
                      type="file"
                      accept=".pdf,.doc,.docx,.xls,.xlsx,.jpg,.jpeg,.png,.txt"
                      onChange={(event) => {
                        const file = event.target.files?.[0]
                        if (file) uploadMutation.mutate({ file, type: 'supporting' })
                        event.currentTarget.value = ''
                      }}
                    />
                  </label>
                ) : null}
              </div>
              {detailDocuments.isPending ? (
                <Skeleton variant="card" className="mt-3 h-16" />
              ) : detailDocuments.isError ? (
                <SectionErrorState
                  title="Documents unavailable"
                  error={detailDocuments.error}
                  onRetry={() => void detailDocuments.refetch()}
                />
              ) : detailDocuments.data?.length ? (
                <ul className="mt-3 space-y-2">
                  {detailDocuments.data.map((doc) => (
                    <li
                      key={doc.id}
                      className="rounded-control bg-surface-muted flex min-w-0 flex-wrap items-center justify-between gap-2 p-3"
                    >
                      <div className="flex min-w-0 items-center gap-2">
                        <FileText className="text-primary size-5 shrink-0" />
                        <div className="min-w-0">
                          <p className="text-label text-text-primary font-semibold break-all">
                            {doc.original_filename}
                          </p>
                          <p className="text-caption text-text-secondary">
                            {doc.document_type} · {Math.ceil(doc.size / 1024)} KB ·{' '}
                            {doc.uploaded_by_name}
                          </p>
                        </div>
                      </div>
                      <div className="flex gap-2">
                        <a
                          className="rounded-control border-border-subtle text-caption inline-flex min-h-9 items-center gap-2 border px-3 font-semibold"
                          href={doc.download_url}
                        >
                          <ArrowDownToLine className="size-4" />
                          Download
                        </a>
                        {canUpdate && doc.document_type !== 'executed' && !selected.signed_at ? (
                          <Button
                            variant="ghost"
                            size="icon"
                            aria-label={`Remove ${doc.original_filename}`}
                            onClick={() => removeDocument.mutate(doc.id)}
                          >
                            <X className="size-4" />
                          </Button>
                        ) : null}
                      </div>
                    </li>
                  ))}
                </ul>
              ) : (
                <p className="text-body-sm text-text-secondary mt-3">
                  No documents have been uploaded.
                </p>
              )}
              {canUpdate && selected.status === 'pending' ? (
                <div className="border-border-subtle mt-3 border-t pt-3">
                  <FormControl
                    id="executed-document"
                    label="Executed contract (required before signing)"
                  >
                    <input
                      className="text-caption text-text-secondary block w-full"
                      type="file"
                      accept=".pdf,.doc,.docx,.jpg,.jpeg,.png"
                      onChange={(event) => {
                        const file = event.target.files?.[0]
                        if (file) uploadMutation.mutate({ file, type: 'executed' })
                        event.currentTarget.value = ''
                      }}
                    />
                  </FormControl>
                </div>
              ) : null}
            </Card>
            <Card className="bg-surface">
              <h3 className="text-label text-text-primary font-semibold">Lifecycle history</h3>
              {detailEvents.data?.length ? (
                <ol className="mt-3 space-y-3">
                  {detailEvents.data.map((event) => (
                    <li key={event.id} className="border-border-subtle border-l-2 pl-3">
                      <p className="text-label text-text-primary font-semibold">
                        {event.event_type}
                      </p>
                      <p className="text-caption text-text-secondary mt-1">
                        {event.actor_name} · {new Date(event.effective_at).toLocaleString()}
                      </p>
                    </li>
                  ))}
                </ol>
              ) : (
                <p className="text-body-sm text-text-secondary mt-2">
                  No lifecycle events recorded.
                </p>
              )}
            </Card>
          </div>
        ) : null}
      </Dialog>
      <Dialog
        open={signOpen}
        onOpenChange={setSignOpen}
        title="Record contract signing"
        description="Confirm the signatory and signing date. An executed file must be uploaded first."
        size="sm"
        fitContent
        bodyClassName="bg-surface-muted"
        footer={
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setSignOpen(false)}>
              Cancel
            </Button>
            <Button isLoading={signMutation.isPending} onClick={() => signMutation.mutate()}>
              Record signature
            </Button>
          </div>
        }
      >
        <div className="rounded-control bg-surface space-y-4 p-4">
          <FormControl id="signatory" label="Signatory name" required>
            <TextInput value={signatory} onChange={(e) => setSignatory(e.target.value)} />
          </FormControl>
          <FormControl id="sign-date" label="Signing date" required>
            <DatePickerField value={signingDate} onValueChange={setSigningDate} />
          </FormControl>
        </div>
      </Dialog>
      <Dialog
        open={terminateOpen}
        onOpenChange={setTerminateOpen}
        title="Terminate contract"
        description="This action is recorded in the contract lifecycle history."
        size="sm"
        fitContent
        bodyClassName="bg-surface-muted"
        footer={
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setTerminateOpen(false)}>
              Cancel
            </Button>
            <Button
              variant="danger"
              isLoading={terminateMutation.isPending}
              disabled={!terminationReason.trim()}
              onClick={() => terminateMutation.mutate()}
            >
              Terminate contract
            </Button>
          </div>
        }
      >
        <div className="rounded-control bg-surface p-4">
          <FormControl id="termination-reason" label="Reason" required>
            <TextArea
              value={terminationReason}
              onChange={(e) => setTerminationReason(e.target.value)}
            />
          </FormControl>
        </div>
      </Dialog>
      <Dialog
        open={renewOpen}
        onOpenChange={setRenewOpen}
        title="Create renewal"
        description="This creates a linked pending successor and marks the existing contract renewed."
        size="lg"
        fitContent
        bodyClassName="bg-surface-muted"
        footer={
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setRenewOpen(false)}>
              Cancel
            </Button>
            <Button isLoading={renewMutation.isPending} onClick={() => renewMutation.mutate()}>
              Create renewal
            </Button>
          </div>
        }
      >
        <div className="rounded-control bg-surface space-y-3 p-4">
          <FormControl id="renew-name" label="Renewal name" required>
            <TextInput
              value={draft.name}
              onChange={(e) => setDraft({ ...draft, name: e.target.value })}
            />
          </FormControl>
          <FormControl id="renew-number" label="New contract number" required>
            <TextInput
              value={draft.contract_number}
              onChange={(e) => setDraft({ ...draft, contract_number: e.target.value })}
            />
          </FormControl>
          <div className="tablet:grid-cols-2 grid gap-3">
            <FormControl id="renew-type" label="Type">
              <DropdownSelect
                value={draft.contract_type}
                options={contractTypes}
                onChange={(contract_type) => setDraft({ ...draft, contract_type })}
              />
            </FormControl>
            <FormControl id="renew-value" label="Value (NGN)" required>
              <TextInput
                type="number"
                min="0"
                value={draft.value}
                onChange={(e) => setDraft({ ...draft, value: e.target.value })}
              />
            </FormControl>
            <FormControl id="renew-start" label="Start date" required>
              <DatePickerField
                value={draft.start_date}
                onValueChange={(start_date) => setDraft({ ...draft, start_date })}
              />
            </FormControl>
            <FormControl id="renew-end" label="End date" required>
              <DatePickerField
                value={draft.end_date}
                onValueChange={(end_date) => setDraft({ ...draft, end_date })}
                min={draft.start_date}
              />
            </FormControl>
          </div>
          {fieldError ? (
            <p role="status" className="text-body-sm text-danger">
              {fieldError}
            </p>
          ) : null}
        </div>
      </Dialog>
    </PageLayout>
  )
}

type MeetingDraft = {
  title: string
  project_id: string
  agenda: string
  meeting_date: string
  meeting_time: string
  duration_minutes: string
  status: string
  location_type: string
  location: string
  notes: string
  attendee_ids: number[]
}
const emptyMeeting: MeetingDraft = {
  title: '',
  project_id: '',
  agenda: '',
  meeting_date: '',
  meeting_time: '',
  duration_minutes: '60',
  status: 'scheduled',
  location_type: 'physical',
  location: '',
  notes: '',
  attendee_ids: [],
}

export function MeetingsPage() {
  const search = useSearch({ strict: false }) as MeetingWorkflowSearch
  const navigate = useNavigate()
  const client = useQueryClient()
  const toast = useToast()
  const session = useQuery(authSessionQueryOptions()).data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const canCreate = Boolean(session && hasPermission(session.permissions, 'meetings', 'create'))
  const canUpdate = Boolean(session && hasPermission(session.permissions, 'meetings', 'update'))
  const canCancel = Boolean(session && hasPermission(session.permissions, 'meetings', 'delete'))
  const params = {
    limit: PAGE_SIZE,
    offset: (search.page - 1) * PAGE_SIZE,
    search: search.search,
    status: search.status,
    location_type: search.locationType,
    date_from: search.dateFrom,
    date_to: search.dateTo,
    project_id: search.projectId,
    my_meetings: search.myMeetings ? true : null,
  }
  const meetingsQuery = useQuery({
    queryKey: ['operations', 'meetings', userId, employeeId, params],
    queryFn: ({ signal }) => operationsWorkflowsApi.meetings(params, signal),
    enabled: Boolean(session),
    ...queryDefaults,
    placeholderData: (previous) => previous,
  })
  const projects = useProjectOptions(userId, employeeId)
  const attendees = useQuery({
    queryKey: ['operations', 'meeting-attendees', userId],
    queryFn: ({ signal }) => operationsWorkflowsApi.meetingAttendees('', signal),
    enabled: Boolean(session && (canCreate || canUpdate)),
    ...queryDefaults,
  })
  const [formOpen, setFormOpen] = useState(false)
  const [editing, setEditing] = useState<MeetingRecord | null>(null)
  const [draft, setDraft] = useState<MeetingDraft>(emptyMeeting)
  const [selected, setSelected] = useState<MeetingRecord | null>(null)
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({})
  const [cancelTarget, setCancelTarget] = useState<MeetingRecord | null>(null)
  function change(patch: Partial<MeetingWorkflowSearch>) {
    void navigate({
      to: '/hr/meetings',
      search: (previous: Record<string, unknown>) => ({ ...previous, ...patch }),
      resetScroll: false,
    })
  }
  function startCreate() {
    setEditing(null)
    setDraft(emptyMeeting)
    setFieldErrors({})
    setFormOpen(true)
  }
  function startEdit(item: MeetingRecord) {
    setEditing(item)
    setSelected(null)
    setDraft({
      title: item.title,
      project_id: item.project_id ? String(item.project_id) : '',
      agenda: item.agenda,
      meeting_date: item.meeting_date,
      meeting_time: item.meeting_time,
      duration_minutes: String(item.duration_minutes),
      status: item.status,
      location_type: item.location_type,
      location: item.location ?? '',
      notes: item.notes ?? '',
      attendee_ids: item.attendees.map((person) => person.user_id),
    })
    setFieldErrors({})
    setFormOpen(true)
  }
  const saveMutation = useMutation({
    mutationFn: () => {
      const errors: Record<string, string> = {}
      if (!draft.title.trim()) errors.title = 'Enter a meeting title.'
      if (!draft.agenda.trim()) errors.agenda = 'Enter an agenda.'
      if (!draft.meeting_date) errors.meeting_date = 'Choose a meeting date.'
      if (!draft.meeting_time) errors.meeting_time = 'Choose a meeting time.'
      const duration = Number(draft.duration_minutes)
      if (!Number.isInteger(duration) || duration <= 0)
        errors.duration_minutes = 'Duration must be a positive number of minutes.'
      setFieldErrors(errors)
      if (Object.keys(errors).length) throw new Error('Correct the highlighted meeting fields.')
      const input = {
        title: draft.title.trim(),
        project_id: draft.project_id ? Number(draft.project_id) : null,
        agenda: draft.agenda.trim(),
        meeting_date: draft.meeting_date,
        meeting_time: draft.meeting_time,
        duration_minutes: duration,
        status: draft.status,
        location_type: draft.location_type,
        location: draft.location,
        notes: draft.notes,
        attendee_ids: draft.attendee_ids,
      }
      return editing
        ? operationsWorkflowsApi.updateMeeting(editing.id, input)
        : operationsWorkflowsApi.createMeeting(input)
    },
    onSuccess: async () => {
      await client.invalidateQueries({ queryKey: ['operations', 'meetings'] })
      setFormOpen(false)
      toast.showToast({ title: editing ? 'Meeting updated' : 'Meeting scheduled', tone: 'success' })
    },
    onError: (error) => {
      if (!(error instanceof Error && error.message.startsWith('Correct')))
        toast.showToast({
          title: 'Meeting could not be saved',
          description: error instanceof Error ? error.message : undefined,
          tone: 'danger',
        })
    },
  })
  const cancelMutation = useMutation({
    mutationFn: (item: MeetingRecord) => operationsWorkflowsApi.cancelMeeting(item.id),
    onSuccess: async () => {
      await client.invalidateQueries({ queryKey: ['operations', 'meetings'] })
      setCancelTarget(null)
      setSelected(null)
      toast.showToast({
        title: 'Meeting cancelled',
        description: 'The record remains available in meeting history.',
        tone: 'success',
      })
    },
    onError: (error) =>
      toast.showToast({
        title: 'Meeting could not be cancelled',
        description: error instanceof Error ? error.message : undefined,
        tone: 'danger',
      }),
  })
  return (
    <PageLayout
      title="Meetings"
      subtitle="Coordinate company meetings, attendees, locations, and project context."
      actionsInline
      actions={
        canCreate ? (
          <Button size="sm" leadingIcon={<Plus className="size-4" />} onClick={startCreate}>
            <span className="hidden min-[480px]:inline">Schedule meeting</span>
            <span className="min-[480px]:hidden">Add</span>
          </Button>
        ) : null
      }
    >
      <div className="space-y-4">
        <Card className="bg-surface-muted/60 space-y-4">
          <div className="flex flex-wrap items-end justify-between gap-3">
            <div>
              <p className="text-overline text-primary font-semibold">Company calendar</p>
              <h2 className="text-h2 text-text-primary mt-1 font-semibold">Meeting register</h2>
              <p className="text-body-sm text-text-secondary mt-1">
                {meetingsQuery.data?.count ?? '—'} meetings visible in your scope
              </p>
            </div>
            <label className="text-caption text-text-secondary inline-flex min-h-10 items-center gap-2">
              <input
                type="checkbox"
                checked={search.myMeetings}
                onChange={(event) => change({ myMeetings: event.target.checked, page: 1 })}
                className="accent-primary size-4"
              />
              My meetings
            </label>
          </div>
          <div className="tablet:grid-cols-2 grid gap-3">
            <SearchBox
              label="Search meetings"
              value={search.search}
              onChange={(value) => change({ search: value, page: 1 })}
            />
            <DropdownSelect
              label="Status"
              value={search.status}
              options={[
                { value: '', label: 'All statuses' },
                { value: 'scheduled', label: 'Scheduled' },
                { value: 'ongoing', label: 'Ongoing' },
                { value: 'completed', label: 'Completed' },
                { value: 'postponed', label: 'Postponed' },
                { value: 'cancelled', label: 'Cancelled' },
              ]}
              onChange={(status) => change({ status, page: 1 })}
            />
            <DropdownSelect
              label="Location type"
              value={search.locationType}
              options={[
                { value: '', label: 'All locations' },
                { value: 'physical', label: 'Physical' },
                { value: 'virtual', label: 'Virtual' },
                { value: 'hybrid', label: 'Hybrid' },
              ]}
              onChange={(locationType) => change({ locationType, page: 1 })}
            />
            <DropdownSelect
              label="Project"
              value={String(search.projectId ?? '')}
              options={[
                { value: '', label: 'All projects' },
                ...(projects.data?.items ?? []).map((p) => ({
                  value: String(p.id),
                  label: `${p.short_code} · ${p.name}`,
                })),
              ]}
              onChange={(value) => change({ projectId: value ? Number(value) : null, page: 1 })}
              searchable
            />
          </div>
          <div className="grid gap-3 min-[700px]:grid-cols-2">
            <FormControl id="meeting-from" label="From date">
              <DatePickerField
                value={search.dateFrom}
                onValueChange={(dateFrom) => change({ dateFrom, page: 1 })}
                clearable
              />
            </FormControl>
            <FormControl id="meeting-to" label="To date">
              <DatePickerField
                value={search.dateTo}
                onValueChange={(dateTo) => change({ dateTo, page: 1 })}
                clearable
              />
            </FormControl>
          </div>
        </Card>
        {meetingsQuery.isPending ? (
          <div role="status" aria-label="Loading meetings" className="space-y-3">
            <Skeleton variant="card" className="h-36" />
            <Skeleton variant="card" className="h-36" />
          </div>
        ) : meetingsQuery.isError ? (
          <ErrorState
            title="Meetings could not load"
            description="Retry to reconnect to the meeting register."
            action={
              <Button variant="outline" onClick={() => void meetingsQuery.refetch()}>
                Try again
              </Button>
            }
            error={meetingsQuery.error}
          />
        ) : !meetingsQuery.data?.items.length ? (
          <Card>
            <EmptyState
              title="No meetings found"
              description="Adjust the date or status filters, or schedule a meeting."
              action={
                canCreate ? <Button onClick={startCreate}>Schedule meeting</Button> : undefined
              }
            />
          </Card>
        ) : (
          <Card className="overflow-hidden p-0">
            <div className="divide-border-subtle divide-y">
              {meetingsQuery.data.items.map((item) => (
                <article
                  key={item.id}
                  className="tablet:grid-cols-[minmax(0,1fr)_auto] tablet:items-center grid min-w-0 gap-4 p-4"
                >
                  <button className="min-w-0 text-left" onClick={() => setSelected(item)}>
                    <div className="flex flex-wrap items-center gap-2">
                      <h3 className="text-label text-text-primary font-semibold">{item.title}</h3>
                      <Status value={item.status} />
                    </div>
                    <p className="text-body-sm text-text-secondary mt-1 break-words">
                      {item.meeting_id} · {prettyDate(item.meeting_date)} at {item.meeting_time} ·{' '}
                      {item.duration_display}
                    </p>
                    <p className="text-caption text-text-secondary mt-1 flex flex-wrap gap-x-3 gap-y-1">
                      <span className="inline-flex items-center gap-1">
                        <MapPin className="size-3.5" />
                        {item.location || item.location_type_display}
                      </span>
                      <span className="inline-flex items-center gap-1">
                        <Users className="size-3.5" />
                        {item.attendee_count} attendees
                      </span>
                    </p>
                  </button>
                  <div className="tablet:justify-end flex flex-wrap gap-2">
                    <Button variant="outline" size="sm" onClick={() => setSelected(item)}>
                      Details
                    </Button>
                    {canUpdate && item.status !== 'cancelled' ? (
                      <Button variant="ghost" size="sm" onClick={() => startEdit(item)}>
                        Edit
                      </Button>
                    ) : null}
                    {canCancel && !['cancelled', 'completed'].includes(item.status) ? (
                      <Button variant="outline" size="sm" onClick={() => setCancelTarget(item)}>
                        Cancel
                      </Button>
                    ) : null}
                  </div>
                </article>
              ))}
            </div>
            <PageControls
              page={search.page}
              count={meetingsQuery.data.count}
              onChange={(page) => change({ page })}
            />
          </Card>
        )}
      </div>
      <Dialog
        open={formOpen}
        onOpenChange={setFormOpen}
        title={editing ? 'Edit meeting' : 'Schedule a meeting'}
        description="Meeting changes are saved to the company calendar."
        size="lg"
        fitContent
        bodyClassName="bg-surface-muted"
        footer={
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setFormOpen(false)}>
              Cancel
            </Button>
            <Button isLoading={saveMutation.isPending} onClick={() => saveMutation.mutate()}>
              {editing ? 'Save changes' : 'Schedule meeting'}
            </Button>
          </div>
        }
      >
        <div className="rounded-control bg-surface space-y-4 p-4">
          <div className="tablet:grid-cols-2 grid gap-3">
            <FormControl
              id="meeting-title"
              label="Meeting title"
              required
              error={fieldErrors.title}
            >
              <TextInput
                value={draft.title}
                onChange={(e) => setDraft({ ...draft, title: e.target.value })}
              />
            </FormControl>
            <DropdownSelect
              label="Project (optional)"
              value={draft.project_id}
              options={[
                { value: '', label: 'Company-wide meeting' },
                ...(projects.data?.items ?? []).map((p) => ({
                  value: String(p.id),
                  label: `${p.short_code} · ${p.name}`,
                })),
                ...(editing?.project_id &&
                !projects.data?.items.some((p) => p.id === editing.project_id)
                  ? [
                      {
                        value: String(editing.project_id),
                        label: `${editing.project_short_code ?? 'Project'} · ${editing.project_name ?? `#${editing.project_id}`}${editing.project_is_archived ? ' · Archived' : ''}`,
                      },
                    ]
                  : []),
              ]}
              onChange={(project_id) => setDraft({ ...draft, project_id })}
              searchable
            />
            <FormControl id="meeting-date" label="Date" required error={fieldErrors.meeting_date}>
              <DatePickerField
                value={draft.meeting_date}
                onValueChange={(meeting_date) => setDraft({ ...draft, meeting_date })}
              />
            </FormControl>
            <FormControl id="meeting-time" label="Time" required error={fieldErrors.meeting_time}>
              <TimePickerField
                value={draft.meeting_time}
                onValueChange={(meeting_time) => setDraft({ ...draft, meeting_time })}
              />
            </FormControl>
            <FormControl
              id="meeting-duration"
              label="Duration (minutes)"
              required
              error={fieldErrors.duration_minutes}
            >
              <TextInput
                type="number"
                min="1"
                step="1"
                value={draft.duration_minutes}
                onChange={(e) => setDraft({ ...draft, duration_minutes: e.target.value })}
              />
            </FormControl>
            <DropdownSelect
              label="Location type"
              value={draft.location_type}
              options={[
                { value: 'physical', label: 'Physical' },
                { value: 'virtual', label: 'Virtual' },
                { value: 'hybrid', label: 'Hybrid' },
              ]}
              onChange={(location_type) => setDraft({ ...draft, location_type })}
            />
            {editing ? (
              <DropdownSelect
                label="Status"
                value={draft.status}
                options={[
                  { value: 'scheduled', label: 'Scheduled' },
                  { value: 'ongoing', label: 'Ongoing' },
                  { value: 'completed', label: 'Completed' },
                  { value: 'postponed', label: 'Postponed' },
                ]}
                onChange={(status) => setDraft({ ...draft, status })}
              />
            ) : null}
            <FormControl id="meeting-location" label="Room, address, or meeting link">
              <TextInput
                value={draft.location}
                onChange={(e) => setDraft({ ...draft, location: e.target.value })}
              />
            </FormControl>
          </div>
          <FormControl id="meeting-agenda" label="Agenda" required error={fieldErrors.agenda}>
            <TextArea
              rows={4}
              value={draft.agenda}
              onChange={(e) => setDraft({ ...draft, agenda: e.target.value })}
            />
          </FormControl>
          <FormControl id="meeting-notes" label="Notes">
            <TextArea
              rows={3}
              value={draft.notes}
              onChange={(e) => setDraft({ ...draft, notes: e.target.value })}
            />
          </FormControl>
          <fieldset className="space-y-2">
            <legend className="text-control-label text-text-secondary font-bold">Attendees</legend>
            {attendees.isPending ? (
              <p className="text-caption text-text-secondary">Loading branch-scoped staff…</p>
            ) : attendees.isError ? (
              <SectionErrorState
                title="Attendees unavailable"
                error={attendees.error}
                onRetry={() => void attendees.refetch()}
              />
            ) : (
              <div className="rounded-control border-border-subtle bg-surface-muted grid max-h-48 gap-2 overflow-y-auto border p-3 min-[700px]:grid-cols-2">
                {(attendees.data ?? []).map((person) => (
                  <label
                    key={person.user_id}
                    className="rounded-control bg-surface text-caption flex min-w-0 items-start gap-2 p-2"
                  >
                    <input
                      className="accent-primary mt-0.5 size-4"
                      type="checkbox"
                      checked={draft.attendee_ids.includes(person.user_id)}
                      onChange={(event) =>
                        setDraft({
                          ...draft,
                          attendee_ids: event.target.checked
                            ? [...draft.attendee_ids, person.user_id]
                            : draft.attendee_ids.filter((id) => id !== person.user_id),
                        })
                      }
                    />
                    <span className="min-w-0">
                      <span className="text-text-primary block truncate font-semibold">
                        {person.name}
                      </span>
                      <span className="text-text-secondary block truncate">
                        {person.employee_id} · {person.email}
                      </span>
                    </span>
                  </label>
                ))}
              </div>
            )}
          </fieldset>
        </div>
      </Dialog>
      <Dialog
        open={Boolean(selected)}
        onOpenChange={(open) => {
          if (!open) setSelected(null)
        }}
        title={selected?.title ?? 'Meeting details'}
        description={selected?.meeting_id}
        size="md"
        fitContent
        bodyClassName="bg-surface-muted"
      >
        {selected ? (
          <div className="space-y-3">
            <Card className="bg-surface">
              <div className="flex flex-wrap items-center justify-between gap-2">
                <Status value={selected.status} />
                <span className="text-caption text-text-secondary">
                  Organized by {selected.organizer_name ?? 'Unknown'}
                </span>
              </div>
              <p className="text-body-sm text-text-primary mt-4">{selected.agenda}</p>
              <div className="mt-4 grid gap-3 min-[480px]:grid-cols-2">
                <p className="rounded-control bg-surface-muted text-caption p-3">
                  {prettyDate(selected.meeting_date)} · {selected.meeting_time}
                </p>
                <p className="rounded-control bg-surface-muted text-caption p-3">
                  {selected.duration_display} · {selected.location_type_display}
                </p>
                <p className="rounded-control bg-surface-muted text-caption p-3">
                  {selected.location || 'Location not specified'}
                </p>
                <p className="rounded-control bg-surface-muted text-caption p-3">
                  {selected.project_id
                    ? `${selected.project_short_code ?? 'Project'} · ${selected.project_name ?? `#${selected.project_id}`}${selected.project_is_archived ? ' · Archived' : ''}`
                    : 'Company-wide meeting'}
                </p>
              </div>
              {selected.notes ? (
                <p className="text-body-sm text-text-secondary mt-3">{selected.notes}</p>
              ) : null}
            </Card>
            <Card className="bg-surface">
              <h3 className="text-label text-text-primary font-semibold">
                Attendees ({selected.attendee_count})
              </h3>
              <ul className="mt-3 space-y-2">
                {selected.attendees.map((person) => (
                  <li key={person.user_id} className="text-body-sm text-text-secondary">
                    {person.full_name} · {person.email}
                  </li>
                ))}
              </ul>
            </Card>
            <div className="flex flex-wrap justify-end gap-2">
              {canUpdate && selected.status !== 'cancelled' ? (
                <Button variant="outline" onClick={() => startEdit(selected)}>
                  Edit meeting
                </Button>
              ) : null}
              {canCancel && !['cancelled', 'completed'].includes(selected.status) ? (
                <Button variant="danger" onClick={() => setCancelTarget(selected)}>
                  Cancel meeting
                </Button>
              ) : null}
            </div>
          </div>
        ) : null}
      </Dialog>
      <Dialog
        open={Boolean(cancelTarget)}
        onOpenChange={(open) => {
          if (!open) setCancelTarget(null)
        }}
        title="Cancel this meeting?"
        description="The meeting will remain in the register with a cancelled status."
        size="sm"
        fitContent
        bodyClassName="bg-surface-muted"
        footer={
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setCancelTarget(null)}>
              Keep meeting
            </Button>
            <Button
              variant="danger"
              isLoading={cancelMutation.isPending}
              onClick={() => cancelTarget && cancelMutation.mutate(cancelTarget)}
            >
              Cancel meeting
            </Button>
          </div>
        }
      >
        <Card className="bg-surface">
          <p className="text-label text-text-primary font-semibold">{cancelTarget?.title}</p>
          <p className="text-caption text-text-secondary mt-1">
            {prettyDate(cancelTarget?.meeting_date)} · {cancelTarget?.meeting_time}
          </p>
        </Card>
      </Dialog>
    </PageLayout>
  )
}
