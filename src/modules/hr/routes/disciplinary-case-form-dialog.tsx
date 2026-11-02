import { useState, type FormEvent } from 'react'
import { useForm } from '@tanstack/react-form'
import { ShieldAlert } from 'lucide-react'

import { presentError } from '@/shared/errors'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'

import type { DisciplinaryCase, DisciplinaryCaseInput } from '../recognition.api'
import type { EmployeeChoice } from '../recognition.queries'

const actionOptions: DropdownSelectOption[] = [
  { value: 'verbal_warning', label: 'Verbal warning' },
  { value: 'written_warning', label: 'Written warning' },
  { value: 'final_warning', label: 'Final warning' },
  { value: 'suspension', label: 'Suspension' },
  { value: 'termination', label: 'Termination' },
  { value: 'demotion', label: 'Demotion' },
]

const categoryOptions: DropdownSelectOption[] = [
  { value: 'attendance_issues', label: 'Attendance issues' },
  { value: 'misconduct', label: 'Misconduct' },
  { value: 'poor_performance', label: 'Poor performance' },
  { value: 'insubordination', label: 'Insubordination' },
  { value: 'dishonesty', label: 'Dishonesty' },
  { value: 'safety_violation', label: 'Safety violation' },
  { value: 'confidentiality_breach', label: 'Confidentiality breach' },
  { value: 'harassment_discrimination', label: 'Harassment / discrimination' },
  { value: 'other', label: 'Other' },
]

type Values = {
  employeeId: string
  actionType: string
  violationCategory: string
  violationTitle: string
  violationDescription: string
  dateOfViolation: string
  actionDate: string
  investigationDetails: string
  severancePaymentDue: boolean
  severanceAmount: string
}

function todayDate(): string {
  const now = new Date()
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
}

function valuesFor(kase?: DisciplinaryCase | null): Values {
  return {
    employeeId: kase ? String(kase.employeeId) : '',
    actionType: kase?.actionType ?? '',
    violationCategory: kase?.violationCategory ?? '',
    violationTitle: kase?.violationTitle ?? '',
    violationDescription: kase?.violationDescription ?? '',
    dateOfViolation: kase?.dateOfViolation ?? '',
    actionDate: kase?.actionDate ?? todayDate(),
    investigationDetails: kase?.investigationDetails ?? '',
    severancePaymentDue: kase?.severancePaymentDue ?? false,
    severanceAmount: kase?.severanceAmount ?? '',
  }
}

function validate(values: Values) {
  const errors: Partial<Record<keyof Values, string>> = {}
  if (!/^\d+$/.test(values.employeeId) || Number(values.employeeId) < 1) {
    errors.employeeId = 'Enter or choose a valid employee record.'
  }
  if (!actionOptions.some(({ value }) => value === values.actionType)) {
    errors.actionType = 'Choose a disciplinary action.'
  }
  if (!categoryOptions.some(({ value }) => value === values.violationCategory)) {
    errors.violationCategory = 'Choose a violation category.'
  }
  if (values.violationTitle.trim().length < 2) errors.violationTitle = 'Enter a case title.'
  if (values.violationTitle.trim().length > 255)
    errors.violationTitle = 'Use 255 characters or fewer.'
  if (values.violationDescription.trim().length < 2) {
    errors.violationDescription = 'Describe the violation.'
  }
  if (!values.dateOfViolation) errors.dateOfViolation = 'Choose the violation date.'
  else if (values.dateOfViolation > todayDate()) {
    errors.dateOfViolation = 'The violation date cannot be in the future.'
  }
  if (!values.actionDate) errors.actionDate = 'Choose the action date.'
  else if (values.dateOfViolation && values.actionDate < values.dateOfViolation) {
    errors.actionDate = 'The action date cannot be before the violation date.'
  }
  if (values.severancePaymentDue) {
    if (!/^\d+(\.\d{1,2})?$/.test(values.severanceAmount)) {
      errors.severanceAmount = 'Enter an amount with up to two decimal places.'
    } else if (
      Number(values.severanceAmount) <= 0 ||
      Number(values.severanceAmount) > 99_999_999.99
    ) {
      errors.severanceAmount = 'Enter an amount greater than zero, up to ₦99,999,999.99.'
    }
  }
  return errors
}

