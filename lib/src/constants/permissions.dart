import '../app_routes/app_route_constants.dart';

/// A single backend permission identity: `resource:action`.
///
/// Prefer the constants on [Perms] for compile-time safety. Route guards
/// and UI gates accept a list of these with OR semantics — user is granted
/// access if they satisfy ANY permission in the list.
class Permission {
  final String resource;
  final String action;

  const Permission(this.resource, this.action);

  @override
  String toString() => '$resource:$action';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Permission &&
          other.resource == resource &&
          other.action == action);

  @override
  int get hashCode => Object.hash(resource, action);
}

/// Backward-compatible string constants for resources + actions.
/// Kept because callers throughout the codebase reference them by name;
/// new code should prefer [Perms.*] typed constants instead.
class PermissionConstants {
  // Resources
  static const String resEmployees = 'employees';
  static const String resEmployeeDocuments = 'employee_documents';
  static const String resEmployeeReviews = 'employee_reviews';
  static const String resDepartments = 'departments';
  static const String resDepartmentUnits = 'department_units';
  static const String resRoles = 'roles';
  static const String resBranches = 'branches';
  static const String resCompanySettings = 'company_settings';
  static const String resLeads = 'leads';
  static const String resClients = 'clients';
  static const String resEstates = 'estates';
  static const String resProperties = 'properties';
  static const String resEstateInvoices = 'estate_invoices';
  static const String resCart = 'cart';
  static const String resPartners = 'partners';
  static const String resPartnerAgreements = 'partner_agreements';
  static const String resLegalCases = 'legal_cases';
  static const String resComplianceRecords = 'compliance_records';
  static const String resComplianceAudits = 'compliance_audits';
  static const String resAuditLogs = 'audit_logs';
  static const String resAnnouncements = 'announcements';
  static const String resBoardResolutions = 'board_resolutions';
  static const String resShareholders = 'shareholders';
  static const String resMeetings = 'meetings';
  static const String resPolicies = 'policies';
  static const String resEvents = 'events';
  static const String resLoans = 'loans';
  static const String resApprovalFlows = 'approval_flows';
  static const String resApprovalRequests = 'approval_requests';
  static const String resDrawings = 'drawings';
  static const String resWallet = 'wallet';
  static const String resClientInventory = 'client_inventory';
  static const String resDashboard = 'dashboard';
  static const String resStats = 'stats';
  static const String resProjects = 'projects';
  static const String resTasks = 'tasks';
  static const String resWorksites = 'worksites';
  static const String resContracts = 'contracts';
  static const String resTimelines = 'timelines';
  static const String resMilestones = 'milestones';
  static const String resSiteEquipment = 'site_equipment';
  static const String resBudgets = 'budgets';
  static const String resCategories = 'categories';
  static const String resContent = 'content';
  static const String resDocuments = 'documents';
  static const String resExpenses = 'expenses';
  static const String resServiceInvoices = 'service_invoices';
  static const String resServiceLeads = 'service_leads';
  static const String resMarketingCampaigns = 'marketing_campaigns';
  static const String resOrders = 'orders';
  static const String resPayments = 'payments';
  static const String resQuotes = 'quotes';
  static const String resServices = 'services';
  static const String resJobPostings = 'job_postings';
  static const String resApplicants = 'applicants';
  static const String resInterviews = 'interviews';
  static const String resOfferLetters = 'offer_letters';
  static const String resLeaveRequests = 'leave_requests';
  static const String resPayroll = 'payroll';
  static const String resPerformanceReviews = 'performance_reviews';
  static const String resTrainingPrograms = 'training_programs';
  static const String resAssets = 'assets';
  static const String resAwards = 'awards';
  static const String resWorkReports = 'work_reports';
  static const String resDisciplinaryCases = 'disciplinary_cases';
  static const String resMonthlyScorecards = 'monthly_scorecards';
  static const String resEmployeeEvaluations = 'employee_evaluations';
  static const String resKpis = 'kpis';
  static const String resWorkLocations = 'work_locations';
  static const String resWorkLocationApprovals = 'work_location_approvals';

  // Actions
  static const String actCreate = 'create';
  static const String actView = 'view';
  static const String actViewOwn = 'view_own';
  static const String actList = 'list';
  static const String actListOwn = 'list_own';
  static const String actUpdate = 'update';
  static const String actUpdateOwn = 'update_own';
  static const String actDelete = 'delete';
  static const String actDeleteOwn = 'delete_own';
  static const String actExit = 'exit';
  static const String actUpload = 'upload';
  static const String actUploadOwn = 'upload_own';
  static const String actSetBusinessHours = 'set_business_hours';
  static const String actConvertToClient = 'convert_to_client';
  static const String actSubmitForApproval = 'submit_for_approval';
  static const String actApprove = 'approve';
  static const String actReject = 'reject';
  static const String actRecordPayment = 'record_payment';
  static const String actAddItem = 'add_item';
  static const String actRemoveItem = 'remove_item';
  static const String actClear = 'clear';
  static const String actUpdateStatus = 'update_status';
  static const String actUpdateScore = 'update_score';
  static const String actCancel = 'cancel';
  static const String actDownload = 'download';
  static const String actFund = 'fund';
  static const String actProcessBatch = 'process_batch';
  static const String actMakePayment = 'make_payment';
  static const String actAuthorize = 'authorize';
  static const String actSubmitFeedback = 'submit_feedback';

