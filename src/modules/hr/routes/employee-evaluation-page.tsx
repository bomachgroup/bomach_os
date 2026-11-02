import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  CalendarDays,
  CheckCircle2,
  ClipboardCheck,
  MessageSquareText,
  UserRound,
} from 'lucide-react'
import { useState, type FormEvent } from 'react'

import { employeesQueryKeys, type EmployeeScorecardDto } from '@/modules/hr/employees.api'
import {
  performanceAnalyticsApi,
  type EmployeeEvaluation,
  type EmployeeEvaluationUpdateInput,
} from '@/modules/hr/performance-analytics.api'
import {
  employeeEvaluationDetailOptions,
  employeeEvaluationListOptions,
  performanceAnalyticsQueryKeys,
  performanceEmployeeChoicesOptions,
  performanceScorecardOptions,
  type PerformanceEmployeeChoice,
} from '@/modules/hr/performance-analytics.queries'
import { type EvaluationSearch } from '@/modules/hr/performance-analytics.search'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { useToast } from '@/shared/feedback/use-toast'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { ProgressBar } from '@/shared/ui/progress-bar'
import { StatusChip } from '@/shared/ui/status-chip'

const MONTH_OPTIONS: DropdownSelectOption[] = Array.from({ length: 12 }, (_, index) => ({
  value: String(index + 1),
  label: new Intl.DateTimeFormat(undefined, { month: 'long' }).format(new Date(2024, index, 1)),
}))

function yearOptions(): DropdownSelectOption[] {
  const currentYear = new Date().getFullYear()
  return Array.from({ length: 5 }, (_, index) => {
    const year = currentYear - 2 + index
    return { value: String(year), label: String(year) }
  })
}

function periodLabel(month: number, year: number): string {
  return new Intl.DateTimeFormat(undefined, { month: 'long', year: 'numeric' }).format(
    new Date(year, month - 1, 1),
  )
}

function numeric(value: number | string | null | undefined): number | null {
  if (value == null) return null
  const parsed = Number(value)
  return Number.isFinite(parsed) ? parsed : null
}

function employeeLabel(employee: PerformanceEmployeeChoice): string {
  return `${employee.fullName || employee.employeeCode} · ${employee.employeeCode}`
}

function scorecardMetrics(scorecard: EmployeeScorecardDto) {
  return [
    ['Attendance', scorecard.attendance_score],
    ['Task delivery', scorecard.task_delivery_score],
    ['Report accuracy', scorecard.report_accuracy_score],
    ['Brand contribution', scorecard.brand_contribution_score],
    ['Training progress', scorecard.training_progress_score],
  ] as const
}

