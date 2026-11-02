import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import { branchesApi } from '@/modules/company/branches.api'
import { companyOrganizationApi } from '@/modules/company/company-organization.api'
import { rolesApi } from '@/modules/company/roles.api'
import { employeesApi, type EmployeeDto, type EmployeeWriteInput } from '@/modules/hr/employees.api'
import { ApiError } from '@/shared/api/api-error'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { EmployeeEditor } from '@/modules/hr/routes/employees-page'

import { asDraft, buildAllowances, validateAllowanceDraft } from './employee-form-model'

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

const session: AuthenticatedSession = {
  user: {
    id: 7,
    email: 'hr-admin@example.test',
    username: 'hr-admin',
    first_name: 'HR',
    last_name: 'Admin',
    is_verified: true,
    created_at: '2026-01-01T00:00:00Z',
    role: null,
    permissions: { employees: ['list', 'create', 'update', 'exit', 'view'] },
  },
  employee: {
    id: 23,
    user_id: 7,
    employee_id: 'EMP-007',
    username: 'hr-admin',
    email: 'hr-admin@example.test',
    first_name: 'HR',
    last_name: 'Admin',
  },
  roles: [],
  permissions: { employees: ['list', 'create', 'update', 'exit', 'view'] },
}

let queryClient: QueryClient

function renderEditor({
  employee = null,
  error,
}: { employee?: EmployeeDto | null; error?: unknown } = {}) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, session)
  const onSave = vi.fn<(input: EmployeeWriteInput, image: File | null) => void>()
  const onClose = vi.fn()
  const view = render(
    <QueryClientProvider client={queryClient}>
      <EmployeeEditor
        open
        employee={employee}
        onClose={onClose}
        onSave={onSave}
        isSaving={false}
        error={error}
      />
    </QueryClientProvider>,
  )
  return { ...view, onSave, onClose }
}

beforeEach(() => {
  vi.spyOn(branchesApi, 'list').mockResolvedValue({ count: 0, items: [] })
  vi.spyOn(companyOrganizationApi, 'departments').mockResolvedValue({ count: 0, items: [] })
  vi.spyOn(rolesApi, 'list').mockResolvedValue({ count: 0, items: [] })
  vi.spyOn(employeesApi, 'list').mockResolvedValue({ count: 0, items: [] })
})

afterEach(() => {
  queryClient?.clear()
  vi.restoreAllMocks()
})

describe('asDraft', () => {
  it('maps standard allowance values to their dedicated form fields', () => {
    const draft = asDraft({
      allowances: { housing: 120000, transport: 25000, meal: 15000 },
    } as unknown as EmployeeDto)

    expect(draft.allowance_housing).toBe('120000')
    expect(draft.allowance_transport).toBe('25000')
    expect(draft.allowance_meal).toBe('15000')
    expect(draft.allowances).toBeUndefined()
  })

  it('keeps empty allowances optional when editing an employee', () => {
    const draft = asDraft({ allowances: null } as unknown as EmployeeDto)

    expect(draft.allowance_housing).toBe('')
    expect(draft.allowance_transport).toBe('')
    expect(draft.allowance_meal).toBe('')
  })

  it('builds a numeric allowances payload and preserves other existing categories', () => {
    const draft = {
      allowance_housing: '150000.50',
      allowance_transport: '',
      allowance_meal: '25000',
    }

    expect(
      buildAllowances(draft, {
        housing: 100000,
        transport: 50000,
        meal: 25000,
        airtime: 10000,
      }),
    ).toEqual({ housing: 150000.5, meal: 25000, airtime: 10000 })
    expect(validateAllowanceDraft(draft)).toEqual({})
  })

  it('validates optional allowance amounts as finite and non-negative', () => {
    expect(
      validateAllowanceDraft({ allowance_housing: '-1', allowance_transport: '1e999' }),
    ).toEqual({
      allowance_housing: 'Housing allowance must be a number greater than or equal to 0.',
      allowance_transport: 'Transport allowance must be a number greater than or equal to 0.',
    })
  })
})

