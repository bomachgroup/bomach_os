import { useEffect, useRef, useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  ArrowRight,
  Building2,
  CalendarDays,
  CalendarRange,
  Camera,
  CheckCircle2,
  ChevronLeft,
  ChevronRight,
  Clock3,
  Eraser,
  FileClock,
  Fingerprint,
  LoaderCircle,
  LogIn,
  LogOut,
  MapPin,
  RotateCw,
  ShieldCheck,
  Trash2,
  type LucideIcon,
} from 'lucide-react'

import { personalOverviewQueryKey } from '@/modules/dashboard/dashboard.api'
import { personalWorkQueryKeys } from '@/modules/dashboard/personal-work.api'
import { isApiError } from '@/shared/api/api-error'
import { presentError } from '@/shared/errors'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { useToast } from '@/shared/feedback/use-toast'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import {
  EmptyState,
  ErrorState,
  SectionErrorState,
  Skeleton,
  SummaryUnavailable,
} from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip } from '@/shared/ui/status-chip'

import {
  attendanceApi,
  startGeoPositionScan,
  type AttendanceRecord,
  type Coordinates,
  type GeoPositionScanSession,
  type GeoPositionScanUpdate,
  type WorkLocation,
} from '../attendance.api'
import {
  attendanceHistoryQueryOptions,
  attendanceQueryKeys,
  attendanceSummaryQueryOptions,
  attendanceTodayQueryOptions,
  biometricStatusQueryOptions,
  workLocationsQueryOptions,
} from '../attendance.queries'
import type { AttendanceSearch } from '../attendance.search'
import { FaceCaptureDialog } from '../components/face-capture-dialog'
import { GpsCapturePanel } from '../components/gps-capture-panel'
import { getBrowserPermissionState, type BrowserPermissionState } from '../browser-permissions'

const PAGE_SIZE = 10

type ClockFlowRecovery = 'face' | 'location' | 'locations'
type ClockFlowStage = 'refreshing' | 'gps' | 'verifying' | null

function formatDate(
  value: string,
  options: Intl.DateTimeFormatOptions = { day: 'numeric', month: 'short', year: 'numeric' },
) {
  const date = new Date(`${value.slice(0, 10)}T12:00:00`)
  return Number.isNaN(date.getTime())
    ? value
    : new Intl.DateTimeFormat(undefined, options).format(date)
}

function formatTime(value: string | null | undefined) {
  if (!value) return 'Not recorded'
  const date = new Date(value)
  return Number.isNaN(date.getTime())
    ? value
    : new Intl.DateTimeFormat(undefined, { hour: 'numeric', minute: '2-digit' }).format(date)
}

function formatDuration(minutes: number) {
  const hours = Math.floor(minutes / 60)
  const remaining = minutes % 60
  if (!hours) return `${remaining} min`
  return remaining ? `${hours} hr ${remaining} min` : `${hours} hr`
}

function formatRecordCount(count: number) {
  return `${count} ${count === 1 ? 'record' : 'records'}`
}

function errorMessage(error: unknown, fallback: string) {
  if (isApiError(error)) return presentError(error, 'form-submit').message
  return error instanceof Error ? error.message : fallback
}

function locationStatus(location: WorkLocation) {
  if (location.status === 'pending') return { label: 'Awaiting review', tone: 'info' as const }
  if (location.status === 'rejected') return { label: 'Not approved', tone: 'danger' as const }
  if (location.is_expired) return { label: 'Expired', tone: 'warning' as const }
  if (!location.is_active) return { label: 'Inactive', tone: 'neutral' as const }
  if (location.can_be_used) return { label: 'Approved', tone: 'success' as const }
  return { label: 'Unavailable', tone: 'neutral' as const }
}

function StatusControl({
  icon: Icon,
  title,
  compactTitle,
  label,
  tone,
  onClick,
  disabled = false,
}: {
  icon: LucideIcon
  title: string
  compactTitle: string
  label: string
  tone: 'success' | 'warning' | 'info' | 'neutral'
  onClick: () => void
  disabled?: boolean
}) {
  const tones =
    tone === 'success'
      ? {
          surface: 'border-success/25 bg-success-subtle/45 hover:bg-success-subtle',
          icon: 'bg-success-subtle text-success-foreground',
          dot: 'bg-success',
        }
      : tone === 'info'
        ? {
            surface: 'border-info/25 bg-info-subtle/45 hover:bg-info-subtle',
            icon: 'bg-info-subtle text-info-foreground',
            dot: 'bg-info',
          }
        : tone === 'warning'
          ? {
              surface: 'border-warning/25 bg-warning-subtle/45 hover:bg-warning-subtle',
              icon: 'bg-warning-subtle text-warning-foreground',
              dot: 'bg-warning',
            }
          : {
              surface: 'border-border-subtle bg-surface hover:bg-surface-muted',
              icon: 'bg-surface-muted text-text-secondary',
              dot: 'bg-text-muted',
            }
  return (
    <Button
      variant="outline"
      size="sm"
      onClick={onClick}
      disabled={disabled}
      aria-label={`${title}: ${label}`}
      className={`group h-12 min-h-12 w-full min-w-0 justify-start gap-1.5 border px-2 py-1.5 text-left transition-colors ${tones.surface}`}
    >
      <span
        className={`rounded-control flex size-7 shrink-0 items-center justify-center ${tones.icon}`}
      >
        <Icon className="size-3.5" aria-hidden="true" />
      </span>
      <span className="min-w-0 flex-1 leading-tight">
        <span className="phone:hidden text-caption text-text-primary block truncate font-semibold">
          {compactTitle}
        </span>
        <span className="phone:block text-caption text-text-primary hidden truncate font-semibold">
          {title}
        </span>
        <span className="text-overline text-text-secondary mt-0.5 flex min-w-0 items-center gap-1">
          <span className={`size-1.5 shrink-0 rounded-full ${tones.dot}`} aria-hidden="true" />
          <span className="truncate">{label}</span>
        </span>
      </span>
      <ChevronRight
        className="text-text-muted size-3.5 shrink-0 transition-transform group-hover:translate-x-0.5"
        aria-hidden="true"
      />
    </Button>
  )
}

function SummaryMetric({
  label,
  value,
  icon: Icon,
  tone,
  detail,
}: {
  label: string
  value: string
  icon: LucideIcon
  tone: string
  detail?: string
}) {
  return (
    <div className="border-border-subtle bg-surface rounded-control tablet:p-3 flex min-h-[72px] min-w-0 flex-col justify-between gap-2 border p-2.5">
      <div className="flex min-w-0 items-center gap-2">
        <span
          className={`bg-surface-muted rounded-control flex size-7 shrink-0 items-center justify-center ${tone}`}
        >
          <Icon className="size-3.5" aria-hidden="true" />
        </span>
        <p className="text-caption text-text-secondary min-w-0 leading-snug font-medium">{label}</p>
      </div>
      <div className="min-w-0">
        <p className="text-label text-text-primary leading-none font-semibold tabular-nums">
          {value}
        </p>
        {detail ? (
          <p className="text-overline text-text-muted mt-1.5 leading-snug">{detail}</p>
        ) : null}
      </div>
    </div>
  )
}

