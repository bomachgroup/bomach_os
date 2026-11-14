# My Work and Operations page ownership

## Purpose and status

This note defines where employee-owned work belongs compared with organization-wide and project-scoped Operations workflows. It records the current React port, the Flutter reference, and the proposed scope for porting Operations.

The ownership split and presentation are implemented: accessible Daily, Engineering, and Survey reports share one permission-scoped **My Work Reports** register. The organization-wide Engineering and Survey registers stay in Operations.

## Ownership rule

- **My Work** answers: “What has been assigned to me, and what have I submitted?” It uses the signed-in employee’s data scope and self-service actions.
- **Operations** answers: “What work is the organization or project coordinating?” It uses project/worksite context and the permissions to view or manage the wider register.
- A record may appear in both areas when each view has a different scope. Both views must use the same backend record; do not copy or create a second version of the task or report.
- Backend permissions and ownership checks remain authoritative. A page must not widen its own scope because a user can open an Operations route.

## My Work destinations in the React port

These destinations are already represented in the React route/navigation model. Some page URLs retain their existing `/hr/` prefix for compatibility while navigation places them under My Work.

`/dashboard` remains the Workspace landing/overview; it is not an item inside the My Work subgroup.

| My Work group    | Page         | Route                          | Current React scope                                                                                                                                                           |
| ---------------- | ------------ | ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| My tasks & goals | Tasks        | `/dashboard/my-tasks`          | Implemented. Lists the signed-in employee’s assigned tasks, with personal status, priority, sort, pagination, detail, and permitted start/complete actions.                   |
| My tasks & goals | Work Reports | `/dashboard/my-reports`        | One date-sorted register of accessible Daily, Engineering, and Survey reports, permission-filtered type choices, type-specific detail/edit, and permitted own-record actions. |
| My tasks & goals | Target       | `/dashboard/my-target-reports` | Employee-facing target and progress-history experience.                                                                                                                       |
| My tasks & goals | My Scorecard | `/hr/monthly-scorecard`        | Read-only scorecard for the signed-in employee.                                                                                                                               |
| Time & leave     | Attendance   | `/hr/attendance`               | Employee attendance experience; access can be own-scoped.                                                                                                                     |
| Time & leave     | My Leaves    | `/hr/leaves`                   | Employee-owned leave requests and history. HR’s review register remains separate.                                                                                             |
| Pay & finance    | My Loans     | `/dashboard/my-loans`          | Employee-owned loan submissions and status. HR’s cross-employee register remains separate.                                                                                    |
| Pay & finance    | My Pay       | `/dashboard/my-pay`            | Read-only payslip history for the signed-in employee. Payroll administration remains separate.                                                                                |
| My account       | Profile      | `/dashboard/my-profile`        | Signed-in employee’s profile.                                                                                                                                                 |
| My account       | Role         | `/dashboard/role`              | Signed-in employee’s role information.                                                                                                                                        |

### Combined personal work-report register

Flutter’s `MyWorkReportsPage` combines the employee’s daily work reports with that employee’s Engineering Site Reports and Survey Site Reports. React now matches that personal feed using the dedicated site-report APIs. It does not fetch the broader `/reports/` endpoint or filter a mixed feed client-side.

Confirmed port behavior:

1. Keep the signed-in employee’s Engineering and Survey Site Reports in My Work as distinct report types with their own APIs, fields, statuses, validation, and permissions.
2. Keep **Engineering Site Reports** and **Survey Site Reports** organization-wide registers in Operations. They remain the places for authorized cross-employee review and operational management.
3. Let an employee open, edit eligible own drafts/returned reports, submit drafts, and delete eligible own drafts/returned reports from My Work. Return to the same filtered personal list and keep ownership enforcement on the server.
4. Show **New report** choices only for report types whose create permission is granted. Engineering/Survey creation also requires `worksites:list`; the form first requires a worksite selection, while the backend assigns the signed-in employee as owner.
5. Do not reproduce Flutter’s fetch-large-feed-then-filter-by-employee-ID approach in React. Site lists pass the signed-in employee ID and the backend enforces owner and role scope. Roles can grant `submit_own` and `delete_own` for self-service actions.

