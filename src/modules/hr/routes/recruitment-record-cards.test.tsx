import { render, screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import type { Applicant, JobPostingListItem } from '../recruitment.api'
import type { StatusTone } from '@/shared/ui/status-chip'
import { ApplicantCard, JobPostingCard } from './recruitment-record-cards'

const posting: JobPostingListItem = {
  id: 25,
  title: 'QA Operations Lead',
  departmentId: 7,
  branchId: 4,
  jobType: 'full_time',
  status: 'draft',
  applicantsCount: 2,
  createdAt: '2026-10-28T09:00:00Z',
  updatedAt: '2026-10-29T09:00:00Z',
}

const applicant: Applicant = {
  id: 25,
  firstName: 'Avery '.repeat(12).trim(),
  lastName: 'Recruitment Candidate',
  email: 'qa-20261028-recruitment-25@example.test',
  phone: '+2348000000000',
  jobPosting: posting,
  status: 'offered',
  resume: null,
  coverLetter: null,
  createdAt: '2026-10-28T09:00:00Z',
  updatedAt: '2026-10-29T09:00:00Z',
  address: null,
  currentJobTitle: 'Operations Director',
  yearsOfExperience: 25,
  highestEducation: 'Bachelor degree',
  institutionName: null,
  source: 'company_website',
  expectedSalary: '550000.00',
  notes: null,
}

const statusTone = (status: string): StatusTone => (status === 'active' ? 'success' : 'neutral')

describe('Recruitment record cards', () => {
  it('arranges job opening facts and keeps secondary actions in the overflow menu', async () => {
    const user = userEvent.setup()
    const onStatusChange = vi.fn()
    render(
      <JobPostingCard
        posting={posting}
        branchName="Lagos"
        departmentName="Operations"
        jobTypeLabel="Full-time"
        dateLabel={() => 'Oct 29, 2026'}
        statusTone={statusTone}
        statusOptions={[
          { value: 'draft', label: 'Draft' },
          { value: 'active', label: 'Active' },
          { value: 'closed', label: 'Closed' },
        ]}
        canView
        canUpdate
        canDelete
        editLoading={false}
        editDisabled={false}
        statusSaving={false}
        onView={vi.fn()}
        onEdit={vi.fn()}
        onStatusChange={onStatusChange}
        onDelete={vi.fn()}
      />,
    )

    expect(screen.getByRole('heading', { name: 'QA Operations Lead' })).toBeVisible()
    expect(screen.getByText('Full-time')).toBeVisible()
    expect(screen.getByText('Lagos')).toBeVisible()
    expect(screen.getByText('2 applicants')).toBeVisible()
    expect(screen.getByText('Job opening ID · #25')).toBeVisible()
    expect(screen.getByRole('button', { name: 'Details' })).toBeVisible()

    await user.click(screen.getByRole('button', { name: 'More actions for QA Operations Lead' }))
    const menu = screen.getByRole('menu', { name: 'Actions for QA Operations Lead' })
    expect(within(menu).getByRole('menuitem', { name: 'Edit job opening' })).toBeVisible()
    expect(
      within(menu).queryByRole('menuitem', { name: 'Set status to Draft' }),
    ).not.toBeInTheDocument()
    await user.click(within(menu).getByRole('menuitem', { name: 'Set status to Active' }))
    expect(onStatusChange).toHaveBeenCalledWith('active')
  })

  it('keeps candidate identity readable and the compact stage menu labels uncropped', async () => {
    const user = userEvent.setup()
    render(
      <ApplicantCard
        applicant={applicant}
        dateLabel={() => 'Oct 28, 2026'}
        statusTone={statusTone}
        canView
        canUpdate
        canChangeStatus
        canDelete
        editLoading={false}
        editDisabled={false}
        onView={vi.fn()}
        onEdit={vi.fn()}
        onStatusChange={vi.fn()}
        onDelete={vi.fn()}
      />,
    )

    expect(
      screen.getByRole('heading', { name: `${applicant.firstName} ${applicant.lastName}` }),
    ).toBeVisible()
    expect(screen.getByText('QA Operations Lead')).toBeVisible()
    expect(screen.getByText(applicant.email)).toBeVisible()
    expect(screen.getByText('Operations Director')).toBeVisible()
    expect(screen.getByText('25 years')).toBeVisible()
    expect(screen.getByText('Candidate ID · #25')).toBeVisible()
    expect(screen.getByText('Applied Oct 28, 2026')).toBeVisible()
    expect(screen.getByRole('button', { name: 'Profile' })).toBeVisible()
    const stage = screen.getByRole('combobox', {
      name: `Change ${applicant.firstName} ${applicant.lastName} stage`,
    })
    expect(stage).toBeVisible()
    expect(stage.parentElement).toHaveClass('w-28', 'shrink-0')

    await user.click(stage)
    const stageMenu = screen.getByRole('listbox', {
      name: `Change ${applicant.firstName} ${applicant.lastName} stage`,
    })
    expect(stageMenu).toHaveStyle({ width: '176px' })
    for (const label of ['Applied', 'Shortlisted', 'Interviewed', 'Offered', 'Hired', 'Rejected']) {
      expect(within(stageMenu).getByRole('option', { name: label })).toBeVisible()
    }
  })
})
