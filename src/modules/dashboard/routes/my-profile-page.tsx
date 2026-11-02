import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useForm } from '@tanstack/react-form'
import { Link } from '@tanstack/react-router'
import { useEffect, useRef, useState, type FormEvent, type ReactNode } from 'react'
import {
  ArrowRight,
  BriefcaseBusiness,
  CalendarDays,
  KeyRound,
  MapPin,
  ShieldCheck,
  UserRound,
} from 'lucide-react'

import { TwoFactorSettingsPanel } from '@/modules/auth/components/two-factor-settings-panel'
import { focusFirstInvalidField } from '@/modules/auth/components/focus-first-invalid-field'
import { ApiError } from '@/shared/api/api-error'
import { SESSION_ESTABLISHED_KEY } from '@/shared/api/api-client'
import { authApi } from '@/shared/auth/auth.api'
import { authSessionQueryOptions, type AuthenticatedSession } from '@/shared/auth/session'
import { SessionBootstrapError } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { ErrorState, PageSkeleton, Skeleton } from '@/shared/ui/feedback-states'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip } from '@/shared/ui/status-chip'
import { Dialog } from '@/shared/ui/dialog'
import { FormControl, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'
import { z } from 'zod'

const resetCodeSchema = z.string().regex(/^\d{6}$/, 'Enter the 6-digit code from your email.')
const newPasswordSchema = z.string().min(8, 'Use at least 8 characters.')

function ChangePasswordDialog({ email }: { email: string }) {
  const [open, setOpen] = useState(false)
  const [step, setStep] = useState<'request' | 'reset' | 'success'>('request')
  const [formError, setFormError] = useState<string | null>(null)
  const queryClient = useQueryClient()
  const resetCodeRef = useRef<HTMLInputElement>(null)
  const formElement = useRef<HTMLFormElement>(null)
  const requestMutation = useMutation({ mutationFn: authApi.forgotPassword })
  const resetMutation = useMutation({ mutationFn: authApi.resetPassword })
  const form = useForm({
    defaultValues: { code: '', newPassword: '', confirmPassword: '' },
    onSubmit: async ({ value }) => {
      setFormError(null)
      try {
        await resetMutation.mutateAsync({
          email,
          code: value.code,
          new_password: value.newPassword,
        })
        setStep('success')
        form.reset()
      } catch (error) {
        setFormError(presentError(error, 'form-submit').message)
      }
    },
  })

  useEffect(() => {
    if (open && step === 'reset') resetCodeRef.current?.focus()
  }, [open, step])

  async function requestCode() {
    setFormError(null)
    try {
      await requestMutation.mutateAsync(email)
      form.reset()
      setStep('reset')
    } catch (error) {
      if (
        error instanceof ApiError &&
        error.status !== 0 &&
        error.status < 500 &&
        error.status !== 429
      ) {
        setFormError(
          'If this account can be verified, a reset code will be sent to the email shown.',
        )
      } else {
        setFormError(presentError(error, 'form-submit').message)
      }
    }
  }

  function closeDialog(nextOpen: boolean) {
    if (requestMutation.isPending || resetMutation.isPending || step === 'success') return
    setOpen(nextOpen)
    if (!nextOpen) {
      setStep('request')
      setFormError(null)
      form.reset()
    }
  }

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    void form.handleSubmit().then(() => focusFirstInvalidField(formElement.current))
  }

  return (
    <>
      <Button
        type="button"
        variant="outline"
        size="sm"
        className="phone:w-auto w-full shrink-0"
        leadingIcon={<KeyRound className="size-4" aria-hidden="true" />}
        onClick={() => setOpen(true)}
      >
        Change password
      </Button>
      <Dialog
        open={open}
        onOpenChange={closeDialog}
        title={step === 'success' ? 'Password updated' : 'Change your password'}
        description={
          step === 'request'
            ? 'We’ll send a verification code to your account email.'
            : step === 'reset'
              ? 'Enter the email code and choose a new password.'
              : 'Your password has been changed successfully.'
        }
        size="sm"
        fitContent
        closeOnBackdrop={
          step !== 'success' && !requestMutation.isPending && !resetMutation.isPending
        }
        initialFocusRef={resetCodeRef}
        footer={
          step === 'success' ? (
            <Link
              to="/login"
              search={{ reset: true }}
              onClick={() => {
                window.sessionStorage.removeItem(SESSION_ESTABLISHED_KEY)
                queryClient.clear()
              }}
              className="bg-primary text-text-on-primary hover:bg-primary-hover focus-visible:shadow-focus-ring rounded-control text-label inline-flex min-h-11 w-full items-center justify-center px-4 font-semibold whitespace-nowrap focus-visible:outline-none"
            >
              Continue to sign in
            </Link>
          ) : (
            <div className="phone:flex-row flex w-full flex-col-reverse justify-end gap-2">
              <Button
                type="button"
                variant="outline"
                className="phone:w-auto w-full"
                disabled={requestMutation.isPending || resetMutation.isPending}
                onClick={() => closeDialog(false)}
              >
                Cancel
              </Button>
              {step === 'request' ? (
                <Button
                  type="button"
                  className="phone:w-auto w-full"
                  isLoading={requestMutation.isPending}
                  onClick={() => void requestCode()}
                >
                  Send verification code
                </Button>
              ) : (
                <Button
                  type="submit"
                  form="profile-reset-password-form"
                  className="phone:w-auto w-full"
                  isLoading={form.state.isSubmitting || resetMutation.isPending}
                >
                  Update password
                </Button>
              )}
            </div>
          )
        }
      >
        {step === 'success' ? (
          <Alert tone="success" title="Sign in again to continue" role="status">
            For your security, this password reset ended your current session. Use your new password
            the next time you sign in.
          </Alert>
        ) : step === 'request' ? (
          <div className="space-y-4">
            {formError ? (
              <Alert tone="danger" role="alert">
                {formError}
              </Alert>
            ) : null}
            <FormSection className="space-y-3">
              <div>
                <h3 className="text-label font-semibold">Verification email</h3>
                <p className="text-caption text-text-secondary mt-1">
                  We’ll send a one-time code to this address. It expires after a short time.
                </p>
              </div>
              <p className="text-body-sm text-text-primary rounded-control border-border-subtle bg-surface border px-3.5 py-3 font-medium break-all">
                {email}
              </p>
            </FormSection>
          </div>
        ) : (
          <form
            ref={formElement}
            id="profile-reset-password-form"
            className="space-y-4"
            noValidate
            onSubmit={submit}
          >
            {formError ? (
              <Alert tone="danger" role="alert">
                {formError}
              </Alert>
            ) : null}
            <Alert tone="info" title="Check your email">
              If this account can be verified, a 6-digit code will be sent to {email}.
            </Alert>
            <FormSection className="space-y-4">
              <div>
                <h3 className="text-label font-semibold">Reset credentials</h3>
                <p className="text-caption text-text-secondary mt-1">
                  Confirm the code and choose a new password.
                </p>
              </div>
              <form.Field
                name="code"
                validators={{
                  onBlur: ({ value }) =>
                    resetCodeSchema.safeParse(value).success
                      ? undefined
                      : 'Enter the 6-digit code from your email.',
                  onSubmit: ({ value }) =>
                    resetCodeSchema.safeParse(value).success
                      ? undefined
                      : 'Enter the 6-digit code from your email.',
                }}
              >
                {(field) => {
                  const error = field.state.meta.errors[0]
                  return (
                    <FormControl
                      id="profile-reset-code"
                      label="Verification code"
                      required
                      error={typeof error === 'string' ? error : undefined}
                    >
                      <TextInput
                        ref={resetCodeRef}
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
              <form.Field
                name="newPassword"
                validators={{
                  onBlur: ({ value }) =>
                    newPasswordSchema.safeParse(value).success
                      ? undefined
                      : 'Use at least 8 characters.',
                  onSubmit: ({ value }) =>
                    newPasswordSchema.safeParse(value).success
                      ? undefined
                      : 'Use at least 8 characters.',
                }}
              >
                {(field) => {
                  const error = field.state.meta.errors[0]
                  return (
                    <FormControl
                      id="profile-new-password"
                      label="New password"
                      required
                      error={typeof error === 'string' ? error : undefined}
                    >
                      <TextInput
                        type="password"
                        autoComplete="new-password"
                        placeholder="At least 8 characters"
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
                    value === form.getFieldValue('newPassword')
                      ? undefined
                      : 'Passwords do not match.',
                  onSubmit: ({ value }) =>
                    value === form.getFieldValue('newPassword')
                      ? undefined
                      : 'Passwords do not match.',
                }}
              >
                {(field) => {
                  const error = field.state.meta.errors[0]
                  return (
                    <FormControl
                      id="profile-confirm-password"
                      label="Confirm new password"
                      required
                      error={typeof error === 'string' ? error : undefined}
                    >
                      <TextInput
                        type="password"
                        autoComplete="new-password"
                        placeholder="Re-enter new password"
                        value={field.state.value}
                        onBlur={field.handleBlur}
                        onChange={(event) => field.handleChange(event.target.value)}
                      />
                    </FormControl>
                  )
                }}
              </form.Field>
              <Button
                type="button"
                variant="ghost"
                size="sm"
                disabled={requestMutation.isPending || resetMutation.isPending}
                isLoading={requestMutation.isPending}
                onClick={() => void requestCode()}
              >
                Send a new code
              </Button>
            </FormSection>
          </form>
        )}
      </Dialog>
    </>
  )
}

function formattedDate(value?: string | null) {
  if (!value) return null
  const parsed = new Date(`${value.slice(0, 10)}T00:00:00`)
  if (Number.isNaN(parsed.getTime())) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  }).format(parsed)
}

function displayName(session: AuthenticatedSession) {
  const name = [
    session.employee.first_name || session.user.first_name,
    session.employee.middle_name,
    session.employee.last_name || session.user.last_name,
  ]
    .filter(Boolean)
    .join(' ')
  return name || session.employee.username || session.user.username || session.user.email
}

function initials(session: AuthenticatedSession) {
  const name = displayName(session)
  return name
    .split(/[\s@._-]+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase())
    .join('')
}

function addressLine(session: AuthenticatedSession) {
  const employee = session.employee
  return [employee.address, employee.city, employee.state, employee.zip_code, employee.country]
    .filter(Boolean)
    .join(', ')
}

function ProfileSection({
  icon,
  title,
  description,
  fields,
}: {
  icon: ReactNode
  title: string
  description?: string
  fields: Array<[string, string | null | undefined]>
}) {
  const visibleFields = fields.filter((field): field is [string, string] => Boolean(field[1]))
  return (
    <Card className="min-w-0 p-0">
      <div className="border-border-subtle phone:px-5 flex items-start gap-3 border-b px-4 py-4">
        <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
          {icon}
        </span>
        <div className="min-w-0">
          <h2 className="text-label font-semibold">{title}</h2>
          {description ? (
            <p className="text-caption text-text-secondary mt-0.5">{description}</p>
          ) : null}
        </div>
      </div>
      {visibleFields.length ? (
        <dl className="divide-border-subtle phone:px-5 divide-y px-4">
          {visibleFields.map(([label, value]) => (
            <div
              key={label}
              className="phone:grid-cols-[minmax(8rem,0.75fr)_minmax(0,1.25fr)] phone:items-start grid min-w-0 grid-cols-1 gap-1 py-3"
            >
              <dt className="text-caption text-text-secondary">{label}</dt>
              <dd className="text-body-sm text-text-primary phone:text-right min-w-0 font-medium break-words">
                {value}
              </dd>
            </div>
          ))}
        </dl>
      ) : (
        <p className="text-body-sm text-text-secondary phone:px-5 px-4 py-5">
          No {title.toLowerCase()} details have been provided.
        </p>
      )}
    </Card>
  )
}

function ProfileContent({ session }: { session: AuthenticatedSession }) {
  const employee = session.employee
  const fullName = displayName(session)
  const role = employee.role_name || session.user.role?.name || session.roles[0]?.name
  const branch = employee.branch_name || employee.branch?.branch_name
  const department = employee.department_name || employee.department?.name
  const address = addressLine(session)
  return (
    <div className="space-y-6">
      <Card className="overflow-hidden p-0">
        <div className="from-primary/10 via-surface to-surface tablet:flex-row tablet:items-center phone:px-7 phone:py-7 flex flex-col gap-5 bg-gradient-to-br px-5 py-6">
          <div className="relative flex size-[4.5rem] shrink-0 items-center justify-center overflow-hidden rounded-full shadow-sm ring-4 ring-white">
            {employee.profile_picture ? (
              <img src={employee.profile_picture} alt="" className="size-full object-cover" />
            ) : (
              <span className="bg-primary-subtle text-primary text-h2 flex size-full items-center justify-center font-semibold">
                {initials(session)}
              </span>
            )}
          </div>
          <div className="min-w-0 flex-1">
            <p className="text-overline text-primary">Employee profile</p>
            <h2 className="text-h2 text-text-primary mt-1 font-semibold tracking-tight">
              {fullName}
            </h2>
            <p className="text-body-sm text-text-secondary mt-1 break-words">
              {role || employee.designation || 'BOMACH OS employee'}
              {employee.employee_id ? ` · ${employee.employee_id}` : ''}
            </p>
          </div>
          <div className="flex shrink-0 flex-wrap gap-2">
            <StatusChip
              label={session.user.is_verified ? 'Verified account' : 'Account not verified'}
              tone={session.user.is_verified ? 'success' : 'warning'}
              dense
            />
            {typeof employee.is_active === 'boolean' ? (
              <StatusChip
                label={employee.is_active ? 'Active' : 'Inactive'}
                tone={employee.is_active ? 'success' : 'neutral'}
                dense
              />
            ) : null}
          </div>
        </div>
        <div className="bg-surface-muted/45 border-border-subtle phone:grid-cols-3 grid grid-cols-1 border-t">
          <div className="border-border-subtle phone:border-r phone:border-b-0 flex min-w-0 items-center gap-3 border-b px-5 py-3">
            <UserRound className="text-primary size-4 shrink-0" aria-hidden="true" />
            <span className="text-body-sm text-text-primary min-w-0 truncate">
              {session.user.email}
            </span>
          </div>
          <div className="border-border-subtle phone:border-r phone:border-b-0 flex min-w-0 items-center gap-3 border-b px-5 py-3">
            <BriefcaseBusiness className="text-primary size-4 shrink-0" aria-hidden="true" />
            <span className="text-body-sm text-text-primary min-w-0 truncate">
              {department || 'Department not set'}
            </span>
          </div>
          <div className="flex min-w-0 items-center gap-3 px-5 py-3">
            <MapPin className="text-primary size-4 shrink-0" aria-hidden="true" />
            <span className="text-body-sm text-text-primary min-w-0 truncate">
              {branch || employee.location || 'Work location not set'}
            </span>
          </div>
        </div>
      </Card>

      <div className="tablet:grid-cols-2 phone:gap-5 grid min-w-0 grid-cols-1 gap-4">
        <ProfileSection
          icon={<UserRound className="size-5" aria-hidden="true" />}
          title="Personal information"
          description="Identity details recorded for your employee account."
          fields={[
            ['First name', employee.first_name || session.user.first_name],
            ['Middle name', employee.middle_name],
            ['Last name', employee.last_name || session.user.last_name],
            ['Date of birth', formattedDate(employee.date_of_birth)],
            ['Gender', employee.gender],
            ['Marital status', employee.marital_status],
            ['Nationality', employee.nationality],
          ]}
        />
        <ProfileSection
          icon={<MapPin className="size-5" aria-hidden="true" />}
          title="Contact information"
          description="Ways to reach you and your recorded address."
          fields={[
            ['Work email', session.user.email],
            ['Personal email', employee.personal_email],
            ['Phone number', employee.phone_number || session.user.phone_number],
            ['Address', address],
          ]}
        />
        <ProfileSection
          icon={<BriefcaseBusiness className="size-5" aria-hidden="true" />}
          title="Employment"
          description="Your current role and employment record."
          fields={[
            ['Employee ID', employee.employee_id],
            ['Role', role],
            ['Designation', employee.designation],
            ['Department', department],
            ['Branch', branch],
            ['Employment type', employee.employment_type],
            ['Employment status', employee.employment_status],
            ['Start date', formattedDate(employee.start_date)],
            ['Work location', employee.location],
          ]}
        />
        <Card className="min-w-0 p-0">
          <div className="border-border-subtle phone:px-5 flex items-start gap-3 border-b px-4 py-4">
            <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
              <ShieldCheck className="size-5" aria-hidden="true" />
            </span>
            <div className="min-w-0">
              <h2 className="text-label font-semibold">Account security</h2>
              <p className="text-caption text-text-secondary mt-0.5">
                Manage sign-in protection for your account.
              </p>
            </div>
          </div>
          <div className="phone:p-5 space-y-4 p-4">
            <div className="phone:flex-row phone:items-center phone:justify-between flex flex-col gap-3">
              <div className="flex min-w-0 items-start gap-3">
                <CalendarDays className="text-primary mt-0.5 size-4 shrink-0" aria-hidden="true" />
                <div className="min-w-0">
                  <p className="text-caption text-text-secondary">Account created</p>
                  <p className="text-body-sm text-text-primary mt-0.5 font-medium">
                    {formattedDate(session.user.created_at) || 'Not available'}
                  </p>
                  <p className="text-caption text-text-secondary mt-1">
                    Username: {employee.username || session.user.username}
                  </p>
                </div>
              </div>
              <ChangePasswordDialog email={session.user.email} />
            </div>
            <TwoFactorSettingsPanel />
          </div>
        </Card>
      </div>

      <div className="flex justify-end">
        <Link
          to="/dashboard/role"
          className="text-body-sm text-primary focus-visible:shadow-focus-ring rounded-control inline-flex min-h-10 items-center gap-2 font-semibold focus-visible:outline-none"
        >
          Review your role <ArrowRight className="size-4" aria-hidden="true" />
        </Link>
      </div>
    </div>
  )
}

export function MyProfilePage() {
  const profileQuery = useQuery({
    ...authSessionQueryOptions(),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const queryError =
    profileQuery.error instanceof SessionBootstrapError
      ? profileQuery.error.cause
      : profileQuery.error

  return (
    <PageLayout
      title="My profile"
      subtitle="Review your personal information, employment details, and account security."
      leading={<UserRound className="size-[18px]" aria-hidden="true" />}
    >
      {profileQuery.isPending ? (
        <PageSkeleton className="tablet:grid-cols-2 grid grid-cols-1 gap-4">
          <Skeleton variant="card" className="tablet:col-span-2 h-40" />
          <Skeleton variant="card" />
          <Skeleton variant="card" />
          <Skeleton variant="card" />
          <Skeleton variant="card" />
        </PageSkeleton>
      ) : profileQuery.data ? (
        <div className="space-y-5">
          {profileQuery.isError ? (
            <Alert tone="warning" title={presentError(queryError, 'background-action').title}>
              <span className="inline-flex flex-wrap items-center gap-2">
                Your saved profile remains available. Refresh to check for updates.
                <Button variant="ghost" size="sm" onClick={() => void profileQuery.refetch()}>
                  Retry
                </Button>
              </span>
            </Alert>
          ) : null}
          <ProfileContent session={profileQuery.data} />
        </div>
      ) : (
        <Card>
          <ErrorState
            title="Your profile could not be loaded"
            description="Check your connection, then retry."
            error={queryError}
            action={<Button onClick={() => void profileQuery.refetch()}>Try again</Button>}
          />
        </Card>
      )}
    </PageLayout>
  )
}
