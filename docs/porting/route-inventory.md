# Bomach OS Sidebar and Route Inventory

## What this inventory represents

This is the configured navigation inventory from the current local Flutter checkout, grouped by the actual sidebar headers in `lib/src/app_routes/menu_structure.dart`. Each menu route was matched to the widget registered for it in `lib/src/app_routes/app_router.dart`. It is a source-based inventory, not a claim that every account sees every item.

The sidebar filters menu entries by the signed-in user’s permissions. After scrolling the Edge test deployment’s sidebar, I observed all six headers and these parent entries: Dashboard and Company under Workspace; HR/Admin under People; Operations, Services, and Events under Operations; Marketing & Sales, CRM, and Finance & Accounting under Revenue; Analytics & Insights under Insights; Legal & Compliance and Security under Compliance. Child pages appear when a parent is expanded and are permission-filtered. The employee screen currently displays `401 — Token has expired`, so I did not treat its data state as valid or attempt to sign in again.

The local Flutter checkout contains uncommitted work and may not exactly match the deployed test build. Use this as the current source inventory; compare against the deployed build before treating it as a final route contract.

## Full Flutter route-registry coverage

The Company and HR port scope is not the full Flutter application. The current Flutter router has 196 dashboard route entries, split by runtime outcome as follows:

- 107 route entries render in-app Flutter widgets/pages when access is granted. Some paths are aliases or instances of the same screen, and some detail routes resolve through route-aware builders.
- 82 route entries render separately deployed Services, Marketing, or Finance content in an iframe or its Flutter host wrapper (17 Services, 37 Marketing, 28 Finance). Seven Marketing entries are hard-disabled in the permission service, so 75 of these iframe route entries can render when their access checks pass.
- 7 legacy Client Portal and CRM route entries redirect to CRM Clients before their mapped widgets are shown.
- 6 auth/bootstrap routes sit outside the dashboard shell: splash, login, forgot password, reset password, biometric, and two-factor verification.
- 3 parameterized detail route patterns are also registered for role, estate, and estate-performance details.

That is 205 registered route patterns when the dashboard entries, auth routes, and parameterized detail patterns are counted together. These are route entries, not 205 unique page designs. There are 124 sidebar destinations; the other 72 dashboard entries are detail, compatibility, legacy, or non-sidebar routes. Some are permission-specific, seven are hard-disabled, and seven are retired redirects. See [flutter-reachability-audit.md](flutter-reachability-audit.md) for the connection map, direct-link behavior, unregistered paths, and orphan-page findings. The page-by-page routes are listed below.

## Sidebar ownership summary

- Of the 124 configured sidebar destinations, 58 render Flutter page widgets and 66 render separately deployed app content inside the Flutter web shell.
- Embedded menu destinations: Services 17, Marketing 27, Finance 22.
- “Flutter page” means the route renders a Dart page/widget in the Bomach OS Flutter app. It can still call the shared backend.
- “Standalone app” means the Flutter route renders that separately deployed web app inside an iframe. The Flutter app still owns its sidebar route and iframe/auth wrapper.

Default standalone origins in `lib/src/constants/api_constants.dart` (build-time overrides are supported):

- Services: `https://services-mocha-xi.vercel.app` (`SERVICES_URL`).
- Marketing: `https://marketing-wine-alpha.vercel.app` (`MARKETING_URL`).
- Finance: `https://finance-six-murex.vercel.app` (`FINANCE_URL`).

The host route is shown first; for embedded pages, the child app route follows `→`.

## Workspace

### Dashboard

- **Overview** — `/dashboard`; Flutter page; Flutter widget: `DashboardScreen`.
- **Profile** — `/dashboard/my-profile`; Flutter page; Flutter widget: `MyProfilePage`.
- **Role** — `/dashboard/role`; Flutter page; Flutter widget: `RolePage`.
- **Tasks** — `/dashboard/my-tasks`; Flutter page; Flutter widget: `MyTasksPage`.
- **Work Reports** — `/dashboard/my-reports`; Flutter page; Flutter widget: `MyWorkReportsPage`.
- **Target** — `/dashboard/my-target-reports`; Flutter page; Flutter widget: `TargetReportsPage`.
- **My Loans** — `/dashboard/my-loans`; employee-owned loan submissions, pending edits, details, and status tracking. `/hr/loans` remains the cross-employee HR register; owner-only users arriving at that legacy URL are redirected here.
- **My Pay** — `/dashboard/my-pay`; read-only payslip history for the signed-in employee. `/hr/benefits` remains the HR payroll register (labeled Payroll); owner-only users arriving at that legacy URL are redirected here.

