# Agent Testing Playbook

This is the required testing workflow for agents working in the Bomach OS React port. Read it before running manual, browser, integration, or automated QA. Apply the relevant sections to the route and workflow under review; do not treat one passing unit test or one desktop screenshot as full verification. Unless the user explicitly asks for automated tests only, “run tests,” “test this page,” or “UI test” means run relevant automated checks **and** complete the live visual and behavioral pass below.

## 1. Establish the test context

Before interacting with the application:

1. Read the repository `AGENTS.md`, the relevant route/module plan, the shared interaction and error-handling standards, and the current backend contract for the endpoints involved.
2. Record the branch/worktree and inspect the existing working tree. Preserve unrelated user changes and test data.
3. Confirm the frontend and backend origins, runtime mode, and actual database target before using the app. Confirm both services are healthy, identify the signed-in account, and inspect its role, permission set, and branch scope; do not infer access from a button alone. If the environment cannot be verified as non-production, do not mutate data.
4. In the verified non-production test database, the user has granted standing authorization to create, update, reset, approve, reject, deactivate, and delete test-only users and records whenever needed for thorough coverage. No per-fixture confirmation is required. Prefer isolated synthetic data with a recognizable `QA-<date>-<feature>` marker, record fixture IDs and ownership, and preserve unrelated user-created QA records. Remove only fixtures created for the current test unless the user asks to retain them.
5. Never use production records as fixtures or run test-data setup against production. Do not transmit real passwords, OTPs, biometrics, precise locations, financial data, or private employee data to test paths. Keep credentials out of screenshots, logs, reports, and committed files except for explicitly seed-defined local test credentials listed in [the QA account and role catalog](qa-user-catalog.md). Existing password hashes are not recoverable passwords.

Check [the QA account and role catalog](qa-user-catalog.md) before reporting a role or fixture unavailable. If it is still missing, create a synthetic user/role/branch/data fixture with the least permission set that exercises the condition, and continue the test. Record the account, permission matrix, branch assignment, and fixture IDs. Do not silently substitute a different user or state.

## 2. Build a route and behavior inventory

List the actual pages, details, dialogs, menus, filters, and actions that belong to the requested slice. For each, identify:

- The route and how users reach it, including direct/deep links and return navigation.
- The signed-in identity and required permission for viewing and for each action.
- The API/query involved, its owner or scope, request payload, response state, and cache invalidation after success.
- The initial, loading, populated, empty, filtered-empty, permission-denied, stale-refresh, retry, validation, pending-mutation, success, and failure states that can occur.
- Related surfaces that must stay consistent, such as list summaries, detail pages, navigation badges, or cached profile/role data.

Read the implementation before testing. Trace controls through event handlers, local state, forms, mutations, API functions, query keys, and feedback. Compare the actual behavior with the backend contract and existing app conventions.

## 3. Responsive viewport matrix

Use the approved CSS viewport widths below for every changed page and every important overlay or responsive action. Set height to a practical device size and record it with the width.

| Class                        |   Width | Minimum checks                                                                               |
| ---------------------------- | ------: | -------------------------------------------------------------------------------------------- |
| Phone                        |  375 px | Primary layout, actions, keyboard/focus, vertical scroll, dialogs and date/dropdown controls |
| Large phone / compact tablet |  600 px | Reflow and control wrapping near the mobile/tablet transition                                |
| Tablet                       |  900 px | Two-column layouts, navigation, cards, modal size, table access                              |
| Desktop                      | 1280 px | Full page hierarchy, aligned content, responsive actions and overlays                        |
| Wide desktop                 | 1600 px | Max-width behavior, whitespace balance, dense tables and long content                        |

Also test a 320 px narrow viewport and each relevant breakpoint at one pixel below, at, and above its cutover. Read the project's Tailwind/configured breakpoints first; do not guess the cutover. Check 200% zoom or equivalent narrow effective width for users who enlarge content. Include landscape height constraints for long dialogs when relevant.

At each width, check for horizontal overflow, clipped text, hidden or unreachable actions, compressed hit targets, overlapping sticky/fixed elements, awkward wrapping, focus visibility, and scroll traps. Open and close overlays at each class; do not assume a dialog that fits on desktop also fits on a phone. Capture screenshots for visual changes and defects, including viewport dimensions.

