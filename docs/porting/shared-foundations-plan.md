# Shared Foundations and Reuse Plan

## Purpose

Agree on the reusable layer for the Company and HR port before creating folders or components. The goal is one consistent Bomach OS experience with a small, extendable foundation—not a framework that anticipates every future screen.

This plan adapts responsibilities and module boundaries from the Service Operations React app while preserving Bomach OS's Flutter visual language, routes, behavior, backend contracts, and permissions. Service Operations is a reference implementation, not a source dependency.

## Flutter baseline and improvement rule

The current Flutter Bomach OS is the source of truth for what the product does and how its screens look. We will inspect the relevant Flutter code and rendered screen before implementing each shared pattern; the React port is not a reason to invent a new product design.

For every reusable Flutter pattern, assess whether the source can be made more consistent, accessible, responsive, or maintainable in the web implementation:

1. Record what Flutter currently does and where that behavior or visual treatment appears.
2. Check the pattern against the other in-scope Flutter screens so a one-off implementation is not mistaken for a product-wide rule.
3. Identify a concrete issue or opportunity, such as inconsistent field errors, keyboard focus, color contrast, repeated styles, or a layout that fails at a supported viewport.
4. Prefer an implementation improvement that keeps the user's expected workflow and visible result intact.
5. If a recommendation changes a visible design or product behavior, describe the difference and decide it with the user before applying it broadly.
6. Record the baseline, proposed improvement, affected routes, and decision in the relevant standard or route review.

This means “Flutter-derived” is the starting point, not a command to reproduce every inconsistency or limitation. Improvements should be deliberate and traceable; do not silently replace the Bomach visual identity or alter business behavior.

## Global design foundation scope

The shared design layer should cover the following cross-app rules. Tokens describe stable values; components apply those tokens through semantic variants. Pages should not introduce one-off colors, typography, focus behavior, or breakpoints when a shared role already exists.

| Foundation          | Flutter baseline                                                         | Web treatment and improvement check                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| ------------------- | ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Color               | `AppColors` semantic palette and the light `ThemeData`                   | Preserve the palette and semantic meaning. Check text and control contrast, and define interaction-state colors consistently. Readable `text-muted` uses the existing `neutral500` (`#64748B`); Flutter's pale `textMuted` (`#94A3B8`) remains available as `text-subtle` for nonessential decoration. Small semantic status text uses darker foreground tokens over the same Flutter tinted backgrounds so it meets AA contrast.                                                    |
| Typography and font | Poppins, `AppTextStyles`, and `ThemeData.textTheme`                      | Provide named semantic tiers with size, weight, line-height, and letter spacing. Keep the same font asset initially; review readability and narrow-screen wrapping against actual pages.                                                                                                                                                                                                                                                                                             |
| Spacing and shape   | Four-pixel spacing scale and `AppRadii`                                  | Retain the scale and named radii. Add page gutters or content-width rules only where repeated screen evidence supports them.                                                                                                                                                                                                                                                                                                                                                         |
| Elevation and focus | `AppShadows` and the Flutter focus ring                                  | Preserve the shadow levels and provide one visible, keyboard-accessible focus treatment for shared controls. Avoid adding elevation where Flutter uses flat surfaces.                                                                                                                                                                                                                                                                                                                |
| Responsive layout   | `Breakpoint` at 700px and 1100px                                         | Use four named cutovers at 480, 700, 1100, and 1440px, creating five mobile-first review ranges: compact phone, phone, tablet, desktop, wide desktop. Retain Flutter's 700/1100 transitions; use 480 for compact phones and 1440 for wide desktop. Use the named `phone:`, `tablet:`, `desktop:`, and `wide:` variants rather than introducing Tailwind's unrelated default `sm:`/`md:`/`lg:`/`xl:` thresholds. A page only changes layout at a threshold when its content needs it. |
| Interaction states  | Material button, input, card, dialog, snackbar, chip, and tooltip themes | Apply shared hover, pressed, focus, invalid, pending, and disabled behavior through reusable controls. Preserve established workflow behavior and avoid styling raw HTML in a way that makes component exceptions necessary.                                                                                                                                                                                                                                                         |
| Motion              | Flutter has no shared motion token set in the reviewed theme             | Keep transitions restrained and honor `prefers-reduced-motion`; add named timing/easing values only when real interactions establish a reusable need.                                                                                                                                                                                                                                                                                                                                |
| Overlay order       | Existing Flutter dialog, menu, snackbar, and tooltip behavior            | Define a small shared layer scale when the React shell uses these overlays together; verify focus and stacking behavior rather than choosing arbitrary per-component z-index values.                                                                                                                                                                                                                                                                                                 |
| Browser baseline    | Flutter framework defaults                                               | Normalize font inheritance and browser-only interaction details globally. Keep domain layout and business rules out of global CSS.                                                                                                                                                                                                                                                                                                                                                   |

