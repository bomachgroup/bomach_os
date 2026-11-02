# HR Workforce and Role Administration

## Scope and routes

- `/company/roles` is the searchable, paginated Roles & Permissions directory.
- `/company/roles/$roleId` is the durable role detail route. It preserves the selected record in the URL instead of relying on router memory.
- `/hr/employees` is the searchable employee directory with Active and Past views, branch and department filters, and pagination.
- `/hr/employees/$userId?section=...` is a durable employee profile route. The selected section is URL-owned.
- `/hr` remains the permission-scoped HR Dashboard and is verified as part of this slice.

The implementation follows the shared React page header, compact mobile header action, dialog, loading/error/empty, toast, and URL state patterns. Role and employee list queries retain cached rows while a new filter/page loads; retries stay with the failed area. Successful writes invalidate the smallest relevant list, detail, lookup, or dashboard query families.

## Roles & Permissions

### Directory and access

- The directory uses `roles:list`; role details use `roles:view`. The sidebar destination now requires the same list permission as the directory route and API.
- Create, update, and delete actions are gated independently by their matching `roles` permission. Branch assignment is saved as `branch_ids`.
- Role cards use a two-line mobile-safe title, branch scope, granted-action count, and a right-aligned View/Edit/Delete action group. The View action opens the durable detail route. At narrow phone widths, actions share an equal three-column row while retaining their text labels.
- The create/edit editor is a guided flow: Role details (name and branch scope), Responsibilities (optional purpose/responsibilities/job description when authorized), Permissions, and a final Review before save. Users without description access omit Responsibilities and do not receive description fields in the write payload.
- Permission selection follows the Review summary’s resource-card layout: each resource has a compact bordered card with its name and wrapping action chips. Every chip includes its action icon, uses a neutral tone when unselected, and uses the shared semantic action color when selected. Hovering or focusing a chip reveals its permission guidance. Resource cards and their action chips sort hierarchically by name for A–Z/Z–A; assigned-first remains available, and selected-only filtering preserves the chosen order. The sort preference is stored in browser local storage and defaults safely to A–Z when missing or invalid. The shared Bomach `DropdownSelect` controls work-area and order filters. Search, select-visible, and clear-visible operate on the currently filtered permissions. The Review step presents selected access in a bounded, internally scrollable panel with area/resource grouping and matching icon-led action chips.
- Branch choices must load before the details step can advance, and the permission map must load before a role can be saved. Both lookup failures offer an in-dialog retry and keep the draft intact, preventing a temporary branch-choice failure from silently saving company-wide access. Role name validation runs before advancing; save errors keep the flow and draft open.
- Description reads/writes require the corresponding `role_descriptions` permission. Existing descriptions require view and update access; they are kept separate from the role request for users who cannot read or edit them.
- A create or update that includes a description requires both the role permission and its matching description permission. Role and description are saved in one database transaction. Existing Flutter requests without descriptions retain their original request shape.
- A deletion is confirmed in the UI; API errors leave the dialog open and explain the blocked delete.

### Detail sections

The detail page includes Overview, Org Chart, Career Path, KPIs, Targets, Performance Analytics, Task Templates, SOPs, Daily Work Routine, Training, Success Playbook, and Resources. The duplicate Authority Limits detail tab is omitted until the backend provides role-scoped amount/quantity limits. The Flutter detail widget receives no limit records, and `/roles/me/authority-limits` only flattens the signed-in employee's permission grants, which are already represented in Overview. The standalone Flutter Authority Limits page is not an active route and its CRUD service paths have no matching backend routes. This keeps the detail page from presenting grants twice or promising unsupported limits.

Org Chart combines the reporting chain and direct reports. Career Path and each role-standard section use the corresponding role-scoped list/create/update/delete endpoints. Role-choice and enum selectors use the shared Bomach `DropdownSelect` control and shared typography; role choices show loading, retry, and unavailable states instead of silently submitting an ID. Performance Analytics uses only employee and scorecard/review endpoints the caller can access; unavailable employee scores remain unscored.

