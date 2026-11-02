import { act, fireEvent, render, screen } from '@testing-library/react'
import { afterEach, describe, expect, it, vi } from 'vitest'

import { PermissionActionGroups } from './permission-action-groups'

afterEach(() => {
  vi.useRealTimers()
})

describe('PermissionActionGroups', () => {
  it('groups grants by work area and gives actions a useful explanation', () => {
    render(
      <PermissionActionGroups
        permissions={{
          attendance: ['view_own', 'list_own'],
          employees: ['view'],
        }}
      />,
    )

    expect(screen.getByRole('button', { name: 'People permission subgroup' })).toHaveAttribute(
      'aria-expanded',
      'false',
    )
    expect(
      screen.getByRole('button', { name: 'Attendance & access permission subgroup' }),
    ).toHaveAttribute('aria-expanded', 'false')
    expect(screen.queryByRole('heading', { name: 'Roles' })).not.toBeInTheDocument()
    expect(screen.getByText('Actions', { exact: true }).parentElement).toHaveTextContent('3')
    expect(screen.getByText('Resources', { exact: true }).parentElement).toHaveTextContent('2')

    fireEvent.click(screen.getByRole('button', { name: 'Attendance & access permission subgroup' }))
    fireEvent.click(screen.getByRole('button', { name: 'Attendance permission set' }))
    const ownAttendanceAction = screen.getByLabelText('View Own permission for Attendance')
    fireEvent.focus(ownAttendanceAction)
    expect(screen.getByRole('tooltip')).toHaveTextContent(
      'Review your clock-in and clock-out history, including recorded times and capture details.',
    )
    expect(screen.getByRole('tooltip')).not.toHaveTextContent('View Own Attendance')
  })

  it('opens matching permission groups during search and resets them when search clears', () => {
    render(<PermissionActionGroups permissions={{ employees: ['create'] }} />)

    fireEvent.change(screen.getByRole('searchbox'), { target: { value: 'employees' } })
    const peopleGroup = screen.getByRole('button', { name: 'People permission subgroup' })
    const employeeResource = screen.getByRole('button', { name: 'Employees permission set' })
    expect(peopleGroup).toHaveAttribute('aria-expanded', 'true')
    expect(employeeResource).toHaveAttribute('aria-expanded', 'true')

    fireEvent.click(peopleGroup)
    expect(peopleGroup).toHaveAttribute('aria-expanded', 'false')

    fireEvent.click(screen.getByRole('button', { name: 'Clear permission search' }))
    expect(peopleGroup).toHaveAttribute('aria-expanded', 'false')
  })

  it('delays pointer help by one second and shows it immediately on keyboard focus', () => {
    vi.useFakeTimers()
    render(<PermissionActionGroups permissions={{ employees: ['create'] }} />)

    fireEvent.click(screen.getByRole('button', { name: 'People permission subgroup' }))
    fireEvent.click(screen.getByRole('button', { name: 'Employees permission set' }))
    const trigger = screen.getByLabelText('Create permission for Employees')
    fireEvent.pointerEnter(trigger, { pointerType: 'mouse' })

    act(() => vi.advanceTimersByTime(999))
    expect(screen.queryByRole('tooltip')).not.toBeInTheDocument()
    act(() => vi.advanceTimersByTime(1))
    const tooltip = screen.getByRole('tooltip')
    expect(tooltip).toHaveStyle({ visibility: 'visible' })

    fireEvent.focus(trigger)
    expect(tooltip).toHaveStyle({ visibility: 'visible' })
    expect(tooltip).toHaveTextContent('Onboard a person by creating their employee profile.')
  })
})