The single register lives at `/dashboard/my-reports` and uses URL-backed type, status, and global page state. Users see only filters for report families they can list. Legacy `tab=daily` and `tab=site` links map to the matching type filter. A user's broad `list` permission follows the backend role branch scope; `list_own` remains owner-only. Do not add a separate My Site Reports sidebar destination or move the full operational registers into My Work. Reviewer decisions remain in Operations.

## Operations destinations to port

These are the Flutter Operations navigation destinations recorded in the route inventory. They are not employee-owned My Work pages, even when an employee can create or view a record.

| Operations destination   | Route                             | Ownership and role                                                                                                              |
| ------------------------ | --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| Operations overview      | `/operations`                     | Organization/project operations overview.                                                                                       |
| Projects                 | `/works/projects`                 | Project register and project selection.                                                                                         |
| Worksite                 | `/works/worksite`                 | Worksite register and worksite administration.                                                                                  |
| Tasks                    | `/works/tasks`                    | Shared operational task register: search, create, assign, edit, delete, and manage work.                                        |
| Engineering Site Reports | `/works/engineering-site-reports` | Operational report register for authorized wider-scope review and management.                                                   |
| Survey Site Reports      | `/works/survey-site-reports`      | Operational report register for authorized wider-scope review and management.                                                   |
| Contracts                | `/works/contracts`                | Organization/project contract register.                                                                                         |
| Meetings                 | `/hr/meetings`                    | Listed inside Flutter’s Operations menu despite the `/hr/` URL; keep its established route and Operations navigation ownership. |

The React route manifest registers these as protected sidebar destinations using the Flutter paths, labels, order, route permissions, and menu visibility resources. Operations, Projects, Worksite, Tasks, and Engineering Site Reports are ported. Survey Site Reports, Contracts, and Meetings remain future page ports; project details and their eight tabs stay nested inside Projects.

### Detail routes and project/worksite subviews

Flutter also registers detail routes that are not separate sidebar destinations:

| Detail view                | Flutter route                                              |
| -------------------------- | ---------------------------------------------------------- |
| Project detail             | `/works/projects/detail` and `/operations/projects/detail` |
| Task detail                | `/operations/task/detail`                                  |
| Worksite detail            | `/operations/worksite/detail`                              |
| Contract detail            | `/operations/contract/detail`                              |
| Operations timeline detail | `/operations/timeline/detail`                              |

Flutter's task and worksite detail concepts are implemented as protected React routes at `/works/tasks/:taskId` and `/works/worksite/:worksiteId`; Engineering Site Report details use `/works/engineering-site-reports/:reportId`. Project details are implemented at `/works/projects/:projectId`. Contract and timeline detail pages remain future work. Both Flutter project paths remain compatibility references for the same project-detail experience.

Project detail contains these project-scoped tabs: **Overview**, **Members**, **Work site**, **Files**, **Milestone**, **Tasks**, **Associates**, and **Meetings**. Project Tasks remains a project-scoped Operations view; the employee’s assigned items remain in My Tasks.

The project Work site view contains **Employees**, **Site Equipment**, **Site Tasks**, **Engineering Reports**, and (when permitted) **Survey Reports**. A worksite detail can also link into Engineering and Survey report registers prefiltered to that worksite. These are contextual Operations views, not new My Work destinations.

## Shared records: tasks

The personal and operational task pages serve different jobs:

