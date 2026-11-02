# My Leaves implementation

## Routes and access

- Register: `/hr/leaves`.
- Durable request detail: `/hr/leaves/$requestId`.
- The register stores request kind, status, and page in validated search state. Filter changes reset the page; no free-text search is included.
- Register access accepts `leave_requests.list_own` or `list`. Employee stats and detail access accept `view_own` or `view` independently; when detail access is absent, the register remains usable without linking to inaccessible records. Create, update, and cancellation actions use the corresponding permissions, with ownership and status constraints enforced by the backend.

## Request behavior

The register combines leave requests with absence and late-arrival exceptions. It shows employee-scoped request counts, supports independent kind/status filters and pagination, and uses a desktop table with compact mobile cards. Duration is shown in calendar days.

Employees can submit leave, absence, and late-arrival requests. Pending requests can be edited or cancelled when the session grants the required action. Late-arrival editing is limited to the submission day. Reviewer rejection feedback is visible in request details. **Request again** opens a prefilled create form and posts a new request, leaving the rejected record unchanged. Backend validation remains authoritative for overlaps, late-arrival date rules, duplicate late-arrival reports, and permission/ownership checks. Failed submissions retain entered values.

## API and freshness

The page uses the existing leave-request list, employee stats, detail, create, update, and cancel endpoints. List requests are explicitly scoped to the signed-in employee; backend owner scoping remains authoritative. Register list, stats, and detail use `standard` freshness (60 seconds), revalidate stale active-route data on entry/revisit, focus, and reconnect, and do not poll. Failed requests retain a local retry; the page has no generic Refresh action.

After a confirmed create/update/cancel, invalidate the employee's request list, stats, relevant detail, and personal/HR Overview summaries. Keep cached content visible during refresh and show errors/retries within the affected section.
