import { useEffect, useRef, useState, type FormEvent } from 'react'
import { useForm } from '@tanstack/react-form'

import { presentError } from '@/shared/errors'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { FormSection } from '@/shared/ui/form-section'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { FormControl, TextArea } from '@/shared/ui/form-control'

import type { LeaveRequest, LeaveRequestInput, LeaveRequestKind } from '../leaves.api'

const leaveTypes = [
  ['annual_leave', 'Annual leave'],
  ['sick_leave', 'Sick leave'],
  ['casual_leave', 'Casual leave'],
  ['maternity_leave', 'Maternity leave'],
  ['paternity_leave', 'Paternity leave'],
  ['unpaid_leave', 'Unpaid leave'],
  ['compassionate_leave', 'Compassionate leave'],
] as const

const requestKindOptions: DropdownSelectOption[] = [
  { value: 'leave', label: 'Leave' },
  { value: 'absence', label: 'Absence' },
  { value: 'running_late', label: 'Late arrival' },
]

const leaveTypeOptions: DropdownSelectOption[] = leaveTypes.map(([value, label]) => ({
  value,
  label,
}))

type FormValues = {
  requestKind: LeaveRequestKind
  leaveType: string
  startDate: string
  endDate: string
  reason: string
}

function valuesFromRequest(request?: LeaveRequest | null): FormValues {
  return {
    requestKind: request?.requestKind ?? 'leave',
    leaveType: request?.leaveType ?? '',
    startDate: request?.requestKind === 'running_late' ? '' : (request?.startDate ?? ''),
    endDate: request?.requestKind === 'running_late' ? '' : (request?.endDate ?? ''),
    reason: request?.reason ?? '',
  }
}

function validateValues(values: FormValues): Partial<Record<keyof FormValues, string>> {
  const errors: Partial<Record<keyof FormValues, string>> = {}
  if (values.requestKind === 'leave' && !values.leaveType) {
    errors.leaveType = 'Choose a leave type.'
  }
  if (values.requestKind !== 'running_late') {
    if (!values.startDate) errors.startDate = 'Choose a start date.'
    if (!values.endDate) errors.endDate = 'Choose an end date.'
    if (values.startDate && values.endDate && values.endDate < values.startDate) {
      errors.endDate = 'End date cannot be before the start date.'
    }
  }
  if (values.reason.trim().length < 3) errors.reason = 'Enter a reason of at least 3 characters.'
  return errors
}

function inputFromValues(values: FormValues): LeaveRequestInput {
  return {
    request_kind: values.requestKind,
    leave_type: values.requestKind === 'leave' ? values.leaveType : null,
    start_date: values.requestKind === 'running_late' ? null : values.startDate,
    end_date: values.requestKind === 'running_late' ? null : values.endDate,
    reason: values.reason.trim(),
  }
}

