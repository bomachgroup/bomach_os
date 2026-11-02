# Port Decision Log

This records the user's direction separately from recommendations and questions that still need verification. Update it when a decision is confirmed or changes.

## Confirmed direction

- Company Profile at `/company` is a focused, permission-gated identity/settings page for company details, branding, and backend-supported operating defaults. Require `company_settings:view` to enter and read; expose edits only with `company_settings:update`. Save each section through its matching API. The page does not replace Company Overview metrics, Board, Compliance, Approval Workflows, or Approval Requests; Shareholder management is separate follow-up work. See [company-profile-implementation.md](company-profile-implementation.md).
- Do not show seeded placeholder identity as real company data. Existing records with real name and email values are migrated as configured; new/default records are explicitly unconfigured until a valid identity save. Persist only the supported optional `industry` and IANA `time_zone` additions; do not create substitute contracts for approval mode, notification channels, or GDPR/CCPA settings. The saved timezone is displayed on Company Profile only in this implementation.
- Departments & Units uses the backend's six fixed department categories and persisted descriptions; units carry only name, parent department, and description. Do not expose unsupported unit status/head, department branch assignment, generated department codes, or delete actions. Org Chart is a read-only role-position chart, not employee reporting. Show active direct, dotted-line, and escalation relationships in separate visual treatments, and keep each exact saved branch/department/unit tuple separate from company-wide scope. See [company-organization-implementation.md](company-organization-implementation.md).
- The signed-in employee's read-only Monthly Scorecard belongs under Workspace > My Work > My tasks & goals and uses the navigation label **My Scorecard**. Keep `/hr/monthly-scorecard`, its existing `monthly_scorecards:view_own`/`view` access checks, and the data contract unchanged; HR-wide scorecard reporting remains in HR/Admin.