The React port of Tasks is implemented at `/dashboard/my-tasks`; see [my-tasks-implementation.md](my-tasks-implementation.md) for its URL state, permission contract, data lifecycle, and verification notes.

For the ownership boundary between employee-owned My Work views and the upcoming Operations port—including the Flutter personal site-report behavior—see [my-work-operations-scope.md](my-work-operations-scope.md).

The React port of personal Daily, Engineering, and Survey Reports is implemented as one permission-scoped register at `/dashboard/my-reports`; see [my-work-reports-implementation.md](my-work-reports-implementation.md) for its routes, create/detail flows, combined backend contract, access matrix, and data lifecycle. The register uses a dedicated authenticated aggregation endpoint rather than the broader `/reports/` feed. The HR/Admin `/hr/work-report` review queue and Operations registers remain separate workflows.

The employee-facing Targets route is implemented at `/dashboard/my-target-reports`; see [my-targets-implementation.md](my-targets-implementation.md) for the separate target and progress-history sections, permissions, API fields, and refresh lifecycle. KPI measures stay in their own workflows.

The employee-facing Profile and Role routes are implemented at `/dashboard/my-profile` and `/dashboard/role`; see [my-profile-role-implementation.md](my-profile-role-implementation.md) for their read-only data mapping, backend contracts, access rules, and freshness behavior.

The signed-in notification inbox and detail pages are implemented at `/notifications` and `/notifications/$notificationId`; see [notifications-implementation.md](notifications-implementation.md) for endpoint permissions, in-app arrival checks, safe related-item navigation, and data freshness. The inbox is reached from the shell bell and is not a sidebar destination. Web Push remains deferred.

### Company

- **Profile** — `/company`; Flutter page; Flutter widget: `CompanyProfilePage`; implemented in React as Company Profile with identity, branding, and supported operating defaults.
- **Branch** — `/company/branch`; Flutter page; Flutter widget: `BranchListPage`.
- **Board** — `/company/board`; Flutter page; Flutter widget: `BoardPage`; implemented in React with permissioned Meetings, Resolutions, Investors, Associates, and Partners sections. See [company-governance-implementation.md](company-governance-implementation.md).
- **Broadcast** — `/company/broadcast`; Flutter page; Flutter widget: `BroadcastPage`; implemented in React with permission-gated Announcements and Events, plus a shortcut to the canonical `/notifications` inbox. See [company-communication-implementation.md](company-communication-implementation.md).
- **Roles & Permissions** — `/company/roles`; Flutter page; Flutter widget: `RolesPage`; implemented in React with role permissions, branch scope, description, and durable role details for supported sections. The duplicate, unsupported role Authority Limits detail tab is omitted. See [hr-roles-employees-implementation.md](hr-roles-employees-implementation.md).
- **Org Chart** — `/company/org-chart`; Flutter page; Flutter widget: `OrgChartPage`; implemented in React as a read-only role-position chart with exact saved-scope separation and branch-limited reporting data. See [company-organization-implementation.md](company-organization-implementation.md).
- **KPI Management** — `/company/kpi-management`; Flutter page; Flutter widget: `KpiManagementPage`; implemented in React against role KPI and shared metric APIs. See [kpi-okr-implementation.md](kpi-okr-implementation.md).
- **OKR Board** — `/company/okr-board`; Flutter page; Flutter widget: `OkrBoardPage`; implemented in React as the same explicit unavailable-capability state because the backend lacks company/role OKR endpoints. See [kpi-okr-implementation.md](kpi-okr-implementation.md).
- **Compliance Dashboard** — `/company/compliance`; Flutter page; Flutter widget: `ComplianceDashboardPage`; implemented in React as the backend-supported Compliance Register. No separate aggregate dashboard endpoint exists. See [company-governance-implementation.md](company-governance-implementation.md).
- **Knowledge Base** — `/company/knowledge-base`; Flutter page; Flutter widget: `CompanyKnowledgeBasePage`; implemented in React as an explicit unavailable-capability state because there is no company-wide backend API.
- **Approval Workflows** — `/company/approval-workflow`; Flutter page; Flutter widget: `ApprovalWorkflowPage`; implemented in React with workflow configuration and the approval-request review tab. See [company-communication-implementation.md](company-communication-implementation.md).
- **Workspace Approvals** — `/company/workspace-approvals`; Flutter page; Flutter widget: `WorkspaceApprovalsPage`.
- **Departments & Units** — `/company/department`; Flutter page; Flutter widget: `DepartmentsUnitsPage`; implemented in React with permissioned department and unit tabs, URL-backed filters, and compact create/edit dialogs. See [company-organization-implementation.md](company-organization-implementation.md).
- **Assets** — `/company/assets`; Flutter page; Flutter widget: `AssetsPage`; implemented in React against the Asset API, with branch-aware choices and register/detail/create/edit/delete flows. See [company-assets-knowledge-base-implementation.md](company-assets-knowledge-base-implementation.md).
- **Audit Log** — `/company/audit-log`; Flutter page; Flutter widget: `AuditLogPage`.
- **Approval Requests** — `/company/approval-requests`; React review destination under Governance & oversight, gated by `approval_requests:list`; approve/reject actions use their own permissions. It keeps Compliance Register and Approval Workflows separate.

