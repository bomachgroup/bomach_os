# My Profile and Role — React Port

## Status

Implemented as read-only employee pages using the current backend contracts and the Flutter Profile and Role pages as the content baseline. React owns the responsive presentation and section-level feedback.

## Routes and access

| Page       | Route                   | Access                                                                                                                                                                              |
| ---------- | ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| My Profile | `/dashboard/my-profile` | Authenticated session. The session bootstrap already loads the employee's own profile and the employee endpoint enforces ownership.                                                 |
| My Role    | `/dashboard/role`       | Existing `roles:view_own` or `roles:view` route permission. The role record is requested with the signed-in user's ID; the backend applies its own ownership and permission checks. |

The shell profile dialog stays a compact identity, verification, employment-status, role-chip, full-profile, and sign-out surface. It no longer hosts two-factor controls or repeats the full employee record. Profile details are read-only. There are no edit or compensation actions.

## Profile fields and privacy

Profile reuses the session query built from `GET /auth/me` and `GET /employees/employees/{user_id}`. The page presents four groups:

- Personal information: first, middle, and last name, date of birth, gender, marital status, and nationality.
- Contact information: work and personal email, phone, and the employee address fields.
- Employment: employee ID, role, designation, department, branch, employment type/status, start date, and work location.
- Account security: account creation date, username, verification/active state, two-factor status, and Change password.

`EmployeeProfileDto` is an explicit safe-field allowlist. Compensation, bank account, pension, tax, health, and benefits response fields are not typed for page use and are never rendered. Optional fields are omitted and a section with no populated fields has a neutral empty explanation.

Change password stays in a compact dialog on Profile. It uses the existing `POST /auth/browser/forgot-password` and `POST /auth/browser/reset-password` contracts: request a code for the signed-in email, then enter the code and new password without leaving Profile. Password reset invalidates the browser session by backend design, so the dialog shows a confirmed completion state and an explicit **Continue to sign in** action. The user is not sent to the public forgot/reset pages during the change flow. Two-factor settings reuse the password-confirmed `/auth/2fa/status`, `/auth/2fa/enable`, and `/auth/2fa/disable` contracts. The confirmation dialog is content-sized on mobile and desktop, and success appears only after the backend confirms it.

## Role content and API mapping

`GET /roles/employees/{user_id}` loads the signed-in employee's assigned role record, including role name, branches, permissions, and role timestamps. Each expandable section is requested only when opened and maps to an existing employee-scoped `/roles/me/*` GET endpoint:

| Role section                       | Endpoint                                                                                                          |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Description and responsibilities   | `/roles/me/description`                                                                                           |
| KPIs                               | `/roles/me/kpis?limit=10&offset={offset}`                                                                         |
| SOPs                               | `/roles/me/sops?limit=10&offset={offset}`                                                                         |
| Permissions and authority guidance | `permissions` from the assigned role response                                                                     |
| Reporting structure                | `/roles/me/reporting-chain`, `/roles/me/reporting-tree`, and `/roles/me/reporting-lines?limit=10&offset={offset}` |
| Career path                        | `/roles/me/career-path/tree`                                                                                      |
| Training requirements              | `/roles/me/training-requirements/grouped`                                                                         |
| Success playbook                   | `/roles/me/success-playbook/grouped`                                                                              |
| Resources                          | `/roles/me/resources/grouped`                                                                                     |
| Task templates                     | `/roles/me/task-templates?limit=10&offset={offset}`                                                               |
| Daily routine                      | `/roles/me/daily-routine?limit=10&offset={offset}`                                                                |

List responses use the backend's paginated `{items, count}` shape and page controls where needed. The reporting chain/tree are used for manager and direct-report structure; the role summary is not treated as manager data. The UI is read-only and does not call role administration endpoints.

Sections are shown only when the session grants one of their existing `view`, `view_own`, `list`, or `list_own` actions. Each endpoint still enforces its own permission and ownership check. An unexpected 403 is rendered as a section-local permission error. The assigned-role 404 is a clear “No role assigned yet” state; an optional section 404 is treated as no configured section data. Network/server failures show a local retry and do not replace already cached role information.