- Port all six Workspace/Dashboard destinations, all 15 Company destinations, and all 17 HR/Admin destinations owned by the Flutter Bomach OS app, along with the Bomach shell pieces needed to host them.
- Keep Services, Marketing, and Finance in their own applications. Hide their links in the React shell during this phase; do not port or edit those app codebases.
- Preserve current Flutter page UI and behavior as the reference. The authenticated shell may use the user-approved navigation improvements below without changing routes, permissions, or page workflows.
- Use current Flutter Bomach OS as the baseline for each shared design pattern, then assess whether the web implementation can improve consistency, accessibility, responsive behavior, or maintainability. Keep expected workflows and visible results intact by default; discuss and record visible deviations before applying them broadly.
- Use four mobile-first responsive cutovers: 480px (phone), 700px (tablet, retained from Flutter), 1100px (desktop, retained from Flutter), and 1440px (wide desktop). This creates five review ranges; use 375, 600, 900, 1280, and 1600px as representative review widths. Routes should only change layout at a cutover when their content requires it.
- Keep a compact 64px app bar below 1100px with the menu control, Bomach identity, and permitted notifications. At 1100px and above, remove the separate app bar; keep the permission-gated notifications control beside the brand and collapse action at the top of the persistent sidebar. Give each route a distinct, full-width-in-content page heading band with a subtle bottom border, a clear title hierarchy, meaningful clickable parent breadcrumbs, optional short descriptions, and route-specific actions. Keep the band sticky on desktop while the document scrolls; let it scroll normally below 1100px. Align the padded page body beneath it. Do not repeat a generic Workspace root or show redundant category context. Keep page tabs and filters on a distinct secondary row only when a real page needs them; Coming Soon pages have no invented description or action. Below 1100px, navigation uses a keyboard-accessible overlay drawer; at 1100px and above, a persistent sidebar is 300px expanded or 72px collapsed. Hover expands the collapsed rail in the page layout so content shifts with it; pointer leave starts the collapse immediately, with a short width transition. Keyboard focus keeps it open until focus exits. An explicit action can keep the sidebar expanded. Keep the account/profile entry at the sidebar bottom and place sign-out in its profile dialog with a confirmation step; do not add a permanent page footer.
- Give sidebar sections clear spacing and separators, present pinned destinations in a quiet bordered surface, style groups as disclosure rows, indent their child routes on a subtle neutral vertical guide with matching horizontal branches to each child, and mark the active destination with a slim primary accent. Keep the account area distinct from navigation and style sign-out as a destructive action.
- Keep the shell profile dialog as a compact identity/status summary with a link to the full read-only Profile page. Show personal, contact, employment, and account details on that page; do not expose compensation, bank, pension, or benefits fields and do not add profile editing. Keep two-factor settings on the full Profile page, require password confirmation in a focused dialog for either enable or disable, and link Change password to the existing reset flow with the signed-in email prefilled.
- Use this sidebar ownership and subgroup map for the React port while keeping every Flutter route path and backend permission contract intact. Workspace has a primary Overview link, a collapsible My Work group, and Company; People has HR/Admin. Company ownership is split deliberately from employee self-service: Attendance, My Leaves, My Loans, My Pay, and My Scorecard are under My Work, while Employee Evaluation remains in HR/Admin and no employee-facing evaluation page is added. Roles & Permissions remains under HR/Admin; the employee's own Role remains under My Work. My Loans is an owner-scoped request workflow; `/hr/loans` is reserved for cross-employee review. `/hr/benefits` is renamed Payroll in the UI and remains the HR payroll register; `/dashboard/my-pay` is a separate read-only signed-in employee payslip history. Backend owner scoping remains authoritative. Use navigation-only labels to distinguish My profile from Company profile.
- Group My Work into **My tasks & goals** (Tasks, personal Work Reports, Target, My Scorecard), **Time & leave** (Attendance, My Leaves), **Pay & finance** (My Loans, My Pay), and **My account** (Profile, Role). Group Company into **Organization** (Company Profile, Branch, Departments & Units, Org Chart), **Governance & oversight** (Board, Compliance Dashboard, Audit Log, Approval Requests), **Workflow & communication** (Approval Workflows, Workspace Approvals, Broadcast), and **Planning & resources** (KPI Management, OKR Board, Knowledge Base, Assets). Approval Requests is a distinct review route; Approval Workflows remains workflow configuration and Compliance remains its own register. Group HR/Admin into **People & access** (Employees, Recruitment, Roles & Permissions), **HR operations** (Work Calendar, Leave Requests, Training, Loans, Payroll), **Performance & reporting** (Performance, HR Work Reports, Employee Evaluation, Performance Engine), and **Recognition & employee relations** (Awards & Recognition, Performance Leaderboard, Disciplinary Process). Each subgroup is collapsible and its open state is saved locally; navigating to a destination opens its parent group and subgroup. Public route URLs remain stable when sidebar ownership or labels change; legacy HR finance URLs redirect owner-only users to their My Work pages while broad-list users remain on the HR registers.
- Use an inline page-search input with a live suggestions list, keyboard navigation, Escape, and Ctrl/Cmd+K focus. Pinned destinations appear in a Pinned shortcuts section and stay in their original group. Reveal the unpinned route's pin action on hover or keyboard focus; once pinned, keep its marker visible. On touch, use a row actions menu for unpinned routes.
- Center shared dialogs on tablet and desktop; keep the full-screen treatment on phone-sized screens.
- Add one consistent Lucide icon family for the shell. Use a permission-gated notification bell in the mobile/tablet app bar and desktop sidebar header, wired to the verified `/api/v1/notifications/` list, `/stats`, per-item read, and read-all endpoints. On desktop, open its panel beside the sidebar. Do not show an unread badge unless the API returns the count and the user has the required permission. Follow only safe, same-origin notification links that resolve to permitted React routes.
- Keep active-route behavior, expandable groups, and saved sidebar preferences. The route manifest remains the shared source for route registration, permissions, breadcrumbs, and sidebar order.
- Use route paths for page/record identity and TanStack Router search parameters for durable view state such as search, filters, sort, pagination, tabs, and view mode. Validate search per route; keep transient overlays, sidebar preferences, and unsent drafts outside the URL. Add actual query state with each real page rather than to Coming Soon routes.
- Register every in-scope sidebar route and active reachable direct/detail route through one Coming Soon page until individual Flutter pages are reviewed and ported. Preserve safe deep links and permission guards. Select the first real page with the user after the shell is reviewed.
- Keep Flutter `textMuted` (`#94A3B8`) available as `text-subtle`, but use the existing Bomach `neutral500` (`#64748B`) for readable `text-muted` because it meets normal-text contrast on the app's light surfaces. Reserve `text-subtle` for nonessential decoration.
- Standardize how forms, field errors, success, loading, empty, page errors, and section errors work across the port.
- Use one upper-left `PageHeader` back link for nested pages, with a canonical safe parent route; carry only validated list/search state through report detail and edit links. Do not rely on browser history for the only way back.
- Use the shared controlled `DatePickerField` for dates: an anchored, viewport-clamped calendar popover at all widths, with keyboard calendar navigation and focus return. On narrow screens it remains a compact popover, constrained to the viewport and internally scrollable; choosing a day applies it immediately. Use a styled native browser time input for work-report times; the browser or operating system supplies its time selector. Do not use the custom circular clock dialog that was tried in the report form and reverted after review. Feature-owned rules validate ranges and calculate durations.
- Work carefully in small steps. The user makes product decisions; Codex writes the implementation side by side with the user.
- Keep the Flutter reference in its existing local checkout. The React port branch is clean of Flutter project files and will host the React app at its root.

