# Dashboard implementation

The dashboard port keeps Flutter as the source for existing data and workflows while giving each React dashboard a clear job. React adds permission-aware composition, bounded lists, section-local states, and responsive layouts. Do not treat a missing backend metric as a reason to show guessed or mock business data.

## Routes and ownership

| Route               | Purpose                                                                                                                                         | Content owner                      |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| `/dashboard`        | Staff-first home with today's context, personal priorities, month-to-date progress, recent updates, and up to three wider organization signals. | Workspace / signed-in staff member |
| `/company/overview` | Branches, departments and units, governance approvals, and company assets. It does not repeat workforce totals.                                 | Company                            |
| `/hr`               | Workforce, hiring, department headcount, and requests needing HR review.                                                                        | HR / People Operations             |

Flutter remains the source of truth for current routes, identity, and workflows. Company Overview is a React route that consolidates the Company summary concepts formerly shown on Company Profile. Existing routes are preserved. The sidebar groups staff actions under My Work; Company owns organization structure and governance; HR owns employee records and people operations.

## Workspace Overview

The page opens with a concise greeting and a `Today` strip for attendance, active tasks, and today's work-report status. Attendance is a link to its workflow; the dashboard has no clock-in or clock-out control. `Today` communicates current status, while `Needs your attention` lists up to five personal next steps, ordered by urgency; action descriptions say what to do without repeating the missing or pending status already shown above. The month-to-date attendance, work-report, and punctuality metrics sit in their own full-width `Performance overview` section immediately below, so action items and progress do not compete in one narrow column. `Recent updates` is a separate information list, capped at five, and `Organization pulse` is capped at three.

Personal data comes from existing endpoints: personal-overview, today's attendance, the signed-in employee's tasks and reports, their leave requests and loans, and their notifications. Queries are enabled only when the session grants the corresponding `list` or `list_own` permission (notifications use `notifications:list`). A backend endpoint must enforce ownership and permission independently of the React display gate.

Recent updates deduplicate notifications and domain records by canonical entity type and ID. For a duplicate entity, keep the newest event by timestamp. Within the ten newest distinct candidates, prefer one event per entity category, then fill remaining slots by recency; if only one category has real events, show those events without fabricating variety. Completed tasks are fetched separately from active tasks so they can appear in history without affecting the Today active-task count. The loan list exposes its record ID and `updated_at` so loan decisions sort by the last record update rather than the original request date. Do not include a task already in Needs your attention or another current attention item. Keep action items and informational updates as separate sections.

The organization pulse draws only from metrics the employee may view. Its current priority is pending Company approvals, pending HR leave requests, then one available structure/workforce/operations signal. It never shows more than three, even when the user has every permission. Operations aggregates remain hidden for a branch-limited scope when the source data cannot safely apply that scope.

## Company Overview

The compact summary strip contains branches, departments, pending approvals, and tracked assets when the matching data and permission exist. Company does not display employee totals; those belong on HR. The approval preview shows at most five pending workflow requests within the caller's branch scope. The structure links are permission-filtered and lead to Branches, Departments & Units, Approval Workflows, or Assets. Empty and failed sections explain their own state; retrying the summary does not replace the whole page.

## HR Dashboard

The summary shows active employees, month-to-date hires, open roles, and pending leave requests when permitted. Headcount is a compact comparison of up to five largest departments. The review queue shows at most five pending leave, absence, or running-late requests. Shortcuts are permission-filtered. Birthday content remains out until a real endpoint and authorization contract exist.

HR workforce metrics require `employees:list`; hiring requires `job_postings:list`; and the review queue requires `leave_requests:list`. Employee and request rows respect role branch scope. Department headcount is omitted for roles that lack employee-list permission. The browser does not grant permissions using email address or `is_superuser`.

## API and scope rules

