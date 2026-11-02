# My Work Reports implementation

## Scope and source references

React replaces the Coming Soon destination at `/dashboard/my-reports` with an employee's daily work-report history. The dedicated create, detail, and edit paths are `/dashboard/my-reports/create`, `/dashboard/my-reports/$reportId`, and `/dashboard/my-reports/$reportId/edit`. This experience covers daily employee reports only. Flutter Engineering and Survey Site Reports remain Operations workflows; the HR/Admin `/hr/work-report` route is the separate review queue.

Flutter's `MyWorkReportsPage` is the page and contract reference. The staff mobile app informed the five-step editor, explicit draft/submit actions, work-time interaction, attachment handling, review feedback, and focused refresh behavior. React keeps the port's TanStack Query/Form and Zod stack; it does not import the mobile app's RTK Query implementation.

## List and URL state

| Search key | Meaning                                                | Default |
| ---------- | ------------------------------------------------------ | ------- |
| `status`   | `all`, `draft`, `submitted`, `approved`, or `rejected` | `all`   |
| `page`     | 10-report server page                                  | `1`     |

The employee history has one useful filter: status. Search was removed because a personal history capped at ten entries per page is easier to scan by date and status, while free-text matching adds little value to this workflow. A from/to date range was also removed because employees generally review a chronological record or choose a status; the paired controls took substantial mobile space for an uncommon use. The backend API still accepts search and date filters for other callers. Legacy `q`, `from`, and `to` URL keys are ignored by the React route. Status and pagination remain in the URL, so copied links and browser Back/Forward restore the current result view. The page shows a separate, bounded Today report lookup and paginated history; it does not calculate totals from only the loaded page.

The status filters use Flutter's segmented surface: status-colored icons and one raised selected segment. On narrow screens, keep them in a single horizontal scroller rather than wrapping the final status into an orphan row; the scrollbar uses the shared border token and stays visually subtle. Desktop history is a table-like list whose entire row opens the report, with the same status accent, work-summary hierarchy, hours pill, optional task/base/evidence/review metadata, and clear View report affordance as the mobile card. On mobile, each report is an individually actionable card: date and color-coded status lead, followed by a bounded work summary, optional task details and operational base, then hours and only available evidence/review metadata (attachment count, actual rating, or revision feedback). This adopts Flutter and the staff app's useful content order while preserving clear hierarchy and avoiding empty placeholder values.

## Guided report editor

The five steps remain the same at every screen size: **Report details**, **Work completed**, **Challenges and next steps**, **Evidence**, and **Review report**. The progress display and spacing adapt to width. Save draft stays available throughout. The final step offers **Submit for review** or **Resubmit for review** for a returned report.

The report date and operational base are recorded in Report details. Start and End use styled native browser time inputs, with a compact arrow between them and a clock-icon total strip. The browser or operating system supplies its native time selector; the React app does not add a custom clock dialog. The summary shows the total when both times are valid, the stored total while editing an existing report without replacement times, or a neutral prompt before a new range is entered. The earlier explanatory paragraph and “Calculated duration” label remain removed. The backend persists only `hours_worked`; raw start/end values are intentionally not sent or stored. A new report needs a complete, distinct time range before submission. Drafts may be incomplete. Existing reports display their stored total because their original times do not exist; that value is retained until both replacement times are entered. If the employee provides only one time, submission is blocked.

Work completed, challenges, and next-workday plans use the staff app's repeatable multiline entry pattern: numbered rows, an **Add** action, and a remove action when there is more than one row. Activities begin with one required row; the optional sections can remain empty. Each list is capped at ten entries. TanStack Form keeps the rows as arrays, then the API adapter serializes non-empty entries with newline separators into the existing string fields. Existing reports are parsed from those fields on edit, so Flutter/mobile compatibility is preserved.

Work locations are loaded from the existing whitelisted-location endpoint when the session grants `work_locations:list`; the user can still enter a base manually if the list is unavailable. The employee's report content is sent through the existing work-report fields (`work_activities`, `task_details`, and `plan_next_day`).

