# Error handling and user feedback

This document defines how the React port classifies backend and network failures. It follows the shared feedback approach used in the Services frontend and keeps the error close to the section or action that failed.

## Classify the failure before choosing the message

| Failure                                                             | User-facing treatment                                                                                                                                                                                                                     |
| ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Browser reports offline (`status: 0`, `navigator.onLine === false`) | “You are offline.” Ask the user to reconnect and retry.                                                                                                                                                                                   |
| Request has no response while the browser is online (`status: 0`)   | “Connection problem.” Say BOMACH OS could not reach the server; do not claim the backend is down or the user is offline with certainty.                                                                                                   |
| Server error (`500–599`)                                            | Say the service is temporarily unavailable. Do not display raw server or stack details.                                                                                                                                                   |
| `401`                                                               | Refresh once when possible. If the refresh token is rejected, clear the session and redirect to sign-in with a return path. If refresh fails because of a network or server error, preserve the session and show that availability error. |
| `403`                                                               | Keep the authenticated user signed in. Show that they lack access to the page, section, or action.                                                                                                                                        |
| `400` / `422`                                                       | Show safe field-level validation where available; otherwise keep one form-level message.                                                                                                                                                  |
| `404`                                                               | Explain that the requested record may have been removed or is no longer accessible.                                                                                                                                                       |
| `409`                                                               | Explain that data changed and ask the user to refresh before retrying.                                                                                                                                                                    |
| `429`                                                               | Ask the user to wait before retrying.                                                                                                                                                                                                     |

`navigator.onLine` only indicates whether the browser believes it has a network connection. When it is `true`, a `status: 0` request may still mean the backend, proxy, or network path is unreachable.

## Placement and retries

- Use a field message for a correctable field error and a persistent form alert for a submission-level failure.
- Use a section error with a local retry when one part of a page failed.
- Use a page error with retry when the page's primary data cannot load.
- Keep cached data visible during background refresh errors. A non-critical summary may show a quiet unavailable state instead of a blocking alert.
- Use a toast for a brief action failure when the surrounding page remains usable.
- Retry only transient network and server failures. Do not retry authorization, validation, not-found, conflict, or rate-limit errors automatically.
- Never redirect to sign-in solely because a request failed to connect.

## Implementation

Translate errors through `presentError(error, context)` from `src/shared/errors`. Supported contexts are `login`, `two-factor`, `form-submit`, `page-load`, `section-load`, `background-action`, and `destructive-action`.

Pass the original query error to `ErrorState` or `SectionErrorState` when displaying a load failure. Do not replace its classification with generic “could not load roles/profile/data” wording. For background refresh failures, retain the cached result and place a retry beside the affected section.

Do not show raw 5xx response details, tokens, stack traces, or internal identifiers. Do not show success until the server confirms the mutation.
