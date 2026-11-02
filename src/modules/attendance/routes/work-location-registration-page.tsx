import { useCallback, useEffect, useMemo, useRef, useState, type FormEvent } from 'react'
import { useForm } from '@tanstack/react-form'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { ArrowLeft, Building2, Check, Clock3, Crosshair, MapPin, ShieldCheck } from 'lucide-react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { useToast } from '@/shared/feedback/use-toast'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { CreationFlowActions, CreationFlowStepper } from '@/shared/ui/creation-flow'
import { FormSection } from '@/shared/ui/form-section'
import { PageLayout } from '@/shared/ui/page-layout'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'

import {
  attendanceApi,
  startGeoPositionScan,
  type Coordinates,
  type GeoPositionScanSession,
  type GeoPositionScanUpdate,
  type WorkLocationInput,
} from '../attendance.api'
import { GpsCapturePanel } from '../components/gps-capture-panel'
import { getBrowserPermissionState, type BrowserPermissionState } from '../browser-permissions'
import {
  attendanceQueryKeys,
  workLocationBranchesQueryOptions,
  workLocationsQueryOptions,
} from '../attendance.queries'
import type { AttendanceSetupSearch } from '../attendance.search'

type LocationType = 'branch' | 'remote' | 'site'
type LocationFormValues = {
  name: string
  type: LocationType
  branchId: number | null
  permanence: 'permanent' | 'temporary'
  expiryDate: string
  notes: string
}
type LocationFieldErrors = Partial<Record<keyof LocationFormValues, string>>

const registrationSteps = [
  {
    id: 'gps',
    label: 'GPS point',
    title: 'Confirm the GPS point',
    detail:
      'Capture the point while you are physically at the work location. We need a reading within 30 metres to continue.',
  },
  {
    id: 'details',
    label: 'Location details',
    title: 'Location details',
    detail: 'BOMACH reviews each location before enabling it for clocking.',
  },
] as const

