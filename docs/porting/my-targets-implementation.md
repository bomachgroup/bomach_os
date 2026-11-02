# My Targets implementation

## Scope and Flutter reference

React implements the employee-facing `/dashboard/my-target-reports` route as **My Targets**. It shows assigned targets and their cumulative approved progress, followed by the employee's paginated progress-report history. The manager review queue and KPI management stay outside this page.

Flutter's `TargetReportsPage` is the behavior reference for assigned targets, progress submission, and status history. The staff app reinforces the short amount-and-summary submission flow. React keeps the useful workflow but does not embed the KPI/target performance-plan panel: target and report access are independently permission-gated, and KPI measures remain distinct.

An assigned target's approved amount, remaining amount, percentage, and completion state come from the employee-target response. A report's submitted amount and review status describe only that report. Submitted or rejected amounts do not count toward cumulative completion. A target with a submitted report cannot accept another report until the current one is decided.

## Layout and navigation

- The header identifies **My Targets** without a manual refresh action. Each independently loaded section keeps its own retry when a request fails.
- **Assigned targets** comes first. Scope (`Active targets` or `All targets`) and period filters apply to this section. Desktop uses aligned rows for target, period, approved progress, state, and action; narrow layouts use compact cards with the same information.
- Each target shows its period dates, approved amount out of its goal, a compact progress bar, and remaining amount. On mobile, the status stays at the top-right of the card. The target detail action is available for completed targets too; it shows the description, period, target amount, approved amount, remaining amount, and completion state. No forecast or “on track” score is inferred.
- **Progress history** follows the assigned goals. It has its own status filter and page number. Each report keeps its submitted amount, summary, and review status separate from target totals. Rejection feedback is shown when available.
- The report status filter uses the same evenly distributed, horizontally scrollable tab treatment as Tasks and Work Reports. Desktop report rows place status and action together in a dedicated column; reviewer feedback gets a separate full-width row. Narrow layouts use cards with the status aligned at the upper right and feedback in its own section.
- “Report progress” opens the shared dialog, which fills the screen on narrow viewports and fits its content on desktop. It preselects the target and states its approved and remaining amounts. The form contains only progress amount and summary; entered values remain if the server rejects submission. Success feedback follows confirmed server creation.
- Progress report details require `target_reports:view_own` or `target_reports:view`. Assigned-target details are available wherever the assigned-target list is visible.
- A rejected report is immutable history. The employee API exposes report creation, listing, and detail, but no update or resubmit endpoint; the staff Flutter target-report controller likewise creates a new report rather than editing a rejected one. Corrected progress must therefore be submitted as a **new report**. Eligible rejected rows link directly to the preselected progress form; the old report remains visible with its reviewer feedback. The form is offered only when the target is active, in its reporting period, incomplete, and has no other report in review. Otherwise the UI explains whether to wait, contact a manager, or take no further action. The backend validates ownership, target state and dates, positive amount, remaining approved value, and duplicate pending submissions.

## URL state

The route validates and preserves these keys for copied links and browser Back/Forward:

| Key           | Purpose                                                                        | Default  |
| ------------- | ------------------------------------------------------------------------------ | -------- |
| `scope`       | Assigned targets: `active` or `all`                                            | `active` |
| `period`      | Assigned-target period: all, daily, weekly, monthly, quarterly, yearly, custom | `all`    |
| `status`      | Report history: all, submitted, approved, rejected                             | `all`    |
| `targetsPage` | Assigned-target server page                                                    | `1`      |
| `reportsPage` | Report-history server page                                                     | `1`      |

Changing scope or period resets only `targetsPage`. Changing report status resets only `reportsPage`. There is no free-text search.

## Permissions and backend contracts

The employee-target section needs `employee_targets:list_own` or `employee_targets:list`. The progress-history section independently needs `target_reports:list_own` or `target_reports:list`. Submitting needs target-list access plus `target_reports:create`. Opening report details additionally checks `target_reports:view_own` or `target_reports:view`. The backend remains authoritative for ownership, branch scope, target dates, active role, positive amount, remaining amount, and duplicate pending submissions.

React uses the existing contracts:

- `GET /api/v1/employees/me/targets` with `is_active`, `period`, `limit`, and `offset`.
- `GET /api/v1/target-reports/me` with report `status`, `limit`, and `offset`.
- `GET /api/v1/target-reports/{id}` for the optional details dialog.
- `POST /api/v1/target-reports/` with `employee_target_id`, `progress_value`, and `summary`.

The assigned-target response now includes additive `has_pending_report`, computed with an `Exists` subquery for a submitted report. The existing approved-progress aggregation and Flutter response fields remain intact. This is a query/schema change only; no migration is required. Existing Flutter clients can ignore the additional response field.

## Data lifecycle

| Query            | Key scope                           | Freshness and revalidation                                                                  | Mutation effect                                                                                                     |
| ---------------- | ----------------------------------- | ------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Assigned targets | User, employee, scope, period, page | `standard` (60 seconds); revalidate on stale route entry, focus, and reconnect. No polling. | Successful submission invalidates this employee's assigned-target variants so pending state and progress refresh.   |
| Progress history | User, employee, status, page        | `history` (120 seconds); revalidate on stale route entry, focus, and reconnect. No polling. | Successful submission invalidates this employee's history variants.                                                 |
| Report detail    | User, employee, report ID           | `history` (120 seconds); revalidate on stale open, focus, reconnect, or retry.              | This page does not edit or decide reports. Submission invalidation does not blanket-clear unrelated detail records. |

Queries are enabled only for the matching permission. Each section has independent first-load, empty, retry, and stale-cache feedback. Cached rows stay visible during revalidation. Routine refresh does not toast; only confirmed submission does. No dashboard or unrelated module query is invalidated.

## Verification

The focused React tests cover independent permission gates and failures, cumulative versus per-report values, pending duplicate prevention, form preservation on server failure, URL filter/page reset behavior, targeted invalidation, and malformed route search state. Backend tests cover pending state for submitted, approved, rejected, and absent reports while retaining the previous progress fields. Manual browser review at 533px and 1513px confirmed the mobile status placement, compact progress bars, aligned desktop rows, distinct reviewer-feedback blocks, and direct corrected-progress action. The correction action opened a preselected form without submitting a report. Build, lint, formatting, and diff checks passed; the automated test suite was not run in this review.
