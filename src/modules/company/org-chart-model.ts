import type {
  OrganizationRoleDto,
  ReportingChartScopeDto,
  ReportingLineDto,
} from './company-organization.api'

export interface OrgChartModel {
  roles: OrganizationRoleDto[]
  directChildren: Map<number, OrganizationRoleDto[]>
  directReports: ReportingLineDto[]
  secondaryLines: ReportingLineDto[]
}

export function buildOrgChartModel(
  roles: OrganizationRoleDto[],
  scope: ReportingChartScopeDto,
): OrgChartModel {
  const scopeRoleIds = new Set(
    scope.key === 'company' ? roles.map((role) => role.id) : scope.role_ids,
  )
  const visibleRoles = roles
    .filter((role) => scopeRoleIds.has(role.id))
    .sort((left, right) => left.name.localeCompare(right.name) || left.id - right.id)
  const visibleIds = new Set(visibleRoles.map((role) => role.id))
  const directReports = scope.reporting_lines
    .filter(
      (line) =>
        line.is_active &&
        line.relationship_type === 'direct' &&
        visibleIds.has(line.role_id) &&
        visibleIds.has(line.reports_to_role_id),
    )
    .sort(
      (left, right) =>
        left.sequence - right.sequence || left.role.name.localeCompare(right.role.name),
    )
  const secondaryLines = scope.reporting_lines
    .filter(
      (line) =>
        line.is_active &&
        line.relationship_type !== 'direct' &&
        visibleIds.has(line.role_id) &&
        visibleIds.has(line.reports_to_role_id),
    )
    .sort((left, right) => {
      const typeOrder = left.relationship_type.localeCompare(right.relationship_type)
      return (
        typeOrder || left.sequence - right.sequence || left.role.name.localeCompare(right.role.name)
      )
    })
  const byParent = new Map<number, OrganizationRoleDto[]>()
  for (const line of directReports) {
    const children = byParent.get(line.reports_to_role_id) ?? []
    children.push(line.role)
    byParent.set(line.reports_to_role_id, children)
  }
  for (const children of byParent.values()) {
    children.sort((left, right) => left.name.localeCompare(right.name) || left.id - right.id)
  }
  return { roles: visibleRoles, directChildren: byParent, directReports, secondaryLines }
}
