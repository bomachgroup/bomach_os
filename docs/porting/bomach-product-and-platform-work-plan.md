# Bomach Product & Platform Work Plan

**Team tracker · Last reviewed: 3 November 2026**

This is the shared overview for current and planned Bomach work across the operating system and its separate products. It is a checklist, not a promise of dates. Add an owner and target date when a work item is picked up; do not mark an item complete until its verification checks pass.

## Status

| Workstream                         | Status        | Owner      | Target   |
| ---------------------------------- | ------------- | ---------- | -------- |
| Bomach OS React port               | In progress   | Unassigned | To agree |
| Vercel hosting and product routing | Open decision | Unassigned | To agree |
| Backend domain reachability        | Open          | Unassigned | To agree |
| Main website reachability          | Open          | Unassigned | To agree |
| Company and HR updates             | Planned       | Unassigned | To agree |
| Client app                         | Planned       | Unassigned | To agree |
| Associates and partners            | Planned       | Unassigned | To agree |
| Projects codebase                  | Planned       | Unassigned | To agree |

**Checklist rule:** every work item has its own verification checklist. Work is complete only when the implementation and its relevant tests are checked, and the evidence or test run is linked from the team tracker.

## 1. Bomach OS React Port

**Status: In progress**  
Continue moving the current Bomach OS experience from Flutter to the React port. Keep the Flutter app as a reference during the port; this work does not merge the other standalone products into the OS.

- [ ] **OS-1 · Route and workflow parity:** review remaining agreed OS routes, prioritize them, and implement in small reviewed slices.
  - [ ] **Test:** confirm each completed route against its source behavior, permissions, navigation, and supported API contract.
  - [ ] **Test:** cover loading, empty, success, validation, permission-denied, and API-error states where applicable.
- [ ] **OS-2 · Quality gate:** keep shared authentication, navigation, responsive shell, and route behavior consistent as pages are added.
  - [ ] **Test:** React unit/integration tests, typecheck, lint, formatting, and production build pass.
  - [ ] **Test:** manually verify agreed critical flows at mobile, tablet, and desktop widths, including keyboard/focus behavior where relevant.
- [ ] **OS-3 · Release readiness:** document remaining gaps and decide which routes are ready for Preview and Production.
  - [ ] **Test:** verify direct links, refresh/deep links, browser history, signed-out redirects, and role/permission access on the target deployment.

## 2. Vercel Hosting and Product Routing