function toInput(values: Values): DisciplinaryCaseInput {
  return {
    employee_id: Number(values.employeeId),
    action_type: values.actionType,
    violation_category: values.violationCategory,
    violation_title: values.violationTitle.trim(),
    violation_description: values.violationDescription.trim(),
    date_of_violation: values.dateOfViolation,
    action_date: values.actionDate,
    investigation_details: values.investigationDetails.trim() || null,
    severance_payment_due: values.severancePaymentDue,
    severance_amount: values.severancePaymentDue ? Number(values.severanceAmount) : null,
  }
}

export function DisciplinaryCaseFormDialog({
  open,
  kase,
  employeeChoices,
  employeeChoicesAvailable,
  saving,
  onOpenChange,
  onSave,
}: {
  open: boolean
  kase: DisciplinaryCase | null
  employeeChoices: EmployeeChoice[]
  employeeChoicesAvailable: boolean
  saving: boolean
  onOpenChange: (open: boolean) => void
  onSave: (input: DisciplinaryCaseInput) => Promise<void>
}) {
  const [errors, setErrors] = useState<Partial<Record<keyof Values, string>>>({})
  const [formError, setFormError] = useState('')
  const form = useForm({
    defaultValues: valuesFor(kase),
    onSubmit: async ({ value }) => {
      const nextErrors = validate(value)
      setErrors(nextErrors)
      setFormError('')
      if (Object.keys(nextErrors).length) {
        document.getElementById(`disciplinary-${Object.keys(nextErrors)[0]}`)?.focus()
        return
      }
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
  const employeeOptions = employeeChoices.map(({ id, employeeCode, fullName, designation }) => ({
    value: String(id),
    label: `${fullName || employeeCode} · ${employeeCode}${designation ? ` · ${designation}` : ''}`,
  }))
  const useEmployeeSelect = employeeChoicesAvailable && employeeOptions.length > 0

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!saving) onOpenChange(next)
      }}
      title={kase ? 'Edit disciplinary case' : 'New disciplinary case'}
      description="Document the employee, incident, and action using the HR case record."
      size="lg"
      fitContent
      compactOnMobile
      dismissDisabled={saving}
      footer={
        <>
          <Button variant="outline" disabled={saving} onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button type="submit" form="disciplinary-case-form" isLoading={saving}>
            {kase ? 'Save changes' : 'Create case'}
          </Button>
        </>
      }
    >
      <form id="disciplinary-case-form" noValidate onSubmit={submit} className="space-y-4">
        {formError ? (
          <Alert tone="danger" title="Case not saved" role="alert">
            {formError}
          </Alert>
        ) : null}
        <FormSection className="space-y-4">
          <div className="flex items-start gap-3">
            <span className="bg-warning-subtle text-warning-foreground rounded-control flex size-10 shrink-0 items-center justify-center">
              <ShieldAlert className="size-5" aria-hidden="true" />
            </span>
            <div>
              <h3 className="text-label font-semibold">Employee and action</h3>
              <p className="text-body-sm text-text-secondary mt-1">
                Case access follows the employee’s branch and ownership permissions.
              </p>
            </div>
          </div>
          <form.Field name="employeeId">
            {(field) => (
              <FormControl
                id="disciplinary-employeeId"
                label={useEmployeeSelect ? 'Employee' : 'Employee record ID'}
                required
                error={errors.employeeId}
              >
                {useEmployeeSelect ? (
                  <DropdownSelect
                    value={field.state.value}
                    options={employeeOptions}
                    placeholder="Choose an employee"
                    searchable
                    searchPlaceholder="Search employee records"
                    emptyMessage="No employee records found."
                    onChange={(value) => {
                      field.handleChange(value)
                      clearError('employeeId')
                    }}
                    aria-label="Employee for disciplinary case"
                    aria-invalid={Boolean(errors.employeeId)}
                  />
                ) : (
                  <TextInput
                    inputMode="numeric"
                    placeholder="Enter the numeric employee record ID"
                    value={field.state.value}
                    onChange={(event) => {
                      field.handleChange(event.currentTarget.value.replace(/\D/g, ''))
                      clearError('employeeId')
                    }}
                  />
                )}
              </FormControl>
            )}
          </form.Field>
          <div className="phone:grid-cols-2 grid gap-4">
            <form.Field name="actionType">
              {(field) => (
                <FormControl
                  id="disciplinary-actionType"
                  label="Action type"
                  required
                  error={errors.actionType}
                >
                  <DropdownSelect
                    value={field.state.value}
                    options={actionOptions}
                    placeholder="Choose an action"
                    onChange={(value) => {
                      field.handleChange(value)
                      clearError('actionType')
                    }}
                    aria-label="Disciplinary action type"
                    aria-invalid={Boolean(errors.actionType)}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="violationCategory">
              {(field) => (
                <FormControl
                  id="disciplinary-violationCategory"
                  label="Violation category"
                  required
                  error={errors.violationCategory}
                >
                  <DropdownSelect
                    value={field.state.value}
                    options={categoryOptions}
                    placeholder="Choose a category"
                    onChange={(value) => {
                      field.handleChange(value)
                      clearError('violationCategory')
                    }}
                    aria-label="Violation category"
                    aria-invalid={Boolean(errors.violationCategory)}
                  />
                </FormControl>
              )}
            </form.Field>
          </div>
          <div className="phone:grid-cols-2 grid gap-4">
            <form.Field name="dateOfViolation">
              {(field) => (
                <FormControl
                  id="disciplinary-dateOfViolation"
                  label="Violation date"
                  required
                  error={errors.dateOfViolation}
                >
                  <DatePickerField
                    value={field.state.value}
                    onValueChange={(value) => {
                      field.handleChange(value)
                      clearError('dateOfViolation')
                      if (form.getFieldValue('actionDate') < value) {
                        form.setFieldValue('actionDate', value)
                        clearError('actionDate')
                      }
                    }}
                    max={todayDate()}
                    required
                    placeholder="Choose a date"
                    aria-invalid={Boolean(errors.dateOfViolation)}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="actionDate">
              {(field) => (
                <FormControl
                  id="disciplinary-actionDate"
                  label="Action date"
                  required
                  error={errors.actionDate}
                >
                  <DatePickerField
                    value={field.state.value}
                    onValueChange={(value) => {
                      field.handleChange(value)
                      clearError('actionDate')
                    }}
                    min={form.getFieldValue('dateOfViolation') || undefined}
                    required
                    placeholder="Choose a date"
                    aria-invalid={Boolean(errors.actionDate)}
                  />
                </FormControl>
              )}
            </form.Field>
          </div>
          <form.Field name="violationTitle">
            {(field) => (
              <FormControl
                id="disciplinary-violationTitle"
                label="Case title"
                required
                error={errors.violationTitle}
              >
                <TextInput
                  maxLength={255}
                  placeholder="Short description of the incident"
                  value={field.state.value}
                  onChange={(event) => {
                    field.handleChange(event.currentTarget.value)
                    clearError('violationTitle')
                  }}
                />
              </FormControl>
            )}
          </form.Field>
          <form.Field name="violationDescription">
            {(field) => (
              <FormControl
                id="disciplinary-violationDescription"
                label="Incident description"
                required
                error={errors.violationDescription}
              >
                <TextArea
                  rows={4}
                  maxLength={10_000}
                  placeholder="Describe the incident and relevant context."
                  value={field.state.value}
                  onChange={(event) => {
                    field.handleChange(event.currentTarget.value)
                    clearError('violationDescription')
                  }}
                />
              </FormControl>
            )}
          </form.Field>
          <form.Field name="investigationDetails">
            {(field) => (
              <FormControl id="disciplinary-investigationDetails" label="Investigation details">
                <TextArea
                  rows={3}
                  maxLength={10_000}
                  placeholder="Optional findings or follow-up notes."
                  value={field.state.value}
                  onChange={(event) => field.handleChange(event.currentTarget.value)}
                />
              </FormControl>
            )}
          </form.Field>
          <form.Field name="severancePaymentDue">
            {(field) => (
              <label className="border-border-subtle bg-surface rounded-control flex items-center gap-2 border p-3">
                <input
                  type="checkbox"
                  checked={field.state.value}
                  onChange={(event) => {
                    field.handleChange(event.currentTarget.checked)
                    clearError('severanceAmount')
                  }}
                />
                <span className="text-body-sm text-text-primary">Severance payment is due</span>
              </label>
            )}
          </form.Field>
          {form.getFieldValue('severancePaymentDue') ? (
            <form.Field name="severanceAmount">
              {(field) => (
                <FormControl
                  id="disciplinary-severanceAmount"
                  label="Severance amount (₦)"
                  required
                  error={errors.severanceAmount}
                >
                  <TextInput
                    inputMode="decimal"
                    placeholder="0.00"
                    value={field.state.value}
                    onChange={(event) => {
                      field.handleChange(event.currentTarget.value.replace(/[^\d.]/g, ''))
                      clearError('severanceAmount')
                    }}
                  />
                </FormControl>
              )}
            </form.Field>
          ) : null}
        </FormSection>
      </form>
    </Dialog>
  )
}
