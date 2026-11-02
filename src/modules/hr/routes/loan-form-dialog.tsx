import { useLayoutEffect, useRef, useState, type FormEvent } from 'react'
import { useForm, useSelector } from '@tanstack/react-form'
import { Banknote, FileText, ImagePlus, Paperclip, UserRound, X } from 'lucide-react'

import type { EmployeeDto } from '@/modules/hr/employees.api'
import { presentError } from '@/shared/errors'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'

import type { LoanCreateInput, LoanRequest, LoanUpdateInput } from '../loans.api'
import { formatLoanAmountInput, groupedLoanCaretPosition } from '../loans.presentation'

type Values = {
  employee_user_id: string
  loan_amount: string
  repayment_date: string
  reason: string
  emergency_contact_name: string
  emergency_contact_phone: string
  attachment: string
}

const today = () => {
  const date = new Date()
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

function valuesFor(
  loan: LoanRequest | null,
  currentUserId: number,
  canChooseEmployee: boolean,
): Values {
  return {
    employee_user_id: String(loan?.employee_user_id ?? (canChooseEmployee ? '' : currentUserId)),
    loan_amount: loan
      ? (formatLoanAmountInput(loan.loan_amount) ?? loan.loan_amount.replaceAll(',', ''))
      : '',
    repayment_date: loan?.repayment_date ?? '',
    reason: loan?.reason ?? '',
    emergency_contact_name: loan?.emergency_contact_name ?? '',
    emergency_contact_phone: loan?.emergency_contact_phone ?? '',
    attachment: loan?.attachment ?? '',
  }
}

function validate(values: Values, canChooseEmployee: boolean) {
  const errors: Partial<Record<keyof Values, string>> = {}
  if (canChooseEmployee && !values.employee_user_id) errors.employee_user_id = 'Choose an employee.'
  const normalizedAmount = values.loan_amount.replaceAll(',', '').trim()
  if (
    !/^\d{1,8}(?:\.\d{1,2})?$/.test(normalizedAmount) ||
    !Number.isFinite(Number(normalizedAmount)) ||
    Number(normalizedAmount) <= 0
  ) {
    errors.loan_amount = 'Enter a positive amount with up to 8 whole digits and 2 decimal places.'
  }
  if (!values.repayment_date) errors.repayment_date = 'Choose the planned repayment date.'
  else if (values.repayment_date <= today())
    errors.repayment_date = 'Repayment date must be in the future.'
  if (values.reason.trim().length < 3) errors.reason = 'Enter a reason of at least 3 characters.'
  if (!values.emergency_contact_name.trim())
    errors.emergency_contact_name = 'Enter an emergency contact name.'
  if (!values.emergency_contact_phone.trim())
    errors.emergency_contact_phone = 'Enter an emergency contact phone.'
  if (values.emergency_contact_phone.length > 20)
    errors.emergency_contact_phone = 'Use 20 characters or fewer.'
  if (values.attachment && !/^https?:\/\//i.test(values.attachment.trim())) {
    errors.attachment = 'Enter a full http or https link.'
  }
  return errors
}

const MAX_ATTACHMENT_BYTES = 15 * 1024 * 1024
const ALLOWED_ATTACHMENT_EXTENSION = /\.(gif|jpe?g|png|webp|pdf|docx?|xlsx?|pptx?)$/i

function attachmentFileError(file: File) {
  if (file.size === 0) return 'Choose a file that is not empty.'
  if (!ALLOWED_ATTACHMENT_EXTENSION.test(file.name)) {
    return 'Choose an image, PDF, or Office document.'
  }
  if (file.size > MAX_ATTACHMENT_BYTES) return 'Choose a file that is 15 MB or smaller.'
  return ''
}

function attachmentFileSize(file: File) {
  return file.size >= 1024 * 1024
    ? `${(file.size / (1024 * 1024)).toFixed(1)} MB`
    : `${Math.max(1, Math.ceil(file.size / 1024))} KB`
}

export function LoanFormDialog({
  open,
  onOpenChange,
  loan,
  currentUserId,
  currentEmployeeName,
  employees,
  canChooseEmployee,
  employeeChoicesLoading,
  employeeChoicesError,
  onRetryEmployees,
  saving,
  onUploadAttachment,
  canSubmit = true,
  onSave,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  loan: LoanRequest | null
  currentUserId: number
  currentEmployeeName: string
  employees: EmployeeDto[]
  canChooseEmployee: boolean
  employeeChoicesLoading: boolean
  employeeChoicesError?: unknown
  onRetryEmployees: () => void
  saving: boolean
  onUploadAttachment: (file: File) => Promise<string>
  canSubmit?: boolean
  onSave: (input: LoanCreateInput | LoanUpdateInput) => Promise<void>
}) {
  const [errors, setErrors] = useState<Partial<Record<keyof Values, string>>>({})
  const [formError, setFormError] = useState('')
  const [selectedAttachment, setSelectedAttachment] = useState<File | null>(null)
  const [uploadingAttachment, setUploadingAttachment] = useState(false)
  const uploadingRef = useRef(false)
  const attachmentInputRef = useRef<HTMLInputElement>(null)
  const amountInputRef = useRef<HTMLInputElement>(null)
  const pendingAmountCaretRef = useRef<number | null>(null)
  const form = useForm({
    defaultValues: valuesFor(loan, currentUserId, canChooseEmployee),
    onSubmit: async ({ value }) => {
      if (uploadingRef.current) return
      const nextErrors = validate(value, canChooseEmployee && !loan)
      setErrors(nextErrors)
      setFormError('')
      const firstInvalid = Object.keys(nextErrors)[0] as keyof Values | undefined
      if (firstInvalid) {
        const controlId: Record<keyof Values, string> = {
          employee_user_id: 'loan-employee',
          loan_amount: 'loan-amount',
          repayment_date: 'loan-repayment-date',
          reason: 'loan-reason',
          emergency_contact_name: 'loan-contact-name',
          emergency_contact_phone: 'loan-contact-phone',
          attachment: 'loan-attachment',
        }
        window.requestAnimationFrame(() =>
          document.getElementById(controlId[firstInvalid])?.focus(),
        )
        return
      }
      let attachment = value.attachment.trim()
      if (selectedAttachment) {
        uploadingRef.current = true
        setUploadingAttachment(true)
        setFormError('')
        try {
          attachment = await onUploadAttachment(selectedAttachment)
          if (!/^https?:\/\//i.test(attachment)) {
            throw new Error('The uploaded document did not return a valid link.')
          }
          form.setFieldValue('attachment', attachment)
          setSelectedAttachment(null)
          setErrors((current) => ({ ...current, attachment: undefined }))
        } catch (error) {
          setErrors((current) => ({
            ...current,
            attachment: presentError(error, 'form-submit').message,
          }))
          uploadingRef.current = false
          setUploadingAttachment(false)
          window.requestAnimationFrame(() => document.getElementById('loan-attachment')?.focus())
          return
        }
      }
      const common = {
        loan_amount: Number(value.loan_amount.replaceAll(',', '')),
        repayment_date: value.repayment_date,
        reason: value.reason.trim(),
        emergency_contact_name: value.emergency_contact_name.trim(),
        emergency_contact_phone: value.emergency_contact_phone.trim(),
        attachment: attachment || undefined,
      }
      const input = loan
        ? common
        : {
            ...common,
            ...(canChooseEmployee ? { employee_user_id: Number(value.employee_user_id) } : {}),
          }
      try {
        await onSave(input)
      } catch (error) {
        setFormError(presentError(error, 'form-submit').message)
      } finally {
        if (selectedAttachment || uploadingRef.current) {
          uploadingRef.current = false
          setUploadingAttachment(false)
        }
      }
    },
  })
  const amountValue = useSelector(form.store, (state) => state.values.loan_amount)
  const isBusy = saving || uploadingAttachment

  useLayoutEffect(() => {
    const characterCount = pendingAmountCaretRef.current
    const input = amountInputRef.current
    if (characterCount === null || !input) return
    pendingAmountCaretRef.current = null
    const position = groupedLoanCaretPosition(input.value, characterCount)
    input.setSelectionRange(position, position)
  }, [amountValue])

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setFormError('')
    void form.handleSubmit()
  }
  const clear = (key: keyof Values) => {
    setErrors((current) => ({ ...current, [key]: undefined }))
    setFormError('')
  }
  const employeeOptions = employees.map((employee) => ({
    value: String(employee.user_id),
    label: `${[employee.first_name, employee.last_name].filter(Boolean).join(' ') || employee.username}${employee.employee_id ? ` · ${employee.employee_id}` : ''}`,
    description: [employee.designation, employee.branch_name].filter(Boolean).join(' · '),
  }))

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!isBusy) {
          if (!next) {
            setErrors({})
            setFormError('')
          }
          onOpenChange(next)
        }
      }}
      title={loan ? 'Edit loan request' : 'New loan request'}
      description={
        loan
          ? 'Update this request while it is awaiting a decision.'
          : 'Record the applicant, amount and repayment plan for review.'
      }
      size="lg"
      dismissDisabled={isBusy}
      footer={
        <>
          <Button variant="outline" disabled={isBusy} onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button type="submit" form="loan-form" isLoading={isBusy} disabled={!canSubmit}>
            {uploadingAttachment ? 'Uploading document…' : loan ? 'Save changes' : 'Submit request'}
          </Button>
        </>
      }
    >
      <form id="loan-form" noValidate onSubmit={submit} className="space-y-4">
        {formError ? (
          <Alert tone="danger" title="Loan request not saved" role="alert">
            {formError}
          </Alert>
        ) : null}
        <fieldset disabled={isBusy} className="m-0 min-w-0 space-y-4 border-0 p-0">
          <FormSection className="space-y-4">
            <div className="flex items-start gap-3">
              <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
                <UserRound className="size-5" />
              </span>
              <div>
                <h3 className="text-label font-semibold">Applicant</h3>
                <p className="text-body-sm text-text-secondary mt-1">
                  Choose the employee this request is for.
                </p>
              </div>
            </div>
            {canChooseEmployee && !loan ? (
              <form.Field name="employee_user_id">
                {(field) => (
                  <FormControl
                    id="loan-employee"
                    label="Employee"
                    required
                    error={errors.employee_user_id}
                  >
                    <DropdownSelect
                      value={field.state.value}
                      options={employeeOptions}
                      placeholder={
                        employeeChoicesLoading ? 'Loading employees…' : 'Choose an employee'
                      }
                      searchable
                      disabled={employeeChoicesLoading || Boolean(employeeChoicesError)}
                      onChange={(value) => {
                        field.handleChange(value)
                        clear('employee_user_id')
                      }}
                    />
                  </FormControl>
                )}
              </form.Field>
            ) : (
              <div className="bg-surface rounded-control border-border-subtle border p-3">
                <p className="text-caption text-text-secondary">Applicant</p>
                <p className="text-body-sm mt-1 font-medium">
                  {loan?.employee_name ?? currentEmployeeName}
                </p>
              </div>
            )}
            {employeeChoicesError && canChooseEmployee && !loan ? (
              <Alert tone="warning" title="Employee choices could not load">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <span>You can retry loading the employee directory.</span>
                  <Button size="sm" variant="outline" onClick={onRetryEmployees}>
                    Retry
                  </Button>
                </div>
              </Alert>
            ) : null}
            {!employeeChoicesError &&
            !employeeChoicesLoading &&
            canChooseEmployee &&
            !loan &&
            employees.length === 0 ? (
              <Alert tone="warning" title="No active employees available">
                This request cannot be assigned until an active employee is available in your access
                scope.
              </Alert>
            ) : null}
          </FormSection>
          <FormSection className="space-y-4">
            <div className="flex items-start gap-3">
              <span className="bg-success-subtle text-success-foreground rounded-control flex size-10 shrink-0 items-center justify-center">
                <Banknote className="size-5" />
              </span>
              <div>
                <h3 className="text-label font-semibold">Request terms</h3>
                <p className="text-body-sm text-text-secondary mt-1">
                  Add the amount and planned repayment date.
                </p>
              </div>
            </div>
            <div className="phone:grid-cols-2 grid gap-4">
              <form.Field name="loan_amount">
                {(field) => (
                  <FormControl
                    id="loan-amount"
                    label="Loan amount (₦)"
                    required
                    error={errors.loan_amount}
                  >
                    <TextInput
                      ref={amountInputRef}
                      type="text"
                      inputMode="decimal"
                      autoComplete="off"
                      value={field.state.value}
                      onChange={(event) => {
                        const input = event.currentTarget
                        const characterCount = input.value
                          .slice(0, input.selectionStart ?? input.value.length)
                          .replaceAll(',', '').length
                        const formatted = formatLoanAmountInput(input.value)
                        if (formatted === null) return
                        pendingAmountCaretRef.current = characterCount
                        field.handleChange(formatted)
                        clear('loan_amount')
                      }}
                    />
                  </FormControl>
                )}
              </form.Field>
              <form.Field name="repayment_date">
                {(field) => (
                  <FormControl
                    id="loan-repayment-date"
                    label="Planned repayment date"
                    required
                    error={errors.repayment_date}
                  >
                    <DatePickerField
                      value={field.state.value}
                      min={today()}
                      onValueChange={(value) => {
                        field.handleChange(value)
                        clear('repayment_date')
                      }}
                      required
                    />
                  </FormControl>
                )}
              </form.Field>
            </div>
            <form.Field name="reason">
              {(field) => (
                <FormControl
                  id="loan-reason"
                  label="Reason for request"
                  required
                  error={errors.reason}
                >
                  <TextArea
                    rows={4}
                    maxLength={500}
                    placeholder="Explain the purpose of the loan."
                    value={field.state.value}
                    onChange={(event) => {
                      field.handleChange(event.currentTarget.value)
                      clear('reason')
                    }}
                  />
                </FormControl>
              )}
            </form.Field>
          </FormSection>
          <FormSection className="space-y-4">
            <div>
              <h3 className="text-label font-semibold">Emergency contact</h3>
              <p className="text-body-sm text-text-secondary mt-1">
                A contact person for urgent follow-up.
              </p>
            </div>
            <div className="phone:grid-cols-2 grid gap-4">
              <form.Field name="emergency_contact_name">
                {(field) => (
                  <FormControl
                    id="loan-contact-name"
                    label="Contact name"
                    required
                    error={errors.emergency_contact_name}
                  >
                    <TextInput
                      maxLength={255}
                      value={field.state.value}
                      onChange={(event) => {
                        field.handleChange(event.currentTarget.value)
                        clear('emergency_contact_name')
                      }}
                    />
                  </FormControl>
                )}
              </form.Field>
              <form.Field name="emergency_contact_phone">
                {(field) => (
                  <FormControl
                    id="loan-contact-phone"
                    label="Contact phone"
                    required
                    error={errors.emergency_contact_phone}
                  >
                    <TextInput
                      type="tel"
                      maxLength={20}
                      value={field.state.value}
                      onChange={(event) => {
                        field.handleChange(event.currentTarget.value)
                        clear('emergency_contact_phone')
                      }}
                    />
                  </FormControl>
                )}
              </form.Field>
            </div>
            <form.Field name="attachment">
              {(field) => (
                <div className="space-y-1.5">
                  <p className="text-caption text-text-primary font-medium">Supporting document</p>
                  <p id="loan-attachment-description" className="text-caption text-text-muted">
                    Optional · Images, PDF, or Office documents · up to 15 MB
                  </p>
                  <input
                    ref={attachmentInputRef}
                    id="loan-attachment-input"
                    type="file"
                    accept="image/gif,image/jpeg,image/png,image/webp,.gif,.jpg,.jpeg,.png,.webp,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx"
                    className="sr-only"
                    aria-label="Choose supporting document"
                    aria-describedby={`loan-attachment-description${errors.attachment ? ' loan-attachment-error' : ''}`}
                    aria-invalid={Boolean(errors.attachment)}
                    onChange={(event) => {
                      const file = event.currentTarget.files?.[0]
                      event.currentTarget.value = ''
                      if (!file) return
                      const error = attachmentFileError(file)
                      setErrors((current) => ({ ...current, attachment: error || undefined }))
                      setSelectedAttachment(error ? null : file)
                      setFormError('')
                    }}
                  />
                  <div className="border-border-subtle bg-surface rounded-control space-y-3 border p-3">
                    <div className="flex flex-wrap items-center justify-between gap-3">
                      <div className="flex min-w-0 items-center gap-3">
                        <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
                          <ImagePlus className="size-5" aria-hidden="true" />
                        </span>
                        <div className="min-w-0">
                          <p className="text-body-sm font-medium">
                            {selectedAttachment ? 'Ready to upload' : 'Add supporting evidence'}
                          </p>
                          <p className="text-caption text-text-secondary mt-0.5">
                            {selectedAttachment
                              ? `${attachmentFileSize(selectedAttachment)} · Uploads when you save`
                              : 'Select one image or document from your device.'}
                          </p>
                        </div>
                      </div>
                      <Button
                        id="loan-attachment"
                        type="button"
                        size="sm"
                        variant="outline"
                        disabled={isBusy}
                        aria-invalid={Boolean(errors.attachment)}
                        aria-describedby={`loan-attachment-description${errors.attachment ? ' loan-attachment-error' : ''}`}
                        leadingIcon={<Paperclip className="size-3.5" aria-hidden="true" />}
                        onClick={() => attachmentInputRef.current?.click()}
                      >
                        {selectedAttachment || field.state.value ? 'Replace file' : 'Choose file'}
                      </Button>
                    </div>
                    {selectedAttachment ? (
                      <div className="bg-surface-muted rounded-control flex min-w-0 items-center justify-between gap-2 px-3 py-2">
                        <span className="text-caption flex min-w-0 items-center gap-2">
                          <FileText className="text-primary size-4 shrink-0" aria-hidden="true" />
                          <span className="truncate">{selectedAttachment.name}</span>
                        </span>
                        <button
                          type="button"
                          className="text-text-secondary hover:text-text-primary focus-visible:shadow-focus-ring rounded-full p-1 focus-visible:outline-none"
                          aria-label={`Remove ${selectedAttachment.name}`}
                          onClick={() => {
                            setSelectedAttachment(null)
                            clear('attachment')
                          }}
                        >
                          <X className="size-4" aria-hidden="true" />
                        </button>
                      </div>
                    ) : null}
                    {field.state.value ? (
                      <div className="border-border-subtle flex min-w-0 flex-wrap items-center justify-between gap-2 border-t pt-3">
                        {/^https?:\/\//i.test(field.state.value) ? (
                          <a
                            href={field.state.value}
                            target="_blank"
                            rel="noreferrer"
                            className="text-primary text-caption inline-flex min-w-0 items-center gap-2 underline"
                          >
                            <FileText className="size-4 shrink-0" aria-hidden="true" />
                            <span className="truncate">
                              {selectedAttachment
                                ? 'Current document (will be replaced)'
                                : 'View current document'}
                            </span>
                          </a>
                        ) : (
                          <span className="text-caption text-text-secondary inline-flex min-w-0 items-center gap-2">
                            <FileText className="size-4 shrink-0" aria-hidden="true" />
                            <span className="truncate">Existing document</span>
                          </span>
                        )}
                        <button
                          type="button"
                          className="text-caption text-text-secondary hover:text-danger-foreground inline-flex items-center gap-1"
                          aria-label="Remove current supporting document"
                          onClick={() => {
                            field.handleChange('')
                            clear('attachment')
                          }}
                        >
                          <X className="size-3.5" aria-hidden="true" />
                          Remove
                        </button>
                      </div>
                    ) : null}
                  </div>
                  {errors.attachment ? (
                    <p
                      id="loan-attachment-error"
                      className="text-caption text-danger-foreground"
                      role="status"
                    >
                      {errors.attachment}
                    </p>
                  ) : null}
                </div>
              )}
            </form.Field>
          </FormSection>
        </fieldset>
      </form>
    </Dialog>
  )
}
