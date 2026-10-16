# Forms, Loading, Error, and Success Standards

## Status

This is the first working draft based on the discussion and the Service Operations feedback standard. Use it as the default while reviewing each workflow against Flutter. Record user-approved exceptions and update this document when a decision changes.

## Purpose

Company and HR should feel like one application and respond predictably when data loads, a form is invalid, a backend rejects a change, or a workflow completes.

Keep the existing Bomach layout and visual language. Standardize where feedback appears and how it behaves, using components styled to match the Flutter reference. Do not redesign screens to fit a generic component library.

## Placement rules

### Field error

Use an inline error immediately below or beside the field when one field can be corrected by the user.

- Associate the label, input, help text, and error semantically.
- Mark invalid controls accessibly and announce errors to assistive technology.
- Do not repeat the same field error in a toast.
- For multiple invalid fields, show each error at its field and focus the first invalid field after submission.

### Form error

Use one persistent form alert when the rejection applies to the whole form, several fields, or a business rule that cannot be assigned to one field.

Place it above the form or near the submit action. Keep the form open and preserve user-entered values after failure. If the server provides both field errors and a form-wide problem, show the field errors plus one form alert for the separate problem.

### Toast

Use a brief toast when an action succeeds or fails and the page remains usable. This is for actions such as a row command, toolbar action, copy operation, or background update.

- Use success, danger, warning, and information tones according to meaning.
- Use a concise message that identifies the action or affected record.
- Show success only after the backend confirms the mutation.
- Do not use a toast for field validation, login errors, a failed primary page load, or information the user must retain while editing.

### Persistent alert

Use an inline Alert for information that must remain visible while the user works, such as a form-wide rejection, a relevant permission restriction, a stale record notice, or a partial outcome that needs attention.

### Section error

Use a SectionErrorState when one panel or dataset fails but the rest of the page remains useful. Include retry when repeating the request can help. Keep unaffected page content visible.

### Page error

Use an ErrorState when the primary page data or main record cannot load. Give a clear title and explanation. Offer Retry when safe and Back or return navigation when useful. Do not also show a toast for the same failure.

### Success state

Use a SuccessState for a major completed workflow when the user needs a reference number, next steps, or a deliberate destination. Use a toast for small updates already visible in the current page. Never show both for the same action.

## Loading and empty states

- Initial page loads use a skeleton shaped like the content that will appear.
- A refresh of one panel uses a panel-level loading indicator; do not blank a whole page for a small refresh.
- Keep existing data visible during background refresh where safe.
- Disable or mark the initiating control pending while a mutation is in flight. Prevent duplicate submission.
- Use EmptyState only when a successful query returns no records.
- Distinguish a truly empty collection from a filter that returns no matches. Offer a create action or a clear-filters action when appropriate.
- Do not represent a network or permission failure as an empty collection.

## Form lifecycle

Use this lifecycle consistently:

1. The user edits a draft.
2. Validate a field on blur and the form on submit; after an error appears, revalidate as the user corrects the value.
3. On submit, show field errors in place and focus the first invalid field.
4. If client validation passes, submit once and show a pending state on the action.
5. Map backend field errors back to matching controls. Show non-field business or transport errors in the form alert.
6. Preserve the draft after failure.
7. After confirmed success, update or invalidate the relevant query data, then close the dialog or show the journey's success state.

Required fields, format, length, numeric bounds, date relationships, file constraints, and cross-field requirements should be consistent across modules. Zod schemas express client-side usability rules; the backend remains authoritative.

## Shared React presentation components

The initial components are deliberately generic. They present states and manage accessible interaction; feature pages decide when a state applies and supply its message and action.

| Component | Use |
| --- | --- |
| `FormControl` with `TextInput` or `TextArea` | One label, required marker, description, control, and inline error. Use it with feature-owned TanStack Form fields; required state is exposed to assistive technology without forcing the browser's native validation popup. |
| `Alert` | Persistent information or a form-wide error. A danger alert is announced urgently; other tones use polite status semantics. |
| `SectionErrorState` | A local dataset or panel failed while the rest of the page remains useful. It can render a retry action. |
| `ErrorState` | The primary page or record cannot load. The caller supplies safe wording and retry/return actions. |
| `EmptyState` | A successful query returned no records. Keep filter-empty wording and actions feature-owned. |
| `SuccessState` | A completed workflow that needs a reference, next step, or deliberate destination. |
| `Skeleton` and `PageSkeleton` | Initial loading placeholders shaped to content; honor reduced-motion settings. |
| `ToastProvider` and `useToast` | One transient action message host in `shared/feedback`. It replaces the previous toast, uses the Flutter-derived three-second default, and pauses dismissal while hovered or keyboard-focused. |
| `Dialog` | Controlled modal with a size union, header/body/footer composition, focus entry and restoration, Escape behavior, and full-screen layout below 700px. |
| `StatusChip` | A visual status label with explicit tone selected by the feature; it does not translate backend status strings into business meaning. |
| `Tooltip` | Short supplementary help for a focusable trigger. It links with `aria-describedby` and clamps its position to the current viewport. |

Use the semantic typography classes through `cn`; the Tailwind Merge configuration knows Bomach's named type tiers so color classes do not erase font-size tokens. Shared buttons and fields use the same keyboard-focus token; invalid fields use the danger variant. `Card` follows the shared Flutter `AppCard` default (12px corners, 16px padding, subtle border and low elevation), while a page can request a different elevation or compose a flat card when its reviewed reference requires it.

