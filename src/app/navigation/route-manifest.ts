import type { PermissionSet } from '@/shared/auth/session'

export interface PermissionRequirement {
  resource: string
  action: string
}

export type NavigationGroup = 'Dashboard' | 'Company' | 'HR/Admin'
export type NavigationSection = 'Workspace' | 'People'
export type NavigationCategoryId =
  | 'my-work-output'
  | 'my-work-time'
  | 'my-work-account'
  | 'company-organization'
  | 'company-governance'
  | 'company-workflows'
  | 'company-planning'
  | 'hr-workforce'
  | 'hr-operations'
  | 'hr-performance'
  | 'hr-recognition'

export interface NavigationCategoryDefinition {
  id: NavigationCategoryId
  label: string
}

export const NAVIGATION_CATEGORIES: Record<
  NavigationGroup,
  readonly NavigationCategoryDefinition[]
> = {
  Dashboard: [
    { id: 'my-work-output', label: 'My tasks & goals' },
    { id: 'my-work-time', label: 'Time & leave' },
    { id: 'my-work-account', label: 'My account' },
  ],
  Company: [
    { id: 'company-organization', label: 'Organization' },
    { id: 'company-governance', label: 'Governance & oversight' },
    { id: 'company-workflows', label: 'Workflow & communication' },
    { id: 'company-planning', label: 'Planning & resources' },
  ],
  'HR/Admin': [
    { id: 'hr-workforce', label: 'People & access' },
    { id: 'hr-operations', label: 'HR operations' },
    { id: 'hr-performance', label: 'Performance & reporting' },
    { id: 'hr-recognition', label: 'Recognition & employee relations' },
  ],
}

export const NAVIGATION_CATEGORY_IDS: readonly NavigationCategoryId[] = Object.values(
  NAVIGATION_CATEGORIES,
).flatMap((categories) => categories.map(({ id }) => id))

const categoryByPath: Partial<Record<string, NavigationCategoryId>> = {
  '/dashboard/my-profile': 'my-work-account',
  '/dashboard/role': 'my-work-account',
  '/dashboard/my-tasks': 'my-work-output',
  '/dashboard/my-reports': 'my-work-output',
  '/dashboard/my-target-reports': 'my-work-output',
  '/hr/attendance': 'my-work-time',
  '/hr/leaves': 'my-work-time',
  '/company': 'company-organization',
  '/company/branch': 'company-organization',
  '/company/department': 'company-organization',
  '/company/org-chart': 'company-organization',
  '/company/board': 'company-governance',
  '/company/compliance': 'company-governance',
  '/company/audit-log': 'company-governance',
  '/company/approval-workflow': 'company-workflows',
  '/company/workspace-approvals': 'company-workflows',
  '/company/broadcast': 'company-workflows',
  '/company/kpi-management': 'company-planning',
  '/company/okr-board': 'company-planning',
  '/company/knowledge-base': 'company-planning',
  '/company/assets': 'company-planning',
  '/hr/employees': 'hr-workforce',
  '/hr/employees/profile': 'hr-workforce',
  '/hr/associates': 'hr-workforce',
  '/hr/job-post': 'hr-workforce',
  '/company/roles': 'hr-workforce',
  '/hr/attendance-calendar': 'hr-operations',
  '/hr/leave-request': 'hr-operations',
  '/hr/training-program': 'hr-operations',
  '/hr/loans': 'hr-operations',
  '/hr/benefits': 'hr-operations',
  '/hr/performance-review': 'hr-performance',
  '/hr/work-report': 'hr-performance',
  '/hr/monthly-scorecard': 'hr-performance',
  '/hr/employee-evaluation': 'hr-performance',
  '/hr/performance-engine': 'hr-performance',
  '/hr/awards-recognition': 'hr-recognition',
  '/hr/performance-leaderboard': 'hr-recognition',
  '/hr/disciplinary-process': 'hr-recognition',
  '/employee/attendance': 'my-work-time',
  '/employee/directory': 'hr-workforce',
  '/employee': 'my-work-account',
  '/employee/performance': 'my-work-output',
  '/employee/training': 'my-work-output',
  '/company/enugu': 'company-organization',
  '/company/roles/detail': 'hr-workforce',
  '/company/roles/$roleId': 'hr-workforce',
}

/** A single source for protected route guards, sidebar entries, breadcrumbs and landing order. */
export interface ProtectedDestination {
  path: string
  title: string
  /** Short, disambiguated label used only in navigation and search. */
  navigationLabel?: string
  section: NavigationSection
  group: NavigationGroup
  navigationCategory?: NavigationCategoryId
  /** Empty means any authenticated user, matching Flutter's public-to-logged-in route gates. */
  requiredPermissions: readonly PermissionRequirement[]
  /** Flutter's menu checks resource presence separately from its route action checks. */
  visibleResources: readonly string[]
  inSidebar: boolean
  icon: string
  order: number
}

