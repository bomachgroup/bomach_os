import { createElement, type ReactNode } from 'react'
import { focusManager, QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import axe from 'axe-core'
import { beforeEach, describe, expect, it, vi } from 'vitest'

const routerMocks = vi.hoisted(() => ({
  navigate: vi.fn(),
  search: { returnTo: undefined as string | undefined, expired: false, reset: false },
}))

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return {
    ...actual,
    Link: ({ to, children, className }: { to: string; children: ReactNode; className?: string }) =>
      createElement('a', { href: to, className }, children),
    useNavigate: () => routerMocks.navigate,
    useSearch: () => routerMocks.search,
  }
})

import { authApi } from '@/shared/auth/auth.api'
import { ApiError } from '@/shared/api/api-error'
import {
  SESSION_ESTABLISHED_KEY,
  SESSION_EXPIRED_NOTICE_CONSUMED,
  SESSION_EXPIRED_NOTICE_KEY,
} from '@/shared/api/api-client'
import { BiometricPage } from './biometric-page'
import { ForgotPasswordPage } from './forgot-password-page'
import { LoginPage } from './login-page'
import { ResetPasswordPage } from './reset-password-page'
import { TwoFactorVerifyPage } from './two-factor-verify-page'

function renderInQueryProvider(children: ReactNode) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  return render(<QueryClientProvider client={queryClient}>{children}</QueryClientProvider>)
}

async function expectNoAxeViolations(container: HTMLElement) {
  const results = await axe.run(container, {
    rules: { 'color-contrast': { enabled: false } },
  })
  expect(results.violations.map(({ id }) => id)).toEqual([])
}

