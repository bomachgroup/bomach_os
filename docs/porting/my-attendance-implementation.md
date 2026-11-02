# My Attendance implementation

## Routes and access

- Canonical page: `/hr/attendance`.
- Compatibility route: `/employee/attendance` redirects to the canonical page.
- Date range and page are validated URL search state: `dateFrom`, `dateTo`, and `page`. Invalid or reversed ranges are discarded and reset to page 1.
- Today, summary, history, biometric readiness, clocking, and face enrollment require `attendance.list` or `attendance.list_own`. The backend checks the same permission and scopes personal requests to the signed-in employee.
- Work-location listing and status use `work_locations.list` or `list_own`. Proposals, pending proposal deletion, and extensions use their corresponding `submit`, `delete_own`, and `request_extension` permissions. The location verification endpoint remains separately permission-checked.

## Page and API behavior

The page presents a centered live clock and today's attendance card after the month-to-date summary. The clock uses Africa/Lagos time synchronized from the API `Date` response header and updates every second with `hh:mm:ss a`; it falls back to the device clock if synchronization is unavailable. Face verification and work-location status controls stay beside the title on desktop and in a compact two-row block on mobile. The global Refresh button is removed. The controls open face setup or the work-location section/registration flow. A clock action appears only when today's next action, both face flags, backend location readiness, and GPS-verification permission are confirmed. Selecting it opens the preflight flow, which refreshes today's state and readiness before beginning an ongoing GPS scan. The scan follows the React Native staff app: it shows best and latest accuracy, elapsed time, and reading count; a very strong fix (±10 m) is accepted automatically; staff can continue with a usable fix within ±30 m, resume scanning, or cancel. The selected location is verified against the server before opening the guided face check. The browser Permissions API is queried without prompting. A saved denial prevents scanning and explains the browser site-settings recovery; an undecided permission is resolved by the browser's native prompt when scanning begins. GPS, readiness, and duplicate-action errors stay in the clock flow; camera and liveness errors stay in the face dialog. Camera permission is queried before scanning; `getUserMedia` is called directly from the user's start action so an undecided permission triggers the browser prompt. Face models load only after camera access succeeds. The face dialog is stacked on mobile and uses a wider camera-plus-guidance layout on desktop. It runs the randomized center/turn/return liveness sequence locally and submits only the verified image. Enrollment and clock verification use distinct titles and submit labels.

Face enrollment lives at `/hr/attendance/face-registration`; detector runtime and model weights are served from the app's own `/face-models` assets. Work-location registration lives at `/hr/attendance/work-locations/new` and follows the staff app's two steps: keep scanning the GPS point until a strong reading arrives or staff select a usable point, then enter branch/site/remote details. The shared capture panel reports best and latest accuracy, elapsed time, and reading count, supports cancel/resume, accepts fixes within 30 metres, and auto-accepts fixes within 10 metres. Leaving the page cancels capture. Desktop adds a separate guidance panel with pin accuracy and approval requirements. Branch selection uses active geocoded branches and the server validates that the captured point falls within the selected branch boundary when submitting. Temporary remote/site requests include a future expiry date. Rejected location proposals open a new request prefilled with editable details and a freshly captured point; the rejected record remains unchanged.

The page uses the existing biometric endpoints for today's record, month summary, status, face enrollment, clocking, location listing, location verification, and location lifecycle actions. History uses the additive `GET /api/v1/biometric/attendance/history` endpoint with `date_from`, `date_to`, `limit`, and `offset`; the legacy `/attendance/my-records` response is unchanged. The history endpoint returns a paginated, employee-scoped result.

The status endpoint's HTTP `Date` header is read once on entry to keep the live clock aligned; no time polling is added. GPS and clock-readiness errors remain actionable inside the clock flow: denied/unavailable permissions, poor GPS accuracy, out-of-range positions, missing or pending approved locations, duplicate clock actions, and service errors are surfaced without clearing the user's current view. Camera and liveness errors remain in the face dialog. A successful clock action refreshes today's state, summary, history, and personal Overview attendance data. Location lifecycle actions refresh location reference data.

## Freshness

- Today: `live` (30 seconds).
- Summary and history: `history` (120 seconds).
- Biometric and work-location reference data: `reference` (300 seconds).
- Revalidate stale active-route data on entry/revisit, window focus, and reconnect. Do not poll. Local retry controls handle section errors; starting clocking refreshes today's state plus face and location readiness.

See [data-freshness.md](data-freshness.md) for the cross-page lifecycle contract.
