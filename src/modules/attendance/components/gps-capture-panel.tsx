import {
  Activity,
  CheckCircle2,
  Crosshair,
  Info,
  LoaderCircle,
  MapPin,
  RotateCcw,
  X,
} from 'lucide-react'

import { Button } from '@/shared/ui/button'
import { Alert } from '@/shared/ui/alert'

import type { Coordinates } from '../attendance.api'
import { permissionStateLabel, type BrowserPermissionState } from '../browser-permissions'

function formatElapsed(elapsedSeconds: number) {
  const minutes = Math.floor(elapsedSeconds / 60)
  const seconds = elapsedSeconds % 60
  return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
}

export function GpsCapturePanel({
  permissionState,
  scanning,
  bestCoordinates,
  latestAccuracyMeters,
  elapsedSeconds,
  sampleCount,
  hasPreviousScan,
  maxAccuracyMeters,
  allowBestSelection = true,
  coordinates,
  error,
  onCapture,
  onUseBest,
  onCancel,
}: {
  permissionState: BrowserPermissionState | 'checking'
  scanning: boolean
  bestCoordinates: Coordinates | null
  latestAccuracyMeters: number | null
  elapsedSeconds: number
  sampleCount: number
  hasPreviousScan?: boolean
  maxAccuracyMeters: number
  allowBestSelection?: boolean
  coordinates?: Coordinates | null
  error?: string | null
  onCapture: () => void
  onUseBest: () => void
  onCancel: () => void
}) {
  const confirmedCoordinates = coordinates ?? null
  const displayCoordinates = confirmedCoordinates ?? bestCoordinates
  const currentAccuracyMeters = latestAccuracyMeters
  const bestAccuracyMeters =
    bestCoordinates?.accuracy_meters ?? confirmedCoordinates?.accuracy_meters ?? null
  const canUseBest = Boolean(
    allowBestSelection && bestCoordinates && bestCoordinates.accuracy_meters <= maxAccuracyMeters,
  )
  const blocked = permissionState === 'denied'
  const waitingForPermission = Boolean(
    scanning &&
    elapsedSeconds === 0 &&
    sampleCount === 0 &&
    (permissionState === 'prompt' ||
      permissionState === 'unknown' ||
      permissionState === 'checking'),
  )
  const showReceptionTip = scanning && elapsedSeconds >= 15 && !canUseBest

  return (
    <section
      className="border-border-subtle bg-surface rounded-control tablet:p-5 space-y-4 border p-4"
      aria-label="GPS location capture"
    >
      <div className="flex min-w-0 items-center gap-3">
        <span
          className={`rounded-control flex size-10 shrink-0 items-center justify-center ${scanning && !waitingForPermission ? 'bg-primary-subtle text-primary' : confirmedCoordinates ? 'bg-success-subtle text-success-foreground' : 'bg-surface-muted text-primary'}`}
        >
          {scanning && !waitingForPermission ? (
            <Crosshair
              className="size-5 animate-pulse motion-reduce:animate-none"
              aria-hidden="true"
            />
          ) : confirmedCoordinates ? (
            <CheckCircle2 className="size-5" aria-hidden="true" />
          ) : (
            <MapPin className="size-5" aria-hidden="true" />
          )}
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-center justify-between gap-x-3 gap-y-2">
            <p className="text-body-sm text-text-primary font-semibold">
              {confirmedCoordinates ? 'GPS point selected' : 'GPS accuracy'}
            </p>
            <div className="flex shrink-0 items-center gap-2">
              <span
                className={`rounded-pill text-caption inline-flex items-center gap-1.5 px-2.5 py-1 font-medium ${scanning ? 'bg-primary-subtle text-primary' : permissionState === 'granted' ? 'bg-success-subtle text-success-foreground' : blocked ? 'bg-danger-subtle text-danger-foreground' : 'bg-surface-muted text-text-secondary'}`}
              >
                {scanning && !waitingForPermission ? (
                  <LoaderCircle
                    className="size-3.5 animate-spin motion-reduce:animate-none"
                    aria-hidden="true"
                  />
                ) : confirmedCoordinates ? (
                  <CheckCircle2 className="size-3.5" aria-hidden="true" />
                ) : null}
                {scanning
                  ? waitingForPermission
                    ? 'Waiting for access'
                    : 'Live GPS'
                  : confirmedCoordinates
                    ? 'Point confirmed'
                    : permissionStateLabel(permissionState)}
              </span>
              {scanning ? (
                <span
                  className="text-caption text-text-secondary tabular-nums"
                  aria-label={`Scan time ${formatElapsed(elapsedSeconds)}`}
                >
                  {formatElapsed(elapsedSeconds)}
                </span>
              ) : null}
            </div>
          </div>
          <p className="text-caption text-text-secondary mt-1">
            {scanning
              ? waitingForPermission
                ? permissionState === 'prompt'
                  ? 'Allow location access in the browser prompt to begin GPS capture.'
                  : 'Waiting for the browser to confirm location access.'
                : 'Keep still while BOMACH listens for clearer readings. You can continue with a usable fix at any time.'
              : blocked
                ? 'Location is blocked for this site. Allow it in browser site settings, then scan again.'
                : confirmedCoordinates
                  ? 'This point is confirmed. Capture again if you need to update it.'
                  : 'Location access is checked when scanning starts. Your browser asks first if permission is not set.'}
          </p>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-2">
        <div className="border-border-subtle bg-surface-muted/60 rounded-control tablet:gap-1.5 tablet:px-3 tablet:py-2.5 flex min-w-0 items-center justify-between gap-1 border px-2 py-1.5">
          <div className="text-caption text-text-secondary tablet:gap-1.5 flex min-w-0 items-center gap-1 font-medium">
            <Crosshair
              className="text-primary tablet:size-3.5 size-3 shrink-0"
              aria-hidden="true"
            />
            <span>Current</span>
          </div>
          <p
            className={`text-caption tablet:text-body-sm shrink-0 font-semibold tabular-nums ${currentAccuracyMeters === null ? 'text-text-muted' : currentAccuracyMeters <= maxAccuracyMeters ? 'text-success-foreground' : 'text-warning-foreground'}`}
          >
            {currentAccuracyMeters === null
              ? scanning
                ? 'Waiting'
                : '—'
              : `±${Math.round(currentAccuracyMeters)} m`}
          </p>
        </div>
        <div className="border-border-subtle bg-surface-muted/60 rounded-control tablet:gap-1.5 tablet:px-3 tablet:py-2.5 flex min-w-0 items-center justify-between gap-1 border px-2 py-1.5">
          <div className="text-caption text-text-secondary tablet:gap-1.5 flex min-w-0 items-center gap-1 font-medium">
            <CheckCircle2
              className="text-success-foreground tablet:size-3.5 size-3 shrink-0"
              aria-hidden="true"
            />
            <span>Best</span>
          </div>
          <p
            className={`text-caption tablet:text-body-sm shrink-0 font-semibold tabular-nums ${bestAccuracyMeters === null ? 'text-text-muted' : bestAccuracyMeters <= maxAccuracyMeters ? 'text-success-foreground' : 'text-warning-foreground'}`}
          >
            {bestAccuracyMeters === null
              ? scanning
                ? 'Waiting'
                : '—'
              : `±${Math.round(bestAccuracyMeters)} m`}
          </p>
        </div>
      </div>

      {error ? (
        <Alert tone="warning" title="Location unavailable">
          {error}
        </Alert>
      ) : null}

      <div className="border-border-subtle bg-surface-muted/70 rounded-control flex min-w-0 flex-wrap items-center justify-between gap-3 border px-3 py-2.5">
        <div className="text-caption text-text-secondary flex min-w-0 items-center gap-2">
          <Activity className="text-primary size-4 shrink-0" aria-hidden="true" />
          <span className="truncate" aria-live="polite">
            {scanning
              ? waitingForPermission
                ? 'Waiting for browser permission'
                : !elapsedSeconds && !sampleCount
                  ? 'Preparing location services'
                  : latestAccuracyMeters === null
                    ? 'Listening for GPS readings'
                    : 'Scanning for a stronger fix'
              : confirmedCoordinates
                ? 'GPS point selected'
                : bestCoordinates
                  ? 'Scan paused'
                  : 'Ready to scan'}
          </span>
        </div>
        <div className="text-caption text-text-secondary flex shrink-0 items-center gap-3 font-medium tabular-nums">
          <span>
            {sampleCount} {sampleCount === 1 ? 'reading' : 'readings'}
          </span>
        </div>
      </div>

      {displayCoordinates ? (
        <div className="bg-success-subtle/60 rounded-control flex flex-wrap items-center justify-between gap-x-4 gap-y-1 px-3 py-2.5">
          <p className="text-caption text-text-primary min-w-0 font-medium break-all tabular-nums">
            {displayCoordinates.latitude.toFixed(5)}, {displayCoordinates.longitude.toFixed(5)}
          </p>
          <p className="text-caption text-success-foreground shrink-0 font-semibold tabular-nums">
            ±{Math.round(displayCoordinates.accuracy_meters)} m
          </p>
        </div>
      ) : null}

      {showReceptionTip ? (
        <div className="bg-info-subtle/60 border-info/20 rounded-control flex items-start gap-2.5 border p-3">
          <Info className="text-info-foreground mt-0.5 size-4 shrink-0" aria-hidden="true" />
          <p className="text-caption text-text-secondary">
            Move near a window or step outside for a clearer reading. Scanning continues while GPS
            updates.
          </p>
        </div>
      ) : null}

      <div className="tablet:flex-row tablet:items-center tablet:justify-end flex flex-col-reverse gap-2">
        {scanning ? (
          <>
            {canUseBest ? (
              <>
                <Button
                  variant="outline"
                  onClick={onCancel}
                  leadingIcon={<X className="size-4" aria-hidden="true" />}
                  className="tablet:w-auto w-full shrink-0"
                >
                  Cancel scan
                </Button>
                <Button onClick={onUseBest} className="tablet:w-auto w-full shrink-0">
                  Continue with this location
                </Button>
              </>
            ) : (
              <Button
                variant="outline"
                onClick={onCancel}
                leadingIcon={<X className="size-4" aria-hidden="true" />}
                className="tablet:w-auto w-full shrink-0"
              >
                Cancel scan
              </Button>
            )}
          </>
        ) : confirmedCoordinates ? (
          <Button
            variant="outline"
            onClick={onCapture}
            leadingIcon={<RotateCcw className="size-4" aria-hidden="true" />}
            className="tablet:w-auto w-full shrink-0"
          >
            Change GPS point
          </Button>
        ) : (
          <>
            {canUseBest ? (
              <Button onClick={onUseBest} className="tablet:w-auto w-full shrink-0">
                Continue with this location
              </Button>
            ) : null}
            <Button
              variant={canUseBest ? 'outline' : 'primary'}
              onClick={onCapture}
              leadingIcon={
                blocked ? (
                  <RotateCcw className="size-4" aria-hidden="true" />
                ) : (
                  <Crosshair className="size-4" aria-hidden="true" />
                )
              }
              className="tablet:w-auto w-full shrink-0"
            >
              {blocked
                ? 'Check location access'
                : bestCoordinates || hasPreviousScan
                  ? 'Resume GPS scan'
                  : 'Start GPS scan'}
            </Button>
          </>
        )}
      </div>
    </section>
  )
}