## Status transitions and permissions

| Status    | Employee actions                                                                        |
| --------- | --------------------------------------------------------------------------------------- |
| Draft     | Continue editing, save, submit, or delete when the corresponding permission is present. |
| Submitted | Read review state and feedback; withdraw to draft before editing.                       |
| Rejected  | Review feedback, revise, save as draft, resubmit, or delete when permitted.             |
| Approved  | Read-only, including any reviewer rating, feedback, and review date.                    |

The shell route checks list permission for the sidebar destination. Create, detail, and edit routes additionally check their specific `work_reports` permission. The page still checks operation permissions before presenting actions, and backend ownership, branch scope, and status-transition checks remain authoritative. The API's existing withdrawal contract is `PUT /api/v1/work-reports/{id}` with `{ "status": "draft" }`; no separate withdrawal endpoint was introduced.

## API and compatibility

| Operation                                                | Existing endpoint                                    |
| -------------------------------------------------------- | ---------------------------------------------------- |
| List, server-side date/status/search filters, pagination | `GET /api/v1/work-reports/`                          |
| Detail                                                   | `GET /api/v1/work-reports/{id}`                      |
| Create draft/submission                                  | `POST /api/v1/work-reports/`                         |
| Update draft/revision                                    | `PUT /api/v1/work-reports/{id}`                      |
| Withdraw submitted report                                | `PUT /api/v1/work-reports/{id}` with `status: draft` |
| Delete draft/rejected report                             | `DELETE /api/v1/work-reports/{id}`                   |
| Upload an attachment                                     | `POST /api/v1/others/upload-file`                    |
| Approved work locations                                  | `GET /api/v1/biometric/location/whitelisted`         |

The personal list request includes the current employee's internal ID so a broad listing permission cannot widen the personal list. React sends only the selected status and page for this employee history. The existing paginated response and Flutter response fields are unchanged. The additive API `search` behavior retains numeric employee-ID matching for management listings; nonnumeric search now checks the user's report content fields. No database migration or raw time fields were added.

Uploads are capped at 15 MB per file in the UI and remain subject to the backend's validation and blocked-file rules. Fetch does not expose upload-byte progress, so the interface reports the current file and `n of total` while each sequential upload is pending; it does not display a fabricated percentage. Uploaded URLs and form values remain in the editor if the report save fails. Images preview on detail; other files open in a new tab for browser preview/download.

Field validation and server field errors stay beside their controls. A single persistent form alert explains save or upload failures. A successful toast appears only after the report mutation is confirmed by the server. No toast is shown for query refreshes.

## Data freshness and invalidation

| Query                          | Scope and freshness                                    | Revalidation                                                         |
| ------------------------------ | ------------------------------------------------------ | -------------------------------------------------------------------- |
| Filtered list and Today lookup | User, employee, filters, page; `standard` (60 seconds) | Stale route entry/revisit, browser focus, or reconnect; no interval. |
| Report detail                  | User, employee, report ID; `standard` (60 seconds)     | Stale route entry/revisit, browser focus, or reconnect; no interval. |
| Work locations                 | User and employee; `reference` (300 seconds)           | Stale route entry, focus, or reconnect; no interval.                 |

The API client's query functions receive TanStack Query's `AbortSignal`. Background refresh keeps existing results visible; first-load errors have local retry; the Today lookup can fail independently from history. Work Reports has no generic Refresh action; retry remains beside a failed section.

After create, edit, submit, withdraw, or delete succeeds, the implementation updates the returned detail when available and invalidates all filtered report lists, the personal dashboard report query, and the workspace personal overview. HR overview is not invalidated: its current endpoint has no daily-report queue or report-derived metric. Inactive affected queries remain cached but stale until their page is opened. No unrelated modules or all-query cache are invalidated.

## Focused review decisions and implementation

