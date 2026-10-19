import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { StatusChip } from './status-chip'

describe('StatusChip', () => {
  it('uses the accessible foreground role for semantic small-text tones', () => {
    const { rerender } = render(<StatusChip label="Approved" tone="success" />)
    expect(screen.getByText('Approved').parentElement).toHaveClass('text-success-foreground')

    rerender(<StatusChip label="Pending" tone="warning" />)
    expect(screen.getByText('Pending').parentElement).toHaveClass('text-warning-foreground')

    rerender(<StatusChip label="Failed" tone="danger" />)
    expect(screen.getByText('Failed').parentElement).toHaveClass('text-danger-foreground')

    rerender(<StatusChip label="Submitted" tone="info" />)
    expect(screen.getByText('Submitted').parentElement).toHaveClass('text-info-foreground')
  })
})
