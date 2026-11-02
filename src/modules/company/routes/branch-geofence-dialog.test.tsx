import { StrictMode, useState } from 'react'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import { validateGeofenceDraft } from '@/modules/company/branch-location'
import type { BranchDto, BranchUpdateInput } from '@/modules/company/branches.api'
import { BranchGeofenceDialog } from './branch-geofence-dialog'

const branch: BranchDto = {
  id: 44,
  branch_name: 'QA branch',
  branch_id: 'QA-44',
  default_currency: 'NGN',
  language_preference: 'en-GB',
  country: 'Nigeria',
  country_code: 'NG',
  state: 'Lagos',
  state_code: 'LA',
  city: 'Lagos',
  lga: 'Ikeja',
  office_address: '12 Airport Road',
  full_address: '12 Airport Road, Lagos, Nigeria',
  operational_status: 'active',
  operational_status_display: 'Active',
  branch_role: 'branch',
  branch_role_display: 'Branch',
  contact_email: 'qa@example.test',
  contact_phone: '+2348012345678',
  manager_id: null,
  manager_name: null,
  is_active: true,
  is_operational: true,
  latitude: null,
  longitude: null,
  attendance_radius_meters: 100,
  notes: '',
  created_at: '2026-01-01T00:00:00Z',
  updated_at: '2026-01-01T00:00:00Z',
}

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

function GeofenceHarness({ onSave }: { onSave: (input: BranchUpdateInput) => Promise<void> }) {
  const [open, setOpen] = useState(false)
  return (
    <>
      <button type="button" onClick={() => setOpen(true)}>
        Open geofence
      </button>
      <BranchGeofenceDialog open={open} branch={branch} onOpenChange={setOpen} onSave={onSave} />
    </>
  )
}

describe('BranchGeofenceDialog', () => {
  it('validates coordinate pairs, coordinate ranges, and radius boundaries', () => {
    expect(validateGeofenceDraft('6.5', '', '100')).toMatch(/both coordinates/)
    expect(validateGeofenceDraft('90.01', '3.3', '100')).toMatch(/valid latitude/)
    expect(validateGeofenceDraft('6.5', '180.01', '100')).toMatch(/valid latitude/)
    expect(validateGeofenceDraft('', '', '0')).toMatch(/radius from 1 to 5000/)
    expect(validateGeofenceDraft('', '', '1')).toBeNull()
    expect(validateGeofenceDraft('90', '180', '5000')).toBeNull()
  })

  it('clears corrected validation errors and resets dismissed drafts on reopen', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn(async () => {})

    render(
      <StrictMode>
        <GeofenceHarness onSave={onSave} />
      </StrictMode>,
    )

    await user.click(screen.getByRole('button', { name: 'Open geofence' }))
    const dialog = await screen.findByRole('dialog', { name: 'Update geofence · QA branch' })
    expect(screen.getByRole('region', { name: 'GPS location capture' })).toBeVisible()
    expect(
      screen.getByRole('button', { name: /Start GPS scan|Check location access/ }),
    ).toBeVisible()
    expect(screen.queryByText(/Scan until the best GPS fix is within/)).not.toBeInTheDocument()
    await user.type(screen.getByLabelText('Latitude'), '91')
    await user.type(screen.getByLabelText('Longitude'), '3.3')
    await user.click(screen.getByRole('button', { name: 'Save geofence' }))
    expect(await screen.findByRole('alert')).toHaveTextContent(/valid latitude/)

    await user.clear(screen.getByLabelText('Latitude'))
    await user.type(screen.getByLabelText('Latitude'), '6.5')
    await waitFor(() => expect(screen.queryByRole('alert')).not.toBeInTheDocument())

    await user.clear(screen.getByLabelText(/^Attendance radius \(metres\)/))
    await user.type(screen.getByLabelText(/^Attendance radius \(metres\)/), '0')
    await user.click(screen.getByRole('button', { name: 'Save geofence' }))
    expect(await screen.findByRole('alert')).toHaveTextContent(/radius from 1 to 5000/)

    await user.clear(screen.getByLabelText(/^Attendance radius \(metres\)/))
    await user.type(screen.getByLabelText(/^Attendance radius \(metres\)/), '5000')
    await waitFor(() => expect(screen.queryByRole('alert')).not.toBeInTheDocument())
    expect(onSave).not.toHaveBeenCalled()

    await user.click(screen.getByRole('button', { name: 'Cancel' }))
    await user.click(screen.getByRole('button', { name: 'Open geofence' }))
    await waitFor(() => expect(dialog).toHaveAttribute('open'))
    expect(screen.getByLabelText('Latitude')).toHaveValue('')
    expect(screen.getByLabelText('Longitude')).toHaveValue('')
    expect(screen.getByLabelText(/^Attendance radius \(metres\)/)).toHaveValue(100)
  })
})