- Keep the feature boundary: report API/query contracts and invalidation stay in `work-reports`; shared controls own generic presentation and input interaction. Work-hour calculation, replacement-time rules, and cross-field validation remain feature-owned.
- For later page ports, use the Service Operations upload, field-feedback, and error-handling patterns as architecture references (`../bomach_os_frontend/services/docs/design-system.md`, `../bomach_os_frontend/services/docs/error-handling-and-feedback.md`, and `../bomach_os_frontend/services/src/modules/specialized-services/real-estate/PropertyImagesEditor.tsx`). Keep their interaction discipline and accessible icon controls; do not copy their app-specific theme or expose workflow-specific actions that the web platform cannot support.
- The shared `DatePickerField` stores controlled ISO `YYYY-MM-DD` values and supports `FormControl` labels, required/invalid state, inline descriptions, min/max, month/year selection, Today, and optional Clear. It opens a viewport-clamped portal popover at all widths, including phones; the popover is constrained to the available viewport and scrolls internally when needed. Selecting a day applies it immediately. Day buttons expose full accessible dates, selected/today semantics, arrow/Home/End/PageUp/PageDown navigation, Escape close, and focus return. The popover stays inside 320px viewports.
- Work hours use styled native browser time inputs with the staff app's Start → End order and arrow, then a compact clock-icon total strip. The inputs sit side by side from 360px and stack below that width. One range error describes both controls and clears when the pair becomes valid. The custom circular clock dialog was removed after review; no app-built clock dialog or extra work-time explanation is part of this form.
- Work completed, challenges, and next-workday plans use numbered multiline rows with Add and conditional Remove actions, matching the staff mobile app. Activities begin with one required row; optional sections remain empty until an item is added. Each list is capped at ten rows. Form state keeps arrays and sends non-empty entries as newline-separated text in the existing API fields.
- Repeated textareas grow to fit entered content, use numbered row headers, and retain concise **Add activity**, **Add challenge**, and **Add next step** actions. Optional sections do not render empty-state prompts; only the required activity field gets a red required marker.
- Desktop uses a persistent step rail with concise step names beside the form. At narrower widths it becomes a compact current-step header and progress bars while preserving the same five-step sequence. Reached steps are keyboard- and pointer-selectable at both sizes. Challenge and next-workday editors sit side by side when the viewport permits; fields stack at smaller widths.
- Evidence uses a clear drop area, a keyboard-accessible **Choose files** action with upload/paperclip icons, per-file type icons, name/size/upload state, and removable rows. The drop area expands across the available desktop width while empty, then shares space with the file list after selection. The shared evidence row component is reused in review and report detail; detail adds image thumbnails and safe open links.
- The final review and detail page share the same report metadata and content sections. Review adds Edit actions; detail adds status and reviewer information. Empty optional content is omitted, and an empty optional group never leaves a placeholder card behind.
- Keep the five-step workflow and Save draft at each step. The desktop step rail and compact mobile progress bars let users return to any step they have reached; future steps stay unavailable until reached through Continue. Switching steps preserves all current form values. Keep the rail concise by showing step names without explanatory text. Report date is required to leave the first step and completed work is required to leave the second; draft save remains available. Submission still requires a complete time range for a new report, while an existing stored duration remains valid if both replacement times are blank.
- The report Today panel, edit form, and detail view retain cached data after a failed background refresh and show one local retry notice. A first-load failure still uses the page/section error state. Mutation success feedback remains server-confirmed, and existing upload/save errors remain singular.
- `PageHeader` now accepts a consistent upper-left `backLink`, shown above the title. Report create returns to the list; detail returns to the list; edit returns to detail. Links and successful actions carry only the validated `status` and `page` search state; legacy `q`, `from`, and `to` query parameters are dropped. Direct links have canonical fallback parents. No arbitrary browser-history target is used.

## Verification

Focused React tests cover URL normalization, time calculation including overnight ranges, API mapping, form validation and draft preservation, repeatable report rows, detail actions, the accessible calendar, date selection, keyboard navigation, and cached data after background refresh failures. Backend tests cover report-content search, numeric employee-ID compatibility, and owner scope. The editor was visually inspected at a 1440px desktop viewport and the existing narrow viewport; the complete width matrix, breakpoint edges, zoom, and keyboard audit remain outstanding.
