# Port Architecture and Technology

## Status

The user has agreed to document this as the working architecture for the port. The Service Operations app informed the choices, but Bomach OS remains a separate application with its own API, session, permissions, and visual contract. Initial dependencies are recorded in `package.json` and `package-lock.json`; recheck compatibility when adding tooling. Source-dependent decisions remain open; see decisions.md.

## Application boundary

Build the React application at the root of this repository. This is the planned Bomach OS web shell for Workspace/Dashboard, Company, and HR/Admin, replacing the Flutter shell after parity review. The repository is the port branch; it does not need an extra nested frontend project.

The React app owns:

- The six Workspace/Dashboard routes and the Company and HR screens currently owned by Flutter.
- The shell, routes, authentication, permissions, and shared controls needed by those screens.
- Shared loading, empty, error, success, and form behavior.

Separately owned Services, Marketing, and Finance modules stay in their own applications. Their links are temporarily hidden in this React shell by the current phase decision. Do not port their screens, alter their codebases, or assume a new launch/session contract; review reintroduction separately after this phase.

## Working technology choices

### React

Use React 19 for the browser UI and composable shared components.

### TypeScript

Use TypeScript in strict mode. Keep API response contracts, frontend domain types, form values, route parameters, permission names, and component properties explicit.

### Vite

Use Vite for local development and production bundling. This is an authenticated, browser-first business application with existing API backends; the current scope has no public SEO pages or server-rendered content requirement. Vite also matches the Service Operations app and keeps the first implementation model direct.

Next.js is not selected for this port. Revisit only if hosting or product requirements introduce a concrete server-rendering, server-side data, or multi-route deployment need.

### TanStack Router

Use TanStack Router for typed route definitions, route parameters, validated search/filter state, deep links, scroll restoration, redirects, and route-level auth/permission checks. Put durable page view state (search, filters, sort, pagination, tabs, and view modes) in route-owned search parameters so reloads and copied URLs restore it. Preserve the existing Bomach route paths where practical so bookmarked links and standalone-module links continue to work. Keep short-lived overlays and local sidebar preferences out of the URL; never serialize credentials or sensitive drafts.

### TanStack Query

Use TanStack Query for server-owned data: lists, details, current user, permissions, mutations, loading/error state, refetching, cancellation, and cache invalidation. Its cache is the canonical client copy of backend-owned data.

Plan query freshness, focused-page refresh triggers, and domain-scoped invalidation for every route using [Data Freshness, Refetching, and Invalidation](data-freshness.md). Token refresh in the shared transport is separate from revalidating application data.

Do not add Redux or RTK Query for the current scope. The port has not identified substantial client-only global state that needs a Redux store, and TanStack Query already owns remote data. Keep form drafts in TanStack Form, route/search state in the URL, and short-lived interface state local to components. Revisit a client-state library only if source review identifies a concrete cross-feature client-only state requirement. Do not run TanStack Query and RTK Query as competing caches for the same endpoints.

### TanStack Form and Zod

Use TanStack Form for field state, touched/dirty state, validation, submit state, and form reset. Use Zod schemas for client-side usability validation and request-shape validation where useful. The backend remains authoritative for business rules and final validation.

Map backend field errors into the same inline field-error model. Keep form values when a request fails; clear or reset them only when the workflow succeeds or the user explicitly cancels.

### Tailwind CSS and semantic tokens

Use Tailwind CSS 4 with a small set of CSS variables and semantic design tokens. Build the React tokens from the Flutter Bomach palette, Poppins font, spacing, radii, and screen measurements. Avoid scattered arbitrary colors and spacing.

The Service Operations app's shared-component and token approach is a reference. Its Inter font and visual palette are not the target design.

### Fetch-based API client

Use the browser Fetch API behind one shared typed API client implementation, following the Service Operations boundary. If auth and operations use different origins, configure clients from this same implementation for the appropriate service; do not duplicate transport logic or hardcode origins in features.

The shared client owns configured base URL selection, auth headers, response parsing, AbortSignal forwarding, refresh coordination, and conversion of transport/backend failures into one typed ApiError. Refresh and retry rules must match the verified backend contract; an eligible failed request may be retried at most once. The client may update or invalidate session state but does not navigate or display feedback.

Feature API files own endpoint paths and request/response DTO types. Feature query definitions own query keys, hooks, and cache policy. Map DTOs into frontend domain types when the backend shape differs meaningfully from what a screen needs; do not require a mapper for a trivial pass-through. API and query code must not create separate transport clients, show toasts, or contain page navigation behavior. TanStack Query's AbortSignal should reach Fetch so obsolete or cancelled queries can stop their requests.

API type generation and runtime response validation have not been selected. Verify the current backend contract first. Existing OpenAPI files are not assumed to be current enough to generate the client or types without comparison.

### Shared UI primitives

Create Bomach-specific shared primitives in src/shared/ui. Start with only patterns needed by the inventoried pages: buttons, form controls, alerts, empty/error/success states, skeletons, dialogs, confirmation, and permission gates. `PageLayout` owns the full-width page-heading band and aligned page body; `PageHeader` owns its title, breadcrumbs, optional actions, and optional route-specific toolbar. Put the toast provider and shared feedback orchestration in src/shared/feedback; keep error normalization and placement policy in src/shared/errors.

Use semantic component variants such as primary, neutral, success, warning, and danger. Do not add a large external component kit that changes the current screens.

