import { useEffect, useState, type FormEvent, type ReactNode } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { Eye, EyeOff, Handshake, ShieldCheck } from 'lucide-react'

import { ApiError } from '@/shared/api/api-error'
import { SESSION_ESTABLISHED_KEY } from '@/shared/api/api-client'
import { authApi } from '@/shared/auth/auth.api'
import { clearWorkspaceMode, setWorkspaceMode } from '@/shared/auth/workspace-mode'
import { presentError } from '@/shared/errors'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { FormControl, TextInput } from '@/shared/ui/form-control'
import { AuthFormAlert, AuthLogo, AuthPageFrame } from '@/modules/auth/components/auth-page-frame'
import { AuthTextInput } from '@/modules/auth/components/auth-text-input'
import { partnerPortalApi } from '../partner.api'
import type { PartnerTwoFactorSearch } from '../partner.search'

const roleCopy = ['Realtors', 'Surveyors', 'Legal associates', 'Consultants']

function PartnerBrand() {
  return (
    <div className="flex items-center gap-3">
      <div className="flex size-11 items-center justify-center rounded-2xl bg-[#061A3A] text-lg font-black text-white shadow-sm">
        B
      </div>
      <div className="min-w-0">
        <p className="text-[11px] font-extrabold tracking-[0.18em] text-[#C62828]">BOMACH GROUP</p>
        <p className="text-sm font-semibold text-[#061A3A]">Partner workspace</p>
      </div>
    </div>
  )
}

function PartnerAuthFrame({
  eyebrow,
  title,
  description,
  children,
}: {
  eyebrow: string
  title: string
  description: string
  children: ReactNode
}) {
  return (
    <main className="relative min-h-svh overflow-hidden bg-[#F4F7FB] px-4 py-5 text-[#172033] sm:px-6 sm:py-8">
      <div
        aria-hidden="true"
        className="pointer-events-none absolute -top-44 right-[-5rem] size-[27rem] rounded-full bg-[#DDE8F5] opacity-70 blur-3xl"
      />
      <div
        aria-hidden="true"
        className="pointer-events-none absolute bottom-[-11rem] left-[-7rem] size-[25rem] rounded-full bg-[#F6DFDF] opacity-60 blur-3xl"
      />
      <div className="relative mx-auto flex min-h-[calc(100svh-2.5rem)] w-full max-w-6xl flex-col">
        <header className="flex items-center justify-between gap-4">
          <PartnerBrand />
          <div className="hidden items-center gap-2 rounded-full border border-[#DDE4EC] bg-white/80 px-3 py-2 text-xs font-semibold text-[#52627A] sm:flex">
            <ShieldCheck className="size-4 text-[#0B3974]" aria-hidden="true" />
            Secure partner access
          </div>
        </header>
        <div className="grid flex-1 items-center gap-8 py-10 lg:grid-cols-[1.05fr_0.95fr] lg:gap-14 lg:py-14">
          <section className="hidden max-w-xl lg:block">
            <p className="text-xs font-extrabold tracking-[0.24em] text-[#0B3974]">{eyebrow}</p>
            <h1 className="mt-4 text-5xl leading-[1.06] font-semibold tracking-[-0.04em] text-[#061A3A] xl:text-6xl">
              {title}
            </h1>
            <p className="mt-5 max-w-lg text-lg leading-8 text-[#52627A]">{description}</p>
            <div className="mt-10 grid grid-cols-2 gap-3">
              {roleCopy.map((role, index) => (
                <div
                  key={role}
                  className="flex items-center gap-3 rounded-2xl border border-white/80 bg-white/75 px-4 py-3 shadow-sm"
                >
                  <span
                    className={`flex size-8 items-center justify-center rounded-xl font-semibold ${index === 0 ? 'bg-[#FDE8E8] text-[#9E2626]' : 'bg-[#E8EFF8] text-[#0B3974]'}`}
                  >
                    <Handshake className="size-4" aria-hidden="true" />
                  </span>
                  <span className="text-sm font-semibold text-[#25354D]">{role}</span>
                </div>
              ))}
            </div>
          </section>
          <section className="mx-auto w-full max-w-xl">
            <div className="mb-6 lg:hidden">
              <p className="text-xs font-extrabold tracking-[0.2em] text-[#0B3974]">{eyebrow}</p>
              <h1 className="mt-2 text-3xl leading-tight font-semibold tracking-[-0.03em] text-[#061A3A]">
                {title}
              </h1>
              <p className="mt-2 text-sm leading-6 text-[#52627A]">{description}</p>
            </div>
            {children}
          </section>
        </div>
        <footer className="flex flex-wrap items-center justify-between gap-2 border-t border-[#DDE4EC] py-4 text-xs text-[#718096]">
          <span>Bomach partner access</span>
          <span>Support: contact your Bomach representative</span>
        </footer>
      </div>
    </main>
  )
}

