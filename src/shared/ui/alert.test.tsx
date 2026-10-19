import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { Alert } from './alert'

describe('Alert', () => {
  it('does not turn static content into a live announcement by tone alone', () => {
    const { container } = render(<Alert tone="danger">A persistent explanation</Alert>)
    expect(container.firstElementChild).not.toHaveAttribute('role')
  })

  it('supports an explicit polite announcement for dynamic feedback', () => {
    render(
      <Alert role="status" aria-atomic="true">
        This section could not load.
      </Alert>,
    )
    expect(screen.getByRole('status')).toHaveTextContent('This section could not load.')
  })
})
