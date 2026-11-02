import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { OkrBoardPage } from './okr-board-page'

describe('OkrBoardPage', () => {
  it('states the unavailable company and role API contract clearly', () => {
    render(<OkrBoardPage />)

    expect(screen.getByRole('heading', { name: 'OKR Board' })).toBeInTheDocument()
    expect(
      screen.getByRole('heading', { name: 'OKR Board is not available yet' }),
    ).toBeInTheDocument()
    expect(
      screen.getByText(/does not currently expose company or role OKR endpoints/),
    ).toBeInTheDocument()
    expect(
      screen.getByText(/Objective, key result, owner, period, progress, status/),
    ).toBeInTheDocument()
  })
})
