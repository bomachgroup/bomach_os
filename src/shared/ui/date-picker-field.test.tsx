import { act, render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'

import { DatePickerField } from './date-picker-field'
import { FormControl } from './form-control'

function renderPicker({
  value = '2026-04-15',
  onValueChange = vi.fn(),
  min,
  max,
  clearable = false,
}: {
  value?: string
  onValueChange?: (value: string) => void
  min?: string
  max?: string
  clearable?: boolean
} = {}) {
  render(
    <FormControl id="report-date" label="Report date" required>
      <DatePickerField
        value={value}
        onValueChange={onValueChange}
        min={min}
        max={max}
        clearable={clearable}
      />
    </FormControl>,
  )
  return { trigger: screen.getByRole('button', { name: 'Report date' }), onValueChange }
}

afterEach(() => {
  vi.restoreAllMocks()
  vi.unstubAllGlobals()
})

describe('DatePickerField', () => {
  it('opens a calendar, supports arrow-key date navigation, and restores focus after selection', async () => {
    const user = userEvent.setup()
    const onValueChange = vi.fn()
    const { trigger } = renderPicker({ onValueChange })

    await user.click(trigger)
    const calendar = screen.getByRole('dialog', { name: 'Choose a date' })
    expect(calendar).toBeInTheDocument()
    await waitFor(() =>
      expect(screen.getByRole('button', { name: 'Wednesday, April 15, 2026' })).toHaveFocus(),
    )
    await user.keyboard('{ArrowRight}{Enter}')

    expect(onValueChange).toHaveBeenCalledWith('2026-04-16')
    await waitFor(() => expect(trigger).toHaveFocus())
    expect(screen.queryByRole('dialog', { name: 'Choose a date' })).not.toBeInTheDocument()
  })

  it('disables dates outside the supplied range', async () => {
    const user = userEvent.setup()
    const { trigger } = renderPicker({ min: '2026-04-15', max: '2026-04-16' })

    await user.click(trigger)

    expect(screen.getByRole('button', { name: 'Tuesday, April 14, 2026' })).toBeDisabled()
    expect(screen.getByRole('button', { name: 'Thursday, April 16, 2026' })).toBeEnabled()
  })

  it('keeps month and year options readable when their calendar menus open', async () => {
    const user = userEvent.setup()
    const { trigger } = renderPicker()

    await user.click(trigger)

    const monthPicker = screen.getByRole('combobox', { name: 'Month' })
    await user.click(monthPicker)
    const monthMenu = screen.getByRole('listbox', { name: 'Month' })
    expect(monthMenu).toHaveStyle({ width: '160px' })
    expect(screen.getByRole('option', { name: 'September' })).toBeInTheDocument()
    await user.click(screen.getByRole('option', { name: 'September' }))
    expect(screen.getByRole('grid', { name: 'September 2026' })).toBeInTheDocument()

    const yearPicker = screen.getByRole('combobox', { name: 'Year' })
    expect(yearPicker.parentElement).toHaveClass('w-20')
    await user.click(yearPicker)
    const yearMenu = screen.getByRole('listbox', { name: 'Year' })
    expect(yearMenu).toHaveStyle({ width: '160px' })
    expect(screen.getByRole('option', { name: '2026' })).toBeInTheDocument()
    await user.click(screen.getByRole('option', { name: '2025' }))
    expect(screen.getByRole('grid', { name: 'September 2025' })).toBeInTheDocument()
  })

  it('keeps the calendar compact on phone layouts and applies a date immediately', async () => {
    const user = userEvent.setup()
    const onValueChange = vi.fn()
    const { trigger } = renderPicker({ onValueChange })

    await user.click(trigger)
    expect(screen.getByRole('dialog', { name: 'Choose a date' })).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Thursday, April 16, 2026' }))

    expect(onValueChange).toHaveBeenCalledWith('2026-04-16')
    await waitFor(() => expect(trigger).toHaveFocus())
    expect(screen.queryByRole('button', { name: 'Use this date' })).not.toBeInTheDocument()
  })

  it('positions a dialog calendar within the scrollable body above its fixed footer', async () => {
    const user = userEvent.setup()
    const { container } = render(
      <dialog open>
        <header />
        <section>
          <FormControl id="dialog-date" label="Dialog date">
            <DatePickerField value="2026-04-15" onValueChange={vi.fn()} />
          </FormControl>
        </section>
        <footer />
      </dialog>,
    )

    await user.click(screen.getByRole('button', { name: 'Dialog date' }))
    const calendar = screen.getByRole('dialog', { name: 'Choose a date' })
    const dialog = container.querySelector('dialog')!
    const trigger = screen.getByRole('button', { name: 'Dialog date' })
    const header = dialog.querySelector('header')!
    const footer = dialog.querySelector('footer')!
    const rect = (left: number, top: number, width: number, height: number) =>
      new DOMRect(left, top, width, height)
    vi.spyOn(dialog, 'getBoundingClientRect').mockReturnValue(rect(40, 100, 800, 600))
    vi.spyOn(header, 'getBoundingClientRect').mockReturnValue(rect(40, 100, 800, 52))
    vi.spyOn(footer, 'getBoundingClientRect').mockReturnValue(rect(40, 650, 800, 50))
    vi.spyOn(trigger, 'getBoundingClientRect').mockReturnValue(rect(80, 560, 220, 44))
    vi.spyOn(calendar, 'getBoundingClientRect').mockReturnValue(rect(0, 0, 320, 460))
    act(() => window.dispatchEvent(new Event('resize')))

    await waitFor(() => expect(calendar).toHaveStyle({ position: 'absolute', maxHeight: '460px' }))
    expect(Number.parseFloat(calendar.style.top)).toBeGreaterThan(0)
    await user.click(within(calendar).getByRole('button', { name: 'Thursday, April 16, 2026' }))
    await waitFor(() => expect(dialog.style.minHeight).toBe(''))
    expect(dialog.style.maxHeight).toBe('')
  })
})
