import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import type { LoanListItem } from '../loans.api'
import { LoanRequestCard } from './loan-request-card'

const pendingLoan: LoanListItem = {
  id: 41,
  employee_user_id: 12,
  employee_name: 'Amina Okafor',
  job_title: 'Operations Analyst',
  loan_amount: '125000.00',
  repayment_date: '2026-12-15',
  reason: 'QA-20261030-loans test request reason',
  status: 'pending',
  created_at: '2026-10-30T10:00:00Z',
  updated_at: '2026-10-30T10:00:00Z',
}

function renderCard(overrides: Partial<Parameters<typeof LoanRequestCard>[0]> = {}) {
  const onView = vi.fn()
  const onEdit = vi.fn()
  const onDecision = vi.fn()
  render(
    <LoanRequestCard
      loan={pendingLoan}
      isOwn={false}
      canView
      canUpdate
      canApprove
      canReject
      onView={onView}
      onEdit={onEdit}
      onDecision={onDecision}
      {...overrides}
    />,
  )
  return { onView, onEdit, onDecision }
}

describe('LoanRequestCard', () => {
  it('shows the request details and independent review actions for another employee', async () => {
    const user = userEvent.setup()
    const { onView, onDecision } = renderCard()

    expect(screen.getByText('₦125,000.00')).toBeVisible()
    expect(screen.getByText('Operations Analyst')).toBeVisible()
    expect(screen.getByText(/QA-20261030-loans test request reason/)).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Details' }))
    await user.click(screen.getByRole('button', { name: 'Approve' }))
    expect(onView).toHaveBeenCalledOnce()
    expect(onDecision).toHaveBeenCalledWith(pendingLoan, 'approved')
  })

  it('does not expose approve/reject controls on the current user’s own request', () => {
    renderCard({ isOwn: true })

    expect(screen.getByText('You')).toBeVisible()
    expect(screen.queryByRole('button', { name: 'Approve' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Reject' })).not.toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Edit' })).toBeVisible()
  })

  it('keeps review actions available when view permission is absent', () => {
    renderCard({ canView: false })

    expect(screen.queryByRole('button', { name: 'Details' })).not.toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Approve' })).toBeVisible()
    expect(screen.getByRole('button', { name: 'Reject' })).toBeVisible()
  })

  it('hides review actions after a request leaves pending status', () => {
    renderCard({ loan: { ...pendingLoan, status: 'approved' } })

    expect(screen.getByText('approved')).toBeVisible()
    expect(screen.queryByRole('button', { name: 'Approve' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Reject' })).not.toBeInTheDocument()
  })
})