  // Combined permission strings for convenience
  static String perm(String resource, String action) => '$resource:$action';
}

/// Typed, compile-time-safe permission constants grouped by resource.
/// Every entry is a [Permission] instance — pass them directly to
/// `PermissionService.has()`, `PermissionGate`, or `routeRequirements`.
///
/// Only the actions actually used in the UI are listed — add more as needed.
class Perms {
  // Employees
  static const employeesCreate = Permission('employees', 'create');
  static const employeesView = Permission('employees', 'view');
  static const employeesViewOwn = Permission('employees', 'view_own');
  static const employeesList = Permission('employees', 'list');
  static const employeesUpdate = Permission('employees', 'update');
  static const employeesUpdateOwn = Permission('employees', 'update_own');
  static const employeesExit = Permission('employees', 'exit');

  // Departments
  static const departmentsCreate = Permission('departments', 'create');
  static const departmentsList = Permission('departments', 'list');
  static const departmentsUpdate = Permission('departments', 'update');

  // Roles
  static const rolesCreate = Permission('roles', 'create');
  static const rolesView = Permission('roles', 'view');
  static const rolesViewOwn = Permission('roles', 'view_own');
  static const rolesList = Permission('roles', 'list');
  static const rolesUpdate = Permission('roles', 'update');
  static const rolesDelete = Permission('roles', 'delete');

  // Branches
  static const branchesCreate = Permission('branches', 'create');
  static const branchesView = Permission('branches', 'view');
  static const branchesList = Permission('branches', 'list');
  static const branchesUpdate = Permission('branches', 'update');

  // Company Settings
  static const companySettingsView = Permission('company_settings', 'view');
  static const companySettingsUpdate = Permission('company_settings', 'update');

  // Dashboard & Stats
  static const dashboardView = Permission('dashboard', 'view');
  static const statsView = Permission('stats', 'view');

  // Leads
  static const leadsCreate = Permission('leads', 'create');
  static const leadsList = Permission('leads', 'list');
  static const leadsUpdate = Permission('leads', 'update');
  static const leadsDelete = Permission('leads', 'delete');

  // Clients
  static const clientsCreate = Permission('clients', 'create');
  static const clientsView = Permission('clients', 'view');
  static const clientsList = Permission('clients', 'list');
  static const clientsUpdate = Permission('clients', 'update');

  // Estates
  static const estatesCreate = Permission('estates', 'create');
  static const estatesView = Permission('estates', 'view');
  static const estatesList = Permission('estates', 'list');
  static const estatesUpdate = Permission('estates', 'update');
  static const estatesDelete = Permission('estates', 'delete');

  // Properties
  static const propertiesCreate = Permission('properties', 'create');
  static const propertiesView = Permission('properties', 'view');
  static const propertiesList = Permission('properties', 'list');
  static const propertiesUpdate = Permission('properties', 'update');
  static const propertiesDelete = Permission('properties', 'delete');

  // Estate Invoices
  static const estateInvoicesCreate = Permission('estate_invoices', 'create');
  static const estateInvoicesList = Permission('estate_invoices', 'list');
  static const estateInvoicesListOwn =
      Permission('estate_invoices', 'list_own');
  static const estateInvoicesUpdate = Permission('estate_invoices', 'update');
  static const estateInvoicesDelete = Permission('estate_invoices', 'delete');
  static const estateInvoicesApprove = Permission('estate_invoices', 'approve');
  static const estateInvoicesReject = Permission('estate_invoices', 'reject');

  // Announcements
  static const announcementsCreate = Permission('announcements', 'create');
  static const announcementsList = Permission('announcements', 'list');
  static const announcementsUpdate = Permission('announcements', 'update');
  static const announcementsDelete = Permission('announcements', 'delete');

  // Board Resolutions
  static const boardResolutionsCreate =
      Permission('board_resolutions', 'create');
  static const boardResolutionsList = Permission('board_resolutions', 'list');
  static const boardResolutionsUpdate =
      Permission('board_resolutions', 'update');
  static const boardResolutionsDelete =
      Permission('board_resolutions', 'delete');

  // Meetings
  static const meetingsCreate = Permission('meetings', 'create');
  static const meetingsList = Permission('meetings', 'list');
  static const meetingsUpdate = Permission('meetings', 'update');
  static const meetingsDelete = Permission('meetings', 'delete');

  // Approval Flows / Requests
  static const approvalFlowsCreate = Permission('approval_flows', 'create');
  static const approvalFlowsList = Permission('approval_flows', 'list');
  static const approvalFlowsUpdate = Permission('approval_flows', 'update');
  static const approvalFlowsDelete = Permission('approval_flows', 'delete');
  static const approvalRequestsListOwn =
      Permission('approval_requests', 'list_own');
  static const approvalRequestsList = Permission('approval_requests', 'list');

