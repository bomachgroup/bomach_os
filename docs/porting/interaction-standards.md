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
- Use the native `required` attribute for required text controls. Forms use `noValidate` and shared validation so the browser does not replace Bomach's inline feedback with native popups.
- Mark invalid controls with `aria-invalid` and connect help and the error through `aria-describedby`. Use one live announcement for a newly displayed error; do not also point `aria-errormessage` at the same text.
- Keep inline field errors polite. On submit, focus the first invalid control so its label, value, and associated error are read together.
- Do not repeat the same field error in a toast.
- For multiple invalid fields, show each error at its field and focus the first invalid field after submission.

### Form error

Use one persistent form alert when the rejection applies to the whole form, several fields, or a business rule that cannot be assigned to one field.

Place it above the form or near the submit action. Keep the form open and preserve user-entered values after failure. If the server provides both field errors and a form-wide problem, show the field errors plus one form alert for the separate problem.

### Toast

Use a brief toast when an action succeeds or fails and the page remains usable. This is for actions such as a row command, toolbar action, copy operation, or background update.

- Use success, danger, warning, and information tones according to meaning.
- Use a concise message that identifies the action or affected record.
- Simple toasts remain for five seconds by default. A toast with an action stays until the user acts or dismisses it unless the caller supplies an explicit duration. Pausing on hover or focus preserves the remaining time.
- Show success only after the backend confirms the mutation.
- Do not use a toast for field validation, login errors, a failed primary page load, or information the user must retain while editing.

### Persistent alert

Use an inline Alert for information that must remain visible while the user works, such as a form-wide rejection, a relevant permission restriction, a stale record notice, or a partial outcome that needs attention.

Static alerts do not become live regions solely because of their visual tone. Set `role="status"` or `role="alert"` only when the content is newly inserted or updated and should be announced; use a polite status for partial updates and reserve assertive alerts for urgent failures.

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

## Roles and employee administration

- Keep search, branch/department filters, active/past views, and pagination in the route URL so a directory view can be shared and restored. Preserve the selected record in a stable role or employee detail URL; profile sections are URL-addressable.
- Role create/edit uses a guided, permission-aware flow: role name and branch scope, responsibilities when the user has description access, then permission grants. Role permission groups reuse My Role's collapsed work-area sections and icons/colors, opening matching groups for search or filter. Provide resource/action search, a work-area filter, A–Z/Z–A/assigned-first ordering, selected-only filtering, and select/clear-visible actions that affect expanded, currently visible grants only. Branch choices must load before advancing, and the permission map must load before save; retry either lookup in place and retain the draft on lookup or mutation failures. Cards keep View/Edit/Delete actions right aligned; at narrow phone widths, use an even three-column action row with visible labels. Treat purpose and grants as one save from the user's point of view; display a confirmed success only after the backend transaction succeeds. Role standards live in the related detail tabs, not in an oversized list card.
- Employee create/edit is a five-step Identity, Contact, Employment, Compensation, Review flow. Review all entered sections before saving, mask bank/statutory identifiers, and let users return to a section without losing their draft. Populate branch, department, unit, role, and manager from named choices rather than asking staff to type database identifiers. The backend owns initial-password generation; never request or display a password in the HR form.
- Keep employment status distinct from login access in labels and confirmation copy. Leave keeps account access enabled; suspend/deactivate disable it; activation restores it. Exit is an immediate offboarding action with a required reason and a date no later than today. The server enforces the matching permissions and branch scope.
- Use a file picker for employee documents and show file name, type, size limit, pending state, and upload result. Do not ask staff to paste image/document URLs. Keep compensation and personal information behind the API's employee view/list permission checks; frontend field hiding is not an access-control boundary.
- Profile sections use their own loading, empty, error, and retry state so one missing document, review, task, or report does not make the whole profile appear broken. A role-less employee gets a clear “No role assigned” plan state instead of a failed query or generic retry.

## Shared React presentation components

Single-line form controls use the shared `CONTROL_SIZE_CLASSES` standard: 38px minimum height, 11px text, and 9px vertical by 10px horizontal padding. `TextInput`, `TimeInput`, `DatePickerField`, and `DropdownSelect` share this sizing, including filter dropdowns. Field labels use the bold `text-control-label` 10px tier to match the local Service module. Keep multiline text areas taller for writing while retaining the same type scale and padding. Prefer these shared controls over page-specific input styles so sizing remains consistent across Company, HR, attendance, and profile forms. Use `FormSection` for the muted, bordered panel in creation and edit flows, `CreationFlowStepper` for accessible per-flow progress, and `CreationFlowActions` for consistent navigation layout. These primitives support different step counts and flow behavior without owning feature validation or save logic.

