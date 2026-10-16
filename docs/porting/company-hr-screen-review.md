# Company and HR Screen Review

This is the working screen-by-screen behavior record for the initial 32-route port scope. It is built from the current Flutter source and, where the test deployment permits access, a live comparison. It is a parity reference, not a redesign specification. Keep each route's observed behavior separate from decisions we make to improve consistency in React.

## Review status

- **In scope:** 15 Company sidebar routes and 17 HR/Admin sidebar routes.
- **Reviewed:** Company Profile has an initial source pass. Its deployed data and populated visual state could not be checked because the test session expired.
- **Candidate source trace:** HR/Admin Employees is a recommended pilot candidate; its list/detail/form flow has an initial source trace below, but is not yet a parity-complete review or approved pilot.
- **Not reviewed yet:** the remaining 30 routes.
- **Implementation:** not started.

Status meanings:

- **Not reviewed** — no detailed page pass yet.
- **Candidate source trace** — initial source inspection identifies a possible pilot and its risks; missing details and user choices remain before implementation.
- **Source pass** — route and Flutter behavior recorded, with live or edge-case checks still open.
- **Parity reference complete** — normal, empty, loading, error, success, permission, form, navigation, and responsive states have sufficient evidence to implement.
- **Blocked** — a specific external dependency prevents further review; record what can still be learned from source.

## In-scope route tracker

| Header | Sidebar destination | Flutter route | Review status |
| --- | --- | --- | --- |
| Company | Profile | `/company` | Source pass — see review below; populated deployment state blocked by expired session |
| Company | Branch | `/company/branch` | Not reviewed |
| Company | Board | `/company/board` | Not reviewed |
| Company | Broadcast | `/company/broadcast` | Not reviewed |
| Company | Roles & Permissions | `/company/roles` | Not reviewed |
| Company | Org Chart | `/company/org-chart` | Not reviewed |
| Company | KPI Management | `/company/kpi-management` | Not reviewed |
| Company | OKR Board | `/company/okr-board` | Not reviewed |
| Company | Compliance Dashboard | `/company/compliance` | Not reviewed |
| Company | Knowledge Base | `/company/knowledge-base` | Not reviewed |
| Company | Approval Workflows | `/company/approval-workflow` | Not reviewed |
| Company | Workspace Approvals | `/company/workspace-approvals` | Not reviewed |
| Company | Departments & Units | `/company/department` | Not reviewed |
| Company | Assets | `/company/assets` | Not reviewed |
| Company | Audit Log | `/company/audit-log` | Not reviewed |
| HR/Admin | Employees | `/hr/employees` | Candidate source trace — pilot recommendation; full screen/form and deployed-state review still needed |
| HR/Admin | Attendance | `/hr/attendance` | Not reviewed |
| HR/Admin | Work Calendar | `/hr/attendance-calendar` | Not reviewed |
| HR/Admin | Recruitment | `/hr/job-post` | Not reviewed |
| HR/Admin | My Leaves | `/hr/leaves` | Not reviewed |
| HR/Admin | Leave Requests | `/hr/leave-request` | Not reviewed |
| HR/Admin | Training | `/hr/training-program` | Not reviewed |
| HR/Admin | Loans | `/hr/loans` | Not reviewed |
| HR/Admin | Benefits | `/hr/benefits` | Not reviewed |
| HR/Admin | Performance | `/hr/performance-review` | Not reviewed |
| HR/Admin | Work Reports | `/hr/work-report` | Not reviewed |
| HR/Admin | Monthly Scorecard | `/hr/monthly-scorecard` | Not reviewed |
| HR/Admin | Awards & Recognition | `/hr/awards-recognition` | Not reviewed |
| HR/Admin | Performance Leaderboard | `/hr/performance-leaderboard` | Not reviewed |
| HR/Admin | Employee Evaluation | `/hr/employee-evaluation` | Not reviewed |
| HR/Admin | Disciplinary Process | `/hr/disciplinary-process` | Not reviewed |
| HR/Admin | Performance Engine | `/hr/performance-engine` | Not reviewed |