## People

### HR/Admin

- **Employees** — `/hr/employees`; Flutter page; Flutter widget: `EmployeeDatabase`; implemented in React with active/past lists, four-step form, and durable employee profiles. See [hr-roles-employees-implementation.md](hr-roles-employees-implementation.md).
- **Attendance** — `/hr/attendance`; Flutter page; Flutter widget: `AttendancePage`.
- **Work Calendar** — `/hr/attendance-calendar`; Flutter page; Flutter widget: `AttendanceCalendarPage`.
- **Recruitment** — `/hr/job-post`; Flutter page; Flutter widget: `JobPostPage`.
- **My Leaves** — `/hr/leaves`; Flutter page; Flutter widget: `LeavesPage`.
- **Leave Requests** — `/hr/leave-request`; Flutter page; Flutter widget: `LeaveRequestPage`.
- **Training** — `/hr/training-program`; Flutter page; Flutter widget: `TrainingProgramPage`; implemented in React with program CRUD, details, supported filters, and URL-backed pagination. See [hr-training-loans-implementation.md](hr-training-loans-implementation.md).
- **Loans** — `/hr/loans`; Flutter page; Flutter widget: `LoanPage`; implemented in React as the cross-employee HR register with pending edits, independent approval/rejection, and decision history. Employee submissions and owner-scoped details are at `/dashboard/my-loans`. See [hr-training-loans-implementation.md](hr-training-loans-implementation.md).
- **Payroll** — `/hr/benefits`; Flutter page; Flutter widget: `BenefitsPage`; React navigation labels the read-only payroll register Payroll. Employee payslip history is at `/dashboard/my-pay`. See [hr-benefits-performance-work-reports-implementation.md](hr-benefits-performance-work-reports-implementation.md).
- **Performance** — `/hr/performance-review`; Flutter page; Flutter widget: `PerformanceReviewPage`.
- **Work Reports** — `/hr/work-report`; Flutter page; Flutter widget: `WorkReportPage`.
- **Monthly Scorecard** — `/hr/monthly-scorecard`; Flutter source page is under HR/Admin; React implements it as the signed-in employee's read-only, period-filtered scorecard under My Work (navigation label **My Scorecard**), and viewing never generates data. The route remains unchanged. See [hr-performance-analytics-implementation.md](hr-performance-analytics-implementation.md).
- **Awards & Recognition** — `/hr/awards-recognition`; Flutter page; Flutter widget: `AwardsRecognitionPage`; implemented in React against award record CRUD. Awards are not linked to employees in the backend model. See [hr-recognition-employee-relations-implementation.md](hr-recognition-employee-relations-implementation.md).
- **Performance Leaderboard** — `/hr/performance-leaderboard`; Flutter page; Flutter widget: `PerformanceLeaderboardPage`; implemented in React against the top-ten monthly scorecard endpoint. See [hr-recognition-employee-relations-implementation.md](hr-recognition-employee-relations-implementation.md).
- **Employee Evaluation** — `/hr/employee-evaluation`; Flutter page; Flutter widget: `EmployeeEvaluationPage`; implemented in React with employee selection, authenticated evaluator identity, scoped create/update, and recommendation flags. The Flutter PDF control is omitted because both it and the API are nonfunctional for export. See [hr-performance-analytics-implementation.md](hr-performance-analytics-implementation.md).
- **Disciplinary Process** — `/hr/disciplinary-process`; Flutter page; Flutter widget: `DisciplinaryProcessPage`; implemented in React against permission-scoped disciplinary case CRUD. See [hr-recognition-employee-relations-implementation.md](hr-recognition-employee-relations-implementation.md).
- **Performance Engine** — `/hr/performance-engine`; Flutter page; Flutter widget: `PerformanceEnginePage`; implemented in React as an honest roadmap page. The Flutter source marks it unavailable and Django has no performance-engine API, so the page does not fabricate live capabilities. See [hr-performance-analytics-implementation.md](hr-performance-analytics-implementation.md).