describe('EmployeeEditor', () => {
  it('validates identity, contact, and job title at the step where each is entered', async () => {
    const user = userEvent.setup()
    renderEditor()

    await user.click(screen.getByRole('button', { name: 'Continue' }))
    expect(await screen.findByText('Enter the employee’s first name.')).toBeInTheDocument()
    expect(screen.getByText('Enter the employee’s last name.')).toBeInTheDocument()
    expect(screen.getByText('Enter the employee’s work email.')).toBeInTheDocument()

    await user.type(screen.getByLabelText(/^First name/), 'Amaka')
    await user.type(screen.getByLabelText(/^Last name/), 'Okafor')
    await user.type(screen.getByLabelText(/^Work email/), 'bad-email')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    expect(await screen.findByText('Enter a valid work email address.')).toBeInTheDocument()

    await user.clear(screen.getByLabelText(/^Work email/))
    await user.type(screen.getByLabelText(/^Work email/), 'amaka@example.test')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    expect(await screen.findByText('Enter the employee’s job title.')).toBeInTheDocument()
    await user.type(screen.getByLabelText(/^Job title/), 'Operations Analyst')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    expect(screen.getByText(/Step 4 of 5 · Compensation/)).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Review details' }))
    expect(screen.getByText(/Step 5 of 5 · Review/)).toBeInTheDocument()
  })

  it('rejects invalid compensation values inline and preserves the entered draft', async () => {
    const user = userEvent.setup()
    renderEditor()
    await user.type(screen.getByLabelText(/^First name/), 'Amaka')
    await user.type(screen.getByLabelText(/^Last name/), 'Okafor')
    await user.type(screen.getByLabelText(/^Work email/), 'amaka@example.test')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.type(screen.getByLabelText(/^Job title/), 'Operations Analyst')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.type(screen.getByLabelText(/^Gross salary/), '-500')
    await user.click(screen.getByRole('button', { name: 'Review details' }))

    expect(
      await screen.findByText('Gross salary must be a number greater than or equal to 0.'),
    ).toBeInTheDocument()
    expect(screen.getByLabelText(/^Gross salary/)).toHaveValue(-500)
  })

  it('saves the three allowance amounts as a structured numeric payload', async () => {
    const user = userEvent.setup()
    const { onSave } = renderEditor()
    await user.type(screen.getByLabelText(/^First name/), 'Amaka')
    await user.type(screen.getByLabelText(/^Last name/), 'Okafor')
    await user.type(screen.getByLabelText(/^Work email/), 'amaka@example.test')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.type(screen.getByLabelText(/^Job title/), 'Operations Analyst')
    await user.click(screen.getByRole('button', { name: 'Continue' }))

    expect(screen.getByLabelText('Housing allowance (₦)')).toBeVisible()
    expect(screen.getByLabelText('Transport allowance (₦)')).toBeVisible()
    expect(screen.getByLabelText('Meal allowance (₦)')).toBeVisible()
    expect(screen.queryByLabelText(/Allowances \(JSON\)/)).not.toBeInTheDocument()

    const housingField = screen.getByLabelText('Housing allowance (₦)')
    await user.type(housingField, '-1')
    await user.click(screen.getByRole('button', { name: 'Review details' }))
    expect(
      await screen.findByText('Housing allowance must be a number greater than or equal to 0.'),
    ).toBeInTheDocument()
    expect(housingField).toHaveValue(-1)

    await user.clear(housingField)
    await user.type(housingField, '150000')
    await user.type(screen.getByLabelText('Meal allowance (₦)'), '25000.50')
    await user.click(screen.getByRole('button', { name: 'Review details' }))

    expect(screen.getByText('₦150,000.00')).toBeVisible()
    expect(screen.getByText('₦25,000.50')).toBeVisible()
    expect(screen.getAllByText('Not provided').length).toBeGreaterThan(0)
    await user.click(screen.getByRole('button', { name: 'Create employee' }))
    expect(onSave).toHaveBeenCalledWith(
      expect.objectContaining({
        allowances: { housing: 150000, meal: 25000.5 },
      }),
      null,
    )
  })

  it('reviews employee data before saving and masks sensitive identifiers', async () => {
    const user = userEvent.setup()
    const { onSave } = renderEditor()
    await user.type(screen.getByLabelText(/^First name/), 'Amaka')
    await user.type(screen.getByLabelText(/^Last name/), 'Okafor')
    await user.type(screen.getByLabelText(/^Work email/), 'amaka@example.test')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.type(screen.getByLabelText(/^Job title/), 'Operations Analyst')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.type(screen.getByLabelText(/^Account number/), '1234567890')
    await user.click(screen.getByRole('button', { name: 'Review details' }))

    expect(screen.getByText(/Step 5 of 5 · Review/)).toBeInTheDocument()
    expect(screen.getByText('Amaka Okafor')).toBeInTheDocument()
    expect(screen.getByText('Operations Analyst')).toBeInTheDocument()
    expect(screen.getByText('•••• 7890')).toBeInTheDocument()
    expect(screen.queryByText('1234567890')).not.toBeInTheDocument()
    expect(onSave).not.toHaveBeenCalled()

    await user.click(screen.getAllByRole('button', { name: 'Edit' })[0])
    expect(screen.getByText(/Step 1 of 5 · Identity/)).toBeInTheDocument()
    expect(screen.getByLabelText(/^First name/)).toHaveValue('Amaka')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Review details' }))
    await user.click(screen.getByRole('button', { name: 'Create employee' }))
    expect(onSave).toHaveBeenCalledWith(
      expect.objectContaining({ account_number: '1234567890' }),
      null,
    )
  })

  it('keeps the form values when the server rejects the save and blocks unsupported photos', async () => {
    const user = userEvent.setup({ applyAccept: false })
    const { rerender } = renderEditor()
    await user.type(screen.getByLabelText(/^First name/), 'Amaka')
    await user.type(screen.getByLabelText(/^Last name/), 'Okafor')
    await user.type(screen.getByLabelText(/^Work email/), 'amaka@example.test')
    await user.upload(
      screen.getByLabelText('Profile photo'),
      new File(['not an image'], 'avatar.gif', { type: 'image/gif' }),
    )
    expect(await screen.findByText('Choose a PNG, JPG, or WEBP image.')).toBeInTheDocument()

    rerender(
      <QueryClientProvider client={queryClient}>
        <EmployeeEditor
          open
          employee={null}
          onClose={vi.fn()}
          onSave={vi.fn()}
          isSaving={false}
          error={new ApiError('Email already exists.', { status: 400 })}
        />
      </QueryClientProvider>,
    )
    expect(screen.getByLabelText(/^First name/)).toHaveValue('Amaka')
    expect(screen.getByLabelText(/^Work email/)).toHaveValue('amaka@example.test')
    expect(screen.getByRole('alert')).toHaveTextContent('Your entered details are preserved.')
  })

  it('keeps employment status read-only in employee edit and routes changes through profile actions', async () => {
    const terminated = {
      ...({} as EmployeeDto),
      user_id: 52,
      first_name: 'Amaka',
      last_name: 'Okafor',
      employment_status: 'terminated',
      department_units: [],
    }
    const user = userEvent.setup()
    renderEditor({ employee: terminated })
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Continue' }))

    expect(screen.getByText('Terminated')).toBeVisible()
    expect(
      screen.getByText(/Use the profile actions to manage access, leave, deactivation, or exit/),
    ).toBeVisible()
    expect(screen.queryByRole('combobox', { name: /^Employment status/ })).not.toBeInTheDocument()
  })

  it('preserves backend-supported associate employment types while editing', async () => {
    const employee = {
      ...({} as EmployeeDto),
      user_id: 52,
      first_name: 'QA',
      last_name: 'Associate',
      employment_type: 'lawyer-associate',
      employment_status: 'on-leave',
      department_units: [],
    }
    const user = userEvent.setup()
    renderEditor({ employee })

    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Continue' }))

    expect(screen.getByLabelText(/^Employment type/)).toHaveTextContent('Lawyer Associate')
    await user.click(screen.getByLabelText(/^Employment type/))
    expect(await screen.findByRole('option', { name: 'Lawyer Associate' })).toBeInTheDocument()
    expect(screen.queryByRole('option', { name: 'Associate' })).not.toBeInTheDocument()
  })
})