### What counts as a complete visual pass

For every requested route, include its list/directory and every reachable detail route, tab, dialog, menu, popover, and create/edit flow in scope. At each applicable viewport in the matrix:

1. Capture the initial page from top to bottom, including loading or cached-refresh presentation, header, every card/table section, footer/pagination, and sticky navigation.
2. Inspect every visible control and action: links, search, filters, sort, pagination, tabs, dropdowns, date/time pickers, file inputs, toggles, menus, retry/refresh, and create/edit/view/action buttons. Check keyboard operation, focus, expanded/selected/disabled states, and whether the action reaches the expected route or state.
3. Open every overlay and responsive menu. Check its size, edge spacing, close/cancel behavior, focus entry/return, internal scroll, footer actions, and content fit at phone, compact-tablet, tablet, and desktop widths. Repeat around actual breakpoint cutovers and at 200% zoom.
4. Exercise each important workflow from entry to completion: create, edit, save, cancel, reopen, approve/reject, and other state-changing actions that exist. Verify the persisted result in the UI/API and all related list, detail, summary, badge, and cache states. Use the authorized test database for mutation and cleanup.
5. Vary data to expose layout and behavior edges: none, one, many, long names/IDs/addresses, missing optional fields, unusual but valid values, each status, boundary dates/numbers, validation failures, and mixed active/inactive or in-scope/out-of-scope records. Seed enough rows to cross pagination boundaries and verify first, middle, last, empty, and invalid-page cases.
6. Repeat route and action checks using the relevant role matrix: anonymous/expired session, no view permission, view-only, each action permission independently, company-wide access, branch-limited access to an assigned branch, and branch-limited access to an unassigned branch. Use existing accounts from the catalog; create precise synthetic roles/users when coverage is missing.

A visual pass is incomplete if it checks only the default admin account, one data record, the first screenful, or one desktop viewport. When a state cannot be safely driven in the live browser, use an API/component test or controlled network mock and label that coverage as mocked rather than visually verified.

## 4. Exercise full workflows

For each workflow, test the whole user path rather than isolated controls:

- Enter through navigation and a direct URL; verify back links and URL-owned filter/page state.
- Use every visible action. Verify enabled/disabled rules against permissions and business state.
- Submit valid data and verify the backend-confirmed result, expected navigation, success feedback, and all affected list/detail/summary caches.
- Correct invalid fields; test missing, malformed, reversed, boundary, and unusually long values. Verify the first useful error is announced/focused and the entered draft is preserved after server rejection.
- Cancel and reopen forms. Verify drafts and defaults follow the documented behavior and stale values/errors do not leak between records.
- Test keyboard-only operation: Tab/Shift+Tab, Enter/Space, Escape, focus entry/return, and controls with custom dropdown/date interactions.
- Test repeated activation, slow response, duplicate submission prevention, refresh during mutation, and navigation away/back.
- Verify that one section's failure does not hide independent sections or show duplicate error messages.

Use synthetic records for state transitions in the verified test database. Perform approve/reject/deactivate/delete and similar actions against those fixtures when they are needed for coverage. For actions that would contact a real person or external system, use local test routing or controlled mocks and verify the UI/API contract without sending the external communication.

## 5. Cover backend and network states

For each API-backed page or section, cover states that apply to its contract:

- Request in flight, slow response, empty result, normal result, cached result refreshing, and explicit refresh.
- No network, connection refused/backend unavailable, request timeout, malformed response, and retry/reconnect behavior.
- Authentication expiry/401, authenticated-but-forbidden/403, missing record/404, validation/400 or 422, conflict/409, throttling/429, and server failure/5xx.
- Partial success or independent endpoint failure when a page loads several sections.
- Permission changes between load and action, ownership/scope boundaries, and direct access to a record outside the current user's scope.

Check the message and recovery action, not just that an error appears. A backend outage must not be mislabeled as missing user data or a permission error. Keep cached data only when the established policy allows it and identify that it may be stale. Confirm retries target the failed query and do not discard useful state. Never disable auth/network protections to make a test pass.