export function PartnerLoginPage() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [visible, setVisible] = useState(false)
  const [error, setError] = useState('')
  const [submitting, setSubmitting] = useState(false)

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setError('')
    setSubmitting(true)
    try {
      const result = await authApi.login({ email: email.trim(), password })
      if (result.requires_2fa) {
        await navigate({ to: '/partners/two-factor', search: { next: 'home' } })
        return
      }
      try {
        await partnerPortalApi.me()
      } catch (cause) {
        await authApi.logout().catch(() => undefined)
        window.sessionStorage.removeItem(SESSION_ESTABLISHED_KEY)
        clearWorkspaceMode()
        queryClient.clear()
        if (cause instanceof ApiError && cause.status === 403) {
          setError(
            'This sign-in is for invited partner accounts. No partner workspace is linked to this account.',
          )
        } else {
          setError(presentError(cause, 'form-submit').message)
        }
        return
      }
      queryClient.clear()
      setWorkspaceMode('partner')
      window.sessionStorage.setItem(SESSION_ESTABLISHED_KEY, '1')
      await navigate({ to: '/partners/app', search: { tab: 'home' }, replace: true })
    } catch (cause) {
      setError(presentError(cause, 'form-submit').message)
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <AuthPageFrame cardClassName="max-w-[440px] px-6 py-8 sm:px-8 sm:py-8">
      <div className="space-y-6 text-center">
        <AuthLogo />
        <div>
          <h1 className="text-h1 font-semibold">Welcome back</h1>
          <p className="text-body-md text-text-secondary mt-1.5">
            Sign in to continue to your Bomach partner workspace.
          </p>
        </div>

        <AuthFormAlert message={error || null} />

        <form className="space-y-4 text-left" onSubmit={(event) => void submit(event)}>
          <FormControl id="partner-login-email" label="Email" required>
            <AuthTextInput
              icon="email"
              autoComplete="username"
              type="email"
              inputMode="email"
              placeholder="Enter your email"
              value={email}
              onChange={(event) => setEmail(event.currentTarget.value)}
              required
            />
          </FormControl>
          <FormControl id="partner-login-password" label="Password" required>
            <AuthTextInput
              icon="lock"
              autoComplete="current-password"
              type={visible ? 'text' : 'password'}
              placeholder="Enter your password"
              value={password}
              onChange={(event) => setPassword(event.currentTarget.value)}
              trailing={
                <button
                  type="button"
                  className="text-text-muted focus-visible:shadow-focus-ring rounded-control absolute inset-y-0 right-2 flex size-10 items-center justify-center focus-visible:outline-none"
                  aria-label={visible ? 'Hide password' : 'Show password'}
                  aria-pressed={visible}
                  onClick={() => setVisible((value) => !value)}
                >
                  {visible ? <EyeOff className="size-[18px]" /> : <Eye className="size-[18px]" />}
                </button>
              }
              required
            />
          </FormControl>
          <Button type="submit" isLoading={submitting} className="w-full">
            Sign in
          </Button>
        </form>
        <p className="text-caption text-text-muted pt-1 text-center">
          Partner access is invitation-only. New partners can set up their account from the
          invitation email.
        </p>
      </div>
    </AuthPageFrame>
  )
}

