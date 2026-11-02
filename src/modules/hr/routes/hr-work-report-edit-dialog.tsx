import { useEffect, useRef, useState, type FormEvent } from 'react'
import { useForm } from '@tanstack/react-form'

import { ApiError } from '@/shared/api/api-error'
import { presentError } from '@/shared/errors'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { Dialog } from '@/shared/ui/dialog'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { StatusChip } from '@/shared/ui/status-chip'

import type { WorkReport, WorkReportInput } from '@/modules/work-reports/work-reports.api'

type Draft = {
  day: string
  hoursWorked: string
  operationalBase: string
  workActivities: string
  taskDetails: string
  planNextDay: string
}

type FieldName = keyof Draft
type FieldErrors = Partial<Record<FieldName, string>>

function valuesFromReport(report: WorkReport | null): Draft {
  return {
    day: report?.day ?? '',
    hoursWorked: report ? String(report.hoursWorked) : '',
    operationalBase: report?.operationalBase ?? '',
    workActivities: report?.workActivities ?? '',
    taskDetails: report?.taskDetails ?? '',
    planNextDay: report?.planNextDay ?? '',
  }
}

function validate(draft: Draft): FieldErrors {
  const errors: FieldErrors = {}
  if (!/^\d{4}-\d{2}-\d{2}$/.test(draft.day)) errors.day = 'Choose a valid report date.'
  if (!draft.hoursWorked.trim()) {
    errors.hoursWorked = 'Enter the hours worked.'
  } else {
    const hours = Number(draft.hoursWorked)
    if (!Number.isFinite(hours) || hours < 0 || hours > 999.9) {
      errors.hoursWorked = 'Enter a value from 0 to 999.9 hours.'
    } else if (!/^\d{1,3}(?:\.\d)?$/.test(draft.hoursWorked)) {
      errors.hoursWorked = 'Enter up to one decimal place.'
    }
  }
  if (draft.operationalBase.length > 500) {
    errors.operationalBase = 'Use 500 characters or fewer.'
  }
  return errors
}

function errorsFromApi(error: unknown): FieldErrors {
  if (!(error instanceof ApiError) || !error.fieldErrors) return {}
  const mapping: Record<string, FieldName> = {
    day: 'day',
    hours_worked: 'hoursWorked',
    operational_base: 'operationalBase',
    work_activities: 'workActivities',
    task_details: 'taskDetails',
    plan_next_day: 'planNextDay',
  }
  const errors: FieldErrors = {}
  for (const [key, value] of Object.entries(error.fieldErrors)) {
    const field = mapping[key]
    if (field) errors[field] = Array.isArray(value) ? value[0] : value
  }
  return errors
}

function focusFirstInvalid(form: HTMLFormElement | null) {
  form?.querySelector<HTMLElement>('[aria-invalid="true"]')?.focus()
}