## Company Profile — initial source pass

### Route and ownership

- **Sidebar:** Workspace → Company → Profile.
- **Path:** `/company` (deployed URL fragment: `#/company`).
- **Flutter destination:** `CompanyProfilePage`, rendered by the Flutter router.
- **Page source:** [company.dart](/home/kachy/project/bomach/bomach_os/lib/pages/company/company.dart).
- **Related source:** [company_controller.dart](/home/kachy/project/bomach/bomach_os/lib/pages/company/controllers/company_controller.dart), [edit_company_dialog.dart](/home/kachy/project/bomach/bomach_os/lib/pages/company/widget/edit_company_dialog.dart), [shareholders_dialogs.dart](/home/kachy/project/bomach/bomach_os/lib/pages/company/widget/shareholders_dialogs.dart), [board_members.dart](/home/kachy/project/bomach/bomach_os/lib/pages/company/board_members.dart), [compliance.dart](/home/kachy/project/bomach/bomach_os/lib/pages/company/compliance.dart), and [company_service.dart](/home/kachy/project/bomach/bomach_os/lib/src/services/company_service.dart).
- **Entry permission:** `company_settings:view` or `company_settings:update` is listed for this route. The Company sidebar item also declares the company-settings resource. The router checks route permissions as an OR set. Profile and Global Business edit actions are not individually wrapped in an update permission gate in this page; verify the intended view-only experience and backend response during role testing.
- **Page organization:** the five tabs below are local state within `/company`; changing tabs does not change the URL and the initial tab is Profile. They are not separate deep-linkable routes.

### Page map

```text
Company > Profile (/company)
├─ Profile
│  ├─ Edit Profile dialog
│  └─ Refresh company profile
├─ Global Business
│  └─ Edit Global Business Settings dialog
├─ Ownership & Shareholders
│  ├─ Edit Shareholders dialog
│  ├─ Add/Edit Shareholder dialog
│  ├─ Authorized shares dialog
│  └─ Delete confirmation
├─ Board Members
│  ├─ Search / add / edit / delete board-linked shareholders
│  └─ Add/Edit Shareholder dialog (board member preset)
└─ Compliance & Registration
   ├─ Search / pagination
   ├─ New/Edit Compliance dialog
   └─ Delete confirmation
```

These are tabs and dialogs, not route entries. Board Members uses the same shareholder collection and marks board members through shareholder data. Compliance & Registration embeds `CompliancePage` and loads its own list.

### What the page displays

- Header title **Company Profile**, subtitle **Organization identity, governance, and operating defaults.** Header action depends on the selected tab: **Edit Profile**, **Edit Settings**, or **Edit Shareholders**; no header action is defined for Board Members or Compliance & Registration.
- Four dashboard statistic cards: **Total Employees**, **Total Branches**, **Pending Approvals**, and **Asset Inventory**. While that query loads, the page shows stat skeletons. If the query fails, the cards fall back to `--` and explanatory subtext; this separate query has no visible error/retry state.
- **Profile:** brand/logo and company identity hero; company information; identity details (name, industry, slogan, address) and contact/registration details (email, phone, RC number, updated and created dates). Has an inline Edit Profile action and Refresh.
- **Global Business:** brand palette; regional defaults (currency, language, timezone, punctuality time); governance rules, approval-flow and notification-channel indicators.
- **Ownership & Shareholders:** authorized, issued, and unissued share totals; shareholder register and actions. Board-member count is derived from the same shareholder list.
- **Board Members:** searchable subset of shareholders marked as board members, with add/edit/delete actions.
- **Compliance & Registration:** compliance register with search by type/reference/authority (the controller also matches name, status, and description), locally paginated rows, expiry/status presentation, and a permission-gated **New Compliance** action.
- **Responsive behavior from source:** page content max width is 1440px; the company tab strip scrolls horizontally; hero/cards adapt at width breakpoints. Source uses compact layouts below 980px, 900px, and 760px depending on the section. Exact narrow-screen parity still needs a live comparison.

