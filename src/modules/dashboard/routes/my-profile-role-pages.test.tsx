import { createElement, type ReactNode } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

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

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return {
    ...actual,
    Link: ({
      to,
      children,
      className,
      onClick,
    }: {
      to: string
      children: ReactNode
      className?: string
      onClick?: () => void
    }) => createElement('a', { href: to, className, onClick }, children),
  }
})

vi.mock('@/modules/auth/components/two-factor-settings-panel', () => ({
  TwoFactorSettingsPanel: () => <div data-testid="two-factor-settings" />,
}))

import { ApiError } from '@/shared/api/api-error'
import { authApi } from '@/shared/auth/auth.api'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { myRoleApi, type AssignedRoleDto } from '../role.api'
import { MyProfilePage } from './my-profile-page'
import { MyRolePage } from './my-role-page'

function createSession(permissions: Record<string, string[]> = {}): AuthenticatedSession {
  return {
    user: {
      id: 7,
      email: 'avery@example.com',
      username: 'avery',
      first_name: 'Avery',
      last_name: 'Person',
      is_verified: true,
      created_at: '2026-01-10T08:00:00Z',
      role: { id: 5, name: 'Project Coordinator' },
      permissions: {},
    },
    employee: {
      user_id: 7,
      employee_id: 'EMP-007',
      username: 'avery',
      email: 'avery@example.com',
      first_name: 'Avery',
      middle_name: 'Taylor',
      last_name: 'Person',
      personal_email: 'avery.personal@example.com',
      phone_number: '+234 800 000 0000',
      date_of_birth: '1992-04-11',
      gender: 'Female',
      marital_status: 'Single',
      nationality: 'Nigerian',
      address: '12 Sample Street',
      city: 'Enugu',
      state: 'Enugu',
      designation: 'Project Coordinator',
      employment_type: 'Full-time',
      employment_status: 'Permanent',
      start_date: '2022-03-01',
      branch_name: 'Enugu Branch',
      department_name: 'Projects',
      // This mirrors fields returned by the backend schema but must not be rendered here.
      salary: 'Confidential salary value',
      bank_account_number: 'Confidential account value',
      pension_number: 'Confidential pension value',
      health_benefit: 'Confidential benefits value',
    } as AuthenticatedSession['employee'],
    roles: [],
    permissions,
  }
}

function renderPage(component: ReactNode, permissions: Record<string, string[]> = {}) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, createSession(permissions))
  return {
    queryClient,
    ...render(<QueryClientProvider client={queryClient}>{component}</QueryClientProvider>),
  }
}

const assignedRole: AssignedRoleDto = {
  id: 5,
  name: 'Project Coordinator',
  branches: [{ id: 3, branch_name: 'Enugu Branch' }],
  permissions: { tasks: ['list_own', 'update_own'], role_descriptions: ['view_own'] },
  created_at: '2024-01-01T00:00:00Z',
  updated_at: '2026-01-01T00:00:00Z',
}

