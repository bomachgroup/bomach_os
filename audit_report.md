# Role Detail Tabs Audit Report

> Generated: 2026-07-24 | Branch: test

## Summary

| Total Tabs | Active (Completed) | Commented Out (Coming Soon) |
|------------|-------------------|----------------------------|
| 20 | 13 | 7 |

## Active Tabs (Completed)

### Core & Structure
| Tab | Widget | Status | Notes |
|-----|--------|--------|-------|
| Overview | OverviewTab | Completed | Full implementation |
| Authority Limits | AuthorityLimitsTab | Completed | Full implementation |
| Org Chart | _OrgChartWrapper + OrgChartTab | Completed | Uses SizedBox(height: 600) for layout fix |
| Career Path | CareerPathTab | Completed | Uses Get.isRegistered guard pattern |

### Performance & Goals
| Tab | Widget | Status | Notes |
|-----|--------|--------|-------|
| KPIs | KpiTab | Completed | Uses Get.isRegistered guard pattern |
| Targets | TargetsTab | Completed | Full implementation |
| Performance Analytics | PerformanceAnalyticsTab | Completed | Full implementation |

### Workflows & Tasks
| Tab | Widget | Status | Notes |
|-----|--------|--------|-------|
| Task Templates | TaskTemplateTab | Completed | Full implementation |
| SOPs | SopTab | Completed | Full implementation |
| Daily Work Routine | DailyRoutineTab | Completed | Full implementation |

### Learning & Resources
| Tab | Widget | Status | Notes |
|-----|--------|--------|-------|
| Training | TrainingTab | Completed | Full implementation |
| Success Playbook | SuccessPlaybookTab | Completed | Full implementation |
| Resources | ResourcesTab | Completed | Full implementation |

## Commented Out Tabs (Coming Soon)

These tabs are commented out in `role_detail.dart` to preserve placement tracking for future backend endpoints. Their widget files remain in `role_detail_tabs/` but the tab entries are commented out in the category configuration.

### Core & Structure
| Tab | Widget | Status | Reason |
|-----|--------|--------|--------|
| Succession Plan | SuccessionPlanTab | Commented Out | Backend endpoint not yet available |

### Performance & Goals
| Tab | Widget | Status | Reason |
|-----|--------|--------|--------|
| OKRs | OkrTab | Commented Out | Backend endpoint not yet available |
| Reports | ReportsTab | Commented Out | Backend endpoint not yet available |

### Workflows & Tasks
| Tab | Widget | Status | Reason |
|-----|--------|--------|--------|
| Decision Matrix | DecisionMatrixTab | Commented Out | Backend endpoint not yet available |

### Learning & Resources
| Tab | Widget | Status | Reason |
|-----|--------|--------|--------|
| Knowledge Base | KnowledgeBaseTab | Commented Out | Backend endpoint not yet available |

### Governance & People (entire category)
| Tab | Widget | Status | Reason |
|-----|--------|--------|--------|
| Risk Profile | RiskProfileTab | Commented Out | Backend endpoint / category not yet available |
| Stakeholders | StakeholderTab | Commented Out | Backend endpoint / category not yet available |

## Implementation Notes

### Patterns Applied
1. **Get.isRegistered guard pattern** — All active tabs use `Get.isRegistered<T>(tag: tag)` before `Get.put<T>(...)` to prevent duplicate controller registration on hot reload.
2. **Commented out preservation** — Tabs with missing backend endpoints are commented out rather than deleted to preserve their placement for future implementation.
3. **Layout fix** — `activeSubTab.builder(role, role.id)` is wrapped in `Expanded` to prevent unbounded height errors in scrollable tab content.

### Bug Fixes
- **GlobalKey conflict** — Separated `_menuKeys` (for widget keys) and `_headerKeys` (for `_ExpandableMenuRow.headerKey`) in `side_menu.dart` to prevent duplicate GlobalKey errors.
- **Unbounded height** — Wrapped tab content with `Expanded` in `role_detail.dart` to constrain ListView height within Column layout.
- **422 Unprocessable Content** — Fixed field name mismatches across multiple API calls (to_role_id, sequence, title, estimated_minutes, default_priority, kind, etc.).

### Files Modified
- `lib/components/nav/side_menu.dart` — GlobalKey conflict fix
- `lib/pages/company/role_detail.dart` — Layout fix (Expanded wrapper)
- `lib/pages/company/widget/role_detail_tabs/decision_matrix_tab.dart` — init: pattern fix
- `lib/pages/company/widget/role_detail_tabs/risk_profile_tab.dart` — init: pattern fix
- `lib/pages/company/widget/role_detail_tabs/stakeholder_tab.dart` — init: pattern fix
- `lib/pages/company/widget/role_detail_tabs/succession_plan_tab.dart` — init: pattern fix

## Backend API Endpoints Status

| Endpoint | Status |
|----------|--------|
| /api/v1/roles/ | Active |
| /api/v1/role-kpis/ | Active |
| /api/v1/role-targets/ | Active |
| /api/v1/role-career-paths/ | Active |
| /api/v1/role-task-templates/ | Active |
| /api/v1/role-sops/ | Active |
| /api/v1/role-daily-routines/ | Active |
| /api/v1/role-training/ | Active |
| /api/v1/role-success-playbook/ | Active |
| /api/v1/role-resources/ | Active |
| /api/v1/role-authority-limits/ | Active |
| /api/v1/role-org-chart/ | Active |
| /api/v1/role-performance-analytics/ | Active |
| /api/v1/role-okrs/ | Pending |
| /api/v1/role-reports/ | Pending |
| /api/v1/roles/{id}/succession-plans | Pending |
| /api/v1/roles/{id}/decision-matrix | Pending |
| /api/v1/roles/{id}/knowledge-base | Pending |
| /api/v1/roles/{id}/risk-profiles | Pending |
| /api/v1/roles/{id}/stakeholders | Pending |