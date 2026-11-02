import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import { ApiError } from '@/shared/api/api-error'

import type { TrainingProgram, TrainingProgramInput } from '../training-programs.api'
import type { LoanRequest } from '../loans.api'
import { TrainingProgramFormDialog } from './training-program-form-dialog'
import { LoanFormDialog } from './loan-form-dialog'

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
  id: 4,
  program_name: 'Safety essentials',
  provider: 'SafeWork',
  description: 'Workplace safety training.',
  start_date: '2026-11-01',
  end_date: '2026-11-03',
  cost: '15000.00',
  target_audience: 'all_employees',
  status: 'pending',
  duration_days: 3,
  is_ongoing: false,
  is_upcoming: true,
  created_at: '2026-10-01T10:00:00Z',
  updated_at: '2026-10-01T10:00:00Z',
}

const loan: LoanRequest = {
  id: 8,
  employee_user_id: 12,
  employee_name: 'Amina Okafor',
  job_title: 'Analyst',
  loan_amount: '75,000.00',
  repayment_date: '2026-12-01',
  reason: 'Tuition support',
  status: 'Pending',
  emergency_contact_name: 'Chidi Okafor',
  emergency_contact_phone: '+2348000000000',
  attachment: '',
  created_at: '2026-10-01T10:00:00Z',
  updated_at: '2026-10-01T10:00:00Z',
}

