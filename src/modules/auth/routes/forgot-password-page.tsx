import { useEffect, useRef, useState, type FormEvent } from 'react'
import { useMutation } from '@tanstack/react-query'
import { useForm } from '@tanstack/react-form'
import { Link, useNavigate, useSearch } from '@tanstack/react-router'
import { z } from 'zod'

import { authApi } from '@/shared/auth/auth.api'
import { ApiError } from '@/shared/api/api-error'
import { presentError } from '@/shared/errors'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { FormControl, TextInput } from '@/shared/ui/form-control'
import { AuthFormAlert, AuthPageFrame } from '../components/auth-page-frame'
import { focusFirstInvalidField } from '../components/focus-first-invalid-field'

const emailSchema = z.string().trim().email('Enter a valid email address.')

export function ForgotPasswordPage() {
  const [formError, setFormError] = useState<string | null>(null)
  const [requestAccepted, setRequestAccepted] = useState(false)
  const [prefillEmail] = useState(() => {
    return window.sessionStorage.getItem('bomach:reset-prefill-email') ?? ''
  })
  const formElement = useRef<HTMLFormElement>(null)
  const navigate = useNavigate()
  const search = useSearch({ from: '/forgot-password' })
  const requestMutation = useMutation({ mutationFn: authApi.forgotPassword })
  useEffect(() => {
    window.sessionStorage.removeItem('bomach:reset-prefill-email')
  }, [])
  const form = useForm({
    defaultValues: { email: prefillEmail },
    onSubmit: async ({ value }) => {
      setFormError(null)
      try {
        await requestMutation.mutateAsync(value.email.trim())
        window.sessionStorage.setItem('bomach:reset-email', value.email.trim())
        setRequestAccepted(true)
      } catch (error) {
        if (
          error instanceof ApiError &&
          error.status !== 0 &&
          error.status < 500 &&
          error.status !== 429
        ) {
          setFormError('If an account exists for this email address, a reset code will be sent.')
        } else {
          setFormError(presentError(error, 'form-submit').message)
        }
      }
    },
  })

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    void form.handleSubmit().then(() => focusFirstInvalidField(formElement.current))
  }

  return (
    <AuthPageFrame>
      <div className="space-y-6">
        <div
          className="bg-primary/10 text-primary mx-auto flex size-[70px] items-center justify-center rounded-full"
          aria-hidden="true"
        >
          <svg
            viewBox="0 0 40 40"
            className="size-10"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
          >
            <rect x="8" y="18" width="24" height="17" rx="3" />
            <path d="M13 18v-5a7 7 0 0 1 14 0v5" />
            <circle cx="20" cy="26" r="1.5" fill="currentColor" />
            <path d="M20 27.5V30" />
          </svg>
        </div>
        <div className="text-center">
          <h1 className="text-h2 font-bold">Forgot Password?</h1>
          <p className="text-body-sm text-text-secondary mt-2">
            Enter your email address to receive a password reset code.
          </p>
        </div>

        {requestAccepted ? (
          <div className="space-y-4">
            <Alert tone="info" title="Check your email">
              If an account exists for this email address, a password reset code will be sent.
            </Alert>
            <Button
              className="w-full"
              onClick={() =>
                void navigate({ to: '/reset-password', search: { returnTo: search.returnTo } })
              }
            >
              Continue to enter reset code
            </Button>
          </div>
        ) : (
          <>
            <AuthFormAlert message={formError} />
            <form ref={formElement} className="space-y-5" noValidate onSubmit={submit}>
              <form.Field
                name="email"
                validators={{
                  onBlur: ({ value }) =>
                    emailSchema.safeParse(value).success
                      ? undefined
                      : 'Enter a valid email address.',
                  onSubmit: ({ value }) =>
                    emailSchema.safeParse(value).success
                      ? undefined
                      : 'Enter a valid email address.',
                }}
              >
                {(field) => {
                  const error = field.state.meta.errors[0]
                  return (
                    <FormControl
                      id="forgot-email"
                      label="Email Address"
                      required
                      error={typeof error === 'string' ? error : undefined}
                    >
                      <TextInput
                        type="email"
                        autoComplete="email"
                        inputMode="email"
                        placeholder="Enter your email"
                        value={field.state.value}
                        onBlur={field.handleBlur}
                        onChange={(event) => field.handleChange(event.target.value)}
                      />
                    </FormControl>
                  )
                }}
              </form.Field>
              <Button
                className="w-full"
                type="submit"
                isLoading={form.state.isSubmitting || requestMutation.isPending}
              >
                Send Reset Code
              </Button>
            </form>
          </>
        )}

        <div className="text-center">
          <Link
            className="text-body-sm text-text-secondary hover:text-primary"
            to="/login"
            search={{ returnTo: search.returnTo }}
          >
            Back to Login
          </Link>
        </div>
      </div>
    </AuthPageFrame>
  )
}
