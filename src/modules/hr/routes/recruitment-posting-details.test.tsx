import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import type { JobPosting } from '../recruitment.api'
import { PostingDetails } from './recruitment-page'

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

const posting: JobPosting = {
  id: 25,
  title: 'Senior Principal Operations and People Strategy Specialist',
  departmentId: 7,
  branchId: 4,
  jobType: 'full_time',
  status: 'active',
  description: 'Lead regional operations and people strategy.',
  responsibilities: 'Build and coach cross-functional teams.',
  requirements: 'At least 10 years of relevant experience.',
  salaryMin: '70000',
  salaryMax: '120000',
  vacancyCount: 2,
  applicantsCount: 1,
  deadline: '2026-11-12T12:00:00Z',
  isActive: true,
  createdAt: '2026-10-28T09:00:00Z',
  updatedAt: '2026-10-29T09:00:00Z',
}

describe('Recruitment posting details', () => {
  it('uses the training detail hierarchy and presents role facts and content clearly', async () => {
    const user = userEvent.setup()
    const onClose = vi.fn()
    render(
      <PostingDetails
        posting={posting}
        branches={[{ value: '4', label: 'Lagos' }]}
        departments={[{ value: '7', label: 'Human Resources' }]}
        onClose={onClose}
      />,
    )

    const dialog = screen.getByRole('dialog')
    expect(dialog).toHaveClass('tablet:max-w-[50rem]', 'max-h-[calc(100dvh-2rem)]')
    expect(screen.getByRole('heading', { name: 'Position overview' })).toBeVisible()
    expect(screen.getByRole('heading', { name: 'Role details' })).toBeVisible()
    expect(screen.getByText('Active')).toBeVisible()
    expect(screen.getByText('Full-time')).toBeVisible()
    expect(screen.getByText('1 applicant')).toBeVisible()
    expect(screen.getByText('Human Resources')).toBeVisible()
    expect(screen.getByText('Lagos')).toBeVisible()
    expect(screen.getByText('₦70,000 – ₦120,000')).toBeVisible()
    expect(screen.getByText('2 positions')).toBeVisible()
    expect(screen.getByText('Position summary')).toBeVisible()
    expect(screen.getByText('Responsibilities')).toBeVisible()
    expect(screen.getByText('Requirements')).toBeVisible()
    expect(dialog.querySelector('dl')).toHaveClass('grid-cols-1', 'phone:grid-cols-2')

    await user.click(screen.getByRole('button', { name: 'Close' }))
    expect(onClose).toHaveBeenCalledOnce()
  })

  it('handles missing assignment, salary and role copy without leaving empty sections', () => {
    render(
      <PostingDetails
        posting={{
          ...posting,
          departmentId: null,
          salaryMin: null,
          salaryMax: '90000',
          description: '',
          responsibilities: '',
          requirements: '',
        }}
        branches={[]}
        departments={[]}
        onClose={vi.fn()}
      />,
    )

    expect(screen.getByText('Not assigned')).toBeVisible()
    expect(screen.getByText('Branch #4')).toBeVisible()
    expect(screen.getByText('Up to ₦90,000')).toBeVisible()
    expect(screen.getByText('No role details have been added.')).toBeVisible()
    expect(screen.queryByText('Position summary')).not.toBeInTheDocument()
  })
})