function ScorecardPanel({ scorecard }: { scorecard: EmployeeScorecardDto }) {
  const metrics = scorecardMetrics(scorecard)
  const overall = numeric(scorecard.overall_score) ?? 0
  const achievement = numeric(scorecard.target_achievement) ?? 0
  const target = numeric(scorecard.target_score) ?? 0
  return (
    <Card className="tablet:p-5 space-y-4 p-4">
      <div className="flex min-w-0 flex-wrap items-start justify-between gap-3">
        <div>
          <p className="text-overline text-primary font-semibold">Performance context</p>
          <h2 className="text-h3 text-text-primary mt-1 font-semibold">Scorecard results</h2>
          <p className="text-caption text-text-secondary mt-1">
            Recorded measures for {periodLabel(scorecard.month, scorecard.year)}.
          </p>
        </div>
        <StatusChip
          label={scorecard.ranking == null ? 'Not ranked' : `Rank #${scorecard.ranking}`}
          tone="primary"
        />
      </div>
      <div className="tablet:grid-cols-3 grid gap-3 min-[420px]:grid-cols-2">
        <div className="from-primary-subtle/70 via-surface-muted to-surface border-primary/20 tablet:col-span-1 rounded-control border bg-gradient-to-br p-4 min-[420px]:col-span-2">
          <div className="flex min-w-0 items-center justify-between gap-4">
            <div className="min-w-0">
              <p className="text-overline text-text-secondary font-semibold">Overall score</p>
              <p className="text-h1 text-text-primary mt-1 font-semibold tracking-tight tabular-nums">
                {overall.toFixed(1)}%
              </p>
            </div>
            <div className="border-primary/15 bg-surface/80 text-primary rounded-control flex size-12 shrink-0 items-center justify-center border">
              <ClipboardCheck className="size-5" aria-hidden="true" />
            </div>
          </div>
        </div>
        <div className="bg-surface-muted/70 border-border-subtle rounded-control min-w-0 border p-4">
          <p className="text-overline text-text-secondary font-semibold">Target achievement</p>
          <p className="text-h2 text-text-primary mt-2 font-semibold tabular-nums">
            {achievement.toFixed(1)}%
          </p>
        </div>
        <div className="bg-surface-muted/70 border-border-subtle rounded-control min-w-0 border p-4">
          <p className="text-overline text-text-secondary font-semibold">Target score</p>
          <p className="text-h2 text-text-primary mt-2 font-semibold tabular-nums">
            {target.toFixed(1)}%
          </p>
        </div>
      </div>
      <div className="tablet:grid-cols-2 tablet:divide-y-0 grid gap-x-6 divide-y">
        {metrics.map(([label, rawValue]) => {
          const value = numeric(rawValue) ?? 0
          return (
            <div
              key={label}
              className="border-border-subtle tablet:first:border-t-0 min-w-0 border-t py-3 first:border-t-0"
            >
              <div className="flex items-center justify-between gap-3">
                <span className="text-caption text-text-primary font-medium">{label}</span>
                <span className="text-caption text-text-secondary tabular-nums">
                  {value.toFixed(1)}%
                </span>
              </div>
              <ProgressBar
                value={Math.max(0, Math.min(100, value))}
                label={`${label}: ${value.toFixed(1)} percent`}
                className="mt-2 h-1.5"
              />
            </div>
          )
        })}
      </div>
    </Card>
  )
}

type EvaluationDraft = EmployeeEvaluationUpdateInput

function draftFromEvaluation(evaluation: EmployeeEvaluation | null): EvaluationDraft {
  return {
    manager_comments: evaluation?.managerComments ?? '',
    promotion_required: evaluation?.promotionRequired ?? false,
    training_required: evaluation?.trainingRequired ?? false,
    salary_increase: evaluation?.salaryIncrease ?? false,
  }
}

function RecommendationToggle({
  id,
  label,
  description,
  checked,
  disabled,
  onChange,
}: {
  id: string
  label: string
  description: string
  checked: boolean
  disabled: boolean
  onChange: (checked: boolean) => void
}) {
  return (
    <label
      htmlFor={id}
      className="border-border-subtle bg-surface-muted/70 rounded-control has-[:focus-visible]:shadow-focus-ring has-[:checked]:border-primary/30 has-[:checked]:bg-primary-subtle/50 flex min-w-0 cursor-pointer items-start gap-3 border p-3 transition-colors has-[:disabled]:cursor-not-allowed"
    >
      <input
        id={id}
        type="checkbox"
        checked={checked}
        disabled={disabled}
        onChange={(event) => onChange(event.currentTarget.checked)}
        className="border-border-strong text-primary focus-visible:shadow-focus-ring accent-primary mt-0.5 size-4 shrink-0 rounded"
      />
      <span className="min-w-0">
        <span className="text-body-sm text-text-primary block font-semibold">{label}</span>
        <span className="text-overline text-text-secondary mt-0.5 block leading-relaxed">
          {description}
        </span>
      </span>
    </label>
  )
}

