# Port Decision Log

This records the user's direction separately from recommendations and questions that still need verification. Update it when a decision is confirmed or changes.

## Confirmed direction

- Port all six Workspace/Dashboard destinations, all 15 Company destinations, and all 17 HR/Admin destinations owned by the Flutter Bomach OS app, along with the Bomach shell pieces needed to host them.
- Keep Services, Marketing, and Finance in their own applications. Hide their links in the React shell during this phase; do not port or edit those app codebases.
- Preserve current Flutter page UI and behavior as the reference. The authenticated shell may use the user-approved navigation improvements below without changing routes, permissions, or page workflows.
- Use current Flutter Bomach OS as the baseline for each shared design pattern, then assess whether the web implementation can improve consistency, accessibility, responsive behavior, or maintainability. Keep expected workflows and visible results intact by default; discuss and record visible deviations before applying them broadly.
- Use four mobile-first responsive cutovers: 480px (phone), 700px (tablet, retained from Flutter), 1100px (desktop, retained from Flutter), and 1440px (wide desktop). This creates five review ranges; use 375, 600, 900, 1280, and 1600px as representative review widths. Routes should only change layout at a cutover when their content requires it.
- Keep a compact 64px app bar below 1100px with the menu control, Bomach identity, and permitted notifications. At 1100px and above, remove the separate app bar; keep the permission-gated notifications control beside the brand and collapse action at the top of the persistent sidebar. Give each route a distinct, full-width-in-content page heading band with a subtle bottom border, a clear title hierarchy, meaningful clickable parent breadcrumbs, optional short descriptions, and route-specific actions. Keep the band sticky on desktop while the document scrolls; let it scroll normally below 1100px. Align the padded page body beneath it. Do not repeat a generic Workspace root or show redundant category context. Keep page tabs and filters on a distinct secondary row only when a real page needs them; Coming Soon pages have no invented description or action. Below 1100px, navigation uses a keyboard-accessible overlay drawer; at 1100px and above, a persistent sidebar is 300px expanded or 72px collapsed. Hover expands the collapsed rail in the page layout so content shifts with it; pointer leave starts the collapse immediately, with a short width transition. Keyboard focus keeps it open until focus exits. An explicit action can keep the sidebar expanded. Keep the account/profile entry at the sidebar bottom and place sign-out in its profile dialog with a confirmation step; do not add a permanent page footer.
- Give sidebar sections clear spacing and separators, present pinned destinations in a quiet bordered surface, style groups as disclosure rows, indent their child routes on a subtle neutral vertical guide with matching horizontal branches to each child, and mark the active destination with a slim primary accent. Keep the account area distinct from navigation and style sign-out as a destructive action.
- Keep profile details grouped and legible with visible dividers. Show two-factor status in the profile and require password confirmation in a focused dialog for either enable or disable; place the full-profile and sign-out actions at opposite ends of the wider-screen dialog footer.
- Use this sidebar ownership and subgroup map for the React port while keeping every Flutter route path, route permission, and page title unchanged. Workspace has a primary Overview link, a collapsible My Work group, and Company; People has HR/Admin. Company ownership is split deliberately from employee self-service: Attendance and My Leaves are under My Work, while Roles & Permissions is under HR/Admin. The employee's own Role remains under My Work, and Loans remains in HR/Admin because the Flutter page includes request review, approvals, and repayments. Use navigation-only labels to distinguish My profile from Company profile.
- Group My Work into **My tasks & goals** (Tasks, personal Work Reports, Target), **Time & leave** (Attendance, My Leaves), and **My account** (Profile, Role). Group Company into **Organization** (Company Profile, Branch, Departments & Units, Org Chart), **Governance & oversight** (Board, Compliance Dashboard, Audit Log), **Workflow & communication** (Approval Workflows, Workspace Approvals, Broadcast), and **Planning & resources** (KPI Management, OKR Board, Knowledge Base, Assets). Group HR/Admin into **People & access** (Employees, Recruitment, Roles & Permissions), **HR operations** (Work Calendar, Leave Requests, Training, Loans, Benefits), **Performance & reporting** (Performance, HR Work Reports, Monthly Scorecard, Employee Evaluation, Performance Engine), and **Recognition & employee relations** (Awards & Recognition, Performance Leaderboard, Disciplinary Process). Each subgroup is collapsible and its open state is saved locally; navigating to a destination opens its parent group and subgroup. Route URLs remain stable even when a destination changes sidebar ownership.
- Use an inline page-search input with a live suggestions list, keyboard navigation, Escape, and Ctrl/Cmd+K focus. Pinned destinations appear in a Pinned shortcuts section and stay in their original group. Reveal the unpinned route's pin action on hover or keyboard focus; once pinned, keep its marker visible. On touch, use a row actions menu for unpinned routes.
- Center shared dialogs on tablet and desktop; keep the full-screen treatment on phone-sized screens.
- Add one consistent Lucide icon family for the shell. Use a permission-gated notification bell in the mobile/tablet app bar and desktop sidebar header, wired to the verified `/api/v1/notifications/` list, `/stats`, per-item read, and read-all endpoints. On desktop, open its panel beside the sidebar. Do not show an unread badge unless the API returns the count and the user has the required permission. Follow only safe, same-origin notification links that resolve to permitted React routes.
- Keep active-route behavior, expandable groups, and saved sidebar preferences. The route manifest remains the shared source for route registration, permissions, breadcrumbs, and sidebar order.
- Use route paths for page/record identity and TanStack Router search parameters for durable view state such as search, filters, sort, pagination, tabs, and view mode. Validate search per route; keep transient overlays, sidebar preferences, and unsent drafts outside the URL. Add actual query state with each real page rather than to Coming Soon routes.
- Register every in-scope sidebar route and active reachable direct/detail route through one Coming Soon page until individual Flutter pages are reviewed and ported. Preserve safe deep links and permission guards. Select the first real page with the user after the shell is reviewed.
- Keep Flutter `textMuted` (`#94A3B8`) available as `text-subtle`, but use the existing Bomach `neutral500` (`#64748B`) for readable `text-muted` because it meets normal-text contrast on the app's light surfaces. Reserve `text-subtle` for nonessential decoration.
- Standardize how forms, field errors, success, loading, empty, page errors, and section errors work across the port.
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
- Keep protected route access fail-closed until the user, employee profile, role, and permission catalog are loaded. A missing assigned role is an empty permission set; other permission/profile failures block the app and offer retry.
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

### Browser and visual parity

- Browser support for camera/liveness, geolocation, uploads/downloads, exports, and notifications used by in-scope screens.
- Exact screens, assets, icons, charts, responsive breakpoints, and visual measurements from the Flutter reference. Pick icon/chart libraries only if the inventory requires them.
- How the web shell launches, returns from, and shares identity with separately hosted or embedded standalone modules.

### Operational choices

- API environment configuration and hosting target, including SPA fallback and eventual cutover. Production cutover remains a separate decision after parity review.
- Exact dependency versions and lockfile/package-manager choice at scaffold time.
- Whether Storybook adds enough value for the actual shared-component inventory.
- Route-specific query freshness, retry, invalidation, and optimistic-update behavior; use confirmed backend semantics rather than a blanket policy.
- Workflow-specific exceptions to the default form validation timing and feedback rules.

See architecture.md and migration-plan.md for the technical and sequencing details.
