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
    const tooltipId = trigger.getAttribute('aria-describedby')
    expect(tooltipId).toBeTruthy()

    await user.tab()
    expect(trigger).toHaveFocus()
    const tooltip = screen.getByRole('tooltip')
    expect(tooltip).toHaveTextContent('Help about this field')
    expect(tooltip).toHaveAttribute('id', tooltipId)

    fireEvent.blur(trigger)
    expect(tooltip).toHaveStyle({ visibility: 'hidden' })
  })
})