The selected role section is URL-owned in the `tab` search parameter. A new visit without a valid `tab` starts on Overview; reloads and successful edits on the same detail route keep the current section. Role tabs follow the employee profile's responsive grid and keyboard pattern: two columns on phones, three on tablet widths, and four on desktop widths.

Performance Analytics loads its employee and review data only while that tab is active. It shows active team size, scorecard coverage for the current month, average among scored employees, reviews on file, and alphabetized employee rows. The React scorecard request sets `generate_if_missing=false`: an absent monthly scorecard stays absent and is shown as **Not scored** instead of being generated by a read. The backend keeps its legacy default (`true`) for existing Flutter clients. A missing individual scorecard is an expected state; network/server failures remain retryable errors scoped to analytics.

## Employees

### Directory, forms, and profile

- Employee list entry requires `employees:list`; profile entry allows `employees:view` or `employees:view_own`. Create, edit, status changes, exit, document, review, plan, task, and work-report actions each use their own resource/action permissions.
- The five-step form is Identity, Contact, Employment, Compensation, and Review. Review covers all entered sections, masks bank/statutory identifiers, and links back to each step without losing the draft. Create and edit save only from Review. It does not ask HR to enter a password. Assignment uses loaded branch, department, role, manager, and selected-department unit choices rather than asking for database IDs.
- Active/Past filtering follows the Flutter `is_active` view contract. The backend derives explicit employment-active state from `employment_status` (`active`, `on-probation`, and `on-leave` count as active); legacy `is_active` remains for Flutter compatibility. Past includes `inactive`, `suspended`, and `terminated`, even for older terminated records without an `offboard_date`.
- The directory uses a compact two-option status tab group, shared Bomach dropdowns for branch, department, and page size, and keeps branch and department filters side by side at all supported widths. Employee cards put status at the top right and right-align actions in a separate footer. The cards stay one per row below the desktop breakpoint and use two columns from 1100px upward. Up to three available actions stay visible; when four or more exist, two primary actions remain visible and the rest move to an accessible ellipsis menu.
- The employee profile provides Profile, Documents, Reviews, Benefits, Performance Plan, Activity, Tasks, and Work Reports when the relevant permission is available.
- Profile section tabs use a responsive two/three/four-column grid and support tab keyboard navigation. The profile's back control reuses the shared page-back link pattern. All section dropdowns and date fields use the shared controls. A manager's raw database ID is not rendered in the Profile tab. Task queries are keyed by target account ID and use the backend's employee-scoped endpoint; work reports continue to filter by Employee-record ID.
- Work-report cards link to the HR review queue at `/hr/work-report?reportId=<report-id>`. Keep this exact ID-based deep link in future HR Work Reports UI changes; the queue must preserve the selected ID in URL state, load the same report, and enforce the backend's `work_reports:view`, `approve`, and `reject` permissions and branch scope.
- The React Tasks route `/dashboard/my-tasks` is self-scoped. It may be linked from an employee profile only when the profile belongs to the signed-in employee. There is no React HR task-management route yet, so do not link another employee's task to the signed-in user's list or invent an HR URL. When the HR task workstation is ported, add an `Open HR tasks` destination and task-ID deep links from employee cards; preserve HR filters/selected-task URL state, enforce task permissions and branch scope, and verify that assignment/detail workflows match the employee-profile links.
- Benefits display salary and allowance amounts as NGN using `Intl.NumberFormat`; allowances remain individual labeled values instead of raw JSON. The Compensation step edits Housing, Transport, and Meal as optional non-negative NGN amounts and maps them to the existing `allowances` JSON object at the API boundary. When editing an employee, unexposed allowance categories are retained so the form does not discard backend data. Profile documents show compact responsive file cards and retain the existing upload size/type contract.
- HR users authorized for `employees:list` and `employees:view` retain the current approved access to compensation, bank, tax, pension, HMO, and personal fields. React visibility is not treated as an authorization boundary; the API still checks permission and branch scope.

