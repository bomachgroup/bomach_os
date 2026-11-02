import { useEffect, useRef, useState, type DragEvent, type FormEvent } from 'react'
import { useForm } from '@tanstack/react-form'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useParams, useRouterState, useSearch } from '@tanstack/react-router'
import {
  ArrowDown,
  ArrowLeft,
  ArrowRight,
  CheckCircle2,
  Clock3,
  LoaderCircle,
  Paperclip,
  Save,
  Send,
  Upload,
} from 'lucide-react'
import { z } from 'zod'

import { personalOverviewQueryKey } from '@/modules/dashboard/dashboard.api'
import { personalWorkQueryKeys } from '@/modules/dashboard/personal-work.api'
import { ApiError } from '@/shared/api/api-error'
import { presentError } from '@/shared/errors'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { ErrorState, SectionErrorState } from '@/shared/ui/feedback-states'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { FormControl, TextInput } from '@/shared/ui/form-control'
import { CreationFlowActions, CreationFlowStepper } from '@/shared/ui/creation-flow'
import { FormSection } from '@/shared/ui/form-section'
import { PageLayout } from '@/shared/ui/page-layout'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'
import { StatusChip } from '@/shared/ui/status-chip'
import { useToast } from '@/shared/feedback/use-toast'
import { TimePickerField } from '@/shared/ui/time-picker-field'

import { ReportEntryList } from '../components/report-entry-list'
import {
  ReportContentSummary,
  ReportEvidenceList,
  type ReportEvidenceItem,
  ReportOverviewSummary,
} from '../components/report-summary'
import type { WorkReportInput } from '../work-reports.api'
import { workReportsApi } from '../work-reports.api'
import {
  workReportDetailQueryOptions,
  workReportsQueryKeys,
  workspacesQueryOptions,
} from '../work-reports.queries'
import { calculateWorkHours, localDateInputValue } from '../work-report-time'
import type { WorkReportsSearch } from '../work-reports.search'

const steps = [
  'Report details',
  'Work completed',
  'Challenges and next steps',
  'Evidence',
  'Review report',
] as const
const flowSteps = steps.map((label, index) => ({ id: `step-${index + 1}`, label }))
type Step = 0 | 1 | 2 | 3 | 4
type ReportFormValues = {
  day: string
  operationalBase: string
  workActivities: string[]
  taskDetails: string[]
  planNextDay: string[]
}
type FieldErrors = Partial<Record<keyof ReportFormValues | 'timeRange' | 'attachments', string>>

const submitSchema = z.object({
  day: z.string().min(1, 'Choose the date for this report.'),
  workActivities: z
    .array(z.string())
    .refine(
      (items) => items.some((item) => item.trim()),
      'Describe at least one completed activity.',
    ),
})

function parseReportItems(value: string): string[] {
  return value
    .split(/\r?\n/)
    .map((item) => item.trim())
    .filter(Boolean)
}

function serializeReportItems(items: string[]): string {
  return items
    .map((item) => item.trim())
    .filter(Boolean)
    .join('\n')
}

function fieldError(error: unknown): string | null {
  if (error instanceof ApiError) {
    if (error.code === 'WORK_REPORT_ALREADY_EXISTS')
      return 'A report already exists for this date. Open it from your report history.'
    return `${presentError(error, 'form-submit').message} Your entries are still here.`
  }
  return `${presentError(error, 'form-submit').message} Your entries are still here.`
}

function serverFieldErrors(error: unknown): FieldErrors {
  if (!(error instanceof ApiError) || !error.fieldErrors) return {}
  const mapping: Record<string, keyof ReportFormValues | 'timeRange' | 'attachments'> = {
    day: 'day',
    operational_base: 'operationalBase',
    work_activities: 'workActivities',
    task_details: 'taskDetails',
    plan_next_day: 'planNextDay',
    hours_worked: 'timeRange',
    attachments: 'attachments',
  }
  const result: FieldErrors = {}
  for (const [key, value] of Object.entries(error.fieldErrors)) {
    const target = mapping[key]
    if (target) result[target] = Array.isArray(value) ? value[0] : value
  }
  return result
}

function attachmentName(url: string): string {
  try {
    return decodeURIComponent(new URL(url).pathname.split('/').pop() || 'Attachment')
  } catch {
    return 'Attachment'
  }
}

function focusFirstInvalid(formElement: HTMLFormElement | null) {
  formElement?.querySelector<HTMLElement>('[aria-invalid="true"]')?.focus()
}

