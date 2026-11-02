import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import { AttachmentPicker, ProfileImagePicker } from './governance-file-picker'

describe('governance file pickers', () => {
  it('stages multiple image and PDF attachments and lets the user remove one', async () => {
    const user = userEvent.setup()
    const onChange = vi.fn()
    const files = [
      new File(['image'], 'board-photo.png', { type: 'image/png' }),
      new File(['pdf'], 'agenda.pdf', { type: 'application/pdf' }),
    ]
    const { rerender } = render(
      <AttachmentPicker id="governance-files" files={[]} multiple onChange={onChange} />,
    )

    await user.upload(screen.getByLabelText('Choose image or PDF'), files)
    expect(onChange).toHaveBeenCalledWith(files)
    rerender(<AttachmentPicker id="governance-files" files={files} multiple onChange={onChange} />)
    expect(screen.getByText('board-photo.png')).toBeVisible()
    expect(screen.getByText('agenda.pdf')).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Remove board-photo.png' }))
    expect(onChange).toHaveBeenLastCalledWith([files[1]])
  })

  it('rejects unsupported files and files larger than 15 MB', async () => {
    const onChange = vi.fn()
    render(<AttachmentPicker id="governance-files" files={[]} onChange={onChange} />)
    const input = screen.getByLabelText('Choose image or PDF')
    const unsupported = new File(['binary'], 'script.bin', { type: 'application/octet-stream' })
    fireEvent.change(input, { target: { files: [unsupported] } })
    expect(await screen.findByRole('alert')).toHaveTextContent('Choose an image or PDF file.')
    expect(onChange).not.toHaveBeenCalled()

    const tooLarge = new File([new Uint8Array(15 * 1024 * 1024 + 1)], 'large.png', {
      type: 'image/png',
    })
    fireEvent.change(input, { target: { files: [tooLarge] } })
    await waitFor(() =>
      expect(screen.getByRole('alert')).toHaveTextContent('Each file must be 15 MB or smaller.'),
    )
    expect(onChange).not.toHaveBeenCalled()
  })

  it('returns a selected profile photo and supports clearing the saved photo', async () => {
    const user = userEvent.setup()
    const onChange = vi.fn()
    const onClear = vi.fn()
    const photo = new File(['photo'], 'shareholder.png', { type: 'image/png' })
    render(
      <ProfileImagePicker
        id="profile-photo"
        currentUrl="https://images.example.test/current.png"
        initials="QA"
        file={null}
        onChange={onChange}
        onClear={onClear}
      />,
    )

    await user.upload(screen.getByLabelText('Choose profile photo'), photo)
    expect(onChange).toHaveBeenCalledWith(photo)
    await user.click(screen.getByRole('button', { name: 'Remove photo' }))
    expect(onChange).toHaveBeenLastCalledWith(null)
    expect(onClear).toHaveBeenCalledOnce()
  })
})
