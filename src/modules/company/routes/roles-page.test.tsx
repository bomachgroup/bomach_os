import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { ApiError } from '@/shared/api/api-error'
import type { RoleDto, RoleWriteInput } from '@/modules/company/roles.api'
import { RoleEditor } from '@/modules/company/routes/roles-page'
import { getPermissionActionPresentation } from '@/shared/permissions/permission-action-presentation'

async function chooseDropdownOption(
  user: ReturnType<typeof userEvent.setup>,
  label: string,
  optionName: RegExp,
) {
  await user.click(screen.getByRole('combobox', { name: new RegExp(`^${label}`) }))
  await user.click(await screen.findByRole('option', { name: optionName }))
}

async function moveToPermissions(
  user: ReturnType<typeof userEvent.setup>,
  name = 'People manager',
  waitForCatalogue = true,
) {
  await user.type(screen.getByRole('textbox', { name: /Role name/ }), name)
  await user.click(screen.getByRole('button', { name: 'Continue' }))
  await user.click(screen.getByRole('button', { name: 'Continue' }))
  if (waitForCatalogue) {
    await waitFor(
      () =>
        expect(
          screen.queryByRole('status', { name: 'Loading permission catalogue' }),
        ).not.toBeInTheDocument(),
      { timeout: 10_000 },
    )
  }
}

Object.defineProperty(HTMLDialogElement.prototype, 'showModal', {
  configurable: true,
  value: function showModal(this: HTMLDialogElement) {
    this.open = true
    this.setAttribute('open', '')
  },
})

Object.defineProperty(HTMLDialogElement.prototype, 'close', {
  configurable: true,
  value: function close(this: HTMLDialogElement) {
    this.open = false
    this.removeAttribute('open')
    this.dispatchEvent(new Event('close'))
  },
})

function renderEditor({
  onSave = vi.fn(),
  permissions = {
    employees: ['create', 'view', 'list'],
    roles: ['view', 'update'],
  },
  permissionMapLoaded = true,
  permissionMapError,
  onRetryPermissionMap = vi.fn(),
  branchChoicesLoaded = true,
  branchChoicesError,
  onRetryBranches = vi.fn(),
  role = null,
  initialStep = 'details',
  canEditDescription = true,
  canViewDescription = true,
  error,
  isSaving = false,
}: {
  onSave?: (input: RoleWriteInput) => void
  permissions?: Record<string, string[]>
  permissionMapLoaded?: boolean
  permissionMapError?: unknown
  onRetryPermissionMap?: () => void
  branchChoicesLoaded?: boolean
  branchChoicesError?: unknown
  onRetryBranches?: () => void
  role?: RoleDto | null
  initialStep?: 'details' | 'permissions'
  canEditDescription?: boolean
  canViewDescription?: boolean
  error?: unknown
  isSaving?: boolean
} = {}) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  })
  const renderTree = (nextError = error) => (
    <QueryClientProvider client={queryClient}>
      <RoleEditor
        open
        role={role}
        initialStep={initialStep}
        onClose={vi.fn()}
        permissions={permissions}
        branches={[{ id: 7, branch_name: 'Lagos branch' }]}
        branchChoicesLoaded={branchChoicesLoaded}
        branchChoicesLoading={!branchChoicesLoaded && !branchChoicesError}
        branchChoicesError={branchChoicesError}
        onRetryBranches={onRetryBranches}
        canEditDescription={canEditDescription}
        canViewDescription={canViewDescription}
        permissionMapLoaded={permissionMapLoaded}
        permissionMapLoading={false}
        permissionMapError={permissionMapError}
        onRetryPermissionMap={onRetryPermissionMap}
        onSave={onSave}
        isSaving={isSaving}
        error={nextError}
      />
    </QueryClientProvider>
  )
  const result = render(renderTree())
  const rerenderWithError = (nextError: unknown) => result.rerender(renderTree(nextError))
  return { ...result, queryClient, rerenderWithError }
}