### Loading, empty, error, and success behavior observed in Flutter

| Situation | Current Flutter behavior | Porting note |
| --- | --- | --- |
| Primary company data loading | Card, stat-row, and card skeletons while settings are absent. | Preserve the visible layout; confirm skeleton dimensions in the reference. |
| Primary company query fails with no data | Page-level EmptyState titled **Could not load company profile**, shows the controller's exception text as subtitle, and offers **Retry**. | Error placement is appropriate for a failed primary load, but raw exception text is exposed. Standardize safe wording and session-expiry handling under the agreed error policy. |
| Stats query fails | Failure is only logged; stat cards display `--`. No retry or section error. | Review whether parity requires preserving this quiet fallback or a visible section-level retry. |
| Choices/shareholders query fails | Failure is only logged. The relevant tabs may not distinguish a failed load from an empty result. | Need to inspect the populated and failed tab states; this is an important state-model gap. |
| Compliance list loading | List skeleton while loading with no filtered records. | Exact loading-to-empty/error transitions need live check. |
| Compliance list fails without rows | Inline error state with Retry. With existing rows, an inline error appears above stale results. | Record as stale-data behavior; align with shared section-error policy. |
| Company profile/global settings save succeeds | Optimistically updates local settings, awaits the three update requests, closes dialog, then shows **Settings updated successfully** toast. | Success is backend-confirmed only if all requests succeed. Current optimistic state is not visibly rolled back on failure. |
| Company profile/global settings save fails | Dialog stays open and an **Update Failed** alert dialog displays `e.toString()`. | Raw error detail; proposed shared form alert should preserve draft and map field errors. Whether to restore optimistic data needs a decision. |
| Logo upload fails | Shows a toast with raw upload error, then continues to attempt the settings update using the previous logo URL. | Possible partial outcome and misleading subsequent success; verify intended behavior before porting. |
| Compliance create/update/delete | On success the list is refreshed and a success toast is shown; errors are shown in a toast with exception text. | A form submission failure currently has no persistent form-level error. |
| Shareholder/equity actions | Mutations show toast feedback. Authorized shares fall back to secure local storage when the equity API is unavailable or no token exists. | Local persistence is per-device/user context and may not represent shared company state; confirm whether this fallback remains valid. |

The test deployment was open in Edge at `https://bomach-os-test.web.app/#/company`, but displayed **Could not load company profile** and `Exception: Token has expired. Try to login again.` with Retry. The route shell/title/error was visible; populated company data, role-specific controls, and normal-flow screenshots could not be verified. The expired state is captured as a reference finding, not the expected normal page design.

### Forms and actions

- **Edit Profile dialog:** Company Name*; Slogan; Industry; RC Number; Company Email; Company Phone; Company Address; logo picker. The required marker appears on Company Name, but this dialog has no enclosing `Form` or field validators in the inspected source. Industry is held in controller state and is not part of the `CompanySettings` payloads sent to the backend.
- **Edit Global Business Settings dialog:** primary/secondary color codes; currency and language choices; timezone; punctuality time picker; approval-level controls; Email/SMS/Push notification controls; GDPR/CCPA data preference controls; business rules. The save method persists colors, currency, language, business rules, and punctuality time through profile settings update. Timezone is changed in controller memory only. Approval, notification, and data-preference controls are not included in the update call (source comment says toggles are handled locally); confirm which are intended to persist.
- **Compliance dialog:** create/edit form with typed compliance category, contact and registration fields, issue/expiry dates, authority, priority, cost, and description. It uses a `Form` and validators; exact field requirements and date rules should be transcribed while reviewing this flow for implementation.
- **Shareholder and board forms:** share register edit, add/edit shareholder, equity value, and destructive delete confirmation. Review validations, duplicate constraints, and failure retention in a follow-up pass before implementing.

### API and data dependencies

The Flutter `CompanyService` owns a Dio client and sends Bearer auth. On `CompanyController.onInit`, five independent loads begin: company settings, field choices, dashboard stats, shareholders, and equity. The settings fetch merges three responses:

