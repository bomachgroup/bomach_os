import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import type { TrainingProgram } from '../training-programs.api'
import { ProgramDetails } from './training-programs-page'

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

const program: TrainingProgram = {
  id: 33,
  program_name: 'QA training program',
  provider: 'QA Learning',
  description: 'Program details from the last successful response.',
  start_date: '2026-10-29',
  end_date: '2026-10-29',
  cost: '125.50',
  target_audience: 'technical_staff',
  status: 'in_progress',
  duration_days: 1,
  is_ongoing: false,
  is_upcoming: false,
  created_at: '2026-10-29T10:00:00Z',
  updated_at: '2026-10-29T10:00:00Z',
}

describe('Training program details', () => {
  it('uses a content-sized dialog and formats cost with the naira symbol and grouped thousands', () => {
    render(
      <ProgramDetails
        program={{ ...program, cost: '1250000.50' }}
        loading={false}
        error={undefined}
        canEdit
        canDelete
        onClose={vi.fn()}
        onRetry={vi.fn()}
        onEdit={vi.fn()}
        onDelete={vi.fn()}
      />,
    )

    const dialog = screen.getByRole('dialog')
    expect(dialog).toHaveClass('max-h-[calc(100dvh-2rem)]')
    expect(dialog.querySelector('.min-h-0')).toHaveClass('flex-auto')
    expect(dialog.querySelector('.grid-cols-1')).toHaveClass('phone:grid-cols-2')
    expect(screen.getByRole('heading', { name: 'Schedule and investment' })).toBeVisible()
    expect(screen.getByText('₦1,250,000.5')).toBeVisible()
  })

  it('shows a loading state instead of stale details while a cached record refreshes', () => {
    render(
      <ProgramDetails
        program={program}
        loading
        error={undefined}
        canEdit
        canDelete
        onClose={vi.fn()}
        onRetry={vi.fn()}
        onEdit={vi.fn()}
        onDelete={vi.fn()}
      />,
    )

    expect(screen.getByRole('dialog', { name: 'Loading training program' })).toBeVisible()
    expect(screen.getByRole('dialog').querySelector('[aria-busy="true"]')).toBeInTheDocument()
    expect(screen.queryByText('Program overview')).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Edit program' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: /^Delete$/ })).not.toBeInTheDocument()
  })

  it('shows the retryable error instead of stale details when refresh fails', async () => {
    const user = userEvent.setup()
    const onRetry = vi.fn()
    render(
      <ProgramDetails
        program={program}
        loading={false}
        error={new Error('The detail refresh failed.')}
        canEdit
        canDelete
        onClose={vi.fn()}
        onRetry={onRetry}
        onEdit={vi.fn()}
        onDelete={vi.fn()}
      />,
    )

    expect(screen.getByRole('heading', { name: 'Unable to load this page' })).toBeVisible()
    expect(screen.queryByText('Program overview')).not.toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(onRetry).toHaveBeenCalledOnce()
  })
})