For representative visual review, use viewport widths of **375, 600, 900, 1280, and 1600px**—one in each range. Check directly around a cutover when a component changes layout there; the five review widths are coverage points, not a requirement to create five different layouts on every page.

Accessibility is part of this foundation, not a later visual polish pass: test keyboard focus, semantic labeling, zoom/reflow, non-color state cues, and text contrast. WCAG AA uses 4.5:1 for normal text and 3:1 for large text. Flutter `textMuted` (`#94A3B8`) measures 2.56:1 on white and 2.45:1 on the app background, so it is too faint for meaningful small text. The React readable-muted token uses the existing Bomach `neutral500` (`#64748B`), which measures 4.76:1 on white and 4.55:1 on the app background; the original pale value remains available as `text-subtle` for nonessential decoration. This is a deliberate web accessibility improvement, not a change to business behavior. See [W3C WCAG 2.2 contrast guidance](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html).

## Current implementation status

- The foundation map is written and linked from the architecture and migration documents.
- The Vite/React/TypeScript/Tailwind scaffold, Flutter Poppins font, semantic color/spacing/radius/typography/shadow tokens, readable-muted/subtle text roles, focus rings, four named responsive cutovers, and reduced-motion handling are in place.
- The first shared UI slice is implemented: Button, Card, PageLayout and its PageHeader, Breadcrumbs, FormControl, TextInput, TextArea, Alert, StatusChip, Tooltip, Dialog, EmptyState, ErrorState, SectionErrorState, SuccessState, Skeleton, PageSkeleton, and LoadingLabel. Their APIs focus on presentation and accessible interaction; modules provide business wording, data, and actions.
- `cn` extends Tailwind Merge with Bomach's semantic typography tiers so font-size and text-color tokens compose without one silently removing the other.
- Button and field focus use shared focus tokens; invalid fields use the danger focus ring. FormControl connects labels, descriptions, and errors, forwards native `required`, and uses polite inline error feedback. Product forms use `noValidate` with the shared validation lifecycle.
- The toast host lives in `src/shared/feedback`; reusable visual primitives live in `src/shared/ui`. The temporary preview mounts one host and exercises the patterns; it is not a product route and will be replaced by the Bomach shell.
- The dialog uses native modal semantics, heading focus by default (or a workflow-provided `initialFocusRef`), Escape handling, Flutter-derived size options, safe-area padding, and full-screen layout below 700px. Tooltip placement is clamped to the visible viewport. Toasts replace the previous toast, default to five seconds without an action, remain until action/dismissal when actionable, and preserve remaining time while hovered or focused.
- Static Alerts have no implicit live role; dynamic contexts select polite `status` or assertive `alert` semantics. Empty, error, and success states announce their message text without including their actions in the live region. Page skeletons are composed to match each route instead of always showing the same cards.
- ESLint, Prettier, Vitest, Testing Library, user-event, and axe-core are configured. Focused tests cover class merging, contrast tokens, form semantics, button pending state, tooltip focus, dialog focus/Escape/backdrop behavior, toast timing/actions, state announcements, and a representative axe pass. Add MSW tests with the API transport, not before the backend contract is known.
- Previous browser review found no horizontal page overflow at 375, 600, 900, 1280, or 1600px, nor at 320px and the 480/700/1100/1440px breakpoint edges. The 320px check led to removing a hard body-width floor that could create horizontal scroll beside a classic scrollbar. Repeat the responsive review for each real route and its important interaction states.
- The browser auth routes/session adapter and backend browser-session contract are implemented locally. The shell registers 40 sidebar destinations plus 12 in-scope direct/detail routes, with permission-aware navigation, search, pinning, saved preferences, account/profile and confirmed sign-out. The Workspace Overview, Company Overview and HR Dashboard are implemented as the first dashboard slice; other route bodies remain placeholders. `TwoFactorSettingsPanel` is ready to mount when the real Profile route is ported.
- The shell navigation polish preserves the route/permission contract while improving hierarchy (Overview, My Work, Company, HR/Admin), live searchable destinations, progressive pin actions, the account footer, Lucide actions, and the permission-aware notification panel. Keep a compact 64px app bar with notifications below 1100px; at desktop widths, remove the separate bar and place notifications beside the brand/collapse controls in the sidebar. If unread statistics fail, the shell does not claim that the user has no unread items. The real notification feed and search were checked in the local signed-in browser; the full viewport and role-permission matrix remains part of shell verification.

