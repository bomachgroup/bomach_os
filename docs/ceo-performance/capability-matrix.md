# CEO performance and marketing capability matrix

Date reviewed: 2026-09-08

This matrix translates the CEO-supplied Enterprise Performance Engine and
Marketing Revenue OS prototypes into frontend work for the existing BOMACH
OS shell and Marketing frontend. The HTML and ZIP artifacts are design and
workflow references only; their seed records, localStorage repositories,
randomized actuals, and proposed API contracts are not production sources.

## Ownership boundary

| Capability | Product owner | Supported frontend source | Status |
| --- | --- | --- | --- |
| Role descriptions and reporting relationships | HR / Company | Current roles endpoints | Supported |
| Role KPI definitions | HR / Company | Role KPI endpoints | Supported |
| Role target templates | HR / Company | Role target-template endpoints | Supported |
| Daily routines | HR | Role daily-routine endpoint | Supported |
| SOPs and role resources | HR | Role SOP/resource endpoints | Supported |
| Training requirements and programs | HR | Role training and training-program endpoints | Supported |
| Employee targets | HR | Employee target endpoint | Supported |
| Target reports | HR / employee | Target-report endpoints | Supported |
| Marketing activity, campaigns, leads, content, appointments | Marketing | Existing Marketing API integrations | Supported where the endpoint exists |
| Marketing-to-HR performance bridge | Shared view | HR role/KPI/target APIs consumed by Marketing | Supported |
| Company objectives and key results | Company | No published supported endpoint | Unavailable; show an explicit capability state |
| Cross-module actual submission | Shared / source modules | No authoritative published endpoint | Unavailable; do not invent a submission API |
| Full appraisal engine calculations | HR | No complete published contract | Not part of frontend-only delivery |
| Approval/review/reward/penalty lifecycle | HR / Company | Partial review/report endpoints only | Partial; no automatic rewards or penalties |
| Performance `/api/v1/performance/*` contract from the prototypes | Backend proposal | Not part of the published contract | Unavailable |
| Continuity packs, fairness rules, secondary assignments | HR policy concepts | No complete published contract | Reference only |

## Artifact-to-product mapping

### Enterprise Performance Engine

The enterprise artifact contributes the product concepts for HR-owned role
templates, KPI and target definitions, daily routines, SOPs, resources,
employee scorecards, appraisals, performance guidance, and continuity packs.
The current frontend can deliver the supported definition and reporting
surfaces. It must not present the prototype's in-memory appraisal calculations
or seed values as live employee performance.

### Marketing Revenue OS

The Marketing artifact contributes the workflow direction for the Revenue
Command Centre, campaigns, leads, content, customer lifecycle, appointments,
and the HR Performance Bridge. Marketing remains the source of marketing
activity data. It consumes HR role/KPI/target definitions; it does not create a
second role, KPI, target, or OKR database.

## Explicit delivery rules

- Supported API responses may render data, loading, empty, error, or denied
  states according to the response.
- A missing or unsupported endpoint renders an unavailable capability state;
  it must not be converted into an empty successful screen.
- Company OKRs/key results remain unavailable until a backend schema,
  lifecycle endpoints, approval semantics, and published OpenAPI contract
  exist.
- Actuals, rewards, penalties, custody history, device verification, and
  platform verification require their own backend contracts before they are
  represented as authoritative frontend workflows.
