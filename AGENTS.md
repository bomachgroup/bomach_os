# Instructions for Work on the Bomach OS Port

Before making implementation changes, read docs/porting/source-review.md, docs/porting/route-inventory.md, docs/porting/flutter-reachability-audit.md, docs/porting/architecture.md, docs/porting/interaction-standards.md, and docs/porting/migration-plan.md.

## Product intent

- The user makes product and behavior decisions. Codex writes the agreed implementation and keeps the user involved in small, reviewable steps.
- Preserve the current Flutter Company and HR UI and behavior as the reference. Do not redesign pages, rename workflows, or simplify permissions without the user's agreement.
- Standardize shared behavior for forms, loading, empty, error, success, and permission states using the porting standards.
- Port only Flutter-owned Company, HR, and the shared shell required to host them. Do not rewrite separately owned standalone modules or edit their repositories.

## Source and workspace boundaries

- The Flutter reference is the sibling checkout ../bomach_os. Read it for current behavior and visuals. Do not edit, reset, stash, or commit in that checkout unless the user explicitly asks.
- The Service Operations React app is ../bomach_os_frontend/services. Use its documented architecture and feedback conventions as references; do not couple this app to its source tree.
- Work in this repository and its current port branch. Keep the new React app at this repository's root.
- The Flutter snapshot in this branch's history is archival. The current Flutter checkout is the source for visual and behavioral comparison.

## Implementation rules

- Use the agreed stack and folder boundaries in docs/porting/architecture.md. Keep shared UI generic and business-specific components inside their owning module.
- Treat the backend as the authority for permissions and business rules. Verify endpoint contracts; do not invent paths or infer behavior from a stale OpenAPI file.
- Send all network errors through the shared API and error-presentation layers. Follow docs/porting/interaction-standards.md and avoid duplicate messages.
- Make server-backed data canonical in TanStack Query. Keep local state for temporary interface state and form drafts.
- Update the porting documents when the user confirms or changes a product or architecture decision.
