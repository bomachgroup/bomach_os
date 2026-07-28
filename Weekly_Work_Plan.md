# Weekly Work Plan

**Name:** Somtochukwu Ukaegbe
**Project:** Bomach OS
**Week of:** July 27 – 31, 2026

---

## Phase 1: Success Playbook Schema Fix

- Update the Success Playbook model, service, controller, and dialog to align with `RoleSuccessPlaybookItemCreateSchema`
- Fields to reconcile: `title`, `kind`, `description`, `sequence`, `is_active`

## Phase 2: OKR Endpoint Activation

- Confirm with backend team whether `/api/v1/role-okrs/` has been deployed
- If deployed: remove the `ComingSoonTab` placeholder in `okr_tab.dart` and activate the pre-built `RoleOkrController` and `RoleOkrService`
- If not yet deployed: flag status to backend team and hold this item

## Phase 3: Marketing OS Sub-Module Deepening (Completed)

- Implement role-based persona view filters in the Marketing UI (`Full Command Centre`, `Telemarketer Queue`, `Branch Manager View`, `CMO Dashboard`)
- Wire up automated lead distribution rules based on branch/department parameters (`Auto-Distribute Leads`)

## Phase 4: Final Acceptance & End-to-End Testing

- Perform end-to-end testing across all 24 Role Framework tabs
- Perform end-to-end testing across the Marketing Module
- Test environment: bomachauthtest.bgbot.app
