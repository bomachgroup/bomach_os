---
phase: 02-code-review-command
reviewed: 2026-07-31T14:30:00Z
depth: deep
files_reviewed: 13
files_reviewed_list:
  - lib/pages/marketing/marketing.dart
  - lib/pages/marketing/dashboard/marketing_dashboard.dart
  - lib/pages/marketing/calendar/marketing_calendar.dart
  - lib/pages/marketing/pipeline/marketing_pipeline.dart
  - lib/pages/marketing/analytics/marketing_analytics.dart
  - lib/pages/marketing/campaigns/marketing_campaigns.dart
  - lib/pages/marketing/okrs/marketing_okrs.dart
  - lib/pages/marketing/reports/marketing_reports.dart
  - lib/pages/marketing/team/marketing_team_directory.dart
  - lib/pages/marketing/new_lead/new_lead_form.dart
  - lib/pages/marketing/media/marketing_media_library.dart
  - lib/pages/marketing/workdesk/workdesk.dart
  - lib/pages/marketing/controllers/marketing_module_controller.dart
findings:
  critical: 2
  warning: 1
  info: 0
  total: 3
status: issues_found
---

# Phase 2: Code Review Report — Marketing Dashboard Constraint Issues

**Reviewed:** 2026-07-31T14:30:00Z  
**Depth:** deep  
**Files Reviewed:** 13  
**Status:** issues_found  

## Summary

This review traces the root cause of the `BoxConstraints forces an infinite height` crash across the Marketing module. The source of the problem is **one layout pattern** in `marketing.dart` that propagates infinite constraints to **9 child pages**, many of which contain `Expanded` widgets that cannot tolerate it. Additionally, a previously unreported but **equally critical** problem exists in `marketing_module_controller.dart`.

### Constraint chain

```
marketing.dart:88  Expanded (bounded height)
marketing.dart:89  └── SingleChildScrollView (passes INFINITE height to child)
marketing.dart:91      └── AnimatedSwitcher
marketing.dart:97          └── child page (receives INFINITE height)
```

`SingleChildScrollView` gives its child **unconstrained height** because scroll views must let their children be arbitrarily tall. Every page shown inside `AnimatedSwitcher` receives this infinite height constraint. Any page whose root `Column` contains an `Expanded`/`Flexible` child will crash with `BoxConstraints forces an infinite height` when the Flex widget tries to compute a fraction of infinity.

---

## Critical Issues

### CR-01: `SingleChildScrollView` wraps all pages with infinite height

**File:** `lib/pages/marketing/marketing.dart:88-98`  
**Severity:** CRITICAL  

**Issue:** The `Expanded` → `SingleChildScrollView` → `AnimatedSwitcher` layout passes `maxHeight: double.infinity` to every child page. Nine of the ten child pages use `Column + Expanded` at their root, which cannot tolerate infinite height.

**Child pages guaranteed to crash on navigation:**

| # | File | Line | Pattern |
|---|------|------|---------|
| 1 | `calendar/marketing_calendar.dart` | 21 | `Column > Expanded > Row` |
| 2 | `pipeline/marketing_pipeline.dart` | 23 | `Column > Expanded > _buildKanbanBoard` |
| 3 | `analytics/marketing_analytics.dart` | 50 | `Column > Expanded > TabBarView` |
| 4 | `campaigns/marketing_campaigns.dart` | 44 | `Column > Expanded > TabBarView` |
| 5 | `okrs/marketing_okrs.dart` | 25 | `Column > Expanded > SingleChildScrollView` (nested) |
| 6 | `reports/marketing_reports.dart` | 46 | `Column > Expanded > TabBarView` |
| 7 | `team/marketing_team_directory.dart` | 38 | `Column > Expanded > GridView` |
| 8 | `new_lead/new_lead_form.dart` | 49 | `Column > Expanded > SingleChildScrollView` (nested) |
| 9 | `media/marketing_media_library.dart` | 27 | `Column > Expanded > SingleChildScrollView` (nested) |

