import { useState, type FormEvent, type ReactNode } from 'react'
import { useQuery } from '@tanstack/react-query'
import { CalendarDays, ChartNoAxesCombined, ChevronLeft, CircleCheck, MapPin } from 'lucide-react'

import { ApiError } from '@/shared/api/api-error'
import { presentError } from '@/shared/errors/error-presentation'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import {
  CreationFlowActions,
  CreationFlowStepper,
  type CreationFlowStep,
} from '@/shared/ui/creation-flow'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { SectionErrorState } from '@/shared/ui/feedback-states'
import {
  projectsApi,
  type ProjectDto,
  type ProjectPriority,
  type ProjectStatus,
  type ProjectWriteInput,
} from '../projects.api'

const statuses: { value: ProjectStatus; label: string }[] = [
  { value: 'planning', label: 'Planning' },
  { value: 'in_progress', label: 'In progress' },
  { value: 'on_hold', label: 'On hold' },
  { value: 'completed', label: 'Completed' },
  { value: 'cancelled', label: 'Cancelled' },
]
const priorities: { value: ProjectPriority; label: string }[] = [
  { value: 'low', label: 'Low' },
  { value: 'medium', label: 'Medium' },
  { value: 'high', label: 'High' },
  { value: 'critical', label: 'Critical' },
]

const steps: CreationFlowStep[] = [
  {
    id: 'basics',
    label: 'Basics',
    compactLabel: 'Start',
    title: 'Project basics',
    detail: 'Set the name, owner, client, and allocated budget.',
  },
  {
    id: 'delivery',
    label: 'Delivery',
    compactLabel: 'Plan',
    title: 'Delivery plan',
    detail: 'Set the project location, status, priority, and schedule.',
  },
  {
    id: 'review',
    label: 'Review',
    title: 'Review and confirm',
    detail: 'Check the project details before saving.',
  },
]

type ProjectField = keyof ProjectWriteInput
type FieldErrors = Partial<Record<ProjectField, string>>
type ProjectFormValues = Omit<ProjectWriteInput, 'progress'> & { progress: string }

const stepFields: ProjectField[][] = [
  ['name', 'short_code', 'category', 'branch_id', 'client_id', 'budget'],
  ['location', 'status', 'priority', 'progress', 'start_date', 'deadline'],
  ['summary'],
]

const serverFieldNames: Record<string, ProjectField> = {
  name: 'name',
  project_name: 'name',
  short_code: 'short_code',
  project_code: 'short_code',
  category: 'category',
  branch_id: 'branch_id',
  client_id: 'client_id',
  budget: 'budget',
  allocated_budget: 'budget',
  location: 'location',
  status: 'status',
  priority: 'priority',
  progress: 'progress',
  start_date: 'start_date',
  deadline: 'deadline',
  summary: 'summary',
}

function emptyInput(): ProjectFormValues {
  return {
    name: '',
    short_code: '',
    category: '',
    client_id: 0,
    branch_id: 0,
    department_id: null,
    employee_ids: [],
    location: '',
    priority: 'medium',
    summary: '',
    status: 'planning',
    budget: '0',
    progress: '0',
    start_date: null,
    deadline: null,
    file_url: null,
  }
}

function projectInput(project: ProjectDto): ProjectFormValues {
  return {
    name: project.name,
    short_code: project.short_code,
    category: project.category,
    client_id: project.client_id,
    branch_id: project.branch_id ?? 0,
    department_id: project.department_id,
    employee_ids: project.employee_ids,
    location: project.location ?? '',
    priority: project.priority,
    summary: project.summary ?? '',
    status: project.status,
    budget: project.budget,
    progress: String(project.progress),
    start_date: project.start_date,
    deadline: project.deadline,
    file_url: project.file_url,
  }
}

