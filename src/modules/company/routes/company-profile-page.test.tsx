import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import {
  companyDashboardApi,
  companyIdentityQueryKeys,
  type CompanyBrandingDto,
  type CompanyPreferencesDto,
  type CompanyProfileDto,
} from '@/modules/company/company-dashboard.api'
import { ApiError } from '@/shared/api/api-error'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { CompanyProfilePage } from './company-profile-page'

const showToast = vi.fn()
let queryClient: QueryClient

const profile: CompanyProfileDto = {
  id: 1,
  company_name: 'Bomach Infrastructure Ltd',
  company_email: 'hello@bomach.example',
  company_phone: '+234 800 000 0000',
  company_addresses: '12 Airport Road, Lagos',
  rc_number: 'RC1234567',
  industry: 'Infrastructure',
  is_configured: true,
  created_at: '2026-01-01T00:00:00Z',
  updated_at: '2026-01-01T00:00:00Z',
}

const unconfiguredProfile: CompanyProfileDto = {
  ...profile,
  company_name: 'Your Company Name',
  company_email: 'info@company.com',
  company_phone: '',
  company_addresses: '',
  rc_number: '',
  industry: '',
  is_configured: false,
}

const branding: CompanyBrandingDto = {
  id: 1,
  company_logo: null,
  company_slogan: 'Building with purpose',
  primary_color_code: '#FE0000',
  secondary_color_code: '#3E4094',
  created_at: '2026-01-01T00:00:00Z',
  updated_at: '2026-01-01T00:00:00Z',
}

const preferences: CompanyPreferencesDto = {
  id: 1,
  default_currency: 'NGN',
  language_preference: 'en-GB',
  time_zone: 'Africa/Lagos',
  punctuality_cutoff_time: '08:10:00',
  business_rules: 'Clock in before starting a shift.',
  extras: {},
  created_at: '2026-01-01T00:00:00Z',
  updated_at: '2026-01-01T00:00:00Z',
}

const makeSession = (permissions: AuthenticatedSession['permissions']): AuthenticatedSession => ({
  user: {
    id: 7,
    email: 'admin@example.com',
    username: 'admin',
    is_verified: true,
    created_at: '2026-01-01T00:00:00Z',
    role: null,
    permissions,
  },
  employee: { user_id: 7, employee_id: 'EMP-007', username: 'admin', email: 'admin@example.com' },
  roles: [],
  permissions,
})

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

function renderPage(
  permissions: AuthenticatedSession['permissions'],
  profileDto: CompanyProfileDto = profile,
) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, makeSession(permissions))
  queryClient.setQueryData(companyIdentityQueryKeys.profile(7), profileDto)
  queryClient.setQueryData(companyIdentityQueryKeys.branding(7), branding)
  queryClient.setQueryData(companyIdentityQueryKeys.preferences(7), preferences)
  return render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <CompanyProfilePage />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