function EvaluationEditor({
  evaluation,
  employeeName,
  month,
  year,
  canUpdate,
  canCreate,
  isSaving,
  submitError,
  onSave,
}: {
  evaluation: EmployeeEvaluation | null
  employeeName: string
  month: number
  year: number
  canUpdate: boolean
  canCreate: boolean
  isSaving: boolean
  submitError: string
  onSave: (draft: EvaluationDraft) => Promise<unknown>
}) {
  const [draft, setDraft] = useState(() => draftFromEvaluation(evaluation))
  const [commentsError, setCommentsError] = useState('')
  const [isOpen, setIsOpen] = useState(false)
  const isEditing = evaluation !== null
  const canEdit = isEditing ? canUpdate : canCreate
  const update = <K extends keyof EvaluationDraft>(key: K, value: EvaluationDraft[K]) => {
    setDraft((current) => ({ ...current, [key]: value }))
    setCommentsError('')
  }

  const submit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    if (!canEdit) return
    if (!draft.manager_comments.trim()) {
      setCommentsError('Add the manager’s comments before saving this evaluation.')
      requestAnimationFrame(() => document.getElementById('evaluation-comments')?.focus())
      return
    }
    setCommentsError('')
    void onSave({ ...draft, manager_comments: draft.manager_comments.trim() })
      .then(() => setIsOpen(false))
      .catch(() => undefined)
  }

  return (
    <>
      <Card className="tablet:flex-row tablet:items-center tablet:justify-between flex min-w-0 flex-col gap-4 p-4">
        <div className="flex min-w-0 items-start gap-3">
          <span className="bg-primary-subtle text-primary mt-0.5 flex size-10 shrink-0 items-center justify-center rounded-xl">
            <MessageSquareText className="size-5" aria-hidden="true" />
          </span>
          <div className="min-w-0">
            <div className="flex flex-wrap items-center gap-2">
              <h2 className="text-label text-text-primary font-semibold">Manager assessment</h2>
              <StatusChip
                label={isEditing ? 'Saved' : 'Not recorded'}
                tone={isEditing ? 'success' : 'neutral'}
              />
            </div>
            <p className="text-caption text-text-secondary mt-1">
              {isEditing
                ? `Review and update feedback for ${periodLabel(month, year)}.`
                : `Record feedback and recommended follow-up for ${periodLabel(month, year)}.`}
            </p>
          </div>
        </div>
        <Button
          variant={canEdit ? 'primary' : 'outline'}
          leadingIcon={<MessageSquareText className="size-4" aria-hidden="true" />}
          onClick={() => setIsOpen(true)}
          className="phone:w-auto w-full shrink-0"
        >
          {isEditing ? (canEdit ? 'Edit assessment' : 'View assessment') : 'Add assessment'}
        </Button>
      </Card>

      <Dialog
        open={isOpen}
        onOpenChange={setIsOpen}
        title={isEditing && canEdit ? 'Edit manager assessment' : 'Manager assessment'}
        description={`${employeeName} · ${periodLabel(month, year)}`}
        size="lg"
        fitContent
        compactOnMobile
        dismissDisabled={isSaving}
        footer={
          <>
            <Button variant="outline" disabled={isSaving} onClick={() => setIsOpen(false)}>
              {canEdit ? 'Cancel' : 'Close'}
            </Button>
            {canEdit ? (
              <Button type="submit" form="employee-evaluation-form" isLoading={isSaving}>
                {isEditing ? 'Save changes' : 'Submit evaluation'}
              </Button>
            ) : null}
          </>
        }
      >
        <form id="employee-evaluation-form" onSubmit={submit} className="space-y-5" noValidate>
          {isEditing ? (
            <div className="bg-surface-muted/70 rounded-control flex flex-wrap items-center justify-between gap-2 px-3 py-2.5">
              <p className="text-caption text-text-secondary">
                Feedback and recommendations saved for this review period.
              </p>
              <StatusChip label="Saved evaluation" tone="success" />
            </div>
          ) : (
            <p className="text-caption text-text-secondary">
              Share specific feedback for this period. Recommendations are recorded for HR follow-up
              and do not trigger payroll or role changes.
            </p>
          )}

          {submitError ? (
            <Alert tone="danger" role="status" title="Evaluation was not saved">
              {submitError}
            </Alert>
          ) : null}

          <FormControl
            id="evaluation-comments"
            label="Manager’s comments"
            description="Record clear, specific feedback for this review period."
            error={commentsError}
            required
          >
            <TextArea
              value={draft.manager_comments}
              onChange={(event) => update('manager_comments', event.currentTarget.value)}
              placeholder="Add the manager’s assessment and context…"
              rows={4}
              maxLength={5000}
              disabled={!canEdit || isSaving}
              aria-label="Manager’s comments"
            />
          </FormControl>

          <fieldset disabled={!canEdit || isSaving} className="min-w-0 space-y-3">
            <legend className="text-label text-text-primary font-semibold">
              Recommended follow-up
            </legend>
            <p className="text-caption text-text-secondary -mt-1">
              Select any items for a separate HR review.
            </p>
            <div className="tablet:grid-cols-3 grid gap-2">
              <RecommendationToggle
                id="evaluation-promotion"
                label="Promotion review"
                description="Review role progression."
                checked={draft.promotion_required}
                disabled={!canEdit || isSaving}
                onChange={(value) => update('promotion_required', value)}
              />
              <RecommendationToggle
                id="evaluation-training"
                label="Training required"
                description="Identify a learning need."
                checked={draft.training_required}
                disabled={!canEdit || isSaving}
                onChange={(value) => update('training_required', value)}
              />
              <RecommendationToggle
                id="evaluation-salary"
                label="Salary review"
                description="Flag for compensation review."
                checked={draft.salary_increase}
                disabled={!canEdit || isSaving}
                onChange={(value) => update('salary_increase', value)}
              />
            </div>
          </fieldset>

          {!canEdit ? (
            <p className="text-caption text-text-secondary">
              This evaluation is read-only for your role.
            </p>
          ) : null}
        </form>
      </Dialog>
    </>
  )
}

