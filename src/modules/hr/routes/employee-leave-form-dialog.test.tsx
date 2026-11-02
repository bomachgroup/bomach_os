import { render, screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import type { EmployeeDto, EmployeeLeavePeriodDto } from '@/modules/hr/employees.api'

import { EmployeeLeaveFormDialog } from './employee-leave-form-dialog'

Object.defineProperty(HTMLDialogElement.prototype, 'showModal', {
  configurable: true,
  value(this: HTMLDialogElement) {
    this.setAttribute('open', '')
  },
})
Object.defineProperty(HTMLDialogElement.prototype, 'close', {
  configurable: true,
  value(this: HTMLDialogElement) {
    this.removeAttribute('open')
    this.dispatchEvent(new Event('close'))
  },
})

const employee = {
  user_id: 52,
  employee_id: 'EMP-052',
  first_name: 'Amaka',
  last_name: 'Okafor',
  account_is_active: false,
} as EmployeeDto

const period = {
  id: 4,
  employee_id: 52,
  leave_type: 'annual_leave',
  leave_type_label: 'Annual leave',
  reason: 'Annual rest period',
  start_date: '2020-01-01',
  expected_return_date: '2020-01-14',
  review_reminder_date: null,
  actual_return_date: null,
  status: 'active',
  return_employment_status: 'suspended',
  created_at: '2026-01-01T10:00:00Z',
  updated_at: '2026-01-01T10:00:00Z',
  created_by_name: 'HR Admin',
  returned_by_name: null,
} satisfies EmployeeLeavePeriodDto

function localDateValue() {
  const now = new Date()
  now.setMinutes(now.getMinutes() - now.getTimezoneOffset())
  return now.toISOString().slice(0, 10)
}

function localTodayLabel() {
  return new Intl.DateTimeFormat(undefined, {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
    year: 'numeric',
  }).format(new Date())
}

describe('EmployeeLeaveFormDialog', () => {
  it('requires the leave reason and an expected return date unless marked indefinite', async () => {
    const user = userEvent.setup()
    const onConfirm = vi.fn()
    render(
      <EmployeeLeaveFormDialog
        mode="start"
        employee={employee}
        isPending={false}
        onClose={vi.fn()}
        onConfirm={onConfirm}
      />,
    )

    expect(screen.queryByLabelText('Actual return date')).not.toBeInTheDocument()
    expect(screen.getByText('Planned date only; HR confirms the actual return.')).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Save leave record' }))
    expect(await screen.findByText('Enter a reason for this leave.')).toBeVisible()
    expect(
      screen.getByText('Choose an expected return date or mark leave indefinite.'),
    ).toBeVisible()
    expect(onConfirm).not.toHaveBeenCalled()
    expect(screen.getByRole('dialog', { name: 'Place employee on leave' })).toHaveClass(
      'max-h-[calc(100dvh-2rem)]',
    )
    expect(
      screen
        .getByRole('dialog', { name: 'Place employee on leave' })
        .querySelector(':scope > div.min-h-0.overflow-y-auto'),
    ).toHaveClass('flex-auto')
    expect(
      screen.getByLabelText(/^Leave start date/).closest('.space-y-1\\.5')?.parentElement,
    ).toHaveClass('min-[480px]:grid-cols-2')

    await user.type(screen.getByLabelText(/^Reason/), '  Annual rest period  ')
    await user.click(screen.getByRole('button', { name: /^Expected return date/ }))
    const calendar = screen.getByRole('dialog', { name: 'Choose a date' })
    await user.click(within(calendar).getByRole('button', { name: localTodayLabel() }))
    await user.click(screen.getByRole('button', { name: 'Save leave record' }))

    expect(onConfirm).toHaveBeenCalledWith({
      leave_type: 'annual_leave',
      reason: 'Annual rest period',
      start_date: localDateValue(),
      expected_return_date: localDateValue(),
      review_reminder_date: null,
    })
  })

  it('requires an HR review reminder for an indefinite leave', async () => {
    const user = userEvent.setup()
    const onConfirm = vi.fn()
    render(
      <EmployeeLeaveFormDialog
        mode="start"
        employee={employee}
        isPending={false}
        onClose={vi.fn()}
        onConfirm={onConfirm}
      />,
    )

    await user.type(screen.getByLabelText(/^Reason/), 'Medical leave; review with HR')
    const indefiniteCheckbox = screen.getByRole('checkbox', { name: 'Indefinite leave' })
    await user.click(indefiniteCheckbox)
    expect(screen.getByText('Review reminder only; HR confirms the actual return.')).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Save leave record' }))

    expect(indefiniteCheckbox.parentElement).toHaveClass(
      'min-[480px]:col-start-2',
      'min-[480px]:row-start-2',
    )
    expect(screen.getByLabelText(/^Review reminder date/)).toBeVisible()
    expect(await screen.findByText('Choose a date to review this indefinite leave.')).toBeVisible()
    expect(onConfirm).not.toHaveBeenCalled()
  })

  it('records the explicit return date without enabling login access', async () => {
    const user = userEvent.setup()
    const onConfirm = vi.fn()
    render(
      <EmployeeLeaveFormDialog
        mode="return"
        employee={employee}
        period={period}
        isPending={false}
        onClose={vi.fn()}
        onConfirm={onConfirm}
      />,
    )

    const returnDialog = screen.getByRole('dialog', { name: 'Return employee from leave' })
    expect(returnDialog).toHaveClass('max-h-[calc(100dvh-2rem)]')
    expect(returnDialog.querySelector(':scope > div.min-h-0.overflow-y-auto')).toHaveClass(
      'flex-auto',
    )
    expect(screen.queryByText(/Login access will not be re-enabled/)).not.toBeInTheDocument()
    expect(screen.getByText(/expected return date reached/i)).toBeVisible()
    expect(
      screen.getByText('Records the confirmed return date; login access is managed separately.'),
    ).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Confirm return' }))

    expect(onConfirm).toHaveBeenCalledWith({ actual_return_date: localDateValue() })
  })
})