describe('Company Profile page', () => {
  beforeEach(() => {
    showToast.mockReset()
    vi.spyOn(companyDashboardApi, 'profile').mockResolvedValue(profile)
    vi.spyOn(companyDashboardApi, 'branding').mockResolvedValue(branding)
    vi.spyOn(companyDashboardApi, 'preferences').mockResolvedValue(preferences)
    vi.spyOn(companyDashboardApi, 'choices').mockResolvedValue({
      currencies: [
        { value: 'NGN', label: 'NGN - Nigerian Naira' },
        { value: 'GHS', label: 'GHS - Ghanaian Cedi' },
      ],
      languages: [
        { value: 'en-GB', label: 'English UK' },
        { value: 'en-US', label: 'English US' },
      ],
      time_zones: [
        { value: 'Africa/Lagos', label: 'Africa/Lagos' },
        { value: 'Africa/Accra', label: 'Africa/Accra' },
      ],
    })
    vi.spyOn(companyDashboardApi, 'updateProfile').mockImplementation(async (input) => ({
      ...profile,
      ...input,
      is_configured: true,
    }))
    vi.spyOn(companyDashboardApi, 'updateBranding').mockResolvedValue(branding)
    vi.spyOn(companyDashboardApi, 'updatePreferences').mockResolvedValue(preferences)
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('hides placeholder company identity until it has been configured', () => {
    renderPage({ company_settings: ['view'] }, unconfiguredProfile)

    expect(screen.getByText('Company profile setup')).toBeInTheDocument()
    expect(screen.getByText('Company identity has not been configured')).toBeInTheDocument()
    expect(screen.queryByText('Your Company Name')).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Edit' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Set up company details' })).not.toBeInTheDocument()
  })

  it('does not mistake a failed profile read for an unconfigured company', async () => {
    vi.mocked(companyDashboardApi.profile).mockRejectedValue(
      new ApiError('Unavailable', { status: 503 }),
    )
    queryClient = new QueryClient({
      defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
    })
    queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, makeSession({ company_settings: ['view'] }))
    queryClient.setQueryData(companyIdentityQueryKeys.branding(7), branding)
    queryClient.setQueryData(companyIdentityQueryKeys.preferences(7), preferences)

    render(
      <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
        <QueryClientProvider client={queryClient}>
          <CompanyProfilePage />
        </QueryClientProvider>
      </ToastContext.Provider>,
    )

    const details = screen.getByRole('region', { name: 'Company details' })
    expect(await within(details).findByText('Service temporarily unavailable')).toBeInTheDocument()
    expect(screen.getByText('Company profile', { selector: 'h1.text-h2' })).toBeInTheDocument()
    expect(screen.queryByText('Company profile setup')).not.toBeInTheDocument()
    expect(screen.queryByText('Setup needed')).not.toBeInTheDocument()
  })

  it('shows saved identity and only exposes section editors to update permission holders', () => {
    renderPage({ company_settings: ['view'] })

    expect(screen.getByRole('heading', { name: profile.company_name })).toBeInTheDocument()
    expect(screen.getByText(profile.company_addresses)).toBeInTheDocument()
    expect(screen.getByText('Africa/Lagos')).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Edit' })).not.toBeInTheDocument()
  })

  it('saves profile changes through the profile endpoint and keeps the configured result in cache', async () => {
    const user = userEvent.setup()
    renderPage({ company_settings: ['view', 'update'] })

    await user.click(screen.getAllByRole('button', { name: 'Edit' })[0]!)
    const dialog = screen.getByRole('dialog', { name: 'Edit company details' })
    await user.clear(within(dialog).getByLabelText(/Company name/))
    await user.type(within(dialog).getByLabelText(/Company name/), 'Bomach Global Ltd')
    await user.click(within(dialog).getByRole('button', { name: 'Save details' }))

    await waitFor(() => expect(companyDashboardApi.updateProfile).toHaveBeenCalled())
    expect(vi.mocked(companyDashboardApi.updateProfile).mock.calls[0]?.[0]).toEqual(
      expect.objectContaining({ company_name: 'Bomach Global Ltd' }),
    )
    expect(
      queryClient.getQueryData<CompanyProfileDto>(companyIdentityQueryKeys.profile(7)),
    ).toMatchObject({ company_name: 'Bomach Global Ltd', is_configured: true })
  })

  it('loads supported choices only when operating defaults are opened and saves timezone settings', async () => {
    const user = userEvent.setup()
    renderPage({ company_settings: ['view', 'update'] })

    expect(companyDashboardApi.choices).not.toHaveBeenCalled()
    await user.click(screen.getAllByRole('button', { name: 'Edit' })[2]!)
    const dialog = screen.getByRole('dialog', { name: 'Edit operating defaults' })
    await waitFor(() => expect(companyDashboardApi.choices).toHaveBeenCalledTimes(1))
    const timeZone = within(dialog).getByRole('combobox', { name: 'Time zone' })
    await user.click(timeZone)
    await user.click(await screen.findByRole('option', { name: 'Africa/Accra' }))
    await user.click(within(dialog).getByRole('button', { name: 'Save defaults' }))

    await waitFor(() => expect(companyDashboardApi.updatePreferences).toHaveBeenCalled())
    expect(vi.mocked(companyDashboardApi.updatePreferences).mock.calls[0]?.[0]).toEqual(
      expect.objectContaining({ time_zone: 'Africa/Accra', punctuality_cutoff_time: '08:10' }),
    )
  })
})