function LiveClock({ serverTimeOffset }: { serverTimeOffset: number }) {
  const [currentTime, setCurrentTime] = useState(() => new Date())

  useEffect(() => {
    const updateTime = () => setCurrentTime(new Date(Date.now() + serverTimeOffset))
    updateTime()
    const intervalId = window.setInterval(updateTime, 1000)
    return () => window.clearInterval(intervalId)
  }, [serverTimeOffset])

  const timeParts = new Intl.DateTimeFormat('en-US', {
    timeZone: 'Africa/Lagos',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: true,
  }).formatToParts(currentTime)
  const getPart = (type: Intl.DateTimeFormatPartTypes) =>
    timeParts.find((part) => part.type === type)?.value ?? ''
  const hour = getPart('hour')
  const minute = getPart('minute')
  const second = getPart('second')
  const dayPeriod = getPart('dayPeriod')
  const timeLabel = `${hour}:${minute}:${second} ${dayPeriod}`
  const weekdayLabel = new Intl.DateTimeFormat('en-GB', {
    timeZone: 'Africa/Lagos',
    weekday: 'long',
  }).format(currentTime)
  const calendarDate = new Intl.DateTimeFormat('en-GB', {
    timeZone: 'Africa/Lagos',
    day: 'numeric',
    month: 'long',
  }).format(currentTime)
  const dateLabel = `${weekdayLabel}, ${calendarDate}`

  return (
    <div className="border-primary/10 from-primary-subtle/35 via-surface to-surface-muted rounded-control tablet:px-5 tablet:py-4 border bg-gradient-to-br px-3.5 py-3">
      <div className="flex items-center justify-between gap-3">
        <p className="text-caption text-text-secondary flex min-w-0 items-center gap-2 font-medium">
          <CalendarDays className="text-primary size-4 shrink-0" aria-hidden="true" />
          <span className="truncate">{dateLabel}</span>
        </p>
        <span className="border-success/20 bg-success-subtle text-success-foreground rounded-pill inline-flex shrink-0 items-center gap-1.5 border px-2.5 py-1 text-[0.65rem] font-semibold tracking-[0.12em]">
          <span
            className="bg-success size-1.5 animate-pulse rounded-full motion-reduce:animate-none"
            aria-hidden="true"
          />
          LIVE
        </span>
      </div>
      <div className="mt-2 text-center">
        <time
          dateTime={currentTime.toISOString()}
          aria-label={`Current time ${timeLabel}`}
          className="text-text-primary inline-flex items-baseline font-bold tabular-nums"
        >
          <span className="tablet:text-[3.25rem] text-[2.75rem] leading-none tracking-[0.045em]">
            {hour}:{minute}
          </span>
          <span className="tablet:text-[1.85rem] text-[1.6rem] leading-none tracking-[0.02em]">
            :{second}
          </span>
          <span className="text-text-secondary tablet:ml-2 tablet:text-sm ml-1.5 text-[0.8rem] leading-none font-semibold tracking-[0.08em]">
            {dayPeriod}
          </span>
        </time>
      </div>
    </div>
  )
}

function ClockTimeCard({
  icon: Icon,
  label,
  value,
  tone,
}: {
  icon: LucideIcon
  label: string
  value: string
  tone: 'success' | 'info'
}) {
  const iconTone = tone === 'success' ? 'text-success-foreground' : 'text-info-foreground'
  return (
    <div className="bg-surface-muted rounded-control min-w-0 p-3">
      <p className="text-caption text-text-secondary flex items-center gap-2">
        <Icon className={`size-4 shrink-0 ${iconTone}`} aria-hidden="true" />
        {label}
      </p>
      <p className="text-label text-text-primary mt-2 truncate font-semibold tabular-nums">
        {value}
      </p>
    </div>
  )
}

function HistoryPagination({
  page,
  pages,
  total,
  onPage,
}: {
  page: number
  pages: number
  total: number
  onPage: (page: number) => void
}) {
  return (
    <div className="border-border-subtle tablet:px-5 flex flex-wrap items-center justify-between gap-3 border-t px-4 py-3">
      <p className="text-caption text-text-secondary" aria-live="polite">
        Page {page} of {pages} · {formatRecordCount(total)}
      </p>
      <div className="flex items-center gap-2">
        <Button variant="outline" size="sm" disabled={page <= 1} onClick={() => onPage(page - 1)}>
          <ChevronLeft className="size-4" />
          Previous
        </Button>
        <Button
          variant="outline"
          size="sm"
          disabled={page >= pages}
          onClick={() => onPage(page + 1)}
        >
          Next
          <ChevronRight className="size-4" />
        </Button>
      </div>
    </div>
  )
}

function ExtensionDialog({
  location,
  open,
  onOpenChange,
  onSave,
  busy,
}: {
  location: WorkLocation | null
  open: boolean
  onOpenChange: (open: boolean) => void
  onSave: (locationId: number, dateTime: string, reason: string) => Promise<void>
  busy: boolean
}) {
  const [dateTime, setDateTime] = useState('')
  const [reason, setReason] = useState('')
  const [error, setError] = useState<string | null>(null)
  return (
    <Dialog
      open={open}
      onOpenChange={onOpenChange}
      title="Request location extension"
      description={location?.name ?? 'Work location'}
      size="sm"
      fitContent
      footer={
        <>
          <Button variant="outline" onClick={() => onOpenChange(false)} disabled={busy}>
            Cancel
          </Button>
          <Button
            onClick={() => {
              const requestedExpiry = new Date(dateTime)
              if (
                !location ||
                !dateTime ||
                !Number.isFinite(requestedExpiry.getTime()) ||
                requestedExpiry <= new Date() ||
                reason.trim().length < 3
              ) {
                setError('Choose a future expiry date and enter a reason.')
                return
              }
              setError(null)
              void onSave(location.id, dateTime, reason.trim()).catch((reason: unknown) => {
                setError(errorMessage(reason, 'The extension request could not be sent.'))
              })
            }}
            isLoading={busy}
          >
            Send request
          </Button>
        </>
      }
    >
      <div className="space-y-4">
        {error ? <Alert tone="danger">{error}</Alert> : null}
        <FormSection className="space-y-4">
          <div>
            <h3 className="text-label font-semibold">Extension request</h3>
            <p className="text-caption text-text-secondary mt-1">
              Choose when access should end and explain why it needs to continue.
            </p>
          </div>
          <FormControl id="extension-expiry" label="Requested expiry" required>
            <TextInput
              type="datetime-local"
              value={dateTime}
              onChange={(event) => setDateTime(event.target.value)}
            />
          </FormControl>
          <FormControl id="extension-reason" label="Reason" required>
            <TextArea
              rows={3}
              value={reason}
              onChange={(event) => setReason(event.target.value)}
              maxLength={500}
              placeholder="Why should this location remain available?"
            />
          </FormControl>
        </FormSection>
      </div>
    </Dialog>
  )
}

