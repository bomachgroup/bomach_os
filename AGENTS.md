# Instructions for Work on the Bomach OS Port

Before making implementation changes, read docs/porting/source-review.md, docs/porting/route-inventory.md, docs/porting/flutter-reachability-audit.md, docs/porting/architecture.md, docs/porting/interaction-standards.md, and docs/porting/migration-plan.md.

Before any manual, browser, or automated QA work, read and follow [the agent testing playbook](docs/testing/agent-testing-playbook.md). It defines the responsive viewport matrix, state and edge-case coverage, source-level root-cause investigation, safe test-data handling, and the required findings report. Record confirmed defects and remedies in [the QA findings log](docs/testing/qa-findings.md); do not report a visual or behavioral check as complete when only a mocked test ran.

## What “run tests” means

- Unless the user explicitly limits the scope to automated tests, interpret “test this page/feature” or “run tests” as a request for both the relevant automated checks and a detailed live UI pass. Passing component tests alone does not complete UI testing.
- For a UI pass, map the whole route and its linked detail pages, inspect every visible section/control/action, exercise the end-to-end paths and applicable empty/loading/error/permission/mutation states, and review every required viewport and breakpoint in the playbook. Capture screenshots or other concrete evidence for visual checks and defects.
- Use [the QA account and role catalog](docs/testing/qa-user-catalog.md) to find suitable existing test identities. If a role, permission combination, branch scope, or data state is missing, create the smallest synthetic test user/fixture needed in the verified non-production test database. Do not wait for the user to create one.
- The user has granted standing authorization to create, update, reset, and remove test-only users, permissions, and records as needed in the verified test database, including exercising destructive or approval actions. This authorization applies only after confirming the active backend runtime and database are non-production. Never infer that a database is safe from its URL or account name alone, and never apply this authorization to production data.
- Current local QA authorization (reaffirmed 2026-10-23): the user explicitly authorizes any local code or database create, edit, update, approval, and cleanup needed to test this codebase. Keep fixtures synthetic and clearly marked. The user states no email will be sent; verify the active email backend remains console-only before exercising workflows that create accounts or send notifications. If the runtime changes or email delivery becomes external, do not send messages as part of QA.
- Record fixture identifiers and the account/role used. Keep credentials out of screenshots, console/network captures, findings reports, and committed documentation except for explicit seed-defined local test credentials in the test-account catalog. Never expose existing users’ password hashes as if they were passwords.

## Working agreement

- Work side by side with the user in small, reviewable slices. The user owns product and behavior decisions; ask before making a material workflow, visual, scope, or architecture change. Do not turn an agreed port into a one-shot rewrite.
- Before implementing a route or workflow, inspect its current Flutter route, widgets, state/controller logic, permissions, assets, and meaningful loading/empty/error/success states. Verify the live backend contract for any API behavior involved.
- Before implementing any page or workflow, read `docs/porting/data-freshness.md` and add a data-lifecycle section to its plan: classify each query, define when its active page may revalidate or poll, identify mutation invalidation targets, and specify what users see while cached data refreshes or fails. Keep this scoped to the current route and its real data dependencies.
- Use the Service Operations React app as a reference for architecture and feedback placement only. Keep Bomach OS's own visual identity, route behavior, domain rules, and application boundary.
- Agree the next route or slice with the user, implement only the shared foundations it needs, then compare the React result with Flutter and review it before expanding scope. Avoid speculative abstractions, placeholder file trees, and broad rewrites.
- At the end of a slice, summarize what changed, important decisions, checks actually performed, and known gaps. Update the relevant porting documents when a decision is confirmed or changed. Never claim a visual or backend verification that was not performed.

## Stack and state ownership