The employee Attendance and My Leaves pages are implemented at `/hr/attendance` and `/hr/leaves`; leave records have durable detail URLs at `/hr/leaves/$requestId`. `/employee/attendance` is kept as an explicit compatibility redirect to the canonical Attendance route. Their filters and pagination are validated route search state, so changing them stays on the implemented page. See [my-attendance-implementation.md](my-attendance-implementation.md) and [my-leaves-implementation.md](my-leaves-implementation.md) for permissions, API contracts, actions, and freshness.

## Operations

### Operations

- **Operations** — `/operations`; Flutter page; Flutter widget: `OperationsPage`.
- **Projects** — `/works/projects`; Flutter page; Flutter widget: `ProjectsPage`.
- **Worksite** — `/works/worksite`; Flutter page; Flutter widget: `WorkSite`.
- **Tasks** — `/works/tasks`; Flutter page; Flutter widget: `TaskPage`.
- **Engineering Site Reports** — `/works/engineering-site-reports`; Flutter page; Flutter widget: `EngineeringSiteReportsPage`.
- **Survey Site Reports** — `/works/survey-site-reports`; Flutter page; Flutter widget: `SurveySiteReportsPage`.
- **Contracts** — `/works/contracts`; Flutter page; Flutter widget: `ContractPage`.
- **Meetings** — `/hr/meetings`; Flutter page; Flutter widget: `Meetings`.

The React port registers these eight destinations under a separate Operations sidebar section and group. `/operations` now shows permission-aware project and delivery metrics, while `/works/projects` is a searchable, filterable, paginated register with create/edit, archive/restore, and confirmed permanent deletion. Opening a project uses the nested `/works/projects/:projectId` workspace, with URL-backed Overview, Members, Work site, Files, Milestones, Tasks, Associates, and Meetings tabs. Other Operations destinations remain Coming Soon until ported individually. See [projects-implementation.md](projects-implementation.md) for the register interactions, review flow, route permissions, query invalidation, and verification notes.

### Services

- **Command center** — `/services/dashboard` → `/app/dashboard`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.
- **Service catalogue** — `/services/service-catalogue` → `/app/service-catalogue`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.
- **Calculator library** — `/services/calculator-library` → `/app/calculator-library`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.
- **Request form builder** — `/services/request-form-builder` → `/app/request-form-builder`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.
- **Workflow designer** — `/services/workflow-designer` → `/app/workflow-designer`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.
- **Branch activation** — `/services/branch-activation` → `/app/branch-activation`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.
- **Service requests** — `/services/service-requests` → `/app/service-requests`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.
- **Quotations** — `/services/quotations` → `/app/quotations`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.
- **Invoices & payments** — `/services/invoices-payments` → `/app/invoices-payments`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.
- **Approvals** — `/services/approvals` → `/app/approvals`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.
- **Service orders** — `/services/service-orders` → `/app/service-orders`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.
- **Execution tasks** — `/services/execution-tasks` → `/app/execution-tasks`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.
- **Deliverables** — `/services/deliverables` → `/app/deliverables`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.
- **Real estate inventory** — `/services/real-estate-inventory` → `/app/real-estate-inventory`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.
- **Survey / engineering / others** — `/services/survey-engineering-others` → `/app/survey-engineering-others`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.
- **Feedback and quality** — `/services/feedback-quality` → `/app/feedback-quality`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.
- **Reports and analytics** — `/services/reports-analytics` → `/app/reports-analytics`; Services standalone app; Flutter host: `ServicesWebView`; page content is in the standalone Services app.

- **Events** — `/events`; Flutter page; Flutter widget: `EventsPage`.

## Revenue

### Marketing & Sales