The initial components are deliberately generic. They present states and manage accessible interaction; feature pages decide when a state applies and supply its message and action.

| Component                                    | Use                                                                                                                                                                                                                                                                                                                                                                                 |
| -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `FormControl` with `TextInput` or `TextArea` | One label, required marker, description, control, and inline error. Use it with feature-owned TanStack Form fields; native required semantics work with `noValidate` to avoid browser validation popups.                                                                                                                                                                            |
| `Alert`                                      | Persistent information or a form-wide error. Static alerts have no live role by default; the owner chooses polite status or urgent alert semantics when an update needs announcement.                                                                                                                                                                                               |
| `SectionErrorState`                          | A local dataset or panel failed while the rest of the page remains useful. It can render a retry action.                                                                                                                                                                                                                                                                            |
| `ErrorState`                                 | The primary page or record cannot load. The caller supplies safe wording and retry/return actions.                                                                                                                                                                                                                                                                                  |
| `EmptyState`                                 | A successful query returned no records. Keep filter-empty wording and actions feature-owned.                                                                                                                                                                                                                                                                                        |
| `SuccessState`                               | A completed workflow that needs a reference, next step, or deliberate destination.                                                                                                                                                                                                                                                                                                  |
| `Skeleton` and `PageSkeleton`                | Initial loading placeholders shaped to content; honor reduced-motion settings.                                                                                                                                                                                                                                                                                                      |
| `ToastProvider` and `useToast`               | One transient action message host in `shared/feedback`. It replaces the previous toast, uses a five-second default, keeps action toasts until acted on or dismissed, and preserves remaining time while paused.                                                                                                                                                                     |
| `Dialog`                                     | Controlled modal with a size union, header/body/footer composition, focus entry and restoration, Escape behavior, and full-screen layout below 700px by default. `compactOnMobile` is reserved for short confirmations and brief account checks; create/edit forms use the shared full-screen phone layout. See the [Popup and Dialog Design Standard](./popup-design-standard.md). |
| `StatusChip`                                 | A visual status label with explicit tone selected by the feature; it does not translate backend status strings into business meaning.                                                                                                                                                                                                                                               |
| `ProgressBar`                                | Compact, 6px accessible progress track with a bounded value and reduced-motion-aware fill. Reuse it for target completion and dashboard scores; feature components own the adjacent labels and tone.                                                                                                                                                                                |
| `Tooltip`                                    | Short supplementary help for a focusable trigger. It links with `aria-describedby` and clamps its position to the current viewport.                                                                                                                                                                                                                                                 |

### Permission descriptions

Use the shared `PermissionActionGroups` component when showing granted permission actions. Group actions by resource and use the backend's matching `label` and `helper_text` so every area explains the same grant consistently. Pointer hover waits one second before showing help; keyboard focus shows it immediately. Keep the trigger focusable and descriptive, and do not make informational grants look like actions the user can invoke. This component is shared by Profile/Role and should be reused in HR permission views.

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

## Page headers, breadcrumbs, and URL state

