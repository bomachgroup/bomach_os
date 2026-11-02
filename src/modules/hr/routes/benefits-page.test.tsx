import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from '@tanstack/react-router'
import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import { benefitsApi, type PayrollAllowanceRecord } from '@/modules/hr/benefits.api'
import { benefitsQueryKeys } from '@/modules/hr/benefits.queries'
import { validateBenefitsSearch, type BenefitsSearch } from '@/modules/hr/benefits.search'
import { validateMyPaySearch } from '@/modules/hr/my-pay.search'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'

import { BenefitsPage, MyPayPage } from './benefits-page'

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
  },
})

const session: AuthenticatedSession = {
  user: {
    id: 9,
    email: 'hr@example.test',
    username: 'hr',
    first_name: 'HR',
    last_name: 'Reviewer',
    is_verified: true,
    created_at: '2026-01-01T00:00:00Z',
    role: null,
    permissions: {},
  },
  employee: {
    id: 19,
    user_id: 9,
    employee_id: 'EMP-019',
    username: 'hr',
    email: 'hr@example.test',
    first_name: 'HR',
    last_name: 'Reviewer',
  },
  roles: [],
  permissions: { payroll: ['list'] },
}

const record: PayrollAllowanceRecord = {
  id: 4,
  employeeId: 23,
  employeeCode: 'EMP-023',
  employeeName: 'Amaka Okafor',
  designation: 'People Manager',
  period: 'October 2026',
  baseSalary: 300000,
  allowanceTotal: 95000,
  allowanceBreakdown: { housing: 70000, transport: 25000 },
  deductionBreakdown: { tax: 15000 },
  deductions: 15000,
  netPay: 380000,
  status: 'paid',
  disbursementDate: '2026-10-28',
}

let queryClient: QueryClient

function renderPage({
  url,
  personal = false,
  permissions = session.permissions,
  seedList = true,
}: {
  url?: string
  personal?: boolean
  permissions?: AuthenticatedSession['permissions']
  seedList?: boolean
} = {}) {
  const initialUrl =
    url ??
    (personal
      ? '/dashboard/my-pay?status=all&page=1&pageSize=10'
      : '/hr/benefits?search=&status=all&page=1&pageSize=10')
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, { ...session, permissions })
  if (seedList) {
    const params = Object.fromEntries(
      new URL(initialUrl, 'http://localhost').searchParams.entries(),
    )
    const routeSearch = personal ? validateMyPaySearch(params) : validateBenefitsSearch(params)
    queryClient.setQueryData(
      benefitsQueryKeys.list(session.user.id, session.employee.employee_id, {
        search: personal ? '' : (routeSearch as BenefitsSearch).search,
        status: routeSearch.status,
        ...(personal ? { employeeId: session.employee.id } : {}),
        limit: routeSearch.pageSize,
        offset: (routeSearch.page - 1) * routeSearch.pageSize,
      }),
      { count: 1, items: [record] },
    )
  }
  const root = createRootRoute()
  const protectedRoute = createRoute({
    getParentRoute: () => root,
    id: '_protected',
    component: Outlet,
  })
  const route = createRoute({
    getParentRoute: () => protectedRoute,
    path: personal ? '/dashboard/my-pay' : '/hr/benefits',
    validateSearch: personal ? validateMyPaySearch : validateBenefitsSearch,
    component: personal ? MyPayPage : BenefitsPage,
  })
  const router = createRouter({
    routeTree: root.addChildren([protectedRoute.addChildren([route])]),
    history: createMemoryHistory({ initialEntries: [initialUrl] }),
  })
  const view = render(
    <QueryClientProvider client={queryClient}>
      <ToastContext.Provider value={{ showToast: vi.fn(), dismissToast: vi.fn() }}>
        <RouterProvider router={router} />
      </ToastContext.Provider>
    </QueryClientProvider>,
  )
  return { view, router }
}

beforeEach(() => {
  vi.spyOn(benefitsApi, 'list').mockResolvedValue({ count: 1, items: [record] })
})

afterEach(() => {
  queryClient?.clear()
  vi.restoreAllMocks()
})