function dateIsFuture(value: string) {
  if (!value) return false
  const today = new Date()
  const localToday = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`
  return value > localToday
}

function coordinatesLabel(coordinates: Coordinates) {
  return `${coordinates.latitude.toFixed(5)}, ${coordinates.longitude.toFixed(5)}`
}

function RegistrationGuidance({
  current,
  coordinates,
}: {
  current: 'location' | 'details'
  coordinates: Coordinates | null
}) {
  return (
    <Card className="desktop:sticky desktop:top-24 desktop:block hidden h-fit space-y-4">
      <div className="bg-primary-subtle text-primary rounded-control flex size-10 items-center justify-center">
        {current === 'location' ? (
          <Crosshair className="size-5" aria-hidden="true" />
        ) : (
          <ShieldCheck className="size-5" aria-hidden="true" />
        )}
      </div>
      <div>
        <h2 className="text-label text-text-primary font-semibold">
          {current === 'location' ? 'A precise pin matters' : 'What happens next'}
        </h2>
        <p className="text-caption text-text-secondary mt-1">
          {current === 'location'
            ? 'The captured point defines where you can clock in after approval.'
            : 'Your request is reviewed before it can be used for attendance.'}
        </p>
      </div>
      <div className="border-border-subtle rounded-control border p-3">
        <p className="text-caption text-text-primary font-semibold">
          {coordinates ? 'GPS point saved' : 'GPS point required'}
        </p>
        <p className="text-caption text-text-secondary mt-1">
          {coordinates
            ? `Current fix is within ±${Math.round(coordinates.accuracy_meters)} m.`
            : 'The browser asks for location only after you start capture.'}
        </p>
      </div>
      <ul className="text-caption text-text-secondary space-y-3">
        <li className="flex items-start gap-2">
          <Crosshair className="text-primary mt-0.5 size-4 shrink-0" aria-hidden="true" />
          Capture while you are at the work location.
        </li>
        <li className="flex items-start gap-2">
          <Building2 className="text-primary mt-0.5 size-4 shrink-0" aria-hidden="true" />
          Branch requests must match the selected active branch area.
        </li>
        <li className="flex items-start gap-2">
          <Clock3 className="text-primary mt-0.5 size-4 shrink-0" aria-hidden="true" />
          Clocking starts after a reviewer approves the request.
        </li>
      </ul>
    </Card>
  )
}

export function WorkLocationRegistrationPage() {
  const navigate = useNavigate()
  const search = useSearch({
    from: '/_protected/hr/attendance/work-locations/new',
  }) as AttendanceSetupSearch
  const queryClient = useQueryClient()
  const toast = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canSubmit = hasPermission(permissions, 'work_locations', 'submit')
  const canReadLocations =
    hasPermission(permissions, 'work_locations', 'list') ||
    hasPermission(permissions, 'work_locations', 'list_own')
  const canListBranches = hasPermission(permissions, 'work_locations', 'list')
  const sourceLocationId = search.sourceLocationId
  const sourceLocationsQuery = useQuery({
    ...workLocationsQueryOptions(userId, employeeId),
    enabled: Boolean(session && canReadLocations && sourceLocationId),
  })
  const formElement = useRef<HTMLFormElement>(null)
  const prefilledLocationRef = useRef<number | null>(null)
  const [step, setStep] = useState<'location' | 'details'>('location')
  const [type, setType] = useState<LocationType>('branch')
  const [coordinates, setCoordinates] = useState<Coordinates | null>(null)
  const [locationScan, setLocationScan] = useState<GeoPositionScanUpdate>({
    phase: 'preparing',
    bestCoordinates: null,
    latestAccuracyMeters: null,
    elapsedMs: 0,
    sampleCount: 0,
  })
  const [locationPermission, setLocationPermission] = useState<BrowserPermissionState | 'checking'>(
    'checking',
  )
  const [capturingLocation, setCapturingLocation] = useState(false)
  const [locationError, setLocationError] = useState<string | null>(null)
  const [formError, setFormError] = useState<string | null>(null)
  const [fieldErrors, setFieldErrors] = useState<LocationFieldErrors>({})
  const createMutation = useMutation({ mutationFn: attendanceApi.proposeLocation })
  const locationCaptureSessionRef = useRef<GeoPositionScanSession | null>(null)
  const autoScanStartedRef = useRef(false)
  const form = useForm({
    defaultValues: {
      name: '',
      type: 'branch',
      branchId: null,
      permanence: 'permanent',
      expiryDate: '',
      notes: '',
    } as LocationFormValues,
    onSubmit: async ({ value }) => {
      setFieldErrors({})
      setFormError(null)
      const errors: LocationFieldErrors = {}
      if (value.name.trim().length < 2) errors.name = 'Enter a location name.'
      if (value.type === 'branch' && value.branchId === null) {
        errors.branchId = 'Choose an active branch.'
      }
      if (value.type !== 'branch' && value.permanence === 'temporary' && !value.expiryDate) {
        errors.expiryDate = 'Choose an expiry date.'
      } else if (
        value.type !== 'branch' &&
        value.permanence === 'temporary' &&
        !dateIsFuture(value.expiryDate)
      ) {
        errors.expiryDate = 'Choose a future expiry date.'
      }
      if (!coordinates) {
        setFormError('Capture and confirm your GPS point before submitting the request.')
        setStep('location')
        return
      }
      setFieldErrors(errors)
      if (Object.keys(errors).length) return
      const input: WorkLocationInput = {
        name: value.name.trim(),
        location_type: value.type,
        notes: value.notes.trim(),
        ...coordinates,
        ...(value.type === 'branch' && value.branchId !== null
          ? { branch_id: value.branchId }
          : {}),
        ...(value.type !== 'branch' && value.permanence === 'temporary'
          ? { expires_at: new Date(`${value.expiryDate}T23:59:59`).toISOString() }
          : { expires_at: null }),
      }
      try {
        await createMutation.mutateAsync(input)
        await queryClient.invalidateQueries({
          queryKey: attendanceQueryKeys.locations(userId, employeeId),
        })
        toast.showToast({
          title: 'Work location submitted',
          description:
            'Your request is pending review. You can use it for clocking after approval.',
          tone: 'success',
        })
        backToAttendance()
      } catch (error) {
        setFormError(presentError(error, 'form-submit').message)
      }
    },
  })
  const branchesQuery = useQuery({
    ...workLocationBranchesQueryOptions(userId),
    enabled: Boolean(session && type === 'branch' && canListBranches),
  })
  const locationTypeOptions: DropdownSelectOption[] = [
    {
      value: 'branch',
      label: canListBranches ? 'Branch' : 'Branch · access required',
      description: 'Use an active branch boundary',
      disabled: !canListBranches,
    },
    { value: 'site', label: 'Work site', description: 'Register a permanent or temporary site' },
    {
      value: 'remote',
      label: 'Remote location',
      description: 'Register a home or remote work point',
    },
  ]
  const branchOptions = useMemo(
    () =>
      (branchesQuery.data ?? []).map((branch) => ({
        value: String(branch.id),
        label: branch.branch_name,
        description: [branch.branch_id, branch.city, branch.state].filter(Boolean).join(' · '),
      })),
    [branchesQuery.data],
  )
  const tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate() + 1)
  const minExpiryDate = `${tomorrow.getFullYear()}-${String(tomorrow.getMonth() + 1).padStart(2, '0')}-${String(tomorrow.getDate()).padStart(2, '0')}`

  function backToAttendance() {
    locationCaptureSessionRef.current?.cancel()
    locationCaptureSessionRef.current = null
    void navigate({
      to: '/hr/attendance',
      search: { dateFrom: search.dateFrom, dateTo: search.dateTo, page: search.page },
    })
  }

  useEffect(() => {
    const source = sourceLocationId
      ? sourceLocationsQuery.data?.locations.find((location) => location.id === sourceLocationId)
      : undefined
    if (!source || prefilledLocationRef.current === source.id) return
    prefilledLocationRef.current = source.id
    form.setFieldValue('name', source.name)
    form.setFieldValue('type', source.location_type as LocationType)
    setType(source.location_type as LocationType)
    form.setFieldValue('branchId', source.branch_id)
    form.setFieldValue('notes', source.notes.replace(/\n?\[capture accuracy:[^\]]+\]/g, '').trim())
  }, [form, sourceLocationId, sourceLocationsQuery.data])

  useEffect(() => {
    if (Object.keys(fieldErrors).length) {
      formElement.current?.querySelector<HTMLElement>('[aria-invalid="true"]')?.focus()
    }
  }, [fieldErrors])

  useEffect(() => {
    let active = true
    void getBrowserPermissionState('geolocation').then((state) => {
      if (active) setLocationPermission(state)
    })
    return () => {
      active = false
    }
  }, [])

  useEffect(
    () => () => {
      locationCaptureSessionRef.current?.cancel()
    },
    [],
  )

  const captureLocation = useCallback(async () => {
    locationCaptureSessionRef.current?.cancel()
    setLocationError(null)
    setCoordinates(null)
    setLocationScan({
      phase: 'preparing',
      bestCoordinates: null,
      latestAccuracyMeters: null,
      elapsedMs: 0,
      sampleCount: 0,
    })
    setCapturingLocation(true)
    const session = startGeoPositionScan({ maxAccuracyMeters: 30 }, setLocationScan)
    locationCaptureSessionRef.current = session
    try {
      const position = await session.result
      setCoordinates(position)
      setLocationPermission(await getBrowserPermissionState('geolocation'))
      setStep('details')
    } catch (error) {
      const cancelled = error instanceof Error && error.message === 'LOCATION_SCAN_CANCELLED'
      if (!cancelled) {
        setLocationError(
          error instanceof Error
            ? error.message
            : 'GPS could not confirm your location. Check location access and try again.',
        )
        const permission = await getBrowserPermissionState('geolocation')
        setLocationPermission(permission)
      }
    } finally {
      if (locationCaptureSessionRef.current === session) {
        locationCaptureSessionRef.current = null
        setCapturingLocation(false)
      }
    }
  }, [])

  function cancelLocationCapture() {
    locationCaptureSessionRef.current?.cancel()
  }

  function acceptBestLocation() {
    const best = locationScan.bestCoordinates
    if (!best || best.accuracy_meters > 30) return
    if (!locationCaptureSessionRef.current?.acceptBest()) {
      setCoordinates(best)
      setStep('details')
    }
  }

  useEffect(() => {
    if (
      step !== 'location' ||
      !session ||
      !canSubmit ||
      coordinates ||
      capturingLocation ||
      locationError ||
      autoScanStartedRef.current
    ) {
      return
    }
    autoScanStartedRef.current = true
    void captureLocation()
  }, [captureLocation, capturingLocation, coordinates, locationError, canSubmit, session, step])

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setFormError(null)
    void form.handleSubmit()
  }

  if (sessionQuery.isPending) {
    return (
      <PageLayout title="Register work location" subtitle="Submit a location for review.">
        <Card className="space-y-3" aria-busy="true">
          <Skeleton variant="title" />
          <Skeleton variant="row" />
        </Card>
      </PageLayout>
    )
  }
  if (sessionQuery.isError || !session) {
    return (
      <PageLayout title="Register work location" subtitle="Submit a location for review.">
        <Card>
          <ErrorState
            title="Your access could not be confirmed"
            description="Reload the page and try again."
            error={sessionQuery.error}
          />
        </Card>
      </PageLayout>
    )
  }
  if (!canSubmit) {
    return (
      <PageLayout title="Register work location" subtitle="Submit a location for review.">
        <Card>
          <ErrorState
            title="You can’t submit a work location"
            description="Your account needs work-location submission access."
          />
        </Card>
      </PageLayout>
    )
  }

  return (
    <PageLayout
      title="Register work location"
      subtitle="Capture the work point, then submit its details for review."
      leading={<MapPin className="size-[18px]" aria-hidden="true" />}
      backLink={
        <Button
          variant="ghost"
          size="sm"
          className={pageBackLinkClassName}
          onClick={backToAttendance}
        >
          <PageBackLinkContent>Attendance</PageBackLinkContent>
        </Button>
      }
      contentClassName="space-y-4"
    >
      {sourceLocationId && sourceLocationsQuery.isError && !sourceLocationsQuery.data ? (
        <SectionErrorState
          description="The rejected location details could not load. You can still submit a new request."
          error={sourceLocationsQuery.error}
          onRetry={() => void sourceLocationsQuery.refetch()}
        />
      ) : null}
      {sourceLocationId &&
      sourceLocationsQuery.data?.locations.some(
        (location) => location.id === sourceLocationId && location.status === 'rejected',
      ) ? (
        <Alert tone="warning" title="Submitting a new request">
          This creates a new work-location request. The rejected request remains in your history.
          Capture a new GPS point at the location.
        </Alert>
      ) : null}
      <div className="desktop:grid-cols-[minmax(0,1fr)_18rem] desktop:items-start mx-auto grid w-full max-w-6xl gap-4">
        <div className="min-w-0 space-y-4">
          <CreationFlowStepper
            ariaLabel="Work location registration"
            steps={registrationSteps}
            currentStep={step === 'location' ? 0 : 1}
            maxSelectableStep={step === 'location' ? 0 : 1}
            onStepSelect={(index) => setStep(index === 0 ? 'location' : 'details')}
            variant="horizontal"
            eyebrow="Work location setup"
          />
          {step === 'location' ? (
            <FormSection className="space-y-5">
              {locationError ? (
                <Alert tone="danger" title="GPS point not confirmed" role="alert">
                  {locationError}
                </Alert>
              ) : null}
              <GpsCapturePanel
                permissionState={locationPermission}
                scanning={capturingLocation}
                bestCoordinates={locationScan.bestCoordinates}
                latestAccuracyMeters={locationScan.latestAccuracyMeters}
                elapsedSeconds={Math.floor(locationScan.elapsedMs / 1000)}
                sampleCount={locationScan.sampleCount}
                hasPreviousScan={locationScan.phase !== 'preparing'}
                maxAccuracyMeters={30}
                coordinates={coordinates}
                error={locationError}
                onCapture={() => void captureLocation()}
                onUseBest={acceptBestLocation}
                onCancel={cancelLocationCapture}
              />
              <CreationFlowActions
                className="border-border-subtle border-t pt-4"
                leading={
                  <Button variant="outline" onClick={backToAttendance}>
                    Cancel
                  </Button>
                }
              >
                <p className="text-caption text-text-muted self-center">
                  Select a usable point above to continue.
                </p>
              </CreationFlowActions>
            </FormSection>
          ) : (
            <FormSection className="space-y-5">
              {coordinates ? (
                <div className="border-success/25 bg-success-subtle rounded-control flex items-start gap-3 border p-3">
                  <Check
                    className="text-success-foreground mt-0.5 size-4 shrink-0"
                    aria-hidden="true"
                  />
                  <div className="min-w-0">
                    <p className="text-label text-text-primary font-semibold">
                      GPS point confirmed
                    </p>
                    <p className="text-caption text-text-secondary mt-0.5 break-words">
                      {coordinatesLabel(coordinates)} · accuracy{' '}
                      {Math.round(coordinates.accuracy_meters)} m
                    </p>
                  </div>
                  <Button
                    variant="ghost"
                    size="sm"
                    className="ml-auto shrink-0"
                    onClick={() => setStep('location')}
                  >
                    Change
                  </Button>
                </div>
              ) : null}
              {formError ? (
                <Alert tone="danger" title="Location request not submitted" role="alert">
                  {formError}
                </Alert>
              ) : null}
              <form
                id="work-location-form"
                ref={formElement}
                noValidate
                onSubmit={submit}
                className="space-y-4"
              >
                <div className="tablet:grid-cols-2 grid gap-4">
                  <form.Field name="type">
                    {(field) => (
                      <FormControl
                        id="work-location-type"
                        label="Location type"
                        required
                        error={fieldErrors.type}
                      >
                        <DropdownSelect
                          aria-label="Location type"
                          value={field.state.value}
                          options={locationTypeOptions}
                          onChange={(value) => {
                            const nextType = value as LocationType
                            field.handleChange(nextType)
                            setType(nextType)
                            setFieldErrors((previous) => ({ ...previous, type: undefined }))
                          }}
                          aria-invalid={Boolean(fieldErrors.type)}
                        />
                      </FormControl>
                    )}
                  </form.Field>
                  <form.Field name="name">
                    {(field) => (
                      <FormControl
                        id="work-location-name"
                        label="Location name"
                        required
                        error={fieldErrors.name}
                      >
                        <TextInput
                          value={field.state.value}
                          onChange={(event) => field.handleChange(event.target.value)}
                          maxLength={120}
                          placeholder={
                            type === 'branch'
                              ? 'Name this work location'
                              : 'For example, home office'
                          }
                          aria-invalid={Boolean(fieldErrors.name)}
                        />
                      </FormControl>
                    )}
                  </form.Field>
                </div>
                {type === 'branch' ? (
                  <form.Field name="branchId">
                    {(field) => (
                      <FormControl
                        id="work-location-branch"
                        label="Active branch"
                        required
                        error={fieldErrors.branchId}
                      >
                        {canListBranches ? (
                          <DropdownSelect
                            aria-label="Active branch"
                            value={field.state.value === null ? '' : String(field.state.value)}
                            options={branchOptions}
                            placeholder="Choose a branch"
                            emptyMessage={
                              branchesQuery.isPending
                                ? 'Loading active branches…'
                                : 'No active branches available.'
                            }
                            onChange={(value) => {
                              field.handleChange(value ? Number(value) : null)
                              setFieldErrors((previous) => ({ ...previous, branchId: undefined }))
                            }}
                            aria-invalid={Boolean(fieldErrors.branchId)}
                            disabled={branchesQuery.isPending || branchesQuery.isError}
                          />
                        ) : (
                          <Alert tone="warning" title="Branch choices require access">
                            Your account can submit locations but cannot list active branches.
                            Choose a work site or remote location, or ask an administrator for
                            branch-list access.
                          </Alert>
                        )}
                      </FormControl>
                    )}
                  </form.Field>
                ) : (
                  <div className="space-y-3">
                    <p className="text-control-label text-text-primary font-bold">Duration</p>
                    <form.Field name="permanence">
                      {(field) => (
                        <div
                          className="grid grid-cols-2 gap-2"
                          role="group"
                          aria-label="Location duration"
                        >
                          {(['permanent', 'temporary'] as const).map((value) => (
                            <button
                              key={value}
                              type="button"
                              aria-pressed={field.state.value === value}
                              onClick={() => field.handleChange(value)}
                              className={`rounded-control text-label focus-visible:shadow-focus-ring border px-3 py-2.5 font-medium capitalize focus-visible:outline-none ${field.state.value === value ? 'border-primary bg-primary-subtle text-primary' : 'border-border-subtle bg-surface text-text-secondary hover:bg-surface-muted'}`}
                            >
                              {value}
                            </button>
                          ))}
                        </div>
                      )}
                    </form.Field>
                    <form.Field name="permanence">
                      {(field) =>
                        field.state.value === 'temporary' ? (
                          <form.Field name="expiryDate">
                            {(expiryField) => (
                              <FormControl
                                id="work-location-expiry"
                                label="Expires on"
                                required
                                error={fieldErrors.expiryDate}
                              >
                                <DatePickerField
                                  value={expiryField.state.value}
                                  onValueChange={(value) => expiryField.handleChange(value)}
                                  min={minExpiryDate}
                                  required
                                  aria-invalid={fieldErrors.expiryDate ? 'true' : undefined}
                                />
                              </FormControl>
                            )}
                          </form.Field>
                        ) : null
                      }
                    </form.Field>
                  </div>
                )}
                <form.Field name="notes">
                  {(field) => (
                    <FormControl id="work-location-notes" label="Notes">
                      <TextArea
                        value={field.state.value}
                        onChange={(event) => field.handleChange(event.target.value)}
                        rows={3}
                        maxLength={500}
                        placeholder="Add context that will help the reviewer assess this location."
                      />
                    </FormControl>
                  )}
                </form.Field>
                {branchesQuery.isError && canListBranches ? (
                  <SectionErrorState
                    description="Active branches could not load."
                    error={branchesQuery.error}
                    onRetry={() => void branchesQuery.refetch()}
                  />
                ) : null}
                <Alert tone="info" title="Review and approval">
                  {type === 'branch'
                    ? 'The server checks that this captured point is inside the selected branch area. This request stays pending until approved.'
                    : 'This request stays pending until approved. Temporary locations expire on the date you choose.'}
                </Alert>
                <CreationFlowActions
                  className="border-border-subtle border-t pt-4"
                  leading={
                    <Button
                      type="button"
                      variant="outline"
                      onClick={() => setStep('location')}
                      leadingIcon={<ArrowLeft className="size-4" />}
                    >
                      Back to GPS
                    </Button>
                  }
                >
                  <Button
                    type="button"
                    variant="outline"
                    onClick={backToAttendance}
                    disabled={createMutation.isPending}
                  >
                    Cancel
                  </Button>
                  <Button
                    type="submit"
                    form="work-location-form"
                    isLoading={createMutation.isPending}
                    leadingIcon={<MapPin className="size-4" />}
                  >
                    Submit for review
                  </Button>
                </CreationFlowActions>
              </form>
            </FormSection>
          )}
        </div>
        <RegistrationGuidance current={step} coordinates={coordinates} />
      </div>
    </PageLayout>
  )
}