export function EmployeeEvaluationPage() {
  const search = useSearch({ from: '/_protected/hr/employee-evaluation' }) as EvaluationSearch
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const permissions = session?.permissions ?? {}
  const userId = session?.user.id ?? 0
  const employeeKey = session?.employee.employee_id ?? ''
  const employeeRecordId = session?.employee.id
  const canSelectEmployee = hasPermission(permissions, 'employees', 'list')
  const canList =
    hasPermission(permissions, 'employee_evaluations', 'list') ||
    hasPermission(permissions, 'employee_evaluations', 'list_own')
  const canCreate = hasPermission(permissions, 'employee_evaluations', 'create')
  const canUpdate = hasPermission(permissions, 'employee_evaluations', 'update')
  const canView = hasPermission(permissions, 'employee_evaluations', 'view')
  const canViewOwn = hasPermission(permissions, 'employee_evaluations', 'view_own')
  const selectedEmployeeId = canSelectEmployee ? search.employee_id : employeeRecordId
  const mayViewSelected = canView || (canViewOwn && selectedEmployeeId === employeeRecordId)

  const employeeChoicesQuery = useQuery({
    ...performanceEmployeeChoicesOptions(userId, employeeKey),
    enabled: Boolean(session && canSelectEmployee),
  })
  const evaluationsQuery = useQuery({
    ...employeeEvaluationListOptions(
      userId,
      employeeKey,
      selectedEmployeeId ?? 0,
      search.month,
      search.year,
    ),
    enabled: Boolean(session && canList && selectedEmployeeId),
  })
  const evaluationSummary = evaluationsQuery.data?.find(
    (evaluation) => evaluation.evaluatorId === employeeRecordId,
  )
  const evaluationDetailQuery = useQuery({
    ...employeeEvaluationDetailOptions(userId, employeeKey, evaluationSummary?.id ?? 0),
    enabled: Boolean(session && evaluationSummary && mayViewSelected),
  })
  const canViewScorecard =
    hasPermission(permissions, 'monthly_scorecards', 'view') ||
    (hasPermission(permissions, 'monthly_scorecards', 'view_own') &&
      selectedEmployeeId === employeeRecordId)
  const scorecardQuery = useQuery({
    ...performanceScorecardOptions(
      userId,
      employeeKey,
      selectedEmployeeId ?? 0,
      search.month,
      search.year,
    ),
    enabled: Boolean(session && selectedEmployeeId && canViewScorecard),
  })
  const [submitError, setSubmitError] = useState('')

  const updateSearch = (updates: Partial<EvaluationSearch>) =>
    void navigate({
      to: '/hr/employee-evaluation',
      search: (previous: EvaluationSearch) => ({ ...previous, ...updates }),
      resetScroll: false,
    })

  const saveMutation = useMutation({
    mutationFn: ({
      existing,
      draft,
    }: {
      existing: EmployeeEvaluation | null
      draft: EmployeeEvaluationUpdateInput
    }) => {
      if (!session || !selectedEmployeeId || !employeeRecordId) {
        throw new Error('The employee and evaluator records are required to save an evaluation.')
      }
      if (existing) return performanceAnalyticsApi.evaluations.update(existing.id, draft)
      return performanceAnalyticsApi.evaluations.create({
        employee_id: selectedEmployeeId,
        evaluator_id: employeeRecordId,
        month: search.month,
        year: search.year,
        ...draft,
      })
    },
    onSuccess: async (evaluation) => {
      setSubmitError('')
      queryClient.setQueryData(
        performanceAnalyticsQueryKeys.evaluation(userId, employeeKey, evaluation.id),
        evaluation,
      )
      if (selectedEmployeeId) {
        await queryClient.invalidateQueries({
          queryKey: performanceAnalyticsQueryKeys.evaluations(
            userId,
            employeeKey,
            selectedEmployeeId,
            search.month,
            search.year,
          ),
        })
        await queryClient.invalidateQueries({
          queryKey: employeesQueryKeys.scorecard(
            userId,
            employeeKey,
            selectedEmployeeId,
            search.month,
            search.year,
          ),
        })
      }
      showToast({
        tone: 'success',
        title:
          evaluation.id === evaluationSummary?.id ? 'Evaluation updated' : 'Evaluation submitted',
        description: `${evaluation.employeeName?.trim() || 'Employee'}’s ${periodLabel(evaluation.month, evaluation.year)} evaluation was saved.`,
      })
    },
    onError: (error) => setSubmitError(presentError(error, 'form-submit').message),
  })

  if (sessionQuery.isError) {
    return (
      <PageLayout title="Employee Evaluation">
        <ErrorState
          title="Your HR session could not be loaded"
          description="Retry loading your employee profile and evaluation access."
          error={sessionQuery.error}
          action={<Button onClick={() => void sessionQuery.refetch()}>Try again</Button>}
        />
      </PageLayout>
    )
  }

  if (session && !canList && !canCreate) {
    return (
      <PageLayout title="Employee Evaluation">
        <ErrorState
          title="You can’t access employee evaluations"
          description="Your role does not have permission to view or create employee evaluations."
        />
      </PageLayout>
    )
  }

  const employeeChoices = employeeChoicesQuery.data ?? []
  const selectedEmployee = employeeChoices.find((employee) => employee.id === selectedEmployeeId)
  const ownEmployee = session?.employee
  const employeeName =
    selectedEmployee?.fullName ||
    (selectedEmployeeId === employeeRecordId
      ? [ownEmployee?.first_name, ownEmployee?.middle_name, ownEmployee?.last_name]
          .filter(Boolean)
          .join(' ')
      : '') ||
    'Selected employee'
  const employeeOptions = employeeChoices
    .filter((employee) => employee.id !== employeeRecordId)
    .map((employee) => ({ value: String(employee.id), label: employeeLabel(employee) }))
  const evaluation = evaluationDetailQuery.data ?? null
  const selfSelected = Boolean(selectedEmployeeId && selectedEmployeeId === employeeRecordId)
  const updatePeriodLabel = periodLabel(search.month, search.year)

  return (
    <PageLayout
      title="Employee Evaluation"
      subtitle="Review monthly scorecards and record a manager assessment."
      leading={<ClipboardCheck className="size-5" aria-hidden="true" />}
    >
      <div className="space-y-5">
        <Card className="tablet:flex-row tablet:items-end tablet:justify-between flex min-w-0 flex-col gap-4 p-4">
          <div className="min-w-0">
            <p className="text-overline text-primary font-semibold">Review setup</p>
            <h2 className="text-h3 text-text-primary mt-1 font-semibold">{updatePeriodLabel}</h2>
            <p className="text-caption text-text-secondary mt-1">
              Choose the employee and period before recording feedback.
            </p>
          </div>
          <div className="phone:grid-cols-2 tablet:max-w-md grid w-full gap-3">
            {canSelectEmployee ? (
              <FormControl
                id="evaluation-employee"
                label="Employee"
                className="phone:col-span-2 min-w-0"
              >
                <DropdownSelect
                  value={selectedEmployeeId ? String(selectedEmployeeId) : ''}
                  options={employeeOptions}
                  onChange={(value) => {
                    setSubmitError('')
                    updateSearch({ employee_id: value ? Number(value) : undefined })
                  }}
                  placeholder="Select an employee"
                  searchable
                  searchPlaceholder="Search employee name or code"
                  emptyMessage="No employees available for evaluation."
                  aria-label="Select employee to evaluate"
                />
              </FormControl>
            ) : (
              <div className="bg-surface-muted text-caption text-text-secondary phone:col-span-2 rounded-control flex min-h-11 items-center gap-2 px-3">
                <UserRound className="size-4 shrink-0" aria-hidden="true" />
                Evaluations addressed to your employee record
              </div>
            )}
            <FormControl id="evaluation-month" label="Month" className="min-w-0">
              <DropdownSelect
                value={String(search.month)}
                options={MONTH_OPTIONS}
                onChange={(value) => {
                  setSubmitError('')
                  updateSearch({ month: Number(value) })
                }}
                aria-label="Select evaluation month"
              />
            </FormControl>
            <FormControl id="evaluation-year" label="Year" className="min-w-0">
              <DropdownSelect
                value={String(search.year)}
                options={yearOptions()}
                onChange={(value) => {
                  setSubmitError('')
                  updateSearch({ year: Number(value) })
                }}
                aria-label="Select evaluation year"
              />
            </FormControl>
          </div>
        </Card>

        {canSelectEmployee && employeeChoicesQuery.isError ? (
          <SectionErrorState
            title="Employee list could not be loaded"
            description="Retry to choose an employee within your permitted scope."
            error={employeeChoicesQuery.error}
            onRetry={() => void employeeChoicesQuery.refetch()}
          />
        ) : null}

        {canSelectEmployee && employeeChoicesQuery.isPending ? (
          <Skeleton className="h-24 w-full" aria-label="Loading employee choices" />
        ) : null}

        {!selectedEmployeeId ? (
          <Card>
            <EmptyState
              icon={<UserRound className="size-6" aria-hidden="true" />}
              title="Select an employee to begin"
              description="Choose a colleague and review period to see available scorecard data and evaluation history."
            />
          </Card>
        ) : selfSelected && canCreate ? (
          <Card>
            <EmptyState
              icon={<CheckCircle2 className="size-6" aria-hidden="true" />}
              title="Self-evaluation is not available"
              description="Select a different employee. Your employee record can only be evaluated by another reviewer."
            />
          </Card>
        ) : evaluationsQuery.isPending && canList ? (
          <div className="space-y-3" aria-label="Loading evaluation">
            <Skeleton className="h-60 w-full" />
            <Skeleton className="h-72 w-full" />
          </div>
        ) : evaluationsQuery.isError && canList ? (
          <Card>
            <SectionErrorState
              title="Evaluation history could not be loaded"
              description="Retry before editing or creating an evaluation for this employee and period."
              error={evaluationsQuery.error}
              onRetry={() => void evaluationsQuery.refetch()}
            />
          </Card>
        ) : !canList ? (
          <Alert tone="info" title="Evaluation history is not available">
            Your role can submit an evaluation, but cannot list previous records. Duplicate periods
            are still rejected by the server.
          </Alert>
        ) : null}

        {selectedEmployeeId && canList && evaluationsQuery.isSuccess && !evaluationSummary ? (
          <Card className="tablet:p-5 p-4">
            <div className="flex min-w-0 flex-wrap items-center justify-between gap-3">
              <div className="flex min-w-0 items-center gap-3">
                <span className="bg-primary-subtle text-primary flex size-11 shrink-0 items-center justify-center rounded-xl">
                  <UserRound className="size-5" aria-hidden="true" />
                </span>
                <div className="min-w-0">
                  <h2 className="text-label text-text-primary truncate font-semibold">
                    {employeeName}
                  </h2>
                  <p className="text-caption text-text-secondary mt-0.5">
                    {selectedEmployee?.designation || 'Employee record'}
                    {selectedEmployee?.branchName ? ` · ${selectedEmployee.branchName}` : ''}
                  </p>
                </div>
              </div>
              <StatusChip label="No evaluation saved" tone="neutral" />
            </div>
          </Card>
        ) : null}

        {selectedEmployeeId && evaluationSummary && !mayViewSelected ? (
          <Card>
            <SectionErrorState
              title="Evaluation details are restricted"
              description="This period already has an evaluation, but your role cannot view its manager comments. No edit form is shown."
            />
          </Card>
        ) : null}

        {selectedEmployeeId &&
        evaluationSummary &&
        mayViewSelected &&
        evaluationDetailQuery.isPending ? (
          <Skeleton className="h-72 w-full" aria-label="Loading saved evaluation details" />
        ) : null}

        {selectedEmployeeId &&
        evaluationSummary &&
        mayViewSelected &&
        evaluationDetailQuery.isError ? (
          <Card>
            <SectionErrorState
              title="Saved evaluation details could not be loaded"
              description="Retry to load the manager comments before making changes."
              error={evaluationDetailQuery.error}
              onRetry={() => void evaluationDetailQuery.refetch()}
            />
          </Card>
        ) : null}

        {selectedEmployeeId && selectedEmployeeId !== employeeRecordId && evaluationSummary ? (
          <Card className="bg-surface-muted/50 flex flex-wrap items-center justify-between gap-3 p-4">
            <div className="flex items-center gap-2">
              <CalendarDays className="text-primary size-4" aria-hidden="true" />
              <p className="text-caption text-text-secondary">
                Your evaluation for {updatePeriodLabel} is already on file.
              </p>
            </div>
            {evaluationSummary.overallScore != null ? (
              <StatusChip
                label={`Score ${evaluationSummary.overallScore.toFixed(1)}%`}
                tone="primary"
              />
            ) : null}
          </Card>
        ) : null}

        {selectedEmployeeId && canViewScorecard && scorecardQuery.isPending ? (
          <Skeleton className="h-64 w-full" aria-label="Loading performance scorecard" />
        ) : null}
        {selectedEmployeeId &&
        canViewScorecard &&
        scorecardQuery.isError &&
        scorecardQuery.error instanceof Error &&
        'status' in scorecardQuery.error &&
        scorecardQuery.error.status !== 404 ? (
          <SectionErrorState
            title="Scorecard context could not be loaded"
            description="The evaluation workflow remains available, but performance metrics could not be checked."
            error={scorecardQuery.error}
            onRetry={() => void scorecardQuery.refetch()}
          />
        ) : null}
        {scorecardQuery.data ? <ScorecardPanel scorecard={scorecardQuery.data} /> : null}
        {selectedEmployeeId &&
        canViewScorecard &&
        scorecardQuery.isError &&
        'status' in scorecardQuery.error &&
        scorecardQuery.error.status === 404 ? (
          <Alert tone="info" title="No scorecard recorded for this period">
            The evaluation can still be documented. Scorecard measures will appear when available.
          </Alert>
        ) : null}
        {selectedEmployeeId && !canViewScorecard ? (
          <Alert tone="info" title="Scorecard metrics are restricted">
            Your evaluation permissions are available, but scorecard viewing is not enabled for this
            role. You can continue with the manager assessment.
          </Alert>
        ) : null}

        {selectedEmployeeId &&
        (evaluationSummary ? Boolean(evaluation && mayViewSelected) : canCreate && !selfSelected) &&
        !evaluationsQuery.isError ? (
          <EvaluationEditor
            key={`${selectedEmployeeId}-${search.month}-${search.year}-${evaluation?.id ?? 'new'}`}
            evaluation={evaluation}
            employeeName={employeeName}
            month={search.month}
            year={search.year}
            canUpdate={canUpdate}
            canCreate={canCreate}
            isSaving={saveMutation.isPending}
            submitError={submitError}
            onSave={(draft) => {
              setSubmitError('')
              return saveMutation.mutateAsync({ existing: evaluation, draft })
            }}
          />
        ) : null}
      </div>
    </PageLayout>
  )
}
