import { apiClient } from '@/shared/api/api-client'

import { getBrowserPermissionState } from './browser-permissions'

export interface AttendanceRecord {
  id: number
  attendance_type: 'clock_in' | 'clock_out' | string
  timestamp: string
  verification_method: string
  notes: string
  location_verified: boolean
  location_used_name: string | null
  distance_meters: number | null
}

export interface AttendanceToday {
  date: string
  state: 'clocked_in' | 'clocked_out' | 'not_clocked_in' | string
  next_action: 'clock_in' | 'clock_out' | null
  day_policy: {
    required: boolean
    reason: string | null
    label: string
    non_working_day_name: string | null
  } | null
  clock_in: AttendanceRecord | null
  clock_out: AttendanceRecord | null
}

export interface AttendanceSummary {
  period_start: string
  period_end: string
  required_workdays: number
  attended_workdays: number
  attendance_rate_percent: number | null
  required_arrivals: number
  on_time_arrivals: number
  late_arrivals: number
  approved_late_arrivals: number
  punctuality_rate_percent: number | null
  completed_shifts: number
  recorded_minutes: number
  optional_days_worked: number
}

export interface BiometricStatus {
  biometric_enabled: boolean
  has_fingerprint: boolean
  has_face: boolean
}

export interface WorkLocation {
  id: number
  name: string
  location_type: 'branch' | 'remote' | 'site' | string
  latitude: number
  longitude: number
  allowed_radius_meters: number
  branch_id: number | null
  branch_name: string | null
  status: 'pending' | 'approved' | 'rejected' | string
  rejection_reason: string
  verified_by_name: string | null
  verified_at: string | null
  expires_at: string | null
  is_active: boolean
  deactivated_at: string | null
  deactivation_reason: string
  deactivation_note: string
  is_expired: boolean
  can_be_used: boolean
  notes: string
  employee_id: number | null
  employee_name: string | null
  created_at: string
}

export interface WorkLocationList {
  locations: WorkLocation[]
  total: number
  attendance_location_status: 'ready' | 'pending' | 'setup_required' | string
}

export interface LocationVerification {
  is_valid: boolean
  location_name: string | null
  distance_meters: number | null
  nearest_location: string | null
  nearest_distance_meters: number | null
  effective_radius_meters: number | null
  user_accuracy_meters: number | null
  hint: string | null
}

export interface AttendanceHistoryPage {
  count: number
  items: AttendanceRecord[]
  limit: number
  offset: number
}

export interface Coordinates {
  latitude: number
  longitude: number
  accuracy_meters: number
}

export interface ClockInput extends Coordinates {
  biometric_data: string
  biometric_type: 'face'
  attendance_type: 'clock_in' | 'clock_out'
}

export interface WorkLocationInput extends Coordinates {
  name: string
  location_type: 'branch' | 'remote' | 'site'
  notes: string
  branch_id?: number
  expires_at?: string | null
}

export interface WorkLocationBranch {
  id: number
  branch_name: string
  branch_id: string
  city: string | null
  state: string
  office_address: string
}

const historyParams = (params: {
  limit: number
  offset: number
  dateFrom: string
  dateTo: string
}) => {
  const search = new URLSearchParams({ limit: String(params.limit), offset: String(params.offset) })
  if (params.dateFrom) search.set('date_from', params.dateFrom)
  if (params.dateTo) search.set('date_to', params.dateTo)
  return search.toString()
}