Rows 5, 8, 9 are **nested scroll views**: an outer `SingleChildScrollView` (infinite height) → inner `Column` → `Expanded` → inner `SingleChildScrollView`. The `Expanded` between two scroll views makes the layout unsolvable — the outer scroll view wants infinite height, but the `Expanded` demands bounded height.

The dashboard (`marketing_dashboard.dart`) avoids the `Column > Expanded` pattern at root level, which may explain why it sometimes doesn't crash. However, it still receives infinite height, and its `_buildKpiCards` Row with all-`Expanded` children (line 148-149) operates in an unbounded cross-axis context, which can trigger the crash depending on the Flutter version's handling of `RenderFlex` when no non-flex children exist to determine the cross-axis extent.

**Fix:** Remove `SingleChildScrollView` from `marketing.dart` so child pages receive bounded height constraints. Replace lines 88-98:

```dart
// BEFORE (marketing.dart:88-98):
Expanded(
  child: SingleChildScrollView(
    padding: EdgeInsets.zero,
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: KeyedSubtree(
        key: ValueKey('${_selectedSection}-$_selectedPage'),
        child: _buildCurrentScreen(),
      ),
    ),
  ),
),

// AFTER:
Expanded(
  child: AnimatedSwitcher(
    duration: const Duration(milliseconds: 200),
    child: KeyedSubtree(
      key: ValueKey('${_selectedSection}-$_selectedPage'),
      child: _buildCurrentScreen(),
    ),
  ),
),
```

This gives each page bounded height. Pages that need scrolling (OKRs, media library, new lead form, campaigns portfolio tab) already contain their own `SingleChildScrollView` and will continue working. Pages without scroll views (dashboard, pipeline, calendar) will get bounded height from `Expanded` and lay out correctly without overflow since their content fits the available space.

---

### CR-02: `currentPeriodData` returns empty map — KPI cards show dash characters

**File:** `lib/pages/marketing/controllers/marketing_module_controller.dart:95-96`  
**Severity:** CRITICAL  

**Issue:** The `currentPeriodData` getter returns `MarketingDemoData.periodData[selectedPeriod.value] ?? {}`. If `selectedPeriod.value` is `'week'` (the default at line 31), the map lookup depends on `periodData` containing a key `'week'`. If that key is missing or returns an empty map, all four KPI cards render `data['leads'] ?? '—'`, `data['conv'] ?? '—'`, etc. — displaying dash (`—`) characters instead of real data.

But the **critical** problem is that this getter is called inside `Obx(() { ... })` in `_buildKpiCards` (dashboard line 137). On first build, the `Obx` subscribes to `MarketingModuleController` reactive state. The controller is lazily registered via `Get.put(MarketingModuleController())` in `marketing.dart:74`.

According to `Get.put` semantics, the controller instance is created during `_MarketingPageState.initState()`. However, `_loadDemoData()` (line 122) runs asynchronously via `onInit` (line 117-119). The reactive `obs` fields are populated after `initState` completes. This means:

1. First frame: `MarketingDashboard` builds → `Obx` subscribes → `currentPeriodData` reads `selectedPeriod.value` ('week') → maps to empty data → KPI cards show `—`
2. Second frame (onInit completes): reactive data populates → UI refreshes → cards show real values

The KPI display flickers from `—` to real values on every initial render. If `periodData` map lacks the 'week' key entirely, the cards **permanently display dashes** as if no data exists, even though demo data loaded successfully.

**Fix (defensive):** Provide a fallback with real initial values rather than silently displaying dashes:

```dart
// BEFORE (line 95-96):
Map<String, String> get currentPeriodData =>
    MarketingDemoData.periodData[selectedPeriod.value] ?? {};

// AFTER:
Map<String, String> get currentPeriodData {
  final data = MarketingDemoData.periodData[selectedPeriod.value];
  if (data != null && data.isNotEmpty) return data;
  // Fallback to computed values from demo data
  return {
    'leads': '${leads.length}',
    'conv': leads.isEmpty ? '0%' : '${(wonLeads * 100 / leads.length).round()}%',
    'pipe': '₦${_formatCurrency(leads.fold<double>(0, (sum, l) => sum + _parseValue(l.value)))}',
    'content': '${contentItems.length}',
  };
}

// Add helper methods:
double _parseValue(String value) {
  final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
  return double.tryParse(cleaned) ?? 0;
}

String _formatCurrency(double value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
  return value.toStringAsFixed(0);
}
```