**Status: Open decision**  
Keep Services, Finance, Marketing, Projects, and the OS as separate codebases and deployments. The shared hostname needs one Vercel project to act as the front door. The exact project/team that owns `bomach-os.vercel.app` must be confirmed before configuring routes. Services currently has its own deployment at [services-mocha-xi.vercel.app](https://services-mocha-xi.vercel.app/).

- [ ] **HOST-1 · Confirm the front door:** identify the Vercel project and account/team that currently owns the intended shared hostname; decide whether Flutter OS or React OS is the front door.
  - [ ] **Test:** verify the hostname resolves to the selected front-door project and its current root experience still works.
- [ ] **HOST-2 · Choose the routing model:** for projects that remain in separate Vercel accounts, evaluate external path rewrites from the front door; consider native Vercel Microfrontends only if project ownership can be grouped under one team and the billing/access impact is accepted.
  - [ ] **Test:** prove the selected model can route a Preview request to the correct independent deployment without changing the browser URL.
- [ ] **HOST-3 · Connect Services first:** route `/services/*` to the existing Services project, then repeat the approved pattern for Finance, Marketing, and Projects.
  - [ ] **Test:** direct-load and refresh nested paths; verify query strings, static assets, client-side navigation, and 404 behavior.
  - [ ] **Test:** verify `/api/*` continues to reach the intended backend and is not captured by a product SPA fallback.
- [ ] **HOST-4 · Shared sign-in and switching:** make every product use the agreed browser session and shared-host API flow; add matching product switchers without merging product sidebars or source code.
  - [ ] **Test:** verify sign-in, refresh, expiry, logout, return-to path, and app-to-app switching across the shared hostname.
  - [ ] **Test:** verify the same employee data and permissions are enforced by the backend regardless of which product initiated the request.
- [ ] **HOST-5 · Roll out safely:** deploy and verify the test host first, then deploy the front door and product changes to Production in a coordinated order.
  - [ ] **Test:** keep a rollback path and confirm each product remains independently deployable.

## 3. Backend Domain Reachability

**Status: Open**  
Investigate why the server/API is not reachable through its backend domain and restore reliable access.

- [ ] **API-1 · Diagnose the failure:** check DNS, TLS/certificate, Vercel or server deployment health, routing, firewall/network rules, and application logs; record the root cause.
  - [ ] **Test:** confirm the backend hostname resolves correctly and presents a valid HTTPS certificate.
- [ ] **API-2 · Restore the endpoint:** fix the confirmed configuration or service issue and verify the correct environment is serving the domain.
  - [ ] **Test:** check health/status and representative authenticated and unauthenticated API requests, including login/session refresh where applicable.
  - [ ] **Test:** confirm the React OS, Flutter OS, and other connected clients can reach the intended API origin without CORS or cookie failures.

## 4. Main Bomach Website Reachability

**Status: Open**  
Restore public access to the main Bomach website without disrupting the OS or product domains.

- [ ] **WEB-1 · Diagnose and restore:** verify domain ownership/DNS, Vercel project assignment, deployment/build health, redirects, and TLS; record the root cause.
  - [ ] **Test:** confirm the canonical website hostname loads over HTTPS and redirects resolve to the intended destination.
- [ ] **WEB-2 · Website smoke pass:** check primary pages, navigation, contact/lead forms, and any important public links.
  - [ ] **Test:** submit forms in the approved test mode and verify success/error feedback; check mobile and desktop layouts and social preview metadata.

## 5. Company and HR Updates

**Status: Planned**  
Agree the business rules and expected outcomes before changing KPI, target, branch, or access behavior.

- [ ] **COHR-1 · KPI updates:** confirm KPI definitions, formulas, ownership, periods, and display/reporting requirements; implement the approved changes.
  - [ ] **Test:** verify representative calculations, boundary/zero-data cases, filtering, and authorized versus unauthorized access.
- [ ] **COHR-2 · Target updates:** define target ownership, periods, progress rules, and how targets relate to scorecards/evaluations; implement the agreed behavior.
  - [ ] **Test:** verify create/update/read behavior, progress calculations, period boundaries, and employee/manager/HR access rules as applicable.
- [ ] **COHR-3 · Branching rules:** document the updated branch rules and affected workflows before implementation.
  - [ ] **Test:** exercise the agreed branch-scope matrix, including permitted and denied cross-branch cases and any approved exceptions.
- [ ] **COHR-4 · Access control:** align UI navigation/guards with backend permissions while keeping the backend authoritative.
  - [ ] **Test:** test allowed and denied roles through direct URLs and API calls; confirm hidden UI controls do not substitute for backend enforcement.
- [ ] **COHR-5 · Company/HR regression:** check related routes after changes to shared rules or permissions.
  - [ ] **Test:** run the affected automated suites and manually verify key workflows, responsive layouts, and success/error states.

## 6. Client App

**Status: Planned**  
Review current client-app behavior, agree the work, then implement and test it as a distinct application/workstream.

- [ ] **CLIENT-1 · Test and triage:** inventory the main client journeys and known issues; record reproducible defects and priorities.
  - [ ] **Test:** run the agreed end-to-end client journeys on supported screen sizes, including validation and network/API failure behavior.
- [ ] **CLIENT-2 · Implement agreed updates:** deliver approved fixes or features without broadening scope mid-slice.
  - [ ] **Test:** add regression coverage for each fix and verify existing client journeys remain intact.

## 7. Associates and Partners

**Status: Planned**  
Confirm the associate/partner workflows, roles, and boundaries before making product changes.

- [ ] **PARTNER-1 · Requirements and workflow review:** document who uses each flow, what they can see/do, and how the flow hands off to staff or clients.
  - [ ] **Test:** get product/stakeholder agreement on workflow examples and an access/visibility matrix.
- [ ] **PARTNER-2 · Implement approved updates:** deliver the agreed associate and partner changes in focused slices.
  - [ ] **Test:** verify applicable onboarding, view/edit/action, status transition, notification, and permission cases; include API failure and responsive checks.

## 8. Projects Codebase Updates and Tests

**Status: Planned**  
Keep the Projects application independent while reviewing its codebase, requested updates, and test coverage.

- [ ] **PROJ-1 · Codebase review:** inventory the repository, current deployment, key dependencies, workflows, and outstanding defects; agree a prioritized change list.
  - [ ] **Test:** establish a baseline of current tests, lint/type checks, build, and critical project workflows.
- [ ] **PROJ-2 · Implement updates:** deliver the approved changes and keep project configuration/deployment ownership documented.
  - [ ] **Test:** run relevant automated checks, integration/API tests, and responsive UI checks; record any accepted gaps.
- [ ] **PROJ-3 · Release and regression:** deploy to Preview, validate the change, then release when accepted.
  - [ ] **Test:** verify direct routes, refresh, key actions, permissions, and rollback readiness on the deployed build.

## Team Working Agreement

- Assign an owner, priority, and target date when starting a work item; keep unknown dates as **To agree** rather than guessing.
- Write down business-rule decisions and dependencies before implementation begins.
- Keep each application deployable and testable on its own unless a deliberate shared-host routing change is being tested.
- Link test results, screenshots, deployment URLs, or issue IDs as evidence before checking off verification.
- Track detailed execution as individual GitHub issues in a shared GitHub Project; keep this document as the cross-project overview. If the team uses Jira/Confluence, link the same work items there instead of maintaining duplicate checklists.
