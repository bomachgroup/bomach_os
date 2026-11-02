import { useState, type FormEvent, type RefObject } from 'react'
import { useForm } from '@tanstack/react-form'
import { CalendarDays, GraduationCap } from 'lucide-react'

import { presentError } from '@/shared/errors'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'

import type {
  TrainingAudience,
  TrainingProgram,
  TrainingProgramInput,
  TrainingProgramStatus,
} from '../training-programs.api'

const audienceOptions: DropdownSelectOption[] = [
  { value: 'all_employees', label: 'All employees' },
  { value: 'management', label: 'Management' },
  { value: 'new_hires', label: 'New hires' },
  { value: 'department_specific', label: 'Department specific' },
  { value: 'leadership_team', label: 'Leadership team' },
  { value: 'technical_staff', label: 'Technical staff' },
  { value: 'sales_team', label: 'Sales team' },
  { value: 'customer_service', label: 'Customer service' },
]
const statusOptions: DropdownSelectOption[] = [
  { value: 'pending', label: 'Planned' },
  { value: 'in_progress', label: 'In progress' },
  { value: 'completed', label: 'Completed' },
  { value: 'cancelled', label: 'Cancelled' },
]

type Values = {
  program_name: string
  provider: string
  description: string
  start_date: string
  end_date: string
  cost: string
  target_audience: string
  status: string
}

const valuesFor = (program?: TrainingProgram | null): Values => ({
  program_name: program?.program_name ?? '',
  provider: program?.provider ?? '',
  description: program?.description ?? '',
  start_date: program?.start_date ?? '',
  end_date: program?.end_date ?? '',
  cost: program?.cost ?? '0',
  target_audience: program?.target_audience ?? 'all_employees',
  status: program?.status ?? 'pending',
})

function validate(values: Values) {
  const errors: Partial<Record<keyof Values, string>> = {}
  if (values.program_name.trim().length < 2) errors.program_name = 'Enter a program name.'
  if (!values.start_date) errors.start_date = 'Choose a start date.'
  if (!values.end_date) errors.end_date = 'Choose an end date.'
  if (values.start_date && values.end_date && values.end_date < values.start_date) {
    errors.end_date = 'End date cannot be before the start date.'
  }
  if (
    values.cost === '' ||
    !Number.isFinite(Number(values.cost)) ||
    Number(values.cost) < 0 ||
    !/^\d+(\.\d{1,2})?$/.test(values.cost)
  ) {
    errors.cost = 'Enter a non-negative cost with up to two decimal places.'
  }
  if (!audienceOptions.some((option) => option.value === values.target_audience)) {
    errors.target_audience = 'Choose the intended audience.'
  }
  if (!statusOptions.some((option) => option.value === values.status)) {
    errors.status = 'Choose a valid program status.'
  }
  return errors
}

function toInput(values: Values): TrainingProgramInput {
  return {
    program_name: values.program_name.trim(),
    provider: values.provider.trim(),
    description: values.description.trim(),
    start_date: values.start_date,
    end_date: values.end_date,
    cost: Number(values.cost),
    target_audience: values.target_audience as TrainingAudience,
    status: values.status as TrainingProgramStatus,
  }
}

