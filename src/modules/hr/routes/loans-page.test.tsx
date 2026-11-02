import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from '@tanstack/react-router'
import { fireEvent, render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import { loansApi, type LoanPage, type LoanRequest } from '@/modules/hr/loans.api'
import { validateMyLoansSearch } from '@/modules/hr/my-loans.search'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'

import { MyLoansPage } from './loans-page'

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

const session: AuthenticatedSession = {
  user: {
    id: 9,
    email: 'employee@example.test',
    username: 'employee',
    first_name: 'Amina',
    last_name: 'Okafor',
    is_verified: true,
    created_at: '2026-01-01T00:00:00Z',
    role: null,
    permissions: {},
  },
  employee: {
    id: 19,
    user_id: 9,
    employee_id: 'EMP-019',
    username: 'employee',
    email: 'employee@example.test',
    first_name: 'Amina',
    last_name: 'Okafor',
  },
  roles: [],
  permissions: {
    loans: ['list_own', 'view_own', 'create', 'update_own'],
  },
}

const ownLoan: LoanRequest = {
  id: 41,
  employee_user_id: session.user.id,
  employee_name: 'Amina Okafor',
  job_title: 'Operations Analyst',
  loan_amount: '125000.00',
  repayment_date: '2026-12-15',
  reason: 'Education expenses',
  status: 'pending',
  emergency_contact_name: 'Chidi Okafor',
  emergency_contact_phone: '+2348000000000',
  attachment: '',
  created_at: '2026-10-30T10:00:00Z',
  updated_at: '2026-10-30T10:00:00Z',
}

let queryClient: QueryClient
const showToast = vi.fn()

function renderMyLoans({
  permissions = session.permissions,
  initialUrl = '/dashboard/my-loans?status=all&page=1&pageSize=10',
}: {
  permissions?: AuthenticatedSession['permissions']
  initialUrl?: string
} = {}) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, { ...session, permissions })

  const root = createRootRoute()
  const protectedRoute = createRoute({
    getParentRoute: () => root,
    id: '_protected',
    component: Outlet,
  })
  const route = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/dashboard/my-loans',
    validateSearch: validateMyLoansSearch,
    component: MyLoansPage,
  })
  const router = createRouter({
    routeTree: root.addChildren([protectedRoute.addChildren([route])]),
    history: createMemoryHistory({ initialEntries: [initialUrl] }),
  })
  const view = render(
    <QueryClientProvider client={queryClient}>
      <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
        <RouterProvider router={router} />
      </ToastContext.Provider>
    </QueryClientProvider>,
  )
  return { view, router }
}

function listResponse(item: LoanRequest | null = ownLoan): LoanPage {
  return { count: item ? 1 : 0, items: item ? [item] : [] }
}

beforeEach(() => {
  vi.spyOn(loansApi, 'list').mockResolvedValue(listResponse())
  vi.spyOn(loansApi, 'get').mockResolvedValue(ownLoan)
  vi.spyOn(loansApi, 'create').mockResolvedValue({ ...ownLoan, id: 42 })
  vi.spyOn(loansApi, 'update').mockResolvedValue(ownLoan)
})

afterEach(() => {
  queryClient?.clear()
  vi.restoreAllMocks()
})

