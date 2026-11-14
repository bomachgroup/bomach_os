import { QueryClient } from '@tanstack/react-query'
import {
  Outlet,
  createRootRouteWithContext,
  createRoute,
  createRouter,
  redirect,
} from '@tanstack/react-router'
import { lazy, type ComponentType, type LazyExoticComponent } from 'react'
import type { AnyRoute } from '@tanstack/react-router'

import { ApiError } from '@/shared/api/api-error'
import {
  requireAuthenticatedSession,
  requirePermission,
  requireProtectedDestination,
} from '@/shared/auth/route-guards'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import {
  isMarketingWorkspaceHref,
  isServicesWorkspaceHref,
  resolveWorkspaceEntryTarget,
} from '@/shared/auth/navigation'
import { NoAccessPage, NotFoundPage, RootLayout, RouteError } from './route-components'
import { PROTECTED_DESTINATIONS } from '@/app/navigation/route-manifest'
import { AppShell, ComingSoonPage } from '@/app/shell/app-shell'
import { validateMyTasksSearch } from '@/modules/tasks/tasks.search'
import {
  hasNonCanonicalWorkReportsSearch,
  validateWorkReportsSearch,
} from '@/modules/work-reports/work-reports.search'
import { validateMyTargetsSearch } from '@/modules/targets/targets.search'
import { validateMyLeavesSearch } from '@/modules/leaves/leaves.search'
import { validateRecruitmentSearch } from '@/modules/hr/recruitment.search'
import { validateHRLeaveRequestsSearch } from '@/modules/hr/leave-requests.search'
import { validateHRWorkReportsSearch } from '@/modules/hr/work-reports.search'
import { validateLoansSearch } from '@/modules/hr/loans.search'
import { validateMyLoansSearch } from '@/modules/hr/my-loans.search'
import { validateMyPaySearch } from '@/modules/hr/my-pay.search'
import {
  loansRouteAudience,
  myLoansSearchFromLegacy,
  myPaySearchFromLegacy,
  payrollRouteAudience,
} from '@/modules/hr/personal-finance-routing'
import { validateTrainingProgramsSearch } from '@/modules/hr/training-programs.search'
import { validateBenefitsSearch } from '@/modules/hr/benefits.search'
import { validatePerformanceReviewsSearch } from '@/modules/hr/performance-reviews.search'
import {
  validateEvaluationSearch,
  validateScorecardSearch,
} from '@/modules/hr/performance-analytics.search'
import {
  validateRecognitionSearch,
  validateLeaderboardSearch,
} from '@/modules/hr/recognition.search'
import { validateApprovalRequestsSearch } from '@/modules/company/approval-requests.search'
import { validateApprovalWorkflowsSearch } from '@/modules/company/approval-workflows.search'
import { validateBroadcastSearch } from '@/modules/company/broadcast.search'
import { validateAuditLogSearch } from '@/modules/company/audit-log.search'
import { validateBoardSearch, validateComplianceSearch } from '@/modules/company/governance.search'
import {
  validateDepartmentSearch,
  validateOrgChartSearch,
} from '@/modules/company/company-organization.search'
import { validateKpiManagementSearch } from '@/modules/company/kpi-management.search'
import { validateRolesSearch } from '@/modules/company/roles.search'
import { validateRoleDetailSearch } from '@/modules/company/role-detail.search'
import {
  validateEmployeeProfileSearch,
  validateEmployeesSearch,
} from '@/modules/hr/employees.search'
import { validateBranchDirectorySearch } from '@/modules/company/branches.search'
import { validateAssetsSearch } from '@/modules/company/assets.search'
import { validateNotificationsSearch } from '@/shared/notifications/notifications.search'
import {
  validateAttendanceSearch,
  validateAttendanceSetupSearch,
} from '@/modules/attendance/attendance.search'
import {
  validateProjectDetailSearch,
  validateProjectsSearch,
} from '@/modules/operations/projects.search'
import {
  validateEngineeringReportsSearch,
  validateOperationsTasksSearch,
  validateWorksitesSearch,
} from '@/modules/operations/operations-registers.search'
import {
  validateContractWorkflowSearch,
  validateMeetingWorkflowSearch,
  validateSurveyWorkflowSearch,
} from '@/modules/operations/operations-workflows.search'

type EmptyRouteProps = Record<string, never>

type LazyRouteComponent = LazyExoticComponent<ComponentType<EmptyRouteProps>> & {
  preload: () => Promise<void>
}

function lazyRouteComponent<
  TModule extends Record<string, unknown>,
  TExport extends keyof TModule = 'default',
>(importer: () => Promise<TModule>, exportName?: TExport): LazyRouteComponent {
  let modulePromise: Promise<TModule> | undefined
  const loadModule = () => {
    if (!modulePromise) {
      modulePromise = importer().catch((error: unknown) => {
        modulePromise = undefined
        throw error
      })
    }
    return modulePromise
  }

  const routeComponent = lazy<ComponentType<EmptyRouteProps>>(async () => {
    const module = await loadModule()
    return {
      default: module[exportName ?? ('default' as TExport)] as ComponentType<EmptyRouteProps>,
    }
  }) as LazyRouteComponent
  routeComponent.preload = () => loadModule().then(() => undefined)
  return routeComponent
}

