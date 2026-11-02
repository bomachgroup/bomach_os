import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen, waitFor } from '@testing-library/react'
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
import { WorkLocationRegistrationPage } from './work-location-registration-page'

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
  permissions: { work_locations: ['submit', 'list'] },
}

const gps: Coordinates = { latitude: 6.45, longitude: 3.4, accuracy_meters: 18 }
let queryClient: QueryClient
const showToast = vi.fn()

function renderPage(permissions = session.permissions) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, { ...session, permissions })
  return render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <WorkLocationRegistrationPage />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

async function captureAndContinue(user: ReturnType<typeof userEvent.setup>) {
  await screen.findByRole('heading', { name: 'Confirm the GPS point' })
  await screen.findByRole('button', { name: 'Continue with this location' })
  await user.click(screen.getByRole('button', { name: 'Continue with this location' }))
  expect(await screen.findByRole('heading', { name: 'Location details' })).toBeInTheDocument()
}

describe('Work location registration', () => {
  beforeEach(() => {
    routeState.search = { dateFrom: '', dateTo: '', page: 1 }
    routeState.navigate.mockReset()
    showToast.mockReset()
    vi.spyOn(attendanceModule, 'startGeoPositionScan').mockImplementation((_options, onUpdate) => {
      let resolveResult!: (coordinates: Coordinates) => void
      let settled = false
      const result = new Promise<Coordinates>((resolve) => {
        resolveResult = resolve
      })
      const update = {
        phase: 'reading' as const,
        bestCoordinates: gps,
        latestAccuracyMeters: gps.accuracy_meters,
        elapsedMs: 1_200,
        sampleCount: 2,
      }
      onUpdate?.(update)
      return {
        result,
        acceptBest: () => {
          if (settled) return false
          settled = true
          resolveResult(gps)
          return true
        },
        cancel: () => {
          if (settled) return
          settled = true
          resolveResult(gps)
        },
      }
    })
    vi.spyOn(attendanceApi, 'branches').mockResolvedValue([
      {
        id: 8,
        branch_name: 'Enugu Office',
        branch_id: 'ENU',
        city: 'Enugu',
        state: 'Enugu',
        office_address: 'Independence Layout',
      },
    ])
    vi.spyOn(attendanceApi, 'proposeLocation').mockResolvedValue({
      id: 40,
      name: 'Enugu field office',
      location_type: 'branch',
      latitude: gps.latitude,
      longitude: gps.longitude,
      allowed_radius_meters: 100,
      branch_id: 8,
      branch_name: 'Enugu Office',
      status: 'pending',
      rejection_reason: '',
      verified_by_name: null,
      verified_at: null,
      expires_at: null,
      is_active: true,
      deactivated_at: null,
      deactivation_reason: '',
      deactivation_note: '',
      is_expired: false,
      can_be_used: false,
      notes: '',
      employee_id: 23,
      employee_name: 'Sam Staff',
      created_at: '2026-10-20T08:00:00Z',
    } satisfies WorkLocation)
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('captures GPS before submission and sends the selected active branch for boundary validation', async () => {
    const user = userEvent.setup()
    renderPage()
    await captureAndContinue(user)

    await user.type(screen.getByLabelText(/Location name/), 'Enugu field office')
    await user.click(screen.getByRole('combobox', { name: /Active branch/ }))
    await user.click(await screen.findByRole('option', { name: /Enugu Office/ }))
    await user.click(screen.getByRole('button', { name: 'Submit for review' }))

    await waitFor(() =>
      expect(attendanceApi.proposeLocation).toHaveBeenCalledWith(
        {
          name: 'Enugu field office',
          location_type: 'branch',
          notes: '',
          ...gps,
          branch_id: 8,
          expires_at: null,
        },
        expect.anything(),
      ),
    )
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Work location submitted', tone: 'success' }),
    )
    expect(routeState.navigate).toHaveBeenCalledWith(
      expect.objectContaining({
        to: '/hr/attendance',
        search: { dateFrom: '', dateTo: '', page: 1 },
      }),
    )
  })

  it('requires a future expiry for temporary remote locations and preserves values after failure', async () => {
    const user = userEvent.setup()
    vi.mocked(attendanceApi.proposeLocation).mockRejectedValueOnce(
      new Error('The selected point is outside the approved area.'),
    )
    renderPage()
    await captureAndContinue(user)

    await user.click(screen.getByRole('combobox', { name: /Location type/ }))
    await user.click(await screen.findByRole('option', { name: /Remote location/ }))
    await user.type(screen.getByLabelText(/Location name/), 'Home office')
    await user.click(screen.getByRole('button', { name: 'temporary' }))
    await user.click(screen.getByRole('button', { name: 'Submit for review' }))
    expect(await screen.findByText('Choose an expiry date.')).toBeInTheDocument()
    expect(attendanceApi.proposeLocation).not.toHaveBeenCalled()

    const expiry = new Date()
    expiry.setDate(expiry.getDate() + 7)
    const expiryValue = `${expiry.getFullYear()}-${String(expiry.getMonth() + 1).padStart(2, '0')}-${String(expiry.getDate()).padStart(2, '0')}`
    await user.click(screen.getByLabelText(/Expires on/))
    const calendar = await screen.findByRole('dialog', { name: 'Choose a date' })
    const expiryDay = calendar.querySelector<HTMLButtonElement>(`[data-date="${expiryValue}"]`)
    expect(expiryDay).toBeEnabled()
    fireEvent.click(expiryDay!)
    expect(screen.queryByRole('dialog', { name: 'Choose a date' })).not.toBeInTheDocument()
    expect(screen.getByLabelText(/Location type/)).toHaveTextContent('Remote location')
    expect(screen.getByRole('button', { name: 'temporary' })).toHaveAttribute(
      'aria-pressed',
      'true',
    )
    expect(screen.getByLabelText(/Expires on/)).toHaveTextContent(
      new Intl.DateTimeFormat(undefined, { day: 'numeric', month: 'long', year: 'numeric' }).format(
        expiry,
      ),
    )
    expect(screen.getByRole('button', { name: 'Submit for review' })).toBeEnabled()
    await user.click(screen.getByRole('button', { name: 'Submit for review' }))

    expect(attendanceApi.proposeLocation).toHaveBeenCalledWith(
      expect.objectContaining({ name: 'Home office', expires_at: expect.any(String) }),
      expect.anything(),
    )
    expect(
      await screen.findByText('An unexpected problem occurred. Please try again.'),
    ).toBeInTheDocument()
    expect(screen.getByLabelText(/Location name/)).toHaveValue('Home office')
    expect(screen.getByLabelText(/Expires on/)).toHaveTextContent(
      new Intl.DateTimeFormat(undefined, { day: 'numeric', month: 'long', year: 'numeric' }).format(
        expiry,
      ),
    )
    expect(attendanceApi.proposeLocation).toHaveBeenCalledWith(
      expect.objectContaining({
        location_type: 'remote',
        name: 'Home office',
        latitude: gps.latitude,
        longitude: gps.longitude,
        accuracy_meters: gps.accuracy_meters,
        expires_at: expect.any(String),
      }),
      expect.anything(),
    )
  })
})
