import { useState, type FormEvent } from 'react'
import { useForm } from '@tanstack/react-form'
import { Award as AwardIcon } from 'lucide-react'

import { presentError } from '@/shared/errors'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'

import type { Award, AwardInput } from '../recognition.api'

const categoryOptions: DropdownSelectOption[] = [
  { value: 'employee_of_the_month', label: 'Employee of the month' },
  { value: 'state_excellence_winner', label: 'State excellence winner' },
  { value: 'best_branch_representative', label: 'Best branch representative' },
  { value: 'regional_leader', label: 'Regional leader' },
  { value: 'dependable_team_member', label: 'Dependable team member' },
  { value: 'other', label: 'Other' },
]

const rankOptions: DropdownSelectOption[] = [
  { value: 'branch', label: 'Branch' },
  { value: 'state', label: 'State' },
  { value: 'inter-state-region', label: 'Inter-state region' },
  { value: 'national', label: 'National' },
]

type Values = {
  title: string
  category: string
  rankLevel: string
  dateAwarded: string
  description: string
}

function valuesFor(award?: Award | null): Values {
  return {
    title: award?.title ?? '',
    category: award?.category ?? '',
    rankLevel: award?.rankLevel ?? '',
    dateAwarded: award?.dateAwarded?.slice(0, 10) ?? '',
    description: award?.description ?? '',
  }
}

function validate(values: Values) {
  const errors: Partial<Record<keyof Values, string>> = {}
  if (values.title.trim().length < 2) errors.title = 'Enter an award title.'
  if (values.title.trim().length > 255) errors.title = 'Use 255 characters or fewer.'
  if (!categoryOptions.some(({ value }) => value === values.category)) {
    errors.category = 'Choose an award category.'
  }
  if (!rankOptions.some(({ value }) => value === values.rankLevel)) {
    errors.rankLevel = 'Choose an award level.'
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(values.dateAwarded)) {
    errors.dateAwarded = 'Choose the award date.'
  }
  return errors
}

function toInput(values: Values): AwardInput {
  return {
    title: values.title.trim(),
    category: values.category,
    rank_level: values.rankLevel,
    date_awarded: values.dateAwarded,
    description: values.description.trim() || null,
  }
}

export function AwardFormDialog({
  open,
  award,
  saving,
  onOpenChange,
  onSave,
}: {
  open: boolean
  award: Award | null
  saving: boolean
  onOpenChange: (open: boolean) => void
  onSave: (input: AwardInput) => Promise<void>
}) {
  const [errors, setErrors] = useState<Partial<Record<keyof Values, string>>>({})
  const [formError, setFormError] = useState('')
  const form = useForm({
    defaultValues: valuesFor(award),
    onSubmit: async ({ value }) => {
      const nextErrors = validate(value)
      setErrors(nextErrors)
      setFormError('')
      if (Object.keys(nextErrors).length) {
        const firstField = Object.keys(nextErrors)[0]
        document.getElementById(`award-${firstField}`)?.focus()
        return
      }
      try {
        await onSave(toInput(value))
      } catch (error) {
        setFormError(presentError(error, 'form-submit').message)
      }
    },
  })

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setFormError('')
    void form.handleSubmit()
  }

  function clearError(key: keyof Values) {
    setErrors((current) => ({ ...current, [key]: undefined }))
  }

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!saving) onOpenChange(next)
      }}
      title={award ? 'Edit award' : 'Create award'}
      description="Record an award category, level, date, and recognition note."
      size="lg"
      fitContent
      compactOnMobile
      dismissDisabled={saving}
      footer={
        <>
          <Button variant="outline" disabled={saving} onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button type="submit" form="award-form" isLoading={saving}>
            {award ? 'Save changes' : 'Create award'}
          </Button>
        </>
      }
    >
      <form id="award-form" noValidate onSubmit={submit} className="space-y-4">
        {formError ? (
          <Alert tone="danger" title="Award not saved" role="alert">
            {formError}
          </Alert>
        ) : null}
        <FormSection className="space-y-4">
          <div className="flex items-start gap-3">
            <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
              <AwardIcon className="size-5" aria-hidden="true" />
            </span>
            <div>
              <h3 className="text-label font-semibold">Award information</h3>
              <p className="text-body-sm text-text-secondary mt-1">
                Awards are organisation-wide records and are not assigned to an employee profile.
              </p>
            </div>
          </div>
          <form.Field name="title">
            {(field) => (
              <FormControl id="award-title" label="Award title" required error={errors.title}>
                <TextInput
                  maxLength={255}
                  value={field.state.value}
                  placeholder="e.g. Customer service excellence"
                  onChange={(event) => {
                    field.handleChange(event.currentTarget.value)
                    clearError('title')
                  }}
                />
              </FormControl>
            )}
          </form.Field>
          <div className="phone:grid-cols-2 grid gap-4">
            <form.Field name="category">
              {(field) => (
                <FormControl id="award-category" label="Category" required error={errors.category}>
                  <DropdownSelect
                    value={field.state.value}
                    options={categoryOptions}
                    placeholder="Choose a category"
                    onChange={(value) => {
                      field.handleChange(value)
                      clearError('category')
                    }}
                    aria-label="Award category"
                    aria-invalid={Boolean(errors.category)}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="rankLevel">
              {(field) => (
                <FormControl
                  id="award-rankLevel"
                  label="Award level"
                  required
                  error={errors.rankLevel}
                >
                  <DropdownSelect
                    value={field.state.value}
                    options={rankOptions}
                    placeholder="Choose a level"
                    onChange={(value) => {
                      field.handleChange(value)
                      clearError('rankLevel')
                    }}
                    aria-label="Award level"
                    aria-invalid={Boolean(errors.rankLevel)}
                  />
                </FormControl>
              )}
            </form.Field>
          </div>
          <form.Field name="dateAwarded">
            {(field) => (
              <FormControl
                id="award-dateAwarded"
                label="Date awarded"
                required
                error={errors.dateAwarded}
              >
                <DatePickerField
                  value={field.state.value}
                  onValueChange={(value) => {
                    field.handleChange(value)
                    clearError('dateAwarded')
                  }}
                  required
                  placeholder="Choose a date"
                  aria-invalid={Boolean(errors.dateAwarded)}
                />
              </FormControl>
            )}
          </form.Field>
          <form.Field name="description">
            {(field) => (
              <FormControl id="award-description" label="Recognition note">
                <TextArea
                  rows={4}
                  maxLength={5000}
                  value={field.state.value}
                  placeholder="Add a short note about the achievement."
                  onChange={(event) => field.handleChange(event.currentTarget.value)}
                />
              </FormControl>
            )}
          </form.Field>
        </FormSection>
      </form>
    </Dialog>
  )
}