describe('MyLoansPage', () => {
  it('loads only the owner request and omits cross-employee search and review controls', async () => {
    renderMyLoans()

    expect(await screen.findByRole('heading', { name: 'My Loans' })).toBeVisible()
    expect(await screen.findByRole('heading', { name: 'Your loan request' })).toBeVisible()
    expect(loansApi.list).toHaveBeenCalledWith(
      { limit: 10, offset: 0, search: '', status: 'all' },
      expect.any(AbortSignal),
    )
    expect(screen.queryByRole('textbox', { name: 'Search requests' })).not.toBeInTheDocument()
    expect(screen.queryByRole('tablist', { name: 'Loan request views' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Approve' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Reject' })).not.toBeInTheDocument()
  })

  it('opens an owned request, supports pending edits, and reflects a successful save', async () => {
    const user = userEvent.setup()
    renderMyLoans()

    await user.click(await screen.findByRole('button', { name: 'Details' }))
    expect(await screen.findByRole('dialog', { name: 'Loan request #41' })).toBeVisible()
    expect(await screen.findByRole('heading', { name: 'Request details' })).toBeVisible()
    expect(loansApi.get).toHaveBeenCalledWith(41, expect.any(AbortSignal))

    await user.click(screen.getByRole('button', { name: 'Edit request' }))
    const editDialog = await screen.findByRole('dialog', { name: 'Edit loan request' })
    const amount = within(editDialog).getByLabelText(/Loan amount/)
    await user.clear(amount)
    await user.type(amount, '150000')
    await user.click(within(editDialog).getByRole('button', { name: 'Save changes' }))

    await waitFor(() =>
      expect(loansApi.update).toHaveBeenCalledWith(
        41,
        expect.objectContaining({
          loan_amount: 150000,
        }),
      ),
    )
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Loan request updated', tone: 'success' }),
    )
  })

  it('submits a personal request without a client-supplied employee id', async () => {
    const user = userEvent.setup()
    const { router } = renderMyLoans()

    await user.click(await screen.findByRole('button', { name: 'Create loan request' }))
    const formDialog = await screen.findByRole('dialog', { name: 'New loan request' })
    await user.type(within(formDialog).getByLabelText(/Loan amount/), '50000')
    await user.type(within(formDialog).getByLabelText(/Reason for request/), 'Home repairs')
    await user.type(within(formDialog).getByLabelText(/Contact name/), 'Chidi Okafor')
    await user.type(within(formDialog).getByLabelText(/Contact phone/), '+2348000000000')
    await user.click(within(formDialog).getByLabelText(/Planned repayment date/))

    const futureDate = new Date()
    futureDate.setDate(futureDate.getDate() + 7)
    const accessibleDate = new Intl.DateTimeFormat(undefined, {
      weekday: 'long',
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    }).format(futureDate)
    const dateDialog = await screen.findByRole('dialog', { name: 'Choose a date' })
    const dateButton = within(dateDialog).getByRole('button', { name: accessibleDate })
    expect(dateButton).toBeEnabled()
    fireEvent.click(dateButton)
    await waitFor(() =>
      expect(within(formDialog).getByLabelText(/Planned repayment date/)).not.toHaveTextContent(
        'Choose a date',
      ),
    )
    expect(within(formDialog).getByLabelText(/Planned repayment date/)).toHaveTextContent(
      new Intl.DateTimeFormat(undefined, {
        day: 'numeric',
        month: 'long',
        year: 'numeric',
      }).format(futureDate),
    )
    await user.click(within(formDialog).getByRole('button', { name: 'Submit request' }))

    await waitFor(() => expect(loansApi.create).toHaveBeenCalledOnce())
    const [submitted] = vi.mocked(loansApi.create).mock.calls[0]
    expect(submitted).toMatchObject({
      loan_amount: 50000,
      reason: 'Home repairs',
      emergency_contact_name: 'Chidi Okafor',
      emergency_contact_phone: '+2348000000000',
    })
    expect(submitted).not.toHaveProperty('employee_user_id')
    expect(router.state.location.search).toMatchObject({ request_id: 42, page: 1 })
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Loan request submitted', tone: 'success' }),
    )
  })

  it('offers a retry when the personal request list fails', async () => {
    const user = userEvent.setup()
    let shouldFail = true
    vi.mocked(loansApi.list).mockImplementation(async () => {
      if (shouldFail) throw new Error('Network unavailable')
      return listResponse()
    })
    renderMyLoans()

    expect(await screen.findByRole('button', { name: 'Try again' })).toBeVisible()
    shouldFail = false
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(await screen.findByRole('heading', { name: 'Your loan request' })).toBeVisible()
    expect(loansApi.list).toHaveBeenCalledTimes(2)
  })
})