export function PartnerSetupPage() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [token, setToken] = useState(
    () => new URLSearchParams(window.location.search).get('token') ?? '',
  )
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [visible, setVisible] = useState(false)
  const [error, setError] = useState('')
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    const previous = document.querySelector('meta[name="referrer"]')
    const meta = previous ?? document.createElement('meta')
    meta.setAttribute('name', 'referrer')
    meta.setAttribute('content', 'no-referrer')
    if (!previous) document.head.append(meta)
    if (token) window.history.replaceState({}, document.title, '/partners/setup')
    return () => {
      if (!previous) meta.remove()
    }
  }, [token])

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setError('')
    if (!token) {
      setError(
        'This setup link is missing or no longer available. Ask Bomach to send a new invitation.',
      )
      return
    }
    if (password.length < 8) {
      setError('Use a password with at least 8 characters.')
      return
    }
    if (password !== confirmPassword) {
      setError('The passwords do not match.')
      return
    }
    setSubmitting(true)
    try {
      const setup = await partnerPortalApi.completeSetup({
        setup_token: token,
        new_password: password,
      })
      const login = await authApi.login({ email: setup.email, password })
      setToken('')
      setPassword('')
      setConfirmPassword('')
      if (login.requires_2fa) {
        await navigate({ to: '/partners/two-factor', search: { next: 'profile' }, replace: true })
        return
      }
      await partnerPortalApi.me()
      queryClient.clear()
      setWorkspaceMode('partner')
      window.sessionStorage.setItem(SESSION_ESTABLISHED_KEY, '1')
      await navigate({ to: '/partners/app', search: { tab: 'profile' }, replace: true })
    } catch (cause) {
      setError(presentError(cause, 'form-submit').message)
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <PartnerAuthFrame
      eyebrow="ACCOUNT SETUP"
      title="Set up your partner access."
      description="Choose a secure password to activate your Bomach partner account. You’ll continue directly into your workspace."
    >
      <Card className="rounded-[1.75rem] border-white/80 bg-white/95 p-5 shadow-xl shadow-[#061A3A]/[0.08] sm:p-8">
        <PartnerBrand />
        <div className="mt-8">
          <h2 className="text-2xl font-semibold tracking-tight text-[#061A3A]">
            Create your password
          </h2>
          <p className="mt-2 text-sm leading-6 text-[#61718A]">
            Use at least 8 characters. The link can only be used once.
          </p>
        </div>
        {token ? (
          <form className="mt-7 space-y-5" onSubmit={(event) => void submit(event)}>
            <FormControl id="partner-setup-password" label="Password" required>
              <div className="relative">
                <TextInput
                  autoComplete="new-password"
                  type={visible ? 'text' : 'password'}
                  minLength={8}
                  value={password}
                  onChange={(event) => setPassword(event.currentTarget.value)}
                  className="pr-12"
                  required
                />
                <button
                  type="button"
                  className="absolute inset-y-0 right-0 flex w-12 items-center justify-center text-[#61718A] focus-visible:outline-2 focus-visible:outline-offset-[-4px] focus-visible:outline-[#0B3974]"
                  aria-label={visible ? 'Hide password' : 'Show password'}
                  onClick={() => setVisible((value) => !value)}
                >
                  {visible ? <EyeOff className="size-4" /> : <Eye className="size-4" />}
                </button>
              </div>
            </FormControl>
            <FormControl id="partner-setup-confirm" label="Confirm password" required>
              <TextInput
                autoComplete="new-password"
                type={visible ? 'text' : 'password'}
                value={confirmPassword}
                onChange={(event) => setConfirmPassword(event.currentTarget.value)}
                required
              />
            </FormControl>
            {error ? (
              <Alert tone="danger" role="alert">
                {error}
              </Alert>
            ) : null}
            <Button
              type="submit"
              isLoading={submitting}
              className="min-h-12 w-full rounded-xl bg-[#C62828] text-white hover:bg-[#A91F1F]"
            >
              Create password and continue
            </Button>
          </form>
        ) : (
          <div className="mt-7 space-y-4">
            <Alert tone="danger" role="alert">
              This setup link is missing or no longer available. Ask Bomach to send a new
              invitation.
            </Alert>
            <Button
              type="button"
              variant="outline"
              className="w-full"
              onClick={() => void navigate({ to: '/partners/login' })}
            >
              Return to partner sign in
            </Button>
          </div>
        )}
      </Card>
    </PartnerAuthFrame>
  )
}

