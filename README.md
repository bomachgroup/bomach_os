# Bomach OS React Port

## Status

Early foundation implementation. The strict Vite/React/TypeScript scaffold and first visual primitives are in place; product routes, auth, and live API integration have not started. The branch is clear of the copied Flutter project, which remains available in the sibling checkout.

## Goal

Port the Flutter-owned Company and HR experience to a browser-based React application while preserving the existing screens, routes, content, permissions, and business behavior. Make shared loading, empty, form, error, and success behavior consistent across the port.

The Flutter checkout remains available beside this repository at ../bomach_os. The separate Service Operations React app remains at ../bomach_os_frontend/services and is a reference for architecture and interaction patterns.

## Scope

- Port Company and HR pages owned by the Flutter Bomach OS app.
- Port the shell, authentication, route, permission, and shared UI pieces those pages require.
- Keep separately owned standalone modules under their current ownership and preserve their existing launch or embedding behavior.
- Keep current Bomach OS screen design as the visual authority. The port is not a redesign.

## Read before implementation

- AGENTS.md — persistent instructions for Codex and contributors.
- docs/porting/source-review.md — findings from the Flutter and Service Operations codebases.
- docs/porting/route-inventory.md — sidebar destinations grouped by header and classified by renderer.
- docs/porting/flutter-reachability-audit.md — route reachability states, navigation map, redirects, unregistered paths, and orphan screen candidates across Flutter.
- docs/porting/decisions.md — confirmed direction, working choices, and unresolved questions.
- docs/porting/architecture.md — working technology and application structure.
- docs/porting/interaction-standards.md — required form and feedback behavior.
- docs/porting/migration-plan.md — implementation sequence and parity criteria.
- docs/porting/company-hr-screen-review.md — route-by-route behavior review and completion tracker for the first 32 routes.
- docs/porting/shared-foundations-plan.md — what is shared, what stays feature-owned, extension rules, and the incremental first-code sequence.

These documents record working decisions from discussion. Update them when the user changes a decision.
