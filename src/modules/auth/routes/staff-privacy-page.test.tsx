import { render, screen, within } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { StaffPrivacyPage } from './staff-privacy-page'

describe('StaffPrivacyPage', () => {
  it('publishes the staff app privacy topics and company privacy contact', () => {
    render(<StaffPrivacyPage />)

    expect(
      screen.getByRole('heading', { name: 'BOMACH Staff Privacy Policy', level: 1 }),
    ).toBeInTheDocument()
    expect(screen.getByRole('navigation', { name: 'Privacy policy sections' })).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Face verification' })).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Location information' })).toBeInTheDocument()
    expect(
      screen.getByRole('heading', { name: 'Reports, photos, and documents' }),
    ).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'bomachgroupmanagement@gmail.com' })).toHaveAttribute(
      'href',
      expect.stringContaining('mailto:bomachgroupmanagement@gmail.com'),
    )
  })

  it('provides working in-page navigation and an unauthenticated route back to sign-in', () => {
    render(<StaffPrivacyPage />)

    const navigation = screen.getByRole('navigation', { name: 'Privacy policy sections' })
    expect(within(navigation).getByRole('link', { name: 'Face verification' })).toHaveAttribute(
      'href',
      '#face-verification',
    )
    expect(screen.getAllByRole('link', { name: 'Staff sign in' })[0]).toHaveAttribute(
      'href',
      '/login',
    )
  })
})