| Endpoint                                                                          | Purpose and permission rules                                                                                                                                                                                                                                                                                                                                                                                                             |
| --------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `GET /api/v1/dashboard/personal-overview`                                         | Existing month-to-date attendance and work-report totals; each result is returned only for the matching `attendance:list`/`list_own` or `work_reports:list`/`list_own` permission.                                                                                                                                                                                                                                                       |
| Existing attendance, tasks, work-report, leave, loan, and notifications endpoints | Used for personal Today, attention, and recent-update sections. Request the signed-in employee's records and only query each source when the relevant session permission is present. The loan list adds `id` and `updated_at` to its response schema for event deduplication and ordering; no stored data or existing Flutter fields are removed.                                                                                        |
| `GET /api/v1/company/dashboard/overview`                                          | Retains legacy Company summary fields. Additive fields provide department/unit counts, tracked-asset counts, and a five-item approval preview. Each field is independently permission-gated. Branch-limited roles receive only branch-scoped branches, employees, approvals, and assets; department and unit totals are omitted because those models have no branch relation. Assets are scoped through their current branch-name field. |
| `GET /api/v1/hr/dashboard/overview`                                               | Retains workforce, hiring, department headcount, role, and pending-leave fields. Additive `review_queue` contains at most five pending leave, absence, or late-arrival requests. Metric permissions and branch scoping are enforced on the backend.                                                                                                                                                                                      |
| `GET /api/v1/operations/dashboard/overview`                                       | Existing module summary. React shows only permission-filtered signals and hides aggregates marked `scope_limited`.                                                                                                                                                                                                                                                                                                                       |

An unauthorized dashboard summary request is rejected. A field hidden by permission or unsupported scope is `null`; a permitted field with no matching records is zero or an empty list. Do not change Flutter's existing endpoint paths or response fields as part of the React dashboard work. No database migration is required for this dashboard slice.

## Shared presentation and responsive behavior

All three pages use the shared type scale, color and spacing tokens, `PageLayout`, and dashboard components for metric tiles, progress rings, list rows, and local loading/empty/error states. The page compositions remain distinct: personal home, Company governance, and HR workforce. Lists are capped in the UI even if a backend response is larger. Motion is limited to short entrance/progress transitions and respects the global reduced-motion setting.

## Visual refinement

The Workspace welcome band uses Bomach's blue gradient and geometric motif, with the employee's name, designation/role, and current date. Today remains a compact, three-part status row. Personal monthly performance follows Flutter's three-part composition: an attendance-rate ring, a work-report score and summary, and a punctuality score with attendance counts. The backend supplies the punctuality rate; `Absent` is required workdays minus attended workdays, bounded at zero. The three panels sit inside one visual section, in three columns on desktop and stacked on narrow screens. Do not manufacture an overall score or ranking from these independent measures; Flutter's ranking can be misleading for a single-person scope, and the current React summary contract does not define an equivalent combined score.

Company and HR summary values use distinct, lightly tinted tiles with category icons and larger tabular values. Section titles use one shared icon-and-heading treatment. List status badges use semantic colors, while their labels remain visible so status is not conveyed by color alone. These changes strengthen the visual hierarchy without changing route placement, permissions, workflows, or data ownership.

Review narrow layouts first: keep the attention and performance sections distinct at every width, use the same three performance panels stacked on phones, and compact their rings, padding, and stat spacing without changing the visual language. Validate 320, 375, 480, 600, 700, 900, 1100, 1280, 1440, and 1600 CSS pixels, plus the 480/700/1100/1440 cutovers. Check 200% zoom, keyboard/focus visibility, reduced motion, horizontal overflow, long employee names, and section-level failures.

## Test admin refresh

In the backend repository's local virtual environment, run:

```sh
python manage.py ensure_test_admin
```

The command is restricted to local, development, or test environments. Rerun it after changing the permission catalog to sync the local `admin@gmail.com` role. The React app uses only permissions returned by backend session bootstrap.

## Verification record

- React: `npm run check` passed type-check, lint, Prettier, all 75 Vitest tests, and the production Vite build.
- Backend: `TRY_LOCAL_DB=true .venv/bin/python manage.py test user.tests.test_dashboard_overviews --verbosity 1` passed 14 tests; Django reported no system-check issues.
- Browser: visually reviewed all three dashboards at the available narrow viewport (about 530 CSS px) and desktop viewport (about 1528 × 687). The Workspace hero, Today status row, separate attention list, three-panel performance view, and Company/HR metric tiles were reviewed with the local test account. The desktop document width measured 1513 px in a 1528 px viewport, with no horizontal overflow. A keyboard test confirms the first Today workflow link receives focus in tab order.
- The full requested viewport matrix (320–1600 px), breakpoint-edge checks, 200% zoom review, and manual reduced-motion review remain to be done. Hosting changes are outside this implementation.
