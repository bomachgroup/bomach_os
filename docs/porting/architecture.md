# Port Architecture and Technology

## Status

The user has agreed to document this as the working architecture for the port. The Service Operations app informed the choices, but Bomach OS remains a separate application with its own API, session, permissions, and visual contract. Initial dependencies are recorded in `package.json` and `package-lock.json`; recheck compatibility when adding tooling. Source-dependent decisions remain open; see decisions.md.

## Application boundary

Build the React application at the root of this repository. This is the planned Bomach OS web shell for Company and HR, replacing the Flutter shell after parity review. The repository is the port branch; it does not need an extra nested frontend project.

The React app owns:

- The Company and HR screens currently owned by Flutter.
- The shell, routes, authentication, permissions, and shared controls needed by those screens.
- Shared loading, empty, error, success, and form behavior.

Separately owned standalone modules stay in their own applications. Preserve their existing navigation, launch, and session-sharing contract from the Bomach shell. Do not port their screens into Company or HR.

## Working technology choices

### React

Use React 19 for the browser UI and composable shared components.

### TypeScript

Use TypeScript in strict mode. Keep API response contracts, frontend domain types, form values, route parameters, permission names, and component properties explicit.

### Vite

Use Vite for local development and production bundling. This is an authenticated, browser-first business application with existing API backends; the current scope has no public SEO pages or server-rendered content requirement. Vite also matches the Service Operations app and keeps the first implementation model direct.

Next.js is not selected for this port. Revisit only if hosting or product requirements introduce a concrete server-rendering, server-side data, or multi-route deployment need.

### TanStack Router

Use TanStack Router for typed route definitions, route parameters, search/filter state, deep links, redirects, and route-level auth/permission checks. Preserve the existing Bomach route paths where practical so bookmarked links and standalone-module links continue to work.

### TanStack Query

Use TanStack Query for server-owned data: lists, details, current user, permissions, mutations, loading/error state, refetching, cancellation, and cache invalidation. Its cache is the canonical client copy of backend-owned data.

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

Create Bomach-specific shared primitives in src/shared/ui. Start with only patterns needed by the inventoried pages: buttons, form controls, alerts, empty/error/success states, skeletons, dialogs, confirmation, and permission gates. Put the toast provider and shared feedback orchestration in src/shared/feedback; keep error normalization and placement policy in src/shared/errors.

Use semantic component variants such as primary, neutral, success, warning, and danger. Do not add a large external component kit that changes the current screens.

The component reuse boundary, promotion criteria, extension rules, and staged foundation build order are detailed in [shared-foundations-plan.md](shared-foundations-plan.md). Follow composition and semantic variants; do not pre-create every proposed folder or make shared UI aware of Company/HR business records.

### Quality and development tools

Align with the Service Operations toolchain where compatible:

- ESLint and Prettier for consistent source formatting and linting.
- Vitest and Testing Library for component and interaction behavior.
- MSW for deterministic API scenarios during development and verification.
- Storybook for shared components when its setup is justified by the component inventory.

These are planned tools; the React scaffold has started, while test setup has not been added. Do not select separate chart, date, or icon libraries until the screen inventory shows what is needed and which choices preserve the current visuals.

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

Use this flow:

1. Verify the backend contract and permission vocabulary.
2. Define request and response DTOs.
3. Call the shared typed transport through feature-owned API functions.
4. Map DTOs into frontend domain models when shapes differ meaningfully.
5. Use feature-owned TanStack Query definitions for server state and cache updates.
6. Present loading, empty, success, and error states through shared patterns in the relevant page or form context.

Treat existing OpenAPI files and endpoint notes as leads to verify, not proof that a live endpoint is current. Do not guess a URL, payload, status transition, or permission name.

## Authentication and standalone-app integration

Authentication is a prerequisite for all protected Company and HR routes. The session contract is still open. Before implementation, compare:

- Flutter token, user, permission, and refresh behavior.
- Service Operations token storage, refresh, and current-user bootstrap.
- How the current Bomach shell launches standalone apps and shares identity.
- Deployment origins and whether the new app runs embedded or as the host.

Select one browser session contract and implement it once in the shared API/auth layer. The Service Operations app's storage and refresh behavior is a reference, not an automatic decision for the shell. Confirm whether Bomach OS uses separate auth and operations API origins and configure the shared transport accordingly.

Do not put authentication tokens in URLs. If embedded auth is required, use an explicitly trusted origin and a validated message contract. Loading or unresolved permissions must never be treated as a denial; show forbidden only after the authenticated user and permissions are resolved. Frontend permission gates improve the experience, while the backend enforces access.

## Visual and behavior contract

The current Flutter screen is the visual authority for its layout, hierarchy, copy, typography, colors, spacing, responsive behavior, icons, and overlays. Record screenshots and route behavior before porting each screen.

Shared feedback behavior follows docs/porting/interaction-standards.md. Styling that behavior should fit the current Bomach visual language. Do not copy the Service Operations theme or redesign the underlying page to fit a new component.

## Deployment

Production hosting and cutover are deferred until parity is reviewed. The Flutter app currently deploys from build/web through its Firebase hosting configuration. The new Vite build output and SPA route fallback must be tested in a non-production target before any hosting change.
