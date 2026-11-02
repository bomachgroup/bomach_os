import { useLayoutEffect, useRef, useState, type FormEvent } from 'react'

import type { EmployeeDto } from '@/modules/hr/employees.api'
import { presentError } from '@/shared/errors'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { TimePickerField } from '@/shared/ui/time-picker-field'

import type { InterviewInput, OfferLetterInput } from '../recruitment.api'

type Props = {
  mode: 'interview' | 'offer'
  open: boolean
  onOpenChange: (open: boolean) => void
  saving: boolean
  onSave: (input: InterviewInput | OfferLetterInput) => Promise<void>
  interviewers?: EmployeeDto[]
  interviewersLoading?: boolean
  interviewersError?: string
  canListInterviewers?: boolean
  onRetryInterviewers?: () => void
}

const OFFER_TEMPLATES = [
  { value: 'standard_full_time', label: 'Standard full-time' },
  { value: 'standard_part_time', label: 'Standard part-time' },
  { value: 'contract', label: 'Contract' },
  { value: 'internship', label: 'Internship' },
]

function today() {
  const now = new Date()
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
}

function isValidSalary(value: string) {
  return /^\d{1,10}(?:\.\d{1,2})?$/.test(value.trim())
}

function employeeName(employee: EmployeeDto) {
  return [employee.first_name, employee.middle_name, employee.last_name].filter(Boolean).join(' ')
}

function formatSalary(value: string) {
  const normalized = value.replaceAll(',', '').trim()
  if (!isValidSalary(normalized)) return value
  return new Intl.NumberFormat('en-NG', { maximumFractionDigits: 2 }).format(Number(normalized))
}

function formatSalaryInput(value: string) {
  const normalized = value.replaceAll(',', '')
  if (!/^\d*(?:\.\d*)?$/.test(normalized)) return value

  const [whole = '', fraction] = normalized.split('.')
  const groupedWhole = whole.replace(/\B(?=(\d{3})+(?!\d))/g, ',')
  return fraction === undefined ? groupedWhole : `${groupedWhole}.${fraction}`
}

function groupedCaretPosition(value: string, characterCount: number) {
  if (characterCount === 0) return 0
  let charactersSeen = 0
  for (let index = 0; index < value.length; index += 1) {
    if (value[index] !== ',') charactersSeen += 1
    if (charactersSeen >= characterCount) return index + 1
  }
  return value.length
}