function timeRangeError(start: string, end: string, isEditing: boolean): string | undefined {
  if (!start && !end)
    return isEditing
      ? undefined
      : 'Choose a valid start and end time before submitting a new report.'
  if (Boolean(start) !== Boolean(end)) return 'Choose both start and end times, or clear both.'
  if (!calculateWorkHours(start, end)) return 'Choose distinct, valid start and end times.'
  return undefined
}

function hoursSummary(value: number, suffix: 'total' | 'currently recorded'): string {
  const formatted = Number.isInteger(value) ? String(value) : value.toFixed(1)
  return `${formatted} ${value === 1 ? 'hour' : 'hours'} ${suffix}`
}

function formatTimeForReview(value: string): string {
  const [hours, minutes] = value.split(':').map(Number)
  if (hours === undefined || minutes === undefined || Number.isNaN(hours + minutes)) return value
  return new Intl.DateTimeFormat(undefined, {
    hour: 'numeric',
    minute: '2-digit',
  }).format(new Date(2000, 0, 1, hours, minutes))
}

function formatFileSize(bytes: number): string {
  return bytes < 1024 * 1024
    ? `${Math.max(1, Math.round(bytes / 1024))} KB`
    : `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}

function WorkReportFormBackLink({
  isEditing,
  reportId,
  search,
}: {
  isEditing: boolean
  reportId?: number
  search: WorkReportsSearch
}) {
  return (
    <Link
      to={isEditing ? '/dashboard/my-reports/$reportId' : '/dashboard/my-reports'}
      params={isEditing && reportId ? { reportId: String(reportId) } : undefined}
      search={search}
      className={pageBackLinkClassName}
    >
      <PageBackLinkContent>{isEditing ? 'Report details' : 'My Work Reports'}</PageBackLinkContent>
    </Link>
  )
}

export function WorkReportFormPage() {
  const params = useParams({ strict: false }) as { reportId?: string }
  const pathname = useRouterState({ select: (state) => state.location.pathname })
  const search = useSearch({ strict: false }) as WorkReportsSearch
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const toast = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const reportId = params.reportId ? Number(params.reportId) : undefined
  const isEditing =
    pathname.endsWith('/edit') && Number.isSafeInteger(reportId) && (reportId ?? 0) > 0
  const canCreate = hasPermission(permissions, 'work_reports', 'create')
  const canUpdate =
    hasPermission(permissions, 'work_reports', 'update_own') ||
    hasPermission(permissions, 'work_reports', 'update')
  const canUseWorkspaces = hasPermission(permissions, 'work_locations', 'list')
  const detailQuery = useQuery({
    ...workReportDetailQueryOptions(userId, employeeId, reportId ?? 0),
    enabled: Boolean(session && isEditing && reportId),
  })
  const workspacesQuery = useQuery({
    ...workspacesQueryOptions(userId, employeeId),
    enabled: Boolean(session && canUseWorkspaces),
  })
  const [step, setStep] = useState<Step>(0)
  const [furthestStep, setFurthestStep] = useState<Step>(0)
  const intentRef = useRef<'draft' | 'submit'>('draft')
  const [formError, setFormError] = useState<string | null>(null)
  const [errors, setErrors] = useState<FieldErrors>({})
  const [startTime, setStartTime] = useState('')
  const [endTime, setEndTime] = useState('')
  const [pendingFiles, setPendingFiles] = useState<File[]>([])
  const [attachments, setAttachments] = useState<string[]>([])
  const [uploadStatus, setUploadStatus] = useState<string | null>(null)
  const [isDraggingFiles, setIsDraggingFiles] = useState(false)
  const formElement = useRef<HTMLFormElement>(null)
  const attachmentsInput = useRef<HTMLInputElement>(null)
  const hydratedReport = useRef<number | null>(null)
  const [storedHours, setStoredHours] = useState(0)

  const defaultValues: ReportFormValues = {
    day: localDateInputValue(),
    operationalBase: '',
    workActivities: [''],
    taskDetails: [],
    planNextDay: [],
  }
  const form = useForm({
    defaultValues,
    onSubmit: async ({ value }) => {
      await saveReport(value)
    },
  })

  useEffect(() => {
    const report = detailQuery.data
    if (!report || hydratedReport.current === report.id) return
    hydratedReport.current = report.id
    const timeout = window.setTimeout(() => {
      const values = {
        day: report.day,
        operationalBase: report.operationalBase ?? '',
        workActivities: parseReportItems(report.workActivities ?? ''),
        taskDetails: parseReportItems(report.taskDetails ?? ''),
        planNextDay: parseReportItems(report.planNextDay ?? ''),
      }
      form.reset(values)
      form.setFieldValue('day', values.day)
      form.setFieldValue('operationalBase', values.operationalBase)
      form.setFieldValue('workActivities', values.workActivities)
      form.setFieldValue('taskDetails', values.taskDetails)
      form.setFieldValue('planNextDay', values.planNextDay)
      setStoredHours(report.hoursWorked)
      setAttachments(report.attachments)
      setFurthestStep(4)
    }, 0)
    return () => window.clearTimeout(timeout)
  }, [detailQuery.data, form])

  const timeHours = calculateWorkHours(startTime, endTime)
  const hoursWorked = timeHours ?? storedHours
  const createMutation = useMutation({ mutationFn: workReportsApi.create })
  const updateMutation = useMutation({
    mutationFn: ({ id, input }: { id: number; input: WorkReportInput }) =>
      workReportsApi.update(id, input),
  })

  async function invalidateAfterSave(report: Awaited<ReturnType<typeof workReportsApi.create>>) {
    queryClient.setQueryData(workReportsQueryKeys.detail(userId, employeeId, report.id), report)
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

  async function uploadPendingFiles(): Promise<string[] | null> {
    const uploaded: string[] = []
    const failedFiles: File[] = []
    for (const [index, file] of pendingFiles.entries()) {
      if (file.size > 15 * 1024 * 1024) {
        setErrors((previous) => ({
          ...previous,
          attachments: `${file.name} is larger than 15 MB.`,
        }))
        failedFiles.push(...pendingFiles.slice(index))
        break
      }
      setUploadStatus(`Uploading ${index + 1} of ${pendingFiles.length}: ${file.name}`)
      try {
        const response = await workReportsApi.upload(file)
        uploaded.push(response.url)
      } catch {
        setFormError(
          `“${file.name}” could not be uploaded. Your report details are preserved; try the upload again.`,
        )
        failedFiles.push(file, ...pendingFiles.slice(index + 1))
        break
      }
    }
    if (uploaded.length) setAttachments((previous) => [...previous, ...uploaded])
    setPendingFiles(failedFiles)
    setUploadStatus(null)
    if (failedFiles.length) return null
    return [...attachments, ...uploaded]
  }

  async function saveReport(value: ReportFormValues) {
    const intent = intentRef.current
    setFormError(null)
    setErrors({})
    const nextErrors: FieldErrors = {}
    if (!value.day) nextErrors.day = 'Choose the date for this report.'
    if (intent === 'submit') {
      const parsed = submitSchema.safeParse(value)
      if (!parsed.success) {
        for (const issue of parsed.error.issues) {
          if (issue.path[0] === 'day') nextErrors.day = issue.message
          if (issue.path[0] === 'workActivities') nextErrors.workActivities = issue.message
        }
      }
      const rangeError = timeRangeError(startTime, endTime, isEditing)
      if (rangeError) nextErrors.timeRange = rangeError
    }
    if (Object.keys(nextErrors).length) {
      setErrors(nextErrors)
      if (nextErrors.day) setStep(0)
      else if (nextErrors.workActivities) setStep(1)
      else setStep(0)
      window.requestAnimationFrame(() => focusFirstInvalid(formElement.current))
      return
    }

    const allAttachments = await uploadPendingFiles()
    if (!allAttachments) return
    const input: WorkReportInput = {
      day: value.day,
      hours_worked: timeHours ?? storedHours,
      operational_base: value.operationalBase.trim(),
      work_activities: serializeReportItems(value.workActivities),
      task_details: serializeReportItems(value.taskDetails),
      plan_next_day: serializeReportItems(value.planNextDay),
      status: intent === 'submit' ? 'submitted' : 'draft',
      attachments: allAttachments,
    }
    try {
      const saved =
        isEditing && reportId
          ? await updateMutation.mutateAsync({ id: reportId, input })
          : await createMutation.mutateAsync(input)
      await invalidateAfterSave(saved)
      toast.showToast({
        title: intent === 'submit' ? 'Report submitted' : 'Draft saved',
        description:
          intent === 'submit'
            ? 'Your work report is now in the review queue.'
            : 'You can return and finish this report later.',
        tone: 'success',
      })
      await navigate({
        to: '/dashboard/my-reports/$reportId',
        params: { reportId: String(saved.id) },
        search,
      })
    } catch (error) {
      setErrors(serverFieldErrors(error))
      setFormError(fieldError(error))
      window.requestAnimationFrame(() => focusFirstInvalid(formElement.current))
    }
  }

  function handleSubmit(event: FormEvent<HTMLFormElement>, nextIntent: 'draft' | 'submit') {
    event.preventDefault()
    intentRef.current = nextIntent
    void form.handleSubmit()
  }

  function updateTimeRange(which: 'start' | 'end', value: string) {
    const nextStart = which === 'start' ? value : startTime
    const nextEnd = which === 'end' ? value : endTime
    if (which === 'start') setStartTime(value)
    else setEndTime(value)
    if (errors.timeRange && !timeRangeError(nextStart, nextEnd, isEditing)) {
      setErrors((previous) => ({ ...previous, timeRange: undefined }))
    }
  }

  function addAttachmentFiles(files: File[]) {
    const acceptedFiles = files.filter((file) => file.size <= 15 * 1024 * 1024)
    const oversizedFiles = files.filter((file) => file.size > 15 * 1024 * 1024)
    if (acceptedFiles.length) {
      setPendingFiles((previous) => [...previous, ...acceptedFiles])
    }
    setErrors((previous) => ({
      ...previous,
      attachments: oversizedFiles.length
        ? `${oversizedFiles.map((file) => file.name).join(', ')} exceed the 15 MB per-file limit.`
        : undefined,
    }))
  }

  function handleEvidenceDrop(event: DragEvent<HTMLDivElement>) {
    event.preventDefault()
    setIsDraggingFiles(false)
    addAttachmentFiles(Array.from(event.dataTransfer.files))
  }

  function continueToNextStep() {
    setFormError(null)
    const nextErrors: FieldErrors = {}
    if (step === 0 && !form.state.values.day) nextErrors.day = 'Choose the date for this report.'
    if (step === 1 && !form.state.values.workActivities.some((item) => item.trim()))
      nextErrors.workActivities = 'Describe at least one completed activity.'
    if (Object.keys(nextErrors).length) {
      setErrors((previous) => ({ ...previous, ...nextErrors }))
      window.requestAnimationFrame(() => focusFirstInvalid(formElement.current))
      return
    }
    if (step === 0) setErrors((previous) => ({ ...previous, day: undefined }))
    if (step === 1) setErrors((previous) => ({ ...previous, workActivities: undefined }))
    const nextStep = Math.min(4, step + 1) as Step
    setStep(nextStep)
    setFurthestStep((previous) => Math.max(previous, nextStep) as Step)
  }

  function goToStep(targetStep: number) {
    if (targetStep > furthestStep) return
    setFormError(null)
    setStep(targetStep as Step)
  }

  const isSaving = createMutation.isPending || updateMutation.isPending || Boolean(uploadStatus)
  const hasSubmittedPermission = canCreate || canUpdate

  if (session && ((!isEditing && !canCreate) || (isEditing && !canUpdate))) {
    return (
      <PageLayout
        title={isEditing ? 'Edit work report' : 'New work report'}
        backLink={
          <WorkReportFormBackLink isEditing={isEditing} reportId={reportId} search={search} />
        }
      >
        <ErrorState
          title="You can’t change this report"
          description="Your account does not have permission to create or update a work report."
        />
      </PageLayout>
    )
  }
  if (isEditing && detailQuery.isPending)
    return (
      <PageLayout
        title="Edit work report"
        backLink={<WorkReportFormBackLink isEditing reportId={reportId} search={search} />}
      >
        <div className="space-y-4" aria-busy="true">
          <Card className="h-40 animate-pulse" />
          <Card className="h-72 animate-pulse" />
        </div>
      </PageLayout>
    )
  if (isEditing && detailQuery.isError && !detailQuery.data)
    return (
      <PageLayout
        title="Edit work report"
        backLink={<WorkReportFormBackLink isEditing reportId={reportId} search={search} />}
      >
        <ErrorState
          title="Report could not load"
          description="The report may have been removed or you may no longer have access."
          error={detailQuery.error}
          action={
            <Button variant="outline" onClick={() => void detailQuery.refetch()}>
              Try again
            </Button>
          }
        />
      </PageLayout>
    )
  if (
    isEditing &&
    detailQuery.data &&
    detailQuery.data.status !== 'draft' &&
    detailQuery.data.status !== 'rejected'
  ) {
    return (
      <PageLayout
        title="Edit work report"
        backLink={<WorkReportFormBackLink isEditing reportId={reportId} search={search} />}
      >
        <ErrorState
          title="This report can’t be edited here"
          description={
            detailQuery.data.status === 'submitted'
              ? 'Withdraw the report from its detail page before making changes.'
              : 'Approved reports are read-only.'
          }
          action={
            <Link
              className="rounded-control border-border-strong bg-surface text-text-primary hover:bg-surface-muted text-label inline-flex min-h-11 items-center border px-4 font-semibold"
              to="/dashboard/my-reports/$reportId"
              params={{ reportId: String(reportId) }}
            >
              View report
            </Link>
          }
        />
      </PageLayout>
    )
  }

  const isBusy = isSaving
  return (
    <PageLayout
      title={isEditing ? 'Edit work report' : 'New work report'}
      backLink={
        <WorkReportFormBackLink isEditing={isEditing} reportId={reportId} search={search} />
      }
      subtitle={
        isEditing
          ? 'Revise your daily record and choose whether to save or resubmit it.'
          : 'Complete a guided daily record. You can save a draft at any step.'
      }
      contentClassName="space-y-0"
    >
      <div className="desktop:grid-cols-[15rem_minmax(0,1fr)] desktop:items-start desktop:gap-6 grid gap-5">
        <CreationFlowStepper
          ariaLabel="Report form"
          steps={flowSteps}
          currentStep={step}
          maxSelectableStep={furthestStep}
          onStepSelect={goToStep}
          variant="responsive"
          headerActionClassName="desktop:hidden"
          headerAction={
            detailQuery.data ? (
              <StatusChip
                dense
                label={
                  detailQuery.data.status === 'rejected'
                    ? 'Needs revision'
                    : detailQuery.data.status === 'draft'
                      ? 'Draft'
                      : detailQuery.data.status
                }
                tone={detailQuery.data.status === 'rejected' ? 'danger' : 'neutral'}
              />
            ) : null
          }
        />

        <div className="min-w-0 space-y-5">
          {detailQuery.isError && detailQuery.data ? (
            <Alert tone="warning" title="Showing the saved report">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <span>
                  The latest refresh failed. Your loaded report and edits are still available.
                </span>
                <Button variant="outline" size="sm" onClick={() => void detailQuery.refetch()}>
                  Retry refresh
                </Button>
              </div>
            </Alert>
          ) : null}
          {detailQuery.data?.status === 'rejected' ? (
            <Alert tone="danger" title="Reviewer feedback">
              {detailQuery.data.feedback || 'This report was returned for revision.'}
            </Alert>
          ) : null}

          <form
            ref={formElement}
            onSubmit={(event) => handleSubmit(event, 'draft')}
            noValidate
            className="space-y-5"
          >
            {formError ? (
              <Alert tone="danger" role="alert" title="Report not saved">
                {formError}
              </Alert>
            ) : null}
            {step === 0 ? (
              <FormSection className="tablet:grid-cols-2 grid gap-4">
                <form.Field name="day">
                  {(field) => (
                    <FormControl id="report-day" label="Report date" required error={errors.day}>
                      <DatePickerField
                        value={field.state.value}
                        onValueChange={(value) => {
                          field.handleChange(value)
                          if (value) setErrors((previous) => ({ ...previous, day: undefined }))
                        }}
                      />
                    </FormControl>
                  )}
                </form.Field>
                <div className="tablet:col-span-2">
                  <p className="text-control-label text-text-secondary mb-2 font-bold">
                    Work hours
                  </p>
                  <div
                    role="group"
                    aria-labelledby="report-time-label"
                    aria-describedby={errors.timeRange ? 'report-time-error' : undefined}
                    className="grid grid-cols-1 items-center gap-2 min-[360px]:grid-cols-[minmax(0,1fr)_1.25rem_minmax(0,1fr)]"
                  >
                    <span id="report-time-label" className="sr-only">
                      Report work hours
                    </span>
                    <FormControl id="report-start-time" label="Start time">
                      <TimePickerField
                        value={startTime}
                        aria-invalid={errors.timeRange ? 'true' : undefined}
                        aria-describedby={errors.timeRange ? 'report-time-error' : undefined}
                        onValueChange={(value) => updateTimeRange('start', value)}
                      />
                    </FormControl>
                    <ArrowRight
                      className="text-text-muted mx-auto hidden size-4 min-[360px]:block"
                      aria-hidden="true"
                    />
                    <ArrowDown
                      className="text-text-muted mx-auto size-4 min-[360px]:hidden"
                      aria-hidden="true"
                    />
                    <FormControl id="report-end-time" label="End time">
                      <TimePickerField
                        value={endTime}
                        aria-invalid={errors.timeRange ? 'true' : undefined}
                        aria-describedby={errors.timeRange ? 'report-time-error' : undefined}
                        onValueChange={(value) => updateTimeRange('end', value)}
                      />
                    </FormControl>
                  </div>
                  <div className="bg-primary-subtle rounded-control mt-2 flex min-h-10 items-center gap-2 px-3 py-2">
                    <Clock3 className="text-primary size-4 shrink-0" aria-hidden="true" />
                    <span className="text-label text-primary">
                      {timeHours !== null
                        ? hoursSummary(timeHours, 'total')
                        : isEditing && !startTime && !endTime
                          ? hoursSummary(storedHours, 'currently recorded')
                          : 'Total hours will appear here'}
                    </span>
                  </div>
                  {errors.timeRange ? (
                    <p
                      id="report-time-error"
                      className="text-body-sm text-danger mt-2"
                      role="status"
                    >
                      {errors.timeRange}
                    </p>
                  ) : null}
                </div>
                <div className="tablet:col-span-2">
                  <form.Field name="operationalBase">
                    {(field) => (
                      <FormControl
                        id="report-operational-base"
                        label="Operational base"
                        description="Select or enter the office, site, or work location for this day."
                      >
                        <TextInput
                          list="work-report-workspaces"
                          value={field.state.value}
                          onBlur={field.handleBlur}
                          onChange={(event) => field.handleChange(event.currentTarget.value)}
                          placeholder="Choose or enter a work location"
                        />
                      </FormControl>
                    )}
                  </form.Field>
                  <datalist id="work-report-workspaces">
                    {workspacesQuery.data?.map((workspace, index) => (
                      <option
                        key={`${workspace.id ?? workspace.name}-${index}`}
                        value={workspace.name}
                      >
                        {workspace.branchName || ''}
                      </option>
                    ))}
                  </datalist>
                  {canUseWorkspaces && workspacesQuery.isError && !workspacesQuery.data ? (
                    <SectionErrorState
                      className="mt-3"
                      description="Saved work locations could not load. You can still type the operational base."
                      error={workspacesQuery.error}
                      onRetry={() => void workspacesQuery.refetch()}
                    />
                  ) : null}
                  {canUseWorkspaces && workspacesQuery.isError && workspacesQuery.data ? (
                    <Alert tone="warning" className="mt-3" title="Using saved locations">
                      <div className="flex flex-wrap items-center justify-between gap-3">
                        <span>
                          The location list could not refresh. Your saved options remain available.
                        </span>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => void workspacesQuery.refetch()}
                        >
                          Retry
                        </Button>
                      </div>
                    </Alert>
                  ) : null}
                </div>
              </FormSection>
            ) : null}
            {step === 1 ? (
              <FormSection className="space-y-4">
                <form.Field name="workActivities">
                  {(field) => (
                    <ReportEntryList
                      id="report-activities"
                      label="Work completed"
                      itemLabel="Activity"
                      description="Add the tasks, milestones, and outcomes you completed today."
                      placeholder="Describe a task or result"
                      entries={field.state.value}
                      onChange={(value) => {
                        field.handleChange(value)
                        if (errors.workActivities && value.some((item) => item.trim()))
                          setErrors((previous) => ({ ...previous, workActivities: undefined }))
                      }}
                      required
                      error={errors.workActivities}
                    />
                  )}
                </form.Field>
              </FormSection>
            ) : null}
            {step === 2 ? (
              <div className="desktop:grid-cols-2 grid items-start gap-4">
                <FormSection className="space-y-4">
                  <form.Field name="taskDetails">
                    {(field) => (
                      <ReportEntryList
                        id="report-challenges-next"
                        label="Challenges and blockers"
                        itemLabel="Challenge"
                        description="Record blockers or issues that need follow-up."
                        placeholder="Describe a blocker, if any"
                        entries={field.state.value}
                        onChange={field.handleChange}
                      />
                    )}
                  </form.Field>
                </FormSection>
                <FormSection className="space-y-4">
                  <form.Field name="planNextDay">
                    {(field) => (
                      <ReportEntryList
                        id="report-next-day"
                        label="Next workday"
                        itemLabel="Next step"
                        description="Capture your next task or priority."
                        placeholder="What will you work on next?"
                        entries={field.state.value}
                        onChange={field.handleChange}
                      />
                    )}
                  </form.Field>
                </FormSection>
              </div>
            ) : null}
            {step === 3 ? (
              <FormSection className="space-y-5">
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <div className="flex min-w-0 items-start gap-3">
                    <span className="text-primary bg-primary-subtle rounded-surface flex size-10 shrink-0 items-center justify-center">
                      <Paperclip className="size-5" aria-hidden="true" />
                    </span>
                    <div>
                      <h3 className="text-h3 text-text-primary font-semibold">
                        Supporting evidence
                      </h3>
                      <p className="text-body-sm text-text-secondary mt-1">
                        Add photos, documents, audio, or video. Maximum 15 MB per file.
                      </p>
                    </div>
                  </div>
                  <span className="text-caption text-text-secondary bg-surface-muted rounded-pill px-3 py-1.5">
                    {attachments.length + pendingFiles.length} files
                  </span>
                </div>

                <input
                  ref={attachmentsInput}
                  id="report-attachments"
                  aria-label="Supporting evidence files"
                  type="file"
                  multiple
                  className="sr-only"
                  tabIndex={-1}
                  onChange={(event) => {
                    addAttachmentFiles(Array.from(event.currentTarget.files ?? []))
                    event.currentTarget.value = ''
                  }}
                />
                <div
                  className={`grid items-start gap-4 ${pendingFiles.length + attachments.length > 0 ? 'desktop:grid-cols-[minmax(0,0.85fr)_minmax(0,1.15fr)]' : 'grid-cols-1'}`}
                >
                  <div
                    onDragEnter={(event) => {
                      event.preventDefault()
                      setIsDraggingFiles(true)
                    }}
                    onDragOver={(event) => event.preventDefault()}
                    onDragLeave={(event) => {
                      if (!event.currentTarget.contains(event.relatedTarget as Node | null))
                        setIsDraggingFiles(false)
                    }}
                    onDrop={handleEvidenceDrop}
                    className={`rounded-surface flex min-h-52 flex-col items-center justify-center border-2 border-dashed px-5 py-6 text-center transition-colors ${isDraggingFiles ? 'border-primary bg-primary-subtle/60' : 'border-border-strong bg-surface-muted/50'}`}
                  >
                    <span className="text-primary bg-primary-subtle rounded-surface mb-3 flex size-12 items-center justify-center">
                      <Upload className="size-5" aria-hidden="true" />
                    </span>
                    <p className="text-label text-text-primary font-semibold">
                      Add files to this report
                    </p>
                    <p className="text-caption text-text-secondary mt-1 max-w-xs">
                      Drop files here or select them from your device.
                    </p>
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      className="mt-4"
                      aria-describedby={errors.attachments ? 'report-attachments-error' : undefined}
                      aria-invalid={errors.attachments ? 'true' : undefined}
                      leadingIcon={<Paperclip className="size-4" aria-hidden="true" />}
                      onClick={() => attachmentsInput.current?.click()}
                    >
                      Choose files
                    </Button>
                  </div>

                  <div className="min-w-0 space-y-3">
                    {uploadStatus ? (
                      <div
                        role="status"
                        aria-live="polite"
                        className="bg-primary-subtle text-primary rounded-control flex items-center gap-2.5 px-3 py-2.5"
                      >
                        <LoaderCircle className="size-4 shrink-0 animate-spin" aria-hidden="true" />
                        <span className="text-body-sm min-w-0">{uploadStatus}</span>
                      </div>
                    ) : null}
                    {errors.attachments ? (
                      <p
                        id="report-attachments-error"
                        className="text-body-sm text-danger"
                        role="status"
                      >
                        {errors.attachments}
                      </p>
                    ) : null}
                    {pendingFiles.length > 0 || attachments.length > 0 ? (
                      <div className="space-y-2">
                        <div className="flex items-center justify-between gap-3">
                          <h4 className="text-label text-text-primary font-semibold">
                            Selected files
                          </h4>
                          <span className="text-caption text-text-secondary">
                            {attachments.length + pendingFiles.length}
                          </span>
                        </div>
                        <ReportEvidenceList
                          items={[
                            ...pendingFiles.map((file, index): ReportEvidenceItem => ({
                              id: `pending-${index}`,
                              name: file.name,
                              detail: formatFileSize(file.size),
                              mediaType: file.type,
                              status: uploadStatus?.includes(file.name) ? 'uploading' : 'ready',
                            })),
                            ...attachments.map((url, index): ReportEvidenceItem => ({
                              id: `attached-${index}`,
                              name: attachmentName(url),
                              detail: 'Saved attachment',
                              href: url,
                              status: 'attached',
                            })),
                          ]}
                          onRemove={(id) => {
                            if (id.startsWith('pending-')) {
                              const index = Number(id.slice('pending-'.length))
                              setPendingFiles((previous) =>
                                previous.filter((_, itemIndex) => itemIndex !== index),
                              )
                            } else if (id.startsWith('attached-')) {
                              const index = Number(id.slice('attached-'.length))
                              setAttachments((previous) =>
                                previous.filter((_, itemIndex) => itemIndex !== index),
                              )
                            }
                          }}
                        />
                      </div>
                    ) : null}
                  </div>
                </div>
              </FormSection>
            ) : null}
            {step === 4 ? (
              <div className="space-y-4">
                <ReportOverviewSummary
                  day={form.state.values.day}
                  hoursWorked={hoursWorked}
                  operationalBase={form.state.values.operationalBase}
                  workTimeRange={
                    startTime && endTime
                      ? `${formatTimeForReview(startTime)}–${formatTimeForReview(endTime)}`
                      : undefined
                  }
                  onEdit={() => setStep(0)}
                />
                <ReportContentSummary
                  workActivities={serializeReportItems(form.state.values.workActivities)}
                  taskDetails={serializeReportItems(form.state.values.taskDetails)}
                  planNextDay={serializeReportItems(form.state.values.planNextDay)}
                  onEditActivities={() => setStep(1)}
                  onEditFollowUps={() => setStep(2)}
                />
                {attachments.length || pendingFiles.length ? (
                  <FormSection className="space-y-3">
                    <div className="flex flex-wrap items-center justify-between gap-3">
                      <div className="flex items-center gap-2.5">
                        <span className="text-primary bg-primary-subtle rounded-control flex size-9 items-center justify-center">
                          <Paperclip className="size-4" aria-hidden="true" />
                        </span>
                        <h3 className="text-label text-text-primary font-semibold">
                          Supporting evidence
                        </h3>
                      </div>
                      <Button
                        type="button"
                        variant="ghost"
                        size="sm"
                        leadingIcon={<CheckCircle2 className="size-4" aria-hidden="true" />}
                        onClick={() => setStep(3)}
                      >
                        Edit files
                      </Button>
                    </div>
                    <ReportEvidenceList
                      items={[
                        ...pendingFiles.map((file, index): ReportEvidenceItem => ({
                          id: `review-pending-${index}`,
                          name: file.name,
                          detail: formatFileSize(file.size),
                          mediaType: file.type,
                          status: 'ready',
                        })),
                        ...attachments.map((url, index): ReportEvidenceItem => ({
                          id: `review-attached-${index}`,
                          name: attachmentName(url),
                          detail: 'Saved attachment',
                          href: url,
                          status: 'attached',
                        })),
                      ]}
                    />
                  </FormSection>
                ) : null}
              </div>
            ) : null}

            <CreationFlowActions
              className="bg-surface border-border-subtle rounded-control shadow-elevation-sm tablet:p-4 border p-3"
              leading={
                <Button
                  variant="outline"
                  type="button"
                  disabled={step === 0 || isBusy}
                  onClick={() => setStep((previous) => Math.max(0, previous - 1) as Step)}
                  leadingIcon={<ArrowLeft className="size-4" />}
                >
                  Previous
                </Button>
              }
            >
              <Button
                variant="secondary"
                type="button"
                isLoading={isBusy}
                disabled={isBusy}
                onClick={(event) => {
                  intentRef.current = 'draft'
                  void form.handleSubmit()
                  event.currentTarget.blur()
                }}
                leadingIcon={<Save className="size-4" />}
              >
                Save draft
              </Button>
              {step < 4 ? (
                <Button
                  type="button"
                  disabled={isBusy}
                  onClick={continueToNextStep}
                  leadingIcon={<ArrowRight className="size-4" />}
                >
                  Continue
                </Button>
              ) : (
                <Button
                  type="button"
                  isLoading={isBusy}
                  disabled={!hasSubmittedPermission}
                  onClick={(event) => {
                    intentRef.current = 'submit'
                    void form.handleSubmit()
                    event.currentTarget.blur()
                  }}
                  leadingIcon={<Send className="size-4" />}
                >
                  {detailQuery.data?.status === 'rejected'
                    ? 'Resubmit for review'
                    : 'Submit for review'}
                </Button>
              )}
            </CreationFlowActions>
          </form>
        </div>
      </div>
    </PageLayout>
  )
}
