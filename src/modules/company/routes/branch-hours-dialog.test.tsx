import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'

import type { BranchDto } from '@/modules/company/branches.api'
import { BranchHoursDialog } from './branch-hours-dialog'

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

const branch = { branch_name: 'North Office' } as BranchDto

async function setTime(
  user: ReturnType<typeof userEvent.setup>,
  label: string,
  hour: string,
  minute: string,
  period: 'AM' | 'PM',
) {
  await user.click(screen.getByRole('button', { name: new RegExp(label) }))
  const picker = await screen.findByRole('dialog', { name: 'Choose a time', hidden: true })
  for (const [name, option] of [
    ['Hour', hour],
    ['Minute', minute],
    ['AM or PM', period],
  ]) {
    await user.click(within(picker).getByRole('combobox', { name }))
    await user.click(screen.getByRole('option', { name: option }))
  }
  await user.click(within(picker).getByRole('button', { name: 'Set time' }))
}

describe('BranchHoursDialog', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('clears the closing-time validation after the user corrects the schedule', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)

    render(
      <BranchHoursDialog open branch={branch} hours={[]} onOpenChange={vi.fn()} onSave={onSave} />,
    )

    await user.click(screen.getByRole('combobox', { name: 'Monday schedule' }))
    await user.click(await screen.findByRole('option', { name: 'Open' }))
    await setTime(user, 'Opens', '09', '00', 'AM')
    await setTime(user, 'Closes', '08', '00', 'AM')
    await user.click(screen.getByRole('button', { name: 'Save business hours' }))

    expect(
      await screen.findByText('Closing time must be later than opening time on Monday.'),
    ).toBeVisible()
    expect(onSave).not.toHaveBeenCalled()

    await setTime(user, 'Closes', '05', '00', 'PM')
    await waitFor(() =>
      expect(
        screen.queryByText('Closing time must be later than opening time on Monday.'),
      ).not.toBeInTheDocument(),
    )

    await user.click(screen.getByRole('button', { name: 'Save business hours' }))
    await waitFor(() => expect(onSave).toHaveBeenCalledTimes(1))
    expect(onSave).toHaveBeenCalledWith([
      {
        day_of_week: 0,
        is_open: true,
        open_time: '09:00',
        close_time: '17:00',
      },
    ])
  })
})
