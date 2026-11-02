import { render, screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import { ApiError } from '@/shared/api/api-error'
import type { EmployeeDto } from '@/modules/hr/employees.api'

import { EmployeeActionDialog, type EmployeeActionIntent } from './employee-action-dialog'

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
} as EmployeeDto

function renderAction(action: EmployeeActionIntent, onConfirm = vi.fn(), error?: unknown) {
  render(
    <EmployeeActionDialog
      action={action}
      isPending={false}
      error={error}
      onClose={vi.fn()}
      onConfirm={onConfirm}
    />,
  )
  return onConfirm
}

function todayLocal() {
  const today = new Date()
  today.setMinutes(today.getMinutes() - today.getTimezoneOffset())
  return today.toISOString().slice(0, 10)
}

describe('EmployeeActionDialog', () => {
  it('blocks future exit dates and requires a reason before confirming offboarding', async () => {
    const user = userEvent.setup()
    const onConfirm = renderAction({ type: 'exit', employee })

    await user.click(screen.getByRole('button', { name: 'Confirm exit' }))
    expect(await screen.findByText('Enter a reason for the employee exit.')).toBeInTheDocument()
    expect(onConfirm).not.toHaveBeenCalled()

    await user.click(screen.getByRole('button', { name: /^Exit date/ }))
    const calendar = screen.getByRole('dialog', { name: 'Choose a date' })
    const tomorrow = new Date()
    tomorrow.setDate(tomorrow.getDate() + 1)
    const tomorrowLabel = new Intl.DateTimeFormat(undefined, {
      weekday: 'long',
      month: 'long',
      day: 'numeric',
      year: 'numeric',
    }).format(tomorrow)
    expect(within(calendar).getByRole('button', { name: tomorrowLabel })).toBeDisabled()
    const today = new Date()
    const todayLabel = new Intl.DateTimeFormat(undefined, {
      weekday: 'long',
      month: 'long',
      day: 'numeric',
      year: 'numeric',
    }).format(today)
    await user.click(within(calendar).getByRole('button', { name: todayLabel }))
    await user.click(screen.getByRole('button', { name: 'Confirm exit' }))
    expect(await screen.findByText('Enter a reason for the employee exit.')).toBeInTheDocument()
    expect(onConfirm).not.toHaveBeenCalled()
    await user.type(screen.getByLabelText(/^Reason for exit/), '  Contract ended  ')
    await user.click(screen.getByRole('button', { name: 'Confirm exit' }))
    expect(onConfirm).toHaveBeenCalledWith({
      type: 'exit',
      employee,
      exitDate: todayLocal(),
      reason: 'Contract ended',
    })
  })

  it('submits a trimmed reason with the selected valid exit date', async () => {
    const user = userEvent.setup()
    const onConfirm = renderAction({ type: 'exit', employee })
    await user.click(screen.getByRole('button', { name: /^Exit date/ }))
    const todayLabel = new Intl.DateTimeFormat(undefined, {
      weekday: 'long',
      month: 'long',
      day: 'numeric',
      year: 'numeric',
    }).format(new Date())
    await user.click(screen.getByRole('button', { name: todayLabel }))
    await user.type(screen.getByLabelText(/^Reason for exit/), '  Contract ended  ')
    await user.click(screen.getByRole('button', { name: 'Confirm exit' }))

    expect(onConfirm).toHaveBeenCalledWith({
      type: 'exit',
      employee,
      exitDate: todayLocal(),
      reason: 'Contract ended',
    })
  })

  it('confirms a suspend transition and preserves the action dialog after a server error', async () => {
    const user = userEvent.setup()
    const onConfirm = renderAction(
      { type: 'status', employee, status: 'suspended' },
      vi.fn(),
      new ApiError('Forbidden', { status: 403 }),
    )

    expect(screen.getByRole('alert')).toHaveTextContent(
      'You do not have permission to complete this action.',
    )
    expect(screen.getByText(/disables the employee account/i)).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Suspend employee' }))

    expect(onConfirm).toHaveBeenCalledWith({ type: 'status', employee, status: 'suspended' })
    expect(screen.getByRole('dialog', { name: 'Suspend employee?' })).toHaveAttribute('open')
  })
})