- **Lead 360 journal** — `/marketing/lead-journal` → `/lead-journal`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Revenue command** — `/marketing/revenue-command` → `/revenue-command`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Daily execution** — `/marketing/daily-execution` → `/daily-execution`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **13-week turnaround** — `/marketing/turnaround` → `/turnaround`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Command centre** — `/marketing/dashboard` → `/dashboard`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **OKRs & targets** — `/marketing/okrs` → `/okrs`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Lead control tower** — `/marketing/lead-control` → `/lead-control`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Forecast & coverage** — `/marketing/forecast` → `/forecast`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **CRM Pipeline** — `/marketing/pipeline` → `/pipeline`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Campaigns** — `/marketing/campaigns` → `/campaigns`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Content calendar** — `/marketing/calendar` → `/calendar`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Media library** — `/marketing/media` → `/media`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Partners & media** — `/marketing/partners` → `/partners`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Analytics** — `/marketing/analytics` → `/analytics`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Support** — `/marketing/support` → `/support`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Team directory** — `/marketing/team` → `/team-directory`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **New lead** — `/marketing/new-lead` → `/new-lead`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Sales playbooks** — `/marketing/playbooks` → `/playbooks`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Coaching** — `/marketing/coaching` → `/coaching`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Content revenue studio** — `/marketing/content-studio` → `/content-studio`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Email marketing** — `/marketing/email-center` → `/email-center`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Traditional media register** — `/marketing/media-register` → `/media-register`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Sales handoffs** — `/marketing/handoff` → `/handoff`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **External realtors** — `/marketing/realtor-portal` → `/realtor-portal`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Partner work portal** — `/marketing/partner-portal` → `/partner-portal`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Approval center** — `/marketing/approvals` → `/approvals`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- **Marketing meetings** — `/marketing/marketing-meetings` → `/marketing-meetings`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.

### CRM

- **Client Relationship Management** — `/crm/clients`; Flutter page; Flutter widget: `CrmClientsPage`.

### Finance & Accounting

- **Command centre** — `/finance/dashboard` → `/dashboard`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Cash flow forecast** — `/finance/cashflow` → `/cashflow`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Approvals queue** — `/finance/approvals` → `/approvals`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Financial statements** — `/finance/reports` → `/reports`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Order profitability** — `/finance/serviceorders` → `/serviceorders`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Invoices & billing** — `/finance/invoices` → `/invoices`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Payment submissions** — `/finance/payments` → `/payments`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Receivables & aging** — `/finance/receivables` → `/receivables`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Project wallets** — `/finance/wallets` → `/wallets`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Estate invoices** — `/finance/estatefinance` → `/estatefinance`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Cashbook & balances** — `/finance/cashbook` → `/cashbook`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Expense vouchers** — `/finance/expenses` → `/expenses`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Vendors & bills** — `/finance/vendors` → `/vendors`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Petty cash** — `/finance/pettycash` → `/pettycash`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Payroll runs** — `/finance/payroll` → `/payroll`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Commissions & awards** — `/finance/commissions` → `/commissions`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Tax & statutory** — `/finance/tax` → `/tax`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Journal entries** — `/finance/journals` → `/journals`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Chart of accounts & GL** — `/finance/coa` → `/coa`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Fixed assets** — `/finance/assets` → `/assets`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Audit & exceptions** — `/finance/audit` → `/audit`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- **Finance settings** — `/finance/settings` → `/settings`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.

## Insights

### Analytics & Insights

- **Overview** — `/analytics`; Flutter page; Flutter widget: `AnalyticsOverviewPage`.

## Compliance

### Legal & Compliance

- **Contracts** — `/legal/contracts`; Flutter page; Flutter widget: `LegalsPage`.
- **Compliance** — `/Compliance`; Flutter page; Flutter widget: `LegalsPage`.
- **Cases** — `/legal/Cases`; Flutter page; Flutter widget: `LegalsPage`.
- **Audits** — `/legal/Audits`; Flutter page; Flutter widget: `LegalsPage`.

### Security

- **Overview** — `/security/overview`; Flutter page; Flutter widget: `SecurityPage`.
- **Codes & Permissions** — `/security/codes`; Flutter page; Flutter widget: `SecurityPage`.
- **Workflows** — `/security/workflows`; Flutter page; Flutter widget: `ApprovalWorkflowPage`.
- **Alerts** — `/security/alerts`; Flutter page; Flutter widget: `SecurityPage`.
- **Audit Logs** — `/security/logs`; Flutter page; Flutter widget: `AuditLogPage`.

## Registered routes not linked as sidebar destinations

The router also contains detail, legacy, landing, and compatibility routes. These are not additional sidebar items. Seven route keys are explicitly redirected to CRM Clients. Three parameterized URL forms are added by route construction for role and estate details.

### Dashboard / HR / employee

