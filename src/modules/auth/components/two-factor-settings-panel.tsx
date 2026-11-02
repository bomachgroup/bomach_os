import { useRef, useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useForm } from '@tanstack/react-form'
import { ShieldCheck } from 'lucide-react'

import { authApi } from '@/shared/auth/auth.api'
import { presentError } from '@/shared/errors'
import { Button } from '@/shared/ui/button'
import { Dialog } from '@/shared/ui/dialog'
import { SectionErrorState } from '@/shared/ui/feedback-states'
import { FormControl, TextInput } from '@/shared/ui/form-control'
import { StatusChip } from '@/shared/ui/status-chip'
import { useToast } from '@/shared/feedback/use-toast'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { AuthFormAlert } from './auth-page-frame'

const STATUS_QUERY_KEY = ['auth', 'two-factor-status'] as const

/** Password-confirmed two-factor controls for account and profile surfaces. */
export function TwoFactorSettingsPanel() {
  const [dialogOpen, setDialogOpen] = useState(false)
  const [formError, setFormError] = useState<string | null>(null)
  const passwordRef = useRef<HTMLInputElement>(null)
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const statusQuery = useQuery({
    queryKey: STATUS_QUERY_KEY,
    queryFn: ({ signal }) => authApi.twoFactorStatus(signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    retry: false,
  })
  const updateMutation = useMutation({
    mutationFn: ({ enabled, password }: { enabled: boolean; password: string }) =>
      authApi.setTwoFactor(enabled, password),
    onSuccess: async (result) => {
      await queryClient.setQueryData(STATUS_QUERY_KEY, result)
      await queryClient.invalidateQueries({ queryKey: STATUS_QUERY_KEY })
      form.reset()
      setFormError(null)
      setDialogOpen(false)
      showToast({
        title: result.two_factor_enabled
          ? 'Two-factor authentication enabled'
          : 'Two-factor authentication disabled',
        tone: 'success',
      })
    },
    onError: (error) => {
      setFormError(presentError(error, 'form-submit').message)
    },
  })
  const form = useForm({
    defaultValues: { password: '' },
    onSubmit: async ({ value }) => {
      if (!statusQuery.data) return
      setFormError(null)
      try {
        await updateMutation.mutateAsync({
          enabled: !statusQuery.data.two_factor_enabled,
          password: value.password,
        })
      } catch {
        // The mutation handler keeps one persistent form-level error visible.
      }
    },
  })

  function closeDialog(nextOpen: boolean) {
    if (updateMutation.isPending) return
    setDialogOpen(nextOpen)
    if (!nextOpen) {
      form.reset()
      setFormError(null)
    }
  }

  if (statusQuery.isLoading) {
    return (
      <div
        aria-label="Loading two-factor setting"
        className="bg-surface-muted rounded-control h-24 animate-pulse"
      />
    )
  }
  if (statusQuery.isError || !statusQuery.data) {
    return (
      <SectionErrorState
        title="Could not load two-factor status"
        description="Retry to check the current setting."
        error={statusQuery.error}
        onRetry={() => void statusQuery.refetch()}
      />
    )
  }

  const isEnabled = statusQuery.data.two_factor_enabled
  const actionLabel = isEnabled
    ? 'Disable two-factor authentication'
    : 'Enable two-factor authentication'
  return (
    <>
      <section
        className="border-border-strong bg-surface rounded-surface phone:flex-row phone:items-center phone:justify-between flex flex-col gap-4 border p-4"
        aria-labelledby="two-factor-settings-title"
      >
        <div className="flex min-w-0 items-start gap-3">
          <span className="bg-primary-subtle text-primary rounded-control mt-0.5 flex size-10 shrink-0 items-center justify-center">
            <ShieldCheck aria-hidden="true" className="size-5" strokeWidth={1.8} />
          </span>
          <div className="min-w-0">
            <div className="flex flex-wrap items-center gap-2">
              <h2 id="two-factor-settings-title" className="text-label font-semibold">
                Two-factor authentication
              </h2>
              <StatusChip
                dense
                label={isEnabled ? 'On' : 'Off'}
                tone={isEnabled ? 'success' : 'neutral'}
              />
            </div>
            <p className="text-body-sm text-text-secondary mt-1 max-w-xl">
              {isEnabled
                ? 'A verification code is required when you sign in.'
                : 'Add an email verification step when you sign in.'}
            </p>
          </div>
        </div>
        <Button
          type="button"
          variant={isEnabled ? 'outline' : 'primary'}
          className="phone:w-auto w-full shrink-0"
          onClick={() => setDialogOpen(true)}
        >
          {isEnabled ? 'Disable' : 'Enable'}
        </Button>
      </section>

      <Dialog
        open={dialogOpen}
        onOpenChange={closeDialog}
        title={actionLabel}
        description={`Confirm your password to ${isEnabled ? 'turn off' : 'turn on'} two-factor authentication.`}
        size="sm"
        fitContent
        compactOnMobile
        bodyClassName="flex-none overflow-y-auto py-4"
        closeOnBackdrop={!updateMutation.isPending}
        initialFocusRef={passwordRef}
        footer={
          <div className="phone:flex-row flex w-full flex-col-reverse justify-end gap-2">
            <Button
              type="button"
              variant="outline"
              className="phone:w-auto w-full"
              disabled={updateMutation.isPending}
              onClick={() => closeDialog(false)}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              form="two-factor-confirm-form"
              variant={isEnabled ? 'danger' : 'primary'}
              className="phone:w-auto w-full"
              isLoading={form.state.isSubmitting || updateMutation.isPending}
            >
              {isEnabled ? 'Disable two-factor' : 'Enable two-factor'}
            </Button>
          </div>
        }
      >
        <form
          id="two-factor-confirm-form"
          className="space-y-4"
          noValidate
          onSubmit={(event) => {
            event.preventDefault()
            void form.handleSubmit()
          }}
        >
          <AuthFormAlert message={formError} />
          <form.Field
            name="password"
            validators={{
              onBlur: ({ value }) => (value.length ? undefined : 'Enter your password.'),
              onSubmit: ({ value }) => (value.length ? undefined : 'Enter your password.'),
            }}
          >
            {(field) => {
              const error = field.state.meta.errors[0]
              return (
                <FormControl
                  id="two-factor-password"
                  label="Password"
                  description="Your password is used to confirm this security change."
                  required
                  error={typeof error === 'string' ? error : undefined}
                >
                  <TextInput
                    ref={passwordRef}
                    type="password"
                    autoComplete="current-password"
                    value={field.state.value}
                    onBlur={field.handleBlur}
                    onChange={(event) => field.handleChange(event.target.value)}
                  />
                </FormControl>
              )
            }}
          </form.Field>
        </form>
      </Dialog>
    </>
  )
}
