# My Tasks page implementation

## Route and source

The React implementation replaces the Coming Soon placeholder at `/dashboard/my-tasks`. Flutter's `MyTasksPage` remains the behavior and content reference. The React route keeps task state in the URL so a copied link can restore the selected status, priority, sort order, page, and optional task detail panel.

| Search key | Meaning                                             | Default    |
| ---------- | --------------------------------------------------- | ---------- |
| `status`   | `all`, `pending`, `in_progress`, or `completed`     | `all`      |
| `priority` | `all`, `low`, `medium`, or `high`                   | `all`      |
| `sort`     | Due date or priority, with a stable secondary order | `due_date` |
| `page`     | 10-item page number                                 | `1`        |
| `task`     | Positive task ID that opens the detail panel        | absent     |

Closing task details removes only `task`; the other URL state remains. Invalid values are normalized by the route validator. Changing a filter resets pagination. Unknown legacy URL keys such as `q` are ignored.

## Page behavior

- Status tabs show server summary counts. The `All tasks` count includes cancelled assignments; cancelled items have a status label but no dedicated tab.
- Desktop uses a five-column task table with a flexible title column and bounded metadata/action columns so it fits the shell's content width. Below the desktop breakpoint, each task becomes a card with the same status, priority, due date, project, milestone, and estimated-time information. The filter panel keeps status in a single segmented strip, with priority and sort controls side by side from the phone breakpoint upward.
- Task details are opened through the `task` URL parameter. They render in a centered, content-sized shared dialog on tablet and desktop, and stay near full-screen on small screens. The summary, task overview, description, and available task action use the same surface and footer patterns as other dialogs. Closing the dialog returns to the same filtered list state.
- Employees can start a pending task. Completing an in-progress task requires confirmation because the status is shared with everyone assigned to that task. The UI does not offer transitions from completed/cancelled back to another state.
- Lists use a ten-item page size, bounded server pagination, and stable ordering. Due-date sorting puts undated tasks last, then uses priority and ID for ties. Priority sorting is high, medium, low, then unspecified, followed by due date and ID.

## Permissions and backend contract

React checks the permissions returned by session bootstrap; it never infers access from email or superuser status. The API enforces the same rules and owner scope.

| Operation        | Permission                                           | Scope                                                                                                                   |
| ---------------- | ---------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| List and summary | `tasks:list_own` or the existing `tasks:list` access | Only tasks assigned to the signed-in employee                                                                           |
| Task detail      | `tasks:view_own` or `tasks:view`                     | Task must be assigned to the signed-in employee                                                                         |
| Start/complete   | `tasks:update_own` or `tasks:update`                 | Task must be assigned to the signed-in employee; only pending → in progress → completed is allowed for employee actions |

The existing `GET /api/v1/my-tasks` and task detail/status contracts are retained. React sends status, priority, sort, and pagination parameters and keeps the existing paginated `count`/`items` response. The backend's optional search parameter remains available to other clients but the personal React task page does not expose or send it. `GET /api/v1/my-tasks/summary` is a new personal aggregate that returns total, pending, in-progress, completed, and cancelled counts. It does not include tasks belonging only to other employees. The dynamic task route remains after `/summary` so the summary path is not interpreted as a task ID.

## Data lifecycle and invalidation

| Query              | Key scope                                               | Freshness and triggers                                                                                                                  |
| ------------------ | ------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| Filtered task list | Signed-in user ID, employee ID, filters, sort, and page | Standard: 60 seconds; fetch on route entry when stale, browser focus, and reconnect. No polling.                                        |
| Status counts      | Signed-in user ID and employee ID                       | Standard: 60 seconds; fetch on route entry when stale, browser focus, and reconnect. No polling.                                        |
| Task detail        | Signed-in user ID, employee ID, and task ID             | Standard: 60 seconds; only enabled when a detail URL is open and the user can view details; focus and reconnect when stale. No polling. |

Route-bound query functions receive TanStack Query's `AbortSignal`. The page has no generic Refresh action; stale task data revalidates through the shared route/focus/reconnect lifecycle, while a failed list keeps its contextual retry. After a confirmed status update, React puts the canonical response in the task detail cache and invalidates:

- all filtered My Tasks list variants and the personal task summary;
- the Workspace Overview's active-task and completed-task queries;

Inactive Workspace task queries remain cached but stale until Workspace Overview is opened. The personal performance summary is not invalidated because it contains attendance and work-report metrics, not task counts. Failed mutations do not invalidate or show success feedback. Start failures use one page-level error; completion failures stay inside the confirmation dialog so the same error is not repeated in the page and dialog.

## Loading, errors, and empty states

- Initial list loading uses task-row skeletons. Initial list failure uses a page-local retry state.
- Background refresh keeps the task list visible and shows a local progress line. If refresh fails with cached results, the results stay visible with a retry notice.
- Summary failure does not block the list or show a separate alert. Unavailable tab counts use an em dash; the summary follows the same shared freshness lifecycle.
- A successful empty response distinguishes no assigned tasks from no matches for current filters. Clearing filters resets the URL state.
- Detail loading, failure, permission denial, and missing content stay within the detail dialog.
- Success toast is shown only after the backend confirms a status transition.

## Verification

Focused tests cover counts/details, shared-completion confirmation and targeted invalidation, and the no-permission state. Backend tests cover owner-scoped filtering and summaries, permission denial, and allowed/denied status transitions. Add route-history, keyboard, accessibility, and viewport checks when the page receives its visual browser review.