| Area                           | Data scope                                           | Typical actions                                                                                                                 |
| ------------------------------ | ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| My Tasks                       | Tasks assigned to the signed-in employee             | Review assignment, start it, and mark it complete when permitted. Completion is a shared status change and should be confirmed. |
| Operations Tasks               | Tasks within the user’s authorized operational scope | Search the register, create tasks, assign employees, set project/deadline/priority, edit, and delete when permitted.            |
| Project detail → Tasks         | Tasks for the selected project                       | View and manage work in its project context.                                                                                    |
| Project Work site → Site Tasks | Site-task view for the selected worksite/project     | View and manage the site-specific tasks in context.                                                                             |

An assignment created or changed in Operations should appear in the assignee’s My Tasks view through the existing personal task API. My Tasks must not become a second task-management register, and Operations must not be replaced by My Tasks.

## Route and permission boundaries

- Keep personal and operational list/detail queries separate, with cache keys that include the current user, scope, and filters.
- Use own-scope permissions such as `tasks:list_own` for personal views and broader `tasks:list`/management permissions for operational registers. A broad permission must not make a personal list return other employees’ records.
- Keep create, update, delete, submit, approve, and reject controls gated by their specific action permissions; page visibility alone does not grant each action.
- Project/worksite filters narrow the operational register; employee ownership narrows My Work. These filters are not interchangeable.
- Keep personal deep links in the My Work area and operational record links in their project/worksite context. Reuse the same record ID and backend state when linking between them.

## Porting sequence

1. Keep the existing My Tasks and daily My Reports experiences intact while porting Operations.
2. Completed: Operations overview, Projects, Worksite, operational Tasks, and Engineering Site Reports are separate permission-aware destinations. Remaining: Survey Site Reports, Contracts, and Meetings.
3. Project, worksite, task, and Engineering Site Report details are implemented with contextual links; the remaining detail views follow their destination ports.
4. Personal Engineering and Survey history and creation are implemented in the unified My Work Reports register. Keep the operational registers separate as their pages are ported; they remain the place for wider-scope review and management.

## Operations register implementation notes

- Worksite, Operations Tasks, and Engineering Site Reports each use URL-backed filters and pagination, scoped React Query cache keys, permission-gated actions, and protected detail routes. Task and report registers open on Active work and Submitted / Needs review respectively; All remains available for historical review.
- A Task may optionally reference a Worksite. Existing tasks remain unlinked; no migration backfill guesses a site. Project-linked sites and tasks must share a project. Site selection can derive the task project when the chosen site is project-linked.
- Worksite deletion is allowed only when unused. Linked tasks, reports, or inventory prevent hard deletion; authorized users can instead mark the site inactive.
- Engineering Site Reports are authored by the signed-in employee. Draft/rejected reports can be edited; submitted reports can be approved or returned by an authorized non-author. Return requires a reason. Report attachments use the existing authenticated upload endpoint and retain previously saved URLs.
- Implementation, API contracts, backend rules, local fixture safety, and the verified test matrix are recorded in [operations-worksites-tasks-engineering-reports-implementation.md](operations-worksites-tasks-engineering-reports-implementation.md).

## Source notes

- React route ownership: `src/app/navigation/route-manifest.ts`.
- React route inventory: [route-inventory.md](route-inventory.md).
- React personal task contract and behavior: [my-tasks-implementation.md](my-tasks-implementation.md).
- React daily work report scope and contract: [my-work-reports-implementation.md](my-work-reports-implementation.md).
- Flutter routes: `lib/src/app_routes/app_route_constants.dart`.
- Flutter navigation ownership: `lib/src/app_routes/menu_structure.dart`.
- Flutter personal task page: `lib/pages/dashboad/my_tasks.dart`.
- Flutter My Work reports aggregation: `lib/pages/dashboad/my_work_reports.dart`.
- Flutter operational task page: `lib/pages/operations/task.dart`.
- Flutter project tabs and project tasks: `lib/pages/operations/each_project.dart` and `lib/pages/operations/widget/project_task_table.dart`.
- Flutter worksite/project site views: `lib/pages/operations/worksite_detail.dart` and `lib/pages/operations/widget/project_work_sites.dart`.
