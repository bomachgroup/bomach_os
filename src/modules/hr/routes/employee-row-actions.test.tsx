import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from '@tanstack/react-router'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import type { EmployeeDto } from '@/modules/hr/employees.api'

import { EmployeeRowActions } from './employee-row-actions'

const employee = {
  id: 23,
  user_id: 52,
  employee_id: 'EMP-052',
  first_name: 'Amaka',
  last_name: 'Okafor',
  employment_status: 'active',
  employment_is_active: true,
  account_is_active: true,
} as EmployeeDto

async function renderActions(
  employeeOverride: Partial<EmployeeDto> = {},
  permissions = { canView: true, canUpdate: true, canExit: true },
) {
  const onEdit = vi.fn()
  const onStatusChange = vi.fn()
  const onExit = vi.fn()
  const rootRoute = createRootRoute({ component: Outlet })
  const actionsRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: '/',
    component: () => (
      <>
        <button type="button">Before actions</button>
        <EmployeeRowActions
          employee={{ ...employee, ...employeeOverride }}
          {...permissions}
          onEdit={onEdit}
          onStatusChange={onStatusChange}
          onExit={onExit}
        />
        <button type="button">After actions</button>
      </>
    ),
  })
  const profileRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: '/hr/employees/$userId',
    component: () => <p>Employee profile destination</p>,
  })
  const router = createRouter({
    routeTree: rootRoute.addChildren([actionsRoute, profileRoute]),
    history: createMemoryHistory({ initialEntries: ['/'] }),
  })
  render(<RouterProvider router={router} />)
  await screen.findByText('Before actions')
  return { onEdit, onStatusChange, onExit }
}

async function openActions(user: ReturnType<typeof userEvent.setup>) {
  await user.click(screen.getByRole('button', { name: 'More actions for Amaka Okafor' }))
  return screen.findByRole('menu', { name: 'Actions for Amaka Okafor' })
}

describe('EmployeeRowActions', () => {
  it('keeps the primary actions visible and dispatches overflow lifecycle actions', async () => {
    const user = userEvent.setup()
    const { onStatusChange, onExit, onEdit } = await renderActions()
    expect(screen.getByRole('link', { name: 'View Amaka Okafor' })).toBeVisible()
    expect(screen.getByRole('button', { name: 'Edit details' })).toBeVisible()
    const menu = await openActions(user)

    expect(menu).toHaveTextContent('Manage leave')
    expect(menu).toHaveTextContent('Suspend access')
    expect(menu).toHaveTextContent('Deactivate employee')
    expect(menu).toHaveTextContent('Exit / offboard')
    await user.click(screen.getByRole('button', { name: 'Edit details' }))
    expect(onEdit).toHaveBeenCalledWith(expect.objectContaining({ user_id: 52 }))

    await openActions(user)
    await user.click(withinMenu(await screen.findByRole('menu'), 'Exit / offboard'))
    expect(onExit).toHaveBeenCalledWith(expect.objectContaining({ user_id: 52 }))

    await openActions(user)
    await user.click(withinMenu(await screen.findByRole('menu'), 'Manage leave'))
    expect(await screen.findByText('Employee profile destination')).toBeInTheDocument()
    expect(onStatusChange).not.toHaveBeenCalled()
  })

  it.each([
    {
      status: 'on-leave',
      account_is_active: true,
      expected: [
        'Manage leave / return',
        'Suspend access',
        'Deactivate employee',
        'Exit / offboard',
      ],
      absent: ['Activate employee'],
    },
    {
      status: 'suspended',
      account_is_active: false,
      expected: ['Manage leave', 'Activate employee', 'Deactivate employee', 'Exit / offboard'],
      absent: ['Suspend access'],
    },
    {
      status: 'inactive',
      account_is_active: false,
      expected: ['Activate employee', 'Exit / offboard'],
      absent: ['Deactivate employee', 'Suspend access', 'Manage leave'],
    },
    {
      status: 'terminated',
      account_is_active: false,
      expected: ['View employee', 'Edit details'],
      absent: ['Activate employee', 'Exit / offboard'],
    },
  ])(
    'shows valid lifecycle actions for $status records',
    async ({ status, account_is_active, expected, absent }) => {
      const user = userEvent.setup()
      await renderActions({ employment_status: status, account_is_active })
      const trigger = screen.queryByRole('button', { name: 'More actions for Amaka Okafor' })
      const menu = trigger ? await openActions(user) : null
      const visibleText = document.body.textContent ?? ''
      for (const label of expected) {
        expect(menu?.textContent ?? visibleText).toContain(label)
      }
      for (const label of absent) {
        expect(menu?.textContent ?? visibleText).not.toContain(label)
      }
      if (status === 'terminated') {
        expect(screen.getByRole('link', { name: 'View Amaka Okafor' })).toBeVisible()
        expect(screen.getByRole('button', { name: 'Edit details' })).toBeVisible()
        expect(trigger).not.toBeInTheDocument()
      }
    },
  )

  it.each(['inactive', 'suspended'] as const)(
    'allows activation when the %s employment status disagrees with the active account flag',
    async (status) => {
      const user = userEvent.setup()
      const { onStatusChange } = await renderActions({
        employment_status: status,
        account_is_active: true,
      })
      const menu = await openActions(user)

      await user.click(withinMenu(menu, 'Activate employee'))
      expect(onStatusChange).toHaveBeenCalledWith(
        expect.objectContaining({ user_id: 52 }),
        'active',
      )
    },
  )

  it('hides records and actions the operator is not authorized to view, edit, or exit', async () => {
    await renderActions({}, { canView: false, canUpdate: false, canExit: false })
    expect(
      screen.queryByRole('button', { name: 'More actions for Amaka Okafor' }),
    ).not.toBeInTheDocument()
  })

  it('supports keyboard navigation, Escape restoration, and direct profile navigation', async () => {
    const user = userEvent.setup()
    await renderActions()
    const trigger = screen.getByRole('button', { name: 'More actions for Amaka Okafor' })
    await user.click(trigger)
    const leaveAction = await screen.findByRole('menuitem', {
      name: 'Manage leave for Amaka Okafor',
    })
    await waitFor(() => expect(leaveAction).toHaveFocus())
    await user.keyboard('{ArrowDown}')
    expect(screen.getByRole('menuitem', { name: 'Suspend access' })).toHaveFocus()
    await user.keyboard('{Escape}')
    await waitFor(() => expect(trigger).toHaveFocus())
    await user.click(screen.getByRole('link', { name: 'View Amaka Okafor' }))
    expect(await screen.findByText('Employee profile destination')).toBeInTheDocument()
  })
})

function withinMenu(menu: HTMLElement, label: string) {
  const item = Array.from(menu.querySelectorAll<HTMLElement>('[role="menuitem"]')).find((node) =>
    node.textContent?.includes(label),
  )
  if (!item) throw new Error(`Missing employee action: ${label}`)
  return item
}
