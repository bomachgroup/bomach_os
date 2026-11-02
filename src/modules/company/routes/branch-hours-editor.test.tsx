import { useState } from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it } from 'vitest'

import {
  blankSchedule,
  type DayScheduleDraft,
  validateHoursDraft,
} from '@/modules/company/branch-hours'
import { BranchHoursEditor } from './branch-hours-editor'

function HoursFixture({ initialDays = blankSchedule() }: { initialDays?: DayScheduleDraft[] }) {
  const [days, setDays] = useState(initialDays)

  return (
    <>
      <BranchHoursEditor days={days} onChange={setDays} idPrefix="test-hours" />
      <div data-testid="schedule-value">{JSON.stringify(days)}</div>
    </>
  )
}

function currentSchedule(): DayScheduleDraft[] {
  return JSON.parse(screen.getByTestId('schedule-value').textContent ?? '[]') as DayScheduleDraft[]
}

async function setTime(
  user: ReturnType<typeof userEvent.setup>,
  id: string,
  hour: string,
  minute: string,
  period: 'AM' | 'PM',
) {
  await user.click(document.getElementById(id)!)
  await user.click(screen.getByRole('combobox', { name: 'Hour' }))
  await user.click(screen.getByRole('option', { name: hour }))
  await user.click(screen.getByRole('combobox', { name: 'Minute' }))
  await user.click(screen.getByRole('option', { name: minute }))
  await user.click(screen.getByRole('combobox', { name: 'AM or PM' }))
  await user.click(screen.getByRole('option', { name: period }))
  await user.click(screen.getByRole('button', { name: 'Set time' }))
}

describe('BranchHoursEditor schedule copying', () => {
  it('applies the source schedule to every other weekday', async () => {
    const user = userEvent.setup()
    const schedule = blankSchedule()
    schedule[0] = { mode: 'open', openTime: '09:00', closeTime: '17:00' }
    render(<HoursFixture initialDays={schedule} />)

    await user.click(screen.getByRole('button', { name: 'Apply to all days' }))

    expect(currentSchedule()).toEqual(schedule.map(() => ({ ...schedule[0] })))
    expect(screen.getByText('Applied Monday’s schedule to all 6 other days.')).toBeInTheDocument()
  })

  it('applies the source schedule only to the selected days', async () => {
    const user = userEvent.setup()
    const schedule = blankSchedule()
    schedule[0] = { mode: 'closed', openTime: '', closeTime: '' }
    render(<HoursFixture initialDays={schedule} />)

    const tuesdayButtons = screen.getAllByRole('button', { name: 'Tuesday' })
    await user.click(tuesdayButtons[0]!)
    await user.click(screen.getByRole('button', { name: 'Apply to selected' }))

    const copied = currentSchedule()
    expect(copied[1]).toEqual(schedule[0])
    expect(copied[2]).toEqual(schedule[2])
    expect(screen.getByText('Applied Monday’s schedule to Tuesday.')).toBeInTheDocument()
  })

  it('updates a copied open schedule from the day editor before applying it', async () => {
    const user = userEvent.setup()
    render(<HoursFixture />)

    await user.click(screen.getByRole('combobox', { name: 'Monday schedule' }))
    await user.click(screen.getByRole('option', { name: 'Open' }))
    await setTime(user, 'test-hours-open-0', '08', '30', 'AM')
    await setTime(user, 'test-hours-close-0', '04', '30', 'PM')
    await user.click(screen.getByRole('button', { name: 'Apply to all days' }))

    expect(currentSchedule()).toEqual(
      blankSchedule().map(() => ({ mode: 'open', openTime: '08:30', closeTime: '16:30' })),
    )
  })
})

describe('business-hours validation', () => {
  it('returns the first invalid open day and clears the error after correction', () => {
    const schedule = blankSchedule()
    schedule[0] = { mode: 'open', openTime: '09:00', closeTime: '08:00' }

    expect(validateHoursDraft(schedule)).toBe(
      'Closing time must be later than opening time on Monday.',
    )

    schedule[0] = { ...schedule[0]!, closeTime: '17:00' }
    expect(validateHoursDraft(schedule)).toBeNull()
  })
})
