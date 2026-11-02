# Notifications implementation

## Scope

The React port now provides signed-in, in-app notifications through the shell bell, a full inbox at `/notifications`, and detail pages at `/notifications/$notificationId`. This work does not request browser notification permission and does not implement Web Push, a service worker, browser push subscriptions, or backend push delivery.

The mobile React Native app remains the reference for the notification journey: users can review all or unread updates, open a notification for its full message and structured context, mark it read, and continue to an authorized related item when the backend supplied a safe destination.

## Backend contract and permissions

The API is owned by the existing System Notifications backend. No backend schema or endpoint changes are required.

## React Native reference and port decisions

The staff mobile implementation was reviewed in `../bomach_staff_mobile/src/features/notifications/` (`api.ts`, `NotificationsScreen.tsx`, `NotificationDetailScreen.tsx`, `presentation.ts`, and `routes.ts`). Its API layer maps the backend's snake-case notification DTO into a typed item, requests up to 50 items with an optional read filter, fetches a notification by ID, reads unread statistics, and exposes mark-one/read-all mutations. The mobile API also declares device-token register/delete mutations; those are mobile delivery integrations and are not used by this web port. The API module declares cache tags, not a periodic polling interval.

The mobile list treats the notification card as the open action. Each card shows its category and type icon, unread state, message, optional amount/context, relative time, and a forward affordance. The detail page marks unread items read on open, then presents the full message and typed sections from `metadata.details`, with separate actions for relevant destinations. The React port follows that interaction: the whole notification content opens the detail view (or an independently permission-checked related destination when detail permission is absent), while the mark-read button remains a separate target.

Mobile destinations are not copied literally because `/home`, `/reports`, `/tasks`, and `/leave` are not all registered in this web application. React maps only destinations that exist here and checks their route permissions before rendering them:

| Notification data                                              | React destination                                                   |
| -------------------------------------------------------------- | ------------------------------------------------------------------- |
| `leave_request` with an authorized request ID                  | `/hr/leaves/{id}`                                                   |
| `work_report` with an authorized report ID                     | `/dashboard/my-reports/{id}`                                        |
| Work-report reminder with an existing report ID                | `/dashboard/my-reports/{id}`                                        |
| Work-report reminder without a report ID and create permission | `/dashboard/my-reports/create`                                      |
| Attendance reminder or attendance entity                       | `/hr/attendance`                                                    |
| Task or project-task entity                                    | `/dashboard/my-tasks` (the React port has no task detail route yet) |
| Unknown, external, unregistered, or unauthorized destination   | No related action is shown                                          |

The full detail page uses a presentation mapper keyed by the versioned backend `metadata.details.kind`, with typed sections for supported notification kinds and a bounded, sanitized fallback for unknown kinds. Amounts, status, date, context, category, and icon share the same mapper between the bell preview, inbox, and detail page so summaries remain consistent. Related-action buttons are generated from permission-checked route mappings; a backend `link` is never trusted as a raw browser destination.

| Endpoint                                | Permission                    | React behavior                                                                         |
| --------------------------------------- | ----------------------------- | -------------------------------------------------------------------------------------- |
| `GET /api/v1/notifications/`            | `notifications:list`          | Bell preview, inbox pages, and active-tab arrival checks. The endpoint is user-scoped. |
| `GET /api/v1/notifications/stats`       | `notifications:view`          | Unread badge and optional inbox unread count.                                          |
| `GET /api/v1/notifications/{id}`        | `notifications:view`          | User-scoped notification detail page.                                                  |
| `PATCH /api/v1/notifications/{id}/read` | `notifications:mark_read`     | Mark one notification read; opening detail also attempts this update.                  |
| `POST /api/v1/notifications/read-all`   | `notifications:mark_all_read` | Mark all notifications read from the inbox or bell panel.                              |

The route guard and the UI use the same permission distinctions. The backend remains authoritative and detail lookup cannot return another user's notification. The frontend only follows same-origin links that resolve to a registered React destination and pass that destination's permission check. Unknown, external, and unauthorized links are not rendered as actions.

## User experience

- The bell remains in the existing permission-gated shell location. Its panel is a short preview with All/Unread filtering, full-card notification opening, separate read actions, load-older support, and a prominent View all route to the full inbox.
- The inbox has URL-backed `filter=all|unread` state, paginated results, optional unread count, mark-one and mark-all actions, and distinct loading, empty, partial-refresh-error, and first-load-error states. It has no generic header Refresh action; failures keep a local retry.
- Opening a notification with `notifications:view` goes to its durable detail URL. The detail page shows a type-specific icon and presentation, read state, importance, the complete message, received time, and structured fields from versioned `metadata.details`; it does not dump arbitrary backend metadata. Relevant actions appear as distinct, permission-checked buttons.
- A detail page attempts to mark an unread item read when opened, if `notifications:mark_read` is granted. A failed read update does not block review or a permitted related-item action; the page gives a local retry.
- If a user can list but cannot view detail, the inbox can still display the authorized list result. A row can open only an independently authorized related destination, or remains informational. Mark-read controls remain permission-gated.
- New notifications observed while the app is open produce one in-app toast with a permission-checked action. The first successful list response after entering the authenticated shell is a baseline, so old items are not announced on login or reload.

## Data lifecycle

- All query keys include the signed-in user ID. List variants also include filter and page size; detail includes notification ID. This prevents user-specific cache data from crossing account boundaries.
- Inbox list and detail are `standard` freshness (60 seconds), revalidated on stale route entry, focus, and reconnect. They do not poll while a user is reading the page.
- The shell unread count uses the existing short live cadence (30 seconds while the bell is open, 60 seconds while closed) and pauses while the document is hidden. Focus and reconnect trigger refresh.
- One shell arrival check requests the newest 20 items every 60 seconds only while the authenticated app is visible. It also rechecks when the page becomes visible, on focus, and after reconnect. This is best-effort in-app polling, not instant delivery.
- The first successful arrival response establishes a baseline. Subsequent IDs are compared during the session. `BroadcastChannel` and a user-scoped local-storage set containing only notification IDs prevent duplicate alerts across tabs where browser storage is available. No notification body or metadata is persisted in browser storage.
- Read mutations invalidate only the current user's notification query family, including bell/inbox list variants, Workspace Overview updates, detail, arrival window, and unread count. Cached content stays visible during revalidation; errors are presented at the affected list, detail, or action.

## Error and access states

- Inbox first-load transport/server/permission errors use the shared error mapper and a page retry. Errors during a cached refresh remain local while cached rows stay visible.
- Unread-count failure does not block the inbox and is not reported as a page error; the count is omitted or marked unavailable in the bell.
- Detail 404/missing records use the shared page error presentation. A detail permission rejection is blocked by the route guard; a late backend 403 remains a safe local error.
- Read/read-all failures stay near the action and can be retried. They do not prevent viewing notification content or an authorized related item.
- Active-tab arrival polling is silent on failure. It keeps the shell usable and tries again on the next scheduled check, focus, visibility, or reconnect event.
- Session expiration continues through the shared API/session handling and clears protected query data.

## Deferred work

Web Push remains a separate future project. It will need a user-initiated browser permission flow, a service worker, browser `PushSubscription` registration and removal, backend storage/validation, sender credentials, and explicit logout/shared-device behavior. Expo push tokens and mobile delivery are not reused. Until that project is approved and implemented, notifications are delivered only while a Bomach tab is open and checking.
