import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { useRef, useState } from 'react'
import { describe, expect, it } from 'vitest'

import { Dialog } from './dialog'

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

function DialogFixture({ closeOnBackdrop = false }: { closeOnBackdrop?: boolean }) {
  const [open, setOpen] = useState(false)
  const inputRef = useRef<HTMLInputElement>(null)

  return (
    <>
      <button type="button" onClick={() => setOpen(true)}>
        Open dialog
      </button>
      <Dialog
        open={open}
        onOpenChange={setOpen}
        title="Edit company"
        closeOnBackdrop={closeOnBackdrop}
        initialFocusRef={inputRef}
      >
        <label>
          Company name
          <input ref={inputRef} />
        </label>
      </Dialog>
    </>
  )
}

describe('Dialog', () => {
  it('focuses the requested control and closes on Escape', async () => {
    const user = userEvent.setup()
    render(<DialogFixture />)
    await user.click(screen.getByRole('button', { name: 'Open dialog' }))

    const dialog = screen.getByRole('dialog', { name: 'Edit company' })
    expect(dialog).toHaveClass('inset-0', 'm-auto', 'tablet:max-h-[90dvh]')
    expect(screen.getByRole('textbox', { name: 'Company name' })).toHaveFocus()

    fireEvent(dialog, new Event('cancel', { cancelable: true }))
    await waitFor(() => expect(screen.queryByRole('dialog')).not.toBeInTheDocument())
  })

  it('does not dismiss on backdrop clicks when the workflow opts out', async () => {
    const user = userEvent.setup()
    render(<DialogFixture />)
    await user.click(screen.getByRole('button', { name: 'Open dialog' }))
    const dialog = screen.getByRole('dialog', { name: 'Edit company' })

    fireEvent.click(dialog)

    expect(dialog).toHaveAttribute('open')
  })
})
