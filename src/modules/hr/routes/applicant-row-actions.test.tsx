import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import { ApplicantRowActions } from './applicant-row-actions'

describe('ApplicantRowActions', () => {
  it('keeps edit and delete in an accessible overflow menu', async () => {
    const user = userEvent.setup()
    const onEdit = vi.fn()
    const onDelete = vi.fn()
    render(
      <ApplicantRowActions
        applicantName="QA Candidate"
        canEdit
        canDelete
        onEdit={onEdit}
        onDelete={onDelete}
      />,
    )

    await user.click(screen.getByRole('button', { name: 'More actions for QA Candidate' }))
    const menu = screen.getByRole('menu', { name: 'Actions for QA Candidate' })
    expect(within(menu).getByRole('menuitem', { name: 'Edit candidate' })).toBeVisible()
    expect(within(menu).getByRole('menuitem', { name: 'Delete candidate' })).toBeVisible()
    await user.click(within(menu).getByRole('menuitem', { name: 'Edit candidate' }))
    expect(onEdit).toHaveBeenCalledOnce()
    expect(screen.queryByRole('menu')).not.toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: 'More actions for QA Candidate' }))
    await user.click(screen.getByRole('menuitem', { name: 'Delete candidate' }))
    expect(onDelete).toHaveBeenCalledOnce()
  })

  it('supports Escape, keyboard movement, and permission-limited actions', async () => {
    const user = userEvent.setup()
    render(
      <ApplicantRowActions
        applicantName="QA Candidate"
        canEdit
        canDelete
        onEdit={vi.fn()}
        onDelete={vi.fn()}
      />,
    )
    const trigger = screen.getByRole('button', { name: 'More actions for QA Candidate' })
    await user.click(trigger)
    await waitFor(() =>
      expect(screen.getByRole('menuitem', { name: 'Edit candidate' })).toHaveFocus(),
    )
    await user.keyboard('{ArrowDown}')
    expect(screen.getByRole('menuitem', { name: 'Delete candidate' })).toHaveFocus()
    await user.keyboard('{ArrowDown}')
    expect(screen.getByRole('menuitem', { name: 'Edit candidate' })).toHaveFocus()
    await user.keyboard('{Escape}')
    await waitFor(() => expect(trigger).toHaveFocus())
    expect(screen.queryByRole('menu')).not.toBeInTheDocument()
  })
})