Use controlled mocks/interceptors for conditions that are hard to reproduce safely, and at least one browser/API-backed test for the ordinary success path. Clearly label mocked coverage; it does not prove the browser, backend, and data path work end to end.

## 6. Investigate every failure before reporting it

When something looks wrong:

1. Reproduce it at least once and record the exact route, account/permission, viewport, starting data state, action, expected result, and observed result.
2. Collect evidence: screenshot or accessibility/DOM state, console/network information where available, response status/body with secrets removed, and fixture ID. Preserve the failing state before retrying if doing so is safe.
3. Trace the source path from rendered control through its state transition, component lifecycle, API/query, and feedback. Check whether a test mock masks browser/native behavior or whether a stale server build, account, cache, or permission changed the result.
4. Compare with the backend contract and a known-good shared pattern. State the smallest code-based root cause supported by evidence; distinguish confirmed cause from hypothesis.
5. Implement the authorized remedy, add or update a regression test at the layer that caught the defect, and rerun the targeted suite plus affected broader checks.
6. Reproduce the original browser scenario after the fix at the agreed widths and confirm the intended result and a safe close/cancel path. If a browser/backend fixture is unavailable, state exactly which part remains unverified.

Do not stop at “the UI does not work” and do not report an untested assumption as a root cause. For out-of-scope defects, document a proposed remedy and leave the product change for a separately authorized slice.

## 7. Automated and manual checks

Use the narrowest test first, then widen coverage based on risk:

1. Run the relevant unit/component test and add a regression assertion for the failure.
2. Run typecheck and lint for changed files; run formatting checks for touched files.
3. Run related module tests, then the complete suite/build when the change can affect shared behavior or routing.
4. Use the live browser to exercise the actual control and inspect the resulting state. For responsive work, repeat at the matrix widths and relevant breakpoint edges.
5. Review console output and network results for unexpected errors, duplicate requests, permission leaks, or stale cached values.

### Commands in this workspace

Run React checks from `bomach_os_react_port`:

```bash
npm run test:run
npm run test:run -- src/modules/company
npm run typecheck
npm run lint
npm run format:check
npm run build
npm run check
```

Use the module or file label for a fast first pass, then run the affected broader suite. `npm run check` runs typecheck, lint, formatting, the full Vitest suite, and the production build. `npm run dev` starts the React app for live browser testing; use the origin printed by Vite and the API origin configured for this local app.

Run Django backend tests from `bomach_os_backend`:

```bash
.venv/bin/python manage.py test user.tests.test_dashboard_overviews --verbosity 2
.venv/bin/python manage.py test --verbosity 1
```

Replace the focused test label with the app, module, or test class under investigation; the second command runs the backend suite. Confirm the Django test database configuration and target before running. Django's test runner normally creates a separate test database, but do not assume this is isolated if the project has custom database settings or test flags. Seeding commands are separate from automated tests and may write to the configured development database; inspect their guards and follow the test-data authorization in Section 1.

After automated checks, perform the live browser pass. Vitest/JSDOM screenshots and mocked endpoints do not count as visual or end-to-end verification. For each route, report the exact commands, browsers, accounts/permissions, data states, and viewport sizes used.

Automated mocks, live browser behavior, and real backend behavior are separate evidence. Say which ones were checked. Do not claim a full end-to-end pass if an endpoint or state was mocked.

## 8. Required test report

For each confirmed issue, record:

- **Finding and severity:** clear user-visible impact, without exaggerating.
- **Reproduction:** route, account/permission class, fixture, viewport, and numbered steps.
- **Evidence:** what was observed and which checks confirmed it.
- **Root cause:** relevant code path and backend/contract evidence; mark any remaining uncertainty.
- **Remedy:** code or configuration change, regression coverage, and any data/cache implications.
- **Retest:** commands, browsers, viewport matrix, states, and result after the fix.
- **Open limitation:** test unavailable, incomplete state, related defect deferred, or follow-up needed.

End the test report with a concise matrix of passed/failed/not-run checks and the exact files or commands used. Keep persistent findings in `docs/testing/qa-findings.md` and module-specific contract decisions in the module's implementation document. Update this playbook when a new shared testing rule is confirmed.