describe('Training and loan forms', () => {
  it('rejects an empty training program while allowing an optional provider', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn<(input: TrainingProgramInput) => Promise<void>>(async () => undefined)
    render(
      <TrainingProgramFormDialog
        open
        onOpenChange={vi.fn()}
        program={null}
        saving={false}
        onSave={onSave}
      />,
    )
    await user.click(screen.getByRole('button', { name: 'Create program' }))
    expect(await screen.findByText('Enter a program name.')).toBeVisible()
    expect(screen.getByText('Choose a start date.')).toBeVisible()
    expect(screen.getByText('Choose an end date.')).toBeVisible()
    expect(onSave).not.toHaveBeenCalled()
  })

  it('creates a free program with optional provider and same-day schedule', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn<(input: TrainingProgramInput) => Promise<void>>(async () => undefined)
    render(
      <TrainingProgramFormDialog
        open
        onOpenChange={vi.fn()}
        program={null}
        saving={false}
        onSave={onSave}
      />,
    )

    await user.type(screen.getByLabelText(/Program name/), '  Safety essentials  ')
    await user.click(screen.getByLabelText(/Start date/))
    const startGrid = await screen.findByRole('grid')
    const today = within(startGrid).getByRole('button', { current: 'date' })
    const todayName = today.getAttribute('aria-label')
    await user.click(today)
    await user.click(screen.getByLabelText(/End date/))
    const endGrid = await screen.findByRole('grid')
    await user.click(within(endGrid).getByRole('button', { name: todayName! }))

    await user.click(screen.getByRole('button', { name: 'Create program' }))

    expect(onSave).toHaveBeenCalledWith(
      expect.objectContaining({
        program_name: 'Safety essentials',
        provider: '',
        cost: 0,
        start_date: expect.any(String),
        end_date: expect.any(String),
        target_audience: 'all_employees',
        status: 'pending',
      }),
    )
    const input = onSave.mock.calls[0][0]
    expect(input.start_date).toBe(input.end_date)
  })

  it('rejects a negative training cost before sending the program', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn<(input: TrainingProgramInput) => Promise<void>>(async () => undefined)
    render(
      <TrainingProgramFormDialog
        open
        onOpenChange={vi.fn()}
        program={null}
        saving={false}
        onSave={onSave}
      />,
    )

    await user.type(screen.getByLabelText(/Program name/), 'Safety essentials')
    await user.click(screen.getByLabelText(/Start date/))
    const startGrid = await screen.findByRole('grid')
    const today = within(startGrid).getByRole('button', { current: 'date' })
    const todayName = today.getAttribute('aria-label')
    await user.click(today)
    await user.click(screen.getByLabelText(/End date/))
    const endGrid = await screen.findByRole('grid')
    await user.click(within(endGrid).getByRole('button', { name: todayName! }))
    await user.clear(screen.getByLabelText(/Program cost/))
    await user.type(screen.getByLabelText(/Program cost/), '-1')
    await user.click(screen.getByRole('button', { name: 'Create program' }))

    expect(
      await screen.findByText('Enter a non-negative cost with up to two decimal places.'),
    ).toBeVisible()
    expect(onSave).not.toHaveBeenCalled()
  })

  it('uses the edit values and surfaces a server rejection without closing the training form', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => {
      throw new ApiError('The program changed. Refresh the list and try again.', { status: 409 })
    })
    render(
      <TrainingProgramFormDialog
        open
        onOpenChange={vi.fn()}
        program={program}
        saving={false}
        onSave={onSave}
      />,
    )
    expect(screen.getByLabelText(/Program name/)).toHaveValue('Safety essentials')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))
    expect(await screen.findByRole('alert')).toHaveTextContent(/refresh the latest information/i)
    expect(screen.getByRole('dialog', { name: 'Edit training program' })).toHaveAttribute('open')
  })

  it('requires valid loan terms and future repayment before submission', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    render(
      <LoanFormDialog
        open
        onOpenChange={vi.fn()}
        loan={null}
        currentUserId={7}
        currentEmployeeName="HR Admin"
        employees={[]}
        canChooseEmployee={false}
        employeeChoicesLoading={false}
        onRetryEmployees={vi.fn()}
        saving={false}
        onUploadAttachment={async () => 'https://files.example.test/loan.pdf'}
        onSave={onSave}
      />,
    )
    await user.click(screen.getByRole('button', { name: 'Submit request' }))
    expect(
      await screen.findByText(
        'Enter a positive amount with up to 8 whole digits and 2 decimal places.',
      ),
    ).toBeVisible()
    expect(screen.getByText('Choose the planned repayment date.')).toBeVisible()
    expect(screen.getByText('Enter a reason of at least 3 characters.')).toBeVisible()
    await waitFor(() => expect(screen.getByLabelText(/Loan amount/)).toHaveFocus())
    expect(onSave).not.toHaveBeenCalled()
  })

  it('prefills a loan edit and uploads a selected supporting document before saving', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    const onUploadAttachment = vi.fn(async () => 'https://files.example.test/loan-proof.pdf')
    render(
      <LoanFormDialog
        open
        onOpenChange={vi.fn()}
        loan={loan}
        currentUserId={12}
        currentEmployeeName="Amina Okafor"
        employees={[]}
        canChooseEmployee={false}
        employeeChoicesLoading={false}
        onRetryEmployees={vi.fn()}
        saving={false}
        onUploadAttachment={onUploadAttachment}
        onSave={onSave}
      />,
    )
    expect(screen.getByLabelText(/Loan amount \(₦\)/)).toHaveValue('75,000.00')
    const proof = new File(['proof'], 'loan-proof.pdf', { type: 'application/pdf' })
    await user.upload(screen.getByLabelText('Choose supporting document'), proof)
    expect(screen.getByText('loan-proof.pdf')).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Save changes' }))
    await waitFor(() => expect(onUploadAttachment).toHaveBeenCalledWith(proof))
    expect(onSave).toHaveBeenCalledWith(
      expect.objectContaining({
        attachment: 'https://files.example.test/loan-proof.pdf',
      }),
    )
  })

  it('removes an existing supporting document without requiring a replacement', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    render(
      <LoanFormDialog
        open
        onOpenChange={vi.fn()}
        loan={{ ...loan, attachment: 'https://files.example.test/existing-proof.pdf' }}
        currentUserId={12}
        currentEmployeeName="Amina Okafor"
        employees={[]}
        canChooseEmployee={false}
        employeeChoicesLoading={false}
        onRetryEmployees={vi.fn()}
        saving={false}
        onUploadAttachment={async () => 'https://files.example.test/replacement.pdf'}
        onSave={onSave}
      />,
    )

    expect(screen.getByRole('link', { name: 'View current document' })).toHaveAttribute(
      'href',
      'https://files.example.test/existing-proof.pdf',
    )
    await user.click(screen.getByRole('button', { name: 'Remove current supporting document' }))
    expect(screen.queryByRole('link', { name: 'View current document' })).not.toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    expect(onSave).toHaveBeenCalledWith(expect.objectContaining({ attachment: undefined }))
  })

  it('shows upload failures under the picker and keeps the edit form open', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    const onUploadAttachment = vi.fn(async () => {
      throw new ApiError('The upload could not be completed.', { status: 400 })
    })
    render(
      <LoanFormDialog
        open
        onOpenChange={vi.fn()}
        loan={loan}
        currentUserId={12}
        currentEmployeeName="Amina Okafor"
        employees={[]}
        canChooseEmployee={false}
        employeeChoicesLoading={false}
        onRetryEmployees={vi.fn()}
        saving={false}
        onUploadAttachment={onUploadAttachment}
        onSave={onSave}
      />,
    )
    const proof = new File(['proof'], 'loan-proof.pdf', { type: 'application/pdf' })
    await user.upload(screen.getByLabelText('Choose supporting document'), proof)
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    const uploadError = await screen.findByRole('status')
    expect(uploadError).toHaveTextContent(/request could not be completed|upload/i)
    expect(uploadError).toHaveAttribute('id', 'loan-attachment-error')
    expect(screen.getByRole('dialog', { name: 'Edit loan request' })).toHaveAttribute('open')
    expect(onSave).not.toHaveBeenCalled()
    expect(screen.getByText('loan-proof.pdf')).toBeVisible()
  })

  it('rejects unsupported and oversized supporting documents before upload', async () => {
    const user = userEvent.setup({ applyAccept: false })
    const onSave = vi.fn(async () => undefined)
    const onUploadAttachment = vi.fn(async () => 'https://files.example.test/loan.pdf')
    render(
      <LoanFormDialog
        open
        onOpenChange={vi.fn()}
        loan={loan}
        currentUserId={12}
        currentEmployeeName="Amina Okafor"
        employees={[]}
        canChooseEmployee={false}
        employeeChoicesLoading={false}
        onRetryEmployees={vi.fn()}
        saving={false}
        onUploadAttachment={onUploadAttachment}
        onSave={onSave}
      />,
    )
    const picker = screen.getByLabelText('Choose supporting document')
    await user.upload(picker, new File(['bad'], 'script.exe'))
    expect(await screen.findByText('Choose an image, PDF, or Office document.')).toBeVisible()

    const oversized = new File(['proof'], 'large.pdf', { type: 'application/pdf' })
    Object.defineProperty(oversized, 'size', { value: 15 * 1024 * 1024 + 1 })
    await user.upload(picker, oversized)
    expect(await screen.findByText('Choose a file that is 15 MB or smaller.')).toBeVisible()
    expect(onUploadAttachment).not.toHaveBeenCalled()
    expect(onSave).not.toHaveBeenCalled()
  })

  it('keeps loan edit values and the uploaded link for retry after a rejected update', async () => {
    const user = userEvent.setup()
    const onUploadAttachment = vi.fn(async () => 'https://files.example.test/retry-proof.pdf')
    const onSave = vi.fn(async () => {
      throw new ApiError('This request changed on the server. Refresh and try again.', {
        status: 409,
      })
    })
    render(
      <LoanFormDialog
        open
        onOpenChange={vi.fn()}
        loan={loan}
        currentUserId={12}
        currentEmployeeName="Amina Okafor"
        employees={[]}
        canChooseEmployee={false}
        employeeChoicesLoading={false}
        onRetryEmployees={vi.fn()}
        saving={false}
        onUploadAttachment={onUploadAttachment}
        onSave={onSave}
      />,
    )

    const proof = new File(['proof'], 'retry-proof.pdf', { type: 'application/pdf' })
    await user.upload(screen.getByLabelText('Choose supporting document'), proof)
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    expect(await screen.findByRole('alert')).toHaveTextContent(/refresh the latest information/i)
    expect(screen.getByRole('dialog', { name: 'Edit loan request' })).toHaveAttribute('open')
    expect(screen.getByLabelText(/Loan amount \(₦\)/)).toHaveValue('75,000.00')
    expect(screen.getByText('View current document')).toBeVisible()
    expect(onSave).toHaveBeenLastCalledWith(
      expect.objectContaining({ attachment: 'https://files.example.test/retry-proof.pdf' }),
    )

    await user.click(screen.getByRole('button', { name: 'Save changes' }))
    await waitFor(() => expect(onSave).toHaveBeenCalledTimes(2))
    expect(onUploadAttachment).toHaveBeenCalledTimes(1)
  })

  it('groups loan amounts as typed and removes grouping before saving', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    render(
      <LoanFormDialog
        open
        onOpenChange={vi.fn()}
        loan={null}
        currentUserId={7}
        currentEmployeeName="HR Admin"
        employees={[]}
        canChooseEmployee={false}
        employeeChoicesLoading={false}
        onRetryEmployees={vi.fn()}
        saving={false}
        onUploadAttachment={async () => 'https://files.example.test/loan.pdf'}
        onSave={onSave}
      />,
    )

    const amount = screen.getByLabelText(/Loan amount/)
    await user.type(amount, '125000.50')
    expect(amount).toHaveValue('125,000.50')
    await user.click(screen.getByLabelText(/Planned repayment date/))
    const calendar = await screen.findByRole('dialog', { name: 'Choose a date' })
    await user.click(within(calendar).getByRole('button', { name: 'Next month' }))
    const nextMonthDate = new Date(new Date().getFullYear(), new Date().getMonth() + 1, 15)
      .toISOString()
      .slice(0, 10)
    await user.click(calendar.querySelector(`[data-date="${nextMonthDate}"]`) as HTMLButtonElement)
    await user.type(
      screen.getByLabelText(/Reason for request/),
      'QA-20261030-loans create and edit test',
    )
    await user.type(screen.getByLabelText(/Contact name/), 'QA Emergency Contact')
    await user.type(screen.getByLabelText(/Contact phone/), '+2348000000099')
    await user.click(screen.getByRole('button', { name: 'Submit request' }))

    expect(onSave).toHaveBeenCalledWith(expect.objectContaining({ loan_amount: 125000.5 }))
  })

  it('rejects scientific notation, excess precision, and amounts above the API limit', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => undefined)
    render(
      <LoanFormDialog
        open
        onOpenChange={vi.fn()}
        loan={null}
        currentUserId={7}
        currentEmployeeName="HR Admin"
        employees={[]}
        canChooseEmployee={false}
        employeeChoicesLoading={false}
        onRetryEmployees={vi.fn()}
        saving={false}
        onUploadAttachment={async () => 'https://files.example.test/loan.pdf'}
        onSave={onSave}
      />,
    )

    const amount = screen.getByLabelText(/Loan amount/)
    await user.type(amount, '1e4')
    expect(amount).toHaveValue('14')
    await user.clear(amount)
    await user.type(amount, '12.345')
    await user.click(screen.getByRole('button', { name: 'Submit request' }))
    expect(
      await screen.findByText(
        'Enter a positive amount with up to 8 whole digits and 2 decimal places.',
      ),
    ).toBeVisible()
    expect(onSave).not.toHaveBeenCalled()
    await user.clear(amount)
    await user.type(amount, '123456789')
    await user.click(screen.getByRole('button', { name: 'Submit request' }))
    expect(
      screen.getByText('Enter a positive amount with up to 8 whole digits and 2 decimal places.'),
    ).toBeVisible()
    expect(onSave).not.toHaveBeenCalled()
  })
})