The temporary foundation preview demonstrates these patterns only. Do not copy its sample wording or mock actions into product screens. Toasts in the preview are labeled as previews and do not represent backend success.

Do not clear form-wide feedback while the user still needs it. Clear it when the relevant correction or a new submit resolves the issue.

## HTTP and session behavior

### 400 and 422

Show field errors when the response identifies fields. Otherwise show one form-level explanation for a submission or the appropriate local error state for a non-form request.

### 401

For a protected route, clear the invalid session, clear protected query data, and redirect to login. Preserve only a validated internal return path. Show one session-expired message on the login screen. Do not leave the user on a protected page with an error toast.

For login itself, use a neutral credential message that does not reveal whether an account exists.

### 403

For a route, show the Forbidden page after auth and permissions have resolved. For one action on an otherwise usable page, show contextual feedback next to the action or one danger toast. Keep backend authorization authoritative.

### 404

For the primary record, show a page-level not-found state. For a secondary row or background action, use contextual feedback if the page remains usable.

### 409

Treat as stale data or business conflict. Keep the user’s draft, explain that the record changed, and offer refresh or reload when useful. Never silently overwrite newer server data.

### 429

Tell the user to wait and retry. Keep the message near the login or submit form when it applies there; otherwise use a toast if the page is still usable.

### Network and 5xx

Translate transport failures and server errors into safe, plain language. Put the message at the page, section, form, or action that failed. Offer retry only when retrying can help. Never expose stack traces, SQL, framework names, internal hostnames, credentials, or raw storage-provider errors.

## Error wording and duplication

- A shared error-presentation function receives the API error and the context in which it happened, then returns safe wording, placement, retryability, and field errors.
- Feature code chooses a context such as login, form submission, page load, section load, background action, or destructive action. It does not parse backend text independently.
- Do not show the same failure as a field error, form alert, toast, and dialog at the same time.
- Treat an intentionally cancelled or superseded request as control flow, not a user-visible failure.
- Do not display raw status numbers or backend implementation terms to users.
- Keep diagnostic details in development logs, with tokens, passwords, verification codes, private documents, and unnecessary personal data redacted.
- Use concise, action-oriented language. Avoid vague messages such as “Something went wrong” when the failed action and next step are known.

## Destructive actions and permissions

- Confirm destructive or difficult-to-reverse actions before sending the request.
- Name the record and consequence in the confirmation. Use clear action labels.
- Show pending state, prevent duplicate clicks, and provide one contextual error if the action fails.
- While auth or permissions are unresolved, show loading behavior rather than Forbidden.
- Hide or disable actions according to the existing screen behavior, but always rely on the backend to enforce authorization.

## Responsive layout and usability

Every React page, screen, dialog, and major interaction must be designed and reviewed at narrow, medium, and wide viewport sizes. Desktop styling is not the only target. Flutter remains the visual and behavior reference; responsive changes should preserve the same content, actions, permissions, and workflow while adapting their layout to the available space.

Use the shared mobile-first cutovers at 480px, 700px, 1100px, and 1440px. These create five review ranges, but do not require every page or component to change at each boundary. Add a layout change only when the content no longer fits or can be made substantially easier to use. A route may keep a Flutter-specific/content-driven threshold such as 760px or 980px when source review shows it is needed; record the reason and test around it instead of adding unexplained one-off breakpoints.

### Per-screen responsive requirements

- Review each screen at **375, 600, 900, 1280, and 1600 CSS pixels**. Also check 320px and browser zoom/reflow where useful, plus a width immediately around any breakpoint that changes that screen's layout.
- Prevent accidental page-wide horizontal scrolling, clipped controls, overlapping content, and unreachable actions. A dense table may scroll within its own labeled region or use a reviewed compact presentation, but do not silently remove important fields or actions.
- Keep the information hierarchy and reading order clear. Let titles, breadcrumbs, toolbars, and action groups wrap or stack deliberately instead of shrinking text or controls until they collide.
- On compact layouts, preserve access to primary navigation and key actions. If the Flutter layout cannot fit the browser viewport, record the adaptation (such as a navigation drawer) and preserve the same destinations and permission behavior.
- Make forms comfortable to complete at every width: use a clear narrow-screen field order, keep labels/help/errors attached to their fields, allow validation messages to expand the layout, and keep submit/cancel actions visible and operable.
- Keep dialogs and menus inside the viewport. Allow long content to scroll without hiding the title, close action, or important footer actions; ensure focus moves into an overlay and returns to its trigger when it closes.
- Preserve status visibility and interaction during resizing. Loading, empty, error, success, pending, and permission states must not overlap, truncate, or become color-only cues at narrow widths.
- At wide desktop sizes, use available space without stretching text and forms into hard-to-scan lines. Choose content constraints per screen based on the Flutter reference and the actual data layout.
- Check pointer, touch, keyboard, and browser zoom behavior where the control is used. Responsive layout must not remove keyboard focus indicators or break assistive-technology labels and announcements.

Capture the normal screen plus the important responsive interaction states for the route review. Record any layout adaptation from Flutter, why it is needed, and whether it changes visible behavior. Ask the user before a responsive adaptation changes workflow behavior or removes information.

## Accessibility

- Use semantic form labels and connect descriptions and errors with the control.
- Provide visible keyboard focus and keyboard operation for dialogs, menus, selects, and buttons.
- Announce asynchronous errors and success through appropriate alert or status semantics.
- Do not communicate state by color alone.
- Restore focus when a dialog closes and move focus into a dialog when it opens.