const FoundationPreview = lazyRouteComponent(() => import('@/app/FoundationPreview'), 'default')
const BiometricPage = lazyRouteComponent(
  () => import('@/modules/auth/routes/biometric-page'),
  'BiometricPage',
)
const ForgotPasswordPage = lazyRouteComponent(
  () => import('@/modules/auth/routes/forgot-password-page'),
  'ForgotPasswordPage',
)
const LoginPage = lazyRouteComponent(() => import('@/modules/auth/routes/login-page'), 'LoginPage')
const ResetPasswordPage = lazyRouteComponent(
  () => import('@/modules/auth/routes/reset-password-page'),
  'ResetPasswordPage',
)
const SplashPage = lazyRouteComponent(
  () => import('@/modules/auth/routes/splash-page'),
  'SplashPage',
)
const StaffPrivacyPage = lazyRouteComponent(
  () => import('@/modules/auth/routes/staff-privacy-page'),
  'StaffPrivacyPage',
)
const TwoFactorVerifyPage = lazyRouteComponent(
  () => import('@/modules/auth/routes/two-factor-verify-page'),
  'TwoFactorVerifyPage',
)
const WorkspaceOverviewPage = lazyRouteComponent(
  () => import('@/modules/dashboard/routes/workspace-overview-page'),
  'WorkspaceOverviewPage',
)
const MyProfilePage = lazyRouteComponent(
  () => import('@/modules/dashboard/routes/my-profile-page'),
  'MyProfilePage',
)
const MyRolePage = lazyRouteComponent(
  () => import('@/modules/dashboard/routes/my-role-page'),
  'MyRolePage',
)
const CompanyOverviewPage = lazyRouteComponent(
  () => import('@/modules/company/routes/company-overview-page'),
  'CompanyOverviewPage',
)
const CompanyProfilePage = lazyRouteComponent(
  () => import('@/modules/company/routes/company-profile-page'),
  'CompanyProfilePage',
)
const ApprovalRequestsPage = lazyRouteComponent(
  () => import('@/modules/company/routes/approval-requests-page'),
  'ApprovalRequestsPage',
)
const ApprovalWorkflowsPage = lazyRouteComponent(
  () => import('@/modules/company/routes/approval-workflows-page'),
  'ApprovalWorkflowsPage',
)
const BroadcastPage = lazyRouteComponent(
  () => import('@/modules/company/routes/broadcast-page'),
  'BroadcastPage',
)
const AuditLogPage = lazyRouteComponent(
  () => import('@/modules/company/routes/audit-log-page'),
  'AuditLogPage',
)
const BoardPage = lazyRouteComponent(
  () => import('@/modules/company/routes/board-page'),
  'BoardPage',
)
const BoardRecordDetailPage = lazyRouteComponent(
  () => import('@/modules/company/routes/board-record-detail-page'),
  'BoardRecordDetailPage',
)
const CompliancePage = lazyRouteComponent(
  () => import('@/modules/company/routes/compliance-page'),
  'CompliancePage',
)
const BranchDirectoryPage = lazyRouteComponent(
  () => import('@/modules/company/routes/branch-directory-page'),
  'BranchDirectoryPage',
)
const BranchDetailPage = lazyRouteComponent(
  () => import('@/modules/company/routes/branch-detail-page'),
  'BranchDetailPage',
)
const DepartmentsUnitsPage = lazyRouteComponent(
  () => import('@/modules/company/routes/departments-units-page'),
  'DepartmentsUnitsPage',
)
const OrgChartPage = lazyRouteComponent(
  () => import('@/modules/company/routes/org-chart-page'),
  'OrgChartPage',
)
const KpiManagementPage = lazyRouteComponent(
  () => import('@/modules/company/routes/kpi-management-page'),
  'KpiManagementPage',
)
const RolesPage = lazyRouteComponent(
  () => import('@/modules/company/routes/roles-page'),
  'RolesPage',
)
const RoleDetailPage = lazyRouteComponent(
  () => import('@/modules/company/routes/role-detail-page'),
  'RoleDetailPage',
)
const EmployeesPage = lazyRouteComponent(
  () => import('@/modules/hr/routes/employees-page'),
  'EmployeesPage',
)
const EmployeeProfilePage = lazyRouteComponent(
  () => import('@/modules/hr/routes/employee-profile-page'),
  'EmployeeProfilePage',
)
const RecruitmentPage = lazyRouteComponent(
  () => import('@/modules/hr/routes/recruitment-page'),
  'RecruitmentPage',
)
const LeaveRequestsPage = lazyRouteComponent(
  () => import('@/modules/hr/routes/leave-requests-page'),
  'LeaveRequestsPage',
)
const HRWorkReportsPage = lazyRouteComponent(
  () => import('@/modules/hr/routes/hr-work-reports-page'),
  'HRWorkReportsPage',
)
const BenefitsPage = lazyRouteComponent(
  () => import('@/modules/hr/routes/benefits-page'),
  'BenefitsPage',
)
const PerformanceReviewsPage = lazyRouteComponent(
  () => import('@/modules/hr/routes/performance-reviews-page'),
  'PerformanceReviewsPage',
)
const AwardsRecognitionPage = lazyRouteComponent(
  () => import('@/modules/hr/routes/awards-recognition-page'),
  'AwardsRecognitionPage',
)
const PerformanceLeaderboardPage = lazyRouteComponent(
  () => import('@/modules/hr/routes/performance-leaderboard-page'),
  'PerformanceLeaderboardPage',
)
const MonthlyScorecardPage = lazyRouteComponent(
  () => import('@/modules/hr/routes/monthly-scorecard-page'),
  'MonthlyScorecardPage',
)
const EmployeeEvaluationPage = lazyRouteComponent(
  () => import('@/modules/hr/routes/employee-evaluation-page'),
  'EmployeeEvaluationPage',
)
const PerformanceEnginePage = lazyRouteComponent(
  () => import('@/modules/hr/routes/performance-engine-page'),
  'PerformanceEnginePage',
)
const DisciplinaryProcessPage = lazyRouteComponent(
  () => import('@/modules/hr/routes/disciplinary-process-page'),
  'DisciplinaryProcessPage',
)
const TrainingProgramsPage = lazyRouteComponent(
  () => import('@/modules/hr/routes/training-programs-page'),
  'TrainingProgramsPage',
)
const LoansPage = lazyRouteComponent(() => import('@/modules/hr/routes/loans-page'), 'LoansPage')
const MyLoansPage = lazyRouteComponent(
  () => import('@/modules/hr/routes/loans-page'),
  'MyLoansPage',
)
const MyPayPage = lazyRouteComponent(() => import('@/modules/hr/routes/benefits-page'), 'MyPayPage')
const OkrBoardPage = lazyRouteComponent(
  () => import('@/modules/company/routes/okr-board-page'),
  'OkrBoardPage',
)
const AssetsPage = lazyRouteComponent(
  () => import('@/modules/company/routes/assets-page'),
  'AssetsPage',
)
const KnowledgeBasePage = lazyRouteComponent(
  () => import('@/modules/company/routes/knowledge-base-page'),
  'KnowledgeBasePage',
)
const HRDashboardPage = lazyRouteComponent(
  () => import('@/modules/hr/routes/hr-dashboard-page'),
  'HRDashboardPage',
)
const MyTasksPage = lazyRouteComponent(
  () => import('@/modules/tasks/routes/my-tasks-page'),
  'MyTasksPage',
)
const MyWorkReportsPage = lazyRouteComponent(
  () => import('@/modules/work-reports/routes/my-work-reports-page'),
  'MyWorkReportsPage',
)
const WorkReportFormPage = lazyRouteComponent(
  () => import('@/modules/work-reports/routes/work-report-form-page'),
  'WorkReportFormPage',
)
const WorkReportDetailPage = lazyRouteComponent(
  () => import('@/modules/work-reports/routes/work-report-detail-page'),
  'WorkReportDetailPage',
)
const SiteReportDetailPage = lazyRouteComponent(
  () => import('@/modules/work-reports/routes/site-report-pages'),
  'SiteReportDetailPage',
)
const SiteReportEditPage = lazyRouteComponent(
  () => import('@/modules/work-reports/routes/site-report-pages'),
  'SiteReportEditPage',
)
const SiteReportCreatePage = lazyRouteComponent(
  () => import('@/modules/work-reports/routes/site-report-create-page'),
  'SiteReportCreatePage',
)
const OperationsSiteReportCreatePage = lazyRouteComponent(
  () => import('@/modules/work-reports/routes/site-report-create-page'),
  'OperationsEngineeringSiteReportCreatePage',
)
const OperationsSiteReportEditPage = lazyRouteComponent(
  () => import('@/modules/work-reports/routes/site-report-pages'),
  'OperationsEngineeringSiteReportEditPage',
)
const WorksiteRegisterPage = lazyRouteComponent(
  () => import('@/modules/operations/routes/worksite-register-page'),
  'WorksiteRegisterPage',
)
const WorksiteDetailPage = lazyRouteComponent(
  () => import('@/modules/operations/routes/worksite-register-page'),
  'WorksiteDetailPage',
)
const OperationsTasksPage = lazyRouteComponent(
  () => import('@/modules/operations/routes/operations-tasks-page'),
  'OperationsTasksPage',
)
const OperationsTaskDetailPage = lazyRouteComponent(
  () => import('@/modules/operations/routes/operations-tasks-page'),
  'OperationsTaskDetailPage',
)
const EngineeringSiteReportsPage = lazyRouteComponent(
  () => import('@/modules/operations/routes/engineering-site-reports-page'),
  'EngineeringSiteReportsPage',
)
const SurveySiteReportsPage = lazyRouteComponent(
  () => import('@/modules/operations/routes/operations-workflow-pages'),
  'SurveySiteReportsPage',
)
const ContractsPage = lazyRouteComponent(
  () => import('@/modules/operations/routes/operations-workflow-pages'),
  'ContractsPage',
)
const MeetingsPage = lazyRouteComponent(
  () => import('@/modules/operations/routes/operations-workflow-pages'),
  'MeetingsPage',
)
const EngineeringSiteReportDetailPage = lazyRouteComponent(
  () => import('@/modules/operations/routes/engineering-site-reports-page'),
  'EngineeringSiteReportDetailPage',
)
const OperationsPage = lazyRouteComponent(
  () => import('@/modules/operations/routes/operations-page'),
  'OperationsPage',
)
const ProjectsPage = lazyRouteComponent(
  () => import('@/modules/operations/routes/projects-page'),
  'ProjectsPage',
)
const ProjectDetailPage = lazyRouteComponent(
  () => import('@/modules/operations/routes/project-detail-page'),
  'ProjectDetailPage',
)
const MyTargetsPage = lazyRouteComponent(
  () => import('@/modules/targets/routes/my-targets-page'),
  'MyTargetsPage',
)
const AttendancePage = lazyRouteComponent(
  () => import('@/modules/attendance/routes/attendance-page'),
  'AttendancePage',
)
const AttendanceFaceRegistrationPage = lazyRouteComponent(
  () => import('@/modules/attendance/routes/face-registration-page'),
  'FaceRegistrationPage',
)
const WorkLocationRegistrationPage = lazyRouteComponent(
  () => import('@/modules/attendance/routes/work-location-registration-page'),
  'WorkLocationRegistrationPage',
)
const MyLeavesPage = lazyRouteComponent(
  () => import('@/modules/leaves/routes/my-leaves-page'),
  'MyLeavesPage',
)
const LeaveRequestDetailPage = lazyRouteComponent(
  () => import('@/modules/leaves/routes/my-leaves-page'),
  'LeaveRequestDetailPage',
)
const NotificationsPage = lazyRouteComponent(
  () => import('@/modules/notifications/routes/notifications-page'),
  'NotificationsPage',
)
const NotificationDetailPage = lazyRouteComponent(
  () => import('@/modules/notifications/routes/notification-detail-page'),
  'NotificationDetailPage',
)