function destination(
  path: string,
  title: string,
  group: NavigationGroup,
  requiredPermissions: readonly PermissionRequirement[] = [],
  visibleResources: readonly string[] = [],
  icon = 'page',
  order = 0,
  inSidebar = true,
  navigationLabel?: string,
): ProtectedDestination {
  return {
    path,
    title,
    ...(navigationLabel ? { navigationLabel } : {}),
    ...(categoryByPath[path] ? { navigationCategory: categoryByPath[path] } : {}),
    group,
    section: group === 'HR/Admin' ? 'People' : 'Workspace',
    requiredPermissions,
    visibleResources,
    inSidebar,
    icon,
    order,
  }
}

const p = (resource: string, action: string): PermissionRequirement => ({ resource, action })
const any = (...requirements: PermissionRequirement[]) => requirements

const dashboardResources = ['dashboard', 'employees', 'attendance', 'work_reports']

export const PROTECTED_DESTINATIONS: ProtectedDestination[] = [
  // Workspace > Overview and My Work. Order is the post-login fallback order.
  destination('/dashboard', 'Overview', 'Dashboard', [], dashboardResources, 'home', 0),
  destination(
    '/dashboard/my-profile',
    'Profile',
    'Dashboard',
    [],
    ['employees'],
    'user',
    1,
    true,
    'My profile',
  ),
  destination(
    '/dashboard/role',
    'Role',
    'Dashboard',
    any(p('roles', 'view_own'), p('roles', 'view')),
    ['roles'],
    'shield',
    2,
  ),
  destination(
    '/dashboard/my-tasks',
    'Tasks',
    'Dashboard',
    any(p('tasks', 'list_own'), p('tasks', 'list')),
    ['tasks'],
    'task',
    3,
  ),
  destination(
    '/dashboard/my-reports',
    'Work Reports',
    'Dashboard',
    any(p('work_reports', 'list_own'), p('work_reports', 'list')),
    ['work_reports'],
    'report',
    4,
  ),
  // Flutter has no routeRequirements entry for this screen, so its route is authenticated-only.
  destination(
    '/dashboard/my-target-reports',
    'Target',
    'Dashboard',
    [],
    ['employees'],
    'target',
    5,
  ),

  // Workspace > Company. Role administration is grouped under People > HR/Admin.
  destination(
    '/company/overview',
    'Company Overview',
    'Company',
    any(
      p('employees', 'list'),
      p('branches', 'list'),
      p('approval_requests', 'list'),
      p('client_inventory', 'list'),
      p('departments', 'list'),
      p('department_units', 'list'),
      p('assets', 'list'),
    ),
    [
      'employees',
      'branches',
      'approval_requests',
      'client_inventory',
      'departments',
      'department_units',
      'assets',
    ],
    'chart',
    9,
  ),
  destination(
    '/company',
    'Profile',
    'Company',
    any(p('company_settings', 'view'), p('company_settings', 'update')),
    ['company_settings'],
    'building',
    10,
    true,
    'Company profile',
  ),
  destination(
    '/company/branch',
    'Branch',
    'Company',
    any(p('branches', 'list'), p('branches', 'view')),
    ['branches'],
    'branch',
    11,
  ),
  destination(
    '/company/board',
    'Board',
    'Company',
    any(p('board_resolutions', 'list')),
    ['board_resolutions'],
    'board',
    12,
  ),
  destination(
    '/company/broadcast',
    'Broadcast',
    'Company',
    any(p('announcements', 'list')),
    ['announcements'],
    'broadcast',
    13,
  ),
  destination(
    '/company/roles',
    'Roles & Permissions',
    'HR/Admin',
    any(p('roles', 'list')),
    ['roles'],
    'shield',
    14,
  ),
  destination(
    '/company/org-chart',
    'Org Chart',
    'Company',
    any(p('roles', 'list')),
    ['roles'],
    'org',
    15,
  ),
  destination(
    '/company/kpi-management',
    'KPI Management',
    'Company',
    any(p('role_kpis', 'list')),
    ['roles'],
    'chart',
    16,
  ),
  destination(
    '/company/okr-board',
    'OKR Board',
    'Company',
    any(p('roles', 'list')),
    ['roles'],
    'target',
    17,
  ),
  destination(
    '/company/compliance',
    'Compliance Dashboard',
    'Company',
    any(p('compliance_records', 'list')),
    ['roles'],
    'shield',
    18,
  ),
  destination(
    '/company/knowledge-base',
    'Knowledge Base',
    'Company',
    any(p('roles', 'list')),
    ['roles'],
    'book',
    19,
  ),
  destination(
    '/company/approval-workflow',
    'Approval Workflows',
    'Company',
    any(p('approval_flows', 'list')),
    ['approval_flows'],
    'workflow',
    20,
  ),
  destination(
    '/company/workspace-approvals',
    'Workspace Approvals',
    'Company',
    any(
      p('work_locations', 'approve'),
      p('work_locations', 'reject'),
      p('work_locations', 'list_pending'),
      p('work_locations', 'manage'),
      p('work_locations', 'list_extensions'),
      p('work_locations', 'approve_extension'),
      p('work_locations', 'reject_extension'),
    ),
    ['work_locations'],
    'approvals',
    21,
  ),
  destination(
    '/company/department',
    'Departments & Units',
    'Company',
    any(p('departments', 'list')),
    ['departments'],
    'org',
    22,
  ),
  destination(
    '/company/assets',
    'Assets',
    'Company',
    any(p('assets', 'list')),
    ['assets'],
    'assets',
    23,
  ),
  destination(
    '/company/audit-log',
    'Audit Log',
    'Company',
    any(p('audit_logs', 'list')),
    ['audit_logs'],
    'audit',
    24,
  ),

  // People > HR/Admin.
  destination(
    '/hr',
    'HR Dashboard',
    'HR/Admin',
    any(p('employees', 'list'), p('job_postings', 'list'), p('leave_requests', 'list')),
    ['employees', 'job_postings', 'leave_requests'],
    'people',
    29,
  ),
  destination(
    '/hr/employees',
    'Employees',
    'HR/Admin',
    any(p('employees', 'list')),
    ['employees'],
    'people',
    30,
  ),
  destination(
    '/hr/attendance',
    'Attendance',
    'Dashboard',
    any(p('attendance', 'list'), p('attendance', 'list_own')),
    ['attendance'],
    'calendar',
    31,
  ),
  destination(
    '/hr/attendance-calendar',
    'Work Calendar',
    'HR/Admin',
    any(p('attendance_calendar', 'list')),
    ['attendance_calendar'],
    'calendar',
    32,
  ),
  destination(
    '/hr/job-post',
    'Recruitment',
    'HR/Admin',
    any(p('job_postings', 'list')),
    ['job_postings'],
    'recruitment',
    33,
  ),
  destination(
    '/hr/leaves',
    'My Leaves',
    'Dashboard',
    any(p('leave_requests', 'list_own'), p('leave_requests', 'list')),
    ['leave_requests'],
    'leave',
    34,
  ),
  destination(
    '/hr/leave-request',
    'Leave Requests',
    'HR/Admin',
    any(p('leave_requests', 'list')),
    ['leave_requests'],
    'leave',
    35,
  ),
  destination(
    '/hr/training-program',
    'Training',
    'HR/Admin',
    any(p('training_programs', 'list')),
    ['training_programs'],
    'training',
    36,
  ),
  destination(
    '/hr/loans',
    'Loans',
    'HR/Admin',
    any(p('loans', 'list_own'), p('loans', 'list')),
    ['loans'],
    'money',
    37,
  ),
  destination(
    '/hr/benefits',
    'Benefits',
    'HR/Admin',
    any(p('payroll', 'list'), p('payroll', 'list_own')),
    ['payroll'],
    'benefits',
    38,
  ),
  destination(
    '/hr/performance-review',
    'Performance',
    'HR/Admin',
    any(p('performance_reviews', 'list')),
    ['performance_reviews'],
    'chart',
    39,
  ),
  destination(
    '/hr/work-report',
    'Work Reports',
    'HR/Admin',
    any(p('work_reports', 'list')),
    ['work_reports'],
    'report',
    40,
  ),
  destination(
    '/hr/monthly-scorecard',
    'Monthly Scorecard',
    'HR/Admin',
    any(p('monthly_scorecards', 'list_own'), p('monthly_scorecards', 'list')),
    ['monthly_scorecards'],
    'scorecard',
    41,
  ),
  destination(
    '/hr/awards-recognition',
    'Awards & Recognition',
    'HR/Admin',
    any(p('awards', 'list')),
    ['awards'],
    'award',
    42,
  ),
  destination(
    '/hr/performance-leaderboard',
    'Performance Leaderboard',
    'HR/Admin',
    any(p('monthly_scorecards', 'list')),
    ['kpis'],
    'leaderboard',
    43,
  ),
  destination(
    '/hr/employee-evaluation',
    'Employee Evaluation',
    'HR/Admin',
    any(p('employee_evaluations', 'list')),
    ['employee_evaluations'],
    'evaluation',
    44,
  ),
  destination(
    '/hr/disciplinary-process',
    'Disciplinary Process',
    'HR/Admin',
    any(p('disciplinary_cases', 'list')),
    ['disciplinary_cases'],
    'warning',
    45,
  ),
  destination(
    '/hr/performance-engine',
    'Performance Engine',
    'HR/Admin',
    any(p('performance_reviews', 'list')),
    ['performance_reviews'],
    'chart',
    46,
  ),

  // Active registered direct routes related to the approved Workspace, Company and HR scope.
  // These are intentionally not sidebar entries; they preserve deep links while their pages are queued.
  destination(
    '/hr/employees/profile',
    'Employee Profile',
    'HR/Admin',
    any(p('employees', 'view'), p('employees', 'view_own')),
    [],
    'user',
    101,
    false,
  ),
  destination(
    '/hr/associates',
    'Associates',
    'HR/Admin',
    any(p('employees', 'list')),
    [],
    'people',
    102,
    false,
  ),
  destination('/employee', 'Employee Home', 'Dashboard', [], [], 'user', 103, false),
  destination(
    '/employee/directory',
    'Employee Directory',
    'HR/Admin',
    any(p('employees', 'list')),
    [],
    'people',
    104,
    false,
  ),
  destination(
    '/employee/performance',
    'Employee Performance',
    'Dashboard',
    any(p('performance_reviews', 'list'), p('performance_reviews', 'list_own')),
    [],
    'chart',
    105,
    false,
  ),
  destination(
    '/employee/attendance',
    'Employee Attendance',
    'Dashboard',
    [],
    [],
    'calendar',
    106,
    false,
  ),
  destination(
    '/employee/training',
    'Employee Training',
    'Dashboard',
    any(p('training_programs', 'list')),
    [],
    'training',
    107,
    false,
  ),
  destination(
    '/company/enugu',
    'Enugu Branch',
    'Company',
    any(p('branches', 'list'), p('branches', 'view')),
    [],
    'branch',
    108,
    false,
  ),
  // Flutter omits these role-detail paths from its route permission map (authenticated-only fallback).
  // React inherits roles:list from the parent Roles page to avoid that fail-open gap. The legacy
  // /detail route also depends on an in-memory extra; durable role links use /company/roles/$roleId.
  destination(
    '/company/roles/detail',
    'Role Details',
    'HR/Admin',
    any(p('roles', 'list')),
    [],
    'shield',
    109,
    false,
  ),
  destination(
    '/company/roles/$roleId',
    'Role Details',
    'HR/Admin',
    any(p('roles', 'list')),
    [],
    'shield',
    110,
    false,
  ),
  destination('/workspace', 'Workspace', 'Dashboard', [], [], 'workspace', 111, false),
  destination(
    '/workspace-dashboard',
    'Workspace Dashboard',
    'Dashboard',
    [],
    [],
    'workspace',
    112,
    false,
  ),
]