### Status, exit, upload, and review contracts

- Employee status and login state are distinct fields: `employment_is_active`, `account_is_active`, and legacy `is_active`. Suspending/deactivating disables both records; activating restores both; on leave keeps the login enabled.
- Exit requires `employees:exit`, accepts today or a past date, records reason and date, sets employment status to `terminated`, and disables the employee and login records. Future dates are rejected.
- Document upload requires `employee_documents:upload`, uses image/PDF/Word picker types supported by Flutter, and enforces the existing 15 MB limit. The React flow does not ask users to type document URLs.
- Review subresources consistently identify an employee by `user_id`; branch-out-of-scope mutations are hidden as not-found.
- New employee onboarding lets the backend generate the initial password. The local environment uses Django's console email backend; the browser create flow is not submitted because it would print a generated credential to the local server console. Automated create-flow tests mock the welcome-email function and use an isolated Django test database.

## HR Dashboard

`/hr/dashboard/overview` remains the single React dashboard source. Each metric is omitted when the matching permission is absent, and employee/request data is limited to the caller's branch scope. “New hires this month” is counted from `Employee.start_date` within the current calendar month. Employee headcount and department totals use canonical employment status rather than a potentially stale legacy active boolean.

The dashboard presents active headcount, current-month hires, open roles, pending leave requests, up to five department counts, and a bounded pending leave/absence/late-arrival review queue. It does not fabricate metrics for missing backend fields.

## Data lifecycle and cross-screen contracts

- Employee profile section data is fetched only for the active URL-owned section. Cached section data remains visible during a stale refresh; query failures and retries stay within that section. Profile edits invalidate employee detail and directory queries. Document upload/delete invalidates the document list. Review create/update/delete invalidates employee reviews and the performance-review summary. Benefits are read-only in this profile surface.
- The HR Work Reports queue uses `standard` freshness (60 seconds), refetches on focus/reconnect when stale, and does not poll. Approval/rejection invalidates work-report lists/details and the HR overview only after backend success. The employee profile's report link is an integration contract, not a decorative shortcut; keep it tested against `/hr/work-report?reportId=<id>`.
- Employee tasks use the employee-scoped task query and no polling. They are read-only on this profile. The existing `/dashboard/my-tasks?task=<id>` destination is only valid for the signed-in employee's own tasks. A manager-facing HR task list/detail route remains a React porting gap; keep the profile read-only for other employees until that route exists.
- HR-managed leave is represented by a separate leave-period record; employee-created Leave Requests remain a separate request-and-approval workflow. Starting leave requires a start date, leave type, and reason. An expected return date is optional and prompts HR only; it never changes employment status automatically. Indefinite leave requires a reason and a review reminder. The explicit `Return from leave` action records the actual return date and restores the employment status captured when leave began. It never changes the employee's login/account-active state, so a separately suspended account stays suspended. Leave remains distinct from suspension, deactivation, and termination.

## Freshness and failure handling

| Data                                                | Freshness                                  | Trigger and behavior                                                                                     |
| --------------------------------------------------- | ------------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| Roles and employee directory                        | `standard` (60s)                           | Revalidate on route entry, focus, and reconnect when stale; retain previous rows while fetching.         |
| Role/employee details and history lists             | `history` (120s) or `standard` per section | Load only for the selected detail/section; retry stays local.                                            |
| Branch, department, role, manager, and unit choices | `reference` (300s)                         | Load only while an editor is open or a role section needs them; choice failure does not erase the draft. |
| HR Dashboard summary                                | `standard` (60s)                           | Permission-scoped query; failures remain in the affected dashboard section with retry.                   |

No page-level Refresh button or broad cache invalidation is used. Mutations invalidate related data only after success.

## Verification record

The local API tests use Django's isolated test database. Email delivery is mocked in employee creation tests. Live UI verification uses the local signed-in QA account and synthetic local records; it is not a production-data test. The complete responsive and functional evidence, regression fixes, passing commands, and any verification limits are recorded in [QA findings](../testing/qa-findings.md).
