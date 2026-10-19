import { act, fireEvent, render, screen } from '@testing-library/react'
import { afterEach, describe, expect, it, vi } from 'vitest'

import { ToastProvider } from './toast-provider'
import { useToast } from './use-toast'

function ToastTrigger({ action }: { action?: () => void }) {
  const { showToast } = useToast()

  return (
    <button
      type="button"
      onClick={() =>
        showToast({
          title: 'Company saved',
          action: action ? { label: 'Undo', onClick: action } : undefined,
        })
      }
    >
      Show toast
    </button>
  )
}

afterEach(() => {
  vi.useRealTimers()
})

describe('ToastProvider', () => {
  it('keeps a toast action available until the user acts or dismisses it', async () => {
    vi.useFakeTimers()
    const undo = vi.fn()
    render(
      <ToastProvider>
        <ToastTrigger action={undo} />
      </ToastProvider>,
    )
    fireEvent.click(screen.getByRole('button', { name: 'Show toast' }))

    await act(async () => {
      await vi.advanceTimersByTimeAsync(60_000)
    })

    expect(screen.getByRole('status')).toHaveTextContent('Company saved')
    fireEvent.click(screen.getByRole('button', { name: 'Undo' }))
    expect(undo).toHaveBeenCalledOnce()
    expect(screen.queryByRole('status')).not.toBeInTheDocument()
  })

  it('uses a five-second default and preserves the remaining time while hovered', async () => {
    vi.useFakeTimers()
    render(
      <ToastProvider>
        <ToastTrigger />
      </ToastProvider>,
    )
    fireEvent.click(screen.getByRole('button', { name: 'Show toast' }))
    const toast = screen.getByRole('status')

    await act(async () => {
      await vi.advanceTimersByTimeAsync(3000)
    })
    fireEvent.mouseEnter(toast)
    await act(async () => {
      await vi.advanceTimersByTimeAsync(10_000)
    })
    expect(screen.getByRole('status')).toBeInTheDocument()

    fireEvent.mouseLeave(toast)
    await act(async () => {
      await vi.advanceTimersByTimeAsync(1999)
    })
    expect(screen.getByRole('status')).toBeInTheDocument()

    await act(async () => {
      await vi.advanceTimersByTimeAsync(1)
    })
    expect(screen.queryByRole('status')).not.toBeInTheDocument()
  })
})