function validateStep(step: number, values: ProjectFormValues): FieldErrors {
  const errors: FieldErrors = {}
  if (step === 0) {
    if (!values.name.trim()) errors.name = 'Enter a project name.'
    if (!values.short_code.trim()) errors.short_code = 'Enter a project code.'
    if (!values.category.trim()) errors.category = 'Enter a project category.'
    if (!values.branch_id) errors.branch_id = 'Select the branch that owns this project.'
    if (!values.client_id) errors.client_id = 'Select a client for this project.'
    const budget = Number(values.budget)
    if (!values.budget.trim() || !Number.isFinite(budget) || budget < 0) {
      errors.budget = 'Enter a valid budget of zero or more naira.'
    }
  }
  if (step === 1) {
    const progress = values.progress.trim() === '' ? Number.NaN : Number(values.progress)
    if (!Number.isInteger(progress) || progress < 0 || progress > 100) {
      errors.progress = 'Enter a whole number between 0 and 100 percent.'
    }
    if (values.start_date && values.deadline && values.deadline < values.start_date) {
      errors.deadline = 'Target completion must be on or after the start date.'
    }
  }
  if (step === 2 && (values.summary?.length ?? 0) > 2000) {
    errors.summary = 'Keep the summary under 2,000 characters.'
  }
  return errors
}

function ReviewItem({ label, value, icon }: { label: string; value: string; icon?: ReactNode }) {
  return (
    <div className="bg-surface-muted/55 border-border-subtle rounded-control flex min-w-0 items-start gap-2.5 border p-3">
      {icon ? <span className="text-primary mt-0.5 shrink-0">{icon}</span> : null}
      <div className="min-w-0">
        <p className="text-overline text-text-muted">{label}</p>
        <p className="text-caption text-text-primary mt-0.5 font-medium break-words">
          {value || 'Not provided'}
        </p>
      </div>
    </div>
  )
}

