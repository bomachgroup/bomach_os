import { fireEvent, render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { CompanyLogoImage } from './company-logo-image'

describe('CompanyLogoImage', () => {
  it('uses the fallback when no logo URL is configured', () => {
    render(
      <CompanyLogoImage
        src={null}
        alt="Company logo"
        className="size-full"
        fallback={<span>Company mark</span>}
      />,
    )

    expect(screen.getByText('Company mark')).toBeInTheDocument()
    expect(screen.queryByRole('img', { name: 'Company logo' })).not.toBeInTheDocument()
  })

  it('uses the fallback when a configured logo cannot load', () => {
    render(
      <CompanyLogoImage
        src="https://assets.example.test/missing-logo.png"
        alt="Company logo"
        className="size-full"
        fallback={<span>Company mark</span>}
      />,
    )

    fireEvent.error(screen.getByRole('img', { name: 'Company logo' }))

    expect(screen.getByText('Company mark')).toBeInTheDocument()
    expect(screen.queryByRole('img', { name: 'Company logo' })).not.toBeInTheDocument()
  })
})
