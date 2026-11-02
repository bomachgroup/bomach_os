import { describe, expect, it } from 'vitest'

import { buildOrgChartModel } from './org-chart-model'
import type {
  OrganizationRoleDto,
  ReportingChartScopeDto,
  ReportingLineDto,
} from './company-organization.api'

const roles: OrganizationRoleDto[] = [
  { id: 1, name: 'Chief Executive' },
  { id: 2, name: 'Finance Lead' },
  { id: 3, name: 'Finance Partner' },
  { id: 4, name: 'Unconnected Position' },
]

function line(
  id: number,
  role: OrganizationRoleDto,
  manager: OrganizationRoleDto,
  relationship_type: ReportingLineDto['relationship_type'],
  is_active = true,
): ReportingLineDto {
  return {
    id,
    role_id: role.id,
    role,
    reports_to_role_id: manager.id,
    reports_to_role: manager,
    relationship_type,
    branch_id: null,
    branch: null,
    department_id: null,
    department: null,
    unit_id: null,
    unit: null,
    sequence: id,
    is_active,
    created_at: '2026-10-01T00:00:00Z',
    updated_at: '2026-10-01T00:00:00Z',
  }
}

const companyScope: ReportingChartScopeDto = {
  key: 'company',
  label: 'Company-wide',
  branch_id: null,
  branch: null,
  department_id: null,
  department: null,
  unit_id: null,
  unit: null,
  role_ids: [1, 2, 3],
  reporting_lines: [
    line(1, roles[1]!, roles[0]!, 'direct'),
    line(2, roles[2]!, roles[1]!, 'dotted_line'),
    line(3, roles[2]!, roles[0]!, 'escalation'),
    line(4, roles[3]!, roles[0]!, 'direct', false),
  ],
}

describe('buildOrgChartModel', () => {
  it('keeps the company role catalog, direct hierarchy, and secondary relationships distinct', () => {
    const model = buildOrgChartModel(roles, companyScope)
    expect(model.roles.map(({ id }) => id)).toEqual([1, 2, 3, 4])
    expect(model.directReports.map(({ id }) => id)).toEqual([1])
    expect(model.directChildren.get(1)?.map(({ id }) => id)).toEqual([2])
    expect(model.secondaryLines.map(({ relationship_type }) => relationship_type)).toEqual([
      'dotted_line',
      'escalation',
    ])
  })

  it('keeps a scoped chart limited to role positions linked in that exact scope', () => {
    const scoped: ReportingChartScopeDto = {
      ...companyScope,
      key: 'branch:7|department:2|unit:3',
      label: 'North · Finance · Planning',
      role_ids: [2, 3],
      reporting_lines: [line(5, roles[2]!, roles[1]!, 'direct')],
    }
    const model = buildOrgChartModel(roles, scoped)
    expect(model.roles.map(({ id }) => id)).toEqual([2, 3])
    expect(model.directReports).toHaveLength(1)
    expect(model.secondaryLines).toHaveLength(0)
  })
})
