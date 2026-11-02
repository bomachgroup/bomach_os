import { permissionAreas } from './permission-guidance'

export type RolePermissionSummaryGroup = {
  id: string
  label: string
  description: string
  resources: [string, string[]][]
}

export function groupRolePermissions(
  permissions: Record<string, string[]>,
): RolePermissionSummaryGroup[] {
  const knownResources = new Set<string>(permissionAreas.flatMap((area) => [...area.resources]))
  const groups: RolePermissionSummaryGroup[] = permissionAreas.map((area) => ({
    ...area,
    resources: area.resources
      .map((resource) => [resource, permissions[resource] ?? []] as [string, string[]])
      .filter(([, actions]) => actions.length > 0),
  }))
  const otherResources = Object.entries(permissions).filter(
    ([resource, actions]) => !knownResources.has(resource) && actions.length > 0,
  )

  if (otherResources.length) {
    groups.push({
      id: 'other',
      label: 'Other access',
      description: 'Additional permissions provided by the backend.',
      resources: otherResources,
    })
  }

  return groups.filter((area) => area.resources.length > 0)
}
