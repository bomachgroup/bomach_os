/// Web-free registry of every path registered in
/// `app_router.dart`'s `_dashboardRoutes` map.
///
/// Lives outside the router file so VM tests can assert sidebar↔router
/// consistency without importing `package:web` through the router's
/// widget graph. The router's map is the source of truth; this list must
/// stay in sync with it (enforced by test T9's companion assertion that
/// every entry here appears in the router map when run on a web-enabled
/// target).
const Set<String> dashboardRoutePaths = {
  '/dashboard',
  '/dashboard/my-tasks',
  '/dashboard/my-reports',
  '/dashboard/my-profile',
  // hr + employee module
  '/hr', '/hr/employees', '/hr/employees/profile',
  '/employee', '/employee/directory', '/employee/performance',
  '/employee/attendance', '/employee/training',
  // operations / work
  '/works/projects', '/works/projects/detail', '/works/worksite',
  '/works/tasks', '/works/contracts', '/hr/meetings',
  '/services/service-order', '/services/land-survey',
  '/services/real-estate', '/services/real-estate/detail',
  '/services/task/detail', '/company/assets',
  '/services-property', '/services/detail',
  // company
  '/company', '/company/branch', '/company/audit-log', '/company/board',
  '/company/broadcast', '/company/roles', '/company/roles/detail',
  '/company/compliance', '/company/knowledge-base', '/company/org-chart',
  '/company/kpi-management', '/company/okr-board',
  '/company/approval-workflow', '/company/workspace-approvals',
  '/company/enugu', '/company/department',
  // finance
  '/finance', '/finance/invoice', '/finance/payment', '/finance/expense',
  '/finance/contract-payment', '/finance/budget',
  // hr admin pages
  '/hr/job-post', '/hr/attendance', '/hr/leave-request', '/hr/benefits',
  '/hr/training-program', '/hr/loans', '/hr/performance-review',
  '/hr/disciplinary-process', '/hr/leaves',
  '/hr/monthly-scorecard', '/hr/awards-recognition',
  '/hr/performance-leaderboard', '/hr/employee-evaluation',
  '/hr/associates', '/hr/work-report',
  // services local + webview routes
  '/services',
  '/services/dashboard', '/services/service-catalogue',
  '/services/calculator-library', '/services/request-form-builder',
  '/services/workflow-designer', '/services/branch-activation',
  '/services/service-requests', '/services/quotations',
  '/services/invoices-payments', '/services/approvals',
  '/services/service-orders', '/services/execution-tasks',
  '/services/deliverables', '/services/real-estate-inventory',
  '/services/survey-engineering-others', '/services/feedback-quality',
  '/services/reports-analytics',
  '/services/land-survey-calculator', '/services/services-calculator',
  '/services/property', '/services/property/detail',
  '/services/estate-management', '/services/estate/detail',
  '/services/estate-performance', '/services/payment-approval',
  '/services/clients', '/services/clients/upload',
  '/services/generate-invoice', '/services/leads', '/services/invoices',
  // operations detail pages
  '/operations', '/operations/projects/detail', '/operations/task/detail',
  '/operations/worksite/detail', '/operations/contract/detail',
  '/operations/timeline/detail',
  // marketing native + webview routes
  '/marketing', '/marketing/dashboard', '/marketing/pipeline',
  '/marketing/campaigns', '/marketing/calendar', '/marketing/analytics',
  '/marketing/okrs', '/marketing/reports', '/marketing/team',
  '/marketing/new-lead', '/marketing/media', '/marketing/revenue-command',
  '/marketing/daily-execution', '/marketing/lead-control',
  '/marketing/funnel-audit', '/marketing/playbooks',
  '/marketing/content-studio', '/marketing/coaching', '/marketing/forecast',
  '/marketing/retention', '/marketing/workdesk', '/marketing/lead-journal',
  '/marketing/integrations', '/marketing/email-center',
  '/marketing/media-register', '/marketing/handoff',
  '/marketing/realtor-portal', '/marketing/partner-portal',
  '/marketing/role-governance', '/marketing/approvals',
  '/marketing/audit-log', '/marketing/marketing-meetings',
  '/marketing/turnaround', '/marketing/compliance', '/marketing/partners',
  '/marketing/support', '/marketing/design', '/marketing/whatsapp',
  '/marketing/lead/detail', '/marketing/campaign/detail',
  // workspace
  '/workspace', '/workspace-dashboard',
  // analytics
  '/analytics', '/analytics/revenue', '/analytics/projects',
  '/analytics/performance', '/analytics/branch-performance',
  // legal
  '/legal/Audits', '/legal/contracts', '/Compliance', '/legal/Cases',
  // client portal
  '/client/portal', '/client/portal/communications',
  '/client/portal/documents&sharing', '/client/portal/analytics',
  // security
  '/security/alerts', '/security/codes', '/security/logs',
  '/security/workflows', '/security/overview',
  // marketing-crm + crm
  '/marketing-crm', '/crm/clients', '/crm/leads', '/crm/interactions',
  '/crm/analytics',
  // events
  '/events',
};
