import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import {
  branchesApi,
  type BranchChoicesDto,
  type BranchDto,
  type BranchManagerPageDto,
  type BranchUpdateInput,
  type BranchWriteInput,
} from '@/modules/company/branches.api'
import { BranchFormDialog } from './branch-form-dialog'

const choices: BranchChoicesDto = {
  operational_status: [{ value: 'active', label: 'Active' }],
  branch_role: [{ value: 'branch', label: 'Branch' }],
  currencies: [{ value: 'NGN', label: 'NGN - Nigerian Naira' }],
  languages: [{ value: 'en-GB', label: 'English UK' }],
}

const branch: BranchDto = {
  id: 44,
  branch_name: 'Lagos branch',
  branch_id: 'LOS',
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
  contact_email: 'lagos@example.test',
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

let queryClient: QueryClient

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
Object.defineProperty(HTMLElement.prototype, 'scrollTo', {
  configurable: true,
  value: vi.fn(),
})

function renderForm({
  selectedBranch = null,
  onSave = vi.fn(async () => undefined),
}: {
  selectedBranch?: BranchDto | null
  onSave?: (input: BranchWriteInput | BranchUpdateInput) => Promise<void>
} = {}) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  render(
    <QueryClientProvider client={queryClient}>
      <BranchFormDialog
        open
        onOpenChange={vi.fn()}
        branch={selectedBranch}
        userId={7}
        employeeId="EMP-007"
        canEditHours
        onSave={onSave}
      />
    </QueryClientProvider>,
  )
  return onSave
}

async function advanceToReview(user: ReturnType<typeof userEvent.setup>) {
  await waitFor(() => expect(branchesApi.choices).toHaveBeenCalled())

  await user.type(screen.getByLabelText(/Branch name/), 'North office')
  await user.click(screen.getByRole('button', { name: 'Next' }))

  await user.type(document.getElementById('branch-country')!, 'Nigeria')
  await user.type(document.getElementById('branch-state')!, 'Lagos')
  await user.type(document.getElementById('branch-address')!, '12 Airport Road')
  await user.type(document.getElementById('branch-email')!, 'north@example.test')
  await user.type(document.getElementById('branch-phone')!, '+2348012345678')
  await user.click(screen.getByRole('button', { name: 'Next' }))

  await screen.findByRole('heading', { name: 'Attendance geofence' })
  expect(screen.getByRole('region', { name: 'GPS location capture' })).toBeVisible()
  expect(screen.getByRole('button', { name: /Start GPS scan|Check location access/ })).toBeVisible()
  await user.click(screen.getByRole('button', { name: 'Next' }))
  await screen.findByRole('heading', { name: 'Business hours' })
  await user.click(screen.getByRole('button', { name: 'Next' }))
  await screen.findByRole('region', { name: 'Review branch details' })
}

async function setTime(
  user: ReturnType<typeof userEvent.setup>,
  label: string,
  hour: string,
  minute: string,
  period: 'AM' | 'PM',
) {
  await user.click(screen.getByRole('button', { name: new RegExp(label) }))
  const picker = await screen.findByRole('dialog', { name: 'Choose a time', hidden: true })
  for (const [name, option] of [
    ['Hour', hour],
    ['Minute', minute],
    ['AM or PM', period],
  ]) {
    await user.click(within(picker).getByRole('combobox', { name }))
    await user.click(screen.getByRole('option', { name: option }))
  }
  await user.click(within(picker).getByRole('button', { name: 'Set time' }))
}

describe('Branch form dialog', () => {
  beforeEach(() => {
    vi.spyOn(branchesApi, 'choices').mockResolvedValue(choices)
    vi.spyOn(branchesApi, 'managerChoices').mockResolvedValue({
      count: 0,
      items: [],
    } satisfies BranchManagerPageDto)
    vi.spyOn(branchesApi, 'businessHours').mockResolvedValue([])
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('does not save when the create flow enters Review; only the final action saves', async () => {
    const user = userEvent.setup()
    const onSave = renderForm()

    await advanceToReview(user)

    expect(screen.getByText('Review and confirm')).toBeInTheDocument()
    expect(onSave).not.toHaveBeenCalled()

    const form = document.querySelector<HTMLFormElement>('#branch-form')
    expect(form).not.toBeNull()
    fireEvent.submit(form!)
    expect(onSave).not.toHaveBeenCalled()

    await user.click(screen.getByRole('button', { name: 'Create branch' }))
    await waitFor(() => expect(onSave).toHaveBeenCalledTimes(1))
    expect(onSave).toHaveBeenCalledWith(
      expect.objectContaining({
        branch_name: 'North office',
        country: 'Nigeria',
        contact_email: 'north@example.test',
      }),
    )
  }, 15_000)

  it('keeps the edit flow on Review until Save changes is activated', async () => {
    const user = userEvent.setup()
    const onSave = renderForm({ selectedBranch: branch })
    await waitFor(() => expect(branchesApi.businessHours).toHaveBeenCalled())

    await user.click(screen.getByRole('button', { name: 'Next' }))
    await user.click(screen.getByRole('button', { name: 'Next' }))
    expect(screen.getByRole('region', { name: 'GPS location capture' })).toBeVisible()
    expect(
      screen.getByRole('button', { name: /Start GPS scan|Check location access/ }),
    ).toBeVisible()
    await user.type(screen.getByLabelText('Latitude'), '6.5244')
    await user.type(screen.getByLabelText('Longitude'), '3.3792')
    await user.clear(screen.getByLabelText(/^Attendance radius \(metres\)/))
    await user.type(screen.getByLabelText(/^Attendance radius \(metres\)/), '250')
    await user.click(screen.getByRole('button', { name: 'Next' }))
    await user.click(screen.getByRole('button', { name: 'Next' }))

    expect(screen.getByRole('region', { name: 'Review branch details' })).toBeVisible()
    expect(screen.getByText('Review and confirm')).toBeInTheDocument()
    expect(onSave).not.toHaveBeenCalled()
    fireEvent.submit(document.querySelector<HTMLFormElement>('#branch-form')!)
    expect(onSave).not.toHaveBeenCalled()

    await user.click(screen.getByRole('button', { name: 'Save changes' }))
    await waitFor(() => expect(onSave).toHaveBeenCalledTimes(1))
    expect(onSave).toHaveBeenCalledWith(
      expect.objectContaining({
        branch_name: branch.branch_name,
        latitude: 6.5244,
        longitude: 3.3792,
        attendance_radius_meters: 250,
      }),
    )
  }, 15_000)

  it('carries copied business hours into the create review summary', async () => {
    const user = userEvent.setup()
    renderForm()

    await advanceToReview(user)
    await user.click(screen.getByRole('button', { name: 'Previous' }))

    await user.click(screen.getByRole('combobox', { name: 'Monday schedule' }))
    await user.click(screen.getByRole('option', { name: 'Open' }))
    await setTime(user, 'Opens', '08', '30', 'AM')
    await setTime(user, 'Closes', '04', '30', 'PM')
    await user.click(screen.getByRole('button', { name: 'Apply to all days' }))

    expect(screen.getByText('Applied Monday’s schedule to all 6 other days.')).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Next' }))

    const review = screen.getByRole('region', { name: 'Review branch details' })
    expect(within(review).getByText('Sunday').closest('li')).toHaveTextContent('08:30–16:30')
  }, 15_000)
})
