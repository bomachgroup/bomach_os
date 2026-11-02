import { useQuery } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { ArrowDown, ArrowRight, GitBranch, Network, ShieldAlert, Workflow } from 'lucide-react'
import { useEffect, useMemo } from 'react'

import {
  companyOrganizationApi,
  companyOrganizationQueryKeys,
  type OrganizationRoleDto,
  type ReportingChartScopeDto,
  type ReportingLineDto,
} from '@/modules/company/company-organization.api'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Card } from '@/shared/ui/card'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { EmptyState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'

import { buildOrgChartModel } from '../org-chart-model'
import type { OrgChartSearch } from '../company-organization.search'
import { departmentCategoryLabel } from '../organization-labels'

function RelationshipBadge({ type }: { type: ReportingLineDto['relationship_type'] }) {
  if (type === 'direct') {
    return (
      <span className="border-primary/25 bg-primary-subtle text-overline text-primary inline-flex items-center gap-1 rounded-full border px-2 py-0.5 font-semibold">
        <GitBranch className="size-3" aria-hidden="true" />
        Direct
      </span>
    )
  }
  if (type === 'dotted_line') {
    return (
      <span className="border-info/30 bg-info-subtle text-overline text-info inline-flex items-center gap-1 self-start rounded-full border px-2 py-0.5 font-semibold">
        <Workflow className="size-3" aria-hidden="true" />
        Dotted line
      </span>
    )
  }
  return (
    <span className="border-warning/40 bg-warning-subtle text-overline text-text-primary inline-flex items-center gap-1 self-start rounded-full border px-2 py-0.5 font-semibold">
      <ShieldAlert className="size-3" aria-hidden="true" />
      Escalation
    </span>
  )
}

function RoleNode({
  role,
  childrenByParent,
  path,
}: {
  role: OrganizationRoleDto
  childrenByParent: Map<number, OrganizationRoleDto[]>
  path: Set<number>
}) {
  const children = childrenByParent.get(role.id) ?? []
  const cycle = path.has(role.id)
  const nextPath = new Set(path).add(role.id)
  return (
    <li className="min-w-0">
      <div className="border-border-subtle bg-surface rounded-control shadow-elevation-sm flex min-w-0 items-center gap-3 border px-3.5 py-3">
        <span className="bg-primary-subtle text-primary rounded-control flex size-9 shrink-0 items-center justify-center">
          <Network className="size-4" aria-hidden="true" />
        </span>
        <div className="min-w-0 flex-1">
          <h3 className="text-body-sm text-text-primary font-semibold break-words">{role.name}</h3>
          <p className="text-overline text-text-muted mt-0.5">Role position</p>
        </div>
      </div>
      {cycle ? (
        <p className="text-caption text-danger mt-2">A legacy reporting cycle ends here.</p>
      ) : null}
      {!cycle && children.length ? (
        <ul
          className="border-border-strong phone:ml-4 phone:pl-4 tablet:ml-5 tablet:pl-5 mt-2 ml-3 space-y-2 border-l-2 pl-3"
          aria-label={`Direct reports to ${role.name}`}
        >
          {children.map((child) => (
            <RoleNode
              key={child.id}
              role={child}
              childrenByParent={childrenByParent}
              path={nextPath}
            />
          ))}
        </ul>
      ) : null}
    </li>
  )
}

function SecondaryRelationship({ line }: { line: ReportingLineDto }) {
  const isDotted = line.relationship_type === 'dotted_line'
  return (
    <li
      className={`rounded-control bg-surface phone:flex-row phone:items-center phone:justify-between flex min-w-0 flex-col gap-2 border px-3 py-3 ${isDotted ? 'border-info/50 border-dashed' : 'border-warning/40'}`}
    >
      <div className="min-w-0">
        <p className="text-body-sm text-text-primary font-semibold break-words">{line.role.name}</p>
        <p className="text-caption text-text-secondary mt-0.5 flex items-center gap-1.5">
          <ArrowRight className="size-3.5 shrink-0" aria-hidden="true" />
          Reports to {line.reports_to_role.name}
        </p>
      </div>
      <RelationshipBadge type={line.relationship_type} />
    </li>
  )
}

function scopeName(scope: ReportingChartScopeDto) {
  if (scope.key === 'company') return 'Company-wide'

  const label = scope.label.trim()
  if (scope.department && !scope.branch && !scope.unit) {
    const rawCategory = scope.department.name.trim().toLocaleLowerCase('en')
    const normalizedLabel = label.toLocaleLowerCase('en')
    if (
      !label ||
      normalizedLabel === rawCategory ||
      normalizedLabel === `${rawCategory} department`
    ) {
      return `${departmentCategoryLabel(scope.department.name)} department`
    }
  }
  if (label) return label

  const parts = [
    scope.branch?.branch_name,
    scope.department ? `${departmentCategoryLabel(scope.department.name)} department` : null,
    scope.unit?.name,
  ].filter(Boolean)
  return parts.join(' · ') || 'Organization scope'
}

function countLabel(count: number, singular: string, plural: string) {
  return `${count} ${count === 1 ? singular : plural}`
}

export function OrgChartPage() {
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const canViewRoles = hasPermission(session?.permissions ?? {}, 'roles', 'list')
  const canViewLines = hasPermission(session?.permissions ?? {}, 'role_reporting_lines', 'list')
  const search = useSearch({ from: '/_protected/company/org-chart' }) as OrgChartSearch
  const navigate = useNavigate()
  const chart = useQuery({
    queryKey: companyOrganizationQueryKeys.reportingChart(userId, employeeId),
    queryFn: ({ signal }) => companyOrganizationApi.reportingChart(signal),
    enabled: Boolean(session && canViewRoles && canViewLines),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnMount: true,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const scopes = chart.data?.scopes ?? []
  const selectedScope =
    scopes.find((scope) => scope.key === search.scope) ??
    scopes.find((scope) => scope.key === 'company') ??
    scopes[0]
  const model = useMemo(
    () =>
      chart.data && selectedScope ? buildOrgChartModel(chart.data.roles, selectedScope) : null,
    [chart.data, selectedScope],
  )

  useEffect(() => {
    if (!chart.data || !selectedScope || selectedScope.key === search.scope) return
    void navigate({
      to: '/company/org-chart',
      search: (previous: OrgChartSearch) => ({ ...previous, scope: selectedScope.key }),
      replace: true,
    })
  }, [chart.data, navigate, search.scope, selectedScope])

  const scopeOptions: DropdownSelectOption[] = scopes.map((scope) => {
    const label = scopeName(scope)
    let description: string | undefined
    if (scope.key === 'company') {
      description = 'All roles · company-wide reporting lines'
    } else if (scope.label.trim().toLocaleLowerCase('en') !== label.toLocaleLowerCase('en')) {
      description = scope.label
    }

    return {
      value: scope.key,
      label,
      ...(description ? { description } : {}),
    }
  })
  const childrenByParent = model?.directChildren ?? new Map<number, OrganizationRoleDto[]>()
  const childRoleIds = new Set(model?.directReports.map((line) => line.role_id) ?? [])
  const roots = model?.roles.filter((role) => !childRoleIds.has(role.id)) ?? []
  const connectedRoleIds = new Set<number>()
  const markConnected = (role: OrganizationRoleDto, path: Set<number>) => {
    if (path.has(role.id)) return
    connectedRoleIds.add(role.id)
    const nextPath = new Set(path).add(role.id)
    for (const child of childrenByParent.get(role.id) ?? []) markConnected(child, nextPath)
  }
  roots.forEach((role) => markConnected(role, new Set()))
  const cycleRoots = model?.roles.filter((role) => !connectedRoleIds.has(role.id)) ?? []

  return (
    <PageLayout
      title="Org Chart"
      subtitle="Explore role positions and their reporting relationships by saved scope."
    >
      <div className="space-y-5">
        <Card className="from-primary-subtle/45 via-surface to-surface phone:p-5 tablet:flex-row tablet:items-end tablet:justify-between flex min-w-0 flex-col gap-4 bg-gradient-to-br p-4">
          <div className="min-w-0">
            <p className="text-overline text-primary font-semibold tracking-wide">
              Reporting structure
            </p>
            <h2 className="text-h3 mt-1 font-semibold">Role positions</h2>
            <p className="text-caption text-text-secondary mt-1 max-w-2xl">
              Each chart uses one exact saved scope. Solid branches show direct reporting; dotted
              and escalation relationships are listed separately.
            </p>
          </div>
          <div className="tablet:max-w-sm w-full">
            <FormControl id="org-chart-scope" label="Chart scope">
              <DropdownSelect
                id="org-chart-scope"
                value={selectedScope?.key ?? ''}
                options={scopeOptions}
                onChange={(scope) =>
                  void navigate({
                    to: '/company/org-chart',
                    search: (previous: OrgChartSearch) => ({ ...previous, scope }),
                    replace: false,
                  })
                }
                placeholder="Choose a chart scope"
                searchable
                disabled={!scopeOptions.length}
                aria-label="Choose Org Chart scope"
              />
            </FormControl>
          </div>
        </Card>

        {chart.isError && !chart.data ? (
          <SectionErrorState
            error={chart.error}
            title="Org Chart could not be loaded"
            onRetry={() => void chart.refetch()}
          />
        ) : null}
        {chart.isError && chart.data ? (
          <SectionErrorState
            error={chart.error}
            title="Showing saved chart data"
            onRetry={() => void chart.refetch()}
            className="py-2"
          />
        ) : null}
        {chart.isPending ? (
          <div className="tablet:grid-cols-2 grid gap-3">
            <Skeleton className="h-36 w-full" />
            <Skeleton className="h-36 w-full" />
          </div>
        ) : null}
        {!canViewRoles || !canViewLines ? (
          <Alert tone="warning" role="status">
            This chart requires both role list and reporting line list access.
          </Alert>
        ) : null}
        {chart.data && scopes.length === 0 ? (
          <EmptyState
            title="No chart scopes are available"
            description="No accessible reporting relationships have been saved yet."
            icon={<Network className="size-6" />}
          />
        ) : null}
        {chart.data && selectedScope && model ? (
          <div className="space-y-5">
            <Card className="phone:p-5 flex min-w-0 flex-wrap items-center justify-between gap-3 p-4">
              <div className="min-w-0">
                <p className="text-overline text-text-secondary">Selected scope</p>
                <h2 className="text-h3 mt-1 font-semibold break-words">
                  {scopeName(selectedScope)}
                </h2>
                <p className="text-caption text-text-secondary mt-1">
                  {countLabel(model.roles.length, 'role position', 'role positions')} ·{' '}
                  {countLabel(
                    model.directReports.length,
                    'direct relationship',
                    'direct relationships',
                  )}{' '}
                  ·{' '}
                  {countLabel(
                    model.secondaryLines.length,
                    'additional relationship',
                    'additional relationships',
                  )}
                </p>
              </div>
              <div className="flex flex-wrap gap-2" role="group" aria-label="Relationship legend">
                <RelationshipBadge type="direct" />
                <RelationshipBadge type="dotted_line" />
                <RelationshipBadge type="escalation" />
              </div>
            </Card>

            <section aria-labelledby="direct-reporting-heading" className="space-y-3">
              <div className="flex items-center gap-2">
                <span className="bg-primary-subtle text-primary rounded-control flex size-8 items-center justify-center">
                  <GitBranch className="size-4" aria-hidden="true" />
                </span>
                <div>
                  <h2 id="direct-reporting-heading" className="text-label font-semibold">
                    Direct reporting
                  </h2>
                  <p className="text-caption text-text-secondary">
                    Solid hierarchy within this scope.
                  </p>
                </div>
              </div>
              {model.roles.length === 0 ? (
                <EmptyState
                  title="No roles in this scope"
                  description="No active reporting line connects role positions in this scope."
                />
              ) : null}
              {model.roles.length > 0 && roots.length === 0 && cycleRoots.length === 0 ? (
                <EmptyState
                  title="No direct reporting lines"
                  description="The available role positions do not have a direct relationship in this scope."
                />
              ) : null}
              {roots.length || cycleRoots.length ? (
                <Card className="phone:p-5 space-y-4 p-4">
                  <ul
                    className="tablet:grid-cols-2 grid min-w-0 gap-4"
                    aria-label={`Direct reporting hierarchy for ${scopeName(selectedScope)}`}
                  >
                    {roots.map((role) => (
                      <RoleNode
                        key={role.id}
                        role={role}
                        childrenByParent={childrenByParent}
                        path={new Set()}
                      />
                    ))}
                    {cycleRoots.map((role) => (
                      <RoleNode
                        key={role.id}
                        role={role}
                        childrenByParent={childrenByParent}
                        path={new Set()}
                      />
                    ))}
                  </ul>
                  {!model.directReports.length && model.roles.length ? (
                    <div className="border-border-subtle text-caption text-text-secondary flex items-center gap-2 border-t pt-3">
                      <ArrowDown className="size-4" aria-hidden="true" />
                      These positions are currently unconnected.
                    </div>
                  ) : null}
                </Card>
              ) : null}
            </section>

            <section aria-labelledby="other-relationships-heading" className="space-y-3">
              <div className="flex items-center gap-2">
                <span className="bg-info-subtle text-info rounded-control flex size-8 items-center justify-center">
                  <Workflow className="size-4" aria-hidden="true" />
                </span>
                <div>
                  <h2 id="other-relationships-heading" className="text-label font-semibold">
                    Dotted-line and escalation relationships
                  </h2>
                </div>
              </div>
              {model.secondaryLines.length ? (
                <Card className="phone:p-4 p-3">
                  <ul
                    className="tablet:grid-cols-2 grid min-w-0 gap-2"
                    aria-label="Additional reporting relationships"
                  >
                    {model.secondaryLines.map((line) => (
                      <SecondaryRelationship key={line.id} line={line} />
                    ))}
                  </ul>
                </Card>
              ) : (
                <Card className="p-4">
                  <p className="text-caption text-text-secondary">
                    No dotted-line or escalation relationships are saved in this scope.
                  </p>
                </Card>
              )}
            </section>
          </div>
        ) : null}
      </div>
    </PageLayout>
  )
}