- `hr` — `/hr`; Flutter page; Flutter widget: `HRPage`.
- `employeeProfile` — `/hr/employees/profile`; Flutter page; Flutter widget: `EmployeeProfile`.
- `employee` — `/employee`; Flutter page; Flutter widget: `EmployeePage`.
- `employeeDirectory` — `/employee/directory`; Flutter page; Flutter widget: `EmployeeDirectoryPage`.
- `employeePerformance` — `/employee/performance`; Flutter page; Flutter widget: `EmployeePerformancePage`.
- `employeeAttendance` — `/employee/attendance`; Flutter page; Flutter widget: `EmployeeAttendancePage`.
- `employeeTraining` — `/employee/training`; Flutter page; Flutter widget: `EmployeeTrainingPage`.
- `associates` — `/hr/associates`; Flutter page; Flutter widget: `AssociatesPage`.

### Company

- `roleDetail` — `/company/roles/detail`; Flutter page; Flutter route builder: `RoleDetailPage` when an integer is supplied in `state.extra`; otherwise `RoleDetailUnavailable`. Durable ID links use `/company/roles/:roleId`.
- `enugu` — `/company/enugu`; Flutter page; Flutter widget: `BranchPage`.

### Operations / work

- `eachProjects` — `/works/projects/detail`; Flutter page; Flutter widget: `EachProjects`.
- `operationsProjectDetail` — `/operations/projects/detail`; Flutter page; Flutter widget: `ProjectDetailPage`.
- `operationsTaskDetail` — `/operations/task/detail`; Flutter page; Flutter widget: `TaskDetail`.
- `operationsWorksiteDetail` — `/operations/worksite/detail`; Flutter page; Flutter widget: `WorksiteDetailPage`.
- `operationsContractDetail` — `/operations/contract/detail`; Flutter page; Flutter widget: `ContractDetailPage`.
- `operationsTimelineDetail` — `/operations/timeline/detail`; Flutter page; Flutter widget: `TimelineDetailPage`.

The React port implements project details at `/works/projects/:projectId`; the eight project tabs remain inside that route and do not create sidebar entries. The older `/works/projects/detail` and `/operations/projects/detail` aliases, plus task/worksite/contract/timeline detail routes, remain protected non-sidebar placeholders.

### Services

- `realEstate` — `/services/real-estate`; Flutter page; Flutter widget: `RealEstateScreen`.
- `serviceOrder` — `/services/service-order`; Flutter page; Flutter widget: `ServiceOrder`.
- `landSurvey` — `/services/land-survey`; Flutter page; Flutter widget: `LandSurveyScreen`.
- `realEstateDetail` — `/services/real-estate/detail`; Flutter page; Flutter widget: `RealEstateDetailScreen`.
- `landSurveyDetail` — `/services/land-survey/detail`; Flutter page; Flutter widget: `LandSurveyDetailScreen`.
- `taskDetail` — `/services/task/detail`; Flutter page; Flutter widget: `TaskDetail`.
- `servicesProperty` — `/services-property`; Flutter page; Flutter widget: `ServicesPropertyPage`.
- `serviceDetail` — `/services/detail`; Flutter page; Flutter widget: `ServiceDetailScreen`.
- `services` — `/services`; Flutter page; Flutter widget: `ServicesPage`.
- `landSurveyCalculator` — `/services/land-survey-calculator`; Flutter page; Flutter widget: `LandSurveyCalculatorPage`.
- `servicesCalculator` — `/services/services-calculator`; Flutter page; Flutter widget: `ServicesCalculatorPage`.
- `propertyList` — `/services/property`; Flutter page; Flutter widget: `PropertyListPage`.
- `propertyDetail` — `/services/property/detail`; Flutter page; Flutter widget: `PropertyDetailPage`.
- `estateManagement` — `/services/estate-management`; Flutter page; Flutter widget: `EstateManagementPage`.
- `estateDetail` — `/services/estate/detail`; Flutter page; Flutter route builder: `EstateDetailPage` when an `Estate` is supplied in `state.extra`; otherwise `EstateDetailUnavailable`. Durable ID links use `/services/estate/:estateId`.
- `estatePerformance` — `/services/estate-performance`; Flutter page; Flutter widget: `EstatePerformancePage`.
- `paymentApproval` — `/services/payment-approval`; Flutter page; Flutter widget: `PaymentApprovalPage`.
- `serviceClients` — `/services/clients`; Flutter page; Flutter widget: `ClientListPage`.
- `serviceClientUpload` — `/services/clients/upload`; Flutter page; Flutter widget: `LandDocumentUploadPage`.
- `generateInvoice` — `/services/generate-invoice`; Flutter page; Flutter widget: `GenerateInvoicePage`.
- `serviceLeads` — `/services/leads`; Flutter page; Flutter widget: `ServiceLeadsPage`.
- `serviceInvoices` — `/services/invoices`; Flutter page; Flutter widget: `ServiceInvoicesPage`.

