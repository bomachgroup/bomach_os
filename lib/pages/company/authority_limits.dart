import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/company/controllers/authority_limit_controller.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/authority_limit_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AuthorityLimitsPage extends StatelessWidget {
  const AuthorityLimitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthorityLimitController());

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Authority Limits',
        subtitle: 'Define approval authority limits across roles and resources',
        trailing: IconButton(
          tooltip: 'Refresh authority limits',
          onPressed: () => controller.fetchAuthorityLimits(refresh: true),
          icon: const Icon(Iconsax.refresh, color: AppColors.textPrimary),
        ),
      ),
      children: [
        Obx(() {
          if (controller.isLoading.value &&
              controller.authorityLimits.isEmpty) {
            return const AppCard(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.authorityLimits.isEmpty) {
            return _MessageCard(
              icon: Iconsax.warning_2,
              message: controller.errorMessage.value,
            );
          }

          if (controller.authorityLimits.isEmpty) {
            return const _MessageCard(
              icon: Iconsax.shield_cross,
              message: 'No authority limits found.',
            );
          }

          return _AuthorityLimitList(
            limits: controller.authorityLimits,
            roleName: (roleId) => controller.roles
                .firstWhereOrNull((role) => role.id.toString() == roleId)
                ?.name,
          );
        }),
      ],
    );
  }
}

class _AuthorityLimitList extends StatelessWidget {
  final List<AuthorityLimit> limits;
  final String? Function(String roleId) roleName;

  const _AuthorityLimitList({required this.limits, required this.roleName});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: limits
            .map((limit) => _AuthorityLimitRow(
                  limit: limit,
                  roleName: roleName(limit.roleId),
                ))
            .toList(),
      ),
    );
  }
}

class _AuthorityLimitRow extends StatelessWidget {
  final AuthorityLimit limit;
  final String? roleName;

  const _AuthorityLimitRow({required this.limit, this.roleName});

  @override
  Widget build(BuildContext context) {
    final amount = limit.maxAmount == null
        ? 'No amount limit'
        : '${limit.currency ?? ''} ${limit.maxAmount}';
    final quantity = limit.maxQuantity == null
        ? 'No quantity limit'
        : 'Up to ${limit.maxQuantity}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
              width: 180,
              child: _Field(label: 'Role', value: roleName ?? limit.roleId)),
          SizedBox(
              width: 180,
              child: _Field(label: 'Resource', value: limit.resource)),
          SizedBox(
              width: 140, child: _Field(label: 'Action', value: limit.action)),
          SizedBox(width: 160, child: _Field(label: 'Amount', value: amount)),
          SizedBox(
              width: 140, child: _Field(label: 'Quantity', value: quantity)),
          SizedBox(
            width: 160,
            child: _Field(
              label: 'Approval level',
              value: limit.approvalLevel ?? 'Not specified',
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;

  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _MessageCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(message, style: AppTextStyles.bodyMd),
          ],
        ),
      ),
    );
  }
}
