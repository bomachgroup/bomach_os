import { useRef, useState, type FormEvent } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useForm } from '@tanstack/react-form'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { z } from 'zod'

import { authApi } from '@/shared/auth/auth.api'
import { authQueryKeys, browserTwoFactorChallengeQueryOptions } from '@/shared/auth/auth.queries'
import { AUTH_SESSION_QUERY_KEY } from '@/shared/auth/session'
import { SESSION_ESTABLISHED_KEY } from '@/shared/api/api-client'
import { ApiError } from '@/shared/api/api-error'
import { presentError } from '@/shared/errors'
import { Button } from '@/shared/ui/button'
import { FormControl, TextInput } from '@/shared/ui/form-control'
import { AuthFormAlert, AuthLogo, AuthPageFrame } from '../components/auth-page-frame'
import { focusFirstInvalidField } from '../components/focus-first-invalid-field'

const codeSchema = z.string().regex(/^\d{6}$/, 'Enter the 6-digit verification code.')

export function TwoFactorVerifyPage() {
  const [formError, setFormError] = useState<string | null>(null)
  const formElement = useRef<HTMLFormElement>(null)
  const navigate = useNavigate()
  const search = useSearch({ from: '/two-factor-verify' })
  const queryClient = useQueryClient()
  const challengeQuery = useQuery(browserTwoFactorChallengeQueryOptions())
  const challengeError = challengeQuery.isError
    ? presentError(challengeQuery.error, 'page-load')
    : null
  const verifyMutation = useMutation({ mutationFn: authApi.verifyTwoFactor })
  const cancelMutation = useMutation({ mutationFn: authApi.cancelTwoFactor })
  const form = useForm({
    defaultValues: { code: '' },
    onSubmit: async ({ value }) => {
      setFormError(null)
      try {
        await verifyMutation.mutateAsync(value.code)
        window.sessionStorage.setItem(SESSION_ESTABLISHED_KEY, '1')
        await queryClient.removeQueries({ queryKey: AUTH_SESSION_QUERY_KEY })
        await navigate({ to: '/splash', search: { returnTo: search.returnTo } })
      } catch (error) {
        if (error instanceof ApiError && error.status === 401) {
          try {
            const challenge = await authApi.browserTwoFactorChallengeStatus()
            queryClient.setQueryData(authQueryKeys.twoFactorChallengeStatus, challenge)
            if (!challenge.pending) return
          } catch {
            // Keep the verification feedback visible if status rechecking is unavailable.
          }
        }
        setFormError(presentError(error, 'two-factor').message)
      }
    },
  })

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    void form.handleSubmit().then(() => focusFirstInvalidField(formElement.current))
  }

  async function cancel() {
    setFormError(null)
    try {
      await cancelMutation.mutateAsync()
      await navigate({ to: '/login', search: { returnTo: search.returnTo } })
    } catch (error) {
      setFormError(presentError(error, 'form-submit').message)
    }
  }

  function returnToLogin() {
    void navigate({ to: '/login', search: { returnTo: search.returnTo } })
  }

  return (
    <AuthPageFrame glass cardClassName="px-7 py-8 sm:px-10 sm:py-[30px]">
      <div className="space-y-5 text-center">
        <AuthLogo variant="tile" />
        <div>
          <h1 className="text-h2 font-semibold">
            {challengeQuery.isPending
              ? 'Checking verification session'
              : challengeQuery.isError
                ? 'Could not verify sign-in'
                : challengeQuery.data?.pending
                  ? '2FA Verification'
                  : 'Verification session expired'}
          </h1>
          <p className="text-body-sm mt-2 text-white/90">
            {challengeQuery.isPending
              ? 'Please wait while we check whether a code is still active.'
              : challengeQuery.isError
                ? (challengeError?.message ??
                  'We could not confirm this verification session. Retry the check or return to sign in.')
                : challengeQuery.data?.pending
                  ? 'Enter the six-digit code from your sign-in email.'
                  : 'This sign-in verification is no longer active. Sign in again to request a new code.'}
          </p>
        </div>

        {challengeQuery.isPending ? (
          <p className="text-body-sm text-white/90" role="status">
            Checking your verification session…
          </p>
        ) : challengeQuery.isError ? (
          <div className="space-y-4" role="alert">
            <p className="text-body-sm text-white/90">
              {challengeError?.message ??
                'We could not confirm this verification session. Retry the check or return to sign in.'}
            </p>
            <Button
              variant="outline"
              className="w-full border-white/50 text-white hover:bg-white/10 hover:text-white"
              onClick={() => void challengeQuery.refetch()}
              isLoading={challengeQuery.isFetching}
            >
              Check again
            </Button>
            <Button
              variant="ghost"
              className="text-white hover:bg-white/10 hover:text-white"
              onClick={returnToLogin}
            >
              Return to Login
            </Button>
          </div>
        ) : challengeQuery.data?.pending ? (
          <>
            <AuthFormAlert
              message={formError}
              className="border-rose-200/60 bg-rose-950/35 text-rose-50"
            />
            <form ref={formElement} className="space-y-5 text-left" noValidate onSubmit={submit}>
              <form.Field
                name="code"
                validators={{
                  onBlur: ({ value }) =>
                    codeSchema.safeParse(value).success
                      ? undefined
                      : 'Enter the 6-digit verification code.',
                  onSubmit: ({ value }) =>
                    codeSchema.safeParse(value).success
                      ? undefined
                      : 'Enter the 6-digit verification code.',
                }}
              >
                {(field) => {
                  const error = field.state.meta.errors[0]
                  return (
                    <FormControl
                      id="two-factor-code"
                      label="Verification Code"
                      required
                      labelClassName="text-white/90"
                      requiredMarkClassName="text-rose-200"
                      errorClassName="text-rose-100"
                      error={typeof error === 'string' ? error : undefined}
                    >
                      <TextInput
                        className="text-center tracking-[0.35em]"
                        autoComplete="one-time-code"
                        inputMode="numeric"
                        maxLength={6}
                        placeholder="Enter 6-digit code"
                        value={field.state.value}
                        onBlur={field.handleBlur}
                        onChange={(event) =>
                          field.handleChange(event.target.value.replace(/\D/g, ''))
                        }
                      />
                    </FormControl>
                  )
                }}
              </form.Field>
              <Button
                className="text-primary w-full bg-white hover:bg-white/90"
                type="submit"
                isLoading={form.state.isSubmitting || verifyMutation.isPending}
              >
                Verify Code
              </Button>
            </form>
            <Button
              variant="ghost"
              className="text-white hover:bg-white/10 hover:text-white"
              onClick={() => void cancel()}
              isLoading={cancelMutation.isPending}
            >
              Back to Login
            </Button>
          </>
        ) : (
          <Button
            className="text-primary w-full bg-white hover:bg-white/90"
            onClick={returnToLogin}
          >
            Return to Login
          </Button>
        )}
      </div>
    </AuthPageFrame>
  )
}