export function ProjectFormDialog({
  open,
  project,
  onOpenChange,
  onSave,
  saving,
}: {
  open: boolean
  project: ProjectDto | null
  onOpenChange: (open: boolean) => void
  onSave: (input: ProjectWriteInput) => Promise<void>
  saving: boolean
}) {
  const [values, setValues] = useState<ProjectFormValues>(() =>
    project ? projectInput(project) : emptyInput(),
  )
  const [step, setStep] = useState(0)
  const [formError, setFormError] = useState('')
  const [fieldErrors, setFieldErrors] = useState<FieldErrors>({})
  const branches = useQuery({
    queryKey: ['operations', 'project-options', 'branches'],
    queryFn: ({ signal }) => projectsApi.branchOptions(signal),
    staleTime: 60_000,
    enabled: open,
  })
  const clients = useQuery({
    queryKey: ['operations', 'project-options', 'clients'],
    queryFn: ({ signal }) => projectsApi.clientOptions('', signal),
    staleTime: 60_000,
    enabled: open,
  })

  function set<K extends keyof ProjectFormValues>(key: K, value: ProjectFormValues[K]) {
    setValues((current) => ({ ...current, [key]: value }))
    setFieldErrors((current) => ({ ...current, [key]: undefined }))
    setFormError('')
  }

  function validateStepAt(stepToValidate: number): boolean {
    const errors = validateStep(stepToValidate, values)
    const fieldsForStep = stepFields[stepToValidate]
    setFieldErrors((current) => {
      const next = { ...current }
      fieldsForStep.forEach((field) => delete next[field])
      return { ...next, ...errors }
    })
    if (Object.keys(errors).length) {
      const firstInvalidField = fieldsForStep.find((field) => errors[field])
      if (firstInvalidField) {
        window.requestAnimationFrame(() =>
          document.getElementById(`project-${firstInvalidField}`)?.focus(),
        )
      }
      return false
    }
    return true
  }

  function validateCurrentStep(): boolean {
    return validateStepAt(step)
  }

  function goToStep(nextStep: number) {
    if (nextStep > step) {
      for (let stepToValidate = step; stepToValidate < nextStep; stepToValidate += 1) {
        if (!validateStepAt(stepToValidate)) {
          setStep(stepToValidate)
          setFormError('')
          return
        }
      }
    }
    setFormError('')
    setStep(nextStep)
  }

  function handleServerError(error: unknown) {
    const mappedErrors: FieldErrors = {}
    const unmappedMessages: string[] = []
    if (error instanceof ApiError && error.fieldErrors) {
      for (const [key, messages] of Object.entries(error.fieldErrors)) {
        const target = serverFieldNames[key]
        const message = Array.isArray(messages) ? messages[0] : messages
        if (target && message) mappedErrors[target] = message
        else if (message) unmappedMessages.push(message)
      }
    }
    if (Object.keys(mappedErrors).length) {
      setFieldErrors((current) => ({ ...current, ...mappedErrors }))
      const earliestStep = Math.min(
        ...Object.keys(mappedErrors).map((field) =>
          stepFields.findIndex((fields) => fields.includes(field as ProjectField)),
        ),
      )
      if (earliestStep >= 0) setStep(earliestStep)
    }
    setFormError(
      unmappedMessages.join(' ') ||
        (Object.keys(mappedErrors).length
          ? ''
          : presentError(error, 'form-submit').message ||
            'The project could not be saved. Review the details and try again.'),
    )
  }

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setFormError('')
    if (!validateCurrentStep()) return
    if (step < steps.length - 1) {
      setStep((current) => current + 1)
      return
    }

    try {
      await onSave({
        ...values,
        name: values.name.trim(),
        short_code: values.short_code.trim().toUpperCase(),
        category: values.category.trim(),
        budget: String(values.budget || '0'),
        progress: Number(values.progress),
        location: values.location?.trim() || null,
        summary: values.summary?.trim() || null,
      })
    } catch (error) {
      handleServerError(error)
    }
  }

  const branchName =
    branches.data?.find((branch) => branch.id === values.branch_id)?.name ??
    project?.branch_name ??
    ''
  const clientName =
    clients.data?.find((client) => client.id === values.client_id)?.name ??
    (values.client_id ? `Client #${values.client_id}` : '')
  const currentStep = steps[step] ?? steps[0]

  return (
    <Dialog
      open={open}
      onOpenChange={onOpenChange}
      title={project ? 'Edit project' : 'Create project'}
      description={`${currentStep.label} · ${currentStep.detail}`}
      size="lg"
      compactOnMobile
      fitContent
      bodyClassName="bg-background tablet:px-5 space-y-4"
      footer={
        <CreationFlowActions
          leading={
            <Button variant="outline" onClick={() => onOpenChange(false)} disabled={saving}>
              Cancel
            </Button>
          }
        >
          {step > 0 ? (
            <Button
              variant="outline"
              leadingIcon={<ChevronLeft className="size-4" aria-hidden="true" />}
              onClick={() => goToStep(step - 1)}
              disabled={saving}
            >
              Previous
            </Button>
          ) : null}
          {/* Keep Next and Submit as distinct DOM nodes so the Next click cannot inherit the submit action during the Review render. */}
          {step < steps.length - 1 ? (
            <Button
              key="advance-project-stage"
              onClick={() => goToStep(step + 1)}
              disabled={saving}
            >
              Next
            </Button>
          ) : (
            <Button
              key="submit-project"
              type="submit"
              form="project-form"
              isLoading={saving}
              disabled={saving}
            >
              {project ? 'Save changes' : 'Create project'}
            </Button>
          )}
        </CreationFlowActions>
      }
    >
      <CreationFlowStepper
        steps={steps}
        currentStep={step}
        maxSelectableStep={steps.length - 1}
        onStepSelect={goToStep}
        ariaLabel={project ? 'Project update' : 'Project setup'}
        variant="horizontal"
        eyebrow={project ? 'Project update' : 'Project setup'}
        hideDetailBelow480
      />
      {branches.isError || clients.isError ? (
        <SectionErrorState
          title="Project options could not load"
          description="Retry the branch and client lists before continuing."
          onRetry={() => {
            void branches.refetch()
            void clients.refetch()
          }}
        />
      ) : null}
      {formError ? (
        <Alert tone="danger" role="alert">
          {formError}
        </Alert>
      ) : null}
      <form
        id="project-form"
        noValidate
        onSubmit={(event) => void submit(event)}
        className="min-w-0"
      >
        {step === 0 ? (
          <fieldset
            disabled={saving}
            className="bg-surface-muted border-border-subtle phone:gap-4 rounded-surface phone:p-5 grid min-w-0 grid-cols-2 gap-3 border p-4"
          >
            <FormControl
              id="project-name"
              label="Project name"
              required
              error={fieldErrors.name}
              className="col-span-2 min-w-0"
            >
              <TextInput
                autoFocus
                maxLength={180}
                autoComplete="off"
                placeholder="e.g. Enugu site expansion"
                value={values.name}
                onChange={(event) => set('name', event.target.value)}
              />
            </FormControl>
            <FormControl
              id="project-code"
              label="Project code"
              required
              error={fieldErrors.short_code}
              className="min-w-0"
            >
              <TextInput
                maxLength={24}
                autoComplete="off"
                value={values.short_code}
                onChange={(event) => set('short_code', event.target.value)}
                placeholder="e.g. FC-001"
              />
            </FormControl>
            <FormControl
              id="project-category"
              label="Category"
              required
              error={fieldErrors.category}
              className="min-w-0"
            >
              <TextInput
                maxLength={100}
                value={values.category}
                onChange={(event) => set('category', event.target.value)}
                placeholder="Construction"
              />
            </FormControl>
            <FormControl
              id="project-branch_id"
              label="Owning branch"
              required
              error={fieldErrors.branch_id}
              description={branches.isPending ? 'Loading available branches…' : undefined}
              className="min-w-0"
            >
              <DropdownSelect
                value={values.branch_id ? String(values.branch_id) : ''}
                placeholder="Select branch"
                searchable
                disabled={Boolean(project?.branch_id) || branches.isPending || branches.isError}
                options={[
                  ...(project?.branch_id &&
                  project.branch_name &&
                  !branches.data?.some((branch) => branch.id === project.branch_id)
                    ? [{ value: String(project.branch_id), label: project.branch_name }]
                    : []),
                  ...(branches.data ?? []).map((branch) => ({
                    value: String(branch.id),
                    label: branch.name,
                    description: branch.code,
                  })),
                ]}
                onChange={(value) => set('branch_id', Number(value))}
              />
            </FormControl>
            <FormControl
              id="project-client_id"
              label="Client"
              required
              error={fieldErrors.client_id}
              description={clients.isPending ? 'Loading available clients…' : undefined}
              className="min-w-0"
            >
              <DropdownSelect
                value={values.client_id ? String(values.client_id) : ''}
                placeholder="Select client"
                searchable
                menuMinWidth={420}
                disabled={clients.isPending || clients.isError}
                options={[
                  ...(project && !clients.data?.some((client) => client.id === project.client_id)
                    ? [{ value: String(project.client_id), label: `Client #${project.client_id}` }]
                    : []),
                  ...(clients.data ?? []).map((client) => ({
                    value: String(client.id),
                    label: client.name,
                    description: client.email || undefined,
                  })),
                ]}
                onChange={(value) => set('client_id', Number(value))}
              />
            </FormControl>
            <FormControl
              id="project-budget"
              label="Allocated budget (NGN)"
              required
              error={fieldErrors.budget}
              className="col-span-2 min-w-0"
            >
              <TextInput
                type="number"
                min="0"
                step="0.01"
                inputMode="decimal"
                value={values.budget}
                onChange={(event) => set('budget', event.target.value)}
              />
            </FormControl>
          </fieldset>
        ) : null}

        {step === 1 ? (
          <fieldset
            disabled={saving}
            className="bg-surface-muted border-border-subtle phone:gap-4 rounded-surface phone:p-5 grid min-w-0 grid-cols-2 gap-3 border p-4"
          >
            <FormControl
              id="project-location"
              label="Project location"
              className="col-span-2 min-w-0"
            >
              <TextInput
                maxLength={240}
                autoComplete="street-address"
                placeholder="City, state or site address"
                value={values.location ?? ''}
                onChange={(event) => set('location', event.target.value || null)}
              />
            </FormControl>
            <div className="min-w-0">
              <DropdownSelect
                label="Status"
                value={values.status}
                options={statuses}
                onChange={(value) => set('status', value as ProjectStatus)}
              />
            </div>
            <div className="min-w-0">
              <DropdownSelect
                label="Priority"
                value={values.priority}
                options={priorities}
                onChange={(value) => set('priority', value as ProjectPriority)}
              />
            </div>
            <FormControl
              id="project-progress"
              label="Current progress (%)"
              error={fieldErrors.progress}
              className="col-span-2 min-w-0"
            >
              <TextInput
                type="number"
                min="0"
                max="100"
                step="1"
                value={values.progress}
                onChange={(event) => set('progress', event.target.value)}
              />
            </FormControl>
            <FormControl
              id="project-start_date"
              label="Start date"
              error={fieldErrors.start_date}
              className="min-w-0"
            >
              <DatePickerField
                value={values.start_date ?? ''}
                max={values.deadline ?? undefined}
                onValueChange={(value) => set('start_date', value || null)}
              />
            </FormControl>
            <FormControl
              id="project-deadline"
              label="Target completion"
              error={fieldErrors.deadline}
              className="min-w-0"
            >
              <DatePickerField
                value={values.deadline ?? ''}
                min={values.start_date ?? undefined}
                onValueChange={(value) => set('deadline', value || null)}
              />
            </FormControl>
          </fieldset>
        ) : null}

        {step === 2 ? (
          <div className="space-y-4">
            <FormControl
              id="project-summary"
              label="Project summary"
              error={fieldErrors.summary}
              description="Add the main objective or scope. You can leave this blank and update it later."
            >
              <TextArea
                maxLength={2000}
                value={values.summary ?? ''}
                onChange={(event) => set('summary', event.target.value || null)}
                rows={3}
                placeholder="Describe the project scope and intended outcome."
              />
            </FormControl>
            <div className="space-y-3">
              <ReviewSection
                title="Project basics"
                description="Identity, ownership, and budget"
                editLabel="Edit project basics"
                onEdit={() => goToStep(0)}
              >
                <ReviewItem label="Project name" value={values.name.trim()} />
                <ReviewItem label="Project code" value={values.short_code.trim().toUpperCase()} />
                <ReviewItem label="Category" value={values.category.trim()} />
                <ReviewItem label="Owning branch" value={branchName} />
                <ReviewItem label="Client" value={clientName} />
                <ReviewItem
                  label="Allocated budget"
                  value={`₦${Number(values.budget || 0).toLocaleString('en-NG')}`}
                />
              </ReviewSection>
              <ReviewSection
                title="Delivery plan"
                description="Status, priority, progress, and schedule"
                editLabel="Edit delivery plan"
                onEdit={() => goToStep(1)}
              >
                <ReviewItem
                  label="Status"
                  value={values.status.replaceAll('_', ' ')}
                  icon={<CircleCheck className="size-4" aria-hidden="true" />}
                />
                <ReviewItem label="Priority" value={values.priority} />
                <ReviewItem
                  label="Current progress"
                  value={`${values.progress.trim() || '0'}%`}
                  icon={<ChartNoAxesCombined className="size-4" aria-hidden="true" />}
                />
                <ReviewItem
                  label="Project location"
                  value={values.location?.trim() || 'Not provided'}
                  icon={<MapPin className="size-4" aria-hidden="true" />}
                />
                <ReviewItem
                  label="Start date"
                  value={values.start_date || 'Not scheduled'}
                  icon={<CalendarDays className="size-4" aria-hidden="true" />}
                />
                <ReviewItem
                  label="Target completion"
                  value={values.deadline || 'Not scheduled'}
                  icon={<CalendarDays className="size-4" aria-hidden="true" />}
                />
              </ReviewSection>
              <section
                aria-labelledby="project-review-summary"
                className="bg-surface-muted border-border-subtle rounded-surface space-y-3 border p-4"
              >
                <h3 id="project-review-summary" className="text-label font-semibold">
                  Project summary
                </h3>
                <p className="text-body-sm text-text-secondary break-words whitespace-pre-wrap">
                  {values.summary?.trim() || 'No summary provided.'}
                </p>
              </section>
            </div>
          </div>
        ) : null}
      </form>
    </Dialog>
  )
}

function ReviewSection({
  title,
  description,
  editLabel,
  onEdit,
  children,
}: {
  title: string
  description: string
  editLabel: string
  onEdit: () => void
  children: ReactNode
}) {
  return (
    <section
      aria-label={title}
      className="bg-surface-muted border-border-subtle rounded-surface phone:p-4 space-y-3 border p-3"
    >
      <div className="flex min-w-0 items-start justify-between gap-3">
        <div className="min-w-0">
          <h3 className="text-label font-semibold">{title}</h3>
          <p className="text-caption text-text-secondary mt-0.5">{description}</p>
        </div>
        <Button
          type="button"
          variant="ghost"
          size="sm"
          aria-label={editLabel}
          onClick={onEdit}
          className="shrink-0"
        >
          Edit
        </Button>
      </div>
      <div className="grid min-w-0 grid-cols-1 gap-2 min-[480px]:grid-cols-2">{children}</div>
    </section>
  )
}
