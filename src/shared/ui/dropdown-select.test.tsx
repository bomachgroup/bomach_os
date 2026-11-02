import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { useState } from 'react'
import { describe, expect, it, vi } from 'vitest'

import { Dialog } from './dialog'
import { DropdownSelect } from './dropdown-select'

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

const departments = ['Finance', 'HR', 'IT', 'Legal', 'Marketing', 'Operations'].map((label) => ({
  value: label.toLowerCase(),
  label,
}))

function DepartmentPickerDialog() {
  const [open, setOpen] = useState(true)
  const [value, setValue] = useState('')

  return (
    <Dialog open={open} onOpenChange={setOpen} title="Unit details" size="sm" fitContent>
      <DropdownSelect
        aria-label="Parent department"
        value={value}
        options={departments}
        onChange={setValue}
        placeholder="Select a department"
        searchable
      />
    </Dialog>
  )
}

describe('DropdownSelect', () => {
  it('keeps a searchable menu inside its native dialog and allows a selection', async () => {
    const user = userEvent.setup()
    render(<DepartmentPickerDialog />)

    const dialog = screen.getByRole('dialog', { name: 'Unit details' })
    const trigger = screen.getByRole('combobox', { name: 'Parent department' })
    vi.spyOn(dialog, 'getBoundingClientRect').mockReturnValue(new DOMRect(100, 100, 480, 400))
    vi.spyOn(trigger, 'getBoundingClientRect').mockReturnValue(new DOMRect(120, 350, 420, 38))

    await user.click(trigger)

    const menu = screen.getByRole('listbox', { name: 'Parent department' })
    expect(menu).toHaveStyle({ position: 'absolute', top: '0px', left: '19px', maxHeight: '245px' })
    expect(menu.querySelector('[role="presentation"]')).toHaveStyle({ maxHeight: '197px' })

    await user.click(screen.getByRole('option', { name: 'Finance' }))

    expect(dialog).toHaveAttribute('open')
    expect(trigger).toHaveTextContent('Finance')
  })

  it('shows the full text of long options instead of truncating it', async () => {
    const user = userEvent.setup()
    const longLabel = 'Best branch representative for exceptional customer service'
    render(
      <DropdownSelect
        aria-label="Award category"
        value="other"
        options={[
          { value: 'long', label: longLabel },
          { value: 'other', label: 'Other' },
        ]}
        onChange={vi.fn()}
      />,
    )

    await user.click(screen.getByRole('combobox', { name: 'Award category' }))

    const option = screen.getByRole('option', { name: longLabel })
    const label = option.querySelector('span.flex-1 > span')
    expect(label).toHaveTextContent(longLabel)
    expect(label).toHaveClass('whitespace-normal', 'break-words')
    expect(label).not.toHaveClass('truncate')
  })
})