  // Audit Logs
  static const auditLogsList = Permission('audit_logs', 'list');

  // Shareholders
  static const shareholdersList = Permission('shareholders', 'list');
  static const shareholdersCreate = Permission('shareholders', 'create');
  static const shareholdersUpdate = Permission('shareholders', 'update');

  // Assets
  static const assetsCreate = Permission('assets', 'create');
  static const assetsList = Permission('assets', 'list');
  static const assetsListOwn = Permission('assets', 'list_own');
  static const assetsUpdate = Permission('assets', 'update');
  static const assetsDelete = Permission('assets', 'delete');

  // Projects / Tasks / Worksites / Contracts / Timelines
  static const projectsCreate = Permission('projects', 'create');
  static const projectsList = Permission('projects', 'list');
  static const projectsUpdate = Permission('projects', 'update');
  static const projectsDelete = Permission('projects', 'delete');

  static const tasksCreate = Permission('tasks', 'create');
  static const tasksList = Permission('tasks', 'list');
  static const tasksListOwn = Permission('tasks', 'list_own');
  static const tasksUpdate = Permission('tasks', 'update');
  static const tasksUpdateOwn = Permission('tasks', 'update_own');
  static const tasksDelete = Permission('tasks', 'delete');

  static const worksitesCreate = Permission('worksites', 'create');
  static const worksitesList = Permission('worksites', 'list');
  static const worksitesUpdate = Permission('worksites', 'update');
  static const worksitesDelete = Permission('worksites', 'delete');

  static const contractsCreate = Permission('contracts', 'create');
  static const contractsList = Permission('contracts', 'list');
  static const contractsUpdate = Permission('contracts', 'update');
  static const contractsDelete = Permission('contracts', 'delete');

  // Budgets / Expenses / Payments / Service Invoices
  static const budgetsCreate = Permission('budgets', 'create');
  static const budgetsList = Permission('budgets', 'list');
  static const budgetsUpdate = Permission('budgets', 'update');
  static const budgetsDelete = Permission('budgets', 'delete');

  static const expensesCreate = Permission('expenses', 'create');
  static const expensesList = Permission('expenses', 'list');
  static const expensesListOwn = Permission('expenses', 'list_own');
  static const expensesUpdate = Permission('expenses', 'update');
  static const expensesUpdateOwn = Permission('expenses', 'update_own');
  static const expensesDelete = Permission('expenses', 'delete');
  static const expensesApprove = Permission('expenses', 'approve');
  static const expensesReject = Permission('expenses', 'reject');

  static const paymentsCreate = Permission('payments', 'create');
  static const paymentsList = Permission('payments', 'list');
  static const paymentsDelete = Permission('payments', 'delete');

  static const serviceInvoicesCreate = Permission('service_invoices', 'create');
  static const serviceInvoicesList = Permission('service_invoices', 'list');
  static const serviceInvoicesUpdate = Permission('service_invoices', 'update');
  static const serviceInvoicesDelete = Permission('service_invoices', 'delete');

  // Job Postings / Applicants / Interviews / Offers
  static const jobPostingsCreate = Permission('job_postings', 'create');
  static const jobPostingsList = Permission('job_postings', 'list');
  static const jobPostingsUpdate = Permission('job_postings', 'update');
  static const jobPostingsDelete = Permission('job_postings', 'delete');

  static const applicantsCreate = Permission('applicants', 'create');
  static const applicantsList = Permission('applicants', 'list');
  static const applicantsUpdate = Permission('applicants', 'update');
  static const applicantsDelete = Permission('applicants', 'delete');

  static const interviewsCreate = Permission('interviews', 'create');
  static const interviewsList = Permission('interviews', 'list');
  static const interviewsUpdate = Permission('interviews', 'update');
  static const interviewsDelete = Permission('interviews', 'delete');

  static const offerLettersCreate = Permission('offer_letters', 'create');
  static const offerLettersList = Permission('offer_letters', 'list');
  static const offerLettersUpdate = Permission('offer_letters', 'update');

  // Leave Requests
  static const leaveRequestsCreate = Permission('leave_requests', 'create');
  static const leaveRequestsList = Permission('leave_requests', 'list');
  static const leaveRequestsListOwn = Permission('leave_requests', 'list_own');
  static const leaveRequestsUpdate = Permission('leave_requests', 'update');
  static const leaveRequestsUpdateOwn =
      Permission('leave_requests', 'update_own');
  static const leaveRequestsDelete = Permission('leave_requests', 'delete');
  static const leaveRequestsDeleteOwn =
      Permission('leave_requests', 'delete_own');
  static const leaveRequestsApprove = Permission('leave_requests', 'approve');
  static const leaveRequestsReject = Permission('leave_requests', 'reject');

  // Payroll
  static const payrollList = Permission('payroll', 'list');
  static const payrollListOwn = Permission('payroll', 'list_own');
  static const payrollProcessBatch = Permission('payroll', 'process_batch');
  static const payrollMakePayment = Permission('payroll', 'make_payment');
  static const payrollAuthorize = Permission('payroll', 'authorize');

