import { fireEvent, render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it } from 'vitest'

import { Tooltip } from './tooltip'

describe('Tooltip', () => {
  it('describes its trigger and reveals the hint on keyboard focus', async () => {
    const user = userEvent.setup()
    render(
      <Tooltip content="Help about this field">
        <button type="button">Help</button>
      </Tooltip>,
    )

    const trigger = screen.getByRole('button', { name: 'Help' })
    expect(trigger).not.toHaveAttribute('aria-describedby')
    expect(screen.queryByRole('tooltip', { hidden: true })).not.toBeInTheDocument()

    await user.tab()
    expect(trigger).toHaveFocus()
    const tooltip = screen.getByRole('tooltip')
    expect(tooltip).toHaveTextContent('Help about this field')
    const tooltipId = trigger.getAttribute('aria-describedby')
    expect(tooltipId).toBeTruthy()
    expect(tooltip).toHaveAttribute('id', tooltipId)
    expect(tooltip.parentElement).toBe(document.body)

    fireEvent.blur(trigger)
    expect(tooltip).toHaveStyle({ visibility: 'hidden' })
  })

  it('keeps its hint inside a native dialog so it stays above the backdrop', async () => {
    const user = userEvent.setup()
    render(
      <dialog open>
        <Tooltip content="Help inside a dialog">
          <button type="button">Dialog help</button>
        </Tooltip>
      </dialog>,
    )

    const dialog = screen.getByRole('dialog')
    const trigger = screen.getByRole('button', { name: 'Dialog help' })
    expect(trigger).not.toHaveAttribute('aria-describedby')
    expect(screen.queryByRole('tooltip', { hidden: true })).not.toBeInTheDocument()

    await user.tab()
    const tooltip = screen.getByRole('tooltip')
    expect(tooltip).toHaveTextContent('Help inside a dialog')
    expect(trigger.getAttribute('aria-describedby')).toBe(tooltip.id)
    expect(tooltip.parentElement).toBe(dialog)
  })
})
