import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { ReportContentSummary } from './report-summary'

describe('ReportContentSummary', () => {
  it('keeps empty optional sections quiet and wraps unusually long report text', () => {
    const longActivity = 'inspectionresult'.repeat(24)

    render(<ReportContentSummary workActivities={longActivity} taskDetails="" planNextDay={null} />)

    expect(screen.getByRole('heading', { name: 'Work completed' })).toBeInTheDocument()
    expect(screen.queryByRole('heading', { name: 'Challenges and next steps' })).toBeNull()
    expect(
      screen.queryByText(/No activities recorded|No challenges to report|Add a plan/),
    ).toBeNull()
    expect(screen.getByText(longActivity)).toHaveStyle({ overflowWrap: 'anywhere' })
  })
})
