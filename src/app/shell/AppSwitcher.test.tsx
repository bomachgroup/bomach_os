import { StrictMode } from 'react'
import { fireEvent, render, screen } from '@testing-library/react'
import { beforeEach, describe, expect, it } from 'vitest'

import { AppSwitcher } from './AppSwitcher'
import { rememberWorkspaceSwitch, WORKSPACE_SWITCH_KEY } from '@/shared/auth/workspace-switch'
import { saveWorkspaceLocation } from '@/shared/auth/workspace-memory'

describe('AppSwitcher arrival transition', () => {
  beforeEach(() => {
    window.sessionStorage.clear()
    window.localStorage.clear()
    Object.defineProperty(window, 'innerWidth', { configurable: true, value: 1024 })
  })

  it('plays the arrival animation once under React Strict Mode', async () => {
    rememberWorkspaceSwitch('services')

    render(
      <StrictMode>
        <AppSwitcher permissions={{ quotes: ['list'] }} userId={7} currentApp="services" />
      </StrictMode>,
    )

    expect(await screen.findByRole('status', { name: 'Opening Services' })).toBeInTheDocument()
    expect(window.sessionStorage.getItem(WORKSPACE_SWITCH_KEY)).toBeNull()
  })

  it('offers a separate same-host link for opening another workspace in a new tab', () => {
    saveWorkspaceLocation(7, 'os', '/hr/employees?view=active')
    render(
      <AppSwitcher
        permissions={{ quotes: ['list'], marketing_campaigns: ['list'] }}
        userId={7}
        currentApp="services"
      />,
    )
    fireEvent.click(screen.getByLabelText('Switch workspace'))

    const marketingLink = screen.getByRole('link', { name: 'Open Marketing in a new tab' })
    expect(marketingLink).toHaveAttribute('target', '_blank')
    expect(marketingLink).toHaveAttribute('rel', 'noopener noreferrer')
    expect(marketingLink.getAttribute('href')).toMatch(/\/marketing\/dashboard$/)

    const osLink = screen.getByRole('link', { name: 'Open Bomach OS in a new tab' })
    expect(osLink).toHaveAttribute('target', '_blank')
    expect(osLink.getAttribute('href')).toMatch(/\/hr\/employees\?view=active$/)
  })

  it('clamps the menu width to the viewport from mobile through desktop sizes', () => {
    render(
      <AppSwitcher
        permissions={{ quotes: ['list'], marketing_campaigns: ['list'] }}
        userId={7}
        currentApp="services"
      />,
    )
    fireEvent.click(screen.getByLabelText('Switch workspace'))

    const menu = screen.getByLabelText('Available workspaces')
    const details = menu.closest('details') as HTMLDetailsElement
    details.open = true
    fireEvent(details, new Event('toggle'))
    for (const width of [320, 360, 375, 480, 600, 699, 700, 900, 1100, 1280, 1440, 1600]) {
      Object.defineProperty(window, 'innerWidth', { configurable: true, value: width })
      fireEvent.resize(window)
      expect(menu.style.width).toBe(`${Math.min(296, width - 24)}px`)
    }
  })
})
