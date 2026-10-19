# Data Freshness, Refetching, and Invalidation

## Status

This is the proposed shared policy and a required planning checklist for every page slice. The mobile app provides a useful precedent. The freshness classes below are starting values to review against each page and backend contract; they do not authorize blanket polling across the application.

## Why this exists

TanStack Query owns server state. Each page should load the data it needs, keep useful data visible during a background update, and refresh related cached data after a confirmed mutation. Refresh work should follow the page the user is using instead of repeatedly requesting every dataset in the system.

Keep these two meanings separate:

- **Authentication token refresh** is handled inside the shared API client when an access token expires. It retries the failed request once and does not mean every page query should reload.
- **Data revalidation/refetching** reloads a query's server data when it is stale, the user returns to the relevant page, connectivity returns, or the user asks for a refresh.
- **Invalidation** marks only data affected by a successful mutation as stale. TanStack Query can refetch matching active queries; inactive cached queries remain stale until the user opens them.

## What the mobile app does

The staff mobile app uses RTK Query with a screen-scoped refresh coordinator. Each focused navigation screen registers its own relevant queries. It checks their age when the screen becomes active, the app returns to the foreground, or connectivity is restored. Pull-to-refresh forces the current screen's registered queries. It avoids refreshing a query already fetching, skips automatic refresh while offline, scopes cooldowns by user and query, and only automatically retries retryable network/server failures.

The mobile freshness age thresholds are 30 seconds for live data, 60 seconds for standard data, 120 seconds for history, and 300 seconds for reference data. These are **age thresholds**, not repeating timers: the mobile code does not poll every registered query continuously. It also uses domain tags so successful changes invalidate related records, lists, and dashboard summaries—for example, a clock action refreshes attendance today/history/summary and the dashboard, while a report change refreshes reports and dashboard data.

This is a lifecycle and domain-invalidation pattern to learn from. The React port stays on TanStack Query and does not copy the mobile app's Redux/RTK Query implementation.

## Current React baseline and gap

The React app already has some local policies, but not a common one:

- The QueryClient currently disables refetch-on-window-focus globally and retries queries once.
- Workspace, Company, and HR dashboard queries use a 30-second `staleTime`; the session query uses 60 seconds.
- The notification unread count currently polls every 30 seconds while its panel is open and every 60 seconds while it is closed. The notification list loads when opened and mutations invalidate notification queries.
- Other page queries and mutations do not yet share a documented freshness-class and invalidation map.

This means a query that has passed its `staleTime` does not necessarily update while the same browser tab stays focused. We will make the browser lifecycle behavior intentional when the shared policy is reviewed and implemented.

## Proposed freshness classes

Use the class as the maximum age at which data may be treated as fresh. Revalidate stale queries when the active route is entered or revisited, when the browser tab regains focus, and when connectivity returns. Add a repeating interval only where users need to see changes without leaving the page; interval polling is a separate, explicit decision from `staleTime`.

| Class          |          Proposed freshness age | Typical data                                                                           | Default refresh behavior                                                                                                                                                                           |
| -------------- | ------------------------------: | -------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `live`         |                      30 seconds | Today's attendance/action state, unread counts, a queue actively monitored by the user | Revalidate on active-page return/focus/reconnect. Add a 30-second interval only when the workflow benefits from continuous updates; stop it when the page or browser is inactive.                  |
| `standard`     |                      60 seconds | Current tasks, work reports, leave/loan requests, dashboard summaries                  | Revalidate when the active page is entered/revisited, browser focus returns, or connection returns. No timer by default.                                                                           |
| `history`      |                     120 seconds | Attendance history, completed records, activity lists                                  | Revalidate on active-page return/focus/reconnect when old enough. No timer by default.                                                                                                             |
| `reference`    |                     300 seconds | Departments, roles, status catalogs, stable lookup data                                | Revalidate on entry/focus/reconnect when old enough. No timer by default.                                                                                                                          |
| `event-driven` | No time-based expiry by default | Expensive/large reports or data whose changes are fully known from app mutations       | Load on entry; refresh through targeted invalidation or an explicit user refresh. Use an invalidatable cache lifetime such as `staleTime: Infinity`, not a static cache that ignores invalidation. |

These are defaults, not promises about server update cadence. A page may assign different classes to separate sections. Record exceptions with a reason, especially for expensive endpoints, server-side aggregation, or workflows where stale information can cause a harmful action.

### Focused-page scope

- Only queries needed by the current route should be observed and eligible for page polling. Do not create a global timer that refetches every cached query.
- If a page has tabs or collapsible sections, keep queries disabled until their panel is needed unless a visible summary depends on them.
- Do not poll in a hidden browser tab. If the product later requires live updates across multiple tabs, document that as a separate shell-level feature.
- Shared shell data is an explicit exception, not a reason to fetch module data globally. For example, the notification badge may have its own lightweight visible-tab cadence; the notification feed should load on demand.
- Browser focus, route re-entry, reconnect, and periodic polling are distinct triggers. State which ones each query uses.