The component reuse boundary, promotion criteria, extension rules, and staged foundation build order are detailed in [shared-foundations-plan.md](shared-foundations-plan.md). Follow composition and semantic variants; do not pre-create every proposed folder or make shared UI aware of Company/HR business records.

### Quality and development tools

The first shared-foundation quality gate is configured with the Service Operations toolchain where compatible:

- ESLint and Prettier for consistent source formatting and linting.
- Vitest, Testing Library, and user-event for component and interaction behavior; axe-core provides representative automated accessibility checks.
- MSW for deterministic API scenarios when the typed client and feature queries are implemented.
- Storybook for shared components when its setup is justified by the component inventory.

The component tests cover current shared behavior; API tests and browser automation are added with the first real workflow. Storybook remains deferred until the shared-component inventory justifies it. Do not select separate chart, date, or icon libraries until the screen inventory shows what is needed and which choices preserve the current visuals.

## Proposed source structure

Use feature-oriented vertical slices. The app composes the modules; each module owns its routes and business features; shared contains only cross-module infrastructure and generic UI.

```text
src/
  app/
    providers/          # Query, auth, theme, and other app-wide providers
    router/             # Route-tree composition and global redirects
    shell/              # Bomach shell and shared layout
    navigation/         # Host navigation composition
    error-boundaries/   # Unexpected render failures
  shared/
    api/                # Typed Fetch client, ApiError, origins, request helpers
    auth/               # Session contract, token/session adapter, current user
    notifications/      # Cross-module notification contracts and API functions
    errors/             # Error normalization and context-aware presentation policy
    feedback/           # Toast provider and shared feedback orchestration
    permissions/        # Permission types, mapping, and reusable gates
    forms/              # Generic form helpers
    ui/                 # Bomach visual and interaction primitives
    utils/              # Small framework-neutral utilities
  modules/
    company/
      index.ts          # Public module exports
      routes.tsx        # Company route contribution
      navigation.ts     # Company navigation contribution, if needed
      shared/           # Company-only code shared by multiple Company features
      features/
        <feature>/       # Name from the verified Flutter route/workflow inventory
          api.ts         # Endpoint functions and transport DTOs
          queries.ts     # Query keys, query/mutation hooks, cache behavior
          types.ts       # Domain types when they differ from transport DTOs
          schema.ts      # Feature form/input schemas where needed
          mapper.ts      # DTO/domain mapping only when useful
          pages/
          components/
    hr/
      index.ts
      routes.tsx
      navigation.ts
      shared/
      features/
        <feature>/       # Same ownership pattern as Company
```

This is a guide, not a requirement to create every listed file or folder up front. A small feature can keep a few files together; split it as its responsibilities grow. Do not create empty folders, global business `services`/`models`/`widgets` buckets, or abstractions with no real second use. Feature names and boundaries come from the source inventory, not guesses.

## Data and API ownership

The backend owns persistent business truth, identifiers, authorization, workflow transitions, and business validation. The frontend owns presentation, drafts, navigation, client-side usability checks, and cache orchestration.

Notifications are shared shell data, not a Company/HR-owned feature. Keep their DTOs and endpoint functions in `shared/notifications`, keep cached list/count state in TanStack Query, and keep the bell/panel presentation in `app/shell`. Check `notifications.list`, `notifications.view`, `notifications.mark_read`, and `notifications.mark_all_read` before calling their corresponding endpoints. Do not navigate notification links unless they are same-origin, map to a registered React destination, and pass that destination's permission check.

Use this flow:

1. Verify the backend contract and permission vocabulary.
2. Define request and response DTOs.
3. Call the shared typed transport through feature-owned API functions.
4. Map DTOs into frontend domain models when shapes differ meaningfully.
5. Use feature-owned TanStack Query definitions for server state and cache updates.
6. Present loading, empty, success, and error states through shared patterns in the relevant page or form context.

Treat existing OpenAPI files and endpoint notes as leads to verify, not proof that a live endpoint is current. Do not guess a URL, payload, status transition, or permission name.

## Authentication and standalone-app integration

Authentication is implemented as a browser-specific session contract documented in [authentication.md](authentication.md). Browser sessions use host-only HttpOnly cookies, exact Origin plus a custom request header for unsafe cookie-authenticated requests, and the shared Fetch client for refresh coordination. Existing bearer-token endpoints and response shapes remain for Flutter, mobile, and other clients.

Protected routes must bootstrap the current user, employee profile, assigned role, and permission catalog before rendering. Loading or unresolved permissions block access and offer retry. One route manifest drives registered placeholders, permission requirements, sidebar visibility/order, and breadcrumb context; the backend remains authoritative. Return targets must be validated same-origin internal paths, and tokens must never appear in URLs. The current page bodies are Coming Soon placeholders and are not considered feature ports.

The Service Operations app remains a reference for client boundaries and error handling, not the source of Bomach identity or token storage. Standalone-app launch, return, and identity-sharing contracts still need their own review before those integrations are ported.

## Visual and behavior contract

The current Flutter screen is the visual authority for its layout, hierarchy, copy, typography, colors, spacing, responsive behavior, icons, and overlays. Record screenshots and route behavior before porting each screen.

Shared feedback behavior follows docs/porting/interaction-standards.md. Styling that behavior should fit the current Bomach visual language. Do not copy the Service Operations theme or redesign the underlying page to fit a new component.

## Deployment

Production hosting and cutover are deferred until parity is reviewed. The Flutter app currently deploys from build/web through its Firebase hosting configuration. The new Vite build output and SPA route fallback must be tested in a non-production target before any hosting change.
