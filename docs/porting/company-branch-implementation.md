# Company Branch Management

## Scope and routes

The React port provides a branch directory at `/company/branch` and shareable details at `/company/branch/:branchId`. Directory filters and pagination are URL state: `search`, `operationalStatus`, `branchRole`, `recordState`, and `page`.

The directory shows the operational and record-active states separately. Desktop uses a table with a **More** menu for permission-available details and edit actions; its action column stays in the table's normal horizontal flow and is not sticky. Narrow layouts use branch cards with the same **More** menu. Branch details cover identity, location and contact, manager, geofence, business hours, and notes. Sample branch performance figures and detail tabs without backend data are excluded.

Create and edit use the same five-step dialog: **Details**, **Location**, **Attendance and notes**, **Business hours**, and **Review**. Each step validates before continuing; Review is a read-only summary, and only its explicit **Create branch** or **Save changes** action submits. Attendance GPS capture, manual coordinates, and radius use one shared field group in create, edit, and the dedicated geofence dialog. Edits now include geofence values in the explicit Review save. A generated branch ID is read-only. Branch removal is represented by record deactivation or an operational status change. Location capture only runs after the user opens a flow step and activates scanning; denial or failure leaves the saved coordinates intact and displays a local explanation.

## Backend contract and access

| Operation       | API                                                | Permission                                      |
| --------------- | -------------------------------------------------- | ----------------------------------------------- |
| Directory       | `GET /branch/branches`                             | `branches:list`                                 |
| Details         | `GET /branch/branches/{id}`                        | `branches:view`                                 |
| Create          | `POST /branch/branches`                            | `branches:create`, company-scoped role          |
| Edit            | `PUT /branch/branches/{id}`                        | `branches:update`                               |
| Business hours  | `GET` / `PUT /branch/branches/{id}/business-hours` | `branches:view` / `branches:set_business_hours` |
| Field choices   | `GET /branch/branches/choices/fields`              | `branches:create` or `branches:update`          |
| Manager choices | `GET /branch/branches/choices/managers`            | `branches:create` or `branches:update`          |

Branch-scoped roles read and update only assigned branches. Out-of-scope IDs return not-found. Creation requires a company-scoped role; including hours at creation also requires `branches:set_business_hours`. Embedded hours during an edit require both update and set-hours permissions. The manager picker returns active employees in the caller's branch scope, with the branch's currently assigned manager retained as an edit option. It sends only the manager-choice DTO fields needed by the form.

The explicit week editor distinguishes unset, closed, and open days. Open days require both valid times, and close must follow open. Saving replaces the submitted weekly schedule in one transaction. Branch wall-clock times are stored without a time zone. The API and model both enforce a 1–5000 metre attendance-radius range. The React page does not call the sample `/performance` endpoint.

## Queries, freshness, and invalidation

| Query                                                            | Freshness          | Refresh triggers                                                                       | After a successful mutation                                                                                                   |
| ---------------------------------------------------------------- | ------------------ | -------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Directory, scoped by signed-in user, employee, filters, and page | `standard` (60s)   | Stale route entry, focus, and reconnect; no polling. Failed sections have local retry. | Create/edit invalidates branch lists and Company Overview counts. Edit also updates/invalidate the matching detail and hours. |
| Company Overview branch counts                                   | `standard` (60s)   | Shared Company Overview query lifecycle and directory refresh button                   | Create/edit invalidates the scoped overview key.                                                                              |
| Branch detail and hours                                          | `reference` (300s) | Stale route entry, focus, reconnect, and section retry; no polling                     | Detail edit refreshes detail, hours, lists, and overview. Standalone hours save updates hours and invalidates detail.         |
| Field choices, manager choices                                   | `reference` (300s) | Load on editor open, stale focus/reconnect, and local retry; no polling                | These are reference data and are not invalidated by branch changes.                                                           |

Successful changes to a branch's active state, operational status, or geofence refresh the attendance branch choices query. A normal details or hours edit does not refresh attendance choices.

Cached directory and detail data stay visible during refresh. Overview count errors are local to the counts. Without cached list/detail data, the affected section gets its own retry state. Failed saves keep the dialog and its draft open. Authentication, permission, validation, network, and server failures use shared error presentation; section retries target only the failed query.

## Verification record

Automated coverage is in `src/modules/company/branches.api.test.ts`, `src/modules/company/branches.search.test.ts`, and `src/modules/company/branch-hours.test.ts`, plus backend endpoint tests in `domains/organization/tests/test_branch_scope_api.py`.

Live browser review is recorded in `docs/testing/qa-findings.md`. The directory was checked across phone, tablet, desktop, breakpoint, and landscape widths; create/edit and business-hours dialogs were opened and cancelled without saving. Search/filter URL behavior was checked in the running app. Existing local branch records were read only. Do not claim a full live API failure-state pass based only on mocked React tests or Django API tests.
