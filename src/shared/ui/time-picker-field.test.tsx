import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import { FormControl } from './form-control'
import { TimePickerField } from './time-picker-field'

function renderPicker({
  value = '16:35',
  disabled = false,
  clearable = false,
  onValueChange = vi.fn(),
}: {
  value?: string
  disabled?: boolean
  clearable?: boolean
  onValueChange?: (value: string) => void
} = {}) {
  render(
    <FormControl id="meeting-time" label="Meeting time" required>
      <TimePickerField
        value={value}
        disabled={disabled}
        clearable={clearable}
        onValueChange={onValueChange}
      />
    </FormControl>,
  )
  return {
    trigger: document.getElementById('meeting-time') as HTMLButtonElement,
    onValueChange,
  }
}

async function chooseOption(
  user: ReturnType<typeof userEvent.setup>,
  label: string,
  option: string,
) {
  await user.click(screen.getByRole('combobox', { name: label }))
  await user.click(screen.getByRole('option', { name: option }))
}

describe('TimePickerField', () => {
  it('uses the shared time dialog and commits a 12-hour selection as 24-hour API time', async () => {
    const user = userEvent.setup()
    const onValueChange = vi.fn()
    const { trigger } = renderPicker({ onValueChange })

    await user.click(trigger)
    const picker = screen.getByRole('dialog', { name: 'Choose a time' })
    expect(picker).toBeInTheDocument()
    await chooseOption(user, 'Hour', '07')
    await chooseOption(user, 'Minute', '05')
    await chooseOption(user, 'AM or PM', 'PM')
    await user.click(within(picker).getByRole('button', { name: 'Set time' }))

    expect(onValueChange).toHaveBeenCalledWith('19:05')
    await waitFor(() => expect(trigger).toHaveFocus())
    expect(screen.queryByRole('dialog', { name: 'Choose a time' })).not.toBeInTheDocument()
  })

  it('does not commit changes when cancelled', async () => {
    const user = userEvent.setup()
    const onValueChange = vi.fn()
    renderPicker({ onValueChange })

    await user.click(screen.getByRole('button', { name: 'Meeting time' }))
    await chooseOption(user, 'Hour', '10')
    await user.click(screen.getByRole('button', { name: 'Cancel' }))

    expect(onValueChange).not.toHaveBeenCalled()
  })

  it('supports clearing optional times and prevents opening when disabled', async () => {
    const user = userEvent.setup()
    const onValueChange = vi.fn()
    const { trigger } = renderPicker({ value: '09:00', clearable: true, onValueChange })
    await user.click(trigger)
    await user.click(screen.getByRole('button', { name: 'Clear' }))
    expect(onValueChange).toHaveBeenCalledWith('')

    renderPicker({ disabled: true })
    const disabledTrigger = screen
      .getAllByRole('button')
      .filter((button) => button.id === 'meeting-time')
      .at(-1)
    expect(disabledTrigger).toBeDisabled()
  })
})
