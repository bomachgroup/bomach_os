# Worksites, Operations Tasks, and Engineering Site Reports

## Scope

The React Operations area now provides protected list and detail routes for Worksites, operational Tasks, and Engineering Site Reports. Employee task ownership and personal report submission remain in **My Work**; this port does not replace those self-service experiences. Site equipment management, Survey Site Reports, Contracts, Meetings, and Flutter changes are out of scope.

## React behavior

- `/works/worksite` is a searchable, paginated register with project/status filters, create/edit, protected delete, and detail links. The detail page shows site facts and contextual links to its tasks and Engineering reports.
- `/works/tasks` opens on Active work (pending and in progress), with All and individual status history, search, priority/project/worksite filters, pagination, create/edit, assignee selection, status changes, and confirmed deletion. Task detail links to its worksite when one exists.
- `/works/engineering-site-reports` opens on Submitted / Needs review, with All history, employee/project/worksite/date filters, pagination, report details, and reviewer decisions. Authors create their own reports; draft/rejected reports may be edited, submitted reports may be approved or returned, returns require a reason, and self-review is prohibited.
- All three registers use URL-backed state, scoped React Query caches, existing permission checks, shared loading/error/empty feedback, and responsive card/form patterns. Create and edit flows use the existing shared controls and dialogs.
- The Engineering report wizard retains existing attachment URLs and uses the authenticated `/api/v1/others/upload-file` flow for new images/documents. Inventory choices are limited to the selected worksite.

## Backend contract and safety

- `Task.worksite` is nullable and protected from deletion while referenced. Migration `operations.0009_task_worksite_link` adds the relation without guessing links for existing tasks.
- Task list/create/update/detail contracts include `worksite_id` and worksite summary. The `active` filter means pending plus in-progress. A project-linked worksite and its task must share a project; the task project is inferred from a linked worksite when appropriate. Assignees must belong to the task project's branch.
- Engineering report context and reviewer decisions are checked against the caller's accessible branch/project scope. A worksite with linked tasks, reports, or inventory cannot be hard-deleted; the API responds with a conflict so an authorized user can mark it inactive.
- Existing report submission/review services remain authoritative for expense and inventory side effects. No new endpoint, schema, file storage, or database subsystem was introduced for attachments.

## Local QA fixtures

The existing `seed_operations_demo` command now also creates/reuses clearly marked synthetic worksites, site-linked tasks, one synthetic inventory item, and Engineering reports spanning Draft, Submitted, Approved, and Rejected. Cleanup identifies only records carrying stable Operations QA markers and removes dependent report/expense/inventory records in a safe order. The command retains its `DEBUG=True`, `TRY_LOCAL_DB=True`, SQLite-only guard. Do not run it against staging or production.

The verified local development database is SQLite at the backend's local `db.sqlite3`. Re-running the seed command kept the marked fixture counts stable: 25 projects, 25 worksites, 25 linked tasks, one marked inventory item, and four marked Engineering reports.

## Verification record — 2026-11-13

- Frontend full suite: **765 tests across 135 files passed**. TypeScript typecheck, ESLint, and production build passed. Vite still reports the repository's existing `face-api` chunk-size advisory; the new register route chunks are approximately 16–20 kB minified.
- A create-form walkthrough found and fixed a project-resolution gap: choosing a project-linked Worksite now fills the project field and exposes branch-approved assignees. Focused Operations tests after that fix passed **27 tests across 6 files**, including the new project inference regression cases.
- Local browser CRUD: created temporary task **#54** on Worksite **#53**, confirmed the linked project and Ifeoma Eze assignment in the task register and detail, then deleted only that temporary task. The active-task count returned to its original 15; the seeded fixtures remain.
- Backend regression suite: **28 tests passed** across task/project APIs and Engineering Site Reports. This includes branch-scoped assignments/review, self-review prevention, protected worksite deletion, worksite project-relink protection, active filtering, report inventory/expense side effects, rollback, and resubmission.
- The repository-wide `npm run format:check` reports four existing formatting violations in untouched files: `src/app/shell/app-catalog.test.ts`, `src/app/shell/app-catalog.ts`, `src/modules/auth/routes/splash-page.tsx`, and `src/shared/auth/workspace-memory.ts`. Changed Operations/porting files are checked separately.
- Live browser smoke checks confirmed Worksite, Task, and Engineering report registers; Active and Needs review defaults; site/task/report detail context; the inventory selector and review summary; the evidence file picker; and approve/return confirmation dialogs. The return action is disabled until a reason is entered. Dialogs were cancelled without submitting a report or changing a review decision.
- Register layouts were checked at 320, 375, 600, 900, 1280, and 1600 CSS pixels. The worksite/task/report detail and review surfaces were checked at 320 and 640 pixels. No document-level horizontal overflow was measured during the register matrix. The embedded browser ignored Ctrl+plus zoom shortcuts, so true 200% browser zoom was not verified; 640px was used as the equivalent layout-width check.
- No browser file was uploaded and no Engineering report was created or decided during the visual pass. Backend lifecycle and scope behavior is covered by the isolated test suite above.

## Follow-up

- Keep the local QA fixtures for repeatable role, filter, status, and detail testing. Use the isolated Django test database for automated mutation/side-effect coverage.
- Re-run changed-file Prettier, focused React tests, backend Operations/reporting tests, and production build after any follow-up edit. Resolve the four unrelated format violations separately before treating repository-wide `npm run check` as green.
- Perform an actual 200% zoom keyboard/focus pass in a browser that supports browser-level zoom before release sign-off.
