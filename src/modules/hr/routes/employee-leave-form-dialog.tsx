import { useState, type FormEvent } from 'react'

import type {
  EmployeeDto,
  EmployeeLeavePeriodCreateInput,
  EmployeeLeavePeriodDto,
  EmployeeLeaveReturnInput,
} from '@/modules/hr/employees.api'
import { presentError } from '@/shared/errors'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { FormControl, TextArea } from '@/shared/ui/form-control'

const leaveTypes: DropdownSelectOption[] = [
  { value: 'annual_leave', label: 'Annual leave' },
  { value: 'sick_leave', label: 'Sick leave' },
  { value: 'casual_leave', label: 'Casual leave' },
  { value: 'maternity_leave', label: 'Maternity leave' },
  { value: 'paternity_leave', label: 'Paternity leave' },
  { value: 'unpaid_leave', label: 'Unpaid leave' },
  { value: 'compassionate_leave', label: 'Compassionate leave' },
  { value: 'other', label: 'Other' },
]

const returnStatuses: DropdownSelectOption[] = [
  { value: 'active', label: 'Active' },
  { value: 'on-probation', label: 'On probation' },
  { value: 'suspended', label: 'Suspended' },
]

function localDateValue() {
  const now = new Date()
  now.setMinutes(now.getMinutes() - now.getTimezoneOffset())
  return now.toISOString().slice(0, 10)
}

type StartProps = {
  mode: 'start'
  employee: EmployeeDto
  isPending: boolean
  error?: unknown
  onClose: () => void
  onConfirm: (input: EmployeeLeavePeriodCreateInput) => void
}

type ReturnProps = {
  mode: 'return'
  employee: EmployeeDto
  period: EmployeeLeavePeriodDto | null
  isPending: boolean
  error?: unknown
  onClose: () => void
  onConfirm: (input: EmployeeLeaveReturnInput) => void
}

type Props = StartProps | ReturnProps

