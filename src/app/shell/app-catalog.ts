import type { PermissionSet } from '@/shared/auth/session'

export interface WorkspaceApp {
  id: 'os' | 'services'
  label: string
  description: string
  href: string
  accessAnyOf?: readonly string[]
}

export const SERVICES_APP_ACCESS_ANY_OF = [
  'command_center.view',
  'services.list',
  'service_pricing_configs.list',
  'service_request_forms.list',
  'service_workflows.list',
  'service_branch_activations.list',
  'service_requests.list',
  'quotes.list',
  'service_invoices.list',
  'dashboard.view',
  'orders.list',
  'orders.view',
  'estates.list',
  'feedback.list',
  'reports.view',
] as const

export const WORKSPACE_APPS: readonly WorkspaceApp[] = [
  {
    id: 'os',
    label: 'Bomach OS',
    description: 'People and company operations',
    href: '/dashboard',
  },
  {
    id: 'services',
    label: 'Services',
    description: 'Service delivery and commercial operations',
    href: '/services',
    accessAnyOf: SERVICES_APP_ACCESS_ANY_OF,
  },
]

export function canAccessWorkspaceApp(app: WorkspaceApp, permissions: PermissionSet): boolean {
  if (!app.accessAnyOf?.length) return true
  return app.accessAnyOf.some((grant) => {
    const separator = grant.lastIndexOf('.')
    return (
      separator > 0 && permissions[grant.slice(0, separator)]?.includes(grant.slice(separator + 1))
    )
  })
}

export function canAccessServicesApp(permissions: PermissionSet): boolean {
  const servicesApp = WORKSPACE_APPS.find((app) => app.id === 'services')
  return Boolean(servicesApp && canAccessWorkspaceApp(servicesApp, permissions))
}
