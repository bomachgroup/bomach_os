import { createElement, type ReactNode } from 'react'
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

import {
  assetsApi,
  type AssetChoicesDto,
  type AssetDto,
  type AssetWriteInput,
} from '@/modules/company/assets.api'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { validateAssetsSearch } from '@/modules/company/assets.search'

import { AssetsPage } from './assets-page'
import { KnowledgeBasePage } from './knowledge-base-page'

const showToast = vi.fn()
let queryClient: QueryClient

const asset: AssetDto = {
  id: 41,
  name: 'Company laptop',
  asset_type: 'laptop',
  branch: 'North Office',
  assigned_to_id: 12,
  department_id: 3,
  purchase_date: '2026-01-10',
  value: '1250000.00',
  vendor: 'Example Supplier',
  invoice_number: 'INV-ASSET-41',
  status: 'in_use',
  warranty_expiry_date: '2027-01-10',
  notes: 'Assigned to field operations.',
  serial_number: 'SERIAL-0041',
  imei: '356000111222333',
  manufacturer: 'Example',
  documents: [
    { name: 'Warranty.pdf', type: 'Document', url: 'https://files.example.test/warranty.pdf' },
  ],
  created_at: '2026-01-10T10:00:00Z',
  updated_at: '2026-01-10T10:00:00Z',
}

const choices: AssetChoicesDto = {
  branches: [{ value: 'North Office', label: 'North Office' }],
  employees: [{ value: '12', label: 'Mina Yusuf', description: 'EMP-012' }],
  departments: [{ value: '3', label: 'Operations' }],
}

function session(permissions: AuthenticatedSession['permissions']): AuthenticatedSession {
  return {
    user: {
      id: 7,
      email: 'asset-admin@example.test',
      username: 'asset-admin',
      is_verified: true,
      created_at: '2026-01-01T00:00:00Z',
      role: null,
      permissions,
    },
    employee: {
      user_id: 7,
      employee_id: 'EMP-007',
      username: 'asset-admin',
      email: 'asset-admin@example.test',
    },
    roles: [],
    permissions,
  }
}

function renderAssets(path: string, permissions: AuthenticatedSession['permissions']) {
  queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false, gcTime: 0 },
      mutations: { retry: false },
    },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, session(permissions))
  const root = createRootRoute()
  const protectedRoute = createRoute({
    getParentRoute: () => root,
    id: '_protected',
    component: Outlet,
  })
  const assetsRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/company/assets',
    validateSearch: validateAssetsSearch,
    component: AssetsPage,
  })
  const knowledgeRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/company/knowledge-base',
    component: KnowledgeBasePage,
  })
  const router = createRouter({
    routeTree: root.addChildren([protectedRoute.addChildren([assetsRoute, knowledgeRoute])]),
    history: createMemoryHistory({ initialEntries: [path] }),
  })
  return render(
    createElement(
      QueryClientProvider,
      { client: queryClient },
      createElement(
        ToastContext.Provider,
        { value: { showToast, dismissToast: vi.fn() } },
        createElement(RouterProvider, { router }),
      ),
    ) as ReactNode,
  )
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

