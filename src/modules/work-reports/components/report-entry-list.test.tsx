import { fireEvent, render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { ReportEntryList } from './report-entry-list'

describe('ReportEntryList', () => {
  it('grows a multiline entry to fit its content', () => {
    const value = 'Completed the inspection.\nUpdated the service log.'
    const { rerender } = render(
      <ReportEntryList
        id="activities"
        label="Work completed"
        itemLabel="Activity"
        description="Tasks and results completed today."
        placeholder="Describe a task or result"
        entries={['']}
        onChange={() => undefined}
        required
      />,
    )
    const textarea = screen.getByRole('textbox', { name: 'Activity 1' })
    Object.defineProperty(textarea, 'scrollHeight', { configurable: true, value: 176 })

    fireEvent.change(textarea, { target: { value } })
    rerender(
      <ReportEntryList
        id="activities"
        label="Work completed"
        itemLabel="Activity"
        description="Tasks and results completed today."
        placeholder="Describe a task or result"
        entries={[value]}
        onChange={() => undefined}
        required
      />,
    )

    expect(textarea).toHaveStyle({ height: '176px' })
  })
})