## Agreed working architecture

The user agreed to document this direction after comparing it with the Service Operations implementation. Use it as the implementation baseline unless source review or a later product decision changes it:

- React with TypeScript for the UI.
- Vite for the browser development server and build.
- TanStack Router for routes and URL state.
- TanStack Query for server state and mutation/cache behavior.
- TanStack Form and Zod for form state and validation.
- Tailwind CSS with Bomach-specific semantic tokens for styling.
- One shared typed Fetch transport implementation, with centrally configured client instances for separate API origins if required.
- Shared ApiError normalization and context-aware error presentation; feature API and query code never show toasts or navigate.
- Feature-oriented Company and HR module slices, with generic cross-module infrastructure and UI under shared.
- ESLint and Prettier for source consistency; Vitest, Testing Library, and MSW are the planned verification toolchain, subject to compatibility at scaffold time.
- No Redux or RTK Query for the current scope. Reconsider only if a concrete client-only global-state need is found; never duplicate the same server cache across both query systems.
- Browser authentication uses dedicated `/api/v1/auth/browser/` cookie endpoints. Bearer endpoints and their response shapes stay compatible with Flutter/mobile/other clients. See [authentication.md](authentication.md) for cookie, CSRF, reset, session-bootstrap, routing, and feedback rules.
- Keep protected route access fail-closed until `/auth/me` returns the current user's identity, role summary, and granted permissions and the employee profile is loaded. No role yields an empty permission map; missing/malformed permissions or profile failures block the app and offer retry. Do not require `roles.view` for a user to load their own grants. The full permission catalogue is separate and is not a session-bootstrap dependency. Authenticated-only routes can remain available to a user whose permission map is empty; show No Access only when no implemented route is permitted.
- Expired access can trigger one coordinated refresh and one retry per request. Logout and password reset clear browser auth state; password reset increments a user-wide token version and signs out every device.
- Auth pages remain outside the application shell. Deep links are preserved only for safe internal paths and only honored when an implemented route is permitted. If no implemented route is available, show no access.
- The default authenticated landing starts with Dashboard Overview in navigation order; an authorized safe deep link overrides it. Routes with no explicit Flutter permission requirement remain authenticated-only, and source permission gaps are documented rather than silently guessed.
- Biometric web entry preserves Flutter's unavailable state; passkeys are explicitly deferred. Two-factor enable/disable stays in the Profile experience and is not a separate page.

Next.js is not selected for the current authenticated, browser-first scope. No exact dependency versions have been pinned; choose compatible versions when scaffolding.

## Working interaction standard