## What the Service Operations code gives us

The Service Operations project has useful patterns worth carrying over:

- One API boundary (`shared/api`) that produces a typed `ApiError`; feature APIs own endpoint paths and DTOs.
- Feature-owned query keys, query/mutation definitions, schemas, and mappers where those layers are useful.
- Explicit separation between server state (TanStack Query), URL state (TanStack Router), form drafts (TanStack Form), and short-lived component state (React).
- Reusable permission gates, field controls, error states, dialogs, confirmation, and toast infrastructure.
- Semantic variants and module-owned routes/business components.

The current implementation confirms the boundary, but not every implementation detail should be copied verbatim:

- `src/shared/api/api-client.ts` centralizes Fetch, response parsing, refresh retry, and `ApiError`; the current client is tied to one configured API base URL and its own token store. Bomach may need one client implementation configured for separate auth and operations origins, subject to contract verification.
- `src/shared/errors/error-presentation.ts` classifies errors by user task, sanitizes technical details, and maps backend validation locations to field keys. Adapt its behavior to Bomach's actual response shapes and the agreed interaction standard.
- `src/shared/ui/FormControl`, `Input`, `Button`, `Alert`, and state components demonstrate small reusable boundaries. Their CSS theme is Service Operations-specific; derive the Bomach versions from Flutter tokens instead.
- Service feature APIs and queries own endpoint paths, DTOs, query keys, and cache policy. The module architecture is useful, while Service Operations domains and auth flows are not part of this port.

Do not copy its Inter typography, Service Operations palette, its auth/token-storage assumptions, its permission vocabulary, or every current component and folder. The Bomach app needs Flutter-derived Poppins styling and its own session, API-origin, route, permission, and standalone-app contracts.

## Meaningful verification

- Use Vitest and Testing Library for observable component contracts: accessible names and descriptions, invalid/required state, keyboard interactions, focus, pending behavior, timers, and dismissal.
- Use a small contrast calculation test against the CSS semantic tokens so status foreground/background pairs cannot regress below 4.5:1.
- Use axe-core for representative semantic/accessibility smoke checks. It does not replace color-contrast verification, browser testing, or manual keyboard and screen-reader review.
- Use MSW when the API layer exists to test typed error mapping and page/form state transitions against deterministic responses.
- Use browser automation for native dialog behavior, responsive boundaries, and pilot workflows. Do not create exhaustive snapshots of every component at every viewport; test the breakpoint that changes its behavior and review routes at the agreed representative widths.
- Avoid snapshots that only lock class names or implementation markup. Assert what a user or assistive technology can observe.

## Reuse map