export interface AppRouterContext {
  queryClient: QueryClient
}

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: (failureCount, error) =>
        failureCount < 2 &&
        error instanceof ApiError &&
        (error.status === 0 || error.status >= 500),
    },
    mutations: { retry: 0 },
  },
})

function validateLoginSearch(search: Record<string, unknown>) {
  const result: { returnTo?: string; expired?: boolean; reset?: boolean } = {}
  if (typeof search.returnTo === 'string') result.returnTo = search.returnTo
  if (search.expired === true || search.expired === 'true' || search.expired === '1') {
    result.expired = true
  }
  if (search.reset === true || search.reset === 'true' || search.reset === '1') {
    result.reset = true
  }
  return result
}

const rootRoute = createRootRouteWithContext<AppRouterContext>()({
  component: RootLayout,
  errorComponent: RouteError,
  notFoundComponent: NotFoundPage,
})

const indexRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/',
  beforeLoad: () => {
    throw redirect({ to: '/splash' })
  },
})

const splashRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/splash',
  validateSearch: validateLoginSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAuthenticatedSession(context, location)
  },
  component: SplashPage,
})

const loginRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/login',
  validateSearch: validateLoginSearch,
  beforeLoad: async ({ context, location }) => {
    try {
      const session = await context.queryClient.ensureQueryData(authSessionQueryOptions())
      const destination = resolveWorkspaceEntryTarget(
        (location.search as { returnTo?: string }).returnTo,
        session,
      )
      if (isServicesWorkspaceHref(destination) || isMarketingWorkspaceHref(destination)) {
        throw redirect({
          to: '/splash',
          search: { returnTo: destination },
          replace: true,
        })
      }
      throw redirect({
        href: destination,
        replace: true,
      })
    } catch (error) {
      if (error instanceof ApiError && error.status === 401) return
      throw error
    }
  },
  component: LoginPage,
})

const forgotPasswordRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/forgot-password',
  validateSearch: validateLoginSearch,
  component: ForgotPasswordPage,
})

const resetPasswordRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/reset-password',
  validateSearch: validateLoginSearch,
  component: ResetPasswordPage,
})

const biometricRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/biometric',
  component: BiometricPage,
})

const twoFactorRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/two-factor-verify',
  validateSearch: validateLoginSearch,
  component: TwoFactorVerifyPage,
})

const staffPrivacyRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/privacy',
  component: StaffPrivacyPage,
})

const protectedLayoutRoute = createRoute({
  getParentRoute: () => rootRoute,
  id: '_protected',
  beforeLoad: async ({ context, location }) => {
    await requireAuthenticatedSession(context, location)
  },
  component: () => (
    <AppShell>
      <Outlet />
    </AppShell>
  ),
})

const protectedNotFoundRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '$',
  component: NotFoundPage,
})

const noAccessRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: 'no-access',
  component: NoAccessPage,
})

const foundationPreviewRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/__foundation',
  component: FoundationPreview,
})

const myTasksDestination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/dashboard/my-tasks')
const myReportsDestination = PROTECTED_DESTINATIONS.find(
  ({ path }) => path === '/dashboard/my-reports',
)
const myTargetsDestination = PROTECTED_DESTINATIONS.find(
  ({ path }) => path === '/dashboard/my-target-reports',
)
const attendanceDestination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/hr/attendance')
const leavesDestination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/hr/leaves')
const profileDestination = PROTECTED_DESTINATIONS.find(
  ({ path }) => path === '/dashboard/my-profile',
)
const roleDestination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/dashboard/role')
const notificationsDestination = PROTECTED_DESTINATIONS.find(
  ({ path }) => path === '/notifications',
)
const approvalRequestsDestination = PROTECTED_DESTINATIONS.find(
  ({ path }) => path === '/company/approval-requests',
)
const approvalWorkflowsDestination = PROTECTED_DESTINATIONS.find(
  ({ path }) => path === '/company/approval-workflow',
)
const broadcastDestination = PROTECTED_DESTINATIONS.find(
  ({ path }) => path === '/company/broadcast',
)
const auditLogDestination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/company/audit-log')
const companyProfileDestination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/company')
const branchDirectoryDestination = PROTECTED_DESTINATIONS.find(
  ({ path }) => path === '/company/branch',
)
const departmentsUnitsDestination = PROTECTED_DESTINATIONS.find(
  ({ path }) => path === '/company/department',
)
const orgChartDestination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/company/org-chart')
const boardDestination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/company/board')
const complianceDestination = PROTECTED_DESTINATIONS.find(
  ({ path }) => path === '/company/compliance',
)
const kpiManagementDestination = PROTECTED_DESTINATIONS.find(
  ({ path }) => path === '/company/kpi-management',
)
const okrBoardDestination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/company/okr-board')
const assetsDestination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/company/assets')
const knowledgeBaseDestination = PROTECTED_DESTINATIONS.find(
  ({ path }) => path === '/company/knowledge-base',
)
const operationsDestination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/operations')
const projectsDestination = PROTECTED_DESTINATIONS.find(({ path }) => path === '/works/projects')
const projectDetailDestination = PROTECTED_DESTINATIONS.find(
  ({ path }) => path === '/works/projects/$projectId',
)

if (!myTasksDestination) throw new Error('The My Tasks route is missing from the route manifest.')
if (!myReportsDestination)
  throw new Error('The My Work Reports route is missing from the route manifest.')
if (!myTargetsDestination)
  throw new Error('The My Targets route is missing from the route manifest.')
if (!attendanceDestination)
  throw new Error('The Attendance route is missing from the route manifest.')
if (!leavesDestination) throw new Error('The My Leaves route is missing from the route manifest.')
if (!profileDestination) throw new Error('The My Profile route is missing from the route manifest.')
if (!roleDestination) throw new Error('The My Role route is missing from the route manifest.')
if (!notificationsDestination)
  throw new Error('The Notifications route is missing from the route manifest.')
if (!approvalRequestsDestination)
  throw new Error('The Approval Requests route is missing from the route manifest.')
if (!approvalWorkflowsDestination)
  throw new Error('The Approval Workflows route is missing from the route manifest.')
if (!broadcastDestination)
  throw new Error('The Broadcast route is missing from the route manifest.')
if (!auditLogDestination) throw new Error('The Audit Log route is missing from the route manifest.')
if (!companyProfileDestination)
  throw new Error('The Company Profile route is missing from the route manifest.')
if (!branchDirectoryDestination)
  throw new Error('The Branch Directory route is missing from the route manifest.')
if (!departmentsUnitsDestination)
  throw new Error('The Departments & Units route is missing from the route manifest.')
if (!orgChartDestination) throw new Error('The Org Chart route is missing from the route manifest.')
if (!boardDestination) throw new Error('The Board route is missing from the route manifest.')
if (!complianceDestination)
  throw new Error('The Compliance route is missing from the route manifest.')
if (!kpiManagementDestination)
  throw new Error('The KPI Management route is missing from the route manifest.')
if (!okrBoardDestination) throw new Error('The OKR Board route is missing from the route manifest.')
if (!assetsDestination) throw new Error('The Assets route is missing from the route manifest.')
if (!knowledgeBaseDestination)
  throw new Error('The Knowledge Base route is missing from the route manifest.')