describe('Company Assets and Knowledge Base pages', () => {
  beforeEach(() => {
    vi.spyOn(assetsApi, 'list').mockResolvedValue({ count: 1, items: [asset] })
    vi.spyOn(assetsApi, 'choices').mockResolvedValue(choices)
    vi.spyOn(assetsApi, 'create').mockImplementation(async (input: AssetWriteInput) => ({
      ...asset,
      ...input,
      id: 42,
    }))
    vi.spyOn(assetsApi, 'update').mockImplementation(async (_id, input) => ({
      ...asset,
      ...input,
    }))
    vi.spyOn(assetsApi, 'remove').mockResolvedValue({ detail: 'Deleted successfully' })
    vi.spyOn(assetsApi, 'upload').mockResolvedValue({ url: 'https://files.example.test/uploaded' })
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
    showToast.mockReset()
  })

  it('shows the paged register and opens the complete asset detail view', async () => {
    const user = userEvent.setup()
    renderAssets('/company/assets?page=1', { assets: ['list'] })

    expect(await screen.findByRole('heading', { name: 'Company laptop' })).toBeVisible()
    const table = screen.getByRole('table')
    expect(within(table).getByRole('columnheader', { name: 'Asset' })).toHaveClass('text-left')
    expect(screen.getByText('Page 1 of 1')).toBeVisible()
    await user.click(
      (await screen.findAllByRole('button', { name: 'Actions for Company laptop' }))[0]!,
    )
    const menu = await screen.findByRole('menu', { name: 'Actions for Company laptop' })
    await user.click(within(menu).getByRole('menuitem', { name: 'View details' }))

    const dialog = await screen.findByRole('dialog', { name: 'Company laptop' })
    expect(within(dialog).getByText('SERIAL-0041')).toBeVisible()
    expect(within(dialog).getByText('North Office')).toBeVisible()
    expect(within(dialog).getByText('Assigned to field operations.')).toBeVisible()
    expect(within(dialog).getByRole('link', { name: 'Open' })).toHaveAttribute(
      'href',
      'https://files.example.test/warranty.pdf',
    )
  })

  it('shows a recoverable page error when the asset register cannot load', async () => {
    vi.mocked(assetsApi.list).mockRejectedValueOnce(new Error('Local service unavailable.'))
    const user = userEvent.setup()
    renderAssets('/company/assets', { assets: ['list'] })

    expect(await screen.findByRole('heading', { name: 'Assets could not be loaded' })).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(await screen.findByRole('heading', { name: 'Company laptop' })).toBeVisible()
  })

  it('creates an asset after validating required name and branch fields', async () => {
    const user = userEvent.setup()
    renderAssets('/company/assets', { assets: ['list', 'create'] })
    await user.click(await screen.findByRole('button', { name: 'New asset' }))

    const dialog = await screen.findByRole('dialog', { name: 'New asset' })
    expect(
      within(dialog).getByRole('progressbar', { name: 'Asset setup progress' }),
    ).toHaveAttribute('aria-valuenow', '1')
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))
    expect(await within(dialog).findByText('Enter an asset name.')).toBeVisible()
    expect(within(dialog).getByLabelText(/Asset name/)).toHaveFocus()

    await user.type(within(dialog).getByLabelText(/Asset name/), 'Survey laptop')
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))
    expect(await within(dialog).findByText('Choose a branch.')).toBeVisible()
    await waitFor(() =>
      expect(within(dialog).getByRole('combobox', { name: 'Branch' })).toBeEnabled(),
    )
    await user.click(within(dialog).getByRole('combobox', { name: 'Branch' }))
    const branchListbox = await within(dialog).findByRole('listbox')
    await user.click(within(branchListbox).getByRole('option', { name: 'North Office' }))
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))
    expect(
      await within(dialog).findByRole('heading', { name: 'Purchase, warranty and records' }),
    ).toBeVisible()
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))
    expect(await within(dialog).findByRole('heading', { name: 'Review and confirm' })).toBeVisible()
    const review = within(dialog).getByRole('region', { name: 'Review asset details' })
    expect(within(review).getByRole('heading', { name: 'Survey laptop' })).toBeVisible()
    expect(within(review).getByText('North Office')).toBeVisible()
    expect(within(review).getByText(/Nothing is saved until you confirm/)).toBeVisible()
    await user.click(within(review).getByRole('button', { name: 'Edit Location and assignment' }))
    expect(
      await within(dialog).findByRole('heading', { name: 'Location and assignment', level: 2 }),
    ).toBeVisible()
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))
    expect(await within(dialog).findByRole('heading', { name: 'Review and confirm' })).toBeVisible()
    await user.click(within(dialog).getByRole('button', { name: 'Create asset' }))

    await waitFor(() =>
      expect(assetsApi.create).toHaveBeenCalledWith(
        expect.objectContaining({
          name: 'Survey laptop',
          asset_type: 'equipment',
          branch: 'North Office',
          assigned_to_id: null,
          department_id: null,
        }),
      ),
    )
    expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'Asset created' }))
    await waitFor(() => expect(screen.queryByRole('dialog', { name: 'New asset' })).toBeNull())
  })

  it('updates and deletes assets when the matching permissions are present', async () => {
    const user = userEvent.setup()
    renderAssets('/company/assets', {
      assets: ['list', 'update', 'delete'],
    })

    await user.click(
      (await screen.findAllByRole('button', { name: 'Actions for Company laptop' }))[0]!,
    )
    let menu = await screen.findByRole('menu', { name: 'Actions for Company laptop' })
    await user.click(within(menu).getByRole('menuitem', { name: 'Edit asset' }))
    const editDialog = await screen.findByRole('dialog', { name: 'Edit asset' })
    const nameInput = within(editDialog).getByLabelText(/Asset name/)
    expect(nameInput).toHaveValue('Company laptop')
    await user.clear(nameInput)
    await user.type(nameInput, 'Updated laptop')
    await user.click(within(editDialog).getByRole('button', { name: 'Next' }))
    await waitFor(() =>
      expect(within(editDialog).getByRole('combobox', { name: 'Branch' })).toBeEnabled(),
    )
    await user.click(within(editDialog).getByRole('button', { name: 'Next' }))
    await user.click(within(editDialog).getByRole('button', { name: 'Next' }))
    expect(within(editDialog).getByText('SERIAL-0041')).toBeVisible()
    await user.click(within(editDialog).getByRole('button', { name: 'Save changes' }))
    await waitFor(() =>
      expect(assetsApi.update).toHaveBeenCalledWith(
        asset.id,
        expect.objectContaining({ name: 'Updated laptop' }),
      ),
    )

    await user.click(
      (await screen.findAllByRole('button', { name: 'Actions for Company laptop' }))[0]!,
    )
    menu = await screen.findByRole('menu', { name: 'Actions for Company laptop' })
    await user.click(within(menu).getByRole('menuitem', { name: 'Delete asset' }))
    const deleteDialog = await screen.findByRole('dialog', { name: 'Delete asset?' })
    await user.click(within(deleteDialog).getByRole('button', { name: 'Delete asset' }))
    await waitFor(() => expect(assetsApi.remove).toHaveBeenCalledWith(asset.id))
  })

  it('keeps the review step and draft open when the backend rejects a save', async () => {
    vi.mocked(assetsApi.create).mockRejectedValueOnce(new Error('Asset service unavailable.'))
    const user = userEvent.setup()
    renderAssets('/company/assets', { assets: ['list', 'create'] })
    await user.click(await screen.findByRole('button', { name: 'New asset' }))

    const dialog = await screen.findByRole('dialog', { name: 'New asset' })
    await user.type(within(dialog).getByLabelText(/Asset name/), 'QA-Asset-failed-save')
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))
    await waitFor(() =>
      expect(within(dialog).getByRole('combobox', { name: 'Branch' })).toBeEnabled(),
    )
    await user.click(within(dialog).getByRole('combobox', { name: 'Branch' }))
    const branchListbox = await within(dialog).findByRole('listbox')
    await user.click(within(branchListbox).getByRole('option', { name: 'North Office' }))
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))
    await user.click(within(dialog).getByRole('button', { name: 'Create asset' }))

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'An unexpected problem occurred. Please try again.',
    )
    expect(within(dialog).getByRole('heading', { name: 'Review and confirm' })).toBeVisible()
    expect(
      within(dialog).getByRole('region', { name: 'Review asset details' }).querySelector('h3'),
    ).toHaveTextContent('QA-Asset-failed-save')
    expect(within(dialog).getByRole('button', { name: 'Create asset' })).toBeEnabled()
  })

  it('blocks location until asset choices recover and can be retried', async () => {
    vi.mocked(assetsApi.choices).mockRejectedValueOnce(new Error('Choices are unavailable.'))
    const user = userEvent.setup()
    renderAssets('/company/assets', { assets: ['list', 'create'] })
    await user.click(await screen.findByRole('button', { name: 'New asset' }))

    const dialog = await screen.findByRole('dialog', { name: 'New asset' })
    await user.type(within(dialog).getByLabelText(/Asset name/), 'QA-Asset-choice-retry')
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))
    expect(
      await within(dialog).findByText('An unexpected problem occurred. Please try again.'),
    ).toBeVisible()
    expect(within(dialog).getByRole('button', { name: 'Next' })).toBeDisabled()

    await user.click(within(dialog).getByRole('button', { name: 'Try again' }))
    await waitFor(() =>
      expect(within(dialog).getByRole('combobox', { name: 'Branch' })).toBeEnabled(),
    )
    await user.click(within(dialog).getByRole('combobox', { name: 'Branch' }))
    expect(await within(dialog).findByRole('option', { name: 'North Office' })).toBeVisible()
  })

  it('includes uploaded document metadata in the review and create payload', async () => {
    vi.mocked(assetsApi.upload).mockResolvedValueOnce({
      url: 'https://files.example.test/receipt.pdf',
    })
    const user = userEvent.setup()
    renderAssets('/company/assets', { assets: ['list', 'create'] })
    await user.click(await screen.findByRole('button', { name: 'New asset' }))

    const dialog = await screen.findByRole('dialog', { name: 'New asset' })
    await user.type(within(dialog).getByLabelText(/Asset name/), 'QA-Asset-upload-flow')
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))
    await waitFor(() =>
      expect(within(dialog).getByRole('combobox', { name: 'Branch' })).toBeEnabled(),
    )
    await user.click(within(dialog).getByRole('combobox', { name: 'Branch' }))
    const branchListbox = await within(dialog).findByRole('listbox')
    await user.click(within(branchListbox).getByRole('option', { name: 'North Office' }))
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))

    const file = new File(['synthetic asset receipt'], 'receipt.pdf', { type: 'application/pdf' })
    await user.upload(within(dialog).getByLabelText('Choose document to upload'), file)
    const documentsSection = within(dialog)
      .getByRole('heading', { name: 'Documents and notes' })
      .closest('section')
    expect(documentsSection).not.toHaveAttribute('hidden')
    expect(await within(documentsSection!).findByText('receipt.pdf')).toBeVisible()
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))
    expect(
      within(within(dialog).getByRole('region', { name: 'Review asset details' })).getByText(
        'receipt.pdf',
      ),
    ).toBeVisible()
    await user.click(within(dialog).getByRole('button', { name: 'Create asset' }))

    await waitFor(() =>
      expect(assetsApi.create).toHaveBeenCalledWith(
        expect.objectContaining({
          documents: [
            {
              name: 'receipt.pdf',
              type: 'Document',
              url: 'https://files.example.test/receipt.pdf',
            },
          ],
        }),
      ),
    )
  })

  it('shows a safe upload error and does not attach a file when storage fails', async () => {
    vi.mocked(assetsApi.upload).mockRejectedValueOnce(new Error('Storage credential details'))
    const user = userEvent.setup()
    renderAssets('/company/assets', { assets: ['list', 'create'] })
    await user.click(await screen.findByRole('button', { name: 'New asset' }))

    const dialog = await screen.findByRole('dialog', { name: 'New asset' })
    await user.type(within(dialog).getByLabelText(/Asset name/), 'QA-Asset-upload-error')
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))
    await waitFor(() =>
      expect(within(dialog).getByRole('combobox', { name: 'Branch' })).toBeEnabled(),
    )
    await user.click(within(dialog).getByRole('combobox', { name: 'Branch' }))
    const branchListbox = await within(dialog).findByRole('listbox')
    await user.click(within(branchListbox).getByRole('option', { name: 'North Office' }))
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))

    const file = new File(['synthetic local QA attachment'], 'qa-attachment.pdf', {
      type: 'application/pdf',
    })
    await user.upload(within(dialog).getByLabelText('Choose document to upload'), file)

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'An unexpected problem occurred. Please try again.',
    )
    expect(within(dialog).queryByText('qa-attachment.pdf')).not.toBeInTheDocument()
    expect(within(dialog).getByText('No files attached.')).toBeVisible()
    expect(assetsApi.upload).toHaveBeenCalledTimes(1)
  })

  it('rejects oversized uploads before contacting storage', async () => {
    const user = userEvent.setup()
    renderAssets('/company/assets', { assets: ['list', 'create'] })
    await user.click(await screen.findByRole('button', { name: 'New asset' }))

    const dialog = await screen.findByRole('dialog', { name: 'New asset' })
    await user.type(within(dialog).getByLabelText(/Asset name/), 'QA-Asset-upload-size')
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))
    await waitFor(() =>
      expect(within(dialog).getByRole('combobox', { name: 'Branch' })).toBeEnabled(),
    )
    await user.click(within(dialog).getByRole('combobox', { name: 'Branch' }))
    const branchListbox = await within(dialog).findByRole('listbox')
    await user.click(within(branchListbox).getByRole('option', { name: 'North Office' }))
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))

    const oversizedFile = new File([new Uint8Array(15 * 1024 * 1024 + 1)], 'oversized.pdf', {
      type: 'application/pdf',
    })
    await user.upload(within(dialog).getByLabelText('Choose document to upload'), oversizedFile)

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'Choose a file smaller than 15 MB.',
    )
    expect(assetsApi.upload).not.toHaveBeenCalled()
  })

  it('blocks invalid asset values before allowing the user to review', async () => {
    const user = userEvent.setup()
    renderAssets('/company/assets', { assets: ['list', 'create'] })
    await user.click(await screen.findByRole('button', { name: 'New asset' }))

    const dialog = await screen.findByRole('dialog', { name: 'New asset' })
    await user.type(within(dialog).getByLabelText(/Asset name/), 'QA-Asset-invalid-value')
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))
    await waitFor(() =>
      expect(within(dialog).getByRole('combobox', { name: 'Branch' })).toBeEnabled(),
    )
    await user.click(within(dialog).getByRole('combobox', { name: 'Branch' }))
    const branchListbox = await within(dialog).findByRole('listbox')
    await user.click(within(branchListbox).getByRole('option', { name: 'North Office' }))
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))

    const valueInput = within(dialog).getByLabelText('Asset value')
    await user.type(valueInput, '-1')
    await user.click(within(dialog).getByRole('button', { name: 'Next' }))

    expect(await within(dialog).findByText(/Enter a non-negative amount/)).toBeVisible()
    expect(within(dialog).getByLabelText('Asset value')).toHaveFocus()
    expect(
      within(dialog).getByRole('heading', { name: 'Purchase, warranty and records' }),
    ).toBeVisible()
    expect(
      within(dialog).queryByRole('heading', { name: 'Review and confirm' }),
    ).not.toBeInTheDocument()
    expect(assetsApi.create).not.toHaveBeenCalled()
  })

  it('hides mutation controls when the user has list access only', async () => {
    renderAssets('/company/assets', { assets: ['list'] })
    expect(await screen.findAllByText('Company laptop')).not.toHaveLength(0)
    expect(screen.queryByRole('button', { name: 'New asset' })).not.toBeInTheDocument()
    await userEvent
      .setup()
      .click((await screen.findAllByRole('button', { name: 'Actions for Company laptop' }))[0]!)
    const menu = await screen.findByRole('menu', { name: 'Actions for Company laptop' })
    expect(within(menu).getByRole('menuitem', { name: 'View details' })).toBeVisible()
    expect(within(menu).queryByRole('menuitem', { name: 'Edit asset' })).not.toBeInTheDocument()
    expect(within(menu).queryByRole('menuitem', { name: 'Delete asset' })).not.toBeInTheDocument()
  })

  it('supports menu keyboard navigation and restores focus on Escape', async () => {
    const user = userEvent.setup()
    renderAssets('/company/assets', { assets: ['list', 'update', 'delete'] })
    const trigger = (
      await screen.findAllByRole('button', { name: 'Actions for Company laptop' })
    )[0]!
    await user.click(trigger)
    const menu = await screen.findByRole('menu', { name: 'Actions for Company laptop' })
    const viewItem = within(menu).getByRole('menuitem', { name: 'View details' })
    const editItem = within(menu).getByRole('menuitem', { name: 'Edit asset' })
    const deleteItem = within(menu).getByRole('menuitem', { name: 'Delete asset' })

    await waitFor(() => expect(viewItem).toHaveFocus())
    await user.keyboard('{ArrowDown}')
    expect(editItem).toHaveFocus()
    await user.keyboard('{End}')
    expect(deleteItem).toHaveFocus()
    await user.keyboard('{Escape}')
    expect(
      screen.queryByRole('menu', { name: 'Actions for Company laptop' }),
    ).not.toBeInTheDocument()
    await waitFor(() => expect(trigger).toHaveFocus())
  })

  it('does not expose delete when only list and update permissions are granted', async () => {
    const user = userEvent.setup()
    renderAssets('/company/assets', { assets: ['list', 'update'] })
    await user.click(
      (await screen.findAllByRole('button', { name: 'Actions for Company laptop' }))[0]!,
    )

    const menu = await screen.findByRole('menu', { name: 'Actions for Company laptop' })
    expect(within(menu).getByRole('menuitem', { name: 'View details' })).toBeVisible()
    expect(within(menu).getByRole('menuitem', { name: 'Edit asset' })).toBeVisible()
    expect(within(menu).queryByRole('menuitem', { name: 'Delete asset' })).not.toBeInTheDocument()
  })

  it('allows delete without exposing edit when only delete permission is granted', async () => {
    const user = userEvent.setup()
    renderAssets('/company/assets', { assets: ['list', 'delete'] })
    await user.click(
      (await screen.findAllByRole('button', { name: 'Actions for Company laptop' }))[0]!,
    )

    const menu = await screen.findByRole('menu', { name: 'Actions for Company laptop' })
    expect(within(menu).getByRole('menuitem', { name: 'View details' })).toBeVisible()
    expect(within(menu).queryByRole('menuitem', { name: 'Edit asset' })).not.toBeInTheDocument()
    expect(within(menu).getByRole('menuitem', { name: 'Delete asset' })).toBeVisible()
  })

  it('keeps Knowledge Base unavailable rather than showing fabricated document records', async () => {
    renderAssets('/company/knowledge-base', { roles: ['list'] })

    expect(
      await screen.findByRole('heading', { name: 'Company Knowledge Base is unavailable' }),
    ).toBeVisible()
    expect(screen.getByText(/does not publish a company-wide Knowledge Base/)).toBeVisible()
    expect(screen.getByRole('link', { name: 'Open My Role resources' })).toHaveAttribute(
      'href',
      '/dashboard/role',
    )
  })
})
