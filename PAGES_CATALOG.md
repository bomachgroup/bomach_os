# Bomach OS - Pages Catalog

A comprehensive catalog of all pages and modules in the Bomach OS enterprise management system.

---

## 📋 Table of Contents

1. [Authentication Pages](#authentication-pages)
2. [Main Dashboard & Layout](#main-dashboard--layout)
3. [HR Module](#hr-module)
4. [Finance Module](#finance-module)
5. [Operations Module](#operations-module)
6. [CRM Module](#crm-module)
7. [Marketing Module](#marketing-module)
8. [Services Module](#services-module)
9. [Legal Module](#legal-module)
10. [Security Module](#security-module)
11. [Analytics Module](#analytics-module)
12. [Clients Portal](#clients-portal)
13. [Employee Module](#employee-module)
14. [Company Module](#company-module)
15. [Workspace Module](#workspace-module)
16. [Events Module](#events-module)

---

## Authentication Pages

### 🔑 Login (`lib/pages/auth/login.dart`)
- **Purpose**: Main user authentication page
- **Features**:
  - Email/password login form
  - Remember device checkbox
  - Background image with centered login card
  - Sign in button integration
  - Navigation to biometric login option

### 🔐 Biometric Login (`lib/pages/auth/biometric.dart`)
- **Purpose**: Fingerprint/face recognition authentication
- **Features**:
  - Biometric availability checking
  - Fingerprint/face authentication flow
  - Error handling for unavailable biometrics
  - "Remember device" option
  - Fallback to regular login
  - Device-specific authentication integration

---

## Main Dashboard & Layout

### 📊 Main Dashboard (`lib/pages/dashboad/dashboard.dart`)
- **Purpose**: Admin dashboard landing page
- **Features**:
  - Welcome message display
  - High-level business overview
  - Navigation hub to other modules
  - Summary statistics

### 🖥️ Large Screen Layout (`lib/pages/large_screen.dart`)
- **Purpose**: Desktop layout wrapper
- **Features**:
  - Persistent sidebar navigation
  - Main content area
  - Responsive to screen size > 900px
  - StatefulShellRoute shell integration

### 📱 Small Screen Layout (`lib/pages/small_screen.dart`)
- **Purpose**: Mobile/tablet responsive layout
- **Features**:
  - Hamburger menu navigation
  - Full-width content area
  - Optimized for screens < 900px
  - Touch-friendly interface

---

## HR Module

### 📚 HR Dashboard (`lib/pages/hr/hr.dart`)
- **Purpose**: Main HR module dashboard
- **Features**:
  - Employee summary statistics
  - Department overview
  - Attendance metrics
  - Payroll summary
  - Leave request counts
  - Quick action buttons

### 👥 Associates (`lib/pages/hr/associates.dart`)
- **Purpose**: View and manage business associates/contractors
- **Features**:
  - List of associates
  - Associate profiles
  - Contract management
  - Performance tracking

### 📅 Attendance (`lib/pages/hr/attendance.dart`)
- **Purpose**: Track employee attendance records
- **Features**:
  - Daily attendance logs
  - Attendance status (Present/Absent/Leave)
  - Department-wise attendance
  - Monthly attendance reports
  - Attendance summary metrics

### ⏰ Clock In (`lib/pages/hr/clock_in.dart`)
- **Purpose**: Employee clock in/out system
- **Features**:
  - Real-time check-in/check-out
  - Timestamp recording
  - Location tracking (optional)
  - Work hours calculation

### 🏢 Department (`lib/pages/hr/department.dart`)
- **Purpose**: Department management
- **Features**:
  - Department listings
  - Employee per department
  - Department budgets
  - Department heads assignment

### 💼 Job Applicants (`lib/pages/hr/job_applicants.dart`)
- **Purpose**: Manage job applications
- **Features**:
  - Application tracking
  - Applicant screening
  - Interview scheduling
  - Applicant status management
  - Resume/document storage

### 📢 Job Posts (`lib/pages/hr/job_post.dart`)
- **Purpose**: Create and manage job postings
- **Features**:
  - Job posting creation
  - Posting status management (Active/Closed)
  - Applicant count tracking
  - Job description editing
  - Requirements management

### 👁️ Leads (`lib/pages/hr/leads.dart`)
- **Purpose**: Track HR leads (potential hires)
- **Features**:
  - Lead pipeline management
  - Lead source tracking
  - Conversion metrics
  - Lead status updates

### 🗓️ Leave Requests (`lib/pages/hr/leave_request.dart`)
- **Purpose**: Manage employee leave requests
- **Features**:
  - Request submission and approval
  - Leave balance tracking
  - Different leave types (annual, medical, etc.)
  - Manager approval workflow
  - Leave calendar view

### 📆 Leaves (`lib/pages/hr/leaves.dart`)
- **Purpose**: Overview of all leaves
- **Features**:
  - Leave types management
  - Leave policies
  - Paid/unpaid leave configuration
  - Leave entitlements per employee

### 💬 Meetings (`lib/pages/hr/meetings.dart`)
- **Purpose**: HR-related meetings coordination
- **Features**:
  - Meeting scheduling
  - Attendee management
  - Meeting agendas
  - Meeting notes/minutes

### ⭐ Performance Review (`lib/pages/hr/performance_review.dart`)
- **Purpose**: Employee performance evaluation
- **Features**:
  - Performance ratings
  - Review scheduling
  - Feedback collection
  - Goal tracking
  - Review history

### 💰 Payroll (`lib/pages/hr/payroll.dart`)
- **Purpose**: Payroll management and processing
- **Features**:
  - Salary calculation
  - Deductions and allowances
  - Payslip generation
  - Payment processing
  - Payroll history
  - Tax calculations

### 🎓 Training Program (`lib/pages/hr/training_program.dart`)
- **Purpose**: Employee training and development
- **Features**:
  - Training course management
  - Employee enrollment
  - Training schedules
  - Certification tracking
  - Course completion status

### 📋 Work Report (`lib/pages/hr/work_report.dart`)
- **Purpose**: Track employee work activities
- **Features**:
  - Daily/weekly work logs
  - Task completion reports
  - Productivity metrics
  - Work hour summaries
  - Project time allocation

### 🔧 Assets (`lib/pages/hr/assets.dart`)
- **Purpose**: Track company assets assigned to employees
- **Features**:
  - Asset inventory
  - Asset assignment to employees
  - Maintenance tracking
  - Asset depreciation
  - Asset return/disposal

---

## Finance Module

### 💳 Finance Dashboard (`lib/pages/finance/finance.dart`)
- **Purpose**: Main finance module dashboard
- **Features**:
  - Revenue summary
  - Expense overview
  - Budget status
  - Cash flow visualization
  - Key financial metrics

### 🧾 Invoice (`lib/pages/finance/invoice.dart`)
- **Purpose**: Invoice management
- **Features**:
  - Invoice creation
  - Invoice templates
  - Payment tracking
  - Invoice history
  - Invoice status (Draft/Sent/Paid)
  - Invoice numbering

### 💸 Payments (`lib/pages/finance/payments.dart`)
- **Purpose**: Payment tracking and processing
- **Features**:
  - Payment records
  - Payment status (Pending/Processed)
  - Payment methods
  - Payment reconciliation
  - Payment history

### 💰 Expenses (`lib/pages/finance/expenses.dart`)
- **Purpose**: Expense tracking and management
- **Features**:
  - Expense entry
  - Expense categorization
  - Expense approval workflow
  - Reimbursement processing
  - Expense reports

### 📊 Budget (`lib/pages/finance/budget.dart`)
- **Purpose**: Budget planning and tracking
- **Features**:
  - Budget creation
  - Department budgets
  - Budget allocation
  - Budget vs actual comparison
  - Budget forecasting

### 📃 Contract Payments (`lib/pages/finance/contract_payment.dart`)
- **Purpose**: Manage payments related to contracts
- **Features**:
  - Contract milestone payments
  - Payment schedules
  - Contract payment tracking
  - Payment invoice generation

---

## Operations Module

### 🏗️ Operations Dashboard (`lib/pages/operations/operations.dart`)
- **Purpose**: Main operations management hub
- **Features**:
  - Project overview
  - Active tasks summary
  - Contract status
  - Worksite management
  - Timeline tracking
  - Quick add buttons for projects, tasks, contracts

### 📁 Projects (`lib/pages/operations/projects.dart`)
- **Purpose**: List and manage all projects
- **Features**:
  - Project listings with filters
  - Project status (Planning/In Progress/Complete)
  - Budget tracking
  - Progress indicators
  - Project quick actions

### 🎯 Each Project (`lib/pages/operations/each_project.dart`)
- **Purpose**: Detailed project management view
- **Features**:
  - Project overview
  - Team members
  - Budget details
  - Timeline
  - Tasks and milestones
  - Associated worksites

### 📋 Project Details (`lib/pages/operations/project_detail.dart`)
- **Purpose**: In-depth project information and management
- **Features**:
  - Project metadata (client, service, budget, location)
  - Project progress tracking
  - Team collaboration
  - Document management
  - Meeting coordination
  - Equipment tracking

### 📌 Task (`lib/pages/operations/task.dart`)
- **Purpose**: Task list and management
- **Features**:
  - Task listings
  - Task status tracking
  - Task assignments
  - Priority levels
  - Due date management

### ✅ Task Details (`lib/pages/operations/task_detail.dart`)
- **Purpose**: Individual task details and updates
- **Features**:
  - Task description
  - Assigned team members
  - Subtasks
  - Attachments
  - Comments/notes
  - Status updates

### 🚧 Operation Task Details (`lib/pages/operations/operation_task_detail.dart`)
- **Purpose**: Operational task tracking
- **Features**:
  - Operational task specifics
  - Resource allocation
  - Time tracking
  - Completion status

### 📜 Contracts (`lib/pages/operations/contract.dart`)
- **Purpose**: Contract list and management
- **Features**:
  - Contract listings
  - Contract status tracking
  - Contract value
  - Timeline management
  - Contract documents

### 🔍 Contract Details (`lib/pages/operations/contract_detail.dart`)
- **Purpose**: Individual contract details
- **Features**:
  - Contract terms
  - Payment schedule
  - Associated projects
  - Involved parties
  - Attachments

### 📍 Work Sites (`lib/pages/operations/worksite_detail.dart`)
- **Purpose**: Manage project work sites
- **Features**:
  - Worksite location details
  - Site equipment tracking
  - Site personnel
  - Site documents
  - Site status

### 📅 Timeline (`lib/pages/operations/timeline_detail.dart`)
- **Purpose**: Project timeline management
- **Features**:
  - Milestone tracking
  - Gantt chart visualization
  - Timeline adjustments
  - Dependency management

---

## CRM Module

### 👥 CRM Dashboard (`lib/pages/crm/crm.dart`)
- **Purpose**: Main customer relationship management hub
- **Features**:
  - Clients overview
  - Leads pipeline
  - Interactions tracking
  - Revenue metrics
  - Charts (Bar, Pie, Line) for analytics
  - Quick actions for adding clients/leads

### 👤 Clients (`lib/pages/crm/clients.dart`)
- **Purpose**: Manage customer relationships
- **Features**:
  - Client listings
  - Client profiles
  - Contact information
  - Transaction history
  - Interaction logs
  - Client segmentation

### 🎯 Leads (`lib/pages/crm/lead.dart`)
- **Purpose**: Lead management and pipeline
- **Features**:
  - Lead listings
  - Lead status (New/Qualified/Negotiating/Won/Lost)
  - Lead value tracking
  - Lead conversion metrics
  - Lead assignment

### 💬 Interactions (`lib/pages/crm/interactions.dart`)
- **Purpose**: Track customer interactions
- **Features**:
  - Call logs
  - Email records
  - Meeting notes
  - Interaction timeline
  - Follow-up tasks

---

## Marketing Module

### 📢 Marketing Dashboard (`lib/pages/marketing/marketing.dart`)
- **Purpose**: Main marketing module hub
- **Features**:
  - Campaign overview
  - Lead generation stats
  - Content management
  - Marketing performance metrics
  - Quick actions for campaigns and leads

### 🎪 Campaign Details (`lib/pages/marketing/campaign_detail.dart`)
- **Purpose**: Individual campaign management
- **Features**:
  - Campaign description
  - Target audience
  - Budget allocation
  - Campaign status
  - Performance metrics
  - Lead generation

### 💌 Lead Details (`lib/pages/marketing/lead_detail.dart`)
- **Purpose**: Marketing lead information
- **Features**:
  - Lead contact details
  - Lead source
  - Lead interaction history
  - Lead conversion status
  - Lead value estimation

### 📍 Site Details (`lib/pages/marketing/site_detail.dart`)
- **Purpose**: Marketing site/location information
- **Features**:
  - Site information
  - Site performance
  - Site leads
  - Site-specific campaigns

---

## Services Module

### 🛠️ Services Dashboard (`lib/pages/services/services.dart`)
- **Purpose**: Main services management hub
- **Features**:
  - Services listing
  - Service leads management
  - Service invoices
  - Service orders
  - Quick service creation

### 🏘️ Real Estate (`lib/pages/services/real_estate.dart`)
- **Purpose**: Real estate service management
- **Features**:
  - Property listings
  - Property details
  - Client assignments
  - Service orders

### 📐 Land Survey (`lib/pages/services/land_survey.dart`)
- **Purpose**: Land surveying services
- **Features**:
  - Survey project listings
  - Property surveys
  - Survey reports
  - Measurement data

### 📊 Estate Management (`lib/pages/services/estate_management.dart`)
- **Purpose**: Manage real estate properties
- **Features**:
  - Property portfolio
  - Property details
  - Tenant management
  - Maintenance tracking

### 🏠 Estate Details (`lib/pages/services/estate_detail_page.dart`)
- **Purpose**: Individual estate/property details
- **Features**:
  - Property specifications
  - Tenant information
  - Lease details
  - Maintenance history
  - Property documents

### 📈 Estate Performance (`lib/pages/services/estate_performance_page.dart`)
- **Purpose**: Property performance analytics
- **Features**:
  - Rental income tracking
  - Occupancy rates
  - Maintenance costs
  - ROI calculations
  - Performance trends

### 📄 Real Estate Details (`lib/pages/services/real_estate_detail.dart`)
- **Purpose**: Real estate property information
- **Features**:
  - Property details
  - Client information
  - Service history
  - Associated invoices

### 🗺️ Land Survey Details (`lib/pages/services/land_survey_detail.dart`)
- **Purpose**: Survey project details
- **Features**:
  - Survey specifications
  - Site location
  - Survey data
  - Survey report

### 🏡 Land Survey Property Details (`lib/pages/services/land_survey_property_detail.dart`)
- **Purpose**: Property details for survey
- **Features**:
  - Property boundaries
  - Survey measurements
  - Property ownership
  - Survey history

### 🧮 Services Calculator (`lib/pages/services/services_calculator.dart`)
- **Purpose**: Calculate service costs
- **Features**:
  - Service cost estimation
  - Area calculations
  - Rate management
  - Quick quotes

### 📐 Land Survey Calculator (`lib/pages/services/land_survey_calculator.dart`)
- **Purpose**: Land survey calculations
- **Features**:
  - Area calculations
  - Distance measurements
  - Cost estimation for surveys
  - Rate tables

### 💰 Service Invoices (`lib/pages/services/service_invoices.dart`)
- **Purpose**: Invoice management for services
- **Features**:
  - Service invoice listings
  - Invoice generation
  - Payment tracking
  - Invoice history

### 🎯 Service Leads (`lib/pages/services/service_leads.dart`)
- **Purpose**: Track service inquiry leads
- **Features**:
  - Lead listings
  - Lead status tracking
  - Lead conversion
  - Lead source tracking

### 📋 Service Orders (`lib/pages/services/service_order.dart`)
- **Purpose**: Service order management
- **Features**:
  - Order creation
  - Order status tracking
  - Client assignment
  - Service details

### 🏗️ Service Details (`lib/pages/services/service_detail.dart`)
- **Purpose**: Individual service details
- **Features**:
  - Service description
  - Service pricing
  - Associated orders
  - Service history

### 🏠 Services Property (`lib/pages/services/services_property.dart`)
- **Purpose**: Property listings for services
- **Features**:
  - Property listings
  - Property details
  - Available services per property

### 🏘️ Property List (`lib/pages/services/property_list.dart`)
- **Purpose**: Complete property listings
- **Features**:
  - Property search/filter
  - Property details
  - Quick actions

### 📍 Property Details (`lib/pages/services/property_detail.dart`)
- **Purpose**: Individual property information
- **Features**:
  - Property specifications
  - Service history
  - Associated clients
  - Property documents

### 📤 Property Document Upload (`lib/pages/services/property_document_upload.dart`)
- **Purpose**: Upload property-related documents
- **Features**:
  - Document upload
  - Document categorization
  - Document storage
  - Document access control

### 📊 Generate Invoice (`lib/pages/services/generate_invoice_page.dart`)
- **Purpose**: Create service invoices
- **Features**:
  - Invoice template selection
  - Line item entry
  - Tax calculation
  - Invoice preview
  - Payment terms

### ✅ Payment Approval (`lib/pages/services/payment_approval.dart`)
- **Purpose**: Approve service payments
- **Features**:
  - Payment request review
  - Amount verification
  - Approval workflow
  - Payment authorization

### 👥 Service Clients (`lib/pages/services/clients.dart`)
- **Purpose**: Manage service clients
- **Features**:
  - Client listings
  - Client details
  - Service history
  - Contact information

---

## Legal Module

### ⚖️ Legal Dashboard (`lib/pages/legal/legal.dart`)
- **Purpose**: Main legal module dashboard
- **Features**:
  - Contracts overview
  - Compliance status
  - Legal cases tracking
  - Audits summary
  - Tab navigation for different sections

### 📄 Contracts (`lib/pages/legal/contract.dart`)
- **Purpose**: Legal contract management
- **Features**:
  - Contract listings
  - Contract status tracking
  - Contract value
  - Signatory information
  - Contract documents

### 📋 Compliance (`lib/pages/legal/compliance.dart`)
- **Purpose**: Regulatory compliance tracking
- **Features**:
  - Compliance requirements
  - Compliance status
  - Policy management
  - Audit trails
  - Remediation tracking

### ⚠️ Cases (`lib/pages/legal/cases.dart`)
- **Purpose**: Legal cases management
- **Features**:
  - Case listings
  - Case status
  - Case details
  - Associated documents
  - Court information

### 🔍 Audits (`lib/pages/legal/audits.dart`)
- **Purpose**: Legal audits and reviews
- **Features**:
  - Audit schedules
  - Audit findings
  - Audit reports
  - Remediation status
  - Audit history

### 📖 Detailed View (`lib/pages/legal/detailed_view.dart`)
- **Purpose**: Detailed information view for legal items
- **Features**:
  - Full document view
  - Related documents
  - Timeline
  - Notes/comments

---

## Security Module

### 🔒 Security Dashboard (`lib/pages/security/security.dart`)
- **Purpose**: Main security module dashboard
- **Features**:
  - Security overview
  - Security alerts
  - Access logs
  - Workflow approvals
  - Security codes
  - Page-based navigation (PageController)

**Pages/Slides:**
- **Overview Slide**: Security summary metrics
- **Alerts Slide**: Security alerts and incidents
- **Logs Slide**: Access and activity logs
- **Codes Slide**: Security code management (API keys, tokens)
- **Workflow Slide**: Approval workflows and access requests

---

## Analytics Module

### 📊 Analytics Overview (`lib/pages/analytics/overview.dart`)
- **Purpose**: Analytics dashboard with key metrics
- **Features**:
  - Key performance metrics cards
  - Responsive grid layout
  - Metric tracking
  - Visual analytics

### 📈 Performance Analytics (`lib/pages/analytics/performance.dart`)
- **Purpose**: Performance metrics and analysis
- **Features**:
  - Performance KPIs
  - Trend analysis
  - Department performance
  - Team performance

### 💰 Revenue Analytics (`lib/pages/analytics/revenue.dart`)
- **Purpose**: Revenue analysis and tracking
- **Features**:
  - Revenue trends
  - Revenue by source
  - Revenue forecasting
  - Historical comparison

### 🏗️ Projects Analytics (`lib/pages/analytics/projects.dart`)
- **Purpose**: Project-related analytics
- **Features**:
  - Project completion rates
  - Project profitability
  - Project timeline analysis
  - Project resource utilization

---

## Clients Portal

### 🔗 Client Portal (`lib/pages/clients_portal/portal.dart`)
- **Purpose**: Client-facing portal for project updates
- **Features**:
  - Client access management
  - Project analytics view
  - Shared documents
  - Communications
  - Page-based navigation (PageController)

**Portal Sections:**
- **Client Access**: View assigned projects
- **Analytics**: Project performance metrics
- **Communications**: Messages and updates
- **Shared Documents**: Access to project documents

---

## Employee Module

### 👨‍💼 Employee Management (`lib/pages/employee/employee.dart`)
- **Purpose**: Main employee management hub
- **Features**:
  - Quick navigation to employee functions
  - Employee directory
  - Attendance tracking
  - Performance reviews
  - Training programs

### 📇 Employee Directory (`lib/pages/employee/employee_directory.dart`)
- **Purpose**: Employee listings and search
- **Features**:
  - Employee search
  - Employee filters
  - Contact information
  - Department view

### 📅 Employee Attendance (`lib/pages/employee/employee_attendance.dart`)
- **Purpose**: Attendance tracking and reports
- **Features**:
  - Attendance records
  - Attendance statistics
  - Attendance history
  - Absent reports

### ⭐ Employee Performance (`lib/pages/employee/employee_performance.dart`)
- **Purpose**: Performance tracking
- **Features**:
  - Performance ratings
  - Review history
  - Performance trends
  - Goal tracking

### 🎓 Employee Training (`lib/pages/employee/employee_training.dart`)
- **Purpose**: Employee training management
- **Features**:
  - Training enrollment
  - Training progress
  - Certification tracking
  - Training history

### 📋 Employee Database (`lib/pages/employees_database/employee_database.dart`)
- **Purpose**: Centralized employee database
- **Features**:
  - Complete employee listings
  - Employee search and filters
  - Bulk actions
  - Employee import/export
  - Database management

### ➕ Add New Employee (`lib/pages/employees_database/add_new_employee.dart`)
- **Purpose**: Employee registration
- **Features**:
  - Employee form creation
  - Personal information entry
  - Professional details
  - Document upload
  - Employment terms

### 👤 Employee Profile (`lib/pages/employees_database/employee_profile.dart`)
- **Purpose**: Individual employee profile
- **Features**:
  - Personal information
  - Professional information
  - Work history
  - Documents and certifications
  - Task assignments
  - Notes

---

## Company Module

### 🏢 Company Profile (`lib/pages/company/company.dart`)
- **Purpose**: Company information management
- **Features**:
  - Company details
  - Contact information
  - Assets overview
  - Branch management
  - Quick edit options

### 🏭 Branch (`lib/pages/company/branch.dart`)
- **Purpose**: Branch/office management
- **Features**:
  - Branch listings
  - Branch details
  - Branch employees
  - Branch contact info

### 📊 Compliance (`lib/pages/company/compliance.dart`)
- **Purpose**: Company compliance tracking
- **Features**:
  - Compliance checklist
  - Certification tracking
  - Regulatory requirements
  - Audit reports

### 📝 Audit Log (`lib/pages/company/audit_log.dart`)
- **Purpose**: System audit trails
- **Features**:
  - User activity logs
  - Data change tracking
  - Access logs
  - Timestamp records

---

## Workspace Module

### 🖥️ Virtual Workspace (`lib/pages/workspace/workspace.dart`)
- **Purpose**: Collaborative workspace for teams
- **Features**:
  - Workspace overview
  - Team collaboration tools
  - Workspace stats
  - Quick links

### 📊 Workspace Dashboard (`lib/pages/workspace/workspace_dashboard.dart`)
- **Purpose**: Workspace analytics and management
- **Features**:
  - Workspace metrics
  - Resource allocation
  - Team activity
  - Productivity tracking

---

## Events Module

### 📅 Events (`lib/pages/events/events.dart`)
- **Purpose**: Company event management
- **Features**:
  - Event calendar
  - Event listings
  - Event details
  - Event RSVP
  - Event notifications

---

## Additional Pages & Features

### 🏘️ Branch Management (`lib/pages/branch/branch.dart`)
- **Purpose**: Multi-branch company management
- **Features**:
  - Branch listings
  - Branch details
  - Branch hierarchy
  - Inter-branch operations

### 👥 Clients Database (`lib/pages/client/clients_database.dart`)
- **Purpose**: Centralized client information
- **Features**:
  - Client listings
  - Client search
  - Client profiles
  - Contact management

---

## Navigation Structure

All pages are integrated through:
- **Router Config**: `lib/src/app_routes/app_router.dart`
- **Route Constants**: `lib/src/app_routes/app_route_constants.dart`
- **Sidebar Navigation**: `lib/components/nav/side_menu.dart`

### Navigation Patterns
- Main modules use **StatefulShellRoute with indexed stack navigation**
- Detail pages use **named routes** for deep linking
- Bottom-level pages use **go_router context.go()** for navigation

---

## Summary

**Total Pages/Modules**: 50+ major pages

**Key Statistics**:
- **HR Module**: 13 pages
- **Finance Module**: 6 pages
- **Operations Module**: 8 pages
- **CRM Module**: 4 pages
- **Marketing Module**: 4 pages
- **Services Module**: 17 pages
- **Legal Module**: 5 pages
- **Analytics Module**: 4 pages
- **Security Module**: 1 main + 5 slides
- **Clients Portal**: 1 main + 4 slides
- **Supporting Modules**: Employee (8), Company (4), Workspace (2), Events (1)

---

*Last Updated: November 2024*
*Auto-generated Pages Catalog for Bomach OS*
