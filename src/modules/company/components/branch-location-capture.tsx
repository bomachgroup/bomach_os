import { useEffect, useRef, useState } from 'react'
import { RotateCcw } from 'lucide-react'

import {
  startGeoPositionScan,
  type Coordinates,
  type GeoPositionScanSession,
  type GeoPositionScanUpdate,
} from '@/modules/attendance/attendance.api'
import { GpsCapturePanel } from '@/modules/attendance/components/gps-capture-panel'
import {
  getBrowserPermissionState,
  type BrowserPermissionState,
} from '@/modules/attendance/browser-permissions'
import { Button } from '@/shared/ui/button'
import { FormControl, TextInput } from '@/shared/ui/form-control'

const MAX_BRANCH_GPS_ACCURACY_METERS = 30

const initialScan: GeoPositionScanUpdate = {
  phase: 'settled',
  bestCoordinates: null,
  latestAccuracyMeters: null,
  elapsedMs: 0,
  sampleCount: 0,
}

export function BranchLocationCapture({
  idPrefix,
  active = true,
  latitude,
  longitude,
  latitudeError,
  longitudeError,
  onClear,
  onLatitudeChange,
  onLongitudeChange,
}: {
  idPrefix: string
  active?: boolean
  latitude: string
  longitude: string
  latitudeError?: string
  longitudeError?: string
  onClear?: () => void
  onLatitudeChange: (value: string) => void
  onLongitudeChange: (value: string) => void
}) {
  const scanSessionRef = useRef<GeoPositionScanSession | null>(null)
  const isMountedRef = useRef(false)
  const [permissionState, setPermissionState] = useState<BrowserPermissionState | 'checking'>(
    'checking',
  )
  const [scan, setScan] = useState(initialScan)
  const [scanning, setScanning] = useState(false)
  const [capturedCoordinates, setCapturedCoordinates] = useState<Coordinates | null>(null)
  const [scanError, setScanError] = useState<string | null>(null)

  useEffect(() => {
    isMountedRef.current = true
    let isMounted = true
    if (active) {
      void getBrowserPermissionState('geolocation').then((state) => {
        if (isMounted) setPermissionState(state)
      })
    }
    return () => {
      isMounted = false
      isMountedRef.current = false
      scanSessionRef.current?.cancel()
    }
  }, [active])

  function applyCoordinates(coordinates: Coordinates) {
    const nextLatitude = String(Number(coordinates.latitude.toFixed(6)))
    const nextLongitude = String(Number(coordinates.longitude.toFixed(6)))
    setCapturedCoordinates(coordinates)
    setScanError(null)
    onLatitudeChange(nextLatitude)
    onLongitudeChange(nextLongitude)
  }

  async function startScan() {
    scanSessionRef.current?.cancel()
    scanSessionRef.current = null
    setScanError(null)
    setCapturedCoordinates(null)
    setScan({
      phase: 'preparing',
      bestCoordinates: null,
      latestAccuracyMeters: null,
      elapsedMs: 0,
      sampleCount: 0,
    })
    setScanning(true)

    const session = startGeoPositionScan(
      { maxAccuracyMeters: MAX_BRANCH_GPS_ACCURACY_METERS, autoAcceptAccuracyMeters: 0 },
      (update) => {
        setScan(update)
        const best = update.bestCoordinates
        if (best && best.accuracy_meters <= MAX_BRANCH_GPS_ACCURACY_METERS) {
          scanSessionRef.current?.acceptBest()
        }
      },
    )
    scanSessionRef.current = session

    try {
      const coordinates = await session.result
      applyCoordinates(coordinates)
      setPermissionState(await getBrowserPermissionState('geolocation'))
    } catch (error) {
      const cancelled = error instanceof Error && error.message === 'LOCATION_SCAN_CANCELLED'
      if (!cancelled) {
        setScanError(
          error instanceof Error
            ? error.message
            : 'GPS could not confirm the branch location. Check browser location access and retry.',
        )
        void getBrowserPermissionState('geolocation').then(setPermissionState)
      }
    } finally {
      if (scanSessionRef.current === session) {
        scanSessionRef.current = null
        if (isMountedRef.current) setScanning(false)
      }
    }
  }

  function cancelScan() {
    scanSessionRef.current?.cancel()
  }

  function useBestCoordinates() {
    const best = scan.bestCoordinates
    if (!best || best.accuracy_meters > MAX_BRANCH_GPS_ACCURACY_METERS) return
    if (!scanSessionRef.current?.acceptBest()) applyCoordinates(best)
  }

  function changeLatitude(value: string) {
    scanSessionRef.current?.cancel()
    scanSessionRef.current = null
    setScanning(false)
    setScan(initialScan)
    setCapturedCoordinates(null)
    setScanError(null)
    onLatitudeChange(value)
  }

  function changeLongitude(value: string) {
    scanSessionRef.current?.cancel()
    scanSessionRef.current = null
    setScanning(false)
    setScan(initialScan)
    setCapturedCoordinates(null)
    setScanError(null)
    onLongitudeChange(value)
  }

  function clearLocationPoint() {
    scanSessionRef.current?.cancel()
    scanSessionRef.current = null
    setScanning(false)
    setScan(initialScan)
    setCapturedCoordinates(null)
    setScanError(null)
    if (onClear) {
      onClear()
    } else {
      onLatitudeChange('')
      onLongitudeChange('')
    }
  }

  return (
    <div className="space-y-4">
      <GpsCapturePanel
        permissionState={permissionState}
        scanning={scanning}
        bestCoordinates={scan.bestCoordinates}
        latestAccuracyMeters={scan.latestAccuracyMeters}
        elapsedSeconds={Math.floor(scan.elapsedMs / 1000)}
        sampleCount={scan.sampleCount}
        hasPreviousScan={scan.phase !== 'preparing' && scan.sampleCount > 0}
        maxAccuracyMeters={MAX_BRANCH_GPS_ACCURACY_METERS}
        coordinates={capturedCoordinates}
        error={scanError}
        onCapture={() => void startScan()}
        onUseBest={useBestCoordinates}
        onCancel={cancelScan}
      />

      <div className="phone:grid-cols-2 grid gap-3">
        <FormControl id={`${idPrefix}-latitude`} label="Latitude" error={latitudeError}>
          <TextInput
            inputMode="decimal"
            value={latitude}
            onChange={(event) => changeLatitude(event.currentTarget.value)}
            placeholder="e.g. 9.0765"
          />
        </FormControl>
        <FormControl id={`${idPrefix}-longitude`} label="Longitude" error={longitudeError}>
          <TextInput
            inputMode="decimal"
            value={longitude}
            onChange={(event) => changeLongitude(event.currentTarget.value)}
            placeholder="e.g. 7.3986"
          />
        </FormControl>
      </div>

      {latitude || longitude ? (
        <Button
          type="button"
          variant="ghost"
          size="sm"
          onClick={clearLocationPoint}
          leadingIcon={<RotateCcw className="size-3.5" aria-hidden="true" />}
        >
          Clear location point
        </Button>
      ) : null}
    </div>
  )
}