- The working stack is React 19, strict TypeScript, Vite, TanStack Router, TanStack Query, TanStack Form, Zod, and Tailwind CSS 4 with Bomach semantic tokens. Confirm exact installed versions in package.json before changing dependencies.
- TanStack Query owns backend state; TanStack Router owns navigable and shareable page state in validated URL search parameters; TanStack Form owns form drafts and validation; components own short-lived interaction state. Do not add Redux or RTK Query without a concrete requirement and user agreement.
- All HTTP goes through the shared typed Fetch client. Feature API modules own endpoint contracts, and feature query modules own query keys/cache behavior. Shared transport and error layers do not navigate or show toasts.
- Keep shared UI generic. Company and HR business rules, types, and components stay inside their feature/module boundary. Create files and abstractions when a real route needs them, not in anticipation of every future page.

## Documentation map

- `docs/porting/decisions.md`: confirmed choices and unresolved decisions.
- `docs/porting/route-inventory.md` and `flutter-reachability-audit.md`: route scope, ownership, reachability, and navigation relationships.
- `docs/porting/source-review.md` and `company-hr-screen-review.md`: Flutter/source findings and per-screen review notes.
- `docs/porting/architecture.md` and `shared-foundations-plan.md`: stack, boundaries, and reusable component guidance.
- `docs/porting/interaction-standards.md` and `authentication.md`: shared feedback/form behavior and auth/session contract.
- `docs/porting/data-freshness.md`: query freshness classes, active-page refresh behavior, mutation invalidation, and the required per-page planning checklist.
- `docs/porting/migration-plan.md`: implementation sequence, verification expectations, and phase scope.
- `docs/testing/agent-testing-playbook.md`: required deep-testing workflow for agents.
- `docs/testing/qa-user-catalog.md`: known test accounts, seeded role personas, and safe credential reset sources.
- `docs/testing/qa-findings.md`: confirmed defects, root-cause evidence, fixes, and outstanding findings.

Read the specific document relevant to the slice in addition to the initial required set above. Keep detailed decisions in their owning document instead of duplicating entire standards here.

## Product intent

- The user makes product and behavior decisions. Codex writes the agreed implementation and keeps the user involved in small, reviewable steps.
- Preserve the current Flutter Company and HR UI and behavior as the reference. Do not redesign pages, rename workflows, or simplify permissions without the user's agreement.
- Standardize shared behavior for forms, loading, empty, error, success, and permission states using the porting standards.
- Port only Flutter-owned Company, HR, and the shared shell required to host them. Do not rewrite separately owned standalone modules or edit their repositories.

## Source and workspace boundaries

- The Flutter reference is the sibling checkout ../../bomach_os. Read it for current behavior and visuals. Do not edit, reset, stash, or commit in that checkout unless the user explicitly asks.
- The Service Operations React app is ../services. Use its documented architecture and feedback conventions as references; do not couple this app to its source tree.
- Work in this repository and its current port branch. Keep the new React app at this repository's root.
- The Flutter snapshot in this branch's history is archival. The current Flutter checkout is the source for visual and behavioral comparison.

## Implementation rules

- Use the agreed stack and folder boundaries in docs/porting/architecture.md. Keep shared UI generic and business-specific components inside their owning module.
- Follow the responsive page-header standard in `docs/porting/interaction-standards.md`: put one primary action/status beside the title at all widths, shrink its visible label at 479px and below, and show icon-only at 360px and below with a complete accessible name. Keep multi-action groups on a separate narrow-screen row. Do not add generic Refresh buttons to page or section headers; use query freshness and keep retry actions in the error state that needs them.
- Treat the backend as the authority for permissions and business rules. Verify endpoint contracts; do not invent paths or infer behavior from a stale OpenAPI file.
- Send all network errors through the shared API and error-presentation layers. Follow docs/porting/interaction-standards.md and avoid duplicate messages.
- Make server-backed data canonical in TanStack Query. Keep local state for temporary interface state and form drafts.
- Use `docs/porting/data-freshness.md` for all server-state freshness and invalidation decisions. Do not add page polling or broad cache invalidation without identifying the data that needs it and why.
- Update the porting documents when the user confirms or changes a product or architecture decision.
