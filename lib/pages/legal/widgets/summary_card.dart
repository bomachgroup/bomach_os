import 'package:bms_front_end/components/cards/stats_header.dart';
import 'package:bms_front_end/pages/legal/legal.dart';
import 'package:flutter/material.dart';

// Model for the data ou can manipulate this later on sha
class SummaryItem {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final bool isCurrency;

  SummaryItem(this.label, this.value, this.icon,
      {this.valueColor, this.isCurrency = false});
}

// This class will notify widgets when the active tab changes.
class DashboardData extends ChangeNotifier {
  DashboardTab _activeTab = DashboardTab.contracts;

  DashboardTab get activeTab => _activeTab;

  void setActiveTab(DashboardTab newTab) {
    if (_activeTab != newTab) {
      _activeTab = newTab;
      notifyListeners();
    }
  }

  // Helper method to get the current list of summary items
  List<SummaryItem> getCurrentSummaryItems() {
    return dashboardSummaryData[_activeTab] ?? [];
  }
}

class DynamicSummaryRow extends StatelessWidget {
  final DashboardData dashboardData;

  const DynamicSummaryRow({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dashboardData,
      builder: (context, child) {
        final summaryItems = dashboardData.getCurrentSummaryItems();

        // Convert SummaryItem data into SummaryCard widgets
        final summaryCards = summaryItems
            .map((item) => StatsHeaderCard(
                  icon: item.icon,
                  count: item.value,
                  label: item.label,
                ))
            .toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 900;

            return isSmall
                ? Wrap(spacing: 12, runSpacing: 12, children: summaryCards)
                : Row(
                    children: summaryCards
                        .map((e) => Expanded(
                                child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: e,
                            )))
                        .toList(),
                  );
          },
        );
      },
    );
  }
}