describe('BenefitsPage', () => {
  it('organizes each payroll card into employee, pay summary, and details sections', async () => {
    renderPage()

    const employee = await screen.findByRole('heading', { name: 'Amaka Okafor' })
    const card = employee.closest('article')

    expect(card).not.toBeNull()
    expect(within(card!).getByText('Gross pay')).toBeVisible()
    expect(within(card!).getByText('Allowances')).toBeVisible()
    expect(within(card!).getByText('Net pay').parentElement).toHaveClass(
      'col-span-2',
      'phone:col-span-1',
    )
    expect(within(card!).getByText('₦380,000')).toHaveClass('text-primary')
    expect(within(card!).getByRole('button', { name: 'View payroll details' })).toBeVisible()
  })

  it('keeps the public Benefits path when applying search filters', async () => {
    const user = userEvent.setup()
    const { router } = renderPage()

    expect(await screen.findByRole('heading', { name: 'Payroll' })).toBeVisible()
    await user.type(screen.getByRole('textbox', { name: 'Search payroll records' }), '  Amaka  ')
    await user.click(screen.getByRole('button', { name: 'Search' }))

    await waitFor(() => expect(router.state.location.pathname).toBe('/hr/benefits'))
    expect((router.state.location.search as BenefitsSearch).search).toBe('Amaka')
    expect(router.state.location.search.page).toBe(1)
  })

  it('shows payroll allowance details and applies employee search and status filters', async () => {
    const user = userEvent.setup()
    renderPage({ url: '/hr/benefits?search=Amaka&status=paid&page=1&pageSize=10' })

    expect(
      await screen.findByRole('heading', { name: 'Amaka Okafor' }, { timeout: 5000 }),
    ).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'View payroll details' }))
    expect(await screen.findByText('Allowance breakdown')).toBeVisible()
    expect(screen.getByText('Housing')).toBeVisible()
    expect(screen.getByText('Transport')).toBeVisible()
    expect(screen.getByText('Total allowances')).toBeVisible()
    expect(screen.getAllByText('₦300,000')).toHaveLength(2)
    expect(screen.getAllByText('₦95,000')).toHaveLength(2)
  })

  it('clears a filtered-empty state back to the first unfiltered page', async () => {
    const user = userEvent.setup()
    vi.mocked(benefitsApi.list).mockResolvedValueOnce({ count: 0, items: [] })
    const { router } = renderPage({
      url: '/hr/benefits?search=missing&status=cancelled&page=3&pageSize=10',
      seedList: false,
    })

    expect(
      await screen.findByRole('heading', { name: 'No records match these filters' }),
    ).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Clear filters' }))

    await waitFor(() => {
      expect(router.state.location.search).toMatchObject({
        search: '',
        status: 'all',
        page: 1,
      })
    })
    expect(screen.getByRole('textbox', { name: 'Search payroll records' })).toHaveValue('')
  })

  it('shows the empty allowance-breakdown message for payroll records without categories', async () => {
    const user = userEvent.setup()
    vi.mocked(benefitsApi.list).mockResolvedValueOnce({
      count: 1,
      items: [{ ...record, allowanceBreakdown: {}, allowanceTotal: 0 }],
    })
    renderPage({ seedList: false })

    await screen.findByRole('heading', { name: 'Amaka Okafor' })
    await user.click(screen.getByRole('button', { name: 'View payroll details' }))
    expect(
      await screen.findByText('No category breakdown was included in this payroll record.'),
    ).toBeVisible()
    expect(screen.getAllByText('₦0').length).toBeGreaterThan(0)
  })

  it('renders a permission-denied state without requesting payroll data', async () => {
    renderPage({ permissions: {}, seedList: false })

    expect(await screen.findByText('You can’t view payroll records')).toBeVisible()
    expect(benefitsApi.list).not.toHaveBeenCalled()
  })

  it('pages through more than one set of payroll records', async () => {
    const user = userEvent.setup()
    const nextRecords = Array.from({ length: 10 }, (_, index) => ({
      ...record,
      id: record.id + index,
      employeeName: `QA Payroll ${index + 1}`,
    }))
    const lastRecords = nextRecords.slice(0, 7).map((item) => ({
      ...item,
      id: item.id + 20,
    }))
    vi.mocked(benefitsApi.list)
      .mockResolvedValueOnce({ count: 17, items: nextRecords })
      .mockResolvedValueOnce({ count: 17, items: lastRecords })
    const { router } = renderPage({ seedList: false })

    expect(await screen.findByText('Showing 1–10 of 17')).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Next' }))
    await waitFor(() => expect(router.state.location.search.page).toBe(2))
    expect(await screen.findByText('Showing 11–17 of 17')).toBeVisible()
    expect(benefitsApi.list).toHaveBeenLastCalledWith(
      expect.objectContaining({ limit: 10, offset: 10 }),
      expect.any(AbortSignal),
    )
  })

  it('denies owner-only payroll access on the HR register', async () => {
    renderPage({ permissions: { payroll: ['list_own'] }, seedList: false })

    expect(await screen.findByText('You can’t view payroll records')).toBeVisible()
    expect(benefitsApi.list).not.toHaveBeenCalled()
  })

  it.each([
    { label: 'owner-only', permissions: { payroll: ['list_own'] } },
    { label: 'broad', permissions: { payroll: ['list'] } },
  ])(
    'scopes $label My Pay to the signed-in employee and shows payroll detail',
    async ({ permissions }) => {
      const user = userEvent.setup()
      renderPage({
        personal: true,
        permissions,
        url: '/dashboard/my-pay?status=paid&page=1&pageSize=10',
        seedList: false,
      })

      expect(await screen.findByRole('heading', { name: 'October 2026' })).toBeVisible()
      expect(
        screen.queryByRole('textbox', { name: 'Search payroll records' }),
      ).not.toBeInTheDocument()
      expect(benefitsApi.list).toHaveBeenCalledWith(
        expect.objectContaining({ employeeId: 19, search: '', status: 'paid' }),
        expect.any(AbortSignal),
      )
      await user.click(screen.getByRole('button', { name: 'View payroll details' }))
      expect(await screen.findByText('Allowance breakdown')).toBeVisible()
      expect(screen.getByText('Deduction breakdown')).toBeVisible()
      expect(screen.getByText('Tax')).toBeVisible()
      expect(screen.getByText('Disbursement date')).toBeVisible()
    },
  )

  it('shows a recoverable API error on My Pay without dropping the selected status', async () => {
    const user = userEvent.setup()
    vi.mocked(benefitsApi.list).mockRejectedValueOnce(new Error('Temporary payroll error'))
    renderPage({
      personal: true,
      permissions: { payroll: ['list_own'] },
      url: '/dashboard/my-pay?status=paid&page=2&pageSize=20',
      seedList: false,
    })

    expect(
      await screen.findByText('Your pay records could not be loaded', {}, { timeout: 5000 }),
    ).toBeVisible()
    expect(benefitsApi.list).toHaveBeenCalledWith(
      expect.objectContaining({ employeeId: 19, status: 'paid', limit: 20, offset: 20 }),
      expect.any(AbortSignal),
    )
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(
      await screen.findByRole('heading', { name: 'October 2026' }, { timeout: 5000 }),
    ).toBeVisible()
  })
})
