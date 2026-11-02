# Company Profile Implementation

**Route:** `/company`  
**Status:** Implemented  
**Reference:** Flutter `CompanyProfilePage`; React page is a focused settings surface rather than the original five-tab company hub.

## Scope and page structure

Company Profile contains three independent sections:

1. **Company details** — company name, email, phone, registered address, registration number, and optional industry.
2. **Brand identity** — logo, slogan, primary color, and secondary color.
3. **Operating defaults** — default currency, language, IANA time zone, punctuality cutoff, and business rules.

The page has an identity header, responsive detail cards, and compact section-specific dialogs built with the shared `Card`, `Dialog`, `DropdownSelect`, `FormControl`, and error-state components. The profile page does not show dashboard metrics. Company Overview, Board, Compliance, Approval Workflows, and Approval Requests retain their own destinations. Shareholder/equity management is deferred to a separate implementation.

## Authorization

- The `/company` route requires `company_settings:view`. Update permission by itself does not grant entry.
- The backend GET endpoints and choices endpoint require `company_settings:view`.
- The matching section edit controls and backend PUT endpoints require `company_settings:update`.
- A view-only user can read persisted values but cannot see edit/setup actions.

## Backend contract

The current shared API client addresses these paths under `/api/v1`:

| Section            | Read                               | Update                             | Persisted fields used                                                                                           |
| ------------------ | ---------------------------------- | ---------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| Company details    | `GET /company/company/profile`     | `PUT /company/company/profile`     | `company_name`, `company_email`, `company_phone`, `company_addresses`, `rc_number`, `industry`, `is_configured` |
| Brand identity     | `GET /company/company/branding`    | `PUT /company/company/branding`    | `company_logo`, `company_slogan`, `primary_color_code`, `secondary_color_code`                                  |
| Operating defaults | `GET /company/company/preferences` | `PUT /company/company/preferences` | `default_currency`, `language_preference`, `time_zone`, `punctuality_cutoff_time`, `business_rules`             |
| Editor choices     | `GET /company/company/choices`     | —                                  | currency, language, and IANA time-zone choices                                                                  |
| Logo upload        | `POST /others/upload-file`         | —                                  | returns a URL that is saved through the branding endpoint                                                       |

Industry is optional. `time_zone` is a first-class IANA identifier, defaults to `Africa/Lagos`, and is validated by the backend using Python `zoneinfo`. The established API field `punctuality_cutoff_time` is used. There is no added scalar for approval mode, and this page does not persist notification channels or GDPR/CCPA controls.

Company phone, address, and registration number accept empty strings so first-time setup can save only data the company has. Company name and email remain required. A successful profile save configures the profile only when the values are not the known generic name/email placeholders.

## Profile setup migration

`CompanyProfile.is_configured` distinguishes real identity from model defaults. Migration `user.0129_company_profile_setup_and_timezone` marks existing profile rows configured only when both name and email are present and do not match the seeded placeholders. Newly materialized/default profiles remain unconfigured. The page hides all placeholder identity values and presents a setup prompt. After a valid save, the backend returns `is_configured: true` and the page displays the saved identity.

## Query lifecycle and failure behavior

- Profile, branding, preferences, and choices use the 300-second `reference` freshness window. They revalidate when stale on route entry, focus, and reconnect. There is no polling.
- Choices load when the operating-default editor opens; the shared searchable dropdown supports the full runtime IANA time-zone list.
- Profile, branding, and preferences are separate queries. A failed section displays a local retry state while other sections remain visible. If cached values exist, they stay visible with a concise stale-data note during failed refresh.
- Saved sections revalidate when stale on route entry, focus, and reconnect without a page-header Refresh action. Keep a local retry beside a failed section; choices retain their editor-local retry.
- Each editor owns an unsent local draft. Validation/API errors stay in the active form; cancel/reopen initializes a fresh draft from the saved query data.
- A successful save writes the canonical response to the affected query cache. Profile and branding use the same identity keys as Company Overview, so the overview header updates immediately. Preferences do not invalidate overview metrics.
- Logo replacement uploads the selected file before saving its returned URL via branding. Removing a logo sends `company_logo: null`. If upload or update fails, the dialog and its draft stay open; the previously saved logo remains the displayed server value.

The company-wide timezone value is shown and saved here only. Other screens retain their existing timezone behavior until their contracts and consumers are reviewed separately.

## Verification coverage

Frontend component coverage is in `src/modules/company/routes/company-profile-page.test.tsx`; route/permission registration is covered by `src/app/router/router.test.ts` and navigation tests. Backend API coverage is in `domains/organization/tests/test_company_settings_api.py`. The migration graph is checked with Django's `makemigrations --check --dry-run`.
