# Source Review

## Repositories reviewed

- Flutter Bomach OS: sibling checkout ../bomach_os.
- Service Operations React app: ../bomach_os_frontend/services.
- Port branch: this repository, currently containing planning documents only.

The sibling Flutter checkout has local Company, HR, authentication, routing, permission, and test changes. Keep reading that checkout for the latest behavior; this port branch's Flutter snapshot is historical.

## Flutter Bomach OS

The app is a Flutter and Dart application whose routing, shell, authentication, permissions, UI components, and API services live under lib.

Relevant source locations:

- Company pages and dialogs: lib/pages/company.
- HR pages, controllers, models, and dialogs: lib/pages/hr.
- Route constants and route construction: lib/src/app_routes/app_route_constants.dart and lib/src/app_routes/app_router.dart.
- Shared navigation: lib/components/nav.
- Shared permission checks: lib/src/services/permission_service.dart and lib/components/permission/permission_gate.dart.
- API base selection: lib/src/constants/api_constants.dart.
- Error string translation: lib/src/helper/error_helper.dart.
- Shared feedback: lib/components/feedback/app_toast.dart.
- Inputs: lib/components/input/my_textformfield.dart and lib/components/input/my_dropdown.dart.
- Page, dialog, loading, and empty patterns: lib/components/section and lib/components/dialog.
- Visual tokens: lib/src/constants/colors.dart, textstyle.dart, spaces.dart, and the Poppins font in assets/fonts.

The current source has about 96 Company Dart files and 118 HR Dart files. Those counts include screens, controllers, models, and widgets; they are not counts of routes. A route-by-route inventory is still required before implementation.

### Findings to carry into the port

- The app already has reusable inputs, page and dialog scaffolds, loading skeletons, empty states, toasts, and permission gates. The migration should map these behaviors before adding new React patterns.
- Error presentation is not centralized at the same level as in Service Operations. ErrorHelper returns a string, while pages also use AppToast, Get.snackbar, SnackBar, dialogs, and field validators in differing ways.
- The Flutter code uses GoRouter, GetX controllers, Dio services, secure storage, and backend-provided roles and permissions. These are source behavior to translate, not libraries to carry into React.
- Company and HR routes live inside a larger host app. The route list must distinguish pages owned by Flutter from modules launched as separate applications.
- CLAUDE.md describes some historical conventions and is not fully aligned with the current source. Prefer the code and current route/API behavior when they disagree.

### Existing visual baseline

Use the current Flutter pages as the screen authority. The semantic palette includes Bomach blue #2563EB, slate neutrals, and semantic success, warning, danger, and information colors. The app includes Poppins and a 4-pixel spacing scale. Confirm exact dimensions, breakpoints, typography, icon choices, and dialog geometry from the actual target screen rather than applying these tokens mechanically.

Service Operations uses Inter and its own color tokens. Reuse its architectural and behavioral conventions, not its visual theme.

## Service Operations React app

The Service Operations app is a separate Vite, React, and TypeScript codebase. Its written standards provide useful conventions:

- docs/error-handling-and-feedback.md defines error placement, safe message translation, success feedback, and duplicate-message rules.
- docs/design-system.md defines shared versus domain component ownership, loading and empty behavior, overlays, and accessibility.
- docs/api-integration/API_Integration_Standard.md defines DTO mapping, API boundaries, TanStack ownership, auth, permissions, and cache invalidation.
- src/shared/errors/error-presentation.ts and src/shared/ui provide concrete implementations of those patterns.
- Its API client wraps the browser Fetch API and centralizes bearer tokens, refresh, response parsing, and ApiError creation.

The package uses React, TypeScript, Vite, Tailwind, TanStack Router, Query, and Form, Zod, custom shared UI primitives, Vitest, Testing Library, MSW, and Storybook. It does not use Redux or RTK Query; TanStack Query owns server state. The architecture document records which of these are working choices for this port.

### Patterns to adapt

- A single shared error-presentation utility determines safe wording and the correct placement.
- Shared components own reusable visual and interaction patterns; domain components stay within their module.
- Backend DTOs are mapped into frontend domain types before screens consume them.
- TanStack Query owns server state and mutation lifecycle; local React state owns transient interface state.
- Permissions are evaluated only after authentication and permission loading resolve. The backend remains the security authority.
- Shared UI uses semantic names and supports keyboard and screen-reader behavior.

### Patterns not to copy without review

- Do not import the Service Operations source tree or rely on it as a runtime package.
- Do not copy its Inter font, color palette, page layout, or module-specific business behavior into Bomach OS.
- Do not assume its token keys, deployment origin, auth bootstrap, or iframe integration are interchangeable with the Flutter app. Resolve the shared-session contract before implementing authentication.
- Do not expose raw backend error text merely because the current Flutter helper sometimes returns it.