| Purpose | Method and path | Use |
| --- | --- | --- |
| Core profile | `GET` and `PUT /api/v1/company/company/profile` | Name, email, phone, address, RC number, created/updated metadata. |
| Branding | `GET` and `PUT /api/v1/company/company/branding` | Logo, primary/secondary colors, slogan. |
| Preferences | `GET` and `PUT /api/v1/company/company/preferences` | Currency, language, business rules, punctuality time. |
| Company field choices | `GET /api/v1/company/company/choices` | Currency/language choices for the settings form. |
| Dashboard summary | `GET /api/v1/stats/dashboard` | Four statistic cards. |
| Shareholder register | `GET /api/v1/shareholders/?limit=100&offset=0`; create/update/delete under `/api/v1/shareholders/` | Ownership and board-member tabs. |
| Compliance register | `GET`, `POST /api/v1/compliance/compliance-records`; update/delete on `/{id}` | Compliance tab. |
| Authorized shares | Equity service method plus secure-storage fallback (`authorized_shares`) | Equity stats and editing. Endpoint/fallback behavior needs contract verification. |

Profile settings update sends three PUT requests in parallel and merges the results. This is not evidently an atomic backend operation: a partial failure may leave some resources updated and others rejected. Verify server behavior and recovery before deciding the React mutation strategy. The Flutter Dio timeout is 15 seconds for connect and receive. The React implementation should use the already agreed shared Fetch client; feature modules should own endpoint contracts rather than creating new transport clients.

### Questions to settle before implementation

1. Which `company_settings` permission should be required to enter, view, and edit this route? Should the form actions disappear/disable for view-only users?
2. Are Industry and timezone meant to be shared backend values? Are approval level, notification channels, and GDPR/CCPA preferences expected to persist? If so, what are the current authoritative contracts?
3. What is the intended behavior when one of the three profile/branding/preferences updates succeeds and another fails? Can the backend provide an atomic update or a read-back recovery contract?
4. Is local-only authorized-share storage intentional, or should the company-wide value always require the equity API?
5. Can the expired test session be renewed so we can capture populated/empty behavior and responsive visual references at the agreed viewport widths?

## HR/Admin Employees — pilot candidate source trace

This is the migration plan's recommended pilot candidate, not a user-approved route selection. It appears to exercise list/detail navigation, server paging and search, permissions, loading/error/empty states, a multi-step form, lookups, image upload, and employee status actions. It also contains sensitive personal and compensation data, so the full form and access rules need review before implementation.

### Route and current layout

- **Sidebar:** People → HR/Admin → Employees.
- **Path:** `/hr/employees`; page widget `EmployeeDatabase` in [employee_database.dart](/home/kachy/project/bomach/bomach_os/lib/pages/hr/employee_database.dart).
- **Related sources:** [employees_controller.dart](/home/kachy/project/bomach/bomach_os/lib/pages/hr/controller/employees_controller.dart), [employees_services.dart](/home/kachy/project/bomach/bomach_os/lib/src/services/employees_services.dart), [employees_model.dart](/home/kachy/project/bomach/bomach_os/lib/src/model/employees_model.dart), [add_new_employee.dart](/home/kachy/project/bomach/bomach_os/lib/pages/hr/widget/add_new_employee.dart), [employee_profile.dart](/home/kachy/project/bomach/bomach_os/lib/pages/hr/employee_profile.dart), and the suspend/exit dialogs.
- **Header:** title **Employee Directory**; subtitle **Manage active team members, alumni, and their employment details.** Header actions are Job Postings (currently an empty callback) and permission-gated Add Employee.
- **List content:** Total Employees and Contract Staff cards; Active and Past (Alumni) tabs; search by name, id, or designation; page sizes 5, 10, 20, and 50; employee count; status/type chips; View and more-actions menus.
- **Responsive behavior:** employee rows become cards below 980px; stats stack below 700px; toolbar stacks below 720px. These content-specific cutovers differ from the global shell thresholds and need live comparison at adjacent widths.
- **Navigation:** View pushes `EmployeeProfile(e: emp)` as an in-memory Flutter page. The router also registers `/hr/employees/profile`; confirm which entry path and URL behavior must be preserved. The profile page is not necessarily a separate browser route in every current list interaction.

