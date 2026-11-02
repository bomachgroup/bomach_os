import { useEffect, useMemo, useRef, useState, type FormEvent, type ReactNode } from 'react'
import { useForm } from '@tanstack/react-form'
import { useQuery } from '@tanstack/react-query'
import {
  Building2,
  ChevronLeft,
  CircleCheck,
  CircleX,
  Clock3,
  FileText,
  Globe2,
  LocateFixed,
  MapPin,
  RotateCw,
} from 'lucide-react'

import {
  branchQueryKeys,
  branchesApi,
  type BranchBusinessHoursDto,
  type BranchChoicesDto,
  type BranchDto,
  type BranchUpdateInput,
  type BranchWriteInput,
} from '@/modules/company/branches.api'
import {
  draftHours,
  toHours,
  WEEKDAYS,
  type DayScheduleDraft,
} from '@/modules/company/branch-hours'
import { presentError } from '@/shared/errors'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { SectionErrorState } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import {
  CreationFlowActions,
  CreationFlowStepper,
  type CreationFlowStep,
} from '@/shared/ui/creation-flow'
import { FormSection } from '@/shared/ui/form-section'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'
import { BranchHoursEditor } from './branch-hours-editor'
import { BranchGeofenceFields } from '../components/branch-geofence-fields'

type BranchFormValues = {
  branchName: string
  branchRole: string
  operationalStatus: string
  defaultCurrency: string
  languagePreference: string
  country: string
  countryCode: string
  state: string
  stateCode: string
  city: string
  lga: string
  officeAddress: string
  contactEmail: string
  contactPhone: string
  managerId: string
  isActive: boolean
  latitude: string
  longitude: string
  radius: string
  notes: string
  hours: DayScheduleDraft[]
}

type BranchFieldErrors = Partial<Record<keyof BranchFormValues, string>>
type BranchFlowStep = 'profile' | 'location' | 'attendance' | 'hours' | 'review'

const BRANCH_FLOW_STEPS: (CreationFlowStep & { id: BranchFlowStep })[] = [
  {
    id: 'profile',
    label: 'Details',
    compactLabel: 'Basics',
    title: 'Branch details',
    detail: 'Give this location a name and set its operating defaults.',
  },
  {
    id: 'location',
    label: 'Location',
    compactLabel: 'Place',
    title: 'Location and contact',
    detail: 'Add the address and the people employees can contact.',
  },
  {
    id: 'attendance',
    label: 'Attendance',
    compactLabel: 'Attend',
    title: 'Attendance and notes',
    detail: 'Set or review the attendance point and add internal branch context.',
  },
  {
    id: 'hours',
    label: 'Hours',
    title: 'Weekly schedule',
    detail: 'Set the local weekly schedule and copy hours across days.',
  },
  {
    id: 'review',
    label: 'Review',
    title: 'Review and confirm',
    detail: 'Check all branch information before saving.',
  },
]

function valuesFromBranch(
  branch: BranchDto | null,
  hours: BranchBusinessHoursDto[] | undefined,
): BranchFormValues {
  return {
    branchName: branch?.branch_name ?? '',
    branchRole: branch?.branch_role ?? 'branch',
    operationalStatus: branch?.operational_status ?? 'active',
    defaultCurrency: branch?.default_currency ?? 'NGN',
    languagePreference: branch?.language_preference ?? 'en-GB',
    country: branch?.country ?? '',
    countryCode: branch?.country_code ?? '',
    state: branch?.state ?? '',
    stateCode: branch?.state_code ?? '',
    city: branch?.city ?? '',
    lga: branch?.lga ?? '',
    officeAddress: branch?.office_address ?? '',
    contactEmail: branch?.contact_email ?? '',
    contactPhone: branch?.contact_phone ?? '',
    managerId: branch?.manager_id ? String(branch.manager_id) : '',
    isActive: branch?.is_active ?? true,
    latitude: branch?.latitude == null ? '' : String(branch.latitude),
    longitude: branch?.longitude == null ? '' : String(branch.longitude),
    radius: String(branch?.attendance_radius_meters ?? 100),
    notes: branch?.notes ?? '',
    hours: draftHours(hours),
  }
}