describe('authentication pages', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
    vi.clearAllMocks()
    window.sessionStorage.clear()
    routerMocks.search = { returnTo: undefined, expired: false, reset: false }
    vi.spyOn(authApi, 'browserTwoFactorChallengeStatus').mockResolvedValue({
      success: true,
      pending: true,
    })
  })

  it('keeps the password draft and shows one generic login error after server rejection', async () => {
    const user = userEvent.setup()
    const login = vi.spyOn(authApi, 'login').mockRejectedValue(
      new ApiError('Internal server detail', {
        status: 401,
        code: 'AUTH_INVALID_CREDENTIALS',
      }),
    )
    renderInQueryProvider(<LoginPage />)

    await user.type(screen.getByRole('textbox', { name: 'Email' }), 'person@example.com')
    await user.type(screen.getByLabelText(/^Password/), '  exact password  ')
    await user.click(screen.getByRole('button', { name: 'Sign in' }))

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'The email address or password is incorrect. Check both and try again.',
    )
    expect(screen.queryAllByRole('alert')).toHaveLength(1)
    expect(screen.getByLabelText(/^Password/)).toHaveValue('  exact password  ')
    expect(login.mock.calls[0]?.[0]).toEqual({
      email: 'person@example.com',
      password: '  exact password  ',
    })
    expect(screen.queryByText('Internal server detail')).not.toBeInTheDocument()

    const email = screen.getByRole('textbox', { name: 'Email' })
    await user.clear(email)
    await user.type(email, 'another@example.com')
    expect(screen.queryByRole('alert')).not.toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: 'Sign in' }))
    expect(await screen.findByRole('alert')).toHaveTextContent(
      'The email address or password is incorrect. Check both and try again.',
    )
    const password = screen.getByLabelText(/^Password/)
    await user.clear(password)
    await user.type(password, 'replacement-password')
    expect(screen.queryByRole('alert')).not.toBeInTheDocument()
  })

  it('replaces the expired-session notice with the login error after a failed sign-in', async () => {
    const user = userEvent.setup()
    routerMocks.search = {
      returnTo: '/services/app/dashboard',
      expired: true,
      reset: false,
    }
    window.sessionStorage.setItem(SESSION_EXPIRED_NOTICE_KEY, '1')
    vi.spyOn(authApi, 'login').mockRejectedValue(
      new ApiError('Upstream sign-in failure', { status: 503 }),
    )
    const view = renderInQueryProvider(<LoginPage />)

    expect(screen.getByText('Your session expired')).toBeInTheDocument()
    expect(window.sessionStorage.getItem(SESSION_EXPIRED_NOTICE_KEY)).toBe(
      SESSION_EXPIRED_NOTICE_CONSUMED,
    )

    await user.type(screen.getByRole('textbox', { name: 'Email' }), 'person@example.com')
    await user.type(screen.getByLabelText(/^Password/), 'password')
    await user.click(screen.getByRole('button', { name: 'Sign in' }))

    expect(
      await screen.findByText(
        'The sign-in service is temporarily unavailable. Please try again shortly.',
      ),
    ).toBeInTheDocument()
    expect(screen.queryByText('Your session expired')).not.toBeInTheDocument()
    expect(screen.getByLabelText(/^Password/)).toHaveValue('password')

    view.unmount()
    renderInQueryProvider(<LoginPage />)
    expect(screen.queryByText('Your session expired')).not.toBeInTheDocument()
  })

  it('focuses the first invalid field after an empty sign-in attempt', async () => {
    const user = userEvent.setup()
    renderInQueryProvider(<LoginPage />)

    await user.click(screen.getByRole('button', { name: 'Sign in' }))

    expect(screen.getByRole('textbox', { name: 'Email' })).toHaveFocus()
    expect(screen.getByText('Enter a valid email address.')).toBeInTheDocument()
  })

  it('renders biometric sign-in as a full-size disabled action while the backend is unavailable', async () => {
    const user = userEvent.setup()
    renderInQueryProvider(<LoginPage />)

    const biometricButton = screen.getByRole('button', { name: 'Use biometric' })
    expect(biometricButton).toBeDisabled()
    expect(biometricButton).toHaveClass('min-h-12', 'w-full')
    expect(biometricButton).toHaveAttribute('aria-describedby', 'biometric-sign-in-unavailable')
    expect(screen.getByText('Biometric sign-in is currently unavailable.')).toHaveClass('sr-only')
    expect(screen.queryByRole('link', { name: 'Use biometric' })).not.toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Forgot password?' })).toHaveAttribute(
      'href',
      '/forgot-password',
    )

    await user.click(biometricButton)
    expect(routerMocks.navigate).not.toHaveBeenCalled()
  })

  it('continues to two-factor verification after the server confirms the challenge', async () => {
    const user = userEvent.setup()
    routerMocks.search.returnTo = '/hr/employees?status=active'
    vi.spyOn(authApi, 'login').mockResolvedValue({
      success: true,
      requires_2fa: true,
      detail: 'Code sent',
    })
    renderInQueryProvider(<LoginPage />)

    await user.type(screen.getByRole('textbox', { name: 'Email' }), 'person@example.com')
    await user.type(screen.getByLabelText(/^Password/), 'Password 123!')
    await user.click(screen.getByRole('button', { name: 'Sign in' }))

    await waitFor(() =>
      expect(routerMocks.navigate).toHaveBeenCalledWith({
        to: '/two-factor-verify',
        search: { returnTo: '/hr/employees?status=active' },
      }),
    )
  })

  it('waits for a confirmed reset request before offering the code form', async () => {
    const user = userEvent.setup()
    routerMocks.search.returnTo = '/services/app/quotations?status=draft'
    const forgot = vi.spyOn(authApi, 'forgotPassword').mockResolvedValue({
      success: true,
      detail: 'If an account exists, a password reset code will be sent.',
    })
    renderInQueryProvider(<ForgotPasswordPage />)

    await user.type(screen.getByLabelText(/^Email Address/), 'person@example.com')
    await user.click(screen.getByRole('button', { name: 'Send Reset Code' }))

    expect(await screen.findByText('Check your email')).toBeInTheDocument()
    expect(routerMocks.navigate).not.toHaveBeenCalled()
    expect(forgot.mock.calls[0]?.[0]).toBe('person@example.com')
    await user.click(screen.getByRole('button', { name: 'Continue to enter reset code' }))
    expect(routerMocks.navigate).toHaveBeenCalledWith({
      to: '/reset-password',
      search: { returnTo: '/services/app/quotations?status=draft' },
    })
    expect(window.sessionStorage.getItem('bomach:reset-email')).toBe('person@example.com')
  })

  it('preserves the return target through successful two-factor verification', async () => {
    const user = userEvent.setup()
    routerMocks.search.returnTo = '/company/profile?tab=details'
    vi.spyOn(authApi, 'verifyTwoFactor').mockResolvedValue({ success: true, user_id: 7 })
    renderInQueryProvider(<TwoFactorVerifyPage />)

    await user.type(await screen.findByRole('textbox', { name: 'Verification Code' }), '123456')
    await user.click(screen.getByRole('button', { name: 'Verify Code' }))

    await waitFor(() =>
      expect(routerMocks.navigate).toHaveBeenCalledWith({
        to: '/splash',
        search: { returnTo: '/company/profile?tab=details' },
      }),
    )
  })

  it('shows the expired two-factor state immediately when no challenge is pending', async () => {
    const user = userEvent.setup()
    routerMocks.search.returnTo = '/hr/attendance?month=2026-10'
    vi.mocked(authApi.browserTwoFactorChallengeStatus).mockResolvedValue({
      success: true,
      pending: false,
    })
    renderInQueryProvider(<TwoFactorVerifyPage />)

    expect(
      await screen.findByRole('heading', { name: 'Verification session expired' }),
    ).toBeInTheDocument()
    expect(screen.queryByRole('textbox', { name: 'Verification Code' })).not.toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Return to Login' }))
    expect(routerMocks.navigate).toHaveBeenCalledWith({
      to: '/login',
      search: { returnTo: '/hr/attendance?month=2026-10' },
    })
  })

  it('rechecks an active two-factor challenge when the browser regains focus', async () => {
    const status = vi
      .mocked(authApi.browserTwoFactorChallengeStatus)
      .mockResolvedValueOnce({ success: true, pending: true })
      .mockResolvedValueOnce({ success: true, pending: false })
    renderInQueryProvider(<TwoFactorVerifyPage />)

    expect(await screen.findByRole('heading', { name: '2FA Verification' })).toBeInTheDocument()
    focusManager.setFocused(false)
    focusManager.setFocused(true)

    expect(
      await screen.findByRole('heading', { name: 'Verification session expired' }),
    ).toBeInTheDocument()
    expect(status).toHaveBeenCalledTimes(2)
  })

  it('moves to the expired state when a verification session expires during code entry', async () => {
    const user = userEvent.setup()
    vi.mocked(authApi.browserTwoFactorChallengeStatus)
      .mockResolvedValueOnce({ success: true, pending: true })
      .mockResolvedValueOnce({ success: true, pending: false })
    vi.spyOn(authApi, 'verifyTwoFactor').mockRejectedValue(
      new ApiError('Your verification session has expired.', { status: 401 }),
    )
    renderInQueryProvider(<TwoFactorVerifyPage />)

    await user.type(await screen.findByRole('textbox', { name: 'Verification Code' }), '123456')
    await user.click(screen.getByRole('button', { name: 'Verify Code' }))

    expect(
      await screen.findByRole('heading', { name: 'Verification session expired' }),
    ).toBeInTheDocument()
    expect(screen.queryByRole('textbox', { name: 'Verification Code' })).not.toBeInTheDocument()
  })

  it('returns to login only after a server-confirmed password reset', async () => {
    const user = userEvent.setup()
    routerMocks.search.returnTo = '/services/app/quotations?status=draft'
    window.sessionStorage.setItem('bomach:reset-email', 'person@example.com')
    window.sessionStorage.setItem(SESSION_ESTABLISHED_KEY, '1')
    const reset = vi.spyOn(authApi, 'resetPassword').mockResolvedValue({ success: true })
    renderInQueryProvider(<ResetPasswordPage />)

    await user.type(screen.getByRole('textbox', { name: 'Reset Code' }), '123456')
    await user.type(screen.getByLabelText(/^New Password/), 'new-password-123')
    await user.type(screen.getByLabelText(/^Confirm Password/), 'new-password-123')
    await user.click(screen.getByRole('button', { name: 'Reset Password' }))

    await waitFor(() =>
      expect(routerMocks.navigate).toHaveBeenCalledWith({
        to: '/login',
        search: { reset: true, returnTo: '/services/app/quotations?status=draft' },
      }),
    )
    expect(reset.mock.calls[0]?.[0]).toEqual({
      email: 'person@example.com',
      code: '123456',
      new_password: 'new-password-123',
    })
    expect(window.sessionStorage.getItem(SESSION_ESTABLISHED_KEY)).toBeNull()
  })

  it('requires a confirmed reset request before showing the code form', () => {
    window.sessionStorage.removeItem('bomach:reset-email')
    renderInQueryProvider(<ResetPasswordPage />)

    expect(screen.getByRole('heading', { name: 'Set New Password' })).toBeInTheDocument()
    expect(screen.getByText('Start with a reset request')).toBeInTheDocument()
    expect(
      screen.getByText('Enter your email address first so we can send a reset code.'),
    ).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Request a reset code' })).toBeInTheDocument()
    expect(screen.queryByRole('textbox', { name: 'Reset Code' })).not.toBeInTheDocument()
  })

  it('shows the browser-unavailable biometric state and password fallback', () => {
    renderInQueryProvider(<BiometricPage />)

    expect(
      screen.getByText('Biometric sign-in is not supported in this browser.'),
    ).toBeInTheDocument()
    expect(screen.queryByRole('button')).not.toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Use Password Instead' })).toHaveAttribute(
      'href',
      '/login',
    )
  })

  it('keeps the sign-in layout free of basic axe accessibility violations', async () => {
    const { container } = renderInQueryProvider(<LoginPage />)
    await expectNoAxeViolations(container)
  })

  it('keeps forgot-password controls accessible', async () => {
    const { container } = renderInQueryProvider(<ForgotPasswordPage />)
    await expectNoAxeViolations(container)
  })

  it('keeps the complete password-reset form accessible', async () => {
    window.sessionStorage.setItem('bomach:reset-email', 'person@example.com')
    const { container } = renderInQueryProvider(<ResetPasswordPage />)
    await expectNoAxeViolations(container)
  })

  it('keeps two-factor code entry accessible', async () => {
    const { container } = renderInQueryProvider(<TwoFactorVerifyPage />)
    await expectNoAxeViolations(container)
  })

  it('keeps biometric-unavailable fallback accessible', async () => {
    const { container } = renderInQueryProvider(<BiometricPage />)
    await expectNoAxeViolations(container)
  })
})
