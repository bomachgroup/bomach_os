# KPI Management and OKR Board

## Route coverage

- `/company/kpi-management` is implemented against the existing role KPI and shared metric APIs.
- `/company/okr-board` follows Flutter's current capability-unavailable screen. It does not present the Revenue Execution OKR endpoints as company or role OKRs.

The Flutter references are `KpiManagementPage` in `lib/pages/company/kpi_management.dart`, its editor in `lib/pages/company/widget/kpi_dialogs.dart`, and the role KPI controller in `lib/pages/company/controllers/role_kpi_controller.dart`. `OkrBoardPage` in `lib/pages/company/okr_board.dart` states that the required company/role API is unavailable.

## KPI contract

The React page uses these backend operations:

| Operation                                       | Endpoint                                            | Permission                  |
| ----------------------------------------------- | --------------------------------------------------- | --------------------------- |
| List role assignments                           | `GET /api/v1/roles/kpis?limit=&offset=&search=`     | `role_kpis:list`            |
| List roles for the editor                       | `GET /api/v1/roles/?limit=&offset=`                 | `roles:list`                |
| List shared metrics                             | `GET /api/v1/kpis/metrics/?limit=&offset=`          | `kpis:list`                 |
| List role assignments before selecting a metric | `GET /api/v1/roles/{role_id}/kpis?limit=&offset=`   | authenticated role endpoint |
| Create assignment                               | `POST /api/v1/roles/{role_id}/kpis`                 | `role_kpis:create`          |
| Edit assignment                                 | `PATCH /api/v1/roles/{role_id}/kpis/{role_kpi_id}`  | `role_kpis:update`          |
| Remove assignment                               | `DELETE /api/v1/roles/{role_id}/kpis/{role_kpi_id}` | `role_kpis:delete`          |
| Create shared metric                            | `POST /api/v1/kpis/metrics/`                        | `kpis:create`               |

Creating an assignment requires list access to roles and metrics as well as `role_kpis:create`; without those inputs the UI hides the action. Creating a shared metric is only offered when the user can also list the catalog. Edit and remove actions are independently permission-gated. The API returns role IDs and embedded metric details, so role names are loaded separately and fall back to a role ID when the user cannot read roles or that lookup fails.

The list is paginated at 50 items and searches the metric name and description. Search is URL-backed, trimmed before it reaches the API, limited to 200 characters, and resets pagination. Invalid page values use page 1. Role, metric, and per-role assignment reference queries collect all backend pages in batches of 100 so duplicate metric choices are not missed on later pages.

Editor validation mirrors the backend bounds: target values must be finite and nonnegative; weight must be finite and from 0 to 100; display order must be an integer from 1 to 2,147,483,647. Blank target and weight values are sent as `null`; blank display order is omitted. Duplicate role/metric assignments remain in the form as a conflict. Historical employee KPI data and the shared metric remain after removing a role assignment. Automatic and semi-automatic modes are labeled as stored configuration because the API does not configure calculations.

Shared metric units follow the backend `KPIMetric.UnitChoices` values: `percentage`, `count`, `currency`, and `rating`. The create form presents these as a dropdown instead of accepting arbitrary text; other values fail Django model validation.

## Query and mutation lifecycle

- Role KPI list keys are scoped by authenticated user and employee and include URL search/page parameters. List data is fresh for `DATA_FRESHNESS_MS.standard` (60 seconds), revalidates on focus and reconnect, and does not poll.
- Role and metric reference catalogs use `DATA_FRESHNESS_MS.reference` (300 seconds), focus/reconnect revalidation, and no polling.
- The selected role's assignment list is checked with zero stale time while the editor is open, preventing a duplicate choice based on an old catalog.
- Create, edit, and remove invalidate the affected list family and the corresponding role assignment query. Success feedback follows server confirmation; errors keep the form or destructive confirmation open for correction/retry.
- Query keys include both user ID and employee ID, so a session switch does not reuse another user's KPI cache.

## OKR backend boundary

The API inspected in `bomach_os_backend` includes Revenue Execution OKRs scoped to branch and owner. Those endpoints are not interchangeable with the company/role OKRs expected by the Flutter board. The React page therefore states the missing contract: company/role objective, key result, owner, period, progress, status, and approval/review actions. No synthetic frontend-only CRUD is exposed.

## Local verification data

The local backend was verified as DEBUG SQLite with Django's console email backend before considering live write tests. Any temporary end-to-end records must use a unique `QA-PORT-KPI` marker, must be deleted after verification, and must not send outbound email. The fixture-free route/API tests remain the regression baseline.