describe('My Profile and My Role pages', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
    window.sessionStorage.clear()
  })

  it('shows only employee-facing profile fields and keeps the page read-only', async () => {
    renderPage(<MyProfilePage />)

    expect(await screen.findByRole('heading', { name: 'Avery Taylor Person' })).toBeInTheDocument()
    expect(screen.getByText('EMP-007')).toBeInTheDocument()
    expect(screen.getByText('avery.personal@example.com')).toBeInTheDocument()
    expect(screen.getByText('12 Sample Street, Enugu, Enugu')).toBeInTheDocument()
    expect(screen.getByTestId('two-factor-settings')).toBeInTheDocument()
    expect(screen.queryByText(/salary|bank account|pension|benefit/i)).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: /edit profile/i })).not.toBeInTheDocument()
    expect(screen.queryByText(/Confidential/)).not.toBeInTheDocument()
  })

  it('keeps the full password reset flow inside Profile and explains the new session', async () => {
    const user = userEvent.setup()
    renderPage(<MyProfilePage />)

    const requestCode = vi.spyOn(authApi, 'forgotPassword').mockResolvedValue({
      success: true,
      detail: 'If an account exists for that email, a password reset code will be sent.',
    })
    const resetPassword = vi.spyOn(authApi, 'resetPassword').mockResolvedValue({
      success: true,
      detail: 'Password reset successfully.',
    })

    await user.click(await screen.findByRole('button', { name: 'Change password' }))
    expect(screen.getByRole('dialog', { name: 'Change your password' })).toBeInTheDocument()
    expect(screen.getAllByText('avery@example.com')).toHaveLength(3)
    await user.click(screen.getByRole('button', { name: 'Send verification code' }))
    await waitFor(() => expect(requestCode.mock.calls[0]?.[0]).toBe('avery@example.com'))

    await user.type(await screen.findByRole('textbox', { name: 'Verification code' }), '123456')
    await user.type(screen.getByPlaceholderText('At least 8 characters'), 'NewPassword-123!')
    await user.type(screen.getByPlaceholderText('Re-enter new password'), 'NewPassword-123!')
    await user.click(screen.getByRole('button', { name: 'Update password' }))

    await waitFor(() =>
      expect(resetPassword.mock.calls[0]?.[0]).toEqual({
        email: 'avery@example.com',
        code: '123456',
        new_password: 'NewPassword-123!',
      }),
    )
    expect(await screen.findByRole('heading', { name: 'Password updated' })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Continue to sign in' })).toHaveAttribute(
      'href',
      '/login',
    )
    expect(screen.queryByRole('link', { name: 'Change password' })).not.toBeInTheDocument()
  })

  it('loads role sections only when opened and keeps section permission errors local', async () => {
    const user = userEvent.setup()
    const description = vi.spyOn(myRoleApi, 'description').mockResolvedValue({
      id: 1,
      role_id: 5,
      purpose: 'Coordinate projects.',
      responsibilities: 'Track plans and delivery.',
      job_description: '',
      created_at: '2026-01-01T00:00:00Z',
      updated_at: '2026-01-01T00:00:00Z',
    })
    const kpis = vi
      .spyOn(myRoleApi, 'kpis')
      .mockRejectedValue(new ApiError('Not allowed', { status: 403 }))
    vi.spyOn(myRoleApi, 'assignedRole').mockResolvedValue(assignedRole)

    renderPage(<MyRolePage />, {
      roles: ['view_own'],
      role_descriptions: ['view_own'],
      role_kpis: ['list_own'],
    })

    expect(await screen.findByRole('heading', { name: 'Project Coordinator' })).toBeInTheDocument()
    expect(description).not.toHaveBeenCalled()
    expect(kpis).not.toHaveBeenCalled()

    await user.click(screen.getByRole('button', { name: /Description & responsibilities/ }))
    expect(await screen.findByText('Coordinate projects.')).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: /Key performance indicators/ }))

    expect(
      await screen.findByText('Your account does not have permission to view this section.'),
    ).toBeInTheDocument()
    expect(screen.getByText('Coordinate projects.')).toBeInTheDocument()
    await waitFor(() => expect(kpis).toHaveBeenCalledOnce())
  })

  it('treats a missing assigned role as a dedicated empty state', async () => {
    vi.spyOn(myRoleApi, 'assignedRole').mockRejectedValue(
      new ApiError('No role assigned', { status: 404 }),
    )
    renderPage(<MyRolePage />, { roles: ['view_own'] })

    expect(await screen.findByRole('heading', { name: 'No role assigned yet' })).toBeInTheDocument()
  })

  it('shows useful shared guidance for each assigned permission', async () => {
    const user = userEvent.setup()
    vi.spyOn(myRoleApi, 'assignedRole').mockResolvedValue(assignedRole)

    renderPage(<MyRolePage />, { roles: ['view_own'] })
    const permissionsPanel = await screen.findByRole('button', { name: /Permissions & authority/ })
    expect(permissionsPanel).toHaveAttribute('aria-expanded', 'true')

    const actionsStat = await screen.findByText('Actions', { exact: true })
    const resourcesStat = screen.getByText('Resources', { exact: true })
    expect(actionsStat.parentElement).toHaveTextContent('3')
    expect(resourcesStat.parentElement).toHaveTextContent('2')
    await user.click(
      screen.getByRole('button', { name: 'Projects & operations permission subgroup' }),
    )
    await user.click(screen.getByRole('button', { name: 'Tasks permission set' }))
    const action = screen.getByLabelText('Update Own permission for Tasks')
    fireEvent.focus(action)
    expect(screen.getByRole('tooltip')).toHaveTextContent(
      'Update tasks assigned to you, such as their progress or status.',
    )
  })
})
