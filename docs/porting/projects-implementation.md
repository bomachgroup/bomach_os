# Projects register and detail implementation

## Routes and permissions

- `/works/projects` is protected and requires `projects:list`. Create, edit, archive/restore, view, and delete controls are shown only when the signed-in session grants the matching `projects` action.
- `/works/projects/:projectId` is a protected detail workspace requiring `projects:view`. Its Overview, Members, Work site, Files, Milestones, Tasks, Associates, and Meetings sections are URL-backed with the `tab` query value; they do not add sidebar routes.
- The API remains the existing project operations contract. List, detail, create, update, archive/restore, and child records use the dedicated methods in `src/modules/operations/projects.api.ts`.

## Register and form behavior

- Search is debounced and applies as the user types. It uses `replace` navigation, resets the page to 1, and remains shareable in the URL. Status and priority are URL-backed and sit side by side from 361px; they stack below that width.
- Project cards show status, code, category, location, summary, progress, budget, priority, and schedule. Budget and priority share a compact full-width allocation strip through tablet widths; from the 1100px desktop breakpoint it becomes a dedicated side panel. Critical and high priorities use danger/warning badges; the smallest phone width shortens the visible badge while retaining the complete accessible name. Schedule dates use two balanced, labeled tiles with calendar/target icons and actions remain on their own row through tablet widths. Actions align to the right edge and collapse to icon controls below 480px with accessible labels. The list clamps a page that becomes invalid after a filter change.
- Create and edit use the shared three-stage creation flow. Basics and Delivery validate before advancing; Review summarizes the draft without saving. The Next and final submit controls are distinct keyed buttons so the browser cannot apply the Next click to a newly rendered submit action. Edit links return to the matching stage with the entered values intact. The final Create project or Save changes action is the only write.
- Project form sections use the shared muted, bordered surface style. The client picker opens at a 420px minimum width when space permits and stays clamped to the dialog on narrow screens, keeping long client names and descriptions easier to read.
- Progress is held as text while editing so the default zero can be cleared. Empty, non-integer, negative, and over-100 values produce an inline field error. Server field errors map back to the related input, and invalid future-step navigation returns to the first invalid stage.

## Freshness and persistence

- List queries are scoped by the authenticated user and employee. Search/filter/page parameters are part of the query key and route search.
- Successful create/update invalidates the project lists and Operations overview, plus the changed detail query for updates. Detail mutations refresh project data and the Operations overview so visible summary values do not remain stale.
- No backend schema or database migration was required for the register redesign. The current project response returns `client_id` without a client display name; the detail screen therefore uses the explicit `Client #<id>` fallback. Returning a client name would require a backend response change and a permissions review because the client-options endpoint is limited to project create/update access.

## Operations overview data lifecycle and compatibility

- `projectQueries.overview(userId, employeeId)` owns the `/operations/dashboard/overview` query. It uses the standard 60-second freshness age, revalidates when stale on route entry, browser focus, and network reconnect, retries one failed request, and polls every 60 seconds only while this route is active in a foreground tab. Create/update/archive/restore/delete mutations invalidate the Operations query through the project query family.
- The summary response has changed additively across backend deployments. Older responses may omit `total_tasks`, expense/utilization values, and `recent_projects`; the React overview treats those as unavailable instead of assuming a fixed response version. `recent_projects` is checked as an array before rendering.
- The project highlights section is shown only when the session has `projects:list`. If the overview response omits the recent list, it explains that highlights are unavailable and links to the scoped Projects register. An omitted field is never presented as an empty project database. A returned empty list represents no active project highlights and may offer project creation when authorized.
- Cached overview values stay visible during refresh. A first-load query failure uses the page-level retry state; a successful response with an omitted optional summary uses the local unavailable state. No unrelated route is refreshed by this fallback.

## Verification record — 2026-11-12

- Focused Projects register/form tests passed **8/8**, including live-search route state, status filtering, list-to-detail navigation, detail-tab URL updates, review-without-write, inline validation, cleared-zero progress, and server field errors.
- TypeScript typecheck passed. Focused ESLint and Prettier checks passed for the Projects list, detail, form, and their tests. Production build passed; Vite reported the existing large `face-api` chunk advisory.
- Full repository ESLint passed. Repository-wide Prettier check currently reports formatting issues in `src/app/shell/app-catalog.test.ts`, `src/app/shell/app-catalog.ts`, `src/modules/auth/routes/splash-page.tsx`, `src/modules/operations/routes/operations-page.tsx`, and `src/shared/auth/workspace-memory.ts`; these files were not changed as part of this Projects pass. The full Vitest suite ran **750 tests: 749 passed, 1 failed** in the unrelated HR `employee-action-dialog.test.tsx` case `submits a trimmed reason with the selected valid exit date`.
- Browser CRUD used the local development database only: Django `DEBUG=True`, SQLite, and console email backend. Test Admin created synthetic project **#53**, `QA Projects visual pass 20261112` (`QA-VISUAL-1112`) on the QA branch/client, then edited its progress from 35% to 42%. The synthetic record remains in the local database so it can be inspected and reused; no existing project was changed.
- The live browser confirmed field-level progress validation, the Review stage and its Edit delivery shortcut, create/update success, live search, combined status/priority filtering, and all eight project detail sections. A live detail-tab click initially reproduced a 404 because the route's search-only navigation emitted the pathless route ID in the URL. Navigation now supplies the canonical `/works/projects/$projectId` path and keeps the selected tab in the query.
- List widths checked: **320, 360, 361, 375, 480, 768, 1024, 1280, and 1440px**. Detail widths checked: **320, 360, 361, 375, 480, 600, 768, 900, 1024, 1280, 1440, and 1600px**. No horizontal document overflow was measured; filter columns switch at 361px and detail tabs use intentional horizontal scrolling on narrow screens. The create/edit dialog was visually checked at 320px and desktop width; its body scrolls while its footer actions remain visible. 200% browser zoom and a complete keyboard-only pass were not covered.

