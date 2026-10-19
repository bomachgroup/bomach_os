import { useRef, useState, type FormEvent } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { useForm } from '@tanstack/react-form'
import { Link, useNavigate } from '@tanstack/react-router'
import { z } from 'zod'

import { authApi } from '@/shared/auth/auth.api'
import { SESSION_ESTABLISHED_KEY } from '@/shared/api/api-client'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { FormControl, TextInput } from '@/shared/ui/form-control'
import { AuthFormAlert, AuthPageFrame } from '../components/auth-page-frame'
import { focusFirstInvalidField } from '../components/focus-first-invalid-field'

const codeSchema = z.string().regex(/^\d{6}$/, 'Enter the 6-digit code from your email.')
const passwordSchema = z.string().min(8, 'Use at least 8 characters.')

export function ResetPasswordPage() {
  const [email] = useState(() => window.sessionStorage.getItem('bomach:reset-email') ?? '')
  const [formError, setFormError] = useState<string | null>(null)
  const formElement = useRef<HTMLFormElement>(null)
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const resetMutation = useMutation({ mutationFn: authApi.resetPassword })
  const form = useForm({
    defaultValues: { code: '', newPassword: '', confirmPassword: '' },
    onSubmit: async ({ value }) => {
      setFormError(null)
      if (value.newPassword !== value.confirmPassword) {
        setFormError('The passwords do not match.')
        return
      }
      try {
        await resetMutation.mutateAsync({
          email,
          code: value.code,
          new_password: value.newPassword,
        })
        window.sessionStorage.removeItem('bomach:reset-email')
        window.sessionStorage.removeItem(SESSION_ESTABLISHED_KEY)
        queryClient.clear()
        await navigate({ to: '/login', search: { reset: true } })
      } catch (error) {
        setFormError(
          error instanceof Error
            ? error.message
            : 'The password could not be reset. Check the code and try again.',
        )
      }
    },
  })

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    void form.handleSubmit().then(() => focusFirstInvalidField(formElement.current))
  }

  if (!email) {
    return (
      <AuthPageFrame>
        <div className="space-y-5 text-center">
          <h1 className="text-h2 font-semibold">Set New Password</h1>
          <Alert tone="info" title="Start with a reset request">
            Enter your email address first so we can send a reset code.
          </Alert>
          <Button className="w-full" onClick={() => void navigate({ to: '/forgot-password' })}>
            Request a reset code
          </Button>
          <Link className="text-body-sm text-text-secondary hover:text-primary" to="/login">
            Back to Login
          </Link>
        </div>
      </AuthPageFrame>
    )
  }

  return (
    <AuthPageFrame>
      <div className="space-y-6">
        <div className="text-center">
          <h1 className="text-h2 font-bold">Set New Password</h1>
          <p className="text-body-sm text-text-secondary mt-2">
            Enter the code sent to your email and choose a new password.
          </p>
        </div>
        <AuthFormAlert message={formError} />
        <form ref={formElement} className="space-y-4" noValidate onSubmit={submit}>
          <form.Field
            name="code"
            validators={{
              onBlur: ({ value }) =>
                codeSchema.safeParse(value).success
                  ? undefined
                  : 'Enter the 6-digit code from your email.',
              onSubmit: ({ value }) =>
                codeSchema.safeParse(value).success
                  ? undefined
                  : 'Enter the 6-digit code from your email.',
            }}
          >
            {(field) => {
              const error = field.state.meta.errors[0]
              return (
                <FormControl
                  id="reset-code"
                  label="Reset Code"
                  required
                  error={typeof error === 'string' ? error : undefined}
                >
                  <TextInput
                    autoComplete="one-time-code"
                    inputMode="numeric"
                    maxLength={6}
                    placeholder="Enter 6-digit code"
                    value={field.state.value}
                    onBlur={field.handleBlur}
                    onChange={(event) => field.handleChange(event.target.value.replace(/\D/g, ''))}
                  />
                </FormControl>
              )
            }}
          </form.Field>
          <form.Field
            name="newPassword"
            validators={{
              onBlur: ({ value }) =>
                passwordSchema.safeParse(value).success ? undefined : 'Use at least 8 characters.',
              onSubmit: ({ value }) =>
                passwordSchema.safeParse(value).success ? undefined : 'Use at least 8 characters.',
            }}
          >
            {(field) => {
              const error = field.state.meta.errors[0]
              return (
                <FormControl
                  id="reset-new-password"
                  label="New Password"
                  required
                  error={typeof error === 'string' ? error : undefined}
                >
                  <TextInput
                    type="password"
                    autoComplete="new-password"
                    placeholder="Enter new password"
                    value={field.state.value}
                    onBlur={field.handleBlur}
                    onChange={(event) => field.handleChange(event.target.value)}
                  />
                </FormControl>
              )
            }}
          </form.Field>
          <form.Field
            name="confirmPassword"
            validators={{
              onBlur: ({ value }) =>
                value === form.getFieldValue('newPassword') ? undefined : 'Passwords do not match.',
              onSubmit: ({ value }) =>
                value === form.getFieldValue('newPassword') ? undefined : 'Passwords do not match.',
            }}
          >
            {(field) => {
              const error = field.state.meta.errors[0]
              return (
                <FormControl
                  id="reset-confirm-password"
                  label="Confirm Password"
                  required
                  error={typeof error === 'string' ? error : undefined}
                >
                  <TextInput
                    type="password"
                    autoComplete="new-password"
                    placeholder="Re-enter password"
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
            isLoading={form.state.isSubmitting || resetMutation.isPending}
          >
            Reset Password
          </Button>
        </form>
        <div className="text-center">
          <Link
            className="text-body-sm text-text-secondary hover:text-primary"
            to="/forgot-password"
          >
            Back
          </Link>
        </div>
      </div>
    </AuthPageFrame>
  )
}
