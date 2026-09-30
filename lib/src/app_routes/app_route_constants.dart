class RouteConstants {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String biometric = '/biometric';
  static const String home = '/dashboard';
  static const String resetPassword = '/reset-password';
  static const String forgotPassword = '/forgot-password';
  static const String twoFactorVerify = '/two-factor-verify';

  static const String company = '/company';
  static const String enugu = '/company/enugu';
  static const String branch = '/company/branch';
  static const String auditLog = '/company/audit-log';
  static const String board = '/company/board';
  static const String broadcast = '/company/broadcast';
  static const String roles = '/company/roles';
  static const String orgChart = '/company/org-chart';
  static const String kpiManagement = '/company/kpi-management';
  static const String okrBoard = '/company/okr-board';
  static const String roleDetail = '/company/roles/detail';
  static String roleDetailPath(int roleId) => '/company/roles/$roleId';
  static const String complianceDashboard = '/company/compliance';
  static const String knowledgeBase = '/company/knowledge-base';
  static const String approvalWorkflow = '/company/approval-workflow';
  static const String workspaceApprovals = '/company/workspace-approvals';
  // static const String compliance = '/company/compliance';

  // marketing
  static const String marketing = '/marketing';
  static const String marketingDashboard = '/marketing/dashboard';
  static const String marketingPipeline = '/marketing/pipeline';
  static const String marketingCampaigns = '/marketing/campaigns';
  static const String marketingCalendar = '/marketing/calendar';
  static const String marketingAnalytics = '/marketing/analytics';
  static const String marketingOkrs = '/marketing/okrs';
  static const String marketingReports = '/marketing/reports';
  static const String marketingTeam = '/marketing/team';
  static const String marketingNewLead = '/marketing/new-lead';
  static const String marketingMedia = '/marketing/media';

  // revenue execution
  static const String marketingRevenueCommand = '/marketing/revenue-command';
  static const String marketingDailyExecution = '/marketing/daily-execution';
  static const String marketingLeadControl = '/marketing/lead-control';
  static const String marketingFunnelAudit = '/marketing/funnel-audit';
  static const String marketingPlaybooks = '/marketing/playbooks';
  static const String marketingContentStudio = '/marketing/content-studio';
  static const String marketingCoaching = '/marketing/coaching';
  static const String marketingForecast = '/marketing/forecast';
  static const String marketingRetention = '/marketing/retention';

  // integrations & workdesk
  static const String marketingWorkdesk = '/marketing/workdesk';
  static const String marketingLeadJournal = '/marketing/lead-journal';
  static const String marketingIntegrations = '/marketing/integrations';

  // commercial operations
  static const String marketingEmailCenter = '/marketing/email-center';
  static const String marketingMediaRegister = '/marketing/media-register';
  static const String marketingHandoff = '/marketing/handoff';
  static const String marketingRealtorPortal = '/marketing/realtor-portal';
  static const String marketingPartnerPortal = '/marketing/partner-portal';

  // governance
  static const String marketingRoleGovernance = '/marketing/role-governance';
  static const String marketingApprovals = '/marketing/approvals';
  static const String marketingAuditLog = '/marketing/audit-log';

  // campaign operations & additional tools
  static const String marketingMeetings = '/marketing/marketing-meetings';
  static const String marketingTurnaround = '/marketing/turnaround';
  static const String marketingCompliance = '/marketing/compliance';
  static const String marketingPartners = '/marketing/partners';
  static const String marketingSupport = '/marketing/support';
  static const String marketingDesign = '/marketing/design';
  static const String marketingWhatsapp = '/marketing/whatsapp';

  static const String marketingLeadDetail = '/marketing/lead/detail';
  static const String marketingCampaignDetail = '/marketing/campaign/detail';
  static const String marketingSiteDetail = '/marketing/site/detail';

  // work
  static const String operations = '/operations';
  static const String operationsProjectDetail = '/operations/projects/detail';
  static const String operationsTaskDetail = '/operations/task/detail';
  static const String operationsWorksiteDetail = '/operations/worksite/detail';
  static const String operationsContractDetail = '/operations/contract/detail';
  static const String operationsTimelineDetail = '/operations/timeline/detail';
  static const String works = '/works';
  static const String projects = '/works/projects';
  static const String eachProjects = '/works/projects/detail';
  static const String tasks = '/works/tasks';
  static const String contracts = '/works/contracts';
  static const String worksite = '/works/worksite';
  static const String engineeringSiteReports = '/works/engineering-site-reports';

  // hr
  static const String employees = '/hr/employees';
  static const String addEmployees = '/hr/employees/add';
  static const String employeeProfile = '/hr/employees/profile';
  static const String leaves = '/hr/leaves';
  static const String meetings = '/hr/meetings';
  static const String department = '/company/department';
  static const String hr = '/hr';
  static const String jobPost = '/hr/job-post';
  static const String attendance = '/hr/attendance';
  static const String benefits = '/hr/benefits';
  static const String leaveRequest = '/hr/leave-request';
  static const String trainingProgram = '/hr/training-program';
  static const String loans = '/hr/loans';
  static const String performanceReview = '/hr/performance-review';
  // static const String clockIn = '/hr/clock-in';
  static const String associates = '/hr/associates';
  static const String assets = '/company/assets';
  static const String workReport = '/hr/work-report';
  static const String monthlyScorecard = '/hr/monthly-scorecard';
  static const String awardsRecognition = '/hr/awards-recognition';
  static const String performanceLeaderboard = '/hr/performance-leaderboard';
  static const String employeeEvaluation = '/hr/employee-evaluation';
  static const String disciplinaryProcess = '/hr/disciplinary-process';
  static const String performanceEngine = '/hr/performance-engine';

  // services
  static const String services = '/services';
  static const String servicesDashboard = '/services/dashboard';
  static const String servicesCatalogue = '/services/service-catalogue';
  static const String servicesCalculators = '/services/calculator-library';
  static const String servicesRequestFormBuilder =
      '/services/request-form-builder';
  static const String servicesWorkflowDesigner = '/services/workflow-designer';
  static const String servicesBranchActivation = '/services/branch-activation';
  static const String servicesRequests = '/services/service-requests';
  static const String servicesQuotations = '/services/quotations';
  static const String servicesInvoicesPayments = '/services/invoices-payments';
  static const String servicesApprovals = '/services/approvals';
  static const String servicesOrders = '/services/service-orders';
  static const String servicesExecutionTasks = '/services/execution-tasks';
  static const String servicesDeliverables = '/services/deliverables';
  static const String servicesRealEstateInventory =
      '/services/real-estate-inventory';
  static const String servicesSurveyEngineeringOthers =
      '/services/survey-engineering-others';
  static const String servicesFeedbackQuality = '/services/feedback-quality';
  static const String servicesReportsAnalytics = '/services/reports-analytics';

  static const String servicesProperty = '/services-property';
  static const String serviceDetail = '/services/detail';
  static const String realEstate = '/services/real-estate';
  static const String realEstateDetail = '/services/real-estate/detail';
  static const String serviceOrder = '/services/service-order';
  static const String landSurvey = '/services/land-survey';
  static const String taskDetail = '/services/task/detail';
  static const String landSurveyDetail = '/services/land-survey/detail';
  static const String landSurveyCalculator = '/services/land-survey-calculator';
  static const String servicesCalculator = '/services/services-calculator';

  // Property Management
  static const String propertyList = '/services/property';
  static const String propertyDetail = '/services/property/detail';

  // Service Client management
  static const String serviceClients = '/services/clients';
  static const String serviceClientUpload = '/services/clients/upload';

  // Service Invoice Management
  static const String generateInvoice = '/services/generate-invoice';
  static const String serviceLeads = '/services/leads';
  static const String serviceInvoices = '/services/invoices';

  // Estate Management
  static const String estateManagement = '/services/estate-management';
  static const String estateDetail = '/services/estate/detail';
  static String estateDetailPath(int estateId) => '/services/estate/$estateId';
  static const String estatePerformance = '/services/estate-performance';
  static String estatePerformancePath(int estateId) =>
      '/services/estate-performance/$estateId';

  // Payment Approval
  static const String paymentApproval = '/services/payment-approval';
  static const String finance = '/finance';
  static const String invoice = '/finance/invoice';
  static const String payment = '/finance/payment';
  static const String expense = '/finance/expense';
  static const String contractPayment = '/finance/contract-payment';
  static const String budget = '/finance/budget';
  static const String financeDashboard = '/finance/dashboard';
  static const String financeInvoices = '/finance/invoices';
  static const String financePayments = '/finance/payments';
  static const String financeReceivables = '/finance/receivables';
  static const String financeWallets = '/finance/wallets';
  static const String financeCashbook = '/finance/cashbook';
  static const String financeExpenses = '/finance/expenses';
  static const String financeVendors = '/finance/vendors';
  static const String financePettyCash = '/finance/pettycash';
  static const String financeApprovals = '/finance/approvals';
  static const String financePayroll = '/finance/payroll';
  static const String financeCommissions = '/finance/commissions';
  static const String financeTax = '/finance/tax';
  static const String financeJournals = '/finance/journals';
  static const String financeCoa = '/finance/coa';
  static const String financeAssets = '/finance/assets';
  static const String financeCashflow = '/finance/cashflow';
  static const String financeServiceOrders = '/finance/serviceorders';
  static const String financeEstate = '/finance/estatefinance';
  static const String financeReports = '/finance/reports';
  static const String financeAudit = '/finance/audit';
  static const String financeSettings = '/finance/settings';

  // workspace
  static const String workspace = '/workspace';
  static const String workspaceDashboard = '/workspace-dashboard';

  // Analytics
  static const String analyticsOverview = '/analytics';
  static const String analyticsRevenue = '/analytics/revenue';
  static const String analyticsProjects = '/analytics/projects';
  static const String analyticsPerformance = '/analytics/performance';
  static const String branchPerformanceAnalysis =
      '/analytics/branch-performance';

  // Legal & Compliance
  static const String legalContracts = '/legal/contracts';
  static const String legalCompliance = '/Compliance';
  static const String legalCases = '/legal/Cases';
  static const String legalAudits = '/legal/Audits';

  // Client Portal
  static const String clientAccess = '/client/portal';
  static const String communications = '/client/portal/communications';
  static const String documentSharing = '/client/portal/documents&sharing';
  static const String portalAnalytics = '/client/portal/analytics';

  // Security
  static const String securityCodes = '/security/codes';
  static const String securityWorkflow = '/security/workflows';
  static const String securityAlerts = '/security/alerts';
  static const String securityLogs = '/security/logs';
  static const String securityOverview = '/security/overview';

  // CRM
  static const String crmAnalytics = '/crm/analytics';
  static const String crmClients = '/crm/clients';
  static const String crmLeads = '/crm/leads';
  static const String crmInteractions = '/crm/interactions';

  // Marketing & CRM combined dashboard
  static const String marketingCrm = '/marketing-crm';

  // Events
  static const String events = '/events';

  // Employee Module
  static const String employee = '/employee';
  static const String employeeDirectory = '/employee/directory';
  static const String employeePerformance = '/employee/performance';
  static const String employeeAttendance = '/employee/attendance';
  static const String employeeTraining = '/employee/training';

  // Employee Dashboard Flow
  static const String employeeMyTasks = '/dashboard/my-tasks';
  static const String employeeMyReports = '/dashboard/my-reports';
  static const String employeeMyTargetReports = '/dashboard/my-target-reports';
  static const String employeeMyProfile = '/dashboard/my-profile';
  static const String employeeRole = '/dashboard/role';
}