| Area                          | Share across Company and HR                                                                                                             | Ownership and extension rule                                                                                                                                                                               | When to build                                                                                                                                 |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| App providers                 | Query client, theme/design tokens, one feedback host                                                                                    | Compose providers once in `app`; share the same QueryClient with route loaders and components                                                                                                              | Query and toast provider are in place; add providers only when a real app-wide contract needs them                                            |
| Routing and shell             | App shell, shared header/navigation composition, route loading/not-found/forbidden boundaries                                           | `app/router` composes module route contributions. Modules own route definitions; preserve existing URLs. Keep standalone-app launch/return integration at the shell boundary                               | Build the shell foundation before the first page, then extend navigation only for agreed routes                                               |
| API transport                 | Typed Fetch request handling, base URL selection, headers, JSON/text/blob parsing, cancellation, refresh coordination, typed `ApiError` | One implementation or factory in `shared/api`; configuration may create clients for distinct verified origins. Features do not create clients, parse transport errors, navigate, or show toasts            | Browser auth transport and refresh are in place; add feature API contracts as each screen is reviewed                                         |
| Feature API/query layer       | Repeated API and cache conventions                                                                                                      | Each feature owns endpoint paths, request/response DTOs, query keys, query options, mutations, and useful mappers. Keep simple features together; split files when there is a real responsibility boundary | Create alongside the first implementation of each feature, never as empty placeholders                                                        |
| Authentication/session        | Current user, session lifecycle, bootstrap state, login/logout/expiry handling                                                          | Browser uses the documented host-only cookie contract; standalone app identity remains separately verified. No tokens in URLs or JS storage                                                                | Browser auth routes, bootstrap, refresh/logout, and reset behavior are implemented locally; verify preview and mount profile 2FA in its route |
| Permissions                   | Typed resource/action values, `PermissionGate`, route guard, unresolved/loading state                                                   | Permission names map from verified backend vocabulary. Route checks and action checks are separate; never infer privileges from a role label in UI code                                                    | Build with auth bootstrap and route access; define feature permissions from current Flutter/backend evidence                                  |
| Error handling                | `ApiError`, safe normalization, field-error mapping, context-aware placement, error boundaries                                          | Shared policy returns meaning/placement/retryability; the page/form supplies context. Feature-specific field mapping stays with its feature when DTO field names differ                                    | Error policy is planned; wire transport errors after API contract verification. Unexpected React render errors are handled by app boundary    |
| Feedback                      | One toast provider/viewport, toast hook, shared placement rules                                                                         | Mutations return outcomes; owning UI decides feedback. Never toast from API/query code. Persistent form/page/section errors are not toasts                                                                 | Add provider with app shell; use only for transient action feedback                                                                           |
| Form foundation               | Label, required marker, description, input, accessible field error, first-invalid focus, pending submit, server field errors            | Build composable `Field`/`FormControl` plus small controls. Use semantic props and slots; do not make one giant universal form component. TanStack Form/Zod hold field rules; each feature owns its schema | Start with controls observed in the first real workflow; add Date/Time, file, number, picker controls when reviewed routes require them       |
| Basic visual controls         | Button, icon button, card, badge, tabs, page header, breadcrumb, divider, tooltip                                                       | Match Flutter tokens. Use semantic variants (`primary`, `neutral`, `danger`, etc.) rather than raw color props. Use composition for layout differences                                                     | Start from Flutter primitives that recur in reviewed routes; grow variants only from real screen needs                                        |
| Page data states              | Empty, page error, section error, success, loading skeletons                                                                            | Shared presentation components accept title/message/action/children; owning feature decides whether its query is empty, partial, stale, or fatal                                                           | Include the smallest set needed by the first screen, then add proven state variants                                                           |
| Overlays                      | Dialog, confirmation dialog, drawer/sheet where needed                                                                                  | Composition with header/body/footer slots and a small size union. Dialog owns focus, Escape, keyboard, and focus restoration. Feature owns its form/actions                                                | Build dialog and confirmation patterns when the first reviewed modal is implemented; defer drawer until a real route needs it                 |
| Lists and tables              | Search field, toolbar layout, paginator, sort controls, responsive table primitives                                                     | Share layout/interaction mechanics only. Feature owns columns, row actions, filters, sort semantics, status logic, and responsive presentation. Do not create a general-purpose table with dozens of flags | Inventory actual list workflows first; start with the first table and promote repeated mechanics after a second use                           |
| Formatting utilities          | Date/time, money, percentage, phone, initials, safe display formatting                                                                  | Pure functions with explicit locale/timezone/currency inputs. Avoid hidden user/company assumptions                                                                                                        | Add when at least one reviewed screen needs them; promote shared use when a second module needs the same rule                                 |
| Domain selectors and entities | Candidate employee, branch, department, user, and attachment pickers/summary components                                                 | Keep in the owning feature or module until both the data contract and interaction are genuinely shared. Promote through a small public export once a second module uses the same behavior                  | Wait for route/API review; same label does not prove the same backend entity or permission behavior                                           |

## Shared versus feature-owned

### Good candidates for `src/shared`

- Browser/API mechanics, authentication adapter, permission evaluation, error presentation, query/app providers.
- Bomach design tokens and controls that know only presentation and accessible interaction.
- Generic form field wiring, dialogs, confirmation, toast host, and generic loading/empty/error/success states.
- Pure formatting functions whose locale and inputs are explicit.

### Keep inside `src/modules/company` or `src/modules/hr`

- Business rules, permission names, DTOs, endpoint paths, query keys, schemas, status translations, page filters, table columns, and row actions.
- Components that understand company settings, employees, leave requests, attendance, benefits, approvals, or another business record.
- A repeated component that has only one real use today. Keep it local until a second use demonstrates the same contract and interaction.

Example: a generic `StatusBadge` may be shared; the mapping from a leave status to its label/tone belongs to HR. A generic `Select` may be shared; the employee search request and selected employee preview belong to the employee feature until a second feature proves they are identical.

## How shared components stay extendable

