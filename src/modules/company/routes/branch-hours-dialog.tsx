import { useEffect, useState, type FormEvent } from 'react'
import { useForm } from '@tanstack/react-form'
import { Clock3 } from 'lucide-react'

import type { BranchBusinessHoursDto, BranchBusinessHoursInput, BranchDto } from '../branches.api'
import { draftHours, toHours, validateHoursDraft } from '../branch-hours'
import { presentError } from '@/shared/errors'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Dialog } from '@/shared/ui/dialog'
import { FormSection } from '@/shared/ui/form-section'
import { BranchHoursEditor } from './branch-hours-editor'

export function BranchHoursDialog({
  open,
  branch,
  hours,
  onOpenChange,
  onSave,
}: {
  open: boolean
  branch: BranchDto
  hours: BranchBusinessHoursDto[]
  onOpenChange: (open: boolean) => void
  onSave: (hours: BranchBusinessHoursInput[]) => Promise<void>
}) {
  const [formError, setFormError] = useState<string | null>(null)
  const [hoursError, setHoursError] = useState<string | null>(null)
  function handleOpenChange(nextOpen: boolean) {
    if (!nextOpen) {
      setFormError(null)
      setHoursError(null)
    }
    onOpenChange(nextOpen)
  }
  const form = useForm({
    defaultValues: { days: draftHours(hours) },
    onSubmit: async ({ value }) => {
      setFormError(null)
      const validationError = validateHoursDraft(value.days)
      setHoursError(validationError)
      if (validationError) return
      try {
        await onSave(toHours(value.days))
        handleOpenChange(false)
      } catch (error) {
        setFormError(presentError(error, 'form-submit').message)
      }
    },
  })

  useEffect(() => {
    if (!open) return
    form.reset({ days: draftHours(hours) })
  }, [form, hours, open])

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    void form.handleSubmit()
  }

  return (
    <Dialog
      open={open}
      onOpenChange={handleOpenChange}
      title={`Business hours · ${branch.branch_name}`}
      description="Set the local weekly schedule. Unset days stay distinct from closed days."
      size="lg"
      bodyClassName="space-y-4"
      footer={
        <>
          <Button variant="outline" onClick={() => handleOpenChange(false)}>
            Cancel
          </Button>
          <Button type="submit" form="branch-hours-form" isLoading={form.state.isSubmitting}>
            Save business hours
          </Button>
        </>
      }
    >
      <form id="branch-hours-form" noValidate onSubmit={submit} className="space-y-4">
        {formError ? (
          <Alert tone="danger" title="Business hours not saved" role="alert">
            {formError}
          </Alert>
        ) : null}
        <div className="bg-info-subtle/50 border-info/20 text-info-foreground rounded-control flex items-start gap-3 border p-3">
          <Clock3 className="mt-0.5 size-4 shrink-0" aria-hidden="true" />
          <p className="text-caption">
            Open days need both times, and closing time must be later than opening time. Times use
            this branch’s local clock.
          </p>
        </div>
        <FormSection className="space-y-4">
          <div>
            <h3 className="text-label font-semibold">Weekly schedule</h3>
            <p className="text-caption text-text-secondary mt-1">
              Set each day to open, closed, or not set.
            </p>
          </div>
          <form.Field name="days">
            {(field) => (
              <div className="space-y-2">
                {hoursError ? (
                  <Alert tone="danger" role="status">
                    {hoursError}
                  </Alert>
                ) : null}
                <BranchHoursEditor
                  days={field.state.value}
                  onChange={(days) => {
                    field.handleChange(days)
                    setHoursError((currentError) =>
                      currentError ? validateHoursDraft(days) : currentError,
                    )
                  }}
                  idPrefix="hours"
                />
              </div>
            )}
          </form.Field>
        </FormSection>
      </form>
    </Dialog>
  )
}