function validate(
  values: BranchFormValues,
  canEditHours: boolean,
  scope: BranchFlowStep | 'all' = 'all',
): BranchFieldErrors {
  const errors: BranchFieldErrors = {}
  if (scope === 'all' || scope === 'profile') {
    if (values.branchName.trim().length < 2) errors.branchName = 'Enter a branch name.'
    if (!values.branchRole) errors.branchRole = 'Choose a branch type.'
    if (!values.operationalStatus) errors.operationalStatus = 'Choose an operational status.'
  }
  if (scope === 'all' || scope === 'location') {
    if (!values.country.trim()) errors.country = 'Enter a country.'
    if (!values.state.trim()) errors.state = 'Enter a state or region.'
    if (!values.officeAddress.trim()) errors.officeAddress = 'Enter the office address.'
    if (!/^\S+@\S+\.\S+$/.test(values.contactEmail.trim())) {
      errors.contactEmail = 'Enter a valid contact email.'
    }
    if (!/^\+?\d{9,15}$/.test(values.contactPhone.trim())) {
      errors.contactPhone = 'Enter a phone number with 9 to 15 digits.'
    }
  }
  if (scope === 'all' || scope === 'attendance') {
    const radius = Number(values.radius)
    if (!Number.isInteger(radius) || radius < 1 || radius > 5000) {
      errors.radius = 'Choose a radius from 1 to 5000 metres.'
    }
    const hasLatitude = values.latitude.trim() !== ''
    const hasLongitude = values.longitude.trim() !== ''
    if (hasLatitude !== hasLongitude) {
      errors.latitude = 'Capture both GPS coordinates, or clear both.'
      errors.longitude = 'Capture both GPS coordinates, or clear both.'
    } else if (hasLatitude && hasLongitude) {
      const latitude = Number(values.latitude)
      const longitude = Number(values.longitude)
      if (!Number.isFinite(latitude) || latitude < -90 || latitude > 90) {
        errors.latitude = 'Latitude must be between -90 and 90.'
      }
      if (!Number.isFinite(longitude) || longitude < -180 || longitude > 180) {
        errors.longitude = 'Longitude must be between -180 and 180.'
      }
    }
  }
  if (canEditHours && (scope === 'all' || scope === 'hours')) {
    values.hours.forEach((day, index) => {
      if (day.mode === 'open' && (!day.openTime || !day.closeTime)) {
        errors.hours = `Add opening and closing times for ${WEEKDAYS[index]}.`
      } else if (day.mode === 'open' && day.closeTime <= day.openTime) {
        errors.hours = `Closing time must be later than opening time on ${WEEKDAYS[index]}.`
      }
    })
  }
  return errors
}

function selectOptions(choices: BranchChoicesDto | undefined, key: keyof BranchChoicesDto) {
  return (choices?.[key] ?? []).map(({ value, label }) => ({ value, label }))
}

function includeCurrentOption(
  options: DropdownSelectOption[],
  value: string,
  label: string | null | undefined,
): DropdownSelectOption[] {
  if (!value || options.some((option) => option.value === value)) return options
  return [...options, { value, label: label || value }]
}

function choiceLabel(options: DropdownSelectOption[], value: string): string {
  return (options.find((option) => option.value === value)?.label ?? value) || 'Not set'
}

function operationalStatusTone(status: string): StatusTone {
  if (status === 'active') return 'success'
  if (status === 'under_maintenance' || status === 'temporarily_closed') return 'warning'
  if (status === 'permanently_closed') return 'danger'
  return 'neutral'
}

function ReviewValue({ label, value }: { label: string; value: string }) {
  return (
    <div className="min-w-0">
      <dt className="text-overline text-text-secondary">{label}</dt>
      <dd className="text-body-sm text-text-primary mt-1 font-medium break-words">
        {value || '—'}
      </dd>
    </div>
  )
}

function ReviewCard({
  title,
  description,
  icon,
  className,
  children,
}: {
  title: string
  description: string
  icon: ReactNode
  className?: string
  children: ReactNode
}) {
  return (
    <section
      className={`border-border-subtle bg-surface rounded-control min-w-0 border p-4 ${className ?? ''}`}
    >
      <div className="flex items-center gap-3">
        <span className="bg-primary-subtle text-primary rounded-control flex size-9 shrink-0 items-center justify-center">
          {icon}
        </span>
        <div className="min-w-0">
          <h4 className="text-body-sm font-semibold">{title}</h4>
          <p className="text-caption text-text-secondary mt-0.5">{description}</p>
        </div>
      </div>
      <div className="border-border-subtle mt-3 border-t pt-3">{children}</div>
    </section>
  )
}

