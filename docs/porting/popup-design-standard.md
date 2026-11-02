# Popup and Dialog Design Standard

## Purpose

Keep modal dialogs consistent across the React port while letting each feature retain its own fields, validation, draft behavior, and save flow. The Branch setup dialog is the reference for structured create and edit forms: one shared dialog frame, clearly named form sections, responsive field groups, and a persistent action footer.

## 1. Use the shared dialog frame

- Use `Dialog` for modal product workflows. Do not build a second native `<dialog>` shell for a feature.
- Keep the title short and specific. Include the record name only when it helps distinguish the task, such as **Update geofence · Abuja**.
- Use an optional one-sentence description to explain the outcome or the requested action. Do not repeat the title or put long instructions in the header.
- Keep the close control in the shared header. Give it a specific `closeLabel` when the dialog’s task is not obvious.
- Put longer content in the scrollable dialog body. Keep the title and footer reachable while that body scrolls.

`Dialog` provides focus entry and restoration, Escape handling, an accessible title and description, safe-area spacing, and the standard branded header and footer. Keep those behaviors unless a workflow has a clear reason to change them.

## 2. Size dialogs for the workflow

- At widths below the shared 700px tablet breakpoint, create and edit forms use the full-screen dialog layout. This gives fields and controls room and preserves a clear header/body/footer structure.
- On larger screens, choose `sm`, `md`, `lg`, or `xl` according to the form’s actual content. Use `fitContent` for short or medium content whose footer should sit directly after the form; let long forms use the available height and internal scrolling.
- `compactOnMobile` is an explicit exception for short confirmations and brief account checks. Do not use it for multi-field create/edit forms, long editors, schedules, or step flows.
- Short confirmations should combine `fitContent` and `compactOnMobile`: the body should not stretch to the dialog's height on desktop, and the dialog should not occupy the full mobile viewport when its content is brief.
- Keep purpose-built camera, GPS, schedule, navigation, notification, and date-picker overlays on their specialized layouts. Do not force these into a generic form-card composition.

## 3. Structure form content

- Group create/edit fields in the shared `FormSection` surface: muted background, subtle border, shared surface radius, and responsive padding.
- Give each substantial section a concise heading and, when useful, one short helper sentence. The field labels remain the source of truth for what each control means.
- Keep form-wide errors and data-loading/retry states above the section they affect. Keep field errors beside their controls.
- Use responsive grids for related fields: one column on phones, then two columns only where labels and control widths remain comfortable. Let long text areas and explanatory controls span the row.
- A specialized control such as live GPS capture may have its own panel inside a `FormSection`. Avoid repeating the same panel background on every individual control or stacking decorative cards without a clear information hierarchy.
- For read-only detail dialogs, group information by topic and use the relevant detail cards or definition lists. Do not style read-only content as an editable form.

## 4. Footer actions

- Place the secondary action before the primary action. Use **Cancel** for an unsaved form and a specific keep/close label when it better explains the decision.
- Use the shared outline treatment for a neutral secondary action and one primary action for the successful outcome. Use the danger treatment for destructive confirmation.
- Keep the primary action last in DOM and visual order. At narrow widths allow actions to wrap without clipping or covering the body; long dialogs retain the footer while their content scrolls.
- Disable or show pending state on actions during a mutation. Do not let Escape, backdrop clicks, or the close button discard a protected draft while a save is in flight.

## 5. Feedback and dismissal

- Follow [Forms, Loading, Error, and Success Standards](./interaction-standards.md#placement-rules) for validation, alerts, pending states, and success feedback.
- Preserve entered values after validation or server failure. Keep form-wide errors inside the body and close only after confirmed success or an explicit safe cancel.
- Set `closeOnBackdrop={false}` when the workflow must not be accidentally discarded, especially during submission. Disable or guard all dismissal paths while a mutation is pending.
- Use one feedback channel for a failure. Do not repeat the same error in a field, form alert, toast, and title.

## 6. Overlay exceptions

These surfaces share Bomach colors, typography, focus treatment, and responsive care, but have a distinct interaction model:

| Surface                                                | Keep its specialized structure                                                      |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------- |
| Attendance face check                                  | Camera preview, guided steps, and capture controls                                  |
| Branch geofence                                        | Live GPS scan, accuracy readings, manual coordinates, and radius                    |
| Branch business hours                                  | Copy-schedule controls and seven responsive day editors                             |
| Branch creation/review                                 | Multi-step flow with its own stepper and previous/next/save actions                 |
| Read-only details                                      | Topic-specific summaries, facts, and decision history                               |
| Confirmations                                          | Short consequence text and one clear confirm/cancel pair; compact sizing is allowed |
| Date picker, notification panel, and navigation drawer | Anchored popover or navigation interaction; do not treat as a modal form            |

## 7. React popup inventory reviewed

The product dialog inventory was checked against this standard. These workflows intentionally differ in content and behavior while sharing the common dialog frame where applicable:

| Area                   | Dialogs and expected treatment                                                                                                                                                                                                                                 |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Account and shell      | Profile summary and sign-out confirmation are brief account dialogs; password reset is a staged form; two-factor changes are a short password-confirmation dialog.                                                                                             |
| Attendance             | Location-extension request uses a form section; clock-in/out and face verification retain their guided device workflow; removing a pending location uses a short confirmation.                                                                                 |
| Company organization   | Branch create/edit retains its five-step setup and review flow; geofence and business-hours editors retain their specialized controls inside the shared form surface; company profile, branding, operating defaults, departments, and units use form sections. |
| Governance             | Board record editors use a form section; board actions and compliance deletion are short confirmations; compliance create/edit uses grouped form sections; approval details remain read-only and rejection uses a reason section.                              |
| Leave                  | Leave request create/edit uses grouped form sections; request cancellation is a short confirmation.                                                                                                                                                            |
| Targets                | Progress submission uses a form section; target and report details remain read-only summaries.                                                                                                                                                                 |
| Tasks and work reports | Task details remains a detail surface; completion, report withdrawal, and report deletion are short confirmations.                                                                                                                                             |

The foundation preview is a component demonstration, not a product popup. The notification panel, navigation drawer, and date picker use their own anchored or navigation layouts rather than the `Dialog` component.

## 8. Review checklist for new or changed dialogs

Before merging a dialog change, confirm:

1. It uses the shared `Dialog` unless it is an anchored or purpose-built overlay.
2. The title and description are concise, and the close control has a useful accessible name.
3. A create/edit form uses `FormSection` for its field group and shared controls for its fields.
4. `compactOnMobile` is limited to a short confirmation or account check.
5. Header and footer remain available while long content scrolls at phone and desktop sizes.
6. Actions wrap cleanly, the primary action comes last, and pending state blocks duplicate submissions and unsafe dismissal.
7. Validation, loading, retry, failure, and success states match the existing interaction standards.
8. Keyboard focus enters and returns correctly; Escape and backdrop behavior match the draft’s safety.
9. The dialog is checked at 375px, 600px, 900px, and 1280px, plus a narrow 320px viewport when wrapping or scrolling could be affected.
