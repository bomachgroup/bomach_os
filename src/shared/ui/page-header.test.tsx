import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { PageBackLinkContent, pageBackLinkClassName } from './page-back-link'
import { PageHeader } from './page-header'

describe('PageHeader nested-page navigation', () => {
  it('shows an arrow-only back button before the title and removes the route icon', () => {
    render(
      <PageHeader
        title="North Office"
        leading={<svg data-testid="page-icon" />}
        backLink={
          <a className={pageBackLinkClassName} href="/company/branch">
            <PageBackLinkContent>Branch directory</PageBackLinkContent>
          </a>
        }
        actions={<button type="button">Edit branch</button>}
      />,
    )

    const backLink = screen.getByRole('link', { name: 'Back to Branch directory' })
    const title = screen.getByRole('heading', { name: 'North Office', level: 1 })
    expect(backLink).toBeInTheDocument()
    expect(backLink.querySelector('svg')).toBeInTheDocument()
    expect(backLink.parentElement?.nextElementSibling).toBe(title)
    expect(screen.getByRole('button', { name: 'Edit branch' })).toBeInTheDocument()
    expect(screen.queryByTestId('page-icon')).not.toBeInTheDocument()
  })

  it('keeps the page icon on top-level pages without a back action', () => {
    render(<PageHeader title="Branches" leading={<svg data-testid="page-icon" />} />)

    expect(screen.getByTestId('page-icon')).toBeInTheDocument()
  })

  it('keeps an inline title and action on one responsive row with the full title accessible', () => {
    render(
      <PageHeader
        title="A long page title that should remain readable to assistive technology"
        actionsInline
        actions={
          <button type="button" aria-label="New record">
            +
          </button>
        }
      />,
    )

    const heading = screen.getByRole('heading', {
      name: 'A long page title that should remain readable to assistive technology',
    })
    expect(heading).toHaveClass('truncate')
    expect(heading).toHaveClass('text-[clamp(1.125rem,3vw,2rem)]')
    expect(heading.parentElement).toHaveClass('flex-1')
    expect(screen.getByRole('button', { name: 'New record' })).toBeInTheDocument()
    expect(heading.parentElement?.parentElement).toHaveClass('items-center')
  })
})