export const attendanceApi = {
  today: (signal?: AbortSignal) =>
    apiClient.get<AttendanceToday>('/biometric/attendance/today', { signal }),
  summary: (signal?: AbortSignal) =>
    apiClient.get<AttendanceSummary>('/biometric/attendance/summary', { signal }),
  biometricStatus: (signal?: AbortSignal) =>
    apiClient.get<BiometricStatus>('/biometric/status', { signal }),
  serverTimeOffset: async (signal?: AbortSignal) => {
    const { headers } = await apiClient.getWithHeaders<BiometricStatus>('/biometric/status', {
      signal,
    })
    const serverTime = headers.get('date')
    const serverTimestamp = serverTime ? Date.parse(serverTime) : Number.NaN
    return Number.isFinite(serverTimestamp) ? serverTimestamp - Date.now() : 0
  },
  history: (
    params: { limit: number; offset: number; dateFrom: string; dateTo: string },
    signal?: AbortSignal,
  ) =>
    apiClient.get<AttendanceHistoryPage>(`/biometric/attendance/history?${historyParams(params)}`, {
      signal,
    }),
  clock: (input: ClockInput) =>
    apiClient.post<{
      employee_id: number
      employee_name: string
      attendance_type: string
      timestamp: string
      location_verified: boolean
      location_used?: string | null
      distance_meters?: number | null
    }>('/biometric/clockin', input),
  enrollFace: (biometric_data: string) =>
    apiClient.post<{ biometric_enabled: boolean }>('/biometric/setup-face', { biometric_data }),
  locations: (signal?: AbortSignal) =>
    apiClient.get<WorkLocationList>('/biometric/location/whitelisted', { signal }),
  branches: (signal?: AbortSignal) =>
    apiClient.get<WorkLocationBranch[]>('/biometric/location/branches', { signal }),
  verifyLocation: (coordinates: Coordinates, signal?: AbortSignal) => {
    const search = new URLSearchParams({
      latitude: String(coordinates.latitude),
      longitude: String(coordinates.longitude),
      accuracy_meters: String(coordinates.accuracy_meters),
    })
    return apiClient.get<LocationVerification>(`/biometric/location/verify?${search}`, { signal })
  },
  proposeLocation: (input: WorkLocationInput) =>
    apiClient.post<WorkLocation>('/biometric/location/whitelisted', input),
  deletePendingLocation: (locationId: number) =>
    apiClient.delete<{ detail: string }>(`/biometric/location/whitelisted/${locationId}`),
  requestExtension: (locationId: number, requested_expires_at: string, reason: string) =>
    apiClient.post(`/biometric/location/whitelisted/${locationId}/extensions`, {
      requested_expires_at,
      reason,
    }),
}

export function readGeoPosition(): Promise<Coordinates> {
  return readAccurateGeoPosition()
}

export interface GeoCaptureProgress {
  accuracyMeters: number | null
  progressPercent: number
  secondsRemaining: number
}

export interface GeoCaptureOptions {
  /** The preferred accuracy that starts the short mobile-style settling window. */
  targetAccuracyMeters?: number
  /** Keep scanning this long after reaching the preferred accuracy. */
  settleGraceMs?: number
  onProgress?: (progress: GeoCaptureProgress) => void
}

export interface GeoPositionScanUpdate {
  phase: 'preparing' | 'started' | 'reading' | 'settled'
  bestCoordinates: Coordinates | null
  latestAccuracyMeters: number | null
  elapsedMs: number
  sampleCount: number
}

export interface GeoPositionScanSession {
  result: Promise<Coordinates>
  acceptBest: () => boolean
  cancel: () => void
}

export interface GeoPositionScanOptions {
  /** Maximum GPS accuracy that can be manually accepted. */
  maxAccuracyMeters: number
  /** Strong fixes at or below this value are accepted automatically. */
  autoAcceptAccuracyMeters?: number
}

/**
 * Keep a live browser GPS watch open like the staff mobile app. It resolves
 * automatically for a very strong fix, or the user can accept the best usable
 * fix while the scan continues. A denied site permission is detected before
 * starting the watch; a prompt state is resolved by the browser when the
 * watch begins.
 */