  // Performance / Training / Scorecards / Evaluations
  static const performanceReviewsCreate =
      Permission('performance_reviews', 'create');
  static const performanceReviewsList =
      Permission('performance_reviews', 'list');
  static const performanceReviewsListOwn =
      Permission('performance_reviews', 'list_own');
  static const performanceReviewsUpdate =
      Permission('performance_reviews', 'update');
  static const performanceReviewsDelete =
      Permission('performance_reviews', 'delete');

  static const trainingProgramsCreate =
      Permission('training_programs', 'create');
  static const trainingProgramsList = Permission('training_programs', 'list');
  static const trainingProgramsUpdate =
      Permission('training_programs', 'update');
  static const trainingProgramsDelete =
      Permission('training_programs', 'delete');

  static const monthlyScorecardsList = Permission('monthly_scorecards', 'list');
  static const monthlyScorecardsListOwn =
      Permission('monthly_scorecards', 'list_own');

  static const employeeEvaluationsList =
      Permission('employee_evaluations', 'list');
  static const employeeEvaluationsListOwn =
      Permission('employee_evaluations', 'list_own');

  // Work Reports
  static const workReportsCreate = Permission('work_reports', 'create');
  static const workReportsList = Permission('work_reports', 'list');
  static const workReportsListOwn = Permission('work_reports', 'list_own');
  static const workReportsUpdate = Permission('work_reports', 'update');
  static const workReportsUpdateOwn = Permission('work_reports', 'update_own');
  static const workReportsDelete = Permission('work_reports', 'delete');

  // Disciplinary / Awards
  static const disciplinaryCasesList = Permission('disciplinary_cases', 'list');
  static const disciplinaryCasesListOwn =
      Permission('disciplinary_cases', 'list_own');
  static const awardsList = Permission('awards', 'list');
  static const awardsListOwn = Permission('awards', 'list_own');

  // Legal
  static const legalCasesCreate = Permission('legal_cases', 'create');
  static const legalCasesList = Permission('legal_cases', 'list');
  static const legalCasesUpdate = Permission('legal_cases', 'update');
  static const legalCasesDelete = Permission('legal_cases', 'delete');

  static const complianceRecordsCreate =
      Permission('compliance_records', 'create');
  static const complianceRecordsList = Permission('compliance_records', 'list');
  static const complianceRecordsUpdate =
      Permission('compliance_records', 'update');

  static const complianceAuditsCreate =
      Permission('compliance_audits', 'create');
  static const complianceAuditsList = Permission('compliance_audits', 'list');
  static const complianceAuditsUpdate =
      Permission('compliance_audits', 'update');
  static const complianceAuditsDelete =
      Permission('compliance_audits', 'delete');

  // Events / Loans / Drawings / Partners
  static const eventsCreate = Permission('events', 'create');
  static const eventsList = Permission('events', 'list');
  static const eventsUpdate = Permission('events', 'update');
  static const eventsDelete = Permission('events', 'delete');

  static const loansCreate = Permission('loans', 'create');
  static const loansList = Permission('loans', 'list');
  static const loansListOwn = Permission('loans', 'list_own');
  static const loansApprove = Permission('loans', 'approve');
  static const loansReject = Permission('loans', 'reject');

  static const drawingsCreate = Permission('drawings', 'create');
  static const drawingsList = Permission('drawings', 'list');
  static const drawingsUpdate = Permission('drawings', 'update');
  static const drawingsDelete = Permission('drawings', 'delete');
  static const drawingsApprove = Permission('drawings', 'approve');
  static const drawingsReject = Permission('drawings', 'reject');

  static const partnersCreate = Permission('partners', 'create');
  static const partnersList = Permission('partners', 'list');
  static const partnersUpdate = Permission('partners', 'update');
  static const partnersDelete = Permission('partners', 'delete');

  // Policies / Documents / Content / Categories
  static const policiesCreate = Permission('policies', 'create');
  static const policiesList = Permission('policies', 'list');
  static const policiesUpdate = Permission('policies', 'update');
  static const policiesDelete = Permission('policies', 'delete');

  static const documentsCreate = Permission('documents', 'create');
  static const documentsList = Permission('documents', 'list');
  static const documentsUpdate = Permission('documents', 'update');
  static const documentsDelete = Permission('documents', 'delete');

  static const contentCreate = Permission('content', 'create');
  static const contentList = Permission('content', 'list');
  static const contentUpdate = Permission('content', 'update');
  static const contentDelete = Permission('content', 'delete');

  // Marketing / Services / Orders / Quotes
  static const marketingCampaignsCreate =
      Permission('marketing_campaigns', 'create');
  static const marketingCampaignsList =
      Permission('marketing_campaigns', 'list');
  static const marketingCampaignsUpdate =
      Permission('marketing_campaigns', 'update');

  static const servicesList = Permission('services', 'list');
  static const servicesCreate = Permission('services', 'create');
  static const servicesUpdate = Permission('services', 'update');

  static const ordersList = Permission('orders', 'list');
  static const quotesList = Permission('quotes', 'list');

  // KPIs (sidebar uses resKpis; typed constant needed by route gates)
  static const kpisList = Permission('kpis', 'list');