## Mutation invalidation rules

Plan invalidation by domain dependency, not by whichever component initiated the mutation. Feature query-key factories should be the shared vocabulary for reads and invalidations. Include relevant user/tenant/branch scope, route filters, date range, and record ID in query keys so records from different scopes cannot collide.

After a mutation succeeds:

1. Put the returned canonical record into its detail cache when that is safe and useful.
2. Invalidate the affected record, collection/list queries, and summary queries whose values depend on the change.
3. Allow active affected queries to refetch in place; leave inactive affected queries stale until they are opened.
4. Keep unrelated query data untouched. Avoid invalidating the whole QueryClient or an entire module when a narrower key is known.
5. Do not invalidate as if a write succeeded when it failed. Handle conflict responses by preserving the draft and offering an explicit reload/reconcile path.

Likely dependency edges to check as real pages are built:

| Successful change                                        | Data to consider refreshing                                                                                                       |
| -------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| Attendance clock action or correction                    | Today's attendance, attendance history/summary, workspace performance and any visible HR attendance queue affected by that record |
| Task create/update/status/assignment                     | Task detail, task lists for affected filters, workspace attention and task counts                                                 |
| Work report create/edit/submit/withdraw/review           | Report detail/lists, workspace performance or attention, HR review lists and summary metrics that include the report              |
| Leave/loan request or approval decision                  | Request detail, employee and reviewer lists, affected HR/workspace queue counts and summaries                                     |
| Notification read/unread change                          | The notification record, relevant feed variants, and unread count                                                                 |
| Employee, department, branch, role, or permission change | The affected record/list and only the Company/HR summaries and session/permission data that depend on it                          |

These are dependency prompts, not automatic instructions to add every endpoint or dashboard invalidation. Verify which records and metrics actually change on the backend before adding an edge.

For optimistic updates, implement rollback on failure and still reconcile with the server after success when server rules can alter the result. Otherwise prefer targeted invalidation over hand-maintaining multiple filtered copies.

## UI behavior during refresh

- Initial loads use content-shaped skeletons and the normal page/section error states.
- During a background refetch, keep existing data visible when safe and show a small local progress/updated state. Do not blank the whole page for a single section refresh.
- If background refresh fails but cached data exists, retain the data and show an unobtrusive stale-data notice with retry when the freshness matters to the next action. Do not show an empty state or duplicate the error as both alert and toast.
- If a required first load fails with no cached data, use the existing page/section error state.
- Provide a manual refresh control only where it gives the user meaningful control. It should refresh that page's relevant queries, not the entire application.
- Disable repeated manual requests while the same query is fetching; use a short interaction cooldown only if repeated attempts can cause load or UI churn.
- Do not show a toast for routine background revalidation. Show success feedback only for a user-triggered mutation confirmed by the backend.
- Cancel/supersede route-bound requests safely when possible, and pass TanStack Query's `AbortSignal` to the shared API client.

## Required data-lifecycle section in every page plan

Before implementing a page or workflow, include a small table or bullets covering:

1. Each server query and its owner/query-key factory, including permission and user/branch/date/filter scope.
2. Freshness class and whether it refreshes on route entry/revisit, browser focus, network reconnect, manual refresh, or a timed interval.
3. Why any periodic interval is needed and how it stops when the route/browser is inactive.
4. Mutations on the page and the exact related record/list/summary query keys to update or invalidate after confirmed success.
5. Which related screens should see fresh data when opened later, without eagerly loading those pages now.
6. Initial loading, background-refresh, offline, refresh-error-with-cached-data, first-load-error, and empty-state behavior.
7. What meaningful tests will prove: active page refreshes, unrelated/inactive data does not refetch unnecessarily, invalidation reaches affected data, and failures preserve usable cached state.

Do not start coding the page's data hooks until this plan is specific enough to review. The user can approve or adjust the freshness classification and any timer before the page is implemented.

## Implementation sequence

1. Review the freshness classes and active-page trigger policy against this mobile precedent with the user.
2. Implement a small TanStack Query policy/query-key pattern in a reviewed route slice; keep auth token refresh separate.
3. Pilot query refresh and invalidation on one real page and one mutation with dependent data.
4. Verify background errors preserve data and that no unrelated/inactive route is fetched.
5. Apply the agreed policy one page or workflow at a time, extending the dependency map as backend contracts are confirmed.

Do not mass-edit every query or turn every freshness class into recurring polling in a single pass.