export function startGeoPositionScan(
  options: GeoPositionScanOptions,
  onUpdate?: (update: GeoPositionScanUpdate) => void,
): GeoPositionScanSession {
  let resolveResult!: (coordinates: Coordinates) => void
  let rejectResult!: (error: Error) => void
  const result = new Promise<Coordinates>((resolve, reject) => {
    resolveResult = resolve
    rejectResult = reject
  })
  let watchId: number | null = null
  let permissionStatus: PermissionStatus | null = null
  let fallbackTimer = 0
  let fallbackTimeout = 0
  let elapsedTimer = 0
  let settled = false
  let startedAt = 0
  let latestAccuracyMeters: number | null = null
  let bestCoordinates: Coordinates | null = null
  let sampleCount = 0
  let watchHasRead = false
  let fallbackRunning = false

  const emit = (phase: GeoPositionScanUpdate['phase']) => {
    onUpdate?.({
      phase,
      bestCoordinates,
      latestAccuracyMeters,
      elapsedMs: startedAt ? Date.now() - startedAt : 0,
      sampleCount,
    })
  }
  const cleanup = () => {
    window.clearTimeout(fallbackTimer)
    window.clearTimeout(fallbackTimeout)
    window.clearInterval(elapsedTimer)
    if (watchId !== null) navigator.geolocation?.clearWatch(watchId)
    watchId = null
    permissionStatus?.removeEventListener('change', handlePermissionChange)
    permissionStatus = null
  }
  const complete = (coordinates: Coordinates | null, error?: Error) => {
    if (settled) return
    settled = true
    cleanup()
    if (error) {
      rejectResult(error)
      return
    }
    if (!coordinates) return
    bestCoordinates = coordinates
    emit('settled')
    resolveResult(coordinates)
  }
  const cancel = () => complete(null, new Error('LOCATION_SCAN_CANCELLED'))
  const acceptBest = () => {
    if (
      !bestCoordinates ||
      bestCoordinates.accuracy_meters > options.maxAccuracyMeters ||
      settled
    ) {
      return false
    }
    complete(bestCoordinates)
    return true
  }
  const scheduleFallback = (delayMs: number) => {
    if (settled || fallbackTimer || fallbackRunning || watchHasRead) return
    fallbackTimer = window.setTimeout(() => {
      fallbackTimer = 0
      if (settled || watchHasRead || fallbackRunning || !navigator.geolocation) return
      if (fallbackTimeout) window.clearTimeout(fallbackTimeout)
      fallbackRunning = true
      navigator.geolocation.getCurrentPosition(
        (position) => {
          fallbackRunning = false
          acceptPosition(position)
        },
        (error) => {
          fallbackRunning = false
          window.clearTimeout(fallbackTimeout)
          fallbackTimeout = 0
          handleError(error, true)
        },
        { enableHighAccuracy: true, timeout: 8_000, maximumAge: 0 },
      )
      fallbackTimeout = window.setTimeout(() => {
        fallbackTimeout = 0
        fallbackRunning = false
        if (!settled && !watchHasRead) scheduleFallback(5_000)
      }, 8_100)
    }, delayMs)
  }
  const markScanStarted = () => {
    if (startedAt) return
    startedAt = Date.now()
    elapsedTimer = window.setInterval(() => emit('reading'), 1_000)
    emit('started')
    scheduleFallback(3_000)
  }
  const handlePermissionChange = () => {
    if (permissionStatus?.state === 'granted') {
      markScanStarted()
    } else if (permissionStatus?.state === 'denied') {
      complete(
        null,
        new Error(
          'Location permission was denied. Allow location access in your browser settings, then try again.',
        ),
      )
    }
  }
  const acceptPosition = (position: GeolocationPosition) => {
    if (settled) return
    // A location callback means the browser permission has been granted, even
    // in browsers without a usable Permissions API change event.
    markScanStarted()
    const { accuracy, latitude, longitude } = position.coords
    if (
      !Number.isFinite(accuracy) ||
      accuracy <= 0 ||
      !Number.isFinite(latitude) ||
      !Number.isFinite(longitude)
    ) {
      return
    }
    watchHasRead = true
    fallbackRunning = false
    window.clearTimeout(fallbackTimer)
    window.clearTimeout(fallbackTimeout)
    fallbackTimer = 0
    fallbackTimeout = 0
    latestAccuracyMeters = accuracy
    sampleCount += 1
    const coordinates = { latitude, longitude, accuracy_meters: accuracy }
    if (!bestCoordinates || accuracy < bestCoordinates.accuracy_meters) {
      bestCoordinates = coordinates
    }
    emit('reading')
    if (accuracy <= (options.autoAcceptAccuracyMeters ?? 10)) complete(coordinates)
  }
  const handleError = (error: GeolocationPositionError, fromFallback = false) => {
    if (settled) return
    if (error.code === error.PERMISSION_DENIED) {
      complete(
        null,
        new Error(
          'Location permission was denied. Allow location access in your browser settings, then try again.',
        ),
      )
      return
    }
    // A timeout or temporary unavailable reading is recoverable. Keep watching
    // and use fresh one-shot reads until the browser starts returning fixes.
    scheduleFallback(fromFallback ? 5_000 : 0)
  }

  emit('preparing')
  const begin = async () => {
    try {
      try {
        permissionStatus =
          (await navigator.permissions?.query({ name: 'geolocation' } as PermissionDescriptor)) ??
          null
      } catch {
        permissionStatus = null
      }
      const permission = permissionStatus?.state ?? (await getBrowserPermissionState('geolocation'))
      if (settled) return
      if (permission === 'denied') {
        complete(
          null,
          new Error(
            'Location access is blocked for this site. Allow it in browser site settings, then try again.',
          ),
        )
        return
      }
      if (!navigator.geolocation) {
        complete(null, new Error('Location access is not available in this browser.'))
        return
      }
      permissionStatus?.addEventListener('change', handlePermissionChange)
      if (permission === 'granted') markScanStarted()
      watchId = navigator.geolocation.watchPosition(acceptPosition, handleError, {
        enableHighAccuracy: true,
        timeout: 10_000,
        maximumAge: 0,
      })
    } catch {
      complete(
        null,
        new Error('Location access could not start. Check browser permissions and retry.'),
      )
    }
  }
  void begin()

  return { result, acceptBest, cancel }
}