- Keep the global application header focused on app-level controls. Do not repeat the active route there.
- Use the shared `PageLayout` for authenticated pages. It places the `PageHeader` in a full-width surface band across the content pane, with a subtle bottom border, and aligns the padded page body beneath it. On desktop, keep the band pinned to the top while the document scrolls; below 1100px, let it scroll normally beneath the compact app bar. This preserves TanStack Router's document scroll restoration and avoids a nested page scroll region.
- The shared `PageHeader` owns the page title, optional short description, concise route context, route-specific actions, and an optional second row for page-level tabs or filters. For one primary action or a compact status summary, use `actionsInline` so it stays on the title row at every width. The title flexes and truncates visually when space is tight; its complete text remains in the heading's accessible name. Keep the action at intrinsic width rather than stretching it across the page.
- Responsive primary action labels follow the KPI Management pattern: show the full label at 480px and wider, a short label such as **New** from 361px through 479px, and an icon only at 360px and narrower. Keep the complete action name in `aria-label` when its visible label shortens or disappears. Use the action's own noun on wider screens; do not add a second CTA row for a single primary action.
- Do not force several unrelated actions, long forms of status controls, or a two-button action group onto the title row. Keep these groups below the title on narrow screens and allow deliberate wrapping. A `toolbar` remains a separate row for actual page-level navigation or filters.
- Do not add generic **Refresh** buttons to page headers or section headers. Use the shared query freshness, focus/reconnect revalidation, and mutation invalidation rules. Keep a contextual **Retry** in the affected loading/error state when a failed request can be retried; retry is recovery from that failure, not a general page action.
- Use one context treatment: when breadcrumbs identify the section, do not repeat it as an eyebrow or another page trail. Start breadcrumbs at the nearest meaningful parent; do not add a generic `Workspace` root. Link an ancestor only when it is a registered route the current session can visit. The page title identifies the current location.
- Keep Coming Soon pages compact. They use the shared title and any meaningful parent breadcrumb, with no fabricated page description, page actions, tabs, or filters.
- Below 480px, replace the full breadcrumb trail with a back link to its nearest accessible ancestor. Keep the same page title and action available across widths, following the responsive header pattern above.
- Treat the pathname as the page or record identity. Put durable, user-visible view state such as search, filters, sort order, pagination, selected tab, and view mode in TanStack Router search parameters so refresh, browser Back/Forward, and a copied link restore that view.
- Nested pages use one shared, compact arrow-only back button immediately before the title. Give it an accessible name such as `Back to Branch directory`, remove the decorative route icon tile when the back action is present, and align a single compact action/status with the title. Multi-action sets stay below the title on narrow screens. Link to a safe canonical parent route, not `history.back()`; carry forward only validated parent-list search state. This keeps direct links and copied URLs navigable.
- Each route owns and validates its search parameters with `validateSearch` (use a route-owned Zod schema when the values need coercion, bounds, or enumerations). Components read validated search state and update it through TanStack Router; do not keep a second local copy of durable route state.
- Omit default values from generated links and normalize invalid values to safe defaults. Reset dependent state such as the page index when a filter or query changes. Use history replacement for high-frequency text entry so each keystroke does not create a history entry; use normal navigation for deliberate view changes users may want to revisit with Back/Forward.
- Keep menus, drawers, popovers, tooltips, and unsent form drafts local. Sidebar pin/collapse preferences remain in local storage. Never put credentials, tokens, private identifiers, or sensitive form values in a URL.
- TanStack Router scroll restoration is enabled. Add page-specific search schemas with the real page that owns those controls; placeholder routes with no filters must not invent query parameters.

## Responsive layout and usability

Every React page, screen, dialog, and major interaction must be designed and reviewed at narrow, medium, and wide viewport sizes. Desktop styling is not the only target. Flutter remains the visual and behavior reference; responsive changes should preserve the same content, actions, permissions, and workflow while adapting their layout to the available space.

Use the shared mobile-first cutovers at 480px, 700px, 1100px, and 1440px. These create five review ranges, but do not require every page or component to change at each boundary. Add a layout change only when the content no longer fits or can be made substantially easier to use. A route may keep a Flutter-specific/content-driven threshold such as 760px or 980px when source review shows it is needed; record the reason and test around it instead of adding unexplained one-off breakpoints.

### Authenticated shell behavior

