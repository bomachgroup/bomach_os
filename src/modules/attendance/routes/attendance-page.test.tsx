import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

const routeState = vi.hoisted(() => ({
  search: { dateFrom: '', dateTo: '', page: 1 },
  navigate: vi.fn(),
}))

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return { ...actual, useSearch: () => routeState.search, useNavigate: () => routeState.navigate }
})

import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import * as attendanceModule from '../attendance.api'
import { attendanceApi, type Coordinates, type WorkLocation } from '../attendance.api'
import { AttendancePage } from './attendance-page'

const session: AuthenticatedSession = {
  user: {
    id: 7,
    email: 'staff@example.com',
    username: 'staff',
    first_name: 'Sam',
    last_name: 'Staff',
    is_verified: true,
    created_at: '2026-01-01T00:00:00Z',
    role: null,
    permissions: {},
  },
  employee: {
    id: 23,
    user_id: 7,
    employee_id: 'EMP-007',
    username: 'staff',
    email: 'staff@example.com',
    first_name: 'Sam',
    last_name: 'Staff',
  },
  roles: [],
  permissions: { attendance: ['list_own'] },
}

function localTodayDate() {
  const today = new Date()
  return `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`
}

let queryClient: QueryClient
const showToast = vi.fn()

Object.defineProperty(HTMLDialogElement.prototype, 'showModal', {
  configurable: true,
  value(this: HTMLDialogElement) {
    this.setAttribute('open', '')
  },
})
Object.defineProperty(HTMLDialogElement.prototype, 'close', {
  configurable: true,
  value(this: HTMLDialogElement) {
    this.removeAttribute('open')
    this.dispatchEvent(new Event('close'))
  },
})

function renderPage(permissions = session.permissions) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, { ...session, permissions })
  return render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <AttendancePage />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

