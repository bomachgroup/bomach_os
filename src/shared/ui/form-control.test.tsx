import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { FormControl, TextInput } from './form-control'

describe('FormControl', () => {
  it('connects required state, help, invalid state, and the inline error to its input', () => {
    render(
      <FormControl
        id="company-email"
        label="Company email"
        required
        description="Used for company notifications."
        error="Enter a valid email address."
      >
        <TextInput type="email" />
      </FormControl>,
    )

    const input = screen.getByRole('textbox', { name: 'Company email' })
    expect(input).toHaveClass('min-h-[38px]', 'px-2.5', 'py-[9px]', 'text-control-value')
    expect(screen.getByText('Company email').closest('label')).toHaveClass(
      'text-control-label',
      'font-bold',
    )
    expect(input).toBeRequired()
    expect(input).toHaveAttribute('aria-invalid', 'true')
    expect(input).toHaveAttribute(
      'aria-describedby',
      'company-email-description company-email-error',
    )
    expect(input).not.toHaveAttribute('aria-errormessage')
    expect(screen.getByRole('status')).toHaveTextContent('Enter a valid email address.')
  })

  it('preserves an existing invalid state when the wrapper has no error', () => {
    render(
      <FormControl id="notes" label="Notes">
        <TextInput aria-invalid="true" />
      </FormControl>,
    )

    expect(screen.getByRole('textbox', { name: 'Notes' })).toHaveAttribute('aria-invalid', 'true')
  })
})