function BranchReview({
  branchId,
  values,
  roleOptions,
  statusOptions,
  currencyOptions,
  languageOptions,
  managerOptions,
  savedHoursAvailable,
}: {
  branchId?: string
  values: BranchFormValues
  roleOptions: DropdownSelectOption[]
  statusOptions: DropdownSelectOption[]
  currencyOptions: DropdownSelectOption[]
  languageOptions: DropdownSelectOption[]
  managerOptions: DropdownSelectOption[]
  savedHoursAvailable: boolean
}) {
  const schedule = values.hours
    .map((day, index) => ({ day: WEEKDAYS[index], ...day }))
    .filter((day) => day.mode !== 'unset')
  const openDayCount = values.hours.filter((day) => day.mode === 'open').length
  const closedDayCount = values.hours.filter((day) => day.mode === 'closed').length
  const unsetDayCount = values.hours.filter((day) => day.mode === 'unset').length

  return (
    <div className="space-y-4">
      <header className="border-border-subtle from-primary-subtle/70 via-primary-subtle/25 to-surface rounded-surface shadow-elevation-sm relative overflow-hidden border bg-gradient-to-br">
        <span
          aria-hidden="true"
          className="from-primary via-primary/35 pointer-events-none absolute inset-x-0 top-0 h-[3px] bg-gradient-to-r to-transparent"
        />
        <div className="tablet:flex-row tablet:items-center tablet:justify-between tablet:p-5 flex min-w-0 flex-col gap-4 p-4">
          <div className="flex min-w-0 items-start gap-3">
            <span className="bg-surface text-primary rounded-control flex size-11 shrink-0 items-center justify-center border border-white/80 shadow-sm">
              <Building2 className="size-5" aria-hidden="true" />
            </span>
            <div className="min-w-0">
              <p className="text-overline text-primary font-semibold">Branch profile</p>
              <h3 className="text-h3 mt-1 font-semibold break-words">
                {values.branchName.trim() || 'Unnamed branch'}
              </h3>
              <p className="text-caption text-text-secondary mt-2">
                <span className="bg-surface/80 border-border-subtle inline-flex max-w-full items-center rounded-full border px-2.5 py-1 font-medium">
                  {branchId ? `Branch ID · ${branchId}` : 'Branch ID assigned after creation'}
                </span>
              </p>
            </div>
          </div>
          <div
            className="tablet:justify-end flex min-w-0 flex-wrap gap-2"
            role="group"
            aria-label="Branch status"
          >
            <StatusChip
              label={choiceLabel(roleOptions, values.branchRole)}
              tone="primary"
              icon={<Globe2 className="size-3.5" />}
            />
            <StatusChip
              label={choiceLabel(statusOptions, values.operationalStatus)}
              tone={operationalStatusTone(values.operationalStatus)}
            />
            <StatusChip
              label={values.isActive ? 'Active record' : 'Inactive record'}
              tone={values.isActive ? 'info' : 'neutral'}
              icon={
                values.isActive ? (
                  <CircleCheck className="size-3.5" />
                ) : (
                  <CircleX className="size-3.5" />
                )
              }
            />
          </div>
        </div>
      </header>

      <div className="tablet:grid-cols-2 grid min-w-0 gap-3">
        <ReviewCard
          title="Branch defaults"
          description="Branch ID, currency and language."
          icon={<Globe2 className="size-4" aria-hidden="true" />}
        >
          <dl className="tablet:grid-cols-2 grid min-w-0 grid-cols-1 gap-3">
            <ReviewValue
              label="Branch ID"
              value={branchId || 'Generated when the branch is created'}
            />
            <ReviewValue
              label="Currency"
              value={choiceLabel(currencyOptions, values.defaultCurrency)}
            />
            <ReviewValue
              label="Language"
              value={choiceLabel(languageOptions, values.languagePreference)}
            />
          </dl>
        </ReviewCard>

        <ReviewCard
          title="Location and contact"
          description="Address and people employees can reach."
          icon={<MapPin className="size-4" aria-hidden="true" />}
        >
          <dl className="tablet:grid-cols-2 grid min-w-0 grid-cols-1 gap-3">
            <ReviewValue label="Address" value={values.officeAddress.trim()} />
            <ReviewValue
              label="City and region"
              value={[values.city, values.state, values.country].filter(Boolean).join(', ')}
            />
            <ReviewValue label="Country code" value={values.countryCode.trim()} />
            <ReviewValue label="State code" value={values.stateCode.trim()} />
            <ReviewValue label="L.G.A. / district" value={values.lga.trim()} />
            <ReviewValue label="Email" value={values.contactEmail.trim()} />
            <ReviewValue label="Phone" value={values.contactPhone.trim()} />
            <ReviewValue
              label="Branch manager"
              value={
                managerOptions.find((option) => option.value === values.managerId)?.label ??
                'No manager assigned'
              }
            />
          </dl>
        </ReviewCard>

        <ReviewCard
          title="Attendance geofence"
          description="The point and distance used for attendance checks."
          icon={<LocateFixed className="size-4" aria-hidden="true" />}
        >
          <dl className="tablet:grid-cols-2 grid min-w-0 grid-cols-1 gap-3">
            <ReviewValue
              label="Attendance point"
              value={
                values.latitude.trim() && values.longitude.trim()
                  ? `${values.latitude}, ${values.longitude}`
                  : 'Not set'
              }
            />
            <ReviewValue label="Radius" value={`${values.radius || '100'} metres`} />
          </dl>
        </ReviewCard>

        <ReviewCard
          title="Business hours"
          description="The branch’s weekly local-time schedule."
          icon={<Clock3 className="size-4" aria-hidden="true" />}
        >
          <div>
            {!savedHoursAvailable ? (
              <p className="text-caption text-text-secondary">
                Saved hours could not be loaded. The current schedule will remain unchanged.
              </p>
            ) : schedule.length ? (
              <>
                <div className="flex flex-wrap gap-1.5">
                  <span className="bg-success-subtle text-success-foreground rounded-pill text-overline px-2.5 py-1">
                    {openDayCount} open
                  </span>
                  <span className="bg-surface-muted text-text-secondary rounded-pill text-overline px-2.5 py-1">
                    {closedDayCount} closed
                  </span>
                  <span className="bg-surface-muted text-text-secondary rounded-pill text-overline px-2.5 py-1">
                    {unsetDayCount} not set
                  </span>
                </div>
                <ul className="text-caption text-text-primary mt-3 space-y-1.5">
                  {schedule.map((day) => (
                    <li
                      key={day.day}
                      className="bg-surface-muted/65 rounded-control flex min-w-0 items-center justify-between gap-3 px-3 py-2"
                    >
                      <span className="font-medium">{day.day}</span>
                      <span className="text-right font-semibold tabular-nums">
                        {day.mode === 'closed' ? 'Closed' : `${day.openTime}–${day.closeTime}`}
                      </span>
                    </li>
                  ))}
                </ul>
              </>
            ) : (
              <p className="text-caption text-text-secondary">
                No schedule has been set. All {unsetDayCount} days will remain not set.
              </p>
            )}
          </div>
        </ReviewCard>

        <ReviewCard
          title="Internal notes"
          description="Additional context for branch operations."
          icon={<FileText className="size-4" aria-hidden="true" />}
          className="tablet:col-span-2"
        >
          <p className="text-body-sm text-text-secondary break-words whitespace-pre-wrap">
            {values.notes.trim() || 'No notes added.'}
          </p>
        </ReviewCard>
      </div>
      <div className="border-primary/15 bg-primary-subtle/35 text-text-secondary rounded-control flex items-start gap-2.5 border p-3">
        <CircleCheck className="text-primary mt-0.5 size-4 shrink-0" aria-hidden="true" />
        <p className="text-caption">
          Review is a preview. Nothing is saved until you choose{' '}
          <span className="text-text-primary font-semibold">
            {branchId ? 'Save changes' : 'Create branch'}
          </span>
          . You can return to any step to make corrections.
        </p>
      </div>
    </div>
  )
}