if (!operationsDestination)
  throw new Error('The Operations route is missing from the route manifest.')
if (!projectsDestination) throw new Error('The Projects route is missing from the route manifest.')
if (!projectDetailDestination)
  throw new Error('The Project Details route is missing from the route manifest.')

const assetsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/assets',
  validateSearch: validateAssetsSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, assetsDestination)
  },
  component: AssetsPage,
})

const knowledgeBaseRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/knowledge-base',
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, knowledgeBaseDestination)
  },
  component: KnowledgeBasePage,
})

const myProfileRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/dashboard/my-profile',
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, profileDestination)
  },
  component: MyProfilePage,
})

const myRoleRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/dashboard/role',
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, roleDestination)
  },
  component: MyRolePage,
})

const notificationsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/notifications',
  validateSearch: validateNotificationsSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, notificationsDestination)
  },
  component: NotificationsPage,
})

const notificationDetailRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/notifications/$notificationId',
  validateSearch: validateNotificationsSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'notifications', actions: ['view'] },
    ])
  },
  component: NotificationDetailPage,
})

const approvalRequestsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/approval-requests',
  validateSearch: validateApprovalRequestsSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, approvalRequestsDestination)
  },
  component: ApprovalRequestsPage,
})

const approvalWorkflowsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/approval-workflow',
  validateSearch: validateApprovalWorkflowsSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, approvalWorkflowsDestination)
  },
  component: ApprovalWorkflowsPage,
})

const broadcastRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/broadcast',
  validateSearch: validateBroadcastSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, broadcastDestination)
  },
  component: BroadcastPage,
})

const auditLogRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/audit-log',
  validateSearch: validateAuditLogSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, auditLogDestination)
  },
  component: AuditLogPage,
})

const companyProfileRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company',
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, companyProfileDestination)
  },
  component: CompanyProfilePage,
})

const branchDirectoryRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/branch',
  validateSearch: validateBranchDirectorySearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, branchDirectoryDestination)
  },
  component: BranchDirectoryPage,
})

const departmentsUnitsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/department',
  validateSearch: validateDepartmentSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, departmentsUnitsDestination)
  },
  component: DepartmentsUnitsPage,
})

const orgChartRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/org-chart',
  validateSearch: validateOrgChartSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, orgChartDestination)
  },
  component: OrgChartPage,
})

const boardRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/board',
  validateSearch: validateBoardSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, boardDestination)
  },
  component: BoardPage,
})

const boardRecordDetailRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/board/$section/$recordId',
  validateSearch: validateBoardSearch,
  beforeLoad: async ({ context, location, params }) => {
    const sectionResources: Record<string, string> = {
      meetings: 'meetings',
      resolutions: 'board_resolutions',
      investors: 'shareholders',
      associates: 'employees',
      partners: 'partners',
    }
    const resource = sectionResources[params.section]
    await requireAnyPermission(
      context,
      location,
      resource
        ? [{ resource, actions: ['view'] }]
        : [
            { resource: 'meetings', actions: ['view'] },
            { resource: 'board_resolutions', actions: ['view'] },
            { resource: 'shareholders', actions: ['view'] },
            { resource: 'employees', actions: ['view'] },
            { resource: 'partners', actions: ['view'] },
          ],
    )
  },
  component: BoardRecordDetailPage,
})

const complianceRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/compliance',
  validateSearch: validateComplianceSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, complianceDestination)
  },
  component: CompliancePage,
})

const kpiManagementRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/kpi-management',
  validateSearch: validateKpiManagementSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, kpiManagementDestination)
  },
  component: KpiManagementPage,
})

const rolesRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/roles',
  validateSearch: validateRolesSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [{ resource: 'roles', actions: ['list'] }])
  },
  component: RolesPage,
})

const roleDetailRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/roles/$roleId',
  validateSearch: validateRoleDetailSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [{ resource: 'roles', actions: ['view'] }])
  },
  component: RoleDetailPage,
})

const employeesRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/employees',
  validateSearch: validateEmployeesSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [{ resource: 'employees', actions: ['list'] }])
  },
  component: EmployeesPage,
})

const employeeProfileRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/employees/$userId',
  validateSearch: validateEmployeeProfileSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'employees', actions: ['view', 'view_own'] },
    ])
  },
  component: EmployeeProfilePage,
})

const recruitmentRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/job-post',
  validateSearch: validateRecruitmentSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'job_postings', actions: ['list'] },
      { resource: 'applicants', actions: ['list'] },
    ])
  },
  component: RecruitmentPage,
})

const hrLeaveRequestsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/leave-request',
  validateSearch: validateHRLeaveRequestsSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'leave_requests', actions: ['list'] },
    ])
  },
  component: LeaveRequestsPage,
})

const hrWorkReportsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/work-report',
  validateSearch: validateHRWorkReportsSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [{ resource: 'work_reports', actions: ['list'] }])
  },
  component: HRWorkReportsPage,
})

const hrBenefitsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/benefits',
  validateSearch: validateBenefitsSearch,
  beforeLoad: async ({ context, location }) => {
    const session = await requireAuthenticatedSession(context, location)
    const audience = payrollRouteAudience(session.permissions)
    if (audience === 'hr') return
    if (audience === 'personal') {
      throw redirect({ to: '/dashboard/my-pay', search: myPaySearchFromLegacy(location.searchStr) })
    }
    throw redirect({ to: '/no-access' })
  },
  component: BenefitsPage,
})

const performanceReviewsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/performance-review',
  validateSearch: validatePerformanceReviewsSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'performance_reviews', actions: ['list'] },
    ])
  },
  component: PerformanceReviewsPage,
})

const awardsRecognitionRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/awards-recognition',
  validateSearch: validateRecognitionSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [{ resource: 'awards', actions: ['list'] }])
  },
  component: AwardsRecognitionPage,
})

const performanceLeaderboardRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/performance-leaderboard',
  validateSearch: validateLeaderboardSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'monthly_scorecards', actions: ['list'] },
    ])
  },
  component: PerformanceLeaderboardPage,
})

const monthlyScorecardRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/monthly-scorecard',
  validateSearch: validateScorecardSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'monthly_scorecards', actions: ['view', 'view_own'] },
    ])
  },
  component: MonthlyScorecardPage,
})

const employeeEvaluationRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/employee-evaluation',
  validateSearch: validateEvaluationSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'employee_evaluations', actions: ['list', 'list_own', 'create'] },
    ])
  },
  component: EmployeeEvaluationPage,
})

const performanceEngineRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/performance-engine',
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'performance_reviews', actions: ['list'] },
    ])
  },
  component: PerformanceEnginePage,
})

const disciplinaryProcessRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/disciplinary-process',
  validateSearch: validateRecognitionSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'disciplinary_cases', actions: ['list', 'list_own'] },
    ])
  },
  component: DisciplinaryProcessPage,
})

const trainingProgramsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/training-program',
  validateSearch: validateTrainingProgramsSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'training_programs', actions: ['list'] },
    ])
  },
  component: TrainingProgramsPage,
})

const loansRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/loans',
  validateSearch: validateLoansSearch,
  beforeLoad: async ({ context, location }) => {
    const session = await requireAuthenticatedSession(context, location)
    const audience = loansRouteAudience(session.permissions)
    if (audience === 'hr') return
    if (audience === 'personal') {
      throw redirect({
        to: '/dashboard/my-loans',
        search: myLoansSearchFromLegacy(location.searchStr),
      })
    }
    throw redirect({ to: '/no-access' })
  },
  component: LoansPage,
})

const myLoansRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/dashboard/my-loans',
  validateSearch: validateMyLoansSearch,
  beforeLoad: async ({ context, location }) => {
    const session = await requireAuthenticatedSession(context, location)
    const audience = loansRouteAudience(session.permissions)
    if (audience === 'hr') {
      const personalSearch = validateMyLoansSearch(
        Object.fromEntries(new URLSearchParams(location.searchStr)),
      )
      throw redirect({
        to: '/hr/loans',
        search: {
          view: 'all',
          search: '',
          status: personalSearch.status,
          request_id: personalSearch.request_id,
          page: personalSearch.page,
          pageSize: personalSearch.pageSize,
        },
      })
    }
    if (audience === 'denied') {
      throw redirect({ to: '/no-access' })
    }
  },
  component: MyLoansPage,
})

const myPayRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/dashboard/my-pay',
  validateSearch: validateMyPaySearch,
  beforeLoad: async ({ context, location }) => {
    const session = await requireAuthenticatedSession(context, location)
    if (payrollRouteAudience(session.permissions) === 'denied') {
      throw redirect({ to: '/no-access' })
    }
  },
  component: MyPayPage,
})

const okrBoardRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/okr-board',
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, okrBoardDestination)
  },
  component: OkrBoardPage,
})

const complianceRecordDetailRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/compliance/$recordId',
  validateSearch: validateComplianceSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'compliance_records', actions: ['view'] },
    ])
  },
  component: lazyRouteComponent(
    () => import('@/modules/company/routes/compliance-record-detail-page'),
    'ComplianceRecordDetailPage',
  ),
})

const myTasksRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/dashboard/my-tasks',
  validateSearch: validateMyTasksSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, myTasksDestination)
  },
  component: MyTasksPage,
})

const myWorkReportsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/dashboard/my-reports',
  validateSearch: validateWorkReportsSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, myReportsDestination)
    if (hasNonCanonicalWorkReportsSearch(location.searchStr)) {
      const normalized = validateWorkReportsSearch(
        Object.fromEntries(new URLSearchParams(location.searchStr)),
      )
      const search = new URLSearchParams({
        type: normalized.type,
        status: normalized.status,
        page: String(normalized.page),
      })
      throw redirect({ href: `/dashboard/my-reports?${search}`, replace: true })
    }
  },
  component: MyWorkReportsPage,
})

const myTargetsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/dashboard/my-target-reports',
  validateSearch: validateMyTargetsSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, myTargetsDestination)
  },
  component: MyTargetsPage,
})

const attendanceRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/attendance',
  validateSearch: validateAttendanceSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, attendanceDestination)
  },
  component: AttendancePage,
})

const operationsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/operations',
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, operationsDestination)
  },
  component: OperationsPage,
})

const projectsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/works/projects',
  validateSearch: validateProjectsSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, projectsDestination)
  },
  component: ProjectsPage,
})

const projectDetailRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/works/projects/$projectId',
  validateSearch: validateProjectDetailSearch,
  beforeLoad: async ({ context, location }) => {
    await requirePermission(context, location, 'projects', 'view')
  },
  component: ProjectDetailPage,
})

const worksitesRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/works/worksite',
  validateSearch: validateWorksitesSearch,
  beforeLoad: async ({ context, location }) => {
    await requirePermission(context, location, 'worksites', 'list')
  },
  component: WorksiteRegisterPage,
})

const worksiteDetailRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/works/worksite/$worksiteId',
  beforeLoad: async ({ context, location }) => {
    await requirePermission(context, location, 'worksites', 'view')
  },
  component: WorksiteDetailPage,
})

const operationsTasksRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/works/tasks',
  validateSearch: validateOperationsTasksSearch,
  beforeLoad: async ({ context, location }) => {
    await requirePermission(context, location, 'tasks', 'list')
  },
  component: OperationsTasksPage,
})

const operationsTaskDetailRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/works/tasks/$taskId',
  beforeLoad: async ({ context, location }) => {
    await requirePermission(context, location, 'tasks', 'view')
  },
  component: OperationsTaskDetailPage,
})

const engineeringSiteReportsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/works/engineering-site-reports',
  validateSearch: validateEngineeringReportsSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'engineering_site_reports', actions: ['list', 'list_own'] },
    ])
  },
  component: EngineeringSiteReportsPage,
})

const surveySiteReportsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/works/survey-site-reports',
  validateSearch: validateSurveyWorkflowSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'survey_site_reports', actions: ['list', 'list_own'] },
    ])
  },
  component: SurveySiteReportsPage,
})

const contractsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/works/contracts',
  validateSearch: validateContractWorkflowSearch,
  beforeLoad: async ({ context, location }) => {
    await requirePermission(context, location, 'contracts', 'list')
  },
  component: ContractsPage,
})

const meetingsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/meetings',
  validateSearch: validateMeetingWorkflowSearch,
  beforeLoad: async ({ context, location }) => {
    await requirePermission(context, location, 'meetings', 'list')
  },
  component: MeetingsPage,
})

const engineeringSiteReportDetailRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/works/engineering-site-reports/$reportId',
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'engineering_site_reports', actions: ['view', 'view_own'] },
    ])
  },
  component: EngineeringSiteReportDetailPage,
})

const engineeringSiteReportCreateRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/works/engineering-site-reports/create',
  beforeLoad: async ({ context, location }) => {
    const session = await requireAuthenticatedSession(context, location)
    if (
      !hasPermission(session.permissions, 'engineering_site_reports', 'create') ||
      !hasPermission(session.permissions, 'worksites', 'list')
    )
      throw redirect({ to: '/no-access' })
  },
  component: OperationsSiteReportCreatePage,
})

const engineeringSiteReportEditRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/works/engineering-site-reports/$reportId/edit',
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'engineering_site_reports', actions: ['update', 'update_own'] },
    ])
  },
  component: OperationsSiteReportEditPage,
})

async function requireAnyPermission(
  context: AppRouterContext,
  location: { pathname: string; searchStr: string; hash: string },
  requirements: Array<{ resource: string; actions: string[] }>,
) {
  const session = await requireAuthenticatedSession(context, location)
  const allowed = requirements.some(({ resource, actions }) =>
    actions.some((action) => hasPermission(session.permissions, resource, action)),
  )
  if (!allowed) throw redirect({ to: '/no-access' })
}

const branchDetailRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/company/branch/$branchId',
  validateSearch: validateBranchDirectorySearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [{ resource: 'branches', actions: ['view'] }])
  },
  component: BranchDetailPage,
})

const attendanceFaceRegistrationRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/attendance/face-registration',
  validateSearch: validateAttendanceSetupSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'attendance', actions: ['list', 'list_own'] },
    ])
  },
  component: AttendanceFaceRegistrationPage,
})

const attendanceWorkLocationRegistrationRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/attendance/work-locations/new',
  validateSearch: validateAttendanceSetupSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyPermission(context, location, [
      { resource: 'work_locations', actions: ['submit'] },
    ])
  },
  component: WorkLocationRegistrationPage,
})

const myLeavesRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/leaves',
  validateSearch: validateMyLeavesSearch,
  beforeLoad: async ({ context, location }) => {
    await requireProtectedDestination(context, location, leavesDestination)
  },
  component: MyLeavesPage,
})

const leaveRequestDetailRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/hr/leaves/$requestId',
  validateSearch: validateMyLeavesSearch,
  beforeLoad: async ({ context, location }) => {
    const session = await requireAuthenticatedSession(context, location)
    const canView = ['view_own', 'view'].some((action) =>
      hasPermission(session.permissions, 'leave_requests', action),
    )
    if (!canView) throw redirect({ to: '/no-access' })
  },
  component: LeaveRequestDetailPage,
})

const employeeAttendanceAliasRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/employee/attendance',
  beforeLoad: () => {
    throw redirect({ to: '/hr/attendance', search: { dateFrom: '', dateTo: '', page: 1 } })
  },
})

async function requireAnyWorkReportPermission(
  context: AppRouterContext,
  location: { pathname: string; searchStr: string; hash: string },
  actions: string[],
) {
  const session = await requireAuthenticatedSession(context, location)
  if (!actions.some((action) => hasPermission(session.permissions, 'work_reports', action))) {
    throw redirect({ to: '/no-access' })
  }
}

async function requireSiteReportPermission(
  context: AppRouterContext,
  location: { pathname: string; searchStr: string; hash: string },
  reportType: string | undefined,
  action: 'view' | 'update',
) {
  const session = await requireAuthenticatedSession(context, location)
  const resource =
    reportType === 'engineering'
      ? 'engineering_site_reports'
      : reportType === 'survey'
        ? 'survey_site_reports'
        : null
  if (
    !resource ||
    ![
      hasPermission(session.permissions, resource, action),
      hasPermission(session.permissions, resource, `${action}_own`),
    ].some(Boolean)
  ) {
    throw redirect({ to: '/no-access' })
  }
}

async function requireSiteReportCreatePermission(
  context: AppRouterContext,
  location: { pathname: string; searchStr: string; hash: string },
  reportType: string | undefined,
) {
  const session = await requireAuthenticatedSession(context, location)
  const resource =
    reportType === 'engineering'
      ? 'engineering_site_reports'
      : reportType === 'survey'
        ? 'survey_site_reports'
        : null
  if (
    !resource ||
    !hasPermission(session.permissions, resource, 'create') ||
    !hasPermission(session.permissions, 'worksites', 'list')
  ) {
    throw redirect({ to: '/no-access' })
  }
}

const workReportCreateRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/dashboard/my-reports/create',
  validateSearch: validateWorkReportsSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyWorkReportPermission(context, location, ['create'])
  },
  component: WorkReportFormPage,
})

const siteReportCreateRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/dashboard/my-reports/create-site/$reportType',
  validateSearch: validateWorkReportsSearch,
  beforeLoad: async ({ context, location, params }) => {
    await requireSiteReportCreatePermission(context, location, params.reportType)
  },
  component: SiteReportCreatePage,
})

const workReportDetailRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/dashboard/my-reports/$reportId',
  validateSearch: validateWorkReportsSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyWorkReportPermission(context, location, ['view_own', 'view'])
  },
  component: WorkReportDetailPage,
})

const workReportEditRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/dashboard/my-reports/$reportId/edit',
  validateSearch: validateWorkReportsSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAnyWorkReportPermission(context, location, ['update_own', 'update'])
  },
  component: WorkReportFormPage,
})

const personalSiteReportDetailRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/dashboard/my-reports/site/$reportType/$reportId',
  validateSearch: validateWorkReportsSearch,
  beforeLoad: async ({ context, location, params }) => {
    await requireSiteReportPermission(context, location, params.reportType, 'view')
  },
  component: SiteReportDetailPage,
})

const personalSiteReportEditRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/dashboard/my-reports/site/$reportType/$reportId/edit',
  validateSearch: validateWorkReportsSearch,
  beforeLoad: async ({ context, location, params }) => {
    await requireSiteReportPermission(context, location, params.reportType, 'update')
  },
  component: SiteReportEditPage,
})

const protectedDestinationRoutes = PROTECTED_DESTINATIONS.filter(
  ({ path }) =>
    path !== '/dashboard/my-profile' &&
    path !== '/operations' &&
    path !== '/works/projects' &&
    path !== '/works/projects/$projectId' &&
    path !== '/works/worksite' &&
    path !== '/works/tasks' &&
    path !== '/works/engineering-site-reports' &&
    path !== '/works/survey-site-reports' &&
    path !== '/works/contracts' &&
    path !== '/hr/meetings' &&
    path !== '/dashboard/role' &&
    path !== '/notifications' &&
    path !== '/company' &&
    path !== '/company/branch' &&
    path !== '/company/department' &&
    path !== '/company/org-chart' &&
    path !== '/company/kpi-management' &&
    path !== '/company/roles' &&
    path !== '/company/roles/$roleId' &&
    path !== '/hr/employees' &&
    path !== '/hr/employees/$userId' &&
    path !== '/hr/job-post' &&
    path !== '/hr/leave-request' &&
    path !== '/hr/work-report' &&
    path !== '/hr/benefits' &&
    path !== '/hr/performance-review' &&
    path !== '/hr/awards-recognition' &&
    path !== '/hr/performance-leaderboard' &&
    path !== '/hr/monthly-scorecard' &&
    path !== '/hr/employee-evaluation' &&
    path !== '/hr/performance-engine' &&
    path !== '/hr/disciplinary-process' &&
    path !== '/hr/training-program' &&
    path !== '/hr/loans' &&
    path !== '/company/okr-board' &&
    path !== '/company/assets' &&
    path !== '/company/knowledge-base' &&
    path !== '/company/board' &&
    path !== '/company/compliance' &&
    path !== '/company/broadcast' &&
    path !== '/company/approval-workflow' &&
    path !== '/company/approval-requests' &&
    path !== '/company/audit-log' &&
    path !== '/dashboard/my-tasks' &&
    path !== '/dashboard/my-loans' &&
    path !== '/dashboard/my-pay' &&
    path !== '/dashboard/my-reports' &&
    path !== '/dashboard/my-target-reports' &&
    path !== '/hr/attendance' &&
    path !== '/hr/leaves' &&
    path !== '/employee/attendance',
).map(
  (destination) =>
    createRoute({
      getParentRoute: () => protectedLayoutRoute,
      path: destination.path,
      beforeLoad: async ({ context, location }) => {
        await requireProtectedDestination(context, location, destination)
      },
      component: () => {
        if (destination.path === '/dashboard') return <WorkspaceOverviewPage />
        if (destination.path === '/company/overview') return <CompanyOverviewPage />
        if (destination.path === '/hr') return <HRDashboardPage />
        return <ComingSoonPage destination={destination} />
      },
    }) as AnyRoute,
)

const routeTree = rootRoute.addChildren([
  indexRoute,
  splashRoute,
  loginRoute,
  forgotPasswordRoute,
  resetPasswordRoute,
  biometricRoute,
  twoFactorRoute,
  staffPrivacyRoute,
  protectedLayoutRoute.addChildren([
    noAccessRoute,
    myTasksRoute,
    myLoansRoute,
    myPayRoute,
    myProfileRoute,
    myRoleRoute,
    notificationsRoute,
    notificationDetailRoute,
    broadcastRoute,
    approvalWorkflowsRoute,
    companyProfileRoute,
    branchDirectoryRoute,
    departmentsUnitsRoute,
    orgChartRoute,
    kpiManagementRoute,
    rolesRoute,
    roleDetailRoute,
    employeesRoute,
    employeeProfileRoute,
    recruitmentRoute,
    hrLeaveRequestsRoute,
    hrWorkReportsRoute,
    hrBenefitsRoute,
    performanceReviewsRoute,
    awardsRecognitionRoute,
    performanceLeaderboardRoute,
    monthlyScorecardRoute,
    employeeEvaluationRoute,
    performanceEngineRoute,
    disciplinaryProcessRoute,
    trainingProgramsRoute,
    loansRoute,
    okrBoardRoute,
    assetsRoute,
    knowledgeBaseRoute,
    boardRoute,
    boardRecordDetailRoute,
    complianceRoute,
    complianceRecordDetailRoute,
    branchDetailRoute,
    approvalRequestsRoute,
    auditLogRoute,
    myWorkReportsRoute,
    myTargetsRoute,
    attendanceRoute,
    attendanceFaceRegistrationRoute,
    attendanceWorkLocationRegistrationRoute,
    myLeavesRoute,
    operationsRoute,
    projectsRoute,
    projectDetailRoute,
    worksitesRoute,
    worksiteDetailRoute,
    operationsTasksRoute,
    operationsTaskDetailRoute,
    engineeringSiteReportsRoute,
    surveySiteReportsRoute,
    contractsRoute,
    meetingsRoute,
    engineeringSiteReportDetailRoute,
    engineeringSiteReportCreateRoute,
    engineeringSiteReportEditRoute,
    leaveRequestDetailRoute,
    employeeAttendanceAliasRoute,
    workReportCreateRoute,
    siteReportCreateRoute,
    workReportDetailRoute,
    workReportEditRoute,
    personalSiteReportDetailRoute,
    personalSiteReportEditRoute,
    ...protectedDestinationRoutes,
    protectedNotFoundRoute,
  ]),
  ...(import.meta.env.DEV ? [foundationPreviewRoute] : []),
])

export const router = createRouter({
  routeTree,
  context: { queryClient },
  defaultPreload: 'intent',
  scrollRestoration: true,
})

export async function protectByPermission(
  context: AppRouterContext,
  location: { pathname: string; searchStr: string; hash: string },
  resource: string,
  action: string,
) {
  await requirePermission(context, location, resource, action)
}

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}