export function HRWorkReportEditDialog({
  open,
  report,
  loading,
  loadError,
  saving,
  onOpenChange,
  onRetry,
  onSave,
}: {
  open: boolean
  report: WorkReport | null
  loading: boolean
  loadError?: string
  saving: boolean
  onOpenChange: (open: boolean) => void
  onRetry: () => void
  onSave: (input: WorkReportInput) => Promise<void>
}) {
  const formElement = useRef<HTMLFormElement>(null)
  const [fieldErrors, setFieldErrors] = useState<FieldErrors>({})
  const [formError, setFormError] = useState('')
  const form = useForm({
    defaultValues: valuesFromReport(report),
    onSubmit: async ({ value }) => {
      const errors = validate(value)
      setFieldErrors(errors)
      setFormError('')
      if (Object.keys(errors).length) return

      try {
        await onSave({
          day: value.day,
          hours_worked: Number(value.hoursWorked),
          operational_base: value.operationalBase.trim() || null,
          work_activities: value.workActivities.trim(),
          task_details: value.taskDetails.trim(),
          plan_next_day: value.planNextDay.trim(),
          status: 'draft',
          attachments: report?.attachments ?? [],
        })
      } catch (error) {
        const apiErrors = errorsFromApi(error)
        setFieldErrors(apiErrors)
        if (Object.keys(apiErrors).length) {
          window.requestAnimationFrame(() => focusFirstInvalid(formElement.current))
        } else {
          setFormError(presentError(error, 'form-submit').message)
        }
      }
    },
  })

  const reportId = report?.id
  useEffect(() => {
    if (!open || !report) return
    form.reset(valuesFromReport(report))
    // Refresh report details only when this dialog opens or changes records.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [form, open, reportId])

  useEffect(() => {
    if (Object.keys(fieldErrors).length) {
      window.requestAnimationFrame(() => focusFirstInvalid(formElement.current))
    }
  }, [fieldErrors])

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setFormError('')
    void form.handleSubmit()
  }

  return (
    <Dialog
      open={open}
      onOpenChange={(nextOpen) => {
        if (saving) return
        if (!nextOpen) {
          setFieldErrors({})
          setFormError('')
        }
        onOpenChange(nextOpen)
      }}
      title="Edit employee report"
      description={
        report
          ? `${report.employeeName?.trim() || `Employee #${report.employeeId}`} · ${report.day}`
          : 'Update the employee’s saved work report.'
      }
      size="lg"
      fitContent
      compactOnMobile
      dismissDisabled={saving}
      bodyClassName="space-y-4"
      footer={
        <>
          <Button variant="outline" disabled={saving} onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button
            type="submit"
            form="hr-work-report-edit-form"
            isLoading={saving}
            disabled={!report || loading || Boolean(loadError)}
          >
            Save changes
          </Button>
        </>
      }
    >
      {loading ? (
        <div className="space-y-3" aria-label="Loading report for editing" aria-busy="true">
          <div className="bg-surface-muted rounded-control h-12 animate-pulse" />
          <div className="bg-surface-muted rounded-control h-32 animate-pulse" />
          <div className="bg-surface-muted rounded-control h-32 animate-pulse" />
        </div>
      ) : loadError ? (
        <div className="space-y-3">
          <Alert tone="danger" title="Report details are unavailable">
            {loadError}
          </Alert>
          <Button variant="outline" onClick={onRetry}>
            Try again
          </Button>
        </div>
      ) : report ? (
        <form
          ref={formElement}
          id="hr-work-report-edit-form"
          noValidate
          onSubmit={submit}
          className="space-y-4"
        >
          <div className="flex flex-wrap items-center gap-2">
            <StatusChip
              label={report.status === 'rejected' ? 'Returned for revision' : 'Draft'}
              tone={report.status === 'rejected' ? 'danger' : 'neutral'}
              dense
            />
            <span className="text-caption text-text-secondary">Editing an employee submission</span>
          </div>
          {report.status === 'rejected' ? (
            <Alert tone="warning" title="This report will return to Draft">
              Saving clears the previous reviewer, rating, and feedback, as required by the report
              workflow.
            </Alert>
          ) : null}
          {formError ? (
            <Alert tone="danger" title="Report not saved" role="alert">
              {formError}
            </Alert>
          ) : null}
          <div className="tablet:grid-cols-2 grid min-w-0 gap-4">
            <form.Field name="day">
              {(field) => (
                <FormControl
                  id="hr-report-day"
                  label="Report date"
                  required
                  error={fieldErrors.day}
                >
                  <DatePickerField
                    value={field.state.value}
                    onValueChange={(value) => {
                      field.handleChange(value)
                      setFieldErrors((previous) => ({ ...previous, day: undefined }))
                    }}
                    placeholder="Choose a date"
                    aria-invalid={fieldErrors.day ? 'true' : undefined}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="hoursWorked">
              {(field) => (
                <FormControl
                  id="hr-report-hours"
                  label="Hours worked"
                  required
                  error={fieldErrors.hoursWorked}
                >
                  <TextInput
                    type="number"
                    min="0"
                    max="999.9"
                    step="0.1"
                    inputMode="decimal"
                    value={field.state.value}
                    onChange={(event) => {
                      field.handleChange(event.currentTarget.value)
                      setFieldErrors((previous) => ({ ...previous, hoursWorked: undefined }))
                    }}
                  />
                </FormControl>
              )}
            </form.Field>
          </div>
          <form.Field name="operationalBase">
            {(field) => (
              <FormControl
                id="hr-report-base"
                label="Operational base"
                error={fieldErrors.operationalBase}
              >
                <TextInput
                  maxLength={500}
                  value={field.state.value}
                  onChange={(event) => {
                    field.handleChange(event.currentTarget.value)
                    setFieldErrors((previous) => ({ ...previous, operationalBase: undefined }))
                  }}
                />
              </FormControl>
            )}
          </form.Field>
          <div className="tablet:grid-cols-2 grid min-w-0 gap-4">
            <form.Field name="workActivities">
              {(field) => (
                <FormControl id="hr-report-activities" label="Work completed">
                  <TextArea
                    rows={4}
                    value={field.state.value}
                    onChange={(event) => field.handleChange(event.currentTarget.value)}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="taskDetails">
              {(field) => (
                <FormControl id="hr-report-tasks" label="Task details">
                  <TextArea
                    rows={4}
                    value={field.state.value}
                    onChange={(event) => field.handleChange(event.currentTarget.value)}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="planNextDay">
              {(field) => (
                <FormControl id="hr-report-next-day" label="Plan for next day">
                  <TextArea
                    rows={3}
                    value={field.state.value}
                    onChange={(event) => field.handleChange(event.currentTarget.value)}
                  />
                </FormControl>
              )}
            </form.Field>
          </div>
          {report.attachments.length ? (
            <section className="border-border-subtle space-y-2 border-t pt-4">
              <h3 className="text-label text-text-primary font-semibold">Existing attachments</h3>
              <ul className="space-y-1">
                {report.attachments.map((attachment, index) => (
                  <li key={`${attachment}-${index}`}>
                    <a
                      className="text-body-sm text-primary break-all hover:underline"
                      href={attachment}
                      target="_blank"
                      rel="noreferrer"
                    >
                      Attachment {index + 1}
                    </a>
                  </li>
                ))}
              </ul>
              <p className="text-caption text-text-secondary">
                Existing attachments will be retained when you save.
              </p>
            </section>
          ) : null}
          <p className="text-caption text-text-secondary">
            This saves the report as a draft. Submitted and approved reports are not editable here.
          </p>
        </form>
      ) : null}
    </Dialog>
  )
}
