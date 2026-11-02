import { fireEvent, render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import type { BranchDto } from '@/modules/company/branches.api'
import type { EmployeeDto } from '@/modules/hr/employees.api'
import { ApiError } from '@/shared/api/api-error'
import type { JobPosting } from '../recruitment.api'
import { ApplicantFormDialog } from './applicant-form-dialog'
import { ApplicantWorkflowFormDialog } from './applicant-workflow-form-dialog'
import { JobPostingFormDialog } from './job-posting-form-dialog'

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

const branches = [{ id: 1, branch_name: 'Lagos HQ', city: 'Lagos', state: 'Lagos' } as BranchDto]
const postings = [
  {
    id: 8,
    title: 'Operations Analyst',
    departmentId: 3,
    branchId: 1,
    jobType: 'full_time',
    status: 'active',
    applicantsCount: 0,
    createdAt: '2026-10-01T09:00:00Z',
    updatedAt: '2026-10-01T09:00:00Z',
  },
]
const existingPosting: JobPosting = {
  ...postings[0],
  departmentId: 2,
  description: '',
  requirements: '',
  responsibilities: '',
  salaryMin: null,
  salaryMax: null,
  vacancyCount: 1,
  deadline: null,
  isActive: true,
}
const interviewer = {
  id: 31,
  employee_id: 'EMP-0031',
  first_name: 'Amina',
  middle_name: '',
  last_name: 'Bello',
  designation: 'People Partner',
  department_name: 'Human Resources',
  branch_name: 'Lagos HQ',
} as EmployeeDto

describe('Recruitment forms', () => {
  it('validates required job-posting fields before saving', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    render(
      <JobPostingFormDialog
        open
        onOpenChange={vi.fn()}
        posting={null}
        branches={branches}
        departments={[]}
        branchChoicesError={false}
        departmentChoicesError={false}
        onRetryBranches={vi.fn()}
        onRetryDepartments={vi.fn()}
        onSave={onSave}
        saving={false}
      />,
    )

    await user.click(screen.getByRole('button', { name: 'Create posting' }))
    expect(await screen.findByText('Enter a job title.')).toBeVisible()
    expect(screen.getByText('Choose a branch.')).toBeVisible()
    expect(onSave).not.toHaveBeenCalled()
  })

  it('rejects a maximum salary below the minimum on a job-posting edit', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    render(
      <JobPostingFormDialog
        open
        onOpenChange={vi.fn()}
        posting={existingPosting}
        branches={branches}
        departments={[]}
        branchChoicesError={false}
        departmentChoicesError={false}
        onRetryBranches={vi.fn()}
        onRetryDepartments={vi.fn()}
        onSave={onSave}
        saving={false}
      />,
    )

    fireEvent.change(screen.getByLabelText('Minimum salary (₦)'), { target: { value: '900000' } })
    fireEvent.change(screen.getByLabelText('Maximum salary (₦)'), { target: { value: '500000' } })
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    expect(await screen.findByText('Maximum salary cannot be below the minimum.')).toBeVisible()
    expect(onSave).not.toHaveBeenCalled()
  })

  it('saves a selected numeric department ID and accepts a zero salary boundary', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    render(
      <JobPostingFormDialog
        open
        onOpenChange={vi.fn()}
        posting={existingPosting}
        branches={branches}
        departments={[{ value: '2', label: 'Human Resources' }]}
        branchChoicesError={false}
        departmentChoicesError={false}
        onRetryBranches={vi.fn()}
        onRetryDepartments={vi.fn()}
        onSave={onSave}
        saving={false}
      />,
    )

    await user.click(screen.getByRole('combobox', { name: 'Department' }))
    await user.click(await screen.findByRole('option', { name: 'Human Resources' }))
    fireEvent.change(screen.getByLabelText('Minimum salary (₦)'), { target: { value: '0' } })
    fireEvent.change(screen.getByLabelText('Maximum salary (₦)'), { target: { value: '0' } })
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    await waitFor(() => expect(onSave).toHaveBeenCalledTimes(1))
    expect(onSave).toHaveBeenCalledWith(
      expect.objectContaining({ department_id: 2, salary_min: 0, salary_max: 0 }),
    )
  })

  it('rejects scientific notation and salary values outside the decimal contract', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    render(
      <JobPostingFormDialog
        open
        onOpenChange={vi.fn()}
        posting={existingPosting}
        branches={branches}
        departments={[]}
        branchChoicesError={false}
        departmentChoicesError={false}
        onRetryBranches={vi.fn()}
        onRetryDepartments={vi.fn()}
        onSave={onSave}
        saving={false}
      />,
    )

    fireEvent.change(screen.getByLabelText('Minimum salary (₦)'), { target: { value: '1e3' } })
    fireEvent.change(screen.getByLabelText('Maximum salary (₦)'), {
      target: { value: '10000000000' },
    })
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    expect(
      await screen.findAllByText('Enter a non-negative amount with up to two decimal places.'),
    ).toHaveLength(2)
    expect(onSave).not.toHaveBeenCalled()
  })

  it('requires a job association and validates resume URLs before adding a candidate', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    render(
      <ApplicantFormDialog
        open
        onOpenChange={vi.fn()}
        applicant={null}
        postings={postings}
        postingsLoading={false}
        postingsError={false}
        onRetryPostings={vi.fn()}
        saving={false}
        onSave={onSave}
      />,
    )

    await user.click(screen.getByRole('button', { name: 'Add candidate' }))
    expect(await screen.findByText('Enter the candidate’s first name.')).toBeVisible()
    expect(screen.getByText('Choose a job posting.')).toBeVisible()
    expect(onSave).not.toHaveBeenCalled()

    await user.type(screen.getByLabelText('First name'), 'Ada')
    await user.type(screen.getByLabelText('Last name'), 'Okafor')
    await user.type(screen.getByLabelText('Email'), 'ada@example.test')
    await user.type(screen.getByLabelText('Phone'), '+2348000000000')
    await user.click(screen.getByRole('combobox', { name: 'Job posting' }))
    await user.click(await screen.findByRole('option', { name: 'Operations Analyst' }))
    await user.type(screen.getByLabelText('Resume URL'), 'javascript:alert(1)')
    await user.click(screen.getByRole('button', { name: 'Add candidate' }))

    expect(await screen.findByText('Enter a valid http or https resume link.')).toBeVisible()
    expect(onSave).not.toHaveBeenCalled()

    await user.clear(screen.getByLabelText('Resume URL'))
    await user.type(screen.getByLabelText('Resume URL'), 'https://example.test/ada-cv')
    await user.click(screen.getByRole('button', { name: 'Add candidate' }))
    await waitFor(() => expect(onSave).toHaveBeenCalledTimes(1))
    expect(onSave).toHaveBeenCalledWith(
      expect.objectContaining({
        first_name: 'Ada',
        last_name: 'Okafor',
        job_posting_id: 8,
        resume: 'https://example.test/ada-cv',
      }),
    )
  })

  it('keeps a candidate draft and reports a backend save failure', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => {
      throw new ApiError('Candidate already exists.', { status: 400 })
    })
    render(
      <ApplicantFormDialog
        open
        onOpenChange={vi.fn()}
        applicant={null}
        postings={postings}
        postingsLoading={false}
        postingsError={false}
        onRetryPostings={vi.fn()}
        saving={false}
        onSave={onSave}
      />,
    )

    await user.type(screen.getByLabelText('First name'), 'Ada')
    await user.type(screen.getByLabelText('Last name'), 'Okafor')
    await user.type(screen.getByLabelText('Email'), 'ada@example.test')
    await user.type(screen.getByLabelText('Phone'), '+2348000000000')
    await user.click(screen.getByRole('combobox', { name: 'Job posting' }))
    await user.click(await screen.findByRole('option', { name: 'Operations Analyst' }))
    await user.click(screen.getByRole('button', { name: 'Add candidate' }))

    expect(await screen.findByText('Candidate already exists.')).toBeVisible()
    expect(screen.getByLabelText('First name')).toHaveValue('Ada')
    expect(onSave).toHaveBeenCalledTimes(1)
  })

  it('explains resume-link support without exposing backend implementation details', () => {
    render(
      <ApplicantFormDialog
        open
        onOpenChange={vi.fn()}
        applicant={null}
        postings={postings}
        postingsLoading={false}
        postingsError={false}
        onRetryPostings={vi.fn()}
        saving={false}
        onSave={vi.fn(async () => undefined)}
      />,
    )

    expect(
      screen.getByText(
        'Add a secure link to the candidate’s resume. File uploads are not available here.',
      ),
    ).toBeVisible()
  })

  it('saves candidate enum choices and preserves zero-valued optional numbers', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    render(
      <ApplicantFormDialog
        open
        onOpenChange={vi.fn()}
        applicant={null}
        postings={postings}
        postingsLoading={false}
        postingsError={false}
        onRetryPostings={vi.fn()}
        saving={false}
        onSave={onSave}
      />,
    )

    await user.type(screen.getByLabelText('First name'), 'Ada')
    await user.type(screen.getByLabelText('Last name'), 'Okafor')
    await user.type(screen.getByLabelText('Email'), 'ada@example.test')
    await user.type(screen.getByLabelText('Phone'), '+2348000000000')
    await user.click(screen.getByRole('combobox', { name: 'Job posting' }))
    await user.click(await screen.findByRole('option', { name: 'Operations Analyst' }))
    await user.click(screen.getByRole('combobox', { name: 'Highest education' }))
    await user.click(await screen.findByRole('option', { name: "Bachelor's degree" }))
    await user.click(screen.getByRole('combobox', { name: 'Application source' }))
    await user.click(await screen.findByRole('option', { name: 'Referral' }))
    fireEvent.change(screen.getByLabelText('Years of experience'), { target: { value: '0' } })
    fireEvent.change(screen.getByLabelText('Expected salary (₦)'), { target: { value: '0' } })
    await user.click(screen.getByRole('button', { name: 'Add candidate' }))

    await waitFor(() => expect(onSave).toHaveBeenCalledTimes(1))
    expect(onSave).toHaveBeenCalledWith(
      expect.objectContaining({
        highest_education: 'bachelor',
        source: 'referral',
        years_of_experience: 0,
        expected_salary: 0,
      }),
    )
  })

  it('rejects candidate amounts with excess precision and does not call save', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    render(
      <ApplicantFormDialog
        open
        onOpenChange={vi.fn()}
        applicant={null}
        postings={postings}
        postingsLoading={false}
        postingsError={false}
        onRetryPostings={vi.fn()}
        saving={false}
        onSave={onSave}
      />,
    )

    await user.type(screen.getByLabelText('First name'), 'Ada')
    await user.type(screen.getByLabelText('Last name'), 'Okafor')
    await user.type(screen.getByLabelText('Email'), 'ada@example.test')
    await user.type(screen.getByLabelText('Phone'), '+2348000000000')
    await user.click(screen.getByRole('combobox', { name: 'Job posting' }))
    await user.click(await screen.findByRole('option', { name: 'Operations Analyst' }))
    fireEvent.change(screen.getByLabelText('Expected salary (₦)'), {
      target: { value: '1200.999' },
    })
    await user.click(screen.getByRole('button', { name: 'Add candidate' }))

    expect(await screen.findByText('Enter a valid non-negative amount.')).toBeVisible()
    expect(onSave).not.toHaveBeenCalled()
  })

  it('shows required interview errors under their controls before saving', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    render(
      <ApplicantWorkflowFormDialog
        mode="interview"
        open
        onOpenChange={vi.fn()}
        saving={false}
        onSave={onSave}
        interviewers={[interviewer]}
      />,
    )

    await user.click(screen.getByRole('button', { name: 'Schedule interview' }))
    expect(await screen.findByText('Select an active employee.')).toBeVisible()
    expect(screen.getByText('Choose an interview date.')).toBeVisible()
    expect(screen.getByText('Choose an interview time.')).toBeVisible()
    expect(screen.queryByRole('alert', { name: 'Details need attention' })).not.toBeInTheDocument()
    expect(onSave).not.toHaveBeenCalled()
  })

  it('schedules an interview with the selected employee record ID and normalized link', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    render(
      <ApplicantWorkflowFormDialog
        mode="interview"
        open
        onOpenChange={vi.fn()}
        saving={false}
        onSave={onSave}
        interviewers={[interviewer]}
      />,
    )

    await user.click(screen.getByRole('combobox', { name: 'Interviewer' }))
    await user.click(await screen.findByRole('option', { name: /Amina Bello/ }))
    const date = screen.getByRole('button', { name: /Date/ })
    await user.click(date)
    const todayLabel = new Intl.DateTimeFormat(undefined, {
      weekday: 'long',
      month: 'long',
      day: 'numeric',
      year: 'numeric',
    }).format(new Date())
    const calendar = screen.getByRole('dialog', { name: 'Choose a date' })
    await user.click(within(calendar).getByRole('button', { name: todayLabel }))
    await user.click(screen.getByRole('button', { name: /Local time/ }))
    await user.click(screen.getByRole('button', { name: 'Set time' }))
    await user.type(screen.getByLabelText('Meeting link'), 'https://meet.example.test/room')
    await user.click(screen.getByRole('button', { name: 'Schedule interview' }))

    await waitFor(() => expect(onSave).toHaveBeenCalledTimes(1))
    expect(onSave).toHaveBeenCalledWith(
      expect.objectContaining({
        interviewer_id: 31,
        scheduled_at: expect.any(String),
        meeting_link: 'https://meet.example.test/room',
      }),
    )
  })

  it('rejects offer content that is too short before it reaches the backend', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    render(
      <ApplicantWorkflowFormDialog
        mode="offer"
        open
        onOpenChange={vi.fn()}
        saving={false}
        onSave={onSave}
      />,
    )

    await user.type(screen.getByLabelText(/Annual salary \(₦\)/), '1000000')
    const dateField = screen.getByRole('button', { name: /Start date/ })
    await user.click(dateField)
    const calendar = screen.getByRole('dialog', { name: 'Choose a date' })
    const todayLabel = new Intl.DateTimeFormat(undefined, {
      weekday: 'long',
      month: 'long',
      day: 'numeric',
      year: 'numeric',
    }).format(new Date())
    await user.click(within(calendar).getByRole('button', { name: todayLabel }))
    await user.type(screen.getByLabelText(/Letter content/), 'Short')
    await user.click(screen.getByRole('button', { name: 'Create offer letter' }))

    expect(
      await screen.findByText('Enter at least 10 characters of offer letter content.'),
    ).toBeVisible()
    expect(
      screen.queryByText('Enter an annual salary greater than zero, with up to two decimals.'),
    ).not.toBeInTheDocument()
    expect(onSave).not.toHaveBeenCalled()
  })

  it('keeps salary and start date in one row and submits comma-formatted salary as a number', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    const { container } = render(
      <ApplicantWorkflowFormDialog
        mode="offer"
        open
        onOpenChange={vi.fn()}
        saving={false}
        onSave={onSave}
      />,
    )

    const salary = screen.getByLabelText(/Annual salary \(₦\)/)
    await user.type(salary, '1250000')
    expect(salary).toHaveValue('1,250,000')
    await user.tab()
    expect(container.querySelector('#offer-salary')?.parentElement?.parentElement).toHaveClass(
      'grid-cols-2',
    )
    const startDate = screen.getByRole('button', { name: /Start date/ })
    await user.click(startDate)
    const todayLabel = new Intl.DateTimeFormat(undefined, {
      weekday: 'long',
      month: 'long',
      day: 'numeric',
      year: 'numeric',
    }).format(new Date())
    fireEvent.click(
      within(screen.getByRole('dialog', { name: 'Choose a date' })).getByRole('button', {
        name: todayLabel,
      }),
    )
    expect(startDate).toHaveTextContent(
      new Intl.DateTimeFormat(undefined, { day: 'numeric', month: 'long', year: 'numeric' }).format(
        new Date(),
      ),
    )
    await user.type(screen.getByLabelText(/Letter content/), 'Offer letter body.')
    await user.click(screen.getByRole('button', { name: 'Create offer letter' }))

    await waitFor(() => expect(onSave).toHaveBeenCalledTimes(1))
    expect(onSave).toHaveBeenCalledWith(
      expect.objectContaining({ annual_salary: 1250000, letter_content: 'Offer letter body.' }),
    )
  })

  it('clarifies that offer delivery is managed outside this form', () => {
    render(
      <ApplicantWorkflowFormDialog
        mode="offer"
        open
        onOpenChange={vi.fn()}
        saving={false}
        onSave={vi.fn(async () => undefined)}
      />,
    )

    expect(
      screen.getByText(
        'The letter is saved to the candidate’s profile. Candidate delivery is managed separately.',
      ),
    ).toBeVisible()
  })
})