### Finance

- `finance` — `/finance` → `/dashboard`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- `invoice` — `/finance/invoice` → `/invoices`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- `payment` — `/finance/payment` → `/payments`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- `expense` — `/finance/expense` → `/expenses`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- `contractPayment` — `/finance/contract-payment` → `/payments`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.
- `budget` — `/finance/budget` → `/cashflow`; Finance standalone app; Flutter host: `FinanceWebView`; page content is in the standalone Finance app.

### Marketing

- `marketing` — `/marketing`; Marketing standalone app (Flutter wrapper); Flutter wrapper: `MarketingPage`; it hosts the standalone Marketing app.
- `marketingReports` — `/marketing/reports` → `/audit-log`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- `marketingFunnelAudit` — `/marketing/funnel-audit` → `/funnel-audit`; Marketing standalone app; current runtime status: blocked by `PermissionService._disabledMarketingRoutes`; the guard redirects before rendering.
- `marketingRetention` — `/marketing/retention` → `/retention`; Marketing standalone app; current runtime status: blocked by `PermissionService._disabledMarketingRoutes`; the guard redirects before rendering.
- `marketingWorkdesk` — `/marketing/workdesk` → `/workdesk`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- `marketingIntegrations` — `/marketing/integrations` → `/integrations`; Marketing standalone app; Flutter host: `MarketingWebView`; page content is in the standalone Marketing app.
- `marketingRoleGovernance` — `/marketing/role-governance` → `/role-governance`; Marketing standalone app; current runtime status: blocked by `PermissionService._disabledMarketingRoutes`; the guard redirects before rendering.
- `marketingAuditLog` — `/marketing/audit-log` → `/audit-log`; Marketing standalone app; current runtime status: blocked by `PermissionService._disabledMarketingRoutes`; the guard redirects before rendering.
- `marketingCompliance` — `/marketing/compliance` → `/compliance`; Marketing standalone app; current runtime status: blocked by `PermissionService._disabledMarketingRoutes`; the guard redirects before rendering.
- `marketingDesign` — `/marketing/design` → `/design`; Marketing standalone app; current runtime status: blocked by `PermissionService._disabledMarketingRoutes`; the guard redirects before rendering.
- `marketingWhatsapp` — `/marketing/whatsapp` → `/whatsapp`; Marketing standalone app; current runtime status: blocked by `PermissionService._disabledMarketingRoutes`; the guard redirects before rendering.
- `marketingLeadDetail` — `/marketing/lead/detail`; Flutter page; Flutter widget: `LeadDetailPage`.
- `marketingCampaignDetail` — `/marketing/campaign/detail`; Flutter page; Flutter widget: `CampaignDetailPage`.
- `marketingSiteDetail` — `/marketing/site/detail`; Flutter page; Flutter widget: `SiteDetailPage`.
- `marketingCrm` — `/marketing-crm`; Flutter page; Flutter widget: `MarketingCrmDashboard`.

### Workspace / analytics

- `workspace` — `/workspace`; Flutter page; Flutter widget: `WorkspacePage`.
- `workspaceDashboard` — `/workspace-dashboard`; Flutter page; Flutter widget: `WorkspaceDashboardPage`.
- `analyticsRevenue` — `/analytics/revenue`; Flutter page; Flutter widget: `RevenueAnalyticsPage`.
- `analyticsProjects` — `/analytics/projects`; Flutter page; Flutter widget: `ProjectsAnalytics`.
- `analyticsPerformance` — `/analytics/performance`; Flutter page; Flutter widget: `PerformanceAnalytics`.
- `branchPerformanceAnalysis` — `/analytics/branch-performance`; Flutter page; Flutter widget: `BranchPerformanceAnalysisPage`.

### Client portal / CRM

