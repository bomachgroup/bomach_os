import { useEffect, useRef, useState, type FormEvent } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { useForm } from '@tanstack/react-form'
import { Link, useNavigate, useSearch } from '@tanstack/react-router'
import { z } from 'zod'

import { authApi } from '@/shared/auth/auth.api'
import { presentError } from '@/shared/errors'
import { authQueryKeys } from '@/shared/auth/auth.queries'
import { AUTH_SESSION_QUERY_KEY } from '@/shared/auth/session'
import {
  SESSION_ESTABLISHED_KEY,
  SESSION_EXPIRED_NOTICE_CONSUMED,
  SESSION_EXPIRED_NOTICE_KEY,
} from '@/shared/api/api-client'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { FormControl } from '@/shared/ui/form-control'
import { AuthTextInput } from '../components/auth-text-input'
import { focusFirstInvalidField } from '../components/focus-first-invalid-field'
import { AuthFormAlert, AuthLogo, AuthPageFrame } from '../components/auth-page-frame'

const emailSchema = z.string().trim().email('Enter a valid email address.')
const passwordSchema = z.string().min(1, 'Enter your password.')

export function LoginPage() {
  const search = useSearch({ from: '/login' })
  const [formError, setFormError] = useState<string | null>(null)
  const [expiredNoticeVisible, setExpiredNoticeVisible] = useState(
    () =>
      search.expired &&
      window.sessionStorage.getItem(SESSION_EXPIRED_NOTICE_KEY) !== SESSION_EXPIRED_NOTICE_CONSUMED,
  )
  const [passwordVisible, setPasswordVisible] = useState(false)
  const formElement = useRef<HTMLFormElement>(null)
  const queryClient = useQueryClient()
  const navigate = useNavigate()
  const loginMutation = useMutation({ mutationFn: authApi.login })

  useEffect(() => {
    if (search.expired) {
      window.sessionStorage.setItem(SESSION_EXPIRED_NOTICE_KEY, SESSION_EXPIRED_NOTICE_CONSUMED)
    }
  }, [search.expired])

  const form = useForm({
    defaultValues: { email: '', password: '' },
    onSubmit: async ({ value }) => {
      setFormError(null)
      setExpiredNoticeVisible(false)
      window.sessionStorage.setItem(SESSION_EXPIRED_NOTICE_KEY, SESSION_EXPIRED_NOTICE_CONSUMED)
      try {
        const response = await loginMutation.mutateAsync({
          email: value.email.trim(),
          password: value.password,
        })
        if (response.requires_2fa) {
          window.sessionStorage.removeItem(SESSION_ESTABLISHED_KEY)
          await queryClient.removeQueries({ queryKey: authQueryKeys.twoFactorChallengeStatus })
          await navigate({
            to: '/two-factor-verify',
            search: { returnTo: search.returnTo },
          })
          return
        }
        window.sessionStorage.setItem(SESSION_ESTABLISHED_KEY, '1')
        await queryClient.removeQueries({ queryKey: AUTH_SESSION_QUERY_KEY })
        await navigate({
          to: '/splash',
          search: { returnTo: search.returnTo },
        })
      } catch (error) {
        setFormError(presentError(error, 'login').message)
      }
    },
  })

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    void form.handleSubmit().then(() => focusFirstInvalidField(formElement.current))
  }

  return (
    <AuthPageFrame dimBackground cardClassName="max-w-[440px] px-6 py-8 sm:px-8 sm:py-8">
      <div className="space-y-6 text-center">
        <AuthLogo />
        <div>
          <h1 className="text-h1 font-semibold">Welcome back</h1>
          <p className="text-body-md text-text-secondary mt-1.5">
            Sign in to continue to Bomach OS
          </p>
        </div>

        {expiredNoticeVisible ? (
          <Alert tone="warning" title="Your session expired">
            Sign in again to continue where you left off.
          </Alert>
        ) : null}
        {search.reset ? (
          <Alert tone="success" title="Password reset complete">
            Sign in with your new password.
          </Alert>
        ) : null}
        <AuthFormAlert message={formError} />

        <form ref={formElement} className="space-y-4 text-left" noValidate onSubmit={submit}>
          <form.Field
            name="email"
            validators={{
              onBlur: ({ value }) =>
                emailSchema.safeParse(value).success ? undefined : 'Enter a valid email address.',
              onSubmit: ({ value }) =>
                emailSchema.safeParse(value).success ? undefined : 'Enter a valid email address.',
            }}
          >
            {(field) => {
              const error = field.state.meta.errors[0]
              return (
                <FormControl
                  id="login-email"
                  label="Email"
                  required
                  error={typeof error === 'string' ? error : undefined}
                >
                  <AuthTextInput
                    icon="email"
                    type="email"
                    autoComplete="username"
                    inputMode="email"
                    value={field.state.value}
                    onBlur={field.handleBlur}
                    onChange={(event) => {
                      if (formError) setFormError(null)
                      field.handleChange(event.target.value)
                    }}
                    placeholder="Enter your email"
                  />
                </FormControl>
              )
            }}
          </form.Field>

          <form.Field
            name="password"
            validators={{
              onBlur: ({ value }) =>
                passwordSchema.safeParse(value).success ? undefined : 'Enter your password.',
              onSubmit: ({ value }) =>
                passwordSchema.safeParse(value).success ? undefined : 'Enter your password.',
            }}
          >
            {(field) => {
              const error = field.state.meta.errors[0]
              return (
                <FormControl
                  id="login-password"
                  label="Password"
                  required
                  error={typeof error === 'string' ? error : undefined}
                >
                  <AuthTextInput
                    icon="lock"
                    type={passwordVisible ? 'text' : 'password'}
                    autoComplete="current-password"
                    value={field.state.value}
                    onBlur={field.handleBlur}
                    onChange={(event) => {
                      if (formError) setFormError(null)
                      field.handleChange(event.target.value)
                    }}
                    placeholder="Enter your password"
                    trailing={
                      <button
                        type="button"
                        className="text-text-muted focus-visible:shadow-focus-ring rounded-control absolute inset-y-0 right-2 flex size-10 items-center justify-center focus-visible:outline-none"
                        aria-label={passwordVisible ? 'Hide password' : 'Show password'}
                        aria-pressed={passwordVisible}
                        onClick={() => setPasswordVisible((visible) => !visible)}
                      >
                        {passwordVisible ? (
                          <svg
                            viewBox="0 0 24 24"
                            className="size-[18px]"
                            fill="none"
                            stroke="currentColor"
                            strokeWidth="1.7"
                            aria-hidden="true"
                          >
                            <path d="M3 3l18 18M10.6 10.6a2 2 0 0 0 2.8 2.8" />
                            <path d="M9.9 5.2A10.8 10.8 0 0 1 12 5c5.2 0 8.8 4.4 10 7-.4.8-1.2 2-2.4 3.2M6.2 6.2C3.9 7.7 2.5 10 2 12c1.2 2.6 4.8 7 10 7 1.5 0 2.8-.4 4-.9" />
                          </svg>
                        ) : (
                          <svg
                            viewBox="0 0 24 24"
                            className="size-[18px]"
                            fill="none"
                            stroke="currentColor"
                            strokeWidth="1.7"
                            aria-hidden="true"
                          >
                            <path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12Z" />
                            <circle cx="12" cy="12" r="2.5" />
                          </svg>
                        )}
                      </button>
                    }
                  />
                </FormControl>
              )
            }}
          </form.Field>

          <div className="flex justify-end pt-0.5">
            <Link
              className="text-label text-primary focus-visible:shadow-focus-ring rounded-control px-1 py-1 font-medium hover:underline focus-visible:outline-none"
              to="/forgot-password"
              search={{ returnTo: search.returnTo }}
            >
              Forgot password?
            </Link>
          </div>

          <Button
            className="w-full"
            type="submit"
            isLoading={form.state.isSubmitting || loginMutation.isPending}
          >
            Sign in
          </Button>

          <div className="flex items-center gap-3 py-1" aria-hidden="true">
            <span className="bg-border-subtle h-px flex-1" />
            <span className="text-caption text-text-muted">or</span>
            <span className="bg-border-subtle h-px flex-1" />
          </div>

          <Button
            variant="outline"
            size="lg"
            className="w-full"
            disabled
            aria-describedby="biometric-sign-in-unavailable"
            leadingIcon={
              <svg
                viewBox="0 0 24 24"
                className="size-[18px]"
                fill="none"
                stroke="currentColor"
                strokeWidth="1.7"
                aria-hidden="true"
              >
                <path d="M12 3.5a8.5 8.5 0 0 0-8.5 8.5M12 7a5 5 0 0 0-5 5c0 3-.5 5.7-1.6 7.8M12 3.5a8.5 8.5 0 0 1 8.5 8.5c0 3-.4 5.5-1.4 7.6M12 10a2 2 0 0 0-2 2c0 3.3-.3 5.7-1.1 7.5M12 10a2 2 0 0 1 2 2c0 2.6.2 4.8.8 6.7M3.8 15.2c-.1 1.8-.4 3.3-1 4.8M20.2 15.2c-.1 1.8-.4 3.3-1 4.8" />
              </svg>
            }
          >
            Use biometric
          </Button>
          <span id="biometric-sign-in-unavailable" className="sr-only">
            Biometric sign-in is currently unavailable.
          </span>
        </form>
      </div>
    </AuthPageFrame>
  )
}
