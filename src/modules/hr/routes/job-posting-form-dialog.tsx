import { useEffect, useRef, useState, type FormEvent } from 'react'
import { useForm } from '@tanstack/react-form'
import { BriefcaseBusiness, RotateCcw } from 'lucide-react'

import { presentError } from '@/shared/errors'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'

import type { BranchDto } from '@/modules/company/branches.api'
import type { DepartmentChoice } from '@/modules/company/company-organization.api'
import type { JobPosting, JobPostingInput, JobPostingStatus, JobType } from '../recruitment.api'

type FormValues = {
  title: string
  branchId: string
  departmentId: string
  jobType: JobType
  status: JobPostingStatus
  description: string
  responsibilities: string
  requirements: string
  salaryMin: string
  salaryMax: string
  deadline: string
  isActive: boolean
}

const jobTypeOptions: DropdownSelectOption[] = [
  { value: 'full_time', label: 'Full-time' },
  { value: 'part_time', label: 'Part-time' },
  { value: 'contract', label: 'Contract' },
  { value: 'internship', label: 'Internship' },
  { value: 'temporary', label: 'Temporary' },
]

const statusOptions: DropdownSelectOption[] = [
  { value: 'draft', label: 'Draft' },
  { value: 'pending', label: 'Pending' },
  { value: 'active', label: 'Active' },
  { value: 'closed', label: 'Closed' },
  { value: 'cancelled', label: 'Cancelled' },
]

function valuesFromPosting(posting?: JobPosting | null): FormValues {
  return {
    title: posting?.title ?? '',
    branchId: posting ? String(posting.branchId) : '',
    departmentId: posting?.departmentId ? String(posting.departmentId) : '',
    jobType: (posting?.jobType as JobType) ?? 'full_time',
    status: (posting?.status as JobPostingStatus) ?? 'draft',
    description: posting?.description ?? '',
    responsibilities: posting?.responsibilities ?? '',
    requirements: posting?.requirements ?? '',
    salaryMin: posting?.salaryMin ?? '',
    salaryMax: posting?.salaryMax ?? '',
    deadline: posting?.deadline?.slice(0, 10) ?? '',
    isActive: posting?.isActive ?? true,
  }
}

function isValidSalary(value: string) {
  return /^\d{1,10}(?:\.\d{1,2})?$/.test(value.trim())
}

function validate(values: FormValues): Partial<Record<keyof FormValues, string>> {
  const errors: Partial<Record<keyof FormValues, string>> = {}
  if (!values.title.trim()) errors.title = 'Enter a job title.'
  else if (values.title.trim().length > 255) errors.title = 'Use 255 characters or fewer.'
  if (!/^[1-9]\d*$/.test(values.branchId)) errors.branchId = 'Choose a branch.'
  if (
    values.salaryMin.trim() &&
    (!isValidSalary(values.salaryMin) ||
      !Number.isFinite(Number(values.salaryMin)) ||
      Number(values.salaryMin) < 0)
  ) {
    errors.salaryMin = 'Enter a non-negative amount with up to two decimal places.'
  }
  if (
    values.salaryMax.trim() &&
    (!isValidSalary(values.salaryMax) ||
      !Number.isFinite(Number(values.salaryMax)) ||
      Number(values.salaryMax) < 0)
  ) {
    errors.salaryMax = 'Enter a non-negative amount with up to two decimal places.'
  }
  if (
    values.salaryMin.trim() &&
    values.salaryMax.trim() &&
    Number(values.salaryMax) < Number(values.salaryMin)
  ) {
    errors.salaryMax = 'Maximum salary cannot be below the minimum.'
  }
  return errors
}

function inputFromValues(values: FormValues): JobPostingInput {
  return {
    job_title: values.title.trim(),
    branch_id: Number(values.branchId),
    department_id: values.departmentId ? Number(values.departmentId) : null,
    job_type: values.jobType,
    status: values.status,
    description: values.description.trim(),
    responsibilities: values.responsibilities.trim(),
    requirements: values.requirements.trim(),
    salary_min: values.salaryMin.trim() ? Number(values.salaryMin) : null,
    salary_max: values.salaryMax.trim() ? Number(values.salaryMax) : null,
    deadline: values.deadline ? `${values.deadline}T00:00:00` : null,
    is_active: values.isActive,
  }
}