export function LeaveRequestFormDialog({
  open,
  onOpenChange,
  request,
  mode = request ? 'edit' : 'create',
  title,
  description,
  onSave,
  saving = false,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  request?: LeaveRequest | null
  mode?: 'create' | 'edit'
  title: string
  description?: string
  onSave: (input: LeaveRequestInput) => Promise<void>
  saving?: boolean
}) {
  const [fieldErrors, setFieldErrors] = useState<Partial<Record<keyof FormValues, string>>>({})
  const [formError, setFormError] = useState<string | null>(null)
  const formElement = useRef<HTMLFormElement>(null)
  const form = useForm({
    defaultValues: valuesFromRequest(request),
    onSubmit: async ({ value }) => {
      const errors = validateValues(value)
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

  const requestId = request?.id
  useEffect(() => {
    if (!open) return
    form.reset(valuesFromRequest(request))
    // Keep the draft stable while background refreshes replace the request object.
    // Rehydrate only when this dialog opens or switches request/mode.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [form, mode, open, requestId])

  function handleOpenChange(nextOpen: boolean) {
    if (!nextOpen) {
      setFieldErrors({})
      setFormError(null)
    }
    onOpenChange(nextOpen)
  }

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

  return (
    <Dialog
      open={open}
      onOpenChange={handleOpenChange}
      title={title}
      description={
        description ?? 'Submit the dates and reason for your request. Your manager will review it.'
      }
      size="lg"
      footer={
        <>
          <Button variant="outline" onClick={() => onOpenChange(false)} disabled={saving}>
            Cancel
          </Button>
          <Button type="submit" form="leave-request-form" isLoading={saving}>
            {mode === 'edit' ? 'Save changes' : 'Submit request'}
          </Button>
        </>
      }
    >
      <form
        id="leave-request-form"
        ref={formElement}
        noValidate
        onSubmit={submit}
        className="tablet:space-y-5 space-y-4"
      >
        {formError ? (
          <Alert tone="danger" title="Request not saved" role="alert">
            {formError}
          </Alert>
        ) : null}
        <form.Subscribe selector={(state) => state.values.requestKind}>
          {(requestKind) => (
            <>
              <FormSection
                aria-labelledby="leave-request-details-heading"
                className="tablet:space-y-5 space-y-4"
              >
                <div>
                  <h3 id="leave-request-details-heading" className="text-label font-semibold">
                    Request details
                  </h3>
                  <p className="text-body-sm text-text-secondary mt-1">
                    Choose the request type and the dates you need.
                  </p>
                </div>

                <div
                  className={
                    requestKind === 'leave' ? 'phone:grid-cols-2 grid gap-4' : 'grid gap-4'
                  }
                >
                  <form.Field name="requestKind">
                    {(field) => (
                      <FormControl id="leave-request-kind" label="Request type" required>
                        <DropdownSelect
                          value={field.state.value}
                          options={requestKindOptions}
                          onChange={(value) => {
                            field.handleChange(value as LeaveRequestKind)
                            setFieldErrors({})
                          }}
                          disabled={mode === 'edit'}
                        />
                      </FormControl>
                    )}
                  </form.Field>

                  {requestKind === 'leave' ? (
                    <form.Field name="leaveType">
                      {(field) => (
                        <FormControl
                          id="leave-request-type"
                          label="Leave type"
                          required
                          error={fieldErrors.leaveType}
                        >
                          <DropdownSelect
                            value={field.state.value}
                            options={leaveTypeOptions}
                            placeholder="Choose a leave type"
                            onChange={(value) => {
                              field.handleChange(value)
                              setFieldErrors((previous) => ({
                                ...previous,
                                leaveType: undefined,
                              }))
                            }}
                            aria-invalid={fieldErrors.leaveType ? 'true' : undefined}
                          />
                        </FormControl>
                      )}
                    </form.Field>
                  ) : null}
                </div>

                {requestKind === 'running_late' ? (
                  <div className="bg-info-subtle text-body-sm text-text-secondary rounded-control border-info/20 border px-3.5 py-3">
                    The report date is set to today when you submit.
                  </div>
                ) : (
                  <div className="border-border-subtle space-y-3 border-t pt-4">
                    <div>
                      <h4 className="text-label font-semibold">Requested dates</h4>
                      <p className="text-body-sm text-text-secondary mt-1">
                        Choose the first and last day of the period.
                      </p>
                    </div>
                    <div className="phone:grid-cols-2 grid gap-4">
                      <form.Field name="startDate">
                        {(field) => (
                          <FormControl
                            id="leave-start-date"
                            label="Start date"
                            required
                            error={fieldErrors.startDate}
                          >
                            <DatePickerField
                              value={field.state.value}
                              max={form.state.values.endDate || undefined}
                              onValueChange={(value) => {
                                field.handleChange(value)
                                setFieldErrors((previous) => ({
                                  ...previous,
                                  startDate: undefined,
                                }))
                              }}
                              required
                              aria-invalid={fieldErrors.startDate ? 'true' : undefined}
                            />
                          </FormControl>
                        )}
                      </form.Field>
                      <form.Field name="endDate">
                        {(field) => (
                          <FormControl
                            id="leave-end-date"
                            label="End date"
                            required
                            error={fieldErrors.endDate}
                          >
                            <DatePickerField
                              value={field.state.value}
                              min={form.state.values.startDate || undefined}
                              onValueChange={(value) => {
                                field.handleChange(value)
                                setFieldErrors((previous) => ({
                                  ...previous,
                                  endDate: undefined,
                                }))
                              }}
                              required
                              aria-invalid={fieldErrors.endDate ? 'true' : undefined}
                            />
                          </FormControl>
                        )}
                      </form.Field>
                    </div>
                  </div>
                )}
              </FormSection>

              <FormSection>
                <form.Field name="reason">
                  {(field) => (
                    <FormControl
                      id="leave-request-reason"
                      label="Reason"
                      description={
                        requestKind === 'running_late'
                          ? 'Explain what may delay your arrival.'
                          : requestKind === 'absence'
                            ? 'Briefly explain the reason for your absence.'
                            : 'Briefly explain why you need this leave.'
                      }
                      required
                      error={fieldErrors.reason}
                    >
                      <TextArea
                        rows={4}
                        placeholder={
                          requestKind === 'running_late'
                            ? 'Explain the reason for your delay'
                            : requestKind === 'absence'
                              ? 'Explain the reason for your absence'
                              : 'Explain the reason for your leave'
                        }
                        value={field.state.value}
                        aria-invalid={fieldErrors.reason ? 'true' : undefined}
                        onChange={(event) => {
                          field.handleChange(event.target.value)
                          setFieldErrors((previous) => ({ ...previous, reason: undefined }))
                        }}
                      />
                    </FormControl>
                  )}
                </form.Field>
              </FormSection>
            </>
          )}
        </form.Subscribe>
      </form>
    </Dialog>
  )
}
