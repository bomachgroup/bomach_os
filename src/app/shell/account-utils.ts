import type { AuthenticatedSession } from '@/shared/auth/session'

export function initials(session: AuthenticatedSession) {
  const first = session.employee.first_name || session.user.first_name || ''
  const last = session.employee.last_name || session.user.last_name || ''
  return (
    `${first.charAt(0)}${last.charAt(0)}`.toUpperCase() ||
    session.user.email.charAt(0).toUpperCase()
  )
}

export function displayName(session: AuthenticatedSession) {
  const name = [
    session.employee.first_name || session.user.first_name,
    session.employee.last_name || session.user.last_name,
  ]
    .filter(Boolean)
    .join(' ')
  return name || session.employee.username || session.user.username || session.user.email
}
