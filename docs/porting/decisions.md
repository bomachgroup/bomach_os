# Port Decision Log

This records the user's direction separately from recommendations and questions that still need verification. Update it when a decision is confirmed or changes.

## Confirmed direction

- Port the Company and HR functionality owned by the Flutter Bomach OS app, along with the Bomach shell pieces needed to host it.
- Keep separately owned standalone modules in their own applications and preserve how the Bomach shell reaches them.
- Preserve the current Flutter UI and behavior as the reference. Do not redesign the product.
- Use current Flutter Bomach OS as the baseline for each shared design pattern, then assess whether the web implementation can improve consistency, accessibility, responsive behavior, or maintainability. Keep expected workflows and visible results intact by default; discuss and record visible deviations before applying them broadly.
- Use four mobile-first responsive cutovers: 480px (phone), 700px (tablet, retained from Flutter), 1100px (desktop, retained from Flutter), and 1440px (wide desktop). This creates five review ranges; use 375, 600, 900, 1280, and 1600px as representative review widths. Routes should only change layout at a cutover when their content requires it.
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
- Login, refresh, logout, current-user, session expiry, and permission-fetch contracts; confirm whether a refresh can safely replay each request.
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