export function PartnerTwoFactorPage() {
  const routeSearch = useSearch({ from: '/partners/two-factor' }) as PartnerTwoFactorSearch
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [code, setCode] = useState('')
  const [error, setError] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [pending, setPending] = useState<boolean | null>(null)

  useEffect(() => {
    let active = true
    void authApi.browserTwoFactorChallengeStatus().then(
      (result) => active && setPending(result.pending),
      () => active && setPending(false),
    )
    return () => {
      active = false
    }
  }, [])

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setError('')
    setSubmitting(true)
    try {
      await authApi.verifyTwoFactor(code)
      try {
        await partnerPortalApi.me()
      } catch (cause) {
        await authApi.logout().catch(() => undefined)
        window.sessionStorage.removeItem(SESSION_ESTABLISHED_KEY)
        clearWorkspaceMode()
        queryClient.clear()
        if (cause instanceof ApiError && cause.status === 403) {
          setError(
            'This sign-in is for invited partner accounts. No partner workspace is linked to this account.',
          )
          return
        }
        throw cause
      }
      queryClient.clear()
      setWorkspaceMode('partner')
      window.sessionStorage.setItem(SESSION_ESTABLISHED_KEY, '1')
      await navigate({ to: '/partners/app', search: { tab: routeSearch.next }, replace: true })
    } catch (cause) {
      setError(presentError(cause, 'two-factor').message)
    } finally {
      setSubmitting(false)
    }
  }

  async function cancel() {
    await authApi.cancelTwoFactor().catch(() => undefined)
    await navigate({ to: '/partners/login', replace: true })
  }

  return (
    <PartnerAuthFrame
      eyebrow="SECURE SIGN IN"
      title="One more security check."
      description="Enter the six-digit code sent to the email address on your Bomach partner account."
    >
      <Card className="rounded-[1.75rem] border-white/80 bg-white/95 p-5 shadow-xl shadow-[#061A3A]/[0.08] sm:p-8">
        <PartnerBrand />
        <div className="mt-8">
          <h2 className="text-2xl font-semibold tracking-tight text-[#061A3A]">
            Verify your sign in
          </h2>
          <p className="mt-2 text-sm leading-6 text-[#61718A]">
            {pending === false
              ? 'Your verification session has expired. Return to sign in to request a new code.'
              : 'Enter the code to continue to your workspace.'}
          </p>
        </div>
        {pending === false ? (
          <Button variant="outline" className="mt-7 w-full" onClick={() => void cancel()}>
            Return to partner sign in
          </Button>
        ) : (
          <form className="mt-7 space-y-5" onSubmit={(event) => void submit(event)}>
            <FormControl id="partner-2fa-code" label="Verification code" required>
              <TextInput
                autoComplete="one-time-code"
                inputMode="numeric"
                maxLength={6}
                pattern="[0-9]{6}"
                value={code}
                onChange={(event) =>
                  setCode(event.currentTarget.value.replace(/\D/g, '').slice(0, 6))
                }
                required
                className="text-center text-xl tracking-[0.35em]"
              />
            </FormControl>
            {error ? (
              <Alert tone="danger" role="alert">
                {error}
              </Alert>
            ) : null}
            <Button
              type="submit"
              isLoading={submitting}
              className="w-full rounded-xl bg-[#C62828] text-white hover:bg-[#A91F1F]"
            >
              Verify and continue
            </Button>
            <Button variant="ghost" className="w-full" onClick={() => void cancel()}>
              Cancel sign in
            </Button>
          </form>
        )}
      </Card>
    </PartnerAuthFrame>
  )
}
