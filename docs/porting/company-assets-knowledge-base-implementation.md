# Assets and Knowledge Base

## Scope

This port covers `/company/assets` and `/company/knowledge-base` in the React application. It follows the existing protected-route, permission, query, dialog, form, status, loading, and error patterns. The Flutter application and its files were not changed.

## Knowledge Base

The Flutter `CompanyKnowledgeBasePage` is an unavailable-capability state, not a document catalogue. The backend has no company-wide Knowledge Base API or supported CRUD contract. React therefore renders an explicit unavailable state, does not invent sample records, and links to My Role resources at `/dashboard/role` as the existing applicable alternative. A real shared Knowledge Base requires a backend contract before document CRUD can be implemented.

The route remains authenticated and uses the existing `roles:list` access requirement from the route manifest, but is intentionally excluded from the sidebar (matching the OKR capability page) until a company-wide backend contract exists. Direct links remain registered and protected.

## Assets

The Assets page is backed by the existing Asset model and `/api/v1/assets/` endpoints. The React page provides:

- Search and URL-backed page navigation for the paginated register.
- Responsive table and small-screen card presentations.
- Full asset detail view, including assignment, financial and warranty information, notes, and document links.
- Permission-gated create, edit, and delete actions.
- A four-step create/edit wizard for asset identity, location and assignment, purchase/records, and a final review before saving. Step-level validation prevents advancing with invalid required values, while review actions return to the relevant step without losing the draft.
- Asset fields for type, branch, employee, department, dates, value, supplier/invoice details, status, serial/IMEI/manufacturer, notes, and documents.
- The existing `/api/v1/others/upload-file` upload contract for a selected file, with the returned URL stored in the asset document list.
- Loading, empty, error/retry, validation, upload, save, and delete-confirmation states.

The React search state is validated from the URL. Search changes reset pagination, and successful mutations invalidate the current asset register so updated data is fetched from the API.

## Backend Contract Repairs

The existing Asset API had gaps that prevented a reliable port. This change repairs those gaps without a database migration:

- Asset responses now include the record `id`, which is required for detail, update, and delete actions.
- Search uses actual Asset fields instead of the nonexistent `asset_id` field. It searches name, serial number, IMEI, manufacturer, branch, and invoice number.
- The register accepts `department_id` filtering.
- `GET /api/v1/assets/choices` returns branch, employee, and department options for the form. Branch-scoped users receive only branches and employees in their assigned branch scope.
- List, detail, update, and delete respect the branch IDs resolved by the existing permission middleware. A branch-scoped user cannot read or mutate an asset outside that scope, and create/update validate the selected branch.

### Existing data limitation

`Asset.branch` is a text value, not a foreign key to `Branch`. Branch names are not unique in the current data model, so two branch records with the same name cannot be safely distinguished from an Asset row. To avoid leaking or changing records across those branches, branch-scoped list/choice results omit ambiguous names and scoped writes reject them. This is a safe guard, not a data migration; the durable model fix is to store a branch foreign key in a separately planned migration.

The existing global permission behavior remains unchanged. The branch guard applies when permission middleware supplies a branch scope.

## Verification

- Backend: `python manage.py test hr.tests.test_assets_api --verbosity 0` passed 4 tests.
- Frontend: focused API, page, and router tests passed 23 tests.
- TypeScript, focused ESLint, focused Prettier, production build, and `git diff --check` passed. The Vite build still reports the existing large face-model chunk advisory.
- Live local QA exercised asset create, detail, edit, search, URL persistence after reload, delete cancellation, and confirmed delete. The uniquely named QA record was removed, and the local database was checked for zero matching rows afterward.
- The Assets page was measured at phone, tablet, desktop, breakpoint-edge, and wide viewport widths from 320px through 1600px; no horizontal document overflow was found. Knowledge Base was checked in the live app at 1280px.
- No real file was uploaded during browser QA. The file picker/upload path is covered at the API contract level, but external storage delivery and opening a newly uploaded file were not verified in this pass.
- No seed data or persistent QA fixtures were left behind.

### Follow-up: staged asset form and responsive QA (2026-10-26)

- The create/edit form now follows the shared four-step creation-flow pattern and includes a review-before-save stage. The Assets page action follows the shared page-header placement and adapts its label for narrow screens.
- Browser QA at **360×640**, **375×812**, **497×684**, **768×900**, and **1024×768** covered the register/header, wizard steps, review, details, and fixed action footer. At 360px the dialog remained inside the viewport and its content scrolled independently; at the 497px breakpoint edge the step labels remained distinct after shortening the local third-step label to “Records.” Tablet and desktop fields used the expected two-column layout. No horizontal page overflow was observed at the tested widths.
- Live local QA covered missing required input, field correction, step navigation, preserved draft values, review changes, create success, details, edit success, search/no-match recovery, URL persistence after reload, delete cancellation, and deletion of the exact synthetic QA asset. The local register returned to zero QA matches; no pre-existing records were modified.
- Automated asset, shared creation-flow, and asset API suites passed **17/17 tests across 3 files**. Targeted ESLint and Prettier passed. `npx vite build` passed with the existing large face-model chunk advisory. `npm run typecheck` and `npm run build` remain blocked by an unrelated existing `EmployeeDto` cast error in `src/modules/hr/routes/employees-page.test.ts:9`.
- An expanded run including the adjacent Branch form suite had one unrelated failure: its copied-hours test expected a “Review branch details” region that the rendered branch dialog does not expose. The branch flow was not changed.
- The browser automation could not reliably open the native file chooser, so a real file upload and external-storage delivery were not verified. Upload success, failure, and size-limit behavior are covered by the focused component tests; do not treat that as proof of storage-provider availability.
