import { useState, type FormEvent } from 'react'

import type { EmployeeDto } from '@/modules/hr/employees.api'
import { presentError } from '@/shared/errors'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Dialog } from '@/shared/ui/dialog'
import { FormControl, TextArea } from '@/shared/ui/form-control'
import { DatePickerField } from '@/shared/ui/date-picker-field'

export type EmployeeActionIntent =
  | {
      type: 'status'
      employee: EmployeeDto
      status: 'active' | 'inactive' | 'suspended'
    }
  | { type: 'exit'; employee: EmployeeDto }

export type EmployeeActionSubmission =
  | {
      type: 'status'
      employee: EmployeeDto
      status: 'active' | 'inactive' | 'suspended'
    }
  | { type: 'exit'; employee: EmployeeDto; exitDate: string; reason: string }

function localDateInputValue() {
  const today = new Date()
  const offset = today.getTimezoneOffset()
  return new Date(today.getTime() - offset * 60_000).toISOString().slice(0, 10)
}

const statusCopy = {
  active: {
    title: 'Activate employee?',
    detail: 'This restores the employee account and access to the system.',
    action: 'Activate employee',
    tone: 'success' as const,
  },
  inactive: {
    title: 'Deactivate employee?',
    detail: 'This disables the employee account but keeps their employment record.',
    action: 'Deactivate employee',
    tone: 'danger' as const,
  },
  suspended: {
    title: 'Suspend employee?',
    detail: 'This disables the employee account and marks their employment as suspended.',
    action: 'Suspend employee',
    tone: 'warning' as const,
  },
}

type EmployeeActionDialogProps = {
  action: EmployeeActionIntent | null
  isPending: boolean
  error?: unknown
  onClose: () => void
  onConfirm: (submission: EmployeeActionSubmission) => void
}

export function EmployeeActionDialog(props: EmployeeActionDialogProps) {
  const actionKey = props.action
    ? `${props.action.type}-${props.action.employee.user_id}-${props.action.type === 'status' ? props.action.status : ''}`
    : 'closed'
  return <EmployeeActionDialogContent key={actionKey} {...props} />
}

function EmployeeActionDialogContent({
  action,
  isPending,
  error,
  onClose,
  onConfirm,
}: EmployeeActionDialogProps) {
  const [exitDate, setExitDate] = useState(localDateInputValue)
  const [reason, setReason] = useState('')
  const [dateError, setDateError] = useState('')
  const [reasonError, setReasonError] = useState('')
  const today = localDateInputValue()
  const employeeName = action
    ? [action.employee.first_name, action.employee.last_name].filter(Boolean).join(' ')
    : ''
  const mutationError = error ? presentError(error, 'form-submit') : null

  const submitExit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    const nextDateError = !exitDate
      ? 'Enter the employee’s exit date.'
      : exitDate > today
        ? 'Exit date cannot be in the future.'
        : ''
    const nextReasonError = reason.trim() ? '' : 'Enter a reason for the employee exit.'
    setDateError(nextDateError)
    setReasonError(nextReasonError)
    if (nextDateError || nextReasonError || action?.type !== 'exit') return
    onConfirm({ type: 'exit', employee: action.employee, exitDate, reason: reason.trim() })
  }

  const statusDetails = action?.type === 'status' ? statusCopy[action.status] : null

  return (
    <Dialog
      open={action !== null}
      onOpenChange={(open) => {
        if (!open && !isPending) onClose()
      }}
      title={statusDetails?.title ?? 'Offboard employee'}
      description={
        statusDetails
          ? `Confirm this employment status change for ${employeeName}.`
          : `Record the departure of ${employeeName}.`
      }
      size="sm"
      fitContent
      compactOnMobile={action?.type === 'status'}
      dismissDisabled={isPending}
      footer={
        <>
          <Button variant="outline" onClick={onClose} disabled={isPending}>
            Cancel
          </Button>
          {statusDetails ? (
            <Button
              variant={
                statusDetails.tone === 'danger'
                  ? 'danger'
                  : statusDetails.tone === 'warning'
                    ? 'outline'
                    : 'primary'
              }
              isLoading={isPending}
              onClick={() => {
                if (action?.type === 'status') onConfirm(action)
              }}
            >
              {statusDetails.action}
            </Button>
          ) : (
            <Button type="submit" form="employee-exit-form" variant="danger" isLoading={isPending}>
              Confirm exit
            </Button>
          )}
        </>
      }
    >
      {statusDetails ? (
        <div className="space-y-4">
          {mutationError ? (
            <Alert tone="danger" role="alert" title={mutationError.title}>
              {mutationError.message} Your confirmation is still open; you can retry.
            </Alert>
          ) : null}
          <Alert tone={statusDetails.tone}>
            <p className="font-semibold">{employeeName}</p>
            <p className="mt-1">{statusDetails.detail}</p>
          </Alert>
        </div>
      ) : (
        <form id="employee-exit-form" onSubmit={submitExit} className="space-y-4" noValidate>
          {mutationError ? (
            <Alert tone="danger" role="alert" title={mutationError.title}>
              {mutationError.message} Your details are preserved; correct the issue or retry.
            </Alert>
          ) : null}
          <Alert tone="danger">
            <p className="font-semibold">This action disables the employee account.</p>
            <p className="mt-1">The record remains available in Past employees.</p>
          </Alert>
          <FormControl id="employee-exit-date" label="Exit date" required error={dateError}>
            <DatePickerField
              id="employee-exit-date"
              value={exitDate}
              max={today}
              onValueChange={(value) => {
                setExitDate(value)
                setDateError('')
              }}
              required
            />
          </FormControl>
          <FormControl
            id="employee-exit-reason"
            label="Reason for exit"
            required
            error={reasonError}
          >
            <TextArea
              value={reason}
              onChange={(event) => {
                setReason(event.currentTarget.value)
                setReasonError('')
              }}
              rows={3}
              maxLength={500}
              placeholder="For example, resignation or contract end"
              required
            />
          </FormControl>
        </form>
      )}
    </Dialog>
  )
}
