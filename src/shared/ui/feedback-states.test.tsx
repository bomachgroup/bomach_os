import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { EmptyState, ErrorState, PageSkeleton, Skeleton, SuccessState } from './feedback-states'

describe('feedback states', () => {
  it('announces empty, error, and success outcomes without wrapping their actions in the live region', () => {
    const { rerender } = render(
      <EmptyState title="No employees" action={<button>Create</button>} />,
    )
    expect(screen.getByText('No employees').parentElement).toHaveAttribute('aria-live', 'polite')
    expect(screen.getByRole('button', { name: 'Create' }).closest('[aria-live]')).toBeNull()

    rerender(<ErrorState title="Could not load employees" action={<button>Retry</button>} />)
    expect(screen.getByText('Could not load employees').parentElement).toHaveAttribute(
      'aria-live',
      'assertive',
    )
    expect(screen.getByRole('button', { name: 'Retry' }).closest('[aria-live]')).toBeNull()

    rerender(<SuccessState title="Employee created" />)
    expect(screen.getByText('Employee created').parentElement).toHaveAttribute(
      'aria-live',
      'polite',
    )
    expect(screen.getByText('Employee created').parentElement?.parentElement).not.toHaveClass(
      'mt-5',
    )
  })

  it('lets a route compose a loading skeleton that matches its own content', () => {
    render(
      <PageSkeleton>
        <Skeleton variant="row" />
        <Skeleton variant="row" />
      </PageSkeleton>,
    )

    expect(screen.getByRole('status', { name: 'Loading page' })).toHaveAttribute(
      'aria-busy',
      'true',
    )
    expect(document.querySelectorAll('[aria-hidden="true"]')).toHaveLength(2)
  })
})