export function ApplicantWorkflowFormDialog({
  mode,
  open,
  onOpenChange,
  saving,
  onSave,
  interviewers = [],
  interviewersLoading = false,
  interviewersError,
  canListInterviewers = true,
  onRetryInterviewers,
}: Props) {
  const [interviewerId, setInterviewerId] = useState('')
  const [scheduledDate, setScheduledDate] = useState('')
  const [scheduledTime, setScheduledTime] = useState('')
  const [meetingLink, setMeetingLink] = useState('')
  const [template, setTemplate] = useState('standard_full_time')
  const [salary, setSalary] = useState('')
  const salaryInputRef = useRef<HTMLInputElement>(null)
  const pendingSalaryCaretRef = useRef<number | null>(null)
  const [startDate, setStartDate] = useState('')
  const [content, setContent] = useState('')
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({})
  const [submitError, setSubmitError] = useState('')

  useLayoutEffect(() => {
    const characterCount = pendingSalaryCaretRef.current
    const input = salaryInputRef.current
    if (characterCount === null || !input) return
    pendingSalaryCaretRef.current = null
    const position = groupedCaretPosition(input.value, characterCount)
    input.setSelectionRange(position, position)
  }, [salary])

  function clearFieldError(field: string) {
    setFieldErrors((current) => {
      if (!current[field]) return current
      const next = { ...current }
      delete next[field]
      return next
    })
    setSubmitError('')
  }

  function showFieldErrors(next: Record<string, string>) {
    setFieldErrors(next)
    const firstField = Object.keys(next)[0]
    if (firstField) {
      window.requestAnimationFrame(() => document.getElementById(firstField)?.focus())
    }
  }

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setFieldErrors({})
    setSubmitError('')
    if (mode === 'interview') {
      const interviewer = Number(interviewerId)
      const nextErrors: Record<string, string> = {}
      if (!Number.isSafeInteger(interviewer) || interviewer <= 0) {
        nextErrors['interviewer-employee-id'] = 'Select an active employee.'
      }
      if (interviewer > 0 && !interviewers.some((employee) => employee.id === interviewer)) {
        nextErrors['interviewer-employee-id'] = 'Select an active employee from the list.'
      }
      if (!scheduledDate) {
        nextErrors['interview-date'] = 'Choose an interview date.'
      } else if (scheduledDate < today()) {
        nextErrors['interview-date'] = 'Interview date cannot be in the past.'
      }
      if (!scheduledTime) {
        nextErrors['interview-time'] = 'Choose an interview time.'
      }
      let link: string | null = null
      if (meetingLink.trim()) {
        try {
          const parsed = new URL(meetingLink.trim())
          if (!['https:', 'http:'].includes(parsed.protocol)) throw new Error()
          link = parsed.toString()
        } catch {
          nextErrors['interview-meeting-link'] = 'Enter a valid http or https meeting link.'
        }
      }
      if (Object.keys(nextErrors).length) {
        showFieldErrors(nextErrors)
        return
      }
      try {
        await onSave({
          interviewer_id: interviewer,
          scheduled_at: new Date(`${scheduledDate}T${scheduledTime}:00`).toISOString(),
          meeting_link: link,
        } satisfies InterviewInput)
      } catch (cause) {
        setSubmitError(presentError(cause, 'form-submit').message)
      }
      return
    }

    const normalizedSalary = salary.replaceAll(',', '').trim()
    const annualSalary = Number(normalizedSalary)
    const nextErrors: Record<string, string> = {}
    if (!Number.isFinite(annualSalary) || annualSalary <= 0 || !isValidSalary(normalizedSalary)) {
      nextErrors['offer-salary'] =
        'Enter an annual salary greater than zero, with up to two decimals.'
    }
    if (!startDate || startDate < today()) {
      nextErrors['offer-start-date'] = 'Choose a start date that is today or later.'
    }
    if (content.trim().length < 10) {
      nextErrors['offer-letter-content'] = 'Enter at least 10 characters of offer letter content.'
    }
    if (Object.keys(nextErrors).length) {
      showFieldErrors(nextErrors)
      return
    }
    try {
      await onSave({
        template,
        annual_salary: annualSalary,
        start_date: new Date(`${startDate}T00:00:00`).toISOString(),
        letter_content: content.trim(),
      } satisfies OfferLetterInput)
    } catch (cause) {
      setSubmitError(presentError(cause, 'form-submit').message)
    }
  }

  const title = mode === 'interview' ? 'Schedule interview' : 'Create offer letter'
  return (
    <Dialog
      open={open}
      onOpenChange={onOpenChange}
      title={title}
      description={
        mode === 'interview'
          ? 'Set the interviewer, date, time, and meeting link.'
          : 'Prepare the candidate’s offer details and letter content.'
      }
      size="md"
      dismissDisabled={saving}
      footer={
        <>
          <Button variant="outline" disabled={saving} onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button
            type="submit"
            form="applicant-workflow-form"
            isLoading={saving}
            disabled={
              saving ||
              (mode === 'interview' &&
                (!canListInterviewers || interviewersLoading || Boolean(interviewersError)))
            }
          >
            {mode === 'interview' ? 'Schedule interview' : 'Create offer letter'}
          </Button>
        </>
      }
    >
      <form
        id="applicant-workflow-form"
        onSubmit={(event) => void submit(event)}
        noValidate
        className="space-y-4"
      >
        {submitError ? (
          <Alert tone="danger" title="Details need attention" role="alert">
            {submitError}
          </Alert>
        ) : null}
        {mode === 'interview' ? (
          <>
            {!canListInterviewers ? (
              <Alert tone="info" title="Employee directory access required">
                Your account needs permission to list active employees before an interviewer can be
                selected.
              </Alert>
            ) : interviewersError ? (
              <Alert tone="warning" title="Interviewers could not load">
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <span>{interviewersError}</span>
                  {onRetryInterviewers ? (
                    <Button size="sm" variant="outline" onClick={onRetryInterviewers}>
                      Retry
                    </Button>
                  ) : null}
                </div>
              </Alert>
            ) : !interviewersLoading && interviewers.length === 0 ? (
              <Alert tone="info" title="No active employees available">
                An active employee must be available before this interview can be scheduled.
              </Alert>
            ) : null}
            <FormControl
              id="interviewer-employee-id"
              label="Interviewer"
              required
              error={fieldErrors['interviewer-employee-id']}
            >
              <DropdownSelect
                value={interviewerId}
                options={interviewers.map((employee) => ({
                  value: String(employee.id),
                  label: employeeName(employee) || employee.employee_id,
                  description: [
                    employee.designation,
                    employee.department_name,
                    employee.branch_name,
                  ]
                    .filter(Boolean)
                    .join(' · '),
                }))}
                onChange={(value) => {
                  setInterviewerId(value)
                  clearFieldError('interviewer-employee-id')
                }}
                searchable
                disabled={!canListInterviewers || interviewersLoading || Boolean(interviewersError)}
                placeholder={
                  interviewersLoading ? 'Loading active employees…' : 'Select an employee'
                }
                emptyMessage="No matching active employees."
              />
            </FormControl>
            <div className="phone:grid-cols-2 grid gap-4">
              <FormControl
                id="interview-date"
                label="Date"
                required
                error={fieldErrors['interview-date']}
              >
                <DatePickerField
                  value={scheduledDate}
                  onValueChange={(value) => {
                    setScheduledDate(value)
                    clearFieldError('interview-date')
                  }}
                  min={today()}
                />
              </FormControl>
              <FormControl
                id="interview-time"
                label="Local time"
                required
                error={fieldErrors['interview-time']}
              >
                <TimePickerField
                  value={scheduledTime}
                  onValueChange={(value) => {
                    setScheduledTime(value)
                    clearFieldError('interview-time')
                  }}
                />
              </FormControl>
            </div>
            <FormControl
              id="interview-meeting-link"
              label="Meeting link"
              error={fieldErrors['interview-meeting-link']}
            >
              <TextInput
                type="url"
                value={meetingLink}
                onChange={(event) => {
                  setMeetingLink(event.currentTarget.value)
                  clearFieldError('interview-meeting-link')
                }}
                placeholder="https://meet.example.com/…"
              />
            </FormControl>
          </>
        ) : (
          <>
            <FormControl id="offer-template" label="Offer template" required>
              <DropdownSelect value={template} options={OFFER_TEMPLATES} onChange={setTemplate} />
            </FormControl>
            <div className="grid grid-cols-2 items-start gap-3">
              <FormControl
                id="offer-salary"
                label="Annual salary (₦)"
                required
                error={fieldErrors['offer-salary']}
              >
                <TextInput
                  ref={salaryInputRef}
                  type="text"
                  inputMode="decimal"
                  autoComplete="off"
                  value={salary}
                  onChange={(event) => {
                    const input = event.currentTarget
                    pendingSalaryCaretRef.current = input.value
                      .slice(0, input.selectionStart ?? input.value.length)
                      .replaceAll(',', '').length
                    setSalary(formatSalaryInput(input.value))
                    clearFieldError('offer-salary')
                  }}
                  onBlur={() => setSalary((value) => formatSalary(value))}
                />
              </FormControl>
              <FormControl
                id="offer-start-date"
                label="Start date"
                required
                error={fieldErrors['offer-start-date']}
              >
                <DatePickerField
                  value={startDate}
                  onValueChange={(value) => {
                    setStartDate(value)
                    clearFieldError('offer-start-date')
                  }}
                  min={today()}
                />
              </FormControl>
            </div>
            <FormControl
              id="offer-letter-content"
              label="Letter content"
              required
              error={fieldErrors['offer-letter-content']}
            >
              <TextArea
                rows={6}
                maxLength={10000}
                value={content}
                onChange={(event) => {
                  setContent(event.currentTarget.value)
                  clearFieldError('offer-letter-content')
                }}
              />
            </FormControl>
            <p className="text-caption text-text-muted">
              The letter is saved to the candidate’s profile. Candidate delivery is managed
              separately.
            </p>
          </>
        )}
      </form>
    </Dialog>
  )
}
