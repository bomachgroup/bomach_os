# Bomach OS React Port

## Status

Early foundation implementation. The strict Vite/React/TypeScript scaffold and first visual primitives are in place; product routes, auth, and live API integration have not started. The branch is clear of the copied Flutter project, which remains available in the sibling checkout.

## Goal

Port the Flutter-owned Company and HR experience to a browser-based React application while preserving the existing screens, routes, content, permissions, and business behavior. Make shared loading, empty, form, error, and success behavior consistent across the port.

The Flutter checkout remains available at ../../bomach_os. The separate Service Operations React app remains at ../services and is a reference for architecture and interaction patterns.

## Deployment branches

Use `main` for production deployments and `test` for the stable Vercel preview environment.

## Scope

- Port Company and HR pages owned by the Flutter Bomach OS app.
- Port the shell, authentication, route, permission, and shared UI pieces those pages require.
- Keep separately owned apps in their own codebases and deployments; connect them through shared-host path routing and browser-cookie authentication rather than embedding or merging them.
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

## Local shared-host development

Run the backend, React OS, Services, and Marketing dev servers together to exercise the same `/services/*` and `/marketing/*` paths and same-origin browser session used by the shared Vercel host.

1. In `bomach_os_backend`, activate `.venv`, run `python manage.py migrate` after confirming the configured database is the local SQLite database, then run `python manage.py runserver 127.0.0.1:8000`.
2. In `bomach_os_frontend/services`, run `npm run dev:shared`. This serves Services with the `/services/` base on port `5175`.
3. In `bomach_os_frontend/marketing`, run `npm run dev:shared` (or `npm run dev`, which uses shared mode by default). This serves Marketing with the `/marketing/` base on port `5177`.
4. In `bomach_os_frontend/bomach_os`, run `npm run dev`. The React Vite server on port `5173` proxies `/api/*` to Django and the two product paths to their dev servers.
5. Open `http://localhost:5173` and use the app switcher, or navigate directly to `http://localhost:5173/services` or `http://localhost:5173/marketing/`.

Keep the browser on the React front-door origin for the combined-flow test. All applications then call `/api/v1` through port `5173`; opening a product dev server directly does not test shared-host authentication or app switching.