export function TrainingProgramFormDialog({
  open,
  onOpenChange,
  program,
  saving,
  onSave,
  returnFocusRef,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  program: TrainingProgram | null
  saving: boolean
  onSave: (input: TrainingProgramInput) => Promise<void>
  returnFocusRef?: RefObject<HTMLElement | null>
}) {
  const [errors, setErrors] = useState<Partial<Record<keyof Values, string>>>({})
  const [formError, setFormError] = useState('')
  const form = useForm({
    defaultValues: valuesFor(program),
    onSubmit: async ({ value }) => {
      const nextErrors = validate(value)
      setErrors(nextErrors)
      setFormError('')
      if (Object.keys(nextErrors).length) return
      try {
        await onSave(toInput(value))
      } catch (error) {
        setFormError(presentError(error, 'form-submit').message)
      }
    },
  })

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setFormError('')
    void form.handleSubmit()
  }

  const clearError = (key: keyof Values) =>
    setErrors((current) => ({ ...current, [key]: undefined }))

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next && !saving) {
          setErrors({})
          setFormError('')
        }
        if (!saving) onOpenChange(next)
      }}
      title={program ? 'Edit training program' : 'Create training program'}
      description="Set the learning details, audience, schedule and budget for this program."
      size="lg"
      dismissDisabled={saving}
      returnFocusRef={returnFocusRef}
      footer={
        <>
          <Button variant="outline" onClick={() => onOpenChange(false)} disabled={saving}>
            Cancel
          </Button>
          <Button type="submit" form="training-program-form" isLoading={saving}>
            {program ? 'Save changes' : 'Create program'}
          </Button>
        </>
      }
    >
      <form id="training-program-form" noValidate onSubmit={submit} className="space-y-4">
        {formError ? (
          <Alert tone="danger" title="Program not saved" role="alert">
            {formError}
          </Alert>
        ) : null}
        <FormSection className="space-y-4">
          <div className="flex items-start gap-3">
            <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
              <GraduationCap className="size-5" />
            </span>
            <div>
              <h3 className="text-label font-semibold">Program details</h3>
              <p className="text-body-sm text-text-secondary mt-1">
                Describe what employees will learn and who will provide it.
              </p>
            </div>
          </div>
          <div className="phone:grid-cols-2 grid gap-4">
            <form.Field name="program_name">
              {(field) => (
                <FormControl
                  id="training-name"
                  label="Program name"
                  required
                  error={errors.program_name}
                >
                  <TextInput
                    maxLength={200}
                    placeholder="e.g. Workplace safety essentials"
                    value={field.state.value}
                    onChange={(event) => {
                      field.handleChange(event.currentTarget.value)
                      clearError('program_name')
                    }}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="provider">
              {(field) => (
                <FormControl id="training-provider" label="Provider" error={errors.provider}>
                  <TextInput
                    maxLength={200}
                    placeholder="Training provider"
                    value={field.state.value}
                    onChange={(event) => {
                      field.handleChange(event.currentTarget.value)
                      clearError('provider')
                    }}
                  />
                </FormControl>
              )}
            </form.Field>
          </div>
          <form.Field name="description">
            {(field) => (
              <FormControl id="training-description" label="Description" error={errors.description}>
                <TextArea
                  rows={4}
                  maxLength={5000}
                  placeholder="Summarize the skills or outcomes this program covers."
                  value={field.state.value}
                  onChange={(event) => {
                    field.handleChange(event.currentTarget.value)
                    clearError('description')
                  }}
                />
              </FormControl>
            )}
          </form.Field>
        </FormSection>
        <FormSection className="space-y-4">
          <div className="flex items-start gap-3">
            <span className="bg-info-subtle text-info-foreground rounded-control flex size-10 shrink-0 items-center justify-center">
              <CalendarDays className="size-5" />
            </span>
            <div>
              <h3 className="text-label font-semibold">Schedule and investment</h3>
              <p className="text-body-sm text-text-secondary mt-1">
                Duration is calculated from the selected dates.
              </p>
            </div>
          </div>
          <div className="phone:grid-cols-2 grid gap-4">
            <form.Field name="start_date">
              {(field) => (
                <FormControl
                  id="training-start"
                  label="Start date"
                  required
                  error={errors.start_date}
                >
                  <DatePickerField
                    value={field.state.value}
                    max={form.state.values.end_date || undefined}
                    onValueChange={(value) => {
                      field.handleChange(value)
                      clearError('start_date')
                    }}
                    required
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="end_date">
              {(field) => (
                <FormControl id="training-end" label="End date" required error={errors.end_date}>
                  <DatePickerField
                    value={field.state.value}
                    min={form.state.values.start_date || undefined}
                    onValueChange={(value) => {
                      field.handleChange(value)
                      clearError('end_date')
                    }}
                    required
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="cost">
              {(field) => (
                <FormControl
                  id="training-cost"
                  label="Program cost (₦)"
                  required
                  error={errors.cost}
                >
                  <TextInput
                    type="number"
                    inputMode="decimal"
                    min="0"
                    step="0.01"
                    value={field.state.value}
                    onChange={(event) => {
                      field.handleChange(event.currentTarget.value)
                      clearError('cost')
                    }}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="status">
              {(field) => (
                <FormControl id="training-status" label="Status" required error={errors.status}>
                  <DropdownSelect
                    value={field.state.value}
                    options={statusOptions}
                    onChange={(value) => {
                      field.handleChange(value)
                      clearError('status')
                    }}
                  />
                </FormControl>
              )}
            </form.Field>
          </div>
          <form.Field name="target_audience">
            {(field) => (
              <FormControl
                id="training-audience"
                label="Intended audience"
                required
                error={errors.target_audience}
              >
                <DropdownSelect
                  value={field.state.value}
                  options={audienceOptions}
                  searchable
                  onChange={(value) => {
                    field.handleChange(value)
                    clearError('target_audience')
                  }}
                />
              </FormControl>
            )}
          </form.Field>
        </FormSection>
      </form>
    </Dialog>
  )
}