export function EmployeeLeaveFormDialog(props: Props) {
  const [leaveType, setLeaveType] = useState('annual_leave')
  const [reason, setReason] = useState('')
  const [startDate, setStartDate] = useState(localDateValue)
  const [expectedReturnDate, setExpectedReturnDate] = useState('')
  const [indefinite, setIndefinite] = useState(false)
  const [reviewReminderDate, setReviewReminderDate] = useState('')
  const [actualReturnDate, setActualReturnDate] = useState(localDateValue)
  const [legacyReturnStatus, setLegacyReturnStatus] = useState(
    props.employee.account_is_active ? 'active' : 'suspended',
  )
  const [errors, setErrors] = useState<Record<string, string>>({})
  const mutationError = props.error ? presentError(props.error, 'form-submit') : null
  const employeeName = [props.employee.first_name, props.employee.last_name]
    .filter(Boolean)
    .join(' ')

  const submit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    const nextErrors: Record<string, string> = {}
    const today = localDateValue()

    if (props.mode === 'start') {
      if (!startDate) nextErrors.startDate = 'Choose the leave start date.'
      else if (startDate > today) nextErrors.startDate = 'Leave cannot start in the future.'
      if (!leaveType) nextErrors.leaveType = 'Choose a leave type.'
      if (!reason.trim()) nextErrors.reason = 'Enter a reason for this leave.'
      if (indefinite) {
        if (!reviewReminderDate) {
          nextErrors.reviewReminderDate = 'Choose a date to review this indefinite leave.'
        } else if (reviewReminderDate < today) {
          nextErrors.reviewReminderDate = 'The review reminder cannot be in the past.'
        }
      } else if (!expectedReturnDate) {
        nextErrors.expectedReturnDate = 'Choose an expected return date or mark leave indefinite.'
      } else if (expectedReturnDate < startDate) {
        nextErrors.expectedReturnDate = 'Expected return cannot be before leave starts.'
      }
      setErrors(nextErrors)
      if (Object.keys(nextErrors).length) return
      if (props.mode !== 'start') return
      props.onConfirm({
        leave_type: leaveType,
        reason: reason.trim(),
        start_date: startDate,
        expected_return_date: indefinite ? null : expectedReturnDate,
        review_reminder_date: indefinite ? reviewReminderDate : null,
      })
      return
    }

    if (!actualReturnDate) nextErrors.actualReturnDate = 'Choose the actual return date.'
    else if (actualReturnDate > today) {
      nextErrors.actualReturnDate = 'Actual return cannot be in the future.'
    } else if (props.period && actualReturnDate < props.period.start_date) {
      nextErrors.actualReturnDate = 'Actual return cannot be before leave starts.'
    }
    if (!props.period) {
      if (!startDate) nextErrors.startDate = 'Enter the original leave start date.'
      else if (startDate > actualReturnDate) {
        nextErrors.startDate = 'Leave start cannot be after the return date.'
      }
      if (!leaveType) nextErrors.leaveType = 'Choose the original leave type.'
      if (!reason.trim()) nextErrors.reason = 'Enter the reason for the existing leave.'
      if (!legacyReturnStatus) nextErrors.legacyReturnStatus = 'Choose the status to restore.'
    }
    setErrors(nextErrors)
    if (Object.keys(nextErrors).length) return
    if (props.mode !== 'return') return
    props.onConfirm({
      actual_return_date: actualReturnDate,
      ...(!props.period
        ? {
            legacy_start_date: startDate,
            legacy_leave_type: leaveType,
            legacy_reason: reason.trim(),
            legacy_return_employment_status: legacyReturnStatus,
          }
        : {}),
    })
  }

  const isStart = props.mode === 'start'
  const leaveDateId = indefinite
    ? 'employee-leave-review-reminder'
    : 'employee-leave-expected-return'
  const expectedReturnDue =
    props.mode === 'return' &&
    props.period?.expected_return_date != null &&
    props.period.expected_return_date <= localDateValue()

  return (
    <Dialog
      open
      onOpenChange={(open) => {
        if (!open && !props.isPending) props.onClose()
      }}
      title={isStart ? 'Place employee on leave' : 'Return employee from leave'}
      description={employeeName}
      size="md"
      fitContent
      compactOnMobile
      dismissDisabled={props.isPending}
      footer={
        <>
          <Button variant="outline" disabled={props.isPending} onClick={props.onClose}>
            Cancel
          </Button>
          <Button type="submit" form="employee-leave-form" isLoading={props.isPending}>
            {isStart ? 'Save leave record' : 'Confirm return'}
          </Button>
        </>
      }
    >
      <form id="employee-leave-form" onSubmit={submit} noValidate className="space-y-4">
        {mutationError ? (
          <Alert tone="danger" role="alert" title={mutationError.title}>
            {mutationError.message}
          </Alert>
        ) : null}
        {expectedReturnDue ? (
          <Alert tone="warning" title="Expected return date reached">
            Confirm the actual return date to close this leave.
          </Alert>
        ) : null}
        {!isStart && !props.period ? (
          <Alert tone="warning" title="Legacy leave details are missing">
            This employee was marked on leave before leave periods were recorded. Add the known
            details so the return is captured without inventing history.
          </Alert>
        ) : null}
        {isStart ? (
          <div className="grid min-w-0 gap-x-4 gap-y-3 min-[480px]:grid-cols-2">
            <FormControl
              id="employee-leave-start-date"
              label="Leave start date"
              required
              error={errors.startDate}
            >
              <DatePickerField
                id="employee-leave-start-date"
                value={startDate}
                max={isStart ? localDateValue() : actualReturnDate || localDateValue()}
                onValueChange={setStartDate}
                required
              />
            </FormControl>
            <FormControl
              className="min-w-0"
              id={leaveDateId}
              label={indefinite ? 'Review reminder date' : 'Expected return date'}
              description={
                indefinite
                  ? 'Review reminder only; HR confirms the actual return.'
                  : 'Planned date only; HR confirms the actual return.'
              }
              required
              error={indefinite ? errors.reviewReminderDate : errors.expectedReturnDate}
            >
              <DatePickerField
                id={leaveDateId}
                value={indefinite ? reviewReminderDate : expectedReturnDate}
                min={indefinite ? localDateValue() : startDate}
                onValueChange={indefinite ? setReviewReminderDate : setExpectedReturnDate}
                required
              />
            </FormControl>
            <FormControl
              id="employee-leave-type"
              label="Leave type"
              required
              error={errors.leaveType}
              className="min-[480px]:col-start-1 min-[480px]:row-start-2"
            >
              <DropdownSelect
                id="employee-leave-type"
                value={leaveType}
                onChange={setLeaveType}
                options={leaveTypes}
                placeholder="Choose leave type"
              />
            </FormControl>
            <label
              htmlFor="employee-leave-indefinite"
              className="text-caption text-text-secondary hover:text-text-primary focus-within:shadow-focus-ring rounded-control inline-flex min-h-10 w-fit cursor-pointer items-center gap-2 px-1 transition-colors focus-within:outline-none min-[480px]:col-start-2 min-[480px]:row-start-2"
            >
              <input
                id="employee-leave-indefinite"
                type="checkbox"
                checked={indefinite}
                onChange={(event) => setIndefinite(event.currentTarget.checked)}
                className="border-border-strong text-primary focus-visible:shadow-focus-ring size-4 rounded"
              />
              <span>Indefinite leave</span>
            </label>
            <FormControl
              id="employee-leave-reason"
              label={isStart ? 'Reason' : 'Original leave reason'}
              required
              error={errors.reason}
              className="min-[480px]:col-span-2 min-[480px]:row-start-3"
            >
              <TextArea
                value={reason}
                onChange={(event) => setReason(event.currentTarget.value)}
                rows={2}
                maxLength={1000}
                placeholder="Add the HR record reason or notes"
              />
            </FormControl>
          </div>
        ) : !props.period ? (
          <>
            <div className="grid min-w-0 gap-4 min-[480px]:grid-cols-2">
              <FormControl
                id="employee-leave-start-date"
                label="Original leave start date"
                required
                error={errors.startDate}
              >
                <DatePickerField
                  id="employee-leave-start-date"
                  value={startDate}
                  max={actualReturnDate || localDateValue()}
                  onValueChange={setStartDate}
                  required
                />
              </FormControl>
              <FormControl
                id="employee-leave-type"
                label="Original leave type"
                required
                error={errors.leaveType}
              >
                <DropdownSelect
                  id="employee-leave-type"
                  value={leaveType}
                  onChange={setLeaveType}
                  options={leaveTypes}
                />
              </FormControl>
            </div>
            <FormControl
              id="employee-leave-reason"
              label="Original leave reason"
              required
              error={errors.reason}
            >
              <TextArea
                value={reason}
                onChange={(event) => setReason(event.currentTarget.value)}
                rows={2}
                maxLength={1000}
                placeholder="Add the HR record reason or notes"
              />
            </FormControl>
          </>
        ) : (
          <div className="bg-surface-muted border-border-subtle rounded-control grid gap-3 border p-4 sm:grid-cols-2">
            <p className="text-body-sm text-text-secondary">
              <span className="text-caption text-text-muted block">Leave type</span>
              <span className="text-text-primary mt-1 block font-semibold">
                {props.period.leave_type_label}
              </span>
            </p>
            <p className="text-body-sm text-text-secondary">
              <span className="text-caption text-text-muted block">Started</span>
              <span className="text-text-primary mt-1 block font-semibold">
                {props.period.start_date}
              </span>
            </p>
          </div>
        )}
        {!isStart ? (
          <FormControl
            id="employee-leave-actual-return"
            label="Actual return date"
            description="Records the confirmed return date; login access is managed separately."
            required
            error={errors.actualReturnDate}
          >
            <DatePickerField
              id="employee-leave-actual-return"
              value={actualReturnDate}
              min={props.mode === 'return' && props.period ? props.period.start_date : undefined}
              max={localDateValue()}
              onValueChange={setActualReturnDate}
              required
            />
          </FormControl>
        ) : null}
        {!isStart && !props.period ? (
          <FormControl
            id="employee-leave-return-status"
            label="Employment status to restore"
            required
            error={errors.legacyReturnStatus}
          >
            <DropdownSelect
              id="employee-leave-return-status"
              value={legacyReturnStatus}
              onChange={setLegacyReturnStatus}
              options={returnStatuses}
            />
          </FormControl>
        ) : null}
      </form>
    </Dialog>
  )
}