export function BranchFormDialog({
  open,
  onOpenChange,
  branch,
  userId,
  employeeId,
  canEditHours,
  onSave,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  branch: BranchDto | null
  userId: number
  employeeId: string
  canEditHours: boolean
  onSave: (input: BranchWriteInput | BranchUpdateInput) => Promise<void>
}) {
  const [fieldErrors, setFieldErrors] = useState<BranchFieldErrors>({})
  const [formError, setFormError] = useState<string | null>(null)
  const [managerSearch, setManagerSearch] = useState('')
  const [managerQueryText, setManagerQueryText] = useState('')
  const [activeStep, setActiveStep] = useState(0)
  const formElement = useRef<HTMLFormElement>(null)
  const hydratedHoursFor = useRef<number | null>(null)
  const intentionalSubmit = useRef(false)

  function handleOpenChange(nextOpen: boolean) {
    if (!nextOpen) {
      setFieldErrors({})
      setFormError(null)
      setActiveStep(0)
    }
    onOpenChange(nextOpen)
  }

  const choicesQuery = useQuery({
    queryKey: branchQueryKeys.choices(userId, employeeId),
    queryFn: ({ signal }) => branchesApi.choices(signal),
    enabled: open,
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const hoursQuery = useQuery({
    queryKey: branchQueryKeys.hours(userId, employeeId, branch?.id ?? 0),
    queryFn: ({ signal }) => branchesApi.businessHours(branch!.id, signal),
    enabled: Boolean(open && branch),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

  useEffect(() => {
    const timer = window.setTimeout(() => setManagerQueryText(managerSearch.trim()), 250)
    return () => window.clearTimeout(timer)
  }, [managerSearch])

  const managerParams = useMemo(
    () => ({
      search: managerQueryText,
      limit: 20,
      offset: 0,
      ...(branch ? { branchId: branch.id } : {}),
      currentManagerId: branch?.manager_id,
    }),
    [branch, managerQueryText],
  )
  const managersQuery = useQuery({
    queryKey: branchQueryKeys.managers(userId, employeeId, managerParams),
    queryFn: ({ signal }) => branchesApi.managerChoices(managerParams, signal),
    enabled: open,
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const canValidateHours = canEditHours && (!branch || hoursQuery.data !== undefined)

  const form = useForm({
    defaultValues: valuesFromBranch(branch, hoursQuery.data),
    onSubmit: async ({ value }) => {
      const errors = validate(value, canValidateHours)
      setFieldErrors(errors)
      setFormError(null)
      if (Object.keys(errors).length) {
        const firstInvalidStep = BRANCH_FLOW_STEPS.findIndex(
          (step) => Object.keys(validate(value, canValidateHours, step.id)).length > 0,
        )
        if (firstInvalidStep >= 0) setActiveStep(firstInvalidStep)
        return
      }
      const parsedLatitude = value.latitude.trim() ? Number(value.latitude) : null
      const parsedLongitude = value.longitude.trim() ? Number(value.longitude) : null
      const input: BranchUpdateInput = {
        branch_name: value.branchName.trim(),
        default_currency: value.defaultCurrency,
        language_preference: value.languagePreference,
        country: value.country.trim(),
        country_code: value.countryCode.trim(),
        state: value.state.trim(),
        state_code: value.stateCode.trim(),
        city: value.city.trim(),
        lga: value.lga.trim(),
        office_address: value.officeAddress.trim(),
        operational_status: value.operationalStatus,
        branch_role: value.branchRole,
        contact_email: value.contactEmail.trim(),
        contact_phone: value.contactPhone.trim(),
        manager_id: value.managerId ? Number(value.managerId) : null,
        is_active: value.isActive,
        notes: value.notes.trim(),
        latitude: parsedLatitude,
        longitude: parsedLongitude,
        attendance_radius_meters: Number(value.radius),
      }
      const maySaveHours = canEditHours && (!branch || hoursQuery.data !== undefined)
      const schedule = toHours(value.hours)
      if (maySaveHours && (branch || schedule.length > 0)) input.business_hours = schedule

      try {
        await onSave(branch ? input : (input as BranchWriteInput))
        setActiveStep(0)
      } catch (error) {
        setFormError(presentError(error, 'form-submit').message)
      }
    },
  })

  useEffect(() => {
    if (!open) return
    form.reset(valuesFromBranch(branch, hoursQuery.data))
    hydratedHoursFor.current = null
    // Rehydrate only when the dialog opens or the selected branch changes.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [branch?.id, form, open])

  useEffect(() => {
    if (!open || !branch || !hoursQuery.data || hydratedHoursFor.current === branch.id) return
    form.setFieldValue('hours', draftHours(hoursQuery.data))
    hydratedHoursFor.current = branch.id
  }, [branch, form, hoursQuery.data, open])

  useEffect(() => {
    if (Object.keys(fieldErrors).length) {
      formElement.current
        ?.querySelector<HTMLElement>('section:not([hidden]) [aria-invalid="true"]')
        ?.focus()
    }
  }, [activeStep, fieldErrors])

  useEffect(() => {
    if (!open) return
    formElement.current?.parentElement?.scrollTo({ top: 0, behavior: 'smooth' })
  }, [activeStep, open])

  const roleOptions = includeCurrentOption(
    selectOptions(choicesQuery.data, 'branch_role'),
    branch?.branch_role ?? '',
    branch?.branch_role_display,
  )
  const statusOptions = includeCurrentOption(
    selectOptions(choicesQuery.data, 'operational_status'),
    branch?.operational_status ?? '',
    branch?.operational_status_display,
  )
  const currencyOptions = includeCurrentOption(
    selectOptions(choicesQuery.data, 'currencies'),
    branch?.default_currency ?? '',
    branch?.default_currency,
  )
  const languageOptions = includeCurrentOption(
    selectOptions(choicesQuery.data, 'languages'),
    branch?.language_preference ?? '',
    branch?.language_preference,
  )
  const managerOptions: DropdownSelectOption[] = [
    { value: '', label: 'No manager assigned' },
    ...(managersQuery.data?.items ?? []).map((manager) => ({
      value: String(manager.user_id),
      label: manager.name,
      description: [manager.employee_id, manager.designation, manager.branch_name]
        .filter(Boolean)
        .join(' · '),
    })),
  ]
  if (
    branch?.manager_id &&
    !managerOptions.some((option) => option.value === String(branch.manager_id))
  ) {
    managerOptions.unshift({
      value: String(branch.manager_id),
      label: branch.manager_name || 'Current manager',
      description: 'Currently assigned manager',
    })
  }

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setFormError(null)
    if (activeStepId !== 'review') {
      continueStep()
      return
    }
    // The form can receive implicit submit events from Enter and browser assistive
    // technology. On Review, persist only after the user activates the final CTA.
    if (!intentionalSubmit.current) return
    intentionalSubmit.current = false
    void form.handleSubmit()
  }

  function continueStep() {
    const step = BRANCH_FLOW_STEPS[activeStep]
    if (!step || step.id === 'review') return
    const errors = validate(form.state.values, canValidateHours, step.id)
    setFieldErrors(errors)
    setFormError(null)
    if (Object.keys(errors).length) return
    setActiveStep((current) => Math.min(current + 1, BRANCH_FLOW_STEPS.length - 1))
  }

  function goToStep(index: number) {
    if (index < 0 || index >= activeStep) return
    setFieldErrors({})
    setFormError(null)
    setActiveStep(index)
  }

  const activeStepId = BRANCH_FLOW_STEPS[activeStep]?.id ?? 'profile'

  return (
    <Dialog
      open={open}
      onOpenChange={handleOpenChange}
      title={branch ? 'Edit branch' : 'Create branch'}
      description={
        branch
          ? 'Update the branch record, operating location, and local defaults.'
          : 'Set up a branch and its operating details.'
      }
      size="xl"
      className="tablet:max-h-[92dvh]"
      bodyClassName="space-y-5"
      footer={
        <CreationFlowActions
          leading={
            <Button variant="outline" onClick={() => handleOpenChange(false)}>
              Cancel
            </Button>
          }
        >
          {activeStep > 0 ? (
            <Button
              variant="outline"
              leadingIcon={<ChevronLeft className="size-4" aria-hidden="true" />}
              onClick={() => goToStep(activeStep - 1)}
              disabled={form.state.isSubmitting}
            >
              Previous
            </Button>
          ) : null}
          {activeStepId !== 'review' ? (
            <Button
              onClick={continueStep}
              disabled={
                form.state.isSubmitting ||
                (!branch && activeStepId === 'profile' && !choicesQuery.data) ||
                (Boolean(branch) && activeStepId === 'hours' && hoursQuery.isLoading)
              }
            >
              Next
            </Button>
          ) : (
            <Button
              type="submit"
              form="branch-form"
              onClick={() => {
                intentionalSubmit.current = true
              }}
              isLoading={form.state.isSubmitting}
              disabled={form.state.isSubmitting}
            >
              {branch ? 'Save changes' : 'Create branch'}
            </Button>
          )}
        </CreationFlowActions>
      }
    >
      <form id="branch-form" ref={formElement} noValidate onSubmit={submit} className="space-y-5">
        {formError ? (
          <Alert tone="danger" title="Branch not saved" role="alert">
            {formError}
          </Alert>
        ) : null}

        {choicesQuery.error ? (
          <SectionErrorState
            title="Branch options could not load"
            description="Retry to load the available branch types, statuses, currency, and language."
            error={choicesQuery.error}
            onRetry={() => void choicesQuery.refetch()}
          />
        ) : null}

        <CreationFlowStepper
          steps={BRANCH_FLOW_STEPS}
          currentStep={activeStep}
          maxSelectableStep={activeStep}
          onStepSelect={goToStep}
          ariaLabel={branch ? 'Branch update' : 'Branch setup'}
          variant="horizontal"
          eyebrow={branch ? 'Branch update' : 'Branch setup'}
          hideDetailBelow480
        />

        <FormSection hidden={activeStepId !== 'profile'} className="space-y-4">
          <div>
            <h3 className="text-label font-semibold">Branch identity</h3>
            <p className="text-caption text-text-secondary mt-1">
              Define the branch name, type, and operating state.
            </p>
          </div>
          <div className="phone:grid-cols-2 grid gap-4">
            <form.Field name="branchName">
              {(field) => (
                <FormControl
                  id="branch-name"
                  label="Branch name"
                  required
                  error={fieldErrors.branchName}
                >
                  <TextInput
                    autoComplete="organization"
                    value={field.state.value}
                    onBlur={field.handleBlur}
                    onChange={(event) => field.handleChange(event.currentTarget.value)}
                  />
                </FormControl>
              )}
            </form.Field>
            {branch ? (
              <FormControl id="branch-id" label="Branch ID">
                <TextInput
                  id="branch-id"
                  value={branch.branch_id || 'Generated when the branch is created'}
                  readOnly
                  className="bg-surface-muted text-text-secondary"
                />
              </FormControl>
            ) : null}
            <form.Field name="branchRole">
              {(field) => (
                <FormControl
                  id="branch-role"
                  label="Branch type"
                  required
                  error={fieldErrors.branchRole}
                >
                  <DropdownSelect
                    id="branch-role"
                    value={field.state.value}
                    options={roleOptions}
                    onChange={field.handleChange}
                    placeholder="Choose a branch type"
                    searchable
                    disabled={!choicesQuery.data}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="operationalStatus">
              {(field) => (
                <FormControl
                  id="branch-status"
                  label="Operational status"
                  required
                  error={fieldErrors.operationalStatus}
                >
                  <DropdownSelect
                    id="branch-status"
                    value={field.state.value}
                    options={statusOptions}
                    onChange={field.handleChange}
                    placeholder="Choose a status"
                    disabled={!choicesQuery.data}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="defaultCurrency">
              {(field) => (
                <FormControl id="branch-currency" label="Default currency">
                  <DropdownSelect
                    id="branch-currency"
                    value={field.state.value}
                    options={currencyOptions}
                    onChange={field.handleChange}
                    placeholder="Choose a currency"
                    searchable
                    disabled={!choicesQuery.data}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="languagePreference">
              {(field) => (
                <FormControl id="branch-language" label="Language">
                  <DropdownSelect
                    id="branch-language"
                    value={field.state.value}
                    options={languageOptions}
                    onChange={field.handleChange}
                    placeholder="Choose a language"
                    disabled={!choicesQuery.data}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="isActive">
              {(field) => (
                <label className="border-border-subtle bg-surface-muted/50 rounded-control phone:col-span-2 flex min-h-11 items-center gap-3 border px-3 py-2">
                  <input
                    type="checkbox"
                    checked={field.state.value}
                    onChange={(event) => field.handleChange(event.currentTarget.checked)}
                    className="accent-primary size-4 rounded"
                  />
                  <span className="min-w-0">
                    <span className="text-body-sm text-text-primary block font-medium">
                      Active record
                    </span>
                    <span className="text-caption text-text-secondary block">
                      Inactive records are retained for reference.
                    </span>
                  </span>
                </label>
              )}
            </form.Field>
          </div>
        </FormSection>

        <FormSection hidden={activeStepId !== 'location'} className="space-y-4">
          <div>
            <h3 className="text-label font-semibold">Location and contact</h3>
            <p className="text-caption text-text-secondary mt-1">
              Keep the physical address and branch contact details current.
            </p>
          </div>
          <div className="phone:grid-cols-2 grid gap-4">
            <form.Field name="country">
              {(field) => (
                <FormControl
                  id="branch-country"
                  label="Country"
                  required
                  error={fieldErrors.country}
                >
                  <TextInput
                    autoComplete="country-name"
                    value={field.state.value}
                    onBlur={field.handleBlur}
                    onChange={(event) => field.handleChange(event.currentTarget.value)}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="countryCode">
              {(field) => (
                <FormControl id="branch-country-code" label="Country code">
                  <TextInput
                    autoComplete="country"
                    maxLength={3}
                    value={field.state.value}
                    onChange={(event) =>
                      field.handleChange(event.currentTarget.value.toUpperCase())
                    }
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="state">
              {(field) => (
                <FormControl
                  id="branch-state"
                  label="State or region"
                  required
                  error={fieldErrors.state}
                >
                  <TextInput
                    autoComplete="address-level1"
                    value={field.state.value}
                    onChange={(event) => field.handleChange(event.currentTarget.value)}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="stateCode">
              {(field) => (
                <FormControl id="branch-state-code" label="State code">
                  <TextInput
                    maxLength={10}
                    value={field.state.value}
                    onChange={(event) =>
                      field.handleChange(event.currentTarget.value.toUpperCase())
                    }
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="city">
              {(field) => (
                <FormControl id="branch-city" label="City">
                  <TextInput
                    autoComplete="address-level2"
                    value={field.state.value}
                    onChange={(event) => field.handleChange(event.currentTarget.value)}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="lga">
              {(field) => (
                <FormControl id="branch-lga" label="L.G.A. / district">
                  <TextInput
                    value={field.state.value}
                    onChange={(event) => field.handleChange(event.currentTarget.value)}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="officeAddress">
              {(field) => (
                <FormControl
                  id="branch-address"
                  label="Office address"
                  required
                  className="phone:col-span-2"
                  error={fieldErrors.officeAddress}
                >
                  <TextArea
                    autoComplete="street-address"
                    rows={2}
                    value={field.state.value}
                    onChange={(event) => field.handleChange(event.currentTarget.value)}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="contactEmail">
              {(field) => (
                <FormControl
                  id="branch-email"
                  label="Contact email"
                  required
                  error={fieldErrors.contactEmail}
                >
                  <TextInput
                    type="email"
                    autoComplete="email"
                    value={field.state.value}
                    onChange={(event) => field.handleChange(event.currentTarget.value)}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="contactPhone">
              {(field) => (
                <FormControl
                  id="branch-phone"
                  label="Contact phone"
                  required
                  error={fieldErrors.contactPhone}
                  description="Include the country code, for example +2348012345678."
                >
                  <TextInput
                    type="tel"
                    autoComplete="tel"
                    value={field.state.value}
                    onChange={(event) => field.handleChange(event.currentTarget.value)}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="managerId">
              {(field) => (
                <div className="phone:col-span-2 space-y-2">
                  <FormControl id="branch-manager" label="Branch manager">
                    <DropdownSelect
                      id="branch-manager"
                      value={field.state.value}
                      options={managerOptions}
                      onChange={field.handleChange}
                      placeholder="No manager assigned"
                      searchable={false}
                      aria-label="Branch manager"
                      emptyMessage="No matching active employees."
                    />
                  </FormControl>
                  <FormControl id="branch-manager-search" label="Search employees">
                    <TextInput
                      type="search"
                      value={managerSearch}
                      onChange={(event) => setManagerSearch(event.currentTarget.value)}
                      placeholder="Search name, ID, or designation"
                    />
                  </FormControl>
                  {managersQuery.error ? (
                    <SectionErrorState
                      title="Manager choices could not load"
                      description="You can keep the current assignment or retry the employee list."
                      error={managersQuery.error}
                      onRetry={() => void managersQuery.refetch()}
                    />
                  ) : null}
                  {managersQuery.isFetching && managersQuery.data ? (
                    <p className="text-overline text-text-muted" role="status">
                      Updating manager choices…
                    </p>
                  ) : null}
                </div>
              )}
            </form.Field>
          </div>
        </FormSection>

        <FormSection hidden={activeStepId !== 'attendance'} className="space-y-4">
          <div className="phone:flex-row phone:items-start flex min-w-0 flex-col gap-3">
            <span className="bg-primary-subtle text-primary rounded-control flex size-9 shrink-0 items-center justify-center">
              <MapPin className="size-4" aria-hidden="true" />
            </span>
            <div className="min-w-0 flex-1">
              <h3 className="text-label font-semibold">Attendance geofence</h3>
              <p className="text-caption text-text-secondary mt-1">
                Set an optional GPS point and the distance used for attendance checks.
              </p>
            </div>
          </div>
          <form.Subscribe
            selector={(state) => ({
              latitude: state.values.latitude,
              longitude: state.values.longitude,
              radius: state.values.radius,
            })}
          >
            {({ latitude, longitude, radius }) => (
              <BranchGeofenceFields
                idPrefix="branch"
                active={activeStepId === 'attendance'}
                latitude={latitude}
                longitude={longitude}
                radius={radius}
                latitudeError={fieldErrors.latitude}
                longitudeError={fieldErrors.longitude}
                radiusError={fieldErrors.radius}
                onClear={() => {
                  form.setFieldValue('latitude', '')
                  form.setFieldValue('longitude', '')
                }}
                onLatitudeChange={(value) => form.setFieldValue('latitude', value)}
                onLongitudeChange={(value) => form.setFieldValue('longitude', value)}
                onRadiusChange={(value) => form.setFieldValue('radius', value)}
              />
            )}
          </form.Subscribe>
        </FormSection>

        <FormSection hidden={activeStepId !== 'hours'} className="space-y-4">
          <div className="flex items-start gap-3">
            <span className="bg-info-subtle text-info-foreground rounded-control flex size-9 shrink-0 items-center justify-center">
              <Clock3 className="size-4" aria-hidden="true" />
            </span>
            <div className="min-w-0">
              <h3 className="text-label font-semibold">Business hours</h3>
              <p className="text-caption text-text-secondary mt-1">
                Times use the branch’s local clock. Leave a day unset when no schedule is recorded.
              </p>
            </div>
          </div>
          {branch && hoursQuery.isLoading ? (
            <p className="text-caption text-text-secondary" role="status">
              Loading the saved weekly schedule…
            </p>
          ) : hoursQuery.error && branch && !hoursQuery.data ? (
            <SectionErrorState
              title="Business hours could not load"
              description={
                canEditHours
                  ? 'Branch details can still be saved. Retry to edit the schedule.'
                  : 'You can still update branch details. Retry to include saved hours in the review.'
              }
              error={hoursQuery.error}
              onRetry={() => void hoursQuery.refetch()}
            />
          ) : hoursQuery.error && hoursQuery.data ? (
            <Alert tone="warning" title="Showing saved business hours" role="status">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <span>The schedule could not refresh. Your saved schedule remains available.</span>
                <Button variant="ghost" size="sm" onClick={() => void hoursQuery.refetch()}>
                  Retry
                </Button>
              </div>
            </Alert>
          ) : !canEditHours ? (
            <Alert tone="info" title="Schedule editing is not available">
              Your role cannot update business hours. Existing hours remain unchanged.
            </Alert>
          ) : null}
          {canEditHours && (!branch || hoursQuery.data) ? (
            <form.Field name="hours">
              {(field) => (
                <div className="space-y-3">
                  {fieldErrors.hours ? (
                    <Alert tone="danger" role="status">
                      {fieldErrors.hours}
                    </Alert>
                  ) : null}
                  <BranchHoursEditor
                    days={field.state.value}
                    onChange={field.handleChange}
                    idPrefix="branch-hours"
                  />
                </div>
              )}
            </form.Field>
          ) : null}
        </FormSection>

        <FormSection hidden={activeStepId !== 'attendance'} className="space-y-3">
          <div>
            <h3 className="text-label font-semibold">Branch notes</h3>
            <p className="text-caption text-text-secondary mt-1">
              Add internal context that helps people operate this location.
            </p>
          </div>
          <form.Field name="notes">
            {(field) => (
              <FormControl id="branch-notes" label="Notes">
                <TextArea
                  rows={3}
                  value={field.state.value}
                  onChange={(event) => field.handleChange(event.currentTarget.value)}
                />
              </FormControl>
            )}
          </form.Field>
        </FormSection>

        <section
          hidden={activeStepId !== 'review'}
          className="space-y-4"
          aria-label="Review branch details"
        >
          <form.Subscribe selector={(state) => state.values}>
            {(values) => (
              <BranchReview
                branchId={branch?.branch_id}
                values={values}
                roleOptions={roleOptions}
                statusOptions={statusOptions}
                currencyOptions={currencyOptions}
                languageOptions={languageOptions}
                managerOptions={managerOptions}
                savedHoursAvailable={!branch || hoursQuery.data !== undefined}
              />
            )}
          </form.Subscribe>
        </section>
        {choicesQuery.isFetching && choicesQuery.data ? (
          <p className="text-overline text-text-muted inline-flex items-center gap-2" role="status">
            <RotateCw className="size-3 animate-spin" aria-hidden="true" /> Updating branch options…
          </p>
        ) : null}
      </form>
    </Dialog>
  )
}