export function readAccurateGeoPosition(
  maxAccuracyMeters = 30,
  timeoutMs = 20_000,
  onAccuracyUpdate?: (accuracyMeters: number) => void,
  signal?: AbortSignal,
  options?: GeoCaptureOptions,
): Promise<Coordinates> {
  return new Promise((resolve, reject) => {
    if (signal?.aborted) {
      reject(new DOMException('Location capture was cancelled.', 'AbortError'))
      return
    }
    if (!navigator.geolocation) {
      reject(new Error('Location access is not available in this browser.'))
      return
    }
    let watchId: number | null = null
    let settled = false
    let best: Coordinates | null = null
    let samples: Coordinates[] = []
    let timeout = 0
    let settleTimeout = 0
    let nextPollTimeout = 0
    let progressInterval = 0
    let startedAt = 0
    const targetAccuracyMeters = options?.targetAccuracyMeters ?? maxAccuracyMeters
    const settleGraceMs = options?.settleGraceMs ?? 0
    const abort = () => {
      if (settled) return
      settled = true
      cleanup()
      reject(new DOMException('Location capture was cancelled.', 'AbortError'))
    }
    const cleanup = () => {
      window.clearTimeout(timeout)
      window.clearTimeout(settleTimeout)
      window.clearTimeout(nextPollTimeout)
      window.clearInterval(progressInterval)
      if (watchId !== null) navigator.geolocation.clearWatch(watchId)
      signal?.removeEventListener('abort', abort)
    }
    const emitProgress = () => {
      if (!options?.onProgress) return
      const elapsed = Date.now() - startedAt
      options.onProgress({
        accuracyMeters: best?.accuracy_meters ?? null,
        progressPercent: Math.min(100, Math.round((elapsed / timeoutMs) * 100)),
        secondsRemaining: Math.max(0, Math.ceil((timeoutMs - elapsed) / 1000)),
      })
    }
    const median = (values: number[]) => {
      const ordered = [...values].sort((a, b) => a - b)
      const middle = Math.floor(ordered.length / 2)
      return ordered.length % 2 === 0
        ? (ordered[middle - 1]! + ordered[middle]!) / 2
        : ordered[middle]!
    }
    const finish = (allowBestEffort: boolean) => {
      if (settled || !best) return
      if (!allowBestEffort && best.accuracy_meters > maxAccuracyMeters) {
        settled = true
        cleanup()
        reject(
          new Error(
            `GPS accuracy is about ${Math.round(best.accuracy_meters)} m. Move near a window or outside, then retry for a fix within ${maxAccuracyMeters} m.`,
          ),
        )
        return
      }
      const bestFix = best
      const closeSamples = samples.filter(
        (sample) => sample.accuracy_meters <= Math.min(bestFix.accuracy_meters * 1.5, 40),
      )
      const sampleCluster = closeSamples.length > 0 ? closeSamples : samples
      settled = true
      cleanup()
      options?.onProgress?.({
        accuracyMeters: bestFix.accuracy_meters,
        progressPercent: 100,
        secondsRemaining: 0,
      })
      resolve({
        latitude:
          sampleCluster.length > 1
            ? median(sampleCluster.map((sample) => sample.latitude))
            : bestFix.latitude,
        longitude:
          sampleCluster.length > 1
            ? median(sampleCluster.map((sample) => sample.longitude))
            : bestFix.longitude,
        accuracy_meters:
          sampleCluster.length > 1
            ? median(sampleCluster.map((sample) => sample.accuracy_meters))
            : bestFix.accuracy_meters,
      })
    }
    const considerPosition = (position: GeolocationPosition) => {
      const { coords } = position
      if (settled || !Number.isFinite(coords.accuracy) || coords.accuracy <= 0) return
      const point: Coordinates = {
        latitude: coords.latitude,
        longitude: coords.longitude,
        accuracy_meters: coords.accuracy,
      }
      samples = [...samples, point].slice(-40)
      if (!best || point.accuracy_meters < best.accuracy_meters) {
        best = point
        onAccuracyUpdate?.(best.accuracy_meters)
        emitProgress()
      }
      if (point.accuracy_meters <= targetAccuracyMeters && !settleTimeout) {
        if (settleGraceMs > 0) {
          settleTimeout = window.setTimeout(() => finish(true), settleGraceMs)
        } else {
          finish(false)
        }
      }
    }
    signal?.addEventListener('abort', abort, { once: true })
    const beginScanning = async () => {
      try {
        const permission = await getBrowserPermissionState('geolocation')
        if (settled) return
        if (permission === 'denied') {
          settled = true
          cleanup()
          reject(
            new Error(
              'Location access is blocked for this site. Allow it in browser site settings, then try again; a saved site block cannot be overridden by the app.',
            ),
          )
          return
        }
        startedAt = Date.now()
        emitProgress()
        progressInterval = window.setInterval(emitProgress, 200)
        timeout = window.setTimeout(() => {
          if (!best) {
            settled = true
            cleanup()
            options?.onProgress?.({
              accuracyMeters: null,
              progressPercent: 100,
              secondsRemaining: 0,
            })
            reject(
              new Error('Your location took too long to determine. Move near a window and retry.'),
            )
            return
          }
          // Like the staff app, return the best available fix when the scan window ends.
          // The caller still enforces the hard maximum accuracy for this action.
          finish(Boolean(options))
        }, timeoutMs)
        if (options) {
          // The staff app uses fresh single-shot fixes in its web flow because
          // browser watchPosition implementations can stall after a timeout.
          const poll = () => {
            if (settled) return
            try {
              navigator.geolocation.getCurrentPosition(
                (position) => {
                  considerPosition(position)
                  if (!settled) nextPollTimeout = window.setTimeout(poll, 1200)
                },
                (error) => {
                  if (error.code === error.PERMISSION_DENIED) {
                    settled = true
                    cleanup()
                    reject(
                      new Error(
                        'Location permission was denied. Allow location access in your browser settings, then retry.',
                      ),
                    )
                    return
                  }
                  if (!settled) nextPollTimeout = window.setTimeout(poll, 1200)
                },
                { enableHighAccuracy: true, timeout: 6000, maximumAge: 0 },
              )
            } catch {
              if (!settled) nextPollTimeout = window.setTimeout(poll, 1200)
            }
          }
          poll()
        } else {
          watchId = navigator.geolocation.watchPosition(
            considerPosition,
            (error) => {
              if (settled || error.code === error.TIMEOUT) return
              settled = true
              cleanup()
              const message =
                error.code === error.PERMISSION_DENIED
                  ? 'Location permission was denied. Allow location access in your browser settings, then retry.'
                  : 'Your location could not be determined. Check GPS access and retry.'
              reject(new Error(message))
            },
            { enableHighAccuracy: true, timeout: timeoutMs, maximumAge: 0 },
          )
        }
      } catch {
        if (settled) return
        settled = true
        cleanup()
        reject(new Error('Location access could not start. Check browser permissions and retry.'))
      }
    }
    void beginScanning()
  })
}
