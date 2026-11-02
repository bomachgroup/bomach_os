# HR Performance Analytics

## Scope and Source Parity

This slice covers Monthly Scorecard, Employee Evaluation, and Performance Engine.
The Flutter sources are `MonthlyScorecardPage`, `EmployeeEvaluationPage`, and
`PerformanceEnginePage` in `bomach_os/lib/pages/hr/`.

Monthly Scorecard and Employee Evaluation have Django APIs mounted at
`/api/v1/monthly-scorecards` and `/api/v1/employee-evaluations`. Performance
Engine is explicitly a roadmap/unavailable screen in Flutter and has no matching
backend router. The React port must not present roadmap capabilities as live data
or add actions that have no backend contract.

## Supported React Behavior

- Navigation ownership follows the audience and behavior rather than the Flutter source folder: the employee's own read-only Monthly Scorecard appears in Workspace > My Work > My tasks & goals as **My Scorecard**. Its `/hr/monthly-scorecard` route and permission contract are unchanged. Cross-employee reporting remains under HR/Admin.
- Monthly Scorecard shows the signed-in employee's scorecard for a URL-backed
  month and year. It reads with `generate_if_missing=false`; visiting or refreshing
  a view must not create scorecards. A 404 is an empty period, not a backend
  failure. Existing scorecard fields are the source of truth for the overall
  score, target achievement, ranking, target, five metrics, generation marker,
  and notes.
- Employee Evaluation is a manager workflow. A selectable employee is evaluated
  by the signed-in employee record; the signed-in employee cannot be the subject
  of their own evaluation. Existing evaluations for that evaluator and period are
  loaded for editing only when both view and update permissions allow it. Create
  and update actions use the backend's manager comments and three recommendation
  flags. Employee selection is shown only with employee-list permission; an
  own-only evaluation role can read evaluations addressed to their own record.
- The Flutter PDF action is a no-op and the API has no PDF export endpoint. The
  React page therefore does not render a nonfunctional export control.
- Performance Engine presents the Flutter roadmap grouped as planned capability
  areas and identifies the feature as unavailable. It contains no fabricated
  scorecards, API calls, or enabled actions.

## Access and Backend Rules

- Scorecard reads require `monthly_scorecards:view` or `view_own`. The API must
  scope the target employee by ownership or assigned branch before returning an
  existing scorecard or generating one for legacy callers.
- Evaluation reads require `employee_evaluations:list` or `list_own`; details
  require `view` or `view_own`; writes require their matching create/update
  permission. Branch-limited access is scoped through the employee's branch.
- Creation must reject an evaluator ID that differs from the authenticated
  employee, self-evaluation, employees outside the caller's branch scope, and a
  duplicate employee/evaluator/month/year record. Run model validation before
  persisting the evaluation.
- These are server-side rules. Client-side permission checks only hide unavailable
  controls and do not substitute for backend authorization.

## URL State and Data Lifecycle

- Monthly Scorecard owns `month` and `year` search parameters; Employee Evaluation
  owns `employee_id`, `month`, and `year`. Defaults are the current period, and
  valid period choices cover the current year plus/minus two years.
- Scorecards and evaluation history use the `history` freshness class (120s),
  with focus/reconnect revalidation and no polling. Employee choices use
  `reference` freshness (300s) while their selector is available.
- Evaluation creation/update invalidates the selected employee/period's
  evaluation list and detail. Creation also invalidates the matching scorecard
  query because the backend may generate a scorecard as part of that workflow.
- Performance Engine is static and has no query lifecycle.
- Initial loading uses content-shaped skeletons. First-load failures have local
  retry. A missing scorecard is a distinct empty state. A failed background
  refresh retains cached data with a local stale-data notice.

## Verification Plan

- React: route/search validation, API mapping and read-only scorecard flag,
  scorecard empty/loading/error/loaded states, evaluation employee selection,
  self-review/duplicate handling, form validation, permission variants, mutation
  success/failure, and roadmap non-interactivity.
- Backend: owner-only and branch-scoped scorecard access, no scorecard creation
  for out-of-scope targets, evaluation list/detail/update branch scope, evaluator
  identity, self-review rejection, duplicate rejection, and persisted valid
  create/update behavior.
- Browser: direct route and navigation, keyboard/accessible labels, long names,
  missing optional fields, empty periods, and 320/375/480/600/699/700/900/1100/
  1280/1440/1600 CSS-pixel widths plus 200% zoom. Check all loading, empty,
  forbidden, validation, success, and recoverable API-error states.
- Backend tests use Django's isolated test database. The confirmed local
  development database is SQLite with `DEBUG=True` and console email; its seed
  records are preserved. Any live smoke-test fixture must be synthetic and
  identified by its exact ID; cleanup must use a supported endpoint or a
  disposable test-database reset.

## Known Contract Limits

- Scorecard generation is currently available only as an implicit side effect of
  the legacy scorecard GET or evaluation creation. The scorecard screen opts out
  of that side effect; HR must generate data through the supported workflow.
- The evaluation list endpoint returns compact rows; detail is needed for manager
  comments. The UI should request detail only for the selected employee's
  matching evaluator/period record.
- The performance-engine endpoint paths listed by Flutter are roadmap text, not
  implemented API routes. Do not call them.
- There is no evaluation delete endpoint. Keep browser smoke-test evaluations
  synthetic and identify them by ID; do not remove them with a direct database
  delete.