The permissions section presents each grant once, grouped into People & roles, Attendance & access, Finance, Projects & operations, Clients & services, and Company & governance. A compact summary explains the grant count and how own-account and branch scope work. Each action’s one-sentence explanation comes from the shared `permission-guidance` catalog, keyed by the backend resource/action pair and checked against the backend permission map and route behavior. It explains the action’s practical effect (for example, attendance history or a work-location decision), rather than restating “View attendance.” The tooltip opens after a one-second pointer hover and immediately on keyboard focus. The presentation does not request `/roles/me/authority-limits`, whose generated fallback repeats the permission label, and it does not render a second guidance list. `PermissionActionGroups` and its catalog are shared for future HR permission surfaces so descriptions stay consistent. The employee role page uses compact inline empty states so optional sections do not leave oversized blank panels.

## Data lifecycle

| Query                           | Freshness                 | Scope and triggers                                                                  | Refresh and failure behavior                                                                                                                                                                             |
| ------------------------------- | ------------------------- | ----------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Authenticated session / Profile | `standard` (60 seconds)   | Shared session key, signed-in account; route entry, focus, and reconnect when stale | No polling. Profile uses the cached employee and user data while refresh is in progress. With no cache, a failure is a page error with retry; with cache, a small stale-data notice stays with the page. |
| Two-factor status               | `standard` (60 seconds)   | Dedicated security-status key                                                       | Route entry, focus, reconnect, and local retry; no polling. A confirmed enable/disable updates and invalidates this key only.                                                                            |
| Assigned role                   | `reference` (300 seconds) | Signed-in user ID in the role query key                                             | Route entry, focus, and reconnect when stale; no polling. A failed initial load is a page error; 404 means no assigned role.                                                                             |
| Expanded Role section           | `reference` (300 seconds) | Signed-in user ID, section name, and page number/offset when paginated              | Enabled only while the disclosure is open; reopens from cache and refreshes when stale. Focus/reconnect are enabled. Failures and retry controls stay in that section; cached data remains visible.      |

There are no Profile-detail or Role writes. Password reset uses the existing browser auth endpoints, invalidates the backend session, and offers an explicit sign-in action after its in-page success state. Two-factor mutation invalidates only the security-status query. Role sections are independent; a permission/network/server error in one section does not prevent the other sections from working.

## Responsive presentation and accessibility

Both pages use the shared full-width page heading and body alignment, semantic cards, status chips, skeletons, and shared error/empty components. Profile leads with identity and uses a balanced two-column details grid on tablet/desktop. Security confirmation dialogs stay compact at every viewport. The Role assignment summary keeps the role ID and branch scope distinct, without repeating an unconfigured-branch message. Role disclosures remain a single column on phones and become a two-column, top-aligned grid on desktop; the description and reporting sections use the full desktop width where their content benefits from it. Section helper text is hidden on narrow phones and shown from tablet width, leaving compact disclosure headers. KPIs, SOP status, training dates, task priority, and routine times use readable labels and semantic chips. Responsibilities become a checklist, and grouped information reflows from one column on phones to two columns on tablet and desktop. Manager chain and direct reports sit side-by-side from tablet width, with reporting relationships below. Long values wrap, narrow screens do not require horizontal scrolling, and disclosures expose their expanded state to assistive technology. Permission descriptions work with pointer and keyboard, and focus rings and reduced-motion-aware transitions follow shared controls.

For local visual review, `user/management/commands/seed_local_role_page_demo.py` provides concrete example content across each Role section: access-review responsibilities, measurable KPIs, procedural steps, reporting relationships, progression guidance, dated learning requirements, decision practices, work resources, recurring tasks, and a timed daily rhythm. Run it against an existing local role with `--role-id <id>`; `--refresh` updates matching preview records and consolidates duplicate entries from earlier preview revisions. The command refuses to run outside the backend checkout's local development SQLite database.

## Verification coverage

The page tests cover the safe Profile field mapping and no-edit contract; the in-Profile password reset; the role overview, lazy section loading, section-local failures, no-role state, and backend permission descriptions; the reusable tooltip's one-second pointer delay and keyboard behavior; and route registration so the two canonical destinations cannot fall back to Coming Soon. Typecheck, lint, targeted tests, formatting check, and production build are run as implementation checks.
