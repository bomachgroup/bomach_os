import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { Button } from './button'

describe('Button', () => {
  it('prevents duplicate activation and exposes its pending state while loading', () => {
    render(<Button isLoading>Saving changes</Button>)

    const button = screen.getByRole('button', { name: 'Saving changes' })
    expect(button).toBeDisabled()
    expect(button).toHaveAttribute('aria-busy', 'true')
    expect(button.querySelector('[aria-hidden="true"]')).toBeInTheDocument()
  })
})
