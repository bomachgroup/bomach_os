import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { StrictMode, useRef, useState } from 'react'
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

function DialogFixture({
  closeOnBackdrop = false,
  fitContent = false,
  compactOnMobile = false,
  dismissDisabled = false,
}: {
  closeOnBackdrop?: boolean
  fitContent?: boolean
  compactOnMobile?: boolean
  dismissDisabled?: boolean
}) {
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
        dismissDisabled={dismissDisabled}
        fitContent={fitContent}
        compactOnMobile={compactOnMobile}
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

function ExternallyFocusedDialogFixture() {
  const [open, setOpen] = useState(false)
  const returnFocusRef = useRef<HTMLElement | null>(null)

  return (
    <>
      <button
        type="button"
        onClick={(event) => {
          returnFocusRef.current = event.currentTarget
          setOpen(true)
        }}
      >
        Open dialog with a return target
      </button>
      <Dialog
        open={open}
        onOpenChange={setOpen}
        title="Form with return target"
        returnFocusRef={returnFocusRef}
      >
        <p>Form content</p>
      </Dialog>
    </>
  )
}

describe('Dialog', () => {
  it('keeps the controlled native dialog open through Strict Mode effect replay', async () => {
    const user = userEvent.setup()
    render(
      <StrictMode>
        <DialogFixture />
      </StrictMode>,
    )
    await user.click(screen.getByRole('button', { name: 'Open dialog' }))

    expect(await screen.findByRole('dialog', { name: 'Edit company' })).toHaveAttribute('open')
    expect(screen.getByRole('textbox', { name: 'Company name' })).toBeInTheDocument()
  })

  it('lets fit-content dialogs shrink their body so the footer remains reachable', async () => {
    const user = userEvent.setup()
    render(<DialogFixture fitContent />)
    await user.click(screen.getByRole('button', { name: 'Open dialog' }))

    expect(screen.getByRole('dialog', { name: 'Edit company' })).toContainElement(
      screen.getByText('Company name').closest('label'),
    )
    expect(
      screen
        .getByRole('dialog', { name: 'Edit company' })
        .querySelector(':scope > div.min-h-0.overflow-y-auto'),
    ).toHaveClass('flex-auto')
    expect(screen.getByRole('dialog', { name: 'Edit company' })).toHaveClass(
      'top-1/2',
      'bottom-auto',
      'h-auto',
      'max-h-[calc(100dvh-1.5rem)]',
    )
  })

  it('uses the shared compact layout for brief mobile confirmations', async () => {
    const user = userEvent.setup()
    render(<DialogFixture compactOnMobile />)
    await user.click(screen.getByRole('button', { name: 'Open dialog' }))

    expect(screen.getByRole('dialog', { name: 'Edit company' })).toHaveClass(
      'max-w-[30rem]',
      'max-h-[calc(100dvh-2rem)]',
      '-translate-y-1/2',
    )
  })

  it('focuses the requested control and closes on Escape', async () => {
    const user = userEvent.setup()
    render(<DialogFixture />)
    await user.click(screen.getByRole('button', { name: 'Open dialog' }))

    const dialog = screen.getByRole('dialog', { name: 'Edit company' })
    expect(dialog).toHaveClass('inset-3', 'm-0', 'tablet:inset-4', 'tablet:max-h-[90dvh]')
    expect(screen.getByRole('textbox', { name: 'Company name' })).toHaveFocus()

    fireEvent(dialog, new Event('cancel', { cancelable: true }))
    await waitFor(() => expect(screen.queryByRole('dialog')).not.toBeInTheDocument())
    await waitFor(() => expect(screen.getByRole('button', { name: 'Open dialog' })).toHaveFocus())
  })

  it('restores focus to an explicit return target', async () => {
    const user = userEvent.setup()
    render(<ExternallyFocusedDialogFixture />)
    const opener = screen.getByRole('button', { name: 'Open dialog with a return target' })
    await user.click(opener)
    await user.click(screen.getByRole('button', { name: 'Close dialog' }))

    await waitFor(() => expect(opener).toHaveFocus())
  })

  it('does not dismiss on backdrop clicks when the workflow opts out', async () => {
    const user = userEvent.setup()
    render(<DialogFixture />)
    await user.click(screen.getByRole('button', { name: 'Open dialog' }))
    const dialog = screen.getByRole('dialog', { name: 'Edit company' })

    fireEvent.click(dialog)

    expect(dialog).toHaveAttribute('open')
  })

  it('prevents every dismissal path while a protected action is pending', async () => {
    const user = userEvent.setup()
    render(<DialogFixture closeOnBackdrop dismissDisabled />)
    await user.click(screen.getByRole('button', { name: 'Open dialog' }))

    const dialog = screen.getByRole('dialog', { name: 'Edit company' })
    expect(screen.getByRole('button', { name: 'Close dialog' })).toBeDisabled()

    fireEvent(dialog, new Event('cancel', { cancelable: true }))
    fireEvent.click(dialog)

    expect(dialog).toHaveAttribute('open')
  })
})
