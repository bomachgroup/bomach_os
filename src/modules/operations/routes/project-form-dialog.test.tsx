import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { ApiError } from '@/shared/api/api-error'
import { projectsApi, type ProjectWriteInput } from '../projects.api'
import { ProjectFormDialog } from './project-form-dialog'

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

const branchOptions = [{ id: 4, name: 'Enugu', code: 'ENU' }]
const clientOptions = [{ id: 8, name: 'Fortress Developments', email: 'client@example.test' }]

function renderForm(onSave = vi.fn<(_: ProjectWriteInput) => Promise<void>>()) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  })
  render(
    <QueryClientProvider client={queryClient}>
      <ProjectFormDialog
        open
        project={null}
        onOpenChange={vi.fn()}
        onSave={onSave}
        saving={false}
      />
    </QueryClientProvider>,
  )
  return onSave
}

async function chooseOption(
  user: ReturnType<typeof userEvent.setup>,
  label: string,
  option: string,
) {
  await user.click(screen.getByRole('combobox', { name: new RegExp(label) }))
  await user.click(await screen.findByRole('option', { name: new RegExp(option) }))
}

describe('ProjectFormDialog', () => {
  beforeEach(() => {
    vi.spyOn(projectsApi, 'branchOptions').mockResolvedValue(branchOptions)
    vi.spyOn(projectsApi, 'clientOptions').mockResolvedValue(clientOptions)
  })

  it('shows input-specific validation under the field and keeps the first step open', async () => {
    const user = userEvent.setup()
    renderForm()

    await user.click(screen.getByRole('button', { name: 'Next' }))

    expect(screen.getByRole('heading', { name: 'Project basics' })).toBeInTheDocument()
    const nameInput = screen.getByRole('textbox', { name: /Project name/ })
    expect(nameInput).toHaveAttribute('aria-invalid', 'true')
    const nameError = screen.getByText('Enter a project name.')
    expect(nameError).toHaveAttribute('role', 'status')
    expect(nameError.parentElement).toContainElement(nameInput)
    expect(screen.getByText('Select the branch that owns this project.')).toBeInTheDocument()
  })

  it('gives long client names a wider menu while keeping it inside the dialog', async () => {
    const user = userEvent.setup()
    renderForm()

    const dialog = screen.getByRole('dialog')
    const client = screen.getByRole('combobox', { name: /Client/ })
    vi.spyOn(dialog, 'getBoundingClientRect').mockReturnValue(new DOMRect(100, 100, 480, 520))
    vi.spyOn(client, 'getBoundingClientRect').mockReturnValue(new DOMRect(300, 360, 160, 42))
    await waitFor(() => expect(client).toBeEnabled())
    await user.click(client)

    const menu = await screen.findByRole('listbox')
    expect(menu).toHaveStyle({ width: '420px' })
    expect(menu).toHaveStyle({ left: '58px' })
  })

  it('moves through the stages, uses the shared date picker, and saves normalized project values', async () => {
    const user = userEvent.setup()
    const onSave = renderForm()

    await user.type(
      screen.getByRole('textbox', { name: /Project name/ }),
      '  Fortress City Phase 2  ',
    )
    await user.type(screen.getByRole('textbox', { name: /Project code/ }), ' fc-002 ')
    await user.type(screen.getByRole('textbox', { name: /Category/ }), 'Residential')
    await chooseOption(user, 'Owning branch', 'Enugu')
    await chooseOption(user, 'Client', 'Fortress Developments')
    await user.click(screen.getByRole('button', { name: 'Next' }))

    expect(screen.getByRole('heading', { name: 'Delivery plan' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Start date' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Target completion' })).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Review, step 3 of 3, available' }))

    expect(screen.getByRole('heading', { name: 'Review and confirm' })).toBeInTheDocument()
    expect(screen.getByText('Fortress City Phase 2')).toBeInTheDocument()
    expect(screen.getByText('Fortress Developments')).toBeInTheDocument()
    expect(screen.getByRole('region', { name: 'Project basics' })).toBeInTheDocument()
    expect(screen.getByRole('region', { name: 'Delivery plan' })).toBeInTheDocument()
    expect(onSave).not.toHaveBeenCalled()
    await user.click(screen.getByRole('button', { name: 'Edit delivery plan' }))
    expect(screen.getByRole('heading', { name: 'Delivery plan' })).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Review, step 3 of 3, available' }))
    expect(screen.getByRole('heading', { name: 'Review and confirm' })).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Create project' }))

    await waitFor(() => expect(onSave).toHaveBeenCalledTimes(1))
    expect(onSave).toHaveBeenCalledWith(
      expect.objectContaining({
        name: 'Fortress City Phase 2',
        short_code: 'FC-002',
        category: 'Residential',
        branch_id: 4,
        client_id: 8,
        budget: '0',
        progress: 0,
      }),
    )
  })

  it('shows Review after advancing twice and saves only after the Review action', async () => {
    const user = userEvent.setup()
    const onSave = renderForm()

    await user.type(screen.getByRole('textbox', { name: /Project name/ }), 'Review gate project')
    await user.type(screen.getByRole('textbox', { name: /Project code/ }), 'REVIEW-GATE')
    await user.type(screen.getByRole('textbox', { name: /Category/ }), 'Construction')
    await chooseOption(user, 'Owning branch', 'Enugu')
    await chooseOption(user, 'Client', 'Fortress Developments')

    await user.click(screen.getByRole('button', { name: 'Next' }))
    expect(screen.getByRole('heading', { name: 'Delivery plan' })).toBeInTheDocument()
    expect(onSave).not.toHaveBeenCalled()

    const deliveryNext = screen.getByRole('button', { name: 'Next' })
    await user.click(deliveryNext)
    expect(screen.getByRole('heading', { name: 'Review and confirm' })).toBeInTheDocument()
    expect(screen.getByRole('region', { name: 'Project basics' })).toBeVisible()
    expect(screen.getByRole('region', { name: 'Delivery plan' })).toBeVisible()
    expect(onSave).not.toHaveBeenCalled()

    const createProject = screen.getByRole('button', { name: 'Create project' })
    expect(createProject).not.toBe(deliveryNext)
    await user.click(createProject)
    await waitFor(() => expect(onSave).toHaveBeenCalledTimes(1))
  })

  it('keeps a cleared zero visible as blank and returns to the invalid field before Review', async () => {
    const user = userEvent.setup()
    const onSave = renderForm()

    await user.type(screen.getByRole('textbox', { name: /Project name/ }), 'Boundary project')
    await user.type(screen.getByRole('textbox', { name: /Project code/ }), 'BOUNDARY-01')
    await user.type(screen.getByRole('textbox', { name: /Category/ }), 'Construction')
    await chooseOption(user, 'Owning branch', 'Enugu')
    await chooseOption(user, 'Client', 'Fortress Developments')
    await user.click(screen.getByRole('button', { name: 'Next' }))

    const progress = screen.getByRole('spinbutton', { name: /Current progress/ })
    expect(progress).toHaveValue(0)
    await user.clear(progress)
    expect(progress).toHaveValue(null)
    await user.click(screen.getByRole('button', { name: 'Review, step 3 of 3, available' }))

    expect(screen.getByRole('heading', { name: 'Delivery plan' })).toBeInTheDocument()
    expect(progress).toHaveAttribute('aria-invalid', 'true')
    expect(screen.getByText('Enter a whole number between 0 and 100 percent.')).toBeInTheDocument()
    expect(onSave).not.toHaveBeenCalled()
  })

  it('returns to the matching step and puts server field errors beneath the input', async () => {
    const user = userEvent.setup()
    renderForm().mockRejectedValue(
      new ApiError('Project could not be saved.', {
        status: 400,
        fieldErrors: { short_code: 'This project code is already in use.' },
      }),
    )

    await user.type(screen.getByRole('textbox', { name: /Project name/ }), 'New project')
    await user.type(screen.getByRole('textbox', { name: /Project code/ }), 'DUPLICATE')
    await user.type(screen.getByRole('textbox', { name: /Category/ }), 'Construction')
    await chooseOption(user, 'Owning branch', 'Enugu')
    await chooseOption(user, 'Client', 'Fortress Developments')
    await user.click(screen.getByRole('button', { name: 'Next' }))
    await user.click(screen.getByRole('button', { name: 'Next' }))
    await user.click(screen.getByRole('button', { name: 'Create project' }))

    expect(await screen.findByRole('heading', { name: 'Project basics' })).toBeInTheDocument()
    const codeInput = screen.getByRole('textbox', { name: /Project code/ })
    expect(codeInput).toHaveAttribute('aria-invalid', 'true')
    const error = screen.getByText('This project code is already in use.')
    expect(error.parentElement).toContainElement(codeInput)
    expect(screen.queryByRole('alert')).not.toBeInTheDocument()
  })
})
