import { afterEach, describe, expect, it, vi } from 'vitest'

import { readAccurateGeoPosition } from './attendance.api'

function mockGeolocation(implementation: Geolocation['watchPosition']) {
  const clearWatch = vi.fn()
  Object.defineProperty(navigator, 'geolocation', {
    configurable: true,
    value: { watchPosition: implementation, clearWatch },
  })
  return clearWatch
}

function grantLocationPermission() {
  Object.defineProperty(navigator, 'permissions', {
    configurable: true,
    value: { query: vi.fn().mockResolvedValue({ state: 'granted' }) },
  })
}

describe('readAccurateGeoPosition', () => {
  afterEach(() => {
    vi.useRealTimers()
    vi.restoreAllMocks()
  })

  it('waits for a GPS fix at or below the requested accuracy and stops watching', async () => {
    grantLocationPermission()
    let reportPosition: PositionCallback | undefined
    let watcherStarted!: () => void
    const watching = new Promise<void>((resolve) => {
      watcherStarted = resolve
    })
    const clearWatch = mockGeolocation(((success) => {
      reportPosition = success
      watcherStarted()
      return 17
    }) as Geolocation['watchPosition'])

    const position = readAccurateGeoPosition(30, 2_000)
    await watching
    reportPosition?.({
      coords: { latitude: 6.45, longitude: 3.4, accuracy: 48 } as GeolocationCoordinates,
      timestamp: Date.now(),
    } as GeolocationPosition)
    reportPosition?.({
      coords: { latitude: 6.45, longitude: 3.4, accuracy: 18 } as GeolocationCoordinates,
      timestamp: Date.now(),
    } as GeolocationPosition)

    await expect(position).resolves.toEqual({
      latitude: 6.45,
      longitude: 3.4,
      accuracy_meters: 18,
    })
    expect(clearWatch).toHaveBeenCalledWith(17)
  })

  it('explains when GPS never reaches the allowed accuracy', async () => {
    vi.useFakeTimers()
    grantLocationPermission()
    let reportPosition: PositionCallback | undefined
    let watcherStarted!: () => void
    const watching = new Promise<void>((resolve) => {
      watcherStarted = resolve
    })
    mockGeolocation(((success) => {
      reportPosition = success
      watcherStarted()
      return 23
    }) as Geolocation['watchPosition'])

    const position = readAccurateGeoPosition(30, 100)
    const rejected = expect(position).rejects.toThrow('GPS accuracy is about 46 m')
    await watching
    reportPosition?.({
      coords: { latitude: 6.45, longitude: 3.4, accuracy: 46 } as GeolocationCoordinates,
      timestamp: Date.now(),
    } as GeolocationPosition)
    await vi.advanceTimersByTimeAsync(100)
    await rejected
  })

  it('returns an actionable message when browser location permission is denied', async () => {
    mockGeolocation(((_success, error) => {
      queueMicrotask(() =>
        error?.({
          code: 1,
          message: 'denied',
          PERMISSION_DENIED: 1,
          POSITION_UNAVAILABLE: 2,
          TIMEOUT: 3,
        } as GeolocationPositionError),
      )
      return 31
    }) as Geolocation['watchPosition'])

    await expect(readAccurateGeoPosition()).rejects.toThrow(
      'Location permission was denied. Allow location access in your browser settings, then retry.',
    )
  })
})