- Below 1100px, keep a 64px app bar with the menu control, Bomach mark, and permitted notifications. At 1100px and above, remove the separate app bar and place the permission-gated notification bell beside the brand and collapse action at the top of the persistent sidebar; its panel opens beside the sidebar. Let each route begin with the shared page heading for route context and title.
- Below 1100px, use an overlay navigation drawer. Opening it moves focus into the drawer and locks page scrolling; Escape and the backdrop close it, and focus returns to the menu button. Keep the drawer within the viewport at 320px.
- At 1100px and above, use a persistent 300px expanded sidebar or 72px collapsed rail. Save collapse, open-group, and pin preferences locally. Keep controls accessible while collapsed and preserve text labels through accessible names/tooltips.
- When the desktop rail is collapsed, pointer hover expands it in the page layout and the main content shifts with it. Pointer leave starts the width transition back to the rail immediately; do not use an overlay or a delayed close. If keyboard focus is inside the temporary expanded sidebar, keep it open until focus leaves. Provide an explicit action to keep the sidebar expanded. Respect reduced-motion preferences.
- Organize navigation under Workspace and People. Workspace begins with the primary Overview link, then the collapsible My Work and Company groups; People contains HR/Admin. My Work has the foldable subgroups My tasks & goals, Time & leave, and My account. Company has Organization, Governance & oversight, Workflow & communication, and Planning & resources. HR/Admin has People & access, HR operations, Performance & reporting, and Recognition & employee relations. Attendance and My Leaves belong to My Work; Roles & Permissions belongs to HR/Admin while the employee's own Role stays in My Work. Loans stays in HR/Admin because it includes approval and repayment work. Separate top-level sections with consistent spacing and a restrained divider. Style both group and subgroup rows as accessible disclosure controls; indent each level under a subtle neutral guide with matching horizontal branches, and use a slim primary accent to identify the active destination. Navigation-only labels may disambiguate repeated names such as My profile and Company profile without changing route titles. Keep route paths and permission guards stable when sidebar ownership changes.
- Save both group and subgroup open/collapsed state with the existing local sidebar preferences. When a route is selected through navigation, search, or a pinned shortcut, expand its parent group and subgroup so the active link is visible in its context. Permission filtering applies before subgroup rendering; do not show empty categories.
- Keep page search as an input in the sidebar. Typing opens a bounded suggestions list; Up/Down changes the active suggestion, Enter navigates, Escape closes suggestions, and Ctrl/Cmd+K focuses the input. Search returns only destinations visible to the current user and displays both the navigation group and subgroup context when a subgroup exists.
- Show only the destination or subgroup name in sidebar tooltips, using the shared Bomach tooltip rather than the browser's native `title` popup. Do not repeat the parent navigation group in a subgroup tooltip. Keep group and subgroup context in search results, where it helps distinguish matching destinations. Position route tooltips beside the collapsed rail and above expanded links. Show sidebar tooltips after 1 second of pointer hover, immediately on keyboard focus, and never on touch hover.
- Show pin controls progressively: on pointer devices, reveal the icon when the row is hovered or keyboard-focused; on touch devices, expose pin/unpin through a row actions menu. Once pinned, keep its pin marker visible in both the pinned shortcut and original route row, including the collapsed rail. Present pinned shortcuts in a restrained bordered surface above the navigation groups while each destination remains in its original group. Save pin and collapse preferences locally.
- Center shared dialogs in the viewport on tablet and desktop. On phone-sized screens, use the agreed full-screen dialog treatment so forms and actions remain usable.
- Keep one account/profile control at the bottom of navigation. It opens a compact profile dialog with identity, verification and employment status, readable access-role chips, a full-profile link, and sign-out. The full Profile page owns the grouped personal, contact, employment, account, and two-factor information. Keep Profile read-only; never display compensation, bank, pension, or benefits fields. Two-factor enable/disable uses a focused password-confirmation dialog, and success appears only after the server confirms the change. Change password enters the existing forgot/reset flow with the signed-in email prefilled. Place full-profile and destructive sign-out actions at opposite ends of the wider-screen dialog footer; stack both actions on phones. Confirm sign-out and state clearly that it closes the current device session. Do not add a global footer to page content; sticky actions belong to individual workflows.
- Place the notification bell in the mobile/tablet header or desktop sidebar only when the session can list notifications. Show unread count only when the backend returns it and the session has `notifications.view`; load the feed on demand, support read/unread filters, mark-read and mark-all-read according to permissions, and show a panel-level retry state on failure. Follow notification destinations only when they resolve to a same-origin, registered, permitted React route.
- Use one icon library and a consistent stroke style for shell navigation and actions. Collapse controls need clear open/close names and tooltips.
- Review shell cutovers at 480, 700, 1100, and 1440px, in addition to the representative 375, 600, 900, 1280, and 1600px widths.

### Per-screen responsive requirements

