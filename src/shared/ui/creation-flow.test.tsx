import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import { CreationFlowStepper } from './creation-flow'
import { FormSection } from './form-section'

const steps = [
  { id: 'details', label: 'Details', title: 'Branch details', detail: 'Name the location.' },
  { id: 'location', label: 'Location', detail: 'Add the branch address.' },
  { id: 'hours', label: 'Hours' },
  { id: 'review', label: 'Review' },
]

describe('creation flow primitives', () => {
  it('keeps future steps unavailable and allows returning to completed steps', async () => {
    const user = userEvent.setup()
    const onStepSelect = vi.fn()
    render(
      <CreationFlowStepper
        ariaLabel="Branch setup"
        steps={steps}
        currentStep={1}
        maxSelectableStep={1}
        onStepSelect={onStepSelect}
        variant="horizontal"
        eyebrow="Branch setup"
        hideDetailBelow480
      />,
    )

    expect(screen.getByRole('heading', { name: 'Location' })).toBeInTheDocument()
    expect(screen.getByText('Add the branch address.')).toHaveClass('max-[479px]:hidden')
    expect(screen.getByRole('progressbar')).toHaveAttribute('aria-valuenow', '2')
    expect(screen.getByRole('button', { name: /Hours, step 3 of 4, not reached/ })).toBeDisabled()

    await user.click(screen.getByRole('button', { name: /Details, step 1 of 4, completed/ }))
    expect(onStepSelect).toHaveBeenCalledWith(0)
  })

  it('provides the shared muted form-section surface', () => {
    render(<FormSection aria-label="Profile details">Fields</FormSection>)

    expect(screen.getByRole('region', { name: 'Profile details' })).toHaveClass(
      'bg-surface-muted',
      'border-border-subtle',
      'rounded-surface',
      'p-4',
    )
  })
})