## Verification continuation — 2026-11-12

- Live testing reproduced an early create on the Delivery → Review click. Distinct keys now prevent the Next button from becoming a submit button during that click; browser verification confirmed the form remains on Review until **Create project** is activated. Edit likewise remains on Review until **Save changes**. The client option menu now uses a 420px minimum width within the dialog bounds, and the field/review panels follow the shared muted form-section styling.
- Responsive screenshots were reviewed at **320×740, 375×740, 600×800, 900×900, 1280×900, and 1600×1200**; the long client picker was checked at 320px and 466px. The two temporary QA projects created to verify the failed and corrected flows were deleted. The retained project **#53** from the prior QA pass was not changed.
- `npx vitest run src/modules/operations` passed **18/18 across 4 files**. Typecheck, full ESLint, scoped Prettier, and production build passed. Vite reported its existing advisory for the large `face-api` chunk.

## Responsive project-card refinement — 2026-11-12

- Project cards retain their current fields and permissions. Their allocation strip stays full-width and compact below 1100px, while desktop uses a 16rem allocation panel. Schedule dates are separated into two cells and action buttons keep a dedicated row through tablet widths. Long project names wrap below 480px, and the under-361px priority chip uses a compact visual label with the full accessible name.
- The project list query remains scoped by user, employee, URL filters, and page. Its existing standard freshness, focus/reconnect revalidation, cached list retention, and mutation invalidation behavior are unchanged; this is a presentation-only change.
- Live register checked at **320, 375, 600, 900, 1099, 1100, 1101, 1280, and 1600px**, plus effective widths of **640 and 800px** as 200%-equivalent layouts. Measured `documentElement.scrollWidth` matched `clientWidth` at every width. The allocation strip was one column through 1099px and changed to the side panel at 1100px; the footer changed from column to row at the same breakpoint. Verified with local Test Admin and existing synthetic `OPS-DEMO-*` records; no records were mutated.
- The project route suite passed **18/18 across 4 files**. TypeScript, full ESLint, focused Prettier, `git diff --check`, and the production build passed; Vite retained its existing large `face-api` chunk advisory. Automated coverage includes tablet allocation layout, priority badge semantics, schedule/action grouping, and long project names. Actual browser-level 200% zoom was not verified.

## Schedule and action alignment — 2026-11-12

- Start and target dates now use compact bordered tiles with distinct calendar/flag icon badges, uppercase labels, and emphasized date values. Project actions are right-aligned at every width; on narrow screens they remain compact icon buttons with accessible names.
- Visual browser checks at **320×850, 375×850, and 600×850** confirmed the paired date tiles and right-aligned action row fit without clipping. Existing responsive rules and project navigation remain unchanged.
- Operations tests passed **18/18 across 4 files**. TypeScript, full ESLint, scoped Prettier, and the production build passed; Vite reported its existing large `face-api` chunk advisory. Actual browser-level 200% zoom was not verified.

## Project detail and dialog polish — 2026-11-12

- The project detail header now keeps the back control, project name, and actions on one responsive line. Below 700px, Edit and Delete become compact icon buttons with explicit accessible names; the project section navigation follows the HR employee-profile card/grid pattern and preserves URL-backed tab selection.
- Project create/edit, child-resource entry, archive/restore/delete confirmations, and list confirmations use the shared popup gradient header, muted form surface, content-sized height, and visible action footer. Short forms no longer stretch across unused vertical space; longer forms use a capped dialog with an internal scrolling body.
- Live browser checks used the local Test Admin and existing synthetic project #26, `Operations demo project 01`. The detail page and dialogs were visually checked at **320×812, 375×812, 600×900, 900×900, 1280×900, and 1600×1000**. Add-associate was checked at mobile and desktop widths; Add-meeting was checked at 320, 600, and 1600px, including its internal scroll and fixed footer. The edit wizard was checked at 375 and 1280px; the delete confirmation at 375px. Dialogs were closed without submitting or confirming; no project records were changed.
- Added a regression test for the HR-style detail header/tab layout and compact popup styling. The focused Projects route suite passed **7/7**; the full Operations suite passed **19/19 across 4 files**; shared Dialog tests passed **7/7**, including sizing and keyboard/focus behavior. TypeScript, full ESLint, scoped Prettier, `git diff --check`, and production build passed. Vite reports its existing advisory for the large `face-api` chunk. Actual 200% browser zoom was not verified.