  // Work Locations (employee-submitted workspaces, admin-approved)
  static const workLocationsList = Permission('work_locations', 'list');
  static const workLocationsListOwn = Permission('work_locations', 'list_own');
  static const workLocationsView = Permission('work_locations', 'view');
  static const workLocationsRequestExtension =
      Permission('work_locations', 'request_extension');
  // Administrative approval actions are exposed by the backend under their
  // dedicated resource, separate from employee-owned work locations.
  static const workLocationsApprove =
      Permission('work_location_approvals', 'approve');
  static const workLocationsReject =
      Permission('work_location_approvals', 'reject');
  static const workLocationsUpdate =
      Permission('work_location_approvals', 'update');
  static const workLocationsDelete =
      Permission('work_location_approvals', 'delete');
  static const workLocationsListPending =
      Permission('work_location_approvals', 'list_pending');
  static const workLocationsManage =
      Permission('work_location_approvals', 'manage');
  static const workLocationsListExtensions =
      Permission('work_location_approvals', 'list_extensions');
  static const workLocationsApproveExtension =
      Permission('work_location_approvals', 'approve_extension');
  static const workLocationsRejectExtension =
      Permission('work_location_approvals', 'reject_extension');

  // System notifications
  static const notificationsView = Permission('notifications', 'view');
  static const notificationsList = Permission('notifications', 'list');
  static const notificationsMarkRead = Permission('notifications', 'mark_read');
  static const notificationsMarkAllRead =
      Permission('notifications', 'mark_all_read');

  // Misc useful actions
  static const clientInventoryList = Permission('client_inventory', 'list');
  static const walletView = Permission('wallet', 'view');
  static const walletViewOwn = Permission('wallet', 'view_own');
}

/// A dedicated sentinel meaning "any logged-in user can access this route."
/// Used in [routeRequirements] when a page should have no permission gate.
const List<Permission> _publicToLoggedIn = <Permission>[];