describe('role editor flow', () => {
  beforeEach(() => window.localStorage.clear())

  it('reuses the same icon for scoped and own view/list actions', () => {
    expect(getPermissionActionPresentation('view_own').icon).toBe(
      getPermissionActionPresentation('view').icon,
    )
    expect(getPermissionActionPresentation('list_own').icon).toBe(
      getPermissionActionPresentation('list').icon,
    )
  })

  it('opens a large permission catalogue without eagerly creating hidden tooltip portals', async () => {
    const user = userEvent.setup()
    const permissions = Object.fromEntries(
      Array.from({ length: 40 }, (_, index) => [
        `qa_permission_resource_${index}`,
        ['create', 'view', 'list', 'update', 'delete'],
      ]),
    )
    renderEditor({ permissions })

    await moveToPermissions(user, 'Permission performance check', false)

    const allPermissions = screen.getByRole('region', { name: 'All permissions' })
    expect(screen.getByRole('heading', { name: 'Permissions' })).toBeInTheDocument()
    expect(
      Number(allPermissions.querySelector('ul')?.getAttribute('data-rendered-group-count')),
    ).toBeGreaterThan(0)
    await waitFor(
      () =>
        expect(allPermissions.querySelector('ul')).toHaveAttribute(
          'data-rendered-group-count',
          '40',
        ),
      { timeout: 3_000 },
    )
    expect(allPermissions.querySelectorAll('[data-permission-option]')).toHaveLength(200)
    expect(
      screen.queryByRole('status', { name: 'Loading permission catalogue' }),
    ).not.toBeInTheDocument()
    expect(document.querySelectorAll('[role="tooltip"]')).toHaveLength(0)

    await user.click(screen.getByRole('button', { name: 'Back' }))
    expect(screen.getByRole('heading', { name: 'Responsibilities' })).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    const revisitedPermissions = screen.getByRole('region', { name: 'All permissions' })
    expect(
      Number(revisitedPermissions.querySelector('ul')?.getAttribute('data-rendered-group-count')),
    ).toBeGreaterThan(0)
    await waitFor(
      () =>
        expect(revisitedPermissions.querySelector('ul')).toHaveAttribute(
          'data-rendered-group-count',
          '40',
        ),
      { timeout: 3_000 },
    )
    expect(
      screen.queryByRole('status', { name: 'Loading permission catalogue' }),
    ).not.toBeInTheDocument()
    expect(revisitedPermissions.querySelectorAll('[data-permission-option]')).toHaveLength(200)

    const firstPermission = within(revisitedPermissions).getAllByRole('checkbox')[0]
    fireEvent.focus(firstPermission)
    expect(screen.getByRole('tooltip')).toBeInTheDocument()
    expect(document.querySelectorAll('[role="tooltip"]')).toHaveLength(1)
  }, 15_000)

  it('uses review-style resource cards with neutral and selected action chips', async () => {
    const user = userEvent.setup()
    renderEditor({
      permissions: {
        employees: ['create', 'view', 'list'],
        employee_documents: ['upload_own', 'view_own', 'list_own'],
      },
    })

    await moveToPermissions(user)
    const allPermissions = screen.getByRole('region', { name: 'All permissions' })
    expect(
      within(allPermissions).getByRole('group', { name: 'Employees permissions' }),
    ).toBeInTheDocument()
    expect(
      within(allPermissions).getByRole('group', { name: 'Employee Documents permissions' }),
    ).toBeInTheDocument()

    const uploadOwn = within(allPermissions).getByRole('checkbox', {
      name: 'Employee Documents Upload Own',
    })
    const uploadChip = uploadOwn.closest('[data-permission-option]')
    expect(uploadChip).toHaveAttribute('data-selected', 'false')
    expect(uploadChip).toHaveClass('bg-surface-muted', 'text-text-secondary')
    expect(within(uploadChip as HTMLElement).getByText('Upload Own')).toBeInTheDocument()
    expect(
      within(allPermissions).getByRole('heading', { name: 'Employee Documents' }),
    ).toBeInTheDocument()
    const uploadIcon = uploadChip?.querySelector('svg')
    expect(uploadIcon).toHaveClass('size-3.5')
    await user.click(uploadOwn)
    expect(uploadOwn).toBeChecked()
    expect(uploadChip).toHaveAttribute('data-selected', 'true')
    expect(uploadChip).toHaveClass('bg-info-subtle', 'text-info-foreground')

    await user.hover(uploadChip as HTMLElement)
    expect(await screen.findByRole('tooltip')).toHaveTextContent(
      'Add a document to your own employee file.',
    )

    await chooseDropdownOption(user, 'Work area', /People/)
    const peoplePermissions = screen.getByRole('region', { name: 'People permissions' })
    expect(
      within(peoplePermissions).getByRole('checkbox', { name: 'Employees Create' }),
    ).toBeInTheDocument()
    expect(
      within(peoplePermissions).getByRole('checkbox', { name: 'Employee Documents Upload Own' }),
    ).toBeChecked()
    expect(
      within(peoplePermissions).queryByRole('checkbox', { name: 'Roles View' }),
    ).not.toBeInTheDocument()

    await user.type(screen.getByRole('searchbox', { name: 'Search permissions' }), 'Upload Own')
    await user.click(screen.getByRole('button', { name: 'Select visible' }))
    expect(
      within(peoplePermissions).getByRole('checkbox', { name: 'Employee Documents Upload Own' }),
    ).toBeChecked()
    await user.click(screen.getByRole('button', { name: 'Clear visible' }))
    expect(
      within(peoplePermissions).getByRole('checkbox', { name: 'Employee Documents Upload Own' }),
    ).not.toBeChecked()
  })

  it('keeps the permission editor viewport stable when a permission is added or removed', async () => {
    const user = userEvent.setup()
    renderEditor({ permissions: { employees: ['create', 'view'], roles: ['view'] } })

    await moveToPermissions(user)

    const dialog = screen.getByRole('dialog', { name: 'Create role' })
    expect(dialog).toHaveClass('overflow-clip', 'tablet:h-[90dvh]')
    const createPermission = within(dialog).getByRole('checkbox', {
      name: 'Employees Create',
    })

    await user.click(createPermission)
    expect(createPermission).toBeChecked()
    expect(within(dialog).getByRole('button', { name: 'Review role' })).toBeInTheDocument()

    await user.click(createPermission)
    expect(createPermission).not.toBeChecked()
  })

  it('can open directly at the permissions step for an existing role', async () => {
    renderEditor({
      role: {
        id: 6,
        name: 'People manager',
        branches: [],
        permissions: { employees: ['view'] },
        created_at: '2026-01-01T00:00:00Z',
        updated_at: '2026-01-02T00:00:00Z',
      },
      initialStep: 'permissions',
      canEditDescription: false,
      canViewDescription: false,
    })

    expect(screen.getByRole('heading', { name: 'Permissions' })).toBeInTheDocument()
    expect(
      screen.getByRole('button', { name: 'Permissions, step 2 of 3, current step' }),
    ).toBeInTheDocument()
    await waitFor(() =>
      expect(
        screen.queryByRole('status', { name: 'Loading permission catalogue' }),
      ).not.toBeInTheDocument(),
    )
    expect(screen.getByRole('checkbox', { name: 'Employees View' })).toBeChecked()
  })

  it('sorts resource cards and their permission chips A–Z or Z–A', async () => {
    const user = userEvent.setup()
    renderEditor({
      permissions: {
        employees: ['view', 'create', 'list'],
        roles: ['update', 'view'],
      },
    })
    await moveToPermissions(user)

    const allPermissions = screen.getByRole('region', { name: 'All permissions' })
    const readOrder = () =>
      within(allPermissions)
        .getAllByRole('checkbox')
        .map((checkbox) => checkbox.getAttribute('aria-label'))

    expect(readOrder()).toEqual([
      'Employees Create',
      'Employees List',
      'Employees View',
      'Roles Update',
      'Roles View',
    ])

    await chooseDropdownOption(user, 'Order', /Name Z–A/)
    expect(readOrder()).toEqual([
      'Roles View',
      'Roles Update',
      'Employees View',
      'Employees List',
      'Employees Create',
    ])

    await user.click(within(allPermissions).getByRole('checkbox', { name: 'Employees View' }))
    await user.click(within(allPermissions).getByRole('checkbox', { name: 'Roles View' }))
    await user.click(screen.getByRole('checkbox', { name: 'Show selected permissions only' }))
    expect(readOrder()).toEqual(['Roles View', 'Employees View'])
  })

  it('remembers the chosen permission order after closing and reopening the editor', async () => {
    const user = userEvent.setup()
    const firstRender = renderEditor()
    await moveToPermissions(user)
    await chooseDropdownOption(user, 'Order', /Name Z–A/)
    expect(window.localStorage.getItem('company.roles.permission-sort')).toBe('za')

    firstRender.unmount()
    renderEditor()
    await moveToPermissions(user)
    expect(screen.getByRole('combobox', { name: /^Order/ })).toHaveTextContent('Name Z–A')
  })

  it('validates details, filters searchable permissions, and saves the selected role access', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn<(input: RoleWriteInput) => void>()
    renderEditor({ onSave })

    expect(screen.getByRole('heading', { name: 'Role details' })).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    expect(screen.getByText('Enter a role name before continuing.')).toBeInTheDocument()
    expect(screen.getByRole('textbox', { name: /Role name/ })).toHaveAttribute(
      'aria-invalid',
      'true',
    )

    await user.type(screen.getByRole('textbox', { name: /Role name/ }), 'People manager')
    await user.click(screen.getByRole('checkbox', { name: 'Lagos branch' }))
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    expect(onSave).not.toHaveBeenCalled()
    expect(screen.getByRole('heading', { name: 'Responsibilities' })).toBeInTheDocument()

    await user.type(screen.getByRole('textbox', { name: 'Purpose' }), 'Support the people team')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    expect(onSave).not.toHaveBeenCalled()
    expect(screen.getByRole('heading', { name: 'Permissions' })).toBeInTheDocument()
    await waitFor(() =>
      expect(
        screen.queryByRole('status', { name: 'Loading permission catalogue' }),
      ).not.toBeInTheDocument(),
    )
    expect(screen.getByRole('region', { name: 'All permissions' })).toBeInTheDocument()
    expect(screen.getByRole('checkbox', { name: 'Employees Create' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Select visible' })).toBeEnabled()

    await chooseDropdownOption(user, 'Work area', /People/)
    expect(screen.getByRole('button', { name: 'Select visible' })).toBeEnabled()
    await chooseDropdownOption(user, 'Order', /Name Z–A/)
    await user.type(screen.getByRole('searchbox', { name: 'Search permissions' }), 'employees')

    const employeePermissions = screen.getByRole('region', { name: 'People permissions' })
    const createPermission = within(employeePermissions).getByRole('checkbox', {
      name: 'Employees Create',
    })
    await user.click(createPermission)
    await user.click(screen.getByRole('checkbox', { name: 'Show selected permissions only' }))

    expect(screen.getByText('1 visible action · 1 selected')).toBeInTheDocument()
    expect(within(employeePermissions).getByRole('checkbox', { name: /Create/ })).toBeChecked()
    expect(
      within(employeePermissions).queryByRole('checkbox', { name: 'Employees View' }),
    ).not.toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: 'Review role' }))
    expect(onSave).not.toHaveBeenCalled()
    const review = screen.getByRole('region', { name: 'Role review' })
    expect(within(review).getByRole('heading', { name: 'People manager' })).toBeInTheDocument()
    expect(within(review).getByText('Lagos branch')).toBeInTheDocument()
    expect(within(review).getByText('Create')).toBeInTheDocument()
    const permissionSummary = within(review).getByRole('region', {
      name: 'Selected permissions by work area',
    })
    expect(permissionSummary).toHaveClass(/max-h-\[min\(52dvh,32rem\)\]/)
    expect(within(permissionSummary).getByText('Employees')).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Edit permissions' }))
    expect(screen.getByRole('heading', { name: 'Permissions' })).toBeInTheDocument()
    await waitFor(() =>
      expect(
        screen.queryByRole('status', { name: 'Loading permission catalogue' }),
      ).not.toBeInTheDocument(),
    )
    const reviewedPeople = screen.getByRole('region', { name: 'People permissions' })
    expect(within(reviewedPeople).getByRole('checkbox', { name: 'Employees Create' })).toBeChecked()
    await user.click(screen.getByRole('button', { name: 'Review role' }))
    await user.click(screen.getByRole('button', { name: 'Create role' }))
    await waitFor(() => expect(onSave).toHaveBeenCalledTimes(1))
    expect(onSave).toHaveBeenCalledWith({
      name: 'People manager',
      branch_ids: [7],
      permissions: { employees: ['create'] },
      description: {
        purpose: 'Support the people team',
        responsibilities: '',
        job_description: '',
      },
    })
  })

  it('keeps save unavailable until the permission map has loaded and offers a local retry', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn<(input: RoleWriteInput) => void>()
    const onRetryPermissionMap = vi.fn()
    renderEditor({
      onSave,
      permissions: {},
      permissionMapLoaded: false,
      permissionMapError: new Error('offline'),
      onRetryPermissionMap,
    })

    await user.type(screen.getByRole('textbox', { name: /Role name/ }), 'No access role')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    expect(screen.getByRole('heading', { name: 'Permissions' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Review role' })).toBeDisabled()

    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(onRetryPermissionMap).toHaveBeenCalledOnce()
    expect(onSave).not.toHaveBeenCalled()
  })

  it('blocks the flow until branch scope choices load and offers a retry', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn<(input: RoleWriteInput) => void>()
    const onRetryBranches = vi.fn()
    renderEditor({
      onSave,
      branchChoicesLoaded: false,
      branchChoicesError: new Error('offline'),
      onRetryBranches,
    })

    await user.type(screen.getByRole('textbox', { name: /Role name/ }), 'Scoped role')
    expect(screen.getByRole('button', { name: 'Continue' })).toBeDisabled()
    expect(screen.getByText('Branch choices could not load')).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Try again' }))

    expect(onRetryBranches).toHaveBeenCalledOnce()
    expect(onSave).not.toHaveBeenCalled()
  })

  it('shows only the details and permissions steps when description access is unavailable', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn<(input: RoleWriteInput) => void>()
    render(
      <QueryClientProvider client={new QueryClient()}>
        <RoleEditor
          open
          role={null}
          onClose={vi.fn()}
          permissions={{ employees: ['view'] }}
          branches={[]}
          canEditDescription={false}
          canViewDescription={false}
          permissionMapLoaded
          permissionMapLoading={false}
          onRetryPermissionMap={vi.fn()}
          onSave={onSave}
          isSaving={false}
        />
      </QueryClientProvider>,
    )

    expect(screen.queryByRole('button', { name: /Responsibilities, step/ })).not.toBeInTheDocument()
    await user.type(screen.getByRole('textbox', { name: /Role name/ }), 'Read only role')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    expect(screen.getByRole('heading', { name: 'Permissions' })).toBeInTheDocument()
    await waitFor(() =>
      expect(
        screen.queryByRole('status', { name: 'Loading permission catalogue' }),
      ).not.toBeInTheDocument(),
    )
    await user.click(screen.getByRole('button', { name: 'Review role' }))
    expect(screen.getByRole('heading', { name: 'Review role' })).toBeInTheDocument()
    expect(screen.queryByRole('heading', { name: 'Responsibilities' })).not.toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Create role' }))
    await waitFor(() =>
      expect(onSave).toHaveBeenCalledWith({
        name: 'Read only role',
        branch_ids: [],
        permissions: {},
      }),
    )
  })

  it('reviews and updates an existing role without changing scope or adding inaccessible description fields', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn<(input: RoleWriteInput) => void>()
    const role: RoleDto = {
      id: 6,
      name: 'Operations Coordinator',
      branches: [{ id: 7, branch_name: 'Lagos branch' }],
      permissions: { employees: ['view'] },
      created_at: '2026-01-01T00:00:00Z',
      updated_at: '2026-01-02T00:00:00Z',
    }
    renderEditor({
      role,
      onSave,
      canEditDescription: false,
      canViewDescription: false,
    })

    const nameInput = screen.getByRole('textbox', { name: /Role name/ })
    await user.clear(nameInput)
    await user.type(nameInput, 'Operations Lead')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Review role' }))

    const review = screen.getByRole('region', { name: 'Role review' })
    expect(within(review).getByRole('heading', { name: 'Operations Lead' })).toBeInTheDocument()
    expect(within(review).getByText('Lagos branch')).toBeInTheDocument()
    expect(within(review).getByText('1 action across 1 work area')).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    await waitFor(() =>
      expect(onSave).toHaveBeenCalledWith({
        name: 'Operations Lead',
        branch_ids: [7],
        permissions: { employees: ['view'] },
      }),
    )
  })

  it('requires review before saving an explicit zero-permission role', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn<(input: RoleWriteInput) => void>()
    renderEditor({
      permissions: {},
      onSave,
      canEditDescription: false,
      canViewDescription: false,
    })

    await user.type(screen.getByRole('textbox', { name: /Role name/ }), 'No access role')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Review role' }))
    expect(screen.getByRole('status')).toHaveTextContent('This role grants no permissions')
    expect(onSave).not.toHaveBeenCalled()

    await user.click(screen.getByRole('button', { name: 'Create role' }))
    await waitFor(() =>
      expect(onSave).toHaveBeenCalledWith({
        name: 'No access role',
        branch_ids: [],
        permissions: {},
      }),
    )
  })

  it('trims the role name, enforces its length limit, and preserves a selected branch through review', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn<(input: RoleWriteInput) => void>()
    renderEditor({
      onSave,
      canEditDescription: false,
      canViewDescription: false,
      permissions: {},
    })

    const nameInput = screen.getByRole('textbox', { name: /Role name/ })
    expect(nameInput).toHaveAttribute('maxLength', '120')
    await user.type(nameInput, 'x'.repeat(140))
    expect(nameInput).toHaveValue('x'.repeat(120))
    await user.clear(nameInput)
    await user.type(nameInput, '   ')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    expect(screen.getByText('Enter a role name before continuing.')).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Role details' })).toBeInTheDocument()

    await user.clear(nameInput)
    await user.type(nameInput, '  Branch Auditor  ')
    await user.click(screen.getByRole('checkbox', { name: 'Lagos branch' }))
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Review role' }))
    expect(screen.getByRole('heading', { name: 'Branch Auditor' })).toBeInTheDocument()
    expect(screen.getByText('Lagos branch')).toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: 'Create role' }))
    await waitFor(() =>
      expect(onSave).toHaveBeenCalledWith({
        name: 'Branch Auditor',
        branch_ids: [7],
        permissions: {},
      }),
    )
  })

  it('keeps role details visible alongside a server validation error', async () => {
    const user = userEvent.setup()
    const onSave = vi.fn<(input: RoleWriteInput) => void>()
    const editor = renderEditor({
      onSave,
      canEditDescription: false,
      canViewDescription: false,
    })

    await user.type(screen.getByRole('textbox', { name: /Role name/ }), 'Finance Manager')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Review role' }))
    await user.click(screen.getByRole('button', { name: 'Create role' }))
    await waitFor(() => expect(onSave).toHaveBeenCalledOnce())
    editor.rerenderWithError(new ApiError('Choose a unique role name.', { status: 400 }))
    expect(screen.getByRole('alert')).toHaveTextContent('Choose a unique role name.')
    expect(screen.getByRole('heading', { name: 'Finance Manager' })).toBeInTheDocument()
    expect(onSave).toHaveBeenCalledOnce()
  })
})
