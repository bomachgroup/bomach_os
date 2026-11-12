import { describe, expect, it } from 'vitest'

import { validateApprovalRequestsSearch } from '@/modules/company/approval-requests.search'
import { validateApprovalWorkflowsSearch } from '@/modules/company/approval-workflows.search'
import { validateBroadcastSearch } from '@/modules/company/broadcast.search'
import { validateAuditLogSearch } from '@/modules/company/audit-log.search'
import { validateKpiManagementSearch } from '@/modules/company/kpi-management.search'
import { validateAssetsSearch } from '@/modules/company/assets.search'
import { validateRolesSearch } from '@/modules/company/roles.search'
import {
  validateEmployeeProfileSearch,
  validateEmployeesSearch,
} from '@/modules/hr/employees.search'
import {
  canSeeDestination,
  canVisitDestination,
  PROTECTED_DESTINATIONS,
  sidebarDestinationsFor,
} from '@/app/navigation/route-manifest'

import { router } from './router'

describe('employee route registrations', () => {
  it('allows My Work Reports for daily or site-only personal list permissions', () => {
    const destination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/dashboard/my-reports')
    expect(destination).toBeDefined()
    expect(canVisitDestination(destination!, { work_reports: ['list_own'] })).toBe(true)
    expect(canVisitDestination(destination!, { engineering_site_reports: ['list_own'] })).toBe(true)
    expect(canVisitDestination(destination!, { survey_site_reports: ['list'] })).toBe(true)
    expect(canVisitDestination(destination!, {})).toBe(false)
    expect(canSeeDestination(destination!, { survey_site_reports: ['list_own'] })).toBe(true)
  })

  it('registers personal site report detail and edit routes with URL-backed daily/site state', () => {
    const detail = router.buildLocation({
      to: '/dashboard/my-reports/site/$reportType/$reportId',
      params: { reportType: 'survey', reportId: '72' },
      search: { tab: 'site', siteStatus: 'rejected', engineeringPage: 2, surveyPage: 3 },
    })
    const edit = router.buildLocation({
      to: '/dashboard/my-reports/site/$reportType/$reportId/edit',
      params: { reportType: 'engineering', reportId: '14' },
      search: { tab: 'site', siteStatus: 'all', engineeringPage: 1, surveyPage: 1 },
    })
    expect(detail.pathname).toBe('/dashboard/my-reports/site/survey/72')
    expect(detail.search).toMatchObject({ tab: 'site', siteStatus: 'rejected', surveyPage: 3 })
    expect(edit.pathname).toBe('/dashboard/my-reports/site/engineering/14/edit')
    expect(edit.search).toMatchObject({ tab: 'site' })
  })

  it('registers the Operations sidebar destinations with their Flutter access rules and order', () => {
    const operations = PROTECTED_DESTINATIONS.filter(
      ({ group, inSidebar }) => group === 'Operations' && inSidebar,
    ).sort((left, right) => left.order - right.order)
    const expectedPaths = [
      '/operations',
      '/works/projects',
      '/works/worksite',
      '/works/tasks',
      '/works/engineering-site-reports',
      '/works/survey-site-reports',
      '/works/contracts',
      '/hr/meetings',
    ]

    expect(operations.map(({ path }) => path)).toEqual(expectedPaths)
    expect(operations.every(({ section }) => section === 'Operations')).toBe(true)

    const operationsDestination = operations[0]!
    expect(canVisitDestination(operationsDestination, { projects: ['list'] })).toBe(true)
    expect(canVisitDestination(operationsDestination, { tasks: ['list'] })).toBe(true)
    expect(canVisitDestination(operationsDestination, {})).toBe(false)
    expect(canSeeDestination(operationsDestination, { tasks: ['list'] })).toBe(false)

    const engineeringReports = operations[4]!
    expect(
      canVisitDestination(engineeringReports, { engineering_site_reports: ['list_own'] }),
    ).toBe(true)
    expect(canSeeDestination(engineeringReports, { engineering_site_reports: ['list_own'] })).toBe(
      true,
    )
    expect(canVisitDestination(engineeringReports, { survey_site_reports: ['list'] })).toBe(false)
    expect(
      sidebarDestinationsFor({ tasks: ['list'] }).some(({ path }) => path === '/works/tasks'),
    ).toBe(true)
  })

  it('registers Operations detail paths as protected routes outside the sidebar', () => {
    const paths = [
      '/works/projects/detail',
      '/operations/projects/detail',
      '/operations/task/detail',
      '/operations/worksite/detail',
      '/operations/contract/detail',
      '/operations/timeline/detail',
    ]

    for (const path of paths) {
      const destination = PROTECTED_DESTINATIONS.find((item) => item.path === path)
      expect(destination, `${path} destination`).toBeDefined()
      expect(destination?.group).toBe('Operations')
      expect(destination?.inSidebar).toBe(false)
      expect(router.routesById[`/_protected${path}`]?.id).toBe(`/_protected${path}`)
    }

    expect(
      sidebarDestinationsFor({ projects: ['list'], tasks: ['list'], worksites: ['list'] }).some(
        ({ path }) => paths.includes(path),
      ),
    ).toBe(false)
  })

  it('routes Operations, the Projects register, and nested project tabs to their pages', () => {
    const operations = router.getMatchedRoutes('/operations')[2]
    const projects = router.getMatchedRoutes('/works/projects')[2]
    const detail = router.buildLocation({
      to: '/works/projects/$projectId',
      params: { projectId: '42' },
      search: { tab: 'milestones' },
    })

    expect(operations?.id).toBe('/_protected/operations')
    expect(projects?.id).toBe('/_protected/works/projects')
    expect(router.getMatchedRoutes(detail.pathname)[2]?.id).toBe(
      '/_protected/works/projects/$projectId',
    )
    expect(detail.pathname).toBe('/works/projects/42')
    expect(detail.search).toMatchObject({ tab: 'milestones' })
  })

  it('registers notification hooks under their protected route IDs', () => {
    expect(router.routesById['/_protected/notifications']?.id).toBe('/_protected/notifications')
    expect(router.routesById['/_protected/notifications/$notificationId']?.id).toBe(
      '/_protected/notifications/$notificationId',
    )

    const inboxLocation = router.buildLocation({
      to: '/notifications',
      search: { filter: 'unread' },
    })
    const detailLocation = router.buildLocation({
      to: '/notifications/$notificationId',
      params: { notificationId: '81' },
      search: { filter: 'all' },
    })

    expect(inboxLocation.search).toMatchObject({ filter: 'unread' })
    expect(detailLocation.pathname).toBe('/notifications/81')
    expect(detailLocation.search).toMatchObject({ filter: 'all' })
  })

  it('registers Profile and Role as explicit employee pages', () => {
    const [, , profileRoute] = router.getMatchedRoutes('/dashboard/my-profile')
    const [, , roleRoute] = router.getMatchedRoutes('/dashboard/role')
    expect(profileRoute?.path).toBe('dashboard/my-profile')
    expect(roleRoute?.path).toBe('dashboard/role')
  })

  it('keeps attendance status filters on the implemented attendance route', () => {
    const location = router.buildLocation({
      to: '/hr/attendance',
      search: { dateFrom: '2026-10-01', dateTo: '2026-10-20', page: 2 },
    })
    const [, , route] = router.getMatchedRoutes(location.pathname)
    expect(route?.path).toBe('hr/attendance')
    expect(location.search).toMatchObject({ dateFrom: '2026-10-01', dateTo: '2026-10-20', page: 2 })
  })

  it('registers explicit Recruitment and HR routes only once', () => {
    expect(router.routesById['/_protected/hr/job-post']?.id).toBe('/_protected/hr/job-post')
    expect(router.routesById['/_protected/hr/training-program']?.id).toBe(
      '/_protected/hr/training-program',
    )
    expect(router.routesById['/_protected/hr/loans']?.id).toBe('/_protected/hr/loans')
  })

  it('separates self-service finance destinations from HR registers by permission scope', () => {
    const myLoans = PROTECTED_DESTINATIONS.find(({ path }) => path === '/dashboard/my-loans')!
    const hrLoans = PROTECTED_DESTINATIONS.find(({ path }) => path === '/hr/loans')!
    const myPay = PROTECTED_DESTINATIONS.find(({ path }) => path === '/dashboard/my-pay')!
    const hrPayroll = PROTECTED_DESTINATIONS.find(({ path }) => path === '/hr/benefits')!

    expect(canVisitDestination(myLoans, { loans: ['list_own'] })).toBe(true)
    expect(canVisitDestination(myLoans, { loans: ['list'] })).toBe(false)
    expect(canVisitDestination(myLoans, { loans: ['list', 'list_own'] })).toBe(false)
    expect(canVisitDestination(hrLoans, { loans: ['list_own'] })).toBe(false)
    expect(canVisitDestination(hrLoans, { loans: ['list'] })).toBe(true)
    expect(canVisitDestination(myPay, { payroll: ['list_own'] })).toBe(true)
    expect(canVisitDestination(myPay, { payroll: ['list'] })).toBe(true)
    expect(canVisitDestination(hrPayroll, { payroll: ['list_own'] })).toBe(false)
    expect(canVisitDestination(hrPayroll, { payroll: ['list'] })).toBe(true)

    expect(router.routesById['/_protected/dashboard/my-loans']?.id).toBe(
      '/_protected/dashboard/my-loans',
    )
    expect(router.routesById['/_protected/dashboard/my-pay']?.id).toBe(
      '/_protected/dashboard/my-pay',
    )
  })

  it('keeps face and work-location setup on explicit routes with Attendance state', () => {
    const search = { dateFrom: '2026-10-01', dateTo: '2026-10-20', page: 3 }
    const faceLocation = router.buildLocation({
      to: '/hr/attendance/face-registration',
      search,
    })
    const [, , faceRoute] = router.getMatchedRoutes(faceLocation.pathname)
    expect(faceRoute?.path).toBe('hr/attendance/face-registration')
    expect(faceLocation.search).toMatchObject(search)

    const locationLocation = router.buildLocation({
      to: '/hr/attendance/work-locations/new',
      search: { ...search, sourceLocationId: 25 },
    })
    const [, , locationRoute] = router.getMatchedRoutes(locationLocation.pathname)
    expect(locationRoute?.path).toBe('hr/attendance/work-locations/new')
    expect(locationLocation.search).toMatchObject({ ...search, sourceLocationId: 25 })
  })

  it('keeps leave filters and request details on their implemented routes', () => {
    const listLocation = router.buildLocation({
      to: '/hr/leaves',
      search: { kind: 'all', status: 'rejected', page: 2 },
    })
    const [, , listRoute] = router.getMatchedRoutes(listLocation.pathname)
    expect(listRoute?.path).toBe('hr/leaves')
    expect(listLocation.search).toMatchObject({ kind: 'all', status: 'rejected', page: 2 })

    const detailLocation = router.buildLocation({
      to: '/hr/leaves/$requestId',
      params: { requestId: '42' },
      search: { kind: 'all', status: 'all', page: 1 },
    })
    const [, , detailRoute] = router.getMatchedRoutes(detailLocation.pathname)
    expect(detailRoute?.path).toBe('hr/leaves/$requestId')
  })

  it('registers a URL-filtered approval review route with All requests as the default', () => {
    const allLocation = router.buildLocation({ to: '/company/approval-requests' })
    const pendingLocation = router.buildLocation({
      to: '/company/approval-requests',
      search: { status: 'pending', search: 'budget', page: 2 },
    })
    const [, , route] = router.getMatchedRoutes(allLocation.pathname)

    expect(route?.path).toBe('company/approval-requests')
    expect(validateApprovalRequestsSearch(allLocation.search)).toEqual({
      status: 'all',
      search: '',
      page: 1,
    })
    expect(pendingLocation.search).toMatchObject({ status: 'pending', search: 'budget', page: 2 })
  })

  it('registers the Broadcast route with tabs, search and pagination in the URL', () => {
    const location = router.buildLocation({
      to: '/company/broadcast',
      search: { tab: 'events', search: 'planning', page: 3 },
    })
    const route = router.getMatchedRoutes(location.pathname)[2]

    expect(route?.path).toBe('company/broadcast')
    expect(validateBroadcastSearch(location.search)).toEqual({
      tab: 'events',
      search: 'planning',
      page: 3,
    })
    expect(validateBroadcastSearch({ tab: 'notifications', search: '', page: 1 }).tab).toBe(
      'announcements',
    )

    const destination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/company/broadcast')!
    expect(canVisitDestination(destination, { notifications: ['list'] })).toBe(false)
    expect(canVisitDestination(destination, { events: ['list'] })).toBe(true)
  })

  it('registers Approval Workflows with permission alternatives for flows and requests', () => {
    const destination = PROTECTED_DESTINATIONS.find(
      ({ path }) => path === '/company/approval-workflow',
    )
    const location = router.buildLocation({
      to: '/company/approval-workflow',
      search: { tab: 'requests', status: 'pending', search: 'leave', page: 2 },
    })
    const route = router.getMatchedRoutes(location.pathname)[2]

    expect(route?.path).toBe('company/approval-workflow')
    expect(validateApprovalWorkflowsSearch(location.search)).toMatchObject({
      tab: 'requests',
      status: 'pending',
      search: 'leave',
      page: 2,
    })
    expect(
      canVisitDestination(destination!, {
        approval_requests: ['list'],
      }),
    ).toBe(true)
  })

  it('registers Audit Log with supported URL filters and safe pagination defaults', () => {
    const location = router.buildLocation({
      to: '/company/audit-log',
      search: {
        search: ' login ',
        userId: '42',
        auditType: 'login_failed',
        auditStatus: 'warning',
        startDate: '2026-10-01',
        endDate: '2026-10-23',
        page: 2,
      },
    })
    const route = router.getMatchedRoutes(location.pathname)[2]

    expect(route?.path).toBe('company/audit-log')
    expect(location.search).toMatchObject({
      auditType: 'login_failed',
      auditStatus: 'warning',
      page: 2,
    })
    expect(validateAuditLogSearch({ page: '0', auditType: 'create', userId: 'nope' })).toEqual({
      search: '',
      userId: '',
      auditType: '',
      auditStatus: '',
      startDate: '',
      endDate: '',
      page: 1,
    })
  })

  it('registers Compliance record details and preserves register filters', () => {
    const location = router.buildLocation({
      to: '/company/compliance/$recordId',
      params: { recordId: '52' },
      search: { search: 'licence', complianceType: 'broker_license', page: 2 },
    })

    expect(router.getMatchedRoutes(location.pathname)[2]?.path).toBe('company/compliance/$recordId')
    expect(location.pathname).toBe('/company/compliance/52')
    expect(location.search).toMatchObject({
      search: 'licence',
      complianceType: 'broker_license',
      page: 2,
    })
  })

  it('registers organization catalog routes with shareable filters and chart scope', () => {
    const catalogLocation = router.buildLocation({
      to: '/company/department',
      search: { tab: 'units', search: 'finance', departmentId: '4', page: 2 },
    })
    const chartLocation = router.buildLocation({
      to: '/company/org-chart',
      search: { scope: 'branch:4|department:2|unit:8' },
    })
    expect(router.getMatchedRoutes(catalogLocation.pathname)[2]?.path).toBe('company/department')
    expect(catalogLocation.search).toMatchObject({
      tab: 'units',
      search: 'finance',
      departmentId: '4',
      page: 2,
    })
    expect(router.getMatchedRoutes(chartLocation.pathname)[2]?.path).toBe('company/org-chart')
    expect(chartLocation.search).toMatchObject({ scope: 'branch:4|department:2|unit:8' })
  })

  it('registers KPI Management as an implemented route and OKR Board as an explicit capability page', () => {
    const kpiLocation = router.buildLocation({
      to: '/company/kpi-management',
      search: { search: 'follow-ups', page: 2 },
    })
    const [, , kpiRoute] = router.getMatchedRoutes(kpiLocation.pathname)
    const [, , okrRoute] = router.getMatchedRoutes('/company/okr-board')

    expect(kpiRoute?.path).toBe('company/kpi-management')
    expect(validateKpiManagementSearch({ search: ' follow-ups ', page: '2' })).toEqual({
      search: ' follow-ups ',
      page: 2,
    })
    expect(validateKpiManagementSearch({ search: {}, page: 0 })).toEqual({ search: '', page: 1 })
    expect(okrRoute?.path).toBe('company/okr-board')
  })

  it('registers the company Assets and Knowledge Base pages explicitly', () => {
    const assetsLocation = router.buildLocation({
      to: '/company/assets',
      search: { search: 'laptop', page: 2 },
    })
    const assetsRoute = router.getMatchedRoutes(assetsLocation.pathname)[2]
    const knowledgeBaseRoute = router.getMatchedRoutes('/company/knowledge-base')[2]
    const assetDestination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/company/assets')

    expect(assetsRoute?.path).toBe('company/assets')
    expect(assetsLocation.search).toMatchObject({ search: 'laptop', page: 2 })
    expect(validateAssetsSearch({ search: ' serial ', page: '0' })).toEqual({
      search: ' serial ',
      page: 1,
    })
    expect(knowledgeBaseRoute?.path).toBe('company/knowledge-base')
    expect(canVisitDestination(assetDestination!, { assets: ['list'] })).toBe(true)
    expect(canVisitDestination(assetDestination!, { assets: ['create'] })).toBe(false)
  })

  it('registers durable Roles and Employees routes with safe URL state', () => {
    const rolesLocation = router.buildLocation({
      to: '/company/roles',
      search: { search: 'finance', page: 2 },
    })
    const roleDetail = router.buildLocation({
      to: '/company/roles/$roleId',
      params: { roleId: '23' },
    })
    const employeesLocation = router.buildLocation({
      to: '/hr/employees',
      search: { search: 'engineer', page: 3, view: 'past', branchId: '4', departmentId: '8' },
    })
    const employeeDetail = router.buildLocation({
      to: '/hr/employees/$userId',
      params: { userId: '52' },
      search: { section: 'reviews' },
    })

    expect(router.getMatchedRoutes(rolesLocation.pathname)[2]?.path).toBe('company/roles')
    expect(router.getMatchedRoutes(roleDetail.pathname)[2]?.path).toBe('company/roles/$roleId')
    expect(roleDetail.pathname).toBe('/company/roles/23')
    expect(router.getMatchedRoutes(employeesLocation.pathname)[2]?.path).toBe('hr/employees')
    expect(router.getMatchedRoutes(employeeDetail.pathname)[2]?.path).toBe('hr/employees/$userId')
    expect(employeeDetail.pathname).toBe('/hr/employees/52')
    expect(validateRolesSearch(rolesLocation.search)).toEqual({ search: 'finance', page: 2 })
    expect(validateEmployeesSearch(employeesLocation.search)).toEqual({
      search: 'engineer',
      page: 3,
      pageSize: 10,
      view: 'past',
      branchId: '4',
      departmentId: '8',
    })
    expect(validateEmployeeProfileSearch(employeeDetail.search)).toEqual({ section: 'reviews' })
    expect(
      validateEmployeesSearch({ page: '0', view: 'invalid', branchId: {}, departmentId: [] }),
    ).toEqual({
      search: '',
      page: 1,
      pageSize: 10,
      view: 'active',
      branchId: 'all',
      departmentId: 'all',
    })
    expect(validateEmployeeProfileSearch({ section: 'unknown' })).toEqual({ section: 'profile' })
    const rolesDestination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/company/roles')!
    expect(canVisitDestination(rolesDestination, { roles: ['list'] })).toBe(true)
    expect(canVisitDestination(rolesDestination, { roles: ['view'] })).toBe(false)
  })

  it('requires view access for Company Profile and does not grant entry from update alone', () => {
    const destination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/company')
    expect(destination).toBeDefined()
    expect(canVisitDestination(destination!, { company_settings: ['view'] })).toBe(true)
    expect(canVisitDestination(destination!, { company_settings: ['update'] })).toBe(false)
  })

  it('keeps the employee attendance compatibility path explicit', () => {
    const [, , route] = router.getMatchedRoutes('/employee/attendance')
    expect(route?.path).toBe('employee/attendance')
  })
})