---

## Warnings

### WR-01: Dashboard Row with all-Expanded children in unbounded cross-axis

**File:** `lib/pages/marketing/dashboard/marketing_dashboard.dart:145-160`  
**Severity:** WARNING  

**Issue:** In `_buildKpiCards`, the `LayoutBuilder` at line 145 creates a `Row` (line 148) where **all four children** are wrapped in `Expanded`:

```dart
Row(
  children: items.map((it) => Expanded(child: _buildKpiCard(it))).toList(),
)
```

The `Row` receives `constraints.maxHeight = double.infinity` from the `SingleChildScrollView` chain. Since every child is `Expanded`, there are **no non-flex children** to determine the Row's cross-axis extent. The `Expanded` widgets in a `Row` constrain **width** (the main axis), which is bounded. However, the Row's cross-axis (height) sizing depends on child intrinsic heights, and without any non-flex children, different Flutter framework versions may compute `crossAxisExtent` differently:

- Some versions set it to `constraints.crossAxisExtent` (= INFINITY)
- Other versions leave it at 0 (no non-flex children laid out)

Either case produces undefined behavior. The Row at line 148 can report a height of 0 (invisible cards), INFINITY (overflow), or throw entirely depending on Flutter version and rendering phase.

The same pattern appears in the `LayoutBuilder` blocks at lines 24-32 (pipeline/notifications) and lines 46-54 (team/okrs), but those **do** have non-flex children — the `SizedBox(width: 16)` spacers — providing at least one non-flex child to establish the cross-axis extent. Those are safe.

The `_buildKpiCards` Row is uniquely vulnerable because every child is `Expanded`.

**Fix:** After removing the outer `SingleChildScrollView` (per CR-01 fix), this Row receives bounded height and works correctly. However, as a defense-in-depth measure, add a fallback `Wrap` layout or give the `Row` a `mainAxisSize: MainAxisSize.min` to avoid cross-axis ambiguity:

```dart
// BEFORE (line 148-149):
return Row(
  children: items.map((it) => Expanded(child: _buildKpiCard(it))).toList(),
);

// AFTER — with defensive height via IntrinsicHeight or explicit cross-axis:
return IntrinsicHeight(
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: items.map((it) => Expanded(child: _buildKpiCard(it))).toList(),
  ),
);
```

`IntrinsicHeight` constrains the Row's cross-axis to the intrinsic height of its tallest child, making the layout deterministic even with unbounded constraints. The `CrossAxisAlignment.stretch` ensures all cards align to the same height. This is only necessary as a defense against unbounded cross-axis; after CR-01 fix, the bounded height makes it optional.

---

## Summary of Fix Priority

| ID | Location | Issue | Priority | Effort |
|----|----------|-------|----------|--------|
| **CR-01** | `marketing.dart:88-98` | Outer `SingleChildScrollView` passes infinite height to 9 child pages | **Fix first** | 1 line change |
| **CR-02** | `marketing_module_controller.dart:95-96` | `currentPeriodData` silently returns empty map → KPI shows dashes | **Fix second** | ~20 lines |
| **WR-01** | `marketing_dashboard.dart:145-160` | All-Expanded Row in unbounded cross-axis | **Fix after CR-01** | Optional |

The single-line removal of `SingleChildScrollView` from `marketing.dart` unblocks all 9 child pages. The `currentPeriodData` fallback ensures KPI cards never display empty dashes even during loading.

---

_Reviewed: 2026-07-31T14:30:00Z_  
_Reviewer: gsd-code-reviewer_  
_Depth: deep_