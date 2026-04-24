import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/pages/services/widget/invoice_list.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Service orders overview — tabbed list of service orders segmented by
/// lifecycle state (Invoice / New / In Progress / Completed).
class ServiceOrder extends StatefulWidget {
  const ServiceOrder({super.key});

  @override
  State<ServiceOrder> createState() => _ServiceOrderState();
}

class _ServiceOrderState extends State<ServiceOrder> {
  int _selectedTab = 0;

  static const _tabs = <_OrderTab>[
    _OrderTab(label: 'Invoices', icon: Iconsax.receipt_2),
    _OrderTab(label: 'New', icon: Iconsax.add_circle),
    _OrderTab(label: 'In Progress', icon: Iconsax.timer_1),
    _OrderTab(label: 'Completed', icon: Iconsax.tick_circle),
  ];

  StatusTone _toneForTab(int index) {
    switch (index) {
      case 0:
        return StatusTone.primary;
      case 1:
        return StatusTone.info;
      case 2:
        return StatusTone.primary;
      case 3:
        return StatusTone.success;
      default:
        return StatusTone.neutral;
    }
  }

  Widget _buildTabs() {
    return AppCard(
      padding: const EdgeInsets.all(8),
      elevation: AppCardElevation.sm,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            final isActive = _selectedTab == index;
            return Padding(
              padding: EdgeInsets.only(right: index == _tabs.length - 1 ? 0 : 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppRadii.brMd,
                  onTap: () => setState(() => _selectedTab = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.surfaceMuted,
                      borderRadius: AppRadii.brMd,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          size: 16,
                          color: isActive
                              ? AppColors.textOnPrimary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tab.label,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: isActive
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTab == 0) {
      return AppCard(
        padding: const EdgeInsets.all(16),
        elevation: AppCardElevation.sm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Invoice orders', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        'Invoices generated against service orders.',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  label: _tabs[_selectedTab].label,
                  tone: _toneForTab(_selectedTab),
                  icon: _tabs[_selectedTab].icon,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const InvoiceList(),
          ],
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.sm,
      child: EmptyState.empty(
        title: 'No ${_tabs[_selectedTab].label.toLowerCase()} orders',
        subtitle:
            'Service orders under this stage will appear here once they are created.',
        action: MyOutlinedButton(
          icon: const Icon(Iconsax.add_circle,
              size: 18, color: AppColors.primary),
          child: 'Create Order',
          onTap: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Service Orders',
        subtitle:
            'Track service orders across their lifecycle — from invoice to completion.',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Order',
          onTap: () {},
        ),
      ),
      children: [
        _buildTabs(),
        _buildTabContent(),
      ],
    );
  }
}

class _OrderTab {
  final String label;
  final IconData icon;
  const _OrderTab({required this.label, required this.icon});
}