export function JobPostingFormDialog({
  open,
  onOpenChange,
  posting,
  branches,
  departments,
  branchChoicesError,
  departmentChoicesError,
  onRetryBranches,
  onRetryDepartments,
  onSave,
  saving,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  posting: JobPosting | null
  branches: BranchDto[]
  departments: DepartmentChoice[]
  branchChoicesError: boolean
  departmentChoicesError: boolean
  onRetryBranches: () => void
  onRetryDepartments: () => void
  onSave: (input: JobPostingInput) => Promise<void>
  saving: boolean
}) {
  const [fieldErrors, setFieldErrors] = useState<Partial<Record<keyof FormValues, string>>>({})
  const [formError, setFormError] = useState<string | null>(null)
  const formElement = useRef<HTMLFormElement>(null)
  const form = useForm({
    defaultValues: valuesFromPosting(posting),
    onSubmit: async ({ value }) => {
      const errors = validate(value)
      setFieldErrors(errors)
      setFormError(null)
      if (Object.keys(errors).length) return
      try {
        await onSave(inputFromValues(value))
      } catch (error) {
        setFormError(presentError(error, 'form-submit').message)
      }
    },
  })

  useEffect(() => {
    if (Object.keys(fieldErrors).length) {
      formElement.current?.querySelector<HTMLElement>('[aria-invalid="true"]')?.focus()
    }
  }, [fieldErrors])

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setFormError(null)
    void form.handleSubmit()
  }

  const branchOptions: DropdownSelectOption[] = branches.map((branch) => ({
    value: String(branch.id),
    label: branch.branch_name,
    description: [branch.city, branch.state].filter(Boolean).join(', '),
  }))
  if (posting && !branchOptions.some((option) => option.value === String(posting.branchId))) {
    branchOptions.unshift({ value: String(posting.branchId), label: `Branch #${posting.branchId}` })
  }
  const departmentOptions: DropdownSelectOption[] = [
    { value: '', label: 'No department' },
    ...departments.map(({ value, label }) => ({ value, label })),
  ]
  if (
    posting?.departmentId &&
    !departmentOptions.some((option) => option.value === String(posting.departmentId))
  ) {
    departmentOptions.push({
      value: String(posting.departmentId),
      label: `Department #${posting.departmentId}`,
    })
  }
  const branchUnavailable = !posting && (branchChoicesError || !branches.length)

  return (
    <Dialog
      open={open}
      onOpenChange={onOpenChange}
      title={posting ? 'Edit job posting' : 'Create job posting'}
      description={
        posting
          ? 'Update the role details and posting status.'
          : 'Add a role to the recruitment register.'
      }
      size="lg"
      dismissDisabled={saving}
      footer={
        <>
          <Button variant="outline" onClick={() => onOpenChange(false)} disabled={saving}>
            Cancel
          </Button>
          <Button
            type="submit"
            form="job-posting-form"
            isLoading={saving}
            disabled={branchUnavailable}
          >
            {posting ? 'Save changes' : 'Create posting'}
          </Button>
        </>
      }
    >
      <form
        id="job-posting-form"
        ref={formElement}
        noValidate
        onSubmit={submit}
        className="tablet:space-y-5 space-y-4"
      >
        {formError ? (
          <Alert tone="danger" title="Posting not saved" role="alert">
            {formError}
          </Alert>
        ) : null}
        {branchChoicesError ? (
          <Alert tone="warning" title="Branch choices unavailable">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <span>
                The posting requires a branch. Your draft is preserved while choices reload.
              </span>
              <Button size="sm" variant="outline" onClick={onRetryBranches}>
                <RotateCcw className="size-4" />
                Try again
              </Button>
            </div>
          </Alert>
        ) : null}
        {departmentChoicesError ? (
          <Alert tone="warning" title="Department choices unavailable">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <span>You can continue without a department, or retry to assign one.</span>
              <Button size="sm" variant="outline" onClick={onRetryDepartments}>
                <RotateCcw className="size-4" />
                Try again
              </Button>
            </div>
          </Alert>
        ) : null}

        <FormSection className="space-y-4">
          <div className="flex items-start gap-3">
            <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
              <BriefcaseBusiness className="size-5" aria-hidden="true" />
            </span>
            <div>
              <h3 className="text-label font-semibold">Role overview</h3>
              <p className="text-body-sm text-text-secondary mt-1">
                Define the role, team, and employment type.
              </p>
            </div>
          </div>
          <form.Field name="title">
            {(field) => (
              <FormControl id="job-title" label="Job title" required error={fieldErrors.title}>
                <TextInput
                  autoComplete="off"
                  maxLength={255}
                  placeholder="e.g. Senior Product Designer"
                  value={field.state.value}
                  onChange={(event) => {
                    field.handleChange(event.target.value)
                    setFieldErrors((previous) => ({ ...previous, title: undefined }))
                  }}
                />
              </FormControl>
            )}
          </form.Field>
          <div className="phone:grid-cols-2 grid gap-4">
            <form.Field name="branchId">
              {(field) => (
                <FormControl id="job-branch" label="Branch" required error={fieldErrors.branchId}>
                  <DropdownSelect
                    value={field.state.value}
                    options={branchOptions}
                    placeholder={
                      branchChoicesError ? 'Branch choices unavailable' : 'Select a branch'
                    }
                    onChange={(value) => {
                      field.handleChange(value)
                      setFieldErrors((previous) => ({ ...previous, branchId: undefined }))
                    }}
                    aria-invalid={fieldErrors.branchId ? 'true' : undefined}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="departmentId">
              {(field) => (
                <FormControl id="job-department" label="Department">
                  <DropdownSelect
                    value={field.state.value}
                    options={departmentOptions}
                    placeholder={
                      departmentChoicesError
                        ? 'Optional department unavailable'
                        : 'Choose a department'
                    }
                    onChange={(value) => field.handleChange(value)}
                    disabled={departmentChoicesError}
                  />
                </FormControl>
              )}
            </form.Field>
          </div>
          <div className="phone:grid-cols-2 grid gap-4">
            <form.Field name="jobType">
              {(field) => (
                <FormControl id="job-type" label="Employment type" required>
                  <DropdownSelect
                    value={field.state.value}
                    options={jobTypeOptions}
                    onChange={(value) => field.handleChange(value as JobType)}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="status">
              {(field) => (
                <FormControl id="job-status" label="Posting status" required>
                  <DropdownSelect
                    value={field.state.value}
                    options={statusOptions}
                    onChange={(value) => field.handleChange(value as JobPostingStatus)}
                  />
                </FormControl>
              )}
            </form.Field>
          </div>
        </FormSection>

        <FormSection className="space-y-4">
          <div>
            <h3 className="text-label font-semibold">Compensation and timing</h3>
            <p className="text-body-sm text-text-secondary mt-1">
              Salary range and application close date are optional.
            </p>
          </div>
          <div className="phone:grid-cols-2 grid gap-4">
            <form.Field name="salaryMin">
              {(field) => (
                <FormControl
                  id="job-salary-min"
                  label="Minimum salary (₦)"
                  error={fieldErrors.salaryMin}
                >
                  <TextInput
                    inputMode="decimal"
                    type="number"
                    min="0"
                    max="9999999999.99"
                    step="0.01"
                    placeholder="Optional"
                    value={field.state.value}
                    onChange={(event) => {
                      field.handleChange(event.target.value)
                      setFieldErrors((previous) => ({
                        ...previous,
                        salaryMin: undefined,
                        salaryMax: undefined,
                      }))
                    }}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="salaryMax">
              {(field) => (
                <FormControl
                  id="job-salary-max"
                  label="Maximum salary (₦)"
                  error={fieldErrors.salaryMax}
                >
                  <TextInput
                    inputMode="decimal"
                    type="number"
                    min="0"
                    max="9999999999.99"
                    step="0.01"
                    placeholder="Optional"
                    value={field.state.value}
                    onChange={(event) => {
                      field.handleChange(event.target.value)
                      setFieldErrors((previous) => ({ ...previous, salaryMax: undefined }))
                    }}
                  />
                </FormControl>
              )}
            </form.Field>
          </div>
          <form.Field name="deadline">
            {(field) => (
              <FormControl id="job-deadline" label="Application deadline">
                <DatePickerField
                  value={field.state.value}
                  onValueChange={field.handleChange}
                  clearable
                />
              </FormControl>
            )}
          </form.Field>
        </FormSection>

        <FormSection className="space-y-4">
          <div>
            <h3 className="text-label font-semibold">Role description</h3>
            <p className="text-body-sm text-text-secondary mt-1">
              Add enough context for a clear, consistent posting.
            </p>
          </div>
          <form.Field name="description">
            {(field) => (
              <FormControl id="job-description" label="Description">
                <TextArea
                  rows={4}
                  value={field.state.value}
                  onChange={(event) => field.handleChange(event.target.value)}
                />
              </FormControl>
            )}
          </form.Field>
          <form.Field name="responsibilities">
            {(field) => (
              <FormControl id="job-responsibilities" label="Responsibilities">
                <TextArea
                  rows={3}
                  value={field.state.value}
                  onChange={(event) => field.handleChange(event.target.value)}
                />
              </FormControl>
            )}
          </form.Field>
          <form.Field name="requirements">
            {(field) => (
              <FormControl id="job-requirements" label="Requirements">
                <TextArea
                  rows={3}
                  value={field.state.value}
                  onChange={(event) => field.handleChange(event.target.value)}
                />
              </FormControl>
            )}
          </form.Field>
          <form.Field name="isActive">
            {(field) => (
              <label className="text-body-sm text-text-secondary flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={field.state.value}
                  onChange={(event) => field.handleChange(event.target.checked)}
                  className="accent-primary size-4"
                />
                Keep this posting active
              </label>
            )}
          </form.Field>
        </FormSection>
      </form>
    </Dialog>
  )
}