function LocationCard({
  location,
  canDelete,
  canExtend,
  canPropose,
  onDelete,
  onExtend,
  onResubmit,
  deleting,
}: {
  location: WorkLocation
  canDelete: boolean
  canExtend: boolean
  canPropose: boolean
  onDelete: (location: WorkLocation) => void
  onExtend: (location: WorkLocation) => void
  onResubmit: (location: WorkLocation) => void
  deleting: boolean
}) {
  const state = locationStatus(location)
  const canRequestExtension =
    canExtend && location.status === 'approved' && location.is_active && !location.is_expired
  const hasActions =
    (canDelete && location.status === 'pending') ||
    canRequestExtension ||
    (canPropose && location.status === 'rejected')
  return (
    <article className="border-border-subtle bg-surface rounded-control tablet:grid-cols-[auto_minmax(0,1fr)_auto] tablet:p-4 grid min-w-0 grid-cols-[auto_minmax(0,1fr)] items-start gap-3 border p-3">
      <span className="bg-primary-subtle text-primary rounded-control flex size-9 shrink-0 items-center justify-center">
        {location.location_type === 'branch' ? (
          <Building2 className="size-4.5" aria-hidden="true" />
        ) : (
          <MapPin className="size-4.5" aria-hidden="true" />
        )}
      </span>
      <div className="min-w-0">
        <div className="flex min-w-0 items-start gap-2">
          <h3 className="text-label text-text-primary min-w-0 flex-1 font-semibold break-words">
            {location.name}
          </h3>
          <StatusChip label={state.label} tone={state.tone} dense className="shrink-0" />
        </div>
        <div className="text-caption text-text-secondary mt-1.5 flex flex-wrap items-center gap-x-3 gap-y-1">
          <span className="inline-flex items-center gap-1.5 capitalize">
            <MapPin className="size-3.5" aria-hidden="true" />
            {location.location_type.replaceAll('_', ' ')}
          </span>
          {location.branch_name ? (
            <span className="inline-flex items-center gap-1.5">
              <Building2 className="size-3.5" aria-hidden="true" />
              {location.branch_name}
            </span>
          ) : null}
          {location.expires_at ? (
            <span className="inline-flex items-center gap-1.5">
              <CalendarDays className="size-3.5" aria-hidden="true" />
              Expires {formatDate(location.expires_at)}
            </span>
          ) : null}
        </div>
      </div>
      {hasActions ? (
        <div className="tablet:col-start-3 tablet:row-span-2 tablet:row-start-1 tablet:items-start col-start-2 flex min-w-0 flex-wrap justify-end gap-2">
          {canDelete && location.status === 'pending' ? (
            <Button
              variant="outline"
              size="sm"
              onClick={() => onDelete(location)}
              isLoading={deleting}
              leadingIcon={<Trash2 className="size-4" />}
            >
              Withdraw request
            </Button>
          ) : null}
          {canRequestExtension ? (
            <Button
              variant="outline"
              size="sm"
              onClick={() => onExtend(location)}
              leadingIcon={<CalendarRange className="size-4" />}
            >
              Request extension
            </Button>
          ) : null}
          {canPropose && location.status === 'rejected' ? (
            <Button
              variant="outline"
              size="sm"
              onClick={() => onResubmit(location)}
              leadingIcon={<ArrowRight className="size-4" />}
            >
              Submit a new proposal
            </Button>
          ) : null}
        </div>
      ) : null}
      {location.status === 'rejected' || location.deactivation_note ? (
        <div className="tablet:col-span-3 col-span-2 min-w-0 space-y-2">
          {location.status === 'rejected' ? (
            <div className="rounded-control border-danger/25 bg-danger-subtle max-w-3xl border px-3 py-2.5">
              <p className="text-caption text-danger-foreground font-semibold">Reviewer feedback</p>
              <p className="text-caption text-text-secondary mt-0.5">
                {location.rejection_reason ||
                  'This location was not approved. Submit a new proposal with updated details.'}
              </p>
            </div>
          ) : null}
          {location.deactivation_note ? (
            <p className="text-caption text-text-secondary">{location.deactivation_note}</p>
          ) : null}
        </div>
      ) : null}
    </article>
  )
}

function AttendanceHistoryRow({ record }: { record: AttendanceRecord }) {
  const isIn = record.attendance_type === 'clock_in'
  const Icon = isIn ? CheckCircle2 : Clock3
  return (
    <div className="desktop:grid-cols-[minmax(9rem,1fr)_minmax(8rem,.8fr)_minmax(11rem,1.2fr)_minmax(8rem,.8fr)] desktop:items-center desktop:gap-4 desktop:px-5 grid min-w-0 grid-cols-2 gap-x-3 gap-y-3 px-4 py-4">
      <div className="min-w-0">
        <p className="text-body-sm text-text-primary flex items-center gap-2 font-medium">
          <CalendarDays className="text-text-muted size-4 shrink-0" aria-hidden="true" />
          <span className="truncate">{formatDate(record.timestamp)}</span>
        </p>
        <p className="text-caption text-text-muted mt-1 pl-6 tabular-nums">
          {formatTime(record.timestamp)}
        </p>
      </div>
      <span
        className={`text-caption rounded-pill inline-flex min-w-0 items-center justify-center gap-1.5 self-center justify-self-end px-2.5 py-1.5 font-semibold ${isIn ? 'bg-success-subtle text-success-foreground' : 'bg-info-subtle text-info-foreground'}`}
      >
        <Icon className="size-4 shrink-0" aria-hidden="true" />
        <span className="truncate">{isIn ? 'Clock in' : 'Clock out'}</span>
      </span>
      <p className="text-caption text-text-secondary flex min-w-0 items-center gap-1.5 truncate">
        <MapPin className="text-text-muted size-3.5 shrink-0" aria-hidden="true" />
        <span className="truncate">
          {record.location_used_name || 'Location verified'}
          {record.distance_meters != null ? ` · ${Math.round(record.distance_meters)} m` : ''}
        </span>
      </p>
      <p className="text-caption text-text-secondary flex min-w-0 items-center gap-1.5 truncate">
        <ShieldCheck className="text-text-muted size-3.5 shrink-0" aria-hidden="true" />
        <span className="truncate capitalize">
          {record.verification_method.replaceAll('_', ' ')}
        </span>
      </p>
    </div>
  )
}