describe('Attendance page', () => {
  beforeEach(() => {
    routeState.search = { dateFrom: '', dateTo: '', page: 1 }
    routeState.navigate.mockReset()
    showToast.mockReset()
    vi.spyOn(attendanceApi, 'today').mockResolvedValue({
      date: '2026-10-20',
      state: 'clocked_in',
      next_action: 'clock_out',
      day_policy: { required: true, reason: null, label: 'Workday', non_working_day_name: null },
      clock_in: {
        id: 1,
        attendance_type: 'clock_in',
        timestamp: '2026-10-20T08:00:00Z',
        verification_method: 'face',
        notes: '',
        location_verified: true,
        location_used_name: 'Lagos office',
        distance_meters: 12,
      },
      clock_out: null,
    })
    vi.spyOn(attendanceApi, 'summary').mockResolvedValue({
      period_start: '2026-10-01',
      period_end: '2026-10-20',
      required_workdays: 14,
      attended_workdays: 12,
      attendance_rate_percent: 86,
      required_arrivals: 14,
      on_time_arrivals: 10,
      late_arrivals: 2,
      approved_late_arrivals: 1,
      punctuality_rate_percent: 71,
      completed_shifts: 11,
      recorded_minutes: 5430,
      optional_days_worked: 0,
    })
    vi.spyOn(attendanceApi, 'biometricStatus').mockResolvedValue({
      biometric_enabled: true,
      has_fingerprint: false,
      has_face: true,
    })
    vi.spyOn(attendanceApi, 'locations').mockResolvedValue({
      locations: [],
      total: 0,
      attendance_location_status: 'setup_required',
    })
    vi.spyOn(attendanceApi, 'history').mockResolvedValue({
      count: 1,
      limit: 10,
      offset: 0,
      items: [
        {
          id: 1,
          attendance_type: 'clock_in',
          timestamp: '2026-10-20T08:00:00Z',
          verification_method: 'face',
          notes: '',
          location_verified: true,
          location_used_name: 'Lagos office',
          distance_meters: 12,
        },
      ],
    })
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('loads today, month summary, and paginated history in the signed-in employee scope', async () => {
    const { container } = renderPage()

    expect((await screen.findAllByText('Clocked in')).length).toBeGreaterThan(0)
    expect(screen.getByText('86%')).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Refresh' })).not.toBeInTheDocument()
    await waitFor(() =>
      expect(attendanceApi.history).toHaveBeenCalledWith(
        { limit: 10, offset: 0, dateFrom: '', dateTo: '' },
        expect.any(AbortSignal),
      ),
    )
    expect(await screen.findByText('Page 1 of 1 · 1 record')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /Face verification/ })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /Work location/ })).toBeInTheDocument()
    expect(container.querySelectorAll('.attendance-readiness-row')).toHaveLength(0)
  })

  it('updates date filters in URL state and resets the history page', async () => {
    const user = userEvent.setup()
    routeState.search.page = 4
    renderPage()
    await screen.findByRole('heading', { name: 'Attendance history' })

    await user.click(screen.getByRole('button', { name: 'From date' }))
    await user.click(screen.getByRole('button', { name: 'Today' }))
    const navigation = routeState.navigate.mock.calls.at(-1)?.[0]
    expect(navigation.to).toBe('/hr/attendance')
    expect(navigation.search(routeState.search)).toMatchObject({
      dateFrom: localTodayDate(),
      page: 1,
    })
  })

  it('does not load attendance APIs without the personal attendance permission', async () => {
    renderPage({})

    expect(await screen.findByText('You can’t view your attendance')).toBeInTheDocument()
    expect(attendanceApi.today).not.toHaveBeenCalled()
    expect(attendanceApi.history).not.toHaveBeenCalled()
  })

  it('offers face setup and withholds clocking unless both face flags are ready', async () => {
    vi.spyOn(attendanceApi, 'biometricStatus').mockResolvedValue({
      biometric_enabled: false,
      has_fingerprint: false,
      has_face: true,
    })

    renderPage()

    expect(await screen.findByRole('button', { name: 'Register face' })).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Clock out' })).not.toBeInTheDocument()
  })

  it('shows clocking only when face, location, and next action are confirmed ready', async () => {
    vi.spyOn(attendanceApi, 'locations').mockResolvedValue({
      locations: [],
      total: 0,
      attendance_location_status: 'ready',
    })
    renderPage({
      attendance: ['list_own'],
      work_locations: ['list_own', 'view_own'],
    })

    expect(await screen.findByRole('button', { name: 'Clock out' })).toBeInTheDocument()
  })

  it('keeps the face verification dialog open after GPS is verified for clocking', async () => {
    const user = userEvent.setup()
    const fix: Coordinates = { latitude: 6.45, longitude: 3.4, accuracy_meters: 18 }
    vi.spyOn(attendanceApi, 'locations').mockResolvedValue({
      locations: [],
      total: 0,
      attendance_location_status: 'ready',
    })
    vi.spyOn(attendanceApi, 'verifyLocation').mockResolvedValue({
      is_valid: true,
      location_name: 'Lagos office',
      distance_meters: 12,
      nearest_location: 'Lagos office',
      nearest_distance_meters: 12,
      effective_radius_meters: 100,
      user_accuracy_meters: 18,
      hint: null,
    })
    vi.spyOn(attendanceModule, 'startGeoPositionScan').mockImplementation((_options, onUpdate) => {
      let resolveResult!: (coordinates: Coordinates) => void
      let settled = false
      const result = new Promise<Coordinates>((resolve) => {
        resolveResult = resolve
      })
      onUpdate?.({
        phase: 'reading',
        bestCoordinates: fix,
        latestAccuracyMeters: fix.accuracy_meters,
        elapsedMs: 1_200,
        sampleCount: 2,
      })
      return {
        result,
        acceptBest: () => {
          if (settled) return false
          settled = true
          resolveResult(fix)
          return true
        },
        cancel: () => {
          settled = true
        },
      }
    })

    renderPage({
      attendance: ['list_own'],
      work_locations: ['list_own', 'view_own'],
    })

    await user.click(await screen.findByRole('button', { name: 'Clock out' }))
    expect(await screen.findByRole('dialog', { name: 'Prepare to clock out' })).toBeInTheDocument()
    await user.click(await screen.findByRole('button', { name: 'Continue with this location' }))

    expect(await screen.findByRole('dialog', { name: 'Verify to clock out' })).toBeInTheDocument()
    expect(attendanceApi.verifyLocation).toHaveBeenCalledWith(fix)
  })

  it('loads work-location reference data only with its separate permission', async () => {
    renderPage({ attendance: ['list_own'], work_locations: ['submit'] })

    expect(await screen.findByRole('heading', { name: 'Work locations' })).toBeInTheDocument()
    expect(attendanceApi.locations).not.toHaveBeenCalled()
    expect(screen.getByRole('button', { name: 'Register work location' })).toBeInTheDocument()
  })

  it('uses the shared date and time popovers for work-location extension requests', async () => {
    const user = userEvent.setup()
    const location: WorkLocation = {
      id: 31,
      name: 'Enugu field office',
      location_type: 'site',
      latitude: 6.45,
      longitude: 7.5,
      allowed_radius_meters: 100,
      branch_id: 4,
      branch_name: 'Enugu',
      status: 'approved',
      rejection_reason: '',
      verified_by_name: 'Test Admin',
      verified_at: '2026-10-20T09:00:00Z',
      expires_at: '2026-12-01T00:00:00Z',
      is_active: true,
      deactivated_at: null,
      deactivation_reason: '',
      deactivation_note: '',
      is_expired: false,
      can_be_used: true,
      notes: '',
      employee_id: 23,
      employee_name: 'Sam Staff',
      created_at: '2026-10-01T09:00:00Z',
    }
    vi.mocked(attendanceApi.locations).mockResolvedValue({
      locations: [location],
      total: 1,
      attendance_location_status: 'ready',
    })

    const { container } = renderPage({
      attendance: ['list_own'],
      work_locations: ['list_own', 'view_own', 'request_extension'],
    })

    await user.click(await screen.findByRole('button', { name: 'Request extension' }))
    const dialog = await screen.findByRole('dialog', { name: 'Request location extension' })
    const dateTrigger = within(dialog).getByRole('button', { name: 'Expiry date' })
    const timeTrigger = within(dialog).getByRole('button', { name: 'Expiry time' })
    expect(container.querySelector('input[type="datetime-local"]')).not.toBeInTheDocument()

    await user.click(dateTrigger)
    expect(await screen.findByRole('dialog', { name: 'Choose a date' })).toBeInTheDocument()
    await user.keyboard('{Escape}')
    await user.click(timeTrigger)
    expect(await screen.findByRole('dialog', { name: 'Choose a time' })).toBeInTheDocument()
  })
})