- Review each screen at **375, 600, 900, 1280, and 1600 CSS pixels**. Also check 320px and browser zoom/reflow where useful, plus a width immediately around any breakpoint that changes that screen's layout.
- Prevent accidental page-wide horizontal scrolling, clipped controls, overlapping content, and unreachable actions. A dense table may scroll within its own labeled region or use a reviewed compact presentation, but do not silently remove important fields or actions.
- Keep the information hierarchy and reading order clear. Let titles, breadcrumbs, toolbars, and action groups wrap or stack deliberately instead of shrinking text or controls until they collide.
- On compact layouts, preserve access to primary navigation and key actions. If the Flutter layout cannot fit the browser viewport, record the adaptation (such as a navigation drawer) and preserve the same destinations and permission behavior.
- Make forms comfortable to complete at every width: use a clear narrow-screen field order, keep labels/help/errors attached to their fields, allow validation messages to expand the layout, and keep submit/cancel actions visible and operable.
- Keep dialogs and menus inside the viewport. Allow long content to scroll without hiding the title, close action, or important footer actions; ensure focus moves into an overlay and returns to its trigger when it closes.
- Dialogs focus their heading by default; a workflow may focus a field with `initialFocusRef`. Disable backdrop dismissal when closing could discard a draft. Full-screen mobile dialogs account for device safe areas. Short detail and confirmation dialogs may use the shared content-sized mode on desktop while remaining full-screen on narrow screens.
- Preserve status visibility and interaction during resizing. Loading, empty, error, success, pending, and permission states must not overlap, truncate, or become color-only cues at narrow widths.
- At wide desktop sizes, use available space without stretching text and forms into hard-to-scan lines. Choose content constraints per screen based on the Flutter reference and the actual data layout.
- Check pointer, touch, keyboard, and browser zoom behavior where the control is used. Responsive layout must not remove keyboard focus indicators or break assistive-technology labels and announcements.

### Shared date and time controls

- Use the controlled shared `DatePickerField` for a branded calendar while keeping values as ISO `YYYY-MM-DD`. `FormControl` owns the label, required indicator, description, and inline error; the date picker exposes those relationships on its trigger.
- Show the calendar in a portal anchored to the field and clamped within the viewport at all widths. On narrow screens, constrain the popover to the available viewport width and height and allow its calendar content to scroll internally; do not turn it into a modal form. Selecting a day applies it immediately. Provide month/year selection, previous/next month, optional Today/Clear actions, min/max bounds, full accessible day names, selected/today semantics, arrow/Home/End/PageUp/PageDown keyboard navigation, Escape close, outside-click dismissal, and focus return to the trigger.
- Use the controlled shared `TimePickerField` for standalone times across the app. It presents the app-styled hour, minute, and AM/PM selectors, displays the user's localized time, and commits the existing 24-hour `HH:mm` value; do not use native `input[type="time"]` controls. Keep duration arithmetic and time-range rules in feature code. For a range, associate one cross-field error with the group and both selectors rather than attributing it to only Start or End.
- For report content that is naturally a list of separate entries, use numbered multiline rows with an **Add** action and a remove action when more than one row exists. Keep the row array inside TanStack Form and serialize to the existing API representation at the feature boundary. Bound the number of rows, give each row an accessible label, and keep optional lists empty until the user adds an item.

Capture the normal screen plus the important responsive interaction states for the route review. Record any layout adaptation from Flutter, why it is needed, and whether it changes visible behavior. Ask the user before a responsive adaptation changes workflow behavior or removes information.

## Accessibility

- Use semantic form labels and connect descriptions and errors with the control.
- Provide visible keyboard focus and keyboard operation for dialogs, menus, selects, and buttons.
- Announce asynchronous errors and success through appropriate alert or status semantics.
- Keep live announcement regions limited to the message; do not put action buttons inside the live region.
- Static alerts stay out of the live announcement stream. Page-level state text is announced when inserted; the route or form owns first-invalid-field focus.
- Do not communicate state by color alone.
- Restore focus when a dialog closes and move focus into a dialog when it opens.

### Workspace switcher and handoff

- Keep the workspace menu anchored to its trigger, clamped within the viewport, and consistent across Bomach OS, Services, and Marketing. The menu heading is “Switch workspace”; identify the current app in the selected row.
- Open the menu from the trigger’s measured position. When navigating, use a small randomized origin within that same trigger so the handoff grows from the actual control the user activated.
- Show both source and destination apps during the handoff. The source recedes as the destination arrives; after navigation, reveal the loaded destination behind the transition card.
- Carry only the source app, destination app, animation origin, and start time in a one-use session-storage marker. Do not put workspace transitions in the URL or persistent storage.
- The transition has a 560ms departure and a 760ms arrival. Respect reduced-motion preferences by skipping both the delay and arrival animation.
- The switcher has no server-owned data: it does not issue API calls, poll, revalidate queries, or invalidate cache entries. The transition marker is temporary UI state and is removed when consumed or rejected.