export const NAVIGATION_GROUPS: readonly NavigationGroup[] = ['Dashboard', 'Company', 'HR/Admin']

export function destinationForPath(pathname: string): ProtectedDestination | undefined {
  return PROTECTED_DESTINATIONS.find((item) => matchDestinationPath(item.path, pathname))
}

export function matchDestinationPath(pattern: string, pathname: string): boolean {
  if (!pattern.includes('$')) return pattern === pathname
  const expression = new RegExp(
    `^${pattern
      .split('/')
      .map((part) => (part.startsWith('$') ? '[^/]+' : escapeRegExp(part)))
      .join('/')}/?$`,
  )
  return expression.test(pathname)
}

function escapeRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

export function canVisitDestination(
  destination: ProtectedDestination,
  permissions: PermissionSet,
): boolean {
  return (
    destination.requiredPermissions.length === 0 ||
    destination.requiredPermissions.some(
      ({ resource, action }) => permissions[resource]?.includes(action) ?? false,
    )
  )
}

export function canSeeDestination(
  destination: ProtectedDestination,
  permissions: PermissionSet,
): boolean {
  return (
    destination.visibleResources.length === 0 ||
    destination.visibleResources.some((resource) => (permissions[resource]?.length ?? 0) > 0)
  )
}

export function sidebarDestinationsFor(permissions: PermissionSet): ProtectedDestination[] {
  return PROTECTED_DESTINATIONS.filter(
    (destination) =>
      destination.inSidebar &&
      canSeeDestination(destination, permissions) &&
      canVisitDestination(destination, permissions),
  )
}