/// Route → required permissions (OR semantics). A user with ANY of the
/// listed permissions may access the route.
///
///   - `_publicToLoggedIn` ([]) means "any logged-in user". Use sparingly.
///   - Missing key means "any logged-in user" (same as public) — try to
///     explicitly add every route.
///   - Super admin (wildcard permission) always passes regardless.
const Map<String, List<Permission>> routeRequirements = {
  // Dashboard / profile — available to every employee (not super admin)
  RouteConstants.home: _publicToLoggedIn,
  RouteConstants.employeeMyProfile: _publicToLoggedIn,
  RouteConstants.employeeMyTasks: [Perms.tasksListOwn, Perms.tasksList],
  RouteConstants.employeeMyReports: [
    Perms.workReportsListOwn,
    Perms.workReportsList,
  ],

  // Company (admin)
  RouteConstants.company: [
    Perms.companySettingsView,
    Perms.companySettingsUpdate
  ],
  RouteConstants.branch: [Perms.branchesList, Perms.branchesView],
  RouteConstants.board: [Perms.boardResolutionsList],
  RouteConstants.broadcast: [Perms.announcementsList],
  RouteConstants.roles: [Perms.rolesList],
  RouteConstants.approvalWorkflow: [Perms.approvalFlowsList],
  RouteConstants.workspaceApprovals: [
    Perms.workLocationsApprove,
    Perms.workLocationsReject,
    Perms.workLocationsListPending,
    Perms.workLocationsManage,
    Perms.workLocationsListExtensions,
    Perms.workLocationsApproveExtension,
    Perms.workLocationsRejectExtension,
  ],
  // Company sub-pages (audit V4 fix): sidebar hid them via resRoles but
  // the router left them unmapped (fail-open). These expose org-wide data
  // (hierarchy, KPIs, compliance), so they require the ADMIN list action —
  // default employees' roles:view_own must not open them.
  RouteConstants.orgChart: [Perms.rolesList],
  RouteConstants.kpiManagement: [Perms.rolesList],
  RouteConstants.okrBoard: [Perms.rolesList],
  RouteConstants.complianceDashboard: [Perms.complianceRecordsList],
  RouteConstants.knowledgeBase: [Perms.rolesList],
  RouteConstants.enugu: [Perms.branchesList, Perms.branchesView],
  RouteConstants.auditLog: [Perms.auditLogsList],
  RouteConstants.department: [Perms.departmentsList],
  RouteConstants.assets: [Perms.assetsList],

  // HR
  RouteConstants.hr: [
    Perms.employeesList,
    Perms.jobPostingsList,
    Perms.leaveRequestsList,
    Perms.leaveRequestsListOwn,
    Perms.payrollList,
    Perms.payrollListOwn,
  ],
  // ── Admin-only list pages ─────────────────────────────────────────────
  // Showing "all X" across the org → require the admin `list` action.
  // Users with only `_own` permissions get the self-service equivalents
  // on the Dashboard ("My Profile", "My Tasks", "My Work Reports") instead.
  RouteConstants.employees: [Perms.employeesList],
  RouteConstants.employeeProfile: [Perms.employeesView, Perms.employeesViewOwn],
  RouteConstants.jobPost: [Perms.jobPostingsList],
  RouteConstants.attendance: [Perms.employeesList, Perms.employeesViewOwn],
  RouteConstants.leaveRequest: [Perms.leaveRequestsList],
  RouteConstants.trainingProgram: [Perms.trainingProgramsList],
  RouteConstants.performanceReview: [Perms.performanceReviewsList],
  RouteConstants.workReport: [Perms.workReportsList],
  RouteConstants.employeeEvaluation: [Perms.employeeEvaluationsList],
  RouteConstants.disciplinaryProcess: [Perms.disciplinaryCasesList],
  RouteConstants.performanceEngine: [Perms.performanceReviewsList],
  // Audit V4 fix: previously unmapped gap routes.
  RouteConstants.benefits: [Perms.payrollList, Perms.payrollListOwn],
  RouteConstants.associates: [Perms.employeesList],
  RouteConstants.eachProjects: [Perms.projectsList],
  RouteConstants.taskDetail: [Perms.tasksList, Perms.tasksListOwn],
  RouteConstants.performanceLeaderboard: [Perms.monthlyScorecardsList],
  RouteConstants.meetings: [Perms.meetingsList],

  // ── Self-service pages (employees' own records) ───────────────────────
  // Accept EITHER the `_own` action (normal employee) OR the admin `list`
  // so an admin landing on the same page still works.
  RouteConstants.leaves: [Perms.leaveRequestsListOwn, Perms.leaveRequestsList],
  RouteConstants.loans: [Perms.loansListOwn, Perms.loansList],
  RouteConstants.monthlyScorecard: [
    Perms.monthlyScorecardsListOwn,
    Perms.monthlyScorecardsList,
  ],
  // Boss/HR only — the default employee baseline grants everyone
  // `awards:list_own`, so that action must NOT appear here.
  RouteConstants.awardsRecognition: [Perms.awardsList],

  // ── Operations (admin list) ───────────────────────────────────────────
  RouteConstants.operations: [Perms.projectsList, Perms.tasksList],
  RouteConstants.projects: [Perms.projectsList],
  RouteConstants.tasks: [Perms.tasksList],
  RouteConstants.worksite: [Perms.worksitesList],
  RouteConstants.contracts: [Perms.contractsList],
  RouteConstants.operationsProjectDetail: [Perms.projectsList],
  // Task detail — opened from "My Tasks" too, so allow list_own.
  RouteConstants.operationsTaskDetail: [Perms.tasksList, Perms.tasksListOwn],
  RouteConstants.operationsWorksiteDetail: [Perms.worksitesList],
  RouteConstants.operationsContractDetail: [Perms.contractsList],
  RouteConstants.operationsTimelineDetail: [Perms.projectsList],

  // Finance (Company accounting and finance command center)
  RouteConstants.finance: [
    Perms.budgetsList,
    Perms.expensesList,
    Perms.paymentsList,
    Perms.estateInvoicesList,
    Perms.serviceInvoicesList,
    Perms.statsView,
  ],
  RouteConstants.financeDashboard: [
    Perms.statsView,
    Perms.budgetsList,
    Perms.expensesList,
  ],
  RouteConstants.budget: [Perms.budgetsList],
  RouteConstants.expense: [Perms.expensesList],
  RouteConstants.invoice: [
    Perms.estateInvoicesList,
    Perms.serviceInvoicesList,
  ],
  RouteConstants.payment: [Perms.paymentsList],
  RouteConstants.contractPayment: [Perms.paymentsList, Perms.contractsList],
  RouteConstants.financeInvoices: [
    Perms.estateInvoicesList,
    Perms.serviceInvoicesList,
  ],
  RouteConstants.financePayments: [Perms.paymentsList],
  RouteConstants.financeReceivables: [
    Perms.estateInvoicesList,
    Perms.serviceInvoicesList,
    Perms.paymentsList,
  ],
  RouteConstants.financeWallets: [Perms.paymentsList, Perms.walletView],
  RouteConstants.financeCashbook: [Perms.paymentsList, Perms.expensesList],
  RouteConstants.financeExpenses: [Perms.expensesList],
  RouteConstants.financeVendors: [Perms.expensesList],
  RouteConstants.financePettyCash: [Perms.expensesList],
  RouteConstants.financeApprovals: [
    Perms.approvalRequestsList,
    Perms.approvalFlowsList,
    Perms.expensesApprove,
    Perms.expensesList,
  ],
  RouteConstants.financePayroll: [Perms.payrollList],
  RouteConstants.financeCommissions: [Perms.paymentsList, Perms.awardsList],
  RouteConstants.financeTax: [Perms.expensesList, Perms.budgetsList],
  RouteConstants.financeJournals: [Perms.budgetsList],
  RouteConstants.financeCoa: [Perms.budgetsList],
  RouteConstants.financeAssets: [Perms.assetsList],
  RouteConstants.financeCashflow: [Perms.budgetsList],
  RouteConstants.financeServiceOrders: [Perms.ordersList],
  RouteConstants.financeEstate: [Perms.estatesList, Perms.estateInvoicesList],
  RouteConstants.financeReports: [Perms.statsView, Perms.budgetsList],
  RouteConstants.financeAudit: [
    Perms.complianceAuditsList,
    Perms.auditLogsList
  ],
  RouteConstants.financeSettings: [
    Perms.companySettingsUpdate,
    Perms.companySettingsView
  ],

  // Services
  RouteConstants.services: [
    Perms.servicesList,
    Perms.propertiesList,
    Perms.estatesList,
    Perms.clientsList,
  ],
  RouteConstants.realEstate: [Perms.propertiesList],
  RouteConstants.realEstateDetail: [Perms.propertiesList],
  RouteConstants.landSurvey: [Perms.propertiesList],
  RouteConstants.landSurveyDetail: [Perms.propertiesList],
  RouteConstants.propertyList: [Perms.propertiesList],
  RouteConstants.propertyDetail: [Perms.propertiesList],
  RouteConstants.estateManagement: [Perms.estatesList],
  RouteConstants.estateDetail: [Perms.estatesList],
  RouteConstants.estatePerformance: [Perms.estatesList],
  RouteConstants.serviceOrder: [Perms.ordersList],
  RouteConstants.serviceClients: [Perms.clientsList],
  RouteConstants.serviceClientUpload: [Perms.clientsList],
  RouteConstants.generateInvoice: [Perms.serviceInvoicesList],
  RouteConstants.serviceLeads: [Perms.leadsList],
  RouteConstants.serviceInvoices: [Perms.serviceInvoicesList],
  RouteConstants.paymentApproval: [Perms.estateInvoicesApprove],
  RouteConstants.servicesProperty: [Perms.propertiesList],
  RouteConstants.serviceDetail: [Perms.servicesList],
  RouteConstants.landSurveyCalculator: _publicToLoggedIn,
  RouteConstants.servicesCalculator: _publicToLoggedIn,

  // ── Services webview module (audit V4 fix) ───────────────────────────
  // Explicit gates mirroring each sidebar entry's resource array; these
  // pages hand tokens to the embedded services app.
  RouteConstants.servicesDashboard: [
    Perms.servicesList,
    Perms.statsView,
  ],
  RouteConstants.servicesCatalogue: [Perms.servicesList],
  RouteConstants.servicesCalculators: [Perms.servicesList],
  RouteConstants.servicesRequestFormBuilder: [Perms.servicesList],
  RouteConstants.servicesWorkflowDesigner: [Perms.servicesList],
  RouteConstants.servicesBranchActivation: [
    Perms.branchesList,
    Perms.servicesList
  ],
  RouteConstants.servicesRequests: [Perms.servicesList, Perms.clientsList],
  RouteConstants.servicesQuotations: [Perms.quotesList, Perms.servicesList],
  RouteConstants.servicesInvoicesPayments: [
    Perms.serviceInvoicesList,
    Perms.paymentsList,
  ],
  RouteConstants.servicesApprovals: [
    Perms.approvalFlowsList,
    Perms.servicesList
  ],
  RouteConstants.servicesOrders: [Perms.ordersList],
  RouteConstants.servicesExecutionTasks: [Perms.tasksList, Perms.ordersList],
  RouteConstants.servicesDeliverables: [Perms.documentsList, Perms.ordersList],
  RouteConstants.servicesRealEstateInventory: [
    Perms.propertiesList,
    Perms.estatesList,
  ],
  RouteConstants.servicesSurveyEngineeringOthers: [
    Perms.servicesList,
    Perms.propertiesList,
  ],
  RouteConstants.servicesFeedbackQuality: [Perms.clientsList],
  RouteConstants.servicesReportsAnalytics: [Perms.statsView],

  // Analytics (stats permission gates all)
  RouteConstants.analyticsOverview: [Perms.statsView],
  RouteConstants.analyticsRevenue: [Perms.statsView],
  RouteConstants.analyticsProjects: [Perms.statsView],
  RouteConstants.analyticsPerformance: [Perms.statsView],
  RouteConstants.branchPerformanceAnalysis: [Perms.statsView],

  // Legal
  RouteConstants.legalContracts: [Perms.contractsList],
  RouteConstants.legalCompliance: [Perms.complianceRecordsList],
  RouteConstants.legalCases: [Perms.legalCasesList],
  RouteConstants.legalAudits: [Perms.complianceAuditsList],

  // Client Portal
  RouteConstants.clientAccess: [Perms.clientsList],
  RouteConstants.communications: [Perms.clientsList],
  RouteConstants.documentSharing: [Perms.documentsList],
  RouteConstants.portalAnalytics: [Perms.statsView, Perms.clientsList],

  // Events
  RouteConstants.events: [Perms.eventsList],

  // Workspace (every logged-in user)
  RouteConstants.workspace: _publicToLoggedIn,
  RouteConstants.workspaceDashboard: _publicToLoggedIn,

  // ── Marketing (audit V4 fix) ─────────────────────────────────────────
  // Every webview route is now explicitly gated, mirroring the resource
  // array of its sidebar entry in menu_structure.dart. Previously these
  // were unmapped (fail-open), so any logged-in user could reach them —
  // and each page hands the user's access+refresh tokens to the embedded
  // marketing app.
  RouteConstants.marketing: [Perms.marketingCampaignsList],
  RouteConstants.marketingLeadDetail: [Perms.leadsList],
  RouteConstants.marketingCampaignDetail: [Perms.marketingCampaignsList],
  RouteConstants.marketingSiteDetail: [Perms.marketingCampaignsList],

  // Overview / command centre family
  RouteConstants.marketingDashboard: [
    Perms.marketingCampaignsList,
    Perms.statsView,
  ],
  RouteConstants.marketingOkrs: [Perms.kpisList],

  // Leads family
  RouteConstants.marketingPipeline: [Perms.leadsList],
  RouteConstants.marketingLeadControl: [Perms.leadsList],
  RouteConstants.marketingLeadJournal: [Perms.leadsList],
  RouteConstants.marketingNewLead: [Perms.leadsList],

  // Campaigns & content family
  RouteConstants.marketingCampaigns: [Perms.marketingCampaignsList],
  RouteConstants.marketingCalendar: [Perms.marketingCampaignsList],
  RouteConstants.marketingPlaybooks: [Perms.marketingCampaignsList],
  RouteConstants.marketingContentStudio: [
    Perms.contentList,
    Perms.marketingCampaignsList,
  ],
  RouteConstants.marketingEmailCenter: [Perms.marketingCampaignsList],
  RouteConstants.marketingMediaRegister: [Perms.marketingCampaignsList],
  RouteConstants.marketingRealtorPortal: [
    Perms.partnersList,
    Perms.marketingCampaignsList,
  ],
  RouteConstants.marketingPartnerPortal: [
    Perms.partnersList,
    Perms.marketingCampaignsList,
  ],
  RouteConstants.marketingPartners: [
    Perms.partnersList,
    Perms.marketingCampaignsList,
  ],
  RouteConstants.marketingMeetings: [
    Perms.meetingsList,
    Perms.marketingCampaignsList,
  ],

  // Analytics family
  RouteConstants.marketingAnalytics: [Perms.statsView],
  RouteConstants.marketingRevenueCommand: [Perms.statsView],
  RouteConstants.marketingFunnelAudit: [Perms.statsView],
  RouteConstants.marketingTurnaround: [Perms.statsView],

  // Team / workdesk
  RouteConstants.marketingTeam: [Perms.employeesList, Perms.employeesViewOwn],
  RouteConstants.marketingWorkdesk: [
    Perms.employeesList,
    Perms.employeesViewOwn,
  ],

  // Tasks / documents / training / budgets / clients families
  RouteConstants.marketingDailyExecution: [Perms.tasksList, Perms.tasksListOwn],
  RouteConstants.marketingMedia: [Perms.documentsList],
  RouteConstants.marketingCoaching: [Perms.trainingProgramsList],
  RouteConstants.marketingForecast: [Perms.budgetsList],
  RouteConstants.marketingRetention: [Perms.clientsList],
  RouteConstants.marketingHandoff: [Perms.clientsList],
  RouteConstants.marketingSupport: [Perms.clientsList],

  // Governance family
  RouteConstants.marketingRoleGovernance: [Perms.rolesList],
  RouteConstants.marketingApprovals: [Perms.approvalFlowsList],
  RouteConstants.marketingAuditLog: [Perms.auditLogsList],
  RouteConstants.marketingCompliance: [Perms.auditLogsList],
  // Registered but sidebar-orphaned routes get module-default gates.
  RouteConstants.marketingReports: [Perms.auditLogsList],
  RouteConstants.marketingIntegrations: [Perms.marketingCampaignsList],
  RouteConstants.marketingDesign: [Perms.marketingCampaignsList],
  RouteConstants.marketingWhatsapp: [Perms.marketingCampaignsList],

  // CRM
  RouteConstants.crmClients: [Perms.clientsList],
  RouteConstants.crmLeads: [Perms.leadsList],
  RouteConstants.crmAnalytics: [Perms.statsView],
  RouteConstants.crmInteractions: [Perms.clientsList],

  // Security (admin)
  RouteConstants.securityOverview: [Perms.auditLogsList, Perms.rolesList],
  RouteConstants.securityAlerts: [Perms.auditLogsList],
  RouteConstants.securityCodes: [Perms.rolesList],
  RouteConstants.securityWorkflow: [Perms.approvalFlowsList],
  RouteConstants.securityLogs: [Perms.auditLogsList],

  // Employee module
  RouteConstants.employee: _publicToLoggedIn,
  RouteConstants.employeeDirectory: [Perms.employeesList],
  RouteConstants.employeePerformance: [
    Perms.performanceReviewsList,
    Perms.performanceReviewsListOwn,
  ],
  RouteConstants.employeeAttendance: _publicToLoggedIn,
  RouteConstants.employeeTraining: [Perms.trainingProgramsList],
  RouteConstants.employeeRole: [Perms.rolesViewOwn, Perms.rolesView],
};

/// Routes the super admin / CEO should be redirected AWAY from
/// because they have their own dashboard ([RouteConstants.company]).
const Set<String> superAdminHiddenRoutes = {
  RouteConstants.home,
};