### Data and state behavior seen in source

- The controller loads departments, branches, up to 500 employees for the reporting-to selector, roles, and the paged list in parallel. Individual lookup failures are logged and generally leave the form without that lookup data.
- The list endpoint sends `is_active`, `search`, `limit`, and `offset`. Search waits 500ms, resets to page one, and refetches. Changing active/alumni tab and page size also resets pagination.
- Initial list loading renders six skeleton rows. A request error renders **Something went wrong**, the controller's error string, and Retry. An empty response renders **No employees found** plus Add Employee when permitted. Existing list data and stale-data refresh behavior need a live/source pass before mapping to the shared states.
- A missing access token causes the controller to return without loading the list; it does not itself route to login or show an auth-expired state. The web-session behavior must be defined by the shared auth contract.
- The create/edit dialog has four steps: Personal Info, Contact Address, Employment, and Compensation. It includes employee identity/contact details, emergency contact, role/department/unit/branch/level/reporting-to selectors, employment status/type, schedule and dates, salary, bank/tax/pension details, HMO details, and profile image upload.
- The list exposes View, Edit Details, Suspend Employee, Activate Employee, Deactivate, and Exit/Offboard actions. The current page's Add action is gated by `employees:create`; entry is gated by `employees:list`; the registered profile path allows `employees:view` or `employees:view_own`. Row-level edit and status actions are not visibly gated in this page source, so action permissions need verification.
- The form calls `FormState.validate()`, but the inspected file contains no field `validator:` definitions; email is checked manually only at final save. The create form initializes the password controller with the literal `Password@123`. The controller logs full create/update payloads, which can include personal, bank, tax, pension, and salary data. Do not carry the hard-coded credential or sensitive payload logging into the React implementation; confirm the intended password-setup flow and preserve the user's visible workflow while applying the agreed security standard.
- Save failures currently pass exception text into a dialog; missing-token returns silently. Image upload failure returns `null` and the employee save continues without the new image. Review the intended partial-upload message and draft-retention behavior.

### API evidence and remaining checks

The Flutter service uses `GET` and `POST /api/v1/employees/employees`, `GET` and `PUT /api/v1/employees/employees/{user_id}`, and `POST /api/v1/employees/exit/{user_id}`. List parameters include active status, employment type, department, branch, search, offboarded, date-of-birth sort, limit, and offset. Its decoder accepts an `items` collection plus `count`; the checked-in root `openapi_schema.json` describes a paged employee response and JWT security. The spec's currentness and exact request/response/error shapes have not yet been verified against the live backend.

Before porting this candidate, finish the four-step form field/validation inventory; confirm route and action permissions; verify whether create credentials are set through invitation, an initial-password flow, or another verified contract; reconcile the checked-in schema with the API; inspect populated/empty/error states against the test deployment if a session becomes available; and establish browser auth/session and file-upload behavior. Do not submit or persist test employee or compensation data during review.

## Template for each next route

Copy this section for each route after Company Profile:

```markdown
### <Route title> — `<path>`
- Sidebar location / Flutter widget / source files:
- Entry and action permissions:
- Related routes, tabs, dialogs, and return navigation:
- Main content, filters, actions, uploads, and dependent lookups:
- API methods, request/response contracts, and backend evidence:
- Loading / empty / stale-data / section-error / page-error states:
- Form fields, client validation, server field errors, pending, success, and failure:
- Responsive layout and reference captures at 375 / 600 / 900 / 1280 / 1600px; 320px/zoom and relevant breakpoint-edge notes:
- Browser capabilities:
- Unknowns / decisions for the user:
- Review status:
```

Keep user-approved product decisions in `decisions.md`, cross-route behavior in `interaction-standards.md`, and implementation sequence in `migration-plan.md`. This review file records what the current Flutter code actually does and the evidence still needed.