Adopt Service Operations' placement rules and component ownership patterns, adapted to the Flutter Bomach visual language:

- Field problems appear with their fields.
- Whole-form problems persist on the form.
- Temporary action feedback uses a toast when the page remains usable.
- Partial page failure uses a section error state; primary data failure uses a page error state.
- Major workflows use a success state; small confirmed actions use a toast.
- Do not show duplicate messages or expose raw backend errors.

Detailed rules are in interaction-standards.md. The form validation timing and exceptional workflows remain subject to screen-by-screen review.

## Still to verify

The framework and data/state-management direction is agreed. These are remaining source reviews, product decisions, and implementation details—not reasons to add a second state-management stack:

### Source and backend contracts

- Verify the configured route inventory against the deployed test build; complete the screen-by-screen inventory of actions, dialogs, permissions, data, and state behavior. Confirm Company/HR ownership versus standalone-app boundaries.
- Current API origins for auth and operations, environment selection, CORS requirements, and which endpoints use which origin.
- Per-feature API contracts, exact permission requirements, and route/action mappings for the Company and HR pages.
- Deployment integration settings for the new test and production origins, including `BOMACH_WEB_AUTH_ORIGINS`, Vercel proxy origins, and deployed cookie round-trip verification.
- Backend response and validation-error shapes, including mapping server field names to form controls.
- Whether request/response types should be handwritten from verified contracts or generated from OpenAPI, and which response boundaries need runtime validation. Existing specs must be checked before using them as code-generation input.
- Exact permission names and route/action mapping, with unresolved/loading behavior.
- Existing route paths, deep links, and return-navigation behavior that must remain stable.
- Keep Employee Evaluation in HR/Admin, including its existing `list_own`/`view_own` access and API contract. Do not create a separate employee-facing evaluation page as part of the finance route split.

### Browser and visual parity

- Browser support for camera/liveness, geolocation, uploads/downloads, exports, and notifications used by in-scope screens.
- Exact screens, assets, icons, charts, responsive breakpoints, and visual measurements from the Flutter reference. Pick icon/chart libraries only if the inventory requires them.
- How the web shell launches, returns from, and shares identity with separately hosted or embedded standalone modules.

### Notifications — in-app implementation

- The in-app experience includes the shell bell, a full `/notifications` inbox, and `/notifications/$notificationId` details. The inbox filter is URL-backed; details show versioned structured metadata in a human-readable form and offer only same-origin, registered, permission-checked related destinations.
- The inbox/list, stats, detail, mark-read, and mark-all operations use the verified backend notification endpoints and their individual `notifications.list`, `notifications.view`, `notifications.mark_read`, and `notifications.mark_all_read` permissions. The backend remains authoritative and scopes detail lookup to the signed-in user.
- An authenticated-shell listener checks the newest notification items every 60 seconds while the tab is visible, establishes its first successful response as a baseline, and shows one in-app toast for newly observed IDs. It rechecks on visibility/focus/reconnect and pauses while hidden. Tab coordination uses BroadcastChannel and a local-storage set of IDs only; notification content is not persisted there.
- The unread badge retains its live cadence (30 seconds while the bell is open, 60 seconds while closed) and pauses while the document is hidden. Inbox and details use standard freshness and do not poll while being read.
- This is best-effort in-app delivery while Bomach is open. No browser notification permission is requested. Web Push remains deferred and requires its own explicit product and backend work; mobile Expo push registration is not reused. See [notifications-implementation.md](notifications-implementation.md).

### Operational choices

- API environment configuration and hosting target, including SPA fallback and eventual cutover. Production cutover remains a separate decision after parity review.
- Exact dependency versions and lockfile/package-manager choice at scaffold time.
- Whether Storybook adds enough value for the actual shared-component inventory.
- Route-specific query freshness, retry, invalidation, and optimistic-update behavior; use confirmed backend semantics rather than a blanket policy.
- Workflow-specific exceptions to the default form validation timing and feedback rules.

See architecture.md and migration-plan.md for the technical and sequencing details.