- `clientAccess` — `/client/portal`; Retired route (redirects to CRM Clients); current runtime status: redirects to `/crm/clients` before this route’s mapped widget is built.
- `communications` — `/client/portal/communications`; Retired route (redirects to CRM Clients); current runtime status: redirects to `/crm/clients` before this route’s mapped widget is built.
- `portalAnalytics` — `/client/portal/analytics`; Retired route (redirects to CRM Clients); current runtime status: redirects to `/crm/clients` before this route’s mapped widget is built.
- `documentSharing` — `/client/portal/documents&sharing`; Retired route (redirects to CRM Clients); current runtime status: redirects to `/crm/clients` before this route’s mapped widget is built.
- `crmLeads` — `/crm/leads`; Retired route (redirects to CRM Clients); current runtime status: redirects to `/crm/clients` before this route’s mapped widget is built.
- `crmInteractions` — `/crm/interactions`; Retired route (redirects to CRM Clients); current runtime status: redirects to `/crm/clients` before this route’s mapped widget is built.
- `crmAnalytics` — `/crm/analytics`; Retired route (redirects to CRM Clients); current runtime status: redirects to `/crm/clients` before this route’s mapped widget is built.

### Additional shell routes

- `/splash`, `/login`, `/forgot-password`, `/reset-password`, `/biometric`, and `/two-factor-verify` are Flutter auth/bootstrap screens outside the dashboard route map.
- `/company/roles/:roleId`, `/services/estate/:estateId`, and `/services/estate-performance/:estateId` are parameterized Flutter detail routes.
- The router marks Client Portal destinations (`/client/portal`, `/client/portal/communications`, `/client/portal/documents&sharing`, `/client/portal/analytics`) and CRM legacy routes (`/crm/leads`, `/crm/interactions`, `/crm/analytics`) as redirects to `/crm/clients`.
- The old `/marketing` entry is a Flutter wrapper around the standalone Marketing iframe. The `/services` root is a Flutter-owned legacy Services Dashboard; neither is one of the current sidebar child destinations.

## Port scope reading

- **Confirmed Flutter source inventory:** all six Workspace/Dashboard, 15 Company, and 17 HR/Admin destinations (38 source sidebar destinations). React intentionally reorganizes them: Attendance and My Leaves are under My Work, Roles & Permissions is under HR/Admin, and `/hr` is surfaced as the HR dashboard.
- **React implementation status:** the route manifest has 49 sidebar destinations and 18 direct/detail routes. Implemented pages include `/dashboard`, `/dashboard/my-reports`, `/operations`, `/works/projects`, `/works/projects/:projectId`, `/company`, `/company/overview`, `/company/approval-requests`, `/company/approval-workflow`, `/company/broadcast`, `/company/branch`, `/company/branch/:branchId`, and `/hr`; remaining destinations use the shared permission-guarded Coming Soon page. My Work Reports combines accessible Daily, Engineering, and Survey history; its type-specific site creation and personal actions do not replace the Operations review registers.
- **React-only routes:** `/company/overview` consolidates company health metrics; `/company/approval-requests` provides a dedicated approval-request review experience, also available as a tab in Approval Workflows; and `/company/branch/:branchId` is a shareable branch detail route. `/company` is the focused company profile/settings page.
- Dashboard metric ownership, summary API contracts, permission rules, branch-scope limits, and dashboard verification are recorded in [dashboard-implementation.md](dashboard-implementation.md).
- **Direct/detail routes:** the 12 existing routes are `/hr/employees/profile`, `/hr/associates`, `/employee`, `/employee/directory`, `/employee/performance`, `/employee/attendance`, `/employee/training`, `/company/enugu`, `/company/roles/detail`, `/company/roles/:roleId`, `/workspace`, and `/workspace-dashboard`; the six newly scaffolded Operations details are listed above (18 unique entries total). The source's legacy `/company/roles/detail` route requires in-memory `state.extra` and otherwise renders an unavailable state; durable role links use the ID route.
- **Outside the current port scope:** remaining Operations registers (Worksite, operational Tasks, review reports, Contracts, and Meetings) remain queued for their own page-by-page ports; Events, CRM Clients, Analytics, Legal & Compliance, Security, and the legacy Flutter Services pages remain outside this slice.
- **Stay as separate applications:** Services is composed under the shared Bomach host at `/services` through an external rewrite; its codebase and page content remain independent. Marketing and Finance remain hidden until their test origins and shared-auth readiness are verified.
- The Company menu’s `Assets` destination is rendered by `AssetsPage` from the Flutter HR source folder, but ownership in this inventory follows its actual Company sidebar group and `/company/assets` route.

## Source files checked

- `../../bomach_os/lib/src/app_routes/menu_structure.dart`
- `../../bomach_os/lib/src/app_routes/app_route_constants.dart`
- `../../bomach_os/lib/src/app_routes/app_router.dart`
- `../../bomach_os/lib/src/constants/api_constants.dart`
- Live test shell: `https://bomach-os-test.web.app/#/hr/employees` (read-only navigation inspection; no login or form submission).