1. **Prefer composition over flags.** Use `children`, named slots, or small subcomponents for page-specific content. Avoid APIs that accumulate booleans such as `isCompany`, `isCompact`, `hasFooter`, `useHrMode`, and `showSpecialAction`.
2. **Use semantic variants.** Model stable differences with narrow TypeScript unions, such as button intent, alert tone, dialog size, or error context. Do not expose raw CSS color or spacing to every feature.
3. **Keep control and business policy separate.** `Dialog` controls focus and dismissal; it does not know which record is being edited. `ErrorState` renders a supplied message/action; it does not decide which API errors are fatal.
4. **Make accessibility part of the public API.** Components expose labels, descriptions, IDs, invalid state, keyboard behavior, and status announcements in consistent ways.
5. **Allow native escape hatches deliberately.** Support `className`, `aria-*`, and native input/button attributes where safe. Do not force feature pages to fork a shared component for ordinary layout or accessibility needs.
6. **Promote on evidence.** A component becomes shared after two real workflows use the same responsibility and contract, or when it is clearly platform infrastructure (for example, the API client). Similar appearance alone is not enough.
7. **Split files on responsibility, not on a preset tree.** A small feature can have one API file and one page file. Add contracts, mapper, query, mutation, schema, or component files when separate ownership improves clarity.
8. **Expose small public surfaces.** Module `index.ts` files re-export only stable routes/components needed outside the module. Other features should not reach into another feature's private implementation folders.

## State ownership (no Redux for the current scope)

- **Backend-owned records and async requests:** TanStack Query.
- **Shareable filters, selected record IDs, and deep links:** TanStack Router search/route state.
- **Unsaved field values, validation, and submit lifecycle:** TanStack Form, with feature-owned Zod schemas.
- **Temporary display state:** local React state (open menu, a non-addressable tab, expanded panel, dialog visibility).
- **Authenticated user/session:** the shared auth contract once verified.

Do not copy query data into a second global store. Revisit Redux only if a reviewed workflow demonstrates meaningful client-only state that crosses routes and cannot be represented clearly by URL state, form state, or a small context. Do not use both TanStack Query and RTK Query for the same backend data.

## Incremental build order

This is a staged build, not a list of files to pre-create:

1. **Foundation map — current task.** Confirm boundaries and extension rules in this document.
2. **Small app scaffold.** Create root Vite/React/TypeScript/Tailwind setup, strict TypeScript, semantic tokens drawn from Flutter, and only the provider/router entry points needed to run the app. Do not create empty feature trees.
3. **Global visual foundation.** Map Flutter colors, type, spacing, radii, shadows, focus, and responsive thresholds into shared web tokens. Check accessibility and browser behavior, record any visible improvements, then apply the agreed tokens to the first repeated primitives.
4. **First visual foundation slice.** Review the first repeated Flutter primitives (initial candidates: Button, Card, PageHeader, FormControl/Input, Alert, and page/section/empty states). Use Poppins and Flutter-derived semantic tokens. Add a variant or slot only when a reviewed reference screen needs it.
5. **First reviewed vertical flow.** Finish review of one route and implement it with its feature-owned API/query/form pieces plus only the shared components it actually consumes. This is where to prove that the shared layer is useful rather than speculative.
6. **Foundation adjustments from the second use.** When the next workflow uses a primitive differently, extend the public API by composition or a semantic variant. Do not fork the component or add module-specific rules to `shared/ui`.
7. **Per-feature contracts and standalone integration.** Implement each feature API and permission mapping from verified Bomach contracts. Preserve the standalone-app bridge only after its current launch and identity behavior is traced.
8. **Repeat by vertical slice.** Review and port routes in small Company/HR workflows, promoting a shared pattern only when the same behavior is proven.

The screen-review workbook continues alongside scaffold and visual-foundation work. Protected API-backed page implementation remains gated on verified auth/API/permission behavior. The first page pilot should be chosen after a route has a sufficiently complete review; the existing Employee-list recommendation is provisional.

## Service Operations reference points

The following local source informed the boundary recommendations:

- API client and typed error: `/home/kachy/project/bomach/bomach_os_frontend/services/src/shared/api/` and `/src/shared/errors/`.
- Feature-owned API/query/mappers: `/home/kachy/project/bomach/bomach_os_frontend/services/src/modules/`.
- Shared controls and state patterns: `/home/kachy/project/bomach/bomach_os_frontend/services/src/shared/ui/`.
- Session and permission bootstrap: `/home/kachy/project/bomach/bomach_os_frontend/services/src/app/auth/`, `/src/shared/auth/`, and `/src/app/permissions/`.
- Architectural rules: `docs/architecture/Bomach_Service_Operations_Module_Architecture.md`, `docs/api-integration/API_Integration_Standard.md`, and `docs/design-system.md` in the Service Operations checkout.

For Bomach visual parity, compare against the current Flutter shared primitives under `/home/kachy/project/bomach/bomach_os/lib/components/`, especially `button/`, `input/`, `section/`, `dialog/`, `feedback/`, `cards/`, `chip/`, and `paginate/`.
