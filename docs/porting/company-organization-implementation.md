# Company Organization: Departments, Units, and Org Chart

## Source review and scope

Flutter's Departments & Units screen has separate department and unit views, text search, department filtering for units, pagination, and create/edit dialogs. Department writes store the fixed category and description. Unit writes store a name, parent department, and description. The older Flutter model also exposes status and head-of-department values that have no persisted backend contract; React does not display or write them.

Flutter's Org Chart is based on role positions and role reporting lines. This port does not infer employee-to-employee reporting from employee records and does not edit the reporting structure. Direct, dotted-line, and escalation relationships are shown with separate treatments.

## Backend contracts and permissions

- `/api/v1/organization/department` lists, creates, and updates department records. The category list is fixed to `operations`, `marketing`, `finance`, `it`, `hr`, and `legal`; responses include `id`, `name`, and `description`.
- `/api/v1/organization/department/choices` supplies the fixed categories. It requires `departments:list`.
- `/api/v1/organization/unit` lists, creates, and updates units. Responses include `id`, `name`, `department_id`, `department_name`, and `description`; writes accept the name, parent department ID, and description.
- The duplicate organization catalog router registration was removed. The canonical organization router preserves the Flutter-used paths and applies `departments` or `department_units` create/list/update permissions.
- `/api/v1/roles/reporting-chart` returns role positions plus active reporting relationships grouped by their exact saved `(branch_id, department_id, unit_id)` tuple. Company-wide is the all-unset tuple. It requires both `roles:list` and `role_reporting_lines:list`.
- Chart and reporting-line reads apply the caller's assigned-branch visibility. Company-wide lines remain visible to branch-scoped roles; branch-specific lines and roles outside that scope return no data (role detail reads return not-found). Dotted-line and escalation lines remain secondary relationships and do not alter direct hierarchy.
- No database migration was required. There is no delete action or contract for unit status, unit head, department branch assignment, or generated department codes.

## React behavior

### Departments & Units

- `/company/department` is available with either `departments:list` or `department_units:list`; each tab and each create/edit action checks its own permission.
- The active tab, search, parent-department filter, and page are validated URL state. The directory uses a desktop table and compact mobile cards. The unit editor needs `departments:list` to load permitted parent choices; unit records remain readable without it.
- Department categories already in use cannot be selected for a second record. Editing retains its existing category. There is no delete action.
- Failed saves keep the editor draft open and show a local error. A tab failure does not replace other page content.

### Org Chart

- `/company/org-chart` requires both `roles:list` and `role_reporting_lines:list`; it is view-only.
- The selected exact scope is URL-backed. The company-wide chart includes the accessible role catalog, including unconnected positions. A scoped chart includes roles associated with reporting lines saved in that exact tuple. The backend retains scopes that have only inactive stored relationships, but returns no inactive line as a visible relationship.
- Direct reporting is displayed as a hierarchy. Dotted-line and escalation relationships are listed separately with visible text labels and different borders/icons, so they are not confused with direct reporting.
- The scope selector stays usable on narrow screens. Chart nodes wrap within the page width; no graph library or pan-only canvas is required for this data size and view-only workflow.

## Data lifecycle

- Department list, unit list, department choices, and chart data are reference data with a 300-second freshness window. There is no polling.
- Active queries revalidate stale results on route entry, window focus, and reconnect. Cached rows remain visible while refreshing; a failed refresh keeps the cached result visible with a local retry state. Initial failures show an error only in the affected tab or chart.
- Department create invalidates department lists and category choices. Department update additionally invalidates unit lists and Org Chart scope labels. Unit create/update invalidates unit lists; unit update also invalidates Org Chart scope labels. These changes do not invalidate Company Overview metrics.
- All requests use the shared typed API client and query keys scoped by user and employee identity. Search and pagination are URL-owned; unsaved dialog drafts remain local.

## Verification plan

- Verify each catalog list and write permission independently, category choices, uniqueness constraints, descriptions, unit parent assignment, pagination, and search.
- Verify Org Chart scope grouping, active direct/dotted-line/escalation relationships, inactive-line exclusion, empty/unconnected positions, and branch-limited access.
- Review keyboard access and mobile, tablet, and desktop layouts. Automated component tests do not substitute for a live UI pass when the local app and a verified non-production backend are available.