export function AttendancePage() {
  const search = useSearch({ from: '/_protected/hr/attendance' }) as AttendanceSearch
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const toast = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canRead =
    hasPermission(permissions, 'attendance', 'list') ||
    hasPermission(permissions, 'attendance', 'list_own')
  const canLocationRead =
    hasPermission(permissions, 'work_locations', 'list') ||
    hasPermission(permissions, 'work_locations', 'list_own')
  const canVerifyLocation =
    hasPermission(permissions, 'work_locations', 'view') ||
    hasPermission(permissions, 'work_locations', 'view_own')
  const canProposeLocation = hasPermission(permissions, 'work_locations', 'submit')
  const canDeleteLocation = hasPermission(permissions, 'work_locations', 'delete_own')
  const canExtendLocation = hasPermission(permissions, 'work_locations', 'request_extension')
  const todayQuery = useQuery({
    ...attendanceTodayQueryOptions(userId, employeeId),
    enabled: Boolean(session && canRead),
  })
  const summaryQuery = useQuery({
    ...attendanceSummaryQueryOptions(userId, employeeId),
    enabled: Boolean(session && canRead),
  })
  const statusQuery = useQuery({
    ...biometricStatusQueryOptions(userId, employeeId),
    enabled: Boolean(session && canRead),
  })
  const locationsQuery = useQuery({
    ...workLocationsQueryOptions(userId, employeeId),
    enabled: Boolean(session && canLocationRead),
  })
  const historyParams = {
    limit: PAGE_SIZE,
    offset: (search.page - 1) * PAGE_SIZE,
    dateFrom: search.dateFrom,
    dateTo: search.dateTo,
  }
  const historyQuery = useQuery({
    ...attendanceHistoryQueryOptions(userId, employeeId, historyParams),
    enabled: Boolean(session && canRead),
  })
  const [cameraMode, setCameraMode] = useState(false)
  const [clockCoordinates, setClockCoordinates] = useState<Coordinates | null>(null)
  const [clockFlowOpen, setClockFlowOpen] = useState(false)
  const [clockFlowAction, setClockFlowAction] = useState<'clock_in' | 'clock_out' | null>(null)
  const [clockFlowStage, setClockFlowStage] = useState<ClockFlowStage>(null)
  const [clockFlowRecovery, setClockFlowRecovery] = useState<ClockFlowRecovery | null>(null)
  const [clockFlowCanRetry, setClockFlowCanRetry] = useState(true)
  const [clockGpsScan, setClockGpsScan] = useState<GeoPositionScanUpdate>({
    phase: 'preparing',
    bestCoordinates: null,
    latestAccuracyMeters: null,
    elapsedMs: 0,
    sampleCount: 0,
  })
  const [clockGpsScanning, setClockGpsScanning] = useState(false)
  const [clockLocationInvalid, setClockLocationInvalid] = useState(false)
  const [clockGpsPermission, setClockGpsPermission] = useState<BrowserPermissionState | 'checking'>(
    'checking',
  )
  const [actionError, setActionError] = useState<string | null>(null)
  const [preparingClock, setPreparingClock] = useState(false)
  const [serverTimeOffset, setServerTimeOffset] = useState(0)
  const clockFlowAttemptRef = useRef(0)
  const [extensionLocation, setExtensionLocation] = useState<WorkLocation | null>(null)
  const [deleteLocation, setDeleteLocation] = useState<WorkLocation | null>(null)
  const [deleteError, setDeleteError] = useState<string | null>(null)
  const clockGeoSessionRef = useRef<GeoPositionScanSession | null>(null)

  useEffect(() => {
    if (!session || !canRead) return
    const controller = new AbortController()
    void attendanceApi
      .serverTimeOffset(controller.signal)
      .then((offset) => setServerTimeOffset(offset))
      .catch(() => undefined)
    return () => controller.abort()
  }, [canRead, employeeId, session, userId])

  useEffect(() => {
    let active = true
    void getBrowserPermissionState('geolocation').then((state) => {
      if (active) setClockGpsPermission(state)
    })
    return () => {
      active = false
    }
  }, [])

  useEffect(
    () => () => {
      clockFlowAttemptRef.current += 1
      clockGeoSessionRef.current?.cancel()
    },
    [],
  )

  const clockMutation = useMutation({ mutationFn: attendanceApi.clock })
  const deleteMutation = useMutation({ mutationFn: attendanceApi.deletePendingLocation })
  const extensionMutation = useMutation({
    mutationFn: ({
      locationId,
      dateTime,
      reason,
    }: {
      locationId: number
      dateTime: string
      reason: string
    }) => attendanceApi.requestExtension(locationId, new Date(dateTime).toISOString(), reason),
  })

  function updateSearch(updates: Partial<AttendanceSearch>) {
    void navigate({
      to: '/hr/attendance',
      search: (previous: AttendanceSearch) => ({ ...previous, ...updates }),
      resetScroll: false,
    })
  }

  async function invalidateAttendance() {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: attendanceQueryKeys.today(userId, employeeId) }),
      queryClient.invalidateQueries({ queryKey: attendanceQueryKeys.summary(userId, employeeId) }),
      queryClient.invalidateQueries({
        queryKey: attendanceQueryKeys.histories(userId, employeeId),
      }),
      queryClient.invalidateQueries({
        queryKey: personalWorkQueryKeys.attendanceToday(userId, employeeId),
      }),
      queryClient.invalidateQueries({ queryKey: personalOverviewQueryKey(userId, employeeId) }),
    ])
  }

  function openFaceSetup() {
    void navigate({ to: '/hr/attendance/face-registration', search })
  }

  function openLocationSetup(sourceLocationId?: number) {
    void navigate({
      to: '/hr/attendance/work-locations/new',
      search: { ...search, ...(sourceLocationId ? { sourceLocationId } : {}) },
    })
  }

  function focusLocations() {
    if (locationsQuery.isError && !locationsQuery.data) {
      void locationsQuery.refetch()
      return
    }
    document
      .getElementById('work-locations')
      ?.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }

  function closeClockFlow() {
    clockFlowAttemptRef.current += 1
    clockGeoSessionRef.current?.cancel()
    clockGeoSessionRef.current = null
    setClockFlowOpen(false)
    setPreparingClock(false)
    setClockGpsScanning(false)
    setClockLocationInvalid(false)
    setClockFlowStage(null)
    setClockFlowRecovery(null)
    setClockGpsScan({
      phase: 'preparing',
      bestCoordinates: null,
      latestAccuracyMeters: null,
      elapsedMs: 0,
      sampleCount: 0,
    })
    setActionError(null)
  }

  function continueClockFlowRecovery() {
    const recovery = clockFlowRecovery
    closeClockFlow()
    if (recovery === 'face') openFaceSetup()
    if (recovery === 'location') openLocationSetup()
    if (recovery === 'locations') focusLocations()
  }

  async function startClock() {
    clockGeoSessionRef.current?.cancel()
    clockGeoSessionRef.current = null
    const attempt = clockFlowAttemptRef.current + 1
    clockFlowAttemptRef.current = attempt
    const isCurrentAttempt = () => clockFlowAttemptRef.current === attempt
    let gpsScanStarted = false

    setClockFlowOpen(true)
    setClockFlowAction(todayQuery.data?.next_action ?? null)
    setClockFlowRecovery(null)
    setClockFlowCanRetry(true)
    setClockGpsScan({
      phase: 'preparing',
      bestCoordinates: null,
      latestAccuracyMeters: null,
      elapsedMs: 0,
      sampleCount: 0,
    })
    setClockGpsScanning(false)
    setClockLocationInvalid(false)
    setActionError(null)
    setPreparingClock(true)
    setClockFlowStage('refreshing')
    try {
      const [todayResult, statusResult, locationResult] = await Promise.all([
        todayQuery.refetch(),
        statusQuery.refetch(),
        canLocationRead ? locationsQuery.refetch() : Promise.resolve(null),
      ])
      if (!isCurrentAttempt()) return
      const freshToday = todayResult.data
      const freshFaceReady = Boolean(
        statusResult.data?.biometric_enabled && statusResult.data?.has_face,
      )
      if (todayResult.isError || !freshToday) {
        setActionError(
          'Today’s clocking status could not be refreshed. Retry the Today section and try again.',
        )
        setClockFlowStage(null)
        return
      }
      setClockFlowAction(freshToday.next_action)
      if (!freshToday?.next_action) {
        await invalidateAttendance()
        if (!isCurrentAttempt()) return
        setActionError(
          'Today’s attendance action has changed. The latest status is now shown above.',
        )
        setClockFlowCanRetry(false)
        setClockFlowStage(null)
        return
      }
      if (statusResult.isError || !statusResult.data) {
        setActionError(
          'Face verification status could not be confirmed. Retry this check before continuing.',
        )
        setClockFlowStage(null)
        return
      }
      if (!freshFaceReady) {
        setActionError('Register your face before recording attendance.')
        setClockFlowRecovery('face')
        setClockFlowStage(null)
        return
      }
      if (!locationResult?.data || locationResult.isError) {
        setActionError(
          'Work-location status could not be confirmed. Retry this check before continuing.',
        )
        setClockFlowStage(null)
        return
      }
      if (locationResult.data.attendance_location_status !== 'ready') {
        setActionError(
          locationResult.data.attendance_location_status === 'pending'
            ? 'Your work location is waiting for review. Clocking becomes available after approval.'
            : 'Submit a work-location request before clocking.',
        )
        setClockFlowRecovery(
          locationResult.data.attendance_location_status === 'setup_required' && canProposeLocation
            ? 'location'
            : 'locations',
        )
        setClockFlowStage(null)
        return
      }
      if (!canVerifyLocation) {
        setActionError(
          'Your account cannot verify GPS against an approved work location. Contact your administrator.',
        )
        setClockFlowCanRetry(false)
        setClockFlowStage(null)
        return
      }

      setClockFlowStage('gps')
      gpsScanStarted = true
      void scanClockGps(attempt)
    } catch (error) {
      if (isCurrentAttempt()) {
        setActionError(errorMessage(error, 'Location could not be verified.'))
        setClockFlowStage(null)
      }
    } finally {
      if (isCurrentAttempt()) {
        if (!gpsScanStarted) {
          setPreparingClock(false)
          setClockFlowStage(null)
        }
      }
    }
  }

  async function verifyClockCoordinates(coordinates: Coordinates, attempt: number) {
    if (clockFlowAttemptRef.current !== attempt) return
    setClockGpsScanning(false)
    setPreparingClock(true)
    setClockFlowStage('verifying')
    setActionError(null)
    if (coordinates.accuracy_meters > 30) {
      setActionError(
        `GPS accuracy is about ${Math.round(coordinates.accuracy_meters)} m. Clocking requires a reading within 30 m. Move near a window or outside and continue scanning.`,
      )
      setPreparingClock(false)
      setClockFlowStage('gps')
      return
    }
    try {
      const verification = await attendanceApi.verifyLocation(coordinates)
      if (clockFlowAttemptRef.current !== attempt) return
      if (!verification.is_valid) {
        const hint = verification.hint ?? ''
        if (hint.includes('no_usable_location')) {
          setActionError(
            'No approved work location is available for your account. Review your work-location status before clocking.',
          )
          setClockFlowRecovery('locations')
          setPreparingClock(false)
          setClockFlowStage(null)
          return
        }
        setClockLocationInvalid(true)
        setActionError(
          hint.includes('poor_gps')
            ? 'GPS accuracy is too weak. Move near a window or outside and wait for a clearer reading.'
            : hint.includes('out_of_range')
              ? `You are outside the approved work-location boundary${verification.nearest_location ? ` for ${verification.nearest_location}` : ''}. Move closer, then scan again.`
              : hint.includes('no_usable_location')
                ? 'No approved work location is available for your account. Ask an administrator to approve or assign a location before clocking.'
                : 'Your GPS position could not be matched to an approved work location.',
        )
        setPreparingClock(false)
        setClockFlowStage('gps')
        return
      }
      setClockCoordinates(coordinates)
      setClockFlowOpen(false)
      setCameraMode(true)
    } catch (error) {
      if (clockFlowAttemptRef.current !== attempt) return
      setActionError(errorMessage(error, 'Location could not be verified.'))
      setPreparingClock(false)
      setClockFlowStage('gps')
    }
  }

  async function scanClockGps(attempt: number) {
    if (clockFlowAttemptRef.current !== attempt) return
    clockGeoSessionRef.current?.cancel()
    setActionError(null)
    setClockGpsScan({
      phase: 'preparing',
      bestCoordinates: null,
      latestAccuracyMeters: null,
      elapsedMs: 0,
      sampleCount: 0,
    })
    setClockLocationInvalid(false)
    setClockFlowStage('gps')
    setClockGpsScanning(true)
    setPreparingClock(true)
    const session = startGeoPositionScan({ maxAccuracyMeters: 30 }, (update) => {
      if (clockFlowAttemptRef.current === attempt) setClockGpsScan(update)
    })
    clockGeoSessionRef.current = session
    try {
      const coordinates = await session.result
      if (clockFlowAttemptRef.current !== attempt) return
      setClockGpsPermission(await getBrowserPermissionState('geolocation'))
      await verifyClockCoordinates(coordinates, attempt)
    } catch (error) {
      if (clockFlowAttemptRef.current !== attempt) return
      const cancelled = error instanceof Error && error.message === 'LOCATION_SCAN_CANCELLED'
      if (!cancelled) {
        setActionError(errorMessage(error, 'Location could not be verified.'))
        void getBrowserPermissionState('geolocation').then(setClockGpsPermission)
      }
      setPreparingClock(false)
      setClockFlowStage('gps')
    } finally {
      if (clockFlowAttemptRef.current === attempt) {
        setClockGpsScanning(false)
        if (clockGeoSessionRef.current === session) clockGeoSessionRef.current = null
        setPreparingClock(false)
      }
    }
  }

  function continueWithBestClockLocation() {
    const attempt = clockFlowAttemptRef.current
    const best = clockGpsScan.bestCoordinates
    if (clockLocationInvalid || !best || best.accuracy_meters > 30) return
    if (!clockGeoSessionRef.current?.acceptBest()) {
      void verifyClockCoordinates(best, attempt)
    }
  }

  async function handleFaceCapture(image: string) {
    const action = todayQuery.data?.next_action
    if (!action || !clockCoordinates)
      throw new Error(
        'Today’s status may have changed. Close this check and start clocking again to refresh readiness.',
      )
    try {
      const result = await clockMutation.mutateAsync({
        biometric_data: image,
        biometric_type: 'face',
        attendance_type: action,
        ...clockCoordinates,
      })
      toast.showToast({
        title: action === 'clock_in' ? 'Clock-in recorded' : 'Clock-out recorded',
        description: `${formatTime(result.timestamp)} · ${result.location_used ?? 'Location verified'}`,
        tone: 'success',
      })
    } catch (error) {
      if (
        isApiError(error) &&
        ['ATTENDANCE_ALREADY_CLOCKED_IN', 'ATTENDANCE_ALREADY_CLOCKED_OUT'].includes(
          error.code ?? '',
        )
      ) {
        await invalidateAttendance()
        setCameraMode(false)
        setClockCoordinates(null)
        setClockFlowAction(action)
        setActionError('This clock action was already recorded. Today’s status has been refreshed.')
        setClockFlowCanRetry(false)
        setClockFlowRecovery(null)
        setClockFlowStage(null)
        setClockFlowOpen(true)
        return
      }
      throw error
    }
    setActionError(null)
    await invalidateAttendance()
  }

  async function confirmDeleteLocation() {
    if (!deleteLocation) return
    setDeleteError(null)
    try {
      await deleteMutation.mutateAsync(deleteLocation.id)
      await locationsQuery.refetch()
      setDeleteLocation(null)
      toast.showToast({
        title: 'Pending request removed',
        description: `${deleteLocation.name} is no longer awaiting review.`,
        tone: 'success',
      })
    } catch (error) {
      setDeleteError(errorMessage(error, 'The pending proposal could not be removed.'))
    }
  }

  async function submitExtension(locationId: number, dateTime: string, reason: string) {
    await extensionMutation.mutateAsync({ locationId, dateTime, reason })
    await locationsQuery.refetch()
    toast.showToast({
      title: 'Extension request sent',
      description: 'Your work-location extension is waiting for review.',
      tone: 'success',
    })
    setExtensionLocation(null)
  }

  const pageCount = Math.max(1, Math.ceil((historyQuery.data?.count ?? 0) / PAGE_SIZE))
  const locationStatus = locationsQuery.data?.attendance_location_status
  const faceReady = Boolean(statusQuery.data?.biometric_enabled && statusQuery.data?.has_face)
  const today = todayQuery.data
  const faceControlLabel = statusQuery.isError
    ? 'Retry'
    : statusQuery.isPending
      ? 'Checking…'
      : faceReady
        ? 'Ready'
        : 'Needs setup'
  const faceControlTone = statusQuery.isError
    ? 'neutral'
    : statusQuery.isPending
      ? 'info'
      : faceReady
        ? 'success'
        : 'warning'
  const locationControlLabel = !canLocationRead
    ? canProposeLocation
      ? 'Submit request'
      : 'Access unavailable'
    : locationsQuery.isError
      ? 'Retry'
      : locationsQuery.isPending
        ? 'Checking…'
        : locationStatus === 'ready'
          ? 'Ready'
          : locationStatus === 'pending'
            ? 'Awaiting review'
            : canProposeLocation
              ? 'Needs setup'
              : 'Check status'
  const locationControlTone =
    !canLocationRead || locationsQuery.isError
      ? 'neutral'
      : locationsQuery.isPending || locationStatus === 'pending'
        ? 'info'
        : locationStatus === 'ready'
          ? 'success'
          : 'warning'
  const clockReady = Boolean(
    today?.next_action &&
    faceReady &&
    !todayQuery.isError &&
    !statusQuery.isError &&
    !locationsQuery.isError &&
    canLocationRead &&
    locationStatus === 'ready' &&
    canVerifyLocation,
  )
  const setupAction = todayQuery.isError
    ? {
        label: 'Retry today’s status',
        action: () => void todayQuery.refetch(),
        icon: <Clock3 className="size-4" />,
      }
    : statusQuery.isError
      ? {
          label: 'Check face status',
          action: () => void statusQuery.refetch(),
          icon: <Camera className="size-4" />,
        }
      : !faceReady
        ? { label: 'Register face', action: openFaceSetup, icon: <Camera className="size-4" /> }
        : !canLocationRead && canProposeLocation
          ? {
              label: 'Submit work location',
              action: () => openLocationSetup(),
              icon: <MapPin className="size-4" />,
            }
          : !canLocationRead || (locationsQuery.isError && !locationsQuery.data)
            ? {
                label: 'Check location status',
                action: focusLocations,
                icon: <MapPin className="size-4" />,
              }
            : locationStatus === 'setup_required' && canProposeLocation
              ? {
                  label: 'Submit work location',
                  action: () => openLocationSetup(),
                  icon: <MapPin className="size-4" />,
                }
              : locationStatus !== 'ready' || !canVerifyLocation
                ? {
                    label: 'Check location status',
                    action: focusLocations,
                    icon: <MapPin className="size-4" />,
                  }
                : null
  const stateLabel =
    today?.state === 'clocked_in'
      ? 'Clocked in'
      : today?.state === 'clocked_out'
        ? 'Shift complete'
        : 'Not clocked in'
  const stateTone =
    today?.state === 'clocked_in'
      ? ('info' as const)
      : today?.state === 'clocked_out'
        ? ('success' as const)
        : ('neutral' as const)

  if (sessionQuery.isPending)
    return (
      <PageLayout title="Attendance" subtitle="Your attendance and clocking record.">
        <Card className="space-y-4" aria-busy="true" aria-label="Loading attendance">
          <Skeleton variant="title" />
          <Skeleton variant="row" />
          <Skeleton variant="row" />
        </Card>
      </PageLayout>
    )
  if (sessionQuery.isError || !session)
    return (
      <PageLayout title="Attendance" subtitle="Your attendance and clocking record.">
        <Card>
          <ErrorState
            title="Your access could not be confirmed"
            description="Reload the page and try again."
            error={sessionQuery.error}
          />
        </Card>
      </PageLayout>
    )
  if (!canRead)
    return (
      <PageLayout title="Attendance" subtitle="Your attendance and clocking record.">
        <Card>
          <ErrorState
            title="You can’t view your attendance"
            description="Your account needs attendance list or list-own access."
            error={sessionQuery.error}
          />
        </Card>
      </PageLayout>
    )

  return (
    <PageLayout
      title="Attendance"
      subtitle="Clock in and review your attendance record."
      leading={<CalendarDays className="size-[18px]" aria-hidden="true" />}
      actions={
        <div className="tablet:max-w-md grid w-full grid-cols-2 gap-2">
          <StatusControl
            icon={faceReady ? ShieldCheck : Camera}
            title="Face verification"
            compactTitle="Face"
            label={faceControlLabel}
            tone={faceControlTone}
            disabled={statusQuery.isPending}
            onClick={() => {
              if (statusQuery.isPending) return
              if (statusQuery.isError && !statusQuery.data) void statusQuery.refetch()
              else openFaceSetup()
            }}
          />
          <StatusControl
            icon={MapPin}
            title="Work location"
            compactTitle="Location"
            label={locationControlLabel}
            tone={locationControlTone}
            disabled={locationsQuery.isPending || (!canLocationRead && !canProposeLocation)}
            onClick={() => {
              if (!canLocationRead && canProposeLocation) openLocationSetup()
              else if (locationsQuery.isError && !locationsQuery.data) void locationsQuery.refetch()
              else focusLocations()
            }}
          />
        </div>
      }
      contentClassName="space-y-5"
    >
      <section aria-labelledby="summary-heading" className="space-y-2.5">
        <div>
          <h2 id="summary-heading" className="text-h3 text-text-primary font-semibold">
            Month to date
          </h2>
          <p className="text-caption text-text-secondary mt-1 leading-snug">
            {summaryQuery.data
              ? `${formatDate(summaryQuery.data.period_start, { month: 'long' })} ${new Date(`${summaryQuery.data.period_start}T12:00:00`).getFullYear()}`
              : 'Current month'}
            {' · '}
            <span className="phone:hidden">
              Required workdays due so far; excludes weekends, approved leave and closures. Today
              counts after your first clock-in.
            </span>
            <span className="phone:inline hidden">
              Due workdays only; today counts after clock-in.
            </span>
          </p>
        </div>
        {summaryQuery.isPending ? (
          <div className="desktop:grid-cols-4 grid grid-cols-2 gap-2" aria-busy="true">
            {Array.from({ length: 4 }, (_, index) => (
              <Skeleton key={index} className="h-[4.5rem]" />
            ))}
          </div>
        ) : summaryQuery.isError && !summaryQuery.data ? (
          <SummaryUnavailable
            description="Month-to-date attendance figures could not be loaded."
            onRetry={() => void summaryQuery.refetch()}
          />
        ) : summaryQuery.data ? (
          <div className="desktop:grid-cols-4 grid grid-cols-2 gap-2">
            <SummaryMetric
              label="Attendance rate"
              value={
                summaryQuery.data.attendance_rate_percent == null
                  ? '—'
                  : `${summaryQuery.data.attendance_rate_percent}%`
              }
              icon={CalendarDays}
              tone="text-primary"
            />
            <SummaryMetric
              label="Workdays attended"
              value={`${summaryQuery.data.attended_workdays} / ${summaryQuery.data.required_workdays}`}
              icon={CheckCircle2}
              tone="text-success-foreground"
              detail="Required days due"
            />
            <SummaryMetric
              label="On-time arrivals"
              value={`${summaryQuery.data.on_time_arrivals} / ${summaryQuery.data.required_arrivals}`}
              icon={Clock3}
              tone="text-info-foreground"
            />
            <SummaryMetric
              label="Time recorded"
              value={formatDuration(summaryQuery.data.recorded_minutes)}
              icon={FileClock}
              tone="text-primary"
            />
          </div>
        ) : null}
      </section>

      <section aria-labelledby="today-attendance-heading" className="space-y-3">
        <h2 id="today-attendance-heading" className="text-h3 text-text-primary font-semibold">
          Today
        </h2>
        {todayQuery.isPending ? (
          <Card className="space-y-3" aria-busy="true">
            <Skeleton variant="title" />
            <Skeleton variant="row" />
          </Card>
        ) : todayQuery.isError && !today ? (
          <Card>
            <SectionErrorState
              description="Today’s attendance status could not load."
              error={todayQuery.error}
              onRetry={() => void todayQuery.refetch()}
            />
          </Card>
        ) : today ? (
          <Card className="tablet:p-6 space-y-4">
            <LiveClock serverTimeOffset={serverTimeOffset} />
            <div className="border-border-subtle border-t" aria-hidden="true" />
            <div className="flex flex-wrap items-start justify-between gap-4">
              <div className="flex min-w-0 items-center gap-3">
                <span
                  className={`rounded-control flex size-12 shrink-0 items-center justify-center ${today.state === 'clocked_out' ? 'bg-success-subtle text-success-foreground' : today.state === 'clocked_in' ? 'bg-info-subtle text-info-foreground' : 'bg-primary-subtle text-primary'}`}
                >
                  <Clock3 className="size-6" aria-hidden="true" />
                </span>
                <div>
                  <p className="text-h3 text-text-primary font-semibold">{stateLabel}</p>
                  <p className="text-body-sm text-text-secondary mt-0.5">
                    {today.day_policy?.label ?? 'Attendance status for today'}
                  </p>
                </div>
              </div>
              <StatusChip label={stateLabel} tone={stateTone} />
            </div>
            {today.day_policy?.reason ? (
              <p className="text-caption text-text-secondary">{today.day_policy.reason}</p>
            ) : null}
            {todayQuery.isError && !clockFlowOpen ? (
              <Alert tone="warning" title="Showing the last confirmed attendance status">
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <span>
                    Today’s latest status refresh failed. Clocking is paused until it can be
                    checked.
                  </span>
                  <Button variant="outline" size="sm" onClick={() => void todayQuery.refetch()}>
                    Retry
                  </Button>
                </div>
              </Alert>
            ) : null}
            <div className="tablet:gap-3 grid grid-cols-2 gap-2.5">
              <ClockTimeCard
                icon={LogIn}
                label="Clock in"
                value={formatTime(today.clock_in?.timestamp)}
                tone="success"
              />
              <ClockTimeCard
                icon={LogOut}
                label="Clock out"
                value={formatTime(today.clock_out?.timestamp)}
                tone="info"
              />
            </div>
            {today.next_action ? (
              <div className="border-border-subtle tablet:flex-row tablet:items-center tablet:justify-between flex flex-col gap-3 border-t pt-4">
                <p className="text-caption text-text-secondary flex min-w-0 items-center gap-2">
                  <CalendarDays className="size-4 shrink-0" aria-hidden="true" />
                  <span>
                    {today.day_policy?.required
                      ? 'Attendance is expected today.'
                      : 'Attendance is optional today; you can still record it.'}
                  </span>
                </p>
                {clockReady ? (
                  <Button
                    onClick={() => void startClock()}
                    isLoading={clockMutation.isPending || preparingClock}
                    leadingIcon={<Fingerprint className="size-4" aria-hidden="true" />}
                    className="tablet:w-auto w-full"
                  >
                    {today.next_action === 'clock_in' ? 'Clock in' : 'Clock out'}
                  </Button>
                ) : setupAction ? (
                  <Button
                    variant="outline"
                    disabled={statusQuery.isPending || locationsQuery.isPending}
                    onClick={setupAction.action}
                    leadingIcon={setupAction.icon}
                    className="tablet:w-auto w-full"
                  >
                    {setupAction.label}
                  </Button>
                ) : (
                  <span className="text-caption text-text-secondary" role="status">
                    Checking clocking requirements…
                  </span>
                )}
              </div>
            ) : null}
          </Card>
        ) : null}
      </section>

      {canLocationRead || canProposeLocation ? (
        <section
          id="work-locations"
          aria-labelledby="locations-heading"
          className="scroll-mt-28 space-y-3"
        >
          <div className="tablet:flex-row tablet:items-center flex flex-col gap-3">
            <div className="flex min-w-0 flex-1 items-start gap-3">
              <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
                <MapPin className="size-5" aria-hidden="true" />
              </span>
              <div className="min-w-0">
                <h2 id="locations-heading" className="text-h3 text-text-primary font-semibold">
                  Work locations
                </h2>
                <p className="text-body-sm text-text-secondary mt-1">
                  Approved locations let you clock in within their boundary.
                </p>
              </div>
            </div>
            {canProposeLocation ? (
              <Button
                variant="outline"
                size="sm"
                onClick={() => openLocationSetup()}
                leadingIcon={<MapPin className="size-4" />}
                className="tablet:w-auto w-full"
              >
                Register work location
              </Button>
            ) : null}
          </div>
          {locationsQuery.isError && locationsQuery.data ? (
            <Alert tone="warning" title="Showing the last confirmed location status">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <span>The latest work-location refresh failed.</span>
                <Button variant="outline" size="sm" onClick={() => void locationsQuery.refetch()}>
                  Retry
                </Button>
              </div>
            </Alert>
          ) : null}
          {locationsQuery.isError && !locationsQuery.data ? (
            <Card>
              <SectionErrorState
                description="Work locations could not load."
                error={locationsQuery.error}
                onRetry={() => void locationsQuery.refetch()}
              />
            </Card>
          ) : locationsQuery.isPending && canLocationRead ? (
            <Card className="space-y-3" aria-busy="true">
              {Array.from({ length: 2 }, (_, index) => (
                <Skeleton key={index} variant="row" />
              ))}
            </Card>
          ) : locationsQuery.data?.locations.length ? (
            <div className="space-y-2">
              {locationsQuery.data.locations.map((location) => (
                <LocationCard
                  key={location.id}
                  location={location}
                  canDelete={canDeleteLocation}
                  canExtend={canExtendLocation}
                  canPropose={canProposeLocation}
                  onDelete={(location) => {
                    setDeleteError(null)
                    setDeleteLocation(location)
                  }}
                  onExtend={setExtensionLocation}
                  onResubmit={(location) => openLocationSetup(location.id)}
                  deleting={deleteMutation.isPending && deleteLocation?.id === location.id}
                />
              ))}
            </div>
          ) : canLocationRead ? (
            <Card>
              <EmptyState
                title="No work locations yet"
                description="Register your work location. It can be used for attendance after it is approved."
                icon={<MapPin className="size-6" />}
                action={
                  canProposeLocation ? (
                    <Button
                      onClick={() => openLocationSetup()}
                      leadingIcon={<MapPin className="size-4" />}
                    >
                      Register work location
                    </Button>
                  ) : undefined
                }
              />
            </Card>
          ) : (
            <Card>
              <p className="text-body-sm text-text-secondary">
                Your account can submit work locations, but cannot view their review status.
              </p>
            </Card>
          )}
        </section>
      ) : null}

      <section aria-labelledby="history-heading" className="space-y-3">
        <div>
          <h2 id="history-heading" className="text-h3 text-text-primary font-semibold">
            Attendance history
          </h2>
          <p className="text-body-sm text-text-secondary mt-1">
            Clock-in and clock-out records for your account.
          </p>
        </div>
        <Card className="space-y-3">
          <div className="grid grid-cols-2 gap-3">
            <FormControl id="attendance-from" label="From date" className="min-w-0">
              <DatePickerField
                value={search.dateFrom}
                onValueChange={(dateFrom) => updateSearch({ dateFrom, page: 1 })}
                max={search.dateTo || undefined}
                placeholder="Start date"
              />
            </FormControl>
            <FormControl id="attendance-to" label="To date" className="min-w-0">
              <DatePickerField
                value={search.dateTo}
                onValueChange={(dateTo) => updateSearch({ dateTo, page: 1 })}
                min={search.dateFrom || undefined}
                placeholder="End date"
              />
            </FormControl>
          </div>
          <div className="border-border-subtle flex flex-wrap items-center justify-between gap-3 border-t pt-3">
            <span className="text-caption text-text-secondary inline-flex items-center gap-2">
              <FileClock className="size-4" aria-hidden="true" />
              {historyQuery.data
                ? formatRecordCount(historyQuery.data.count)
                : 'Attendance records'}
            </span>
            <Button
              variant="outline"
              size="sm"
              onClick={() => updateSearch({ dateFrom: '', dateTo: '', page: 1 })}
              disabled={!search.dateFrom && !search.dateTo}
              leadingIcon={<Eraser className="size-4" />}
            >
              Clear filters
            </Button>
          </div>
        </Card>
        {historyQuery.isError && historyQuery.data ? (
          <Alert tone="warning" title="Showing saved history">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <span>The latest history refresh failed.</span>
              <Button variant="outline" size="sm" onClick={() => void historyQuery.refetch()}>
                Retry
              </Button>
            </div>
          </Alert>
        ) : null}
        {historyQuery.isPending ? (
          <Card className="space-y-3" aria-busy="true">
            {Array.from({ length: 4 }, (_, index) => (
              <Skeleton key={index} variant="row" />
            ))}
          </Card>
        ) : historyQuery.isError && !historyQuery.data ? (
          <Card>
            <SectionErrorState
              description="Attendance history could not load."
              error={historyQuery.error}
              onRetry={() => void historyQuery.refetch()}
            />
          </Card>
        ) : historyQuery.data?.items.length ? (
          <Card className="overflow-hidden p-0">
            <div className="bg-surface-muted text-caption text-text-secondary border-border-subtle desktop:grid hidden grid-cols-[minmax(9rem,1fr)_minmax(8rem,.8fr)_minmax(11rem,1.2fr)_minmax(8rem,.8fr)] gap-4 border-b px-5 py-3 font-semibold">
              <span>Date and time</span>
              <span>Action</span>
              <span>Location</span>
              <span>Method</span>
            </div>
            <div className="divide-border-subtle divide-y">
              {historyQuery.data.items.map((record) => (
                <AttendanceHistoryRow key={record.id} record={record} />
              ))}
            </div>
            <HistoryPagination
              page={search.page}
              pages={pageCount}
              total={historyQuery.data.count}
              onPage={(page) => updateSearch({ page })}
            />
          </Card>
        ) : (
          <Card>
            <EmptyState
              title={
                search.dateFrom || search.dateTo
                  ? 'No records in this date range'
                  : 'No attendance records yet'
              }
              description={
                search.dateFrom || search.dateTo
                  ? 'Change or clear the dates to see other records.'
                  : 'Your clock-in and clock-out history will appear here.'
              }
              icon={<FileClock className="size-6" />}
              action={
                search.dateFrom || search.dateTo ? (
                  <Button
                    variant="outline"
                    onClick={() => updateSearch({ dateFrom: '', dateTo: '', page: 1 })}
                  >
                    Clear dates
                  </Button>
                ) : undefined
              }
            />
          </Card>
        )}
      </section>

      <Dialog
        open={clockFlowOpen}
        onOpenChange={(open) => {
          if (!open) closeClockFlow()
        }}
        title={clockFlowAction === 'clock_out' ? 'Prepare to clock out' : 'Prepare to clock in'}
        description="We’ll confirm today’s attendance, verify your approved work location and then complete the face check."
        size="md"
        fitContent
        footer={
          <>
            <Button variant="outline" onClick={closeClockFlow}>
              {preparingClock ? 'Cancel' : 'Close'}
            </Button>
            {clockFlowRecovery ? (
              <Button onClick={continueClockFlowRecovery}>
                {clockFlowRecovery === 'face'
                  ? 'Register face'
                  : clockFlowRecovery === 'location'
                    ? 'Submit work location'
                    : 'View locations'}
              </Button>
            ) : clockFlowCanRetry && actionError && clockFlowStage !== 'gps' ? (
              <Button
                onClick={() => void startClock()}
                leadingIcon={<RotateCw className="size-4" aria-hidden="true" />}
              >
                Try again
              </Button>
            ) : null}
          </>
        }
      >
        {clockFlowStage === 'gps' ? (
          <div className="space-y-3" aria-live="polite" aria-busy={clockGpsScanning}>
            <GpsCapturePanel
              permissionState={clockGpsPermission}
              scanning={clockGpsScanning}
              bestCoordinates={clockGpsScan.bestCoordinates}
              latestAccuracyMeters={clockGpsScan.latestAccuracyMeters}
              elapsedSeconds={Math.floor(clockGpsScan.elapsedMs / 1000)}
              sampleCount={clockGpsScan.sampleCount}
              hasPreviousScan={clockGpsScan.phase !== 'preparing'}
              maxAccuracyMeters={30}
              allowBestSelection={!clockLocationInvalid}
              error={actionError}
              onCapture={() => void scanClockGps(clockFlowAttemptRef.current)}
              onUseBest={continueWithBestClockLocation}
              onCancel={() => clockGeoSessionRef.current?.cancel()}
            />
            <p className="text-caption text-text-secondary flex items-center gap-2">
              <Fingerprint className="size-4 shrink-0" aria-hidden="true" />
              Once the work area is confirmed, the guided face check opens to finish clocking.
            </p>
          </div>
        ) : preparingClock ? (
          <div className="space-y-4" aria-live="polite" aria-busy="true">
            <div className="bg-primary-subtle/60 border-primary/15 rounded-control flex items-start gap-3 border p-4">
              <span className="bg-surface text-primary rounded-control shadow-elevation-sm flex size-10 shrink-0 items-center justify-center">
                {clockFlowStage === 'refreshing' ? (
                  <LoaderCircle className="size-5 animate-spin" aria-hidden="true" />
                ) : (
                  <ShieldCheck className="size-5" aria-hidden="true" />
                )}
              </span>
              <div className="min-w-0 flex-1">
                <p className="text-label text-text-primary font-semibold">
                  {clockFlowStage === 'refreshing'
                    ? 'Checking today’s attendance'
                    : 'Verifying the approved work area'}
                </p>
                <p className="text-caption text-text-secondary mt-1">
                  {clockFlowStage === 'refreshing'
                    ? 'We’ll confirm the next clock action and setup status first.'
                    : 'Your position is precise enough. BOMACH is checking it against your approved location.'}
                </p>
              </div>
            </div>
            <div className="tablet:grid-cols-3 grid gap-2">
              {[
                {
                  key: 'refreshing',
                  label: 'Attendance',
                  detail: 'Confirm action',
                  icon: Clock3,
                },
                { key: 'gps', label: 'GPS check', detail: 'Live location scan', icon: MapPin },
                {
                  key: 'verifying',
                  label: 'Work area',
                  detail: 'Server verified',
                  icon: ShieldCheck,
                },
              ].map((step) => {
                const active = step.key === clockFlowStage
                const completed = clockFlowStage === 'verifying' && step.key !== 'verifying'
                const StepIcon = completed ? CheckCircle2 : active ? LoaderCircle : step.icon
                return (
                  <div
                    key={step.key}
                    className={`border-border-subtle rounded-control flex min-w-0 items-start gap-2.5 border p-3 ${active ? 'bg-primary-subtle/50 border-primary/25' : 'bg-surface'}`}
                  >
                    <span
                      className={`flex size-8 shrink-0 items-center justify-center rounded-full ${completed ? 'bg-success-subtle text-success-foreground' : active ? 'bg-primary-subtle text-primary' : 'bg-surface-muted text-text-muted'}`}
                    >
                      <StepIcon
                        className={`size-4 ${active ? 'animate-spin' : ''}`}
                        aria-hidden="true"
                      />
                    </span>
                    <span className="min-w-0">
                      <span className="text-caption text-text-primary block font-semibold">
                        {step.label}
                      </span>
                      <span className="text-caption text-text-secondary block">{step.detail}</span>
                    </span>
                  </div>
                )
              })}
            </div>
          </div>
        ) : actionError ? (
          <Alert tone="warning" title="Clock action not started" role="alert">
            {actionError}
          </Alert>
        ) : null}
      </Dialog>

      <FaceCaptureDialog
        open={cameraMode}
        onOpenChange={(open) => {
          if (!open) {
            setCameraMode(false)
            setClockCoordinates(null)
          }
        }}
        title={today?.next_action === 'clock_out' ? 'Verify to clock out' : 'Verify to clock in'}
        description="Complete the guided face check to securely record attendance."
        busy={clockMutation.isPending}
        actionLabel="Verify and record"
        onCapture={handleFaceCapture}
      />
      <ExtensionDialog
        key={extensionLocation?.id ?? 'closed'}
        location={extensionLocation}
        open={Boolean(extensionLocation)}
        onOpenChange={(open) => {
          if (!open) setExtensionLocation(null)
        }}
        busy={extensionMutation.isPending}
        onSave={submitExtension}
      />
      <Dialog
        open={Boolean(deleteLocation)}
        onOpenChange={(open) => {
          if (!open) setDeleteLocation(null)
          else setDeleteError(null)
        }}
        title="Remove this pending proposal?"
        description={deleteLocation?.name}
        size="sm"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button
              variant="outline"
              onClick={() => setDeleteLocation(null)}
              disabled={deleteMutation.isPending}
            >
              Keep proposal
            </Button>
            <Button
              variant="danger"
              onClick={() => void confirmDeleteLocation()}
              isLoading={deleteMutation.isPending}
              leadingIcon={<Trash2 className="size-4" />}
            >
              Remove proposal
            </Button>
          </>
        }
      >
        {deleteError ? (
          <Alert tone="danger" title="Proposal not removed">
            {deleteError}
          </Alert>
        ) : null}
        <p className="text-body-sm text-text-secondary mt-3">
          This removes only your pending location proposal. Approved or rejected locations cannot be
          removed here.
        </p>
      </Dialog>
    </PageLayout>
  )
}
