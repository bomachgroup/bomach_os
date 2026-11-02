# HR Training and Loans

## React routes

- `/hr/training-program` is the React training program register. It supports one URL-backed search across program names and providers, audience and status filters, paging, details, create, edit and delete. The editor uses the shared date picker, dropdowns, form controls, confirmation and feedback states.
- `/hr/loans` is the cross-employee HR loan register. Its URL-backed views are All requests, Pending approvals and Decision history, with search, status, paging, details, create, pending-request edit, approve and reject. It requires `loans:list`; decision actions require their own permissions and are disabled for the request owner.
- `/dashboard/my-loans` is the employee self-service request page. It uses the existing loan list/detail/create/update endpoints, allows an employee to submit and track their own requests, and permits edits only while a request is pending and `loans:update_own` is granted. It does not show cross-employee search, reviewer tabs, or approve/reject actions.
- Broad `loans:list` access takes precedence over `loans:list_own`: those users stay on the HR register and are redirected away from My Loans. Users with only `loans:list_own` are redirected from `/hr/loans` to `/dashboard/my-loans`; compatible status, paging and request-detail state are preserved, while HR search and review-view state are dropped. The frontend does not use an employee ID as its privacy boundary; backend owner scoping remains authoritative.
- Both routes are permission-gated and retain compatible route state after mutations. The dialogs use shared responsive patterns and preserve a draft after a save error.

## Flutter comparison

### Training

Flutter's `TrainingProgramPage`, `TrainingProgramController`, `AddProgramDialog` and `ViewProgramDialog` provide a paginated card register and create/edit/details flows. The Flutter register's Training Policy button has an empty callback. Its “All Departments” filter is also a placeholder with no behavior, and the listed status labels (Active, Inactive, Scheduled, Pending) do not match the backend status values. React replaces these misleading controls with a name-or-provider search and supported audience and status filters.

The Flutter editor collects program name, provider, description, dates, duration, cost, audience and status. The API derives duration from the date range; React presents it as a calculated value. The API accepts a zero cost, so free programs are supported. Provider and description are optional in React to match the backend and existing records.

### Loans

Flutter's `LoanPage`, `LoanController`, `LoanService`, `AddLoanDialog` and `ViewLoanDialog` provide the register, request form, pending approvals, decision history, details and approve/reject controls. The Flutter service has no update request even though the row menu exposes Edit; React completes the update flow using the backend PUT endpoint. Flutter's employee picker requests up to 500 employees without the React route's permission-aware branch-scoped choice behavior.

The Flutter form exposes an optional attachment field. The loan model persists an optional URL, and the shared `/api/v1/others/upload-file` endpoint accepts multipart files and returns a durable URL. React uses this endpoint for an optional image/document picker and saves the returned URL on the loan; upload starts only when the user submits. If upload succeeds but the loan write fails, the returned URL remains in the draft for retry. The backend has no delete-upload endpoint, so canceling after such a failed loan write may leave an unreferenced stored object. Loan records only support pending, approved and rejected states. The backend has no repayment ledger, installment schedule, paid/repaid status or repayment action, so React does not present those workflows. Repayment date must be in the future and amount must be greater than zero.

## Backend contract and limits

### Training API

The training API supports permission-checked list/detail/create/update/status-update/delete operations under `/api/v1/training-programs/`. Lists support name search, provider, status, target audience, date and cost filters and limit/offset pagination. List and detail responses expose provider, cost, audience and derived duration. The model contains no department relation, employee enrollment, attendance, assessment, per-employee completion, certificate, or training-policy resource. A department filter or those employee-level workflows would need backend work before they can be offered as functional UI.

Create and update validate the date range and supported statuses (`pending`, `in_progress`, `completed`, `cancelled`). The list DTO was expanded to include the provider, cost, audience and duration needed by the register. Invalid dates/statuses now return a client error rather than an unhandled server error.

### Loans API

The loan API supports create, owner- or branch-scoped list/detail, update, approve and reject under `/api/v1/loans`. A caller with `loans:list_own` is scoped by the backend to the signed-in employee; a caller with broad `loans:list` receives its branch/company scope. List search covers employee name/username and request reason; status supports pending, approved, rejected and the history union. Request payloads require positive amount, future repayment date, reason, emergency contact and phone; an optional attachment is a URL. A create payload may name another employee only when the caller has `employees:list`, and the employee must be active and in the caller's branch scope. Personal submissions omit `employee_user_id`, allowing the backend to assign the authenticated owner.

The update endpoint was added to the backend contract. Only the owner may update their pending request, and an empty update or update to a decided request is rejected. Approval/rejection require their respective permissions, branch scope, pending state and a different reviewer from the request owner. Full responses now include `employee_user_id` and `updated_at`, so the UI can enforce owner/edit rules and show a complete detail view. The attachment column accepts a blank value to support requests without a document link.

The loan contract does not provide repayment processing, a payment schedule, an amortization calculation, or a decision reason. The shared upload endpoint supports binary upload, but Loans has no document-specific upload or delete endpoint; the React form stores only the returned URL on the loan.

## Data and query behavior

Training and loan lists use the standard freshness window, keyed by the current user and the full route filters/page. Details use the history freshness window. The loan list query sends no employee ID; ownership is enforced by the backend permission scope. Employee choices are reference data and load only while the HR create form is open and the caller can list employees. The upload request is made only after client validation on submit; it does not change query data. The subsequent confirmed loan create/update invalidates the affected list and detail keys; successful HR loan decisions also invalidate list views. Neither page polls.

## Verification

See the latest Training and Loans entry in [`../testing/qa-findings.md`](../testing/qa-findings.md) for automated tests, backend contract coverage, local seed cleanup and the browser viewport sweep.
