import 'package:bomach_os/src/constants/colors.dart' show AppColors;
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';

import '../../components/input/my_dropdown.dart';
import '../../components/text/my_text.dart';
import 'dialogs/client_dialog.dart';
import 'dialogs/lead_dialog.dart';
import 'models.dart';
import 'widgets/widgets.dart';

class InteractionsPage extends StatelessWidget {
  const InteractionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth < 900;

    Widget buildActionButton({
      required IconData icon,
      required String label,
      required bool isWide,
      void Function()? onPressed,
      Color? foregroundColor,
      Color? backgroundColor,
    }) {
      if (isWide) {
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.white,
            foregroundColor: foregroundColor ?? Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          icon: Icon(icon, size: 18),
          label: Text(label, style: const TextStyle(fontSize: 12)),
          onPressed: onPressed,
        );
      } else {
        return IconButton(
          tooltip: label,
          style: IconButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.white,
            foregroundColor: foregroundColor ?? Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
        );
      }
    }

    return Column(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 520,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    'Customer Relationship Management',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  MyText(
                    'Manage clients, leads, and customer interactions',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                buildActionButton(
                    onPressed: () {},
                    icon: Iconsax.message_text,
                    label: 'Log Interactions',
                    isWide: !isMobile),
                buildActionButton(
                    onPressed: () {
                      AddNewLeadDialog.show(context);
                    },
                    icon: Iconsax.copy,
                    label: 'Add Lead',
                    isWide: !isMobile),
                buildActionButton(
                    onPressed: () {
                      AddNewClientDialog.show(context);
                    },
                    icon: Iconsax.user_add,
                    label: 'Add Client',
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    isWide: !isMobile),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: crmMetrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: isMobile
                ? 1.5
                : isTablet
                    ? 1
                    : 1.8,
          ),
          itemBuilder: (context, index) =>
              StandardMetricCard(data: crmMetrics[index]),
        ),
        const SizedBox(height: 32),
        const InteractonsWidget()
      ],
    );
  }
}

Map<String, Color> _getPriorityColors(String priority) {
  switch (priority.toLowerCase()) {
    case 'critical':
      return {'bg': const Color(0xFFFFE6E6), 'text': AppColors.danger};
    case 'high':
      return {'bg': AppColors.dangerSubtle, 'text': const Color(0xFFF39C12)};
    case 'medium':
    default:
      return {'bg': const Color(0xFFE6F3FF), 'text': const Color(0xFF3498DB)};
  }
}

Map<String, Color> _getStatusColors(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return {'bg': AppColors.successSubtle, 'text': AppColors.success};
    case 'pending':
      return {'bg': AppColors.neutral100, 'text': Colors.black87};
    case 'in progress':
      return {'bg': AppColors.warningSubtle, 'text': const Color(0xFFF1C40F)};
    default:
      return {'bg': AppColors.neutral100, 'text': Colors.black87};
  }
}

class InteractonsWidget extends StatelessWidget {
  const InteractonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Client Interactions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track all client communications and activities',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 620;

              const search = TextField(
                decoration: InputDecoration(
                  hintText: 'Search interactions...',
                  prefixIcon: Icon(Iconsax.search_normal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.neutral100,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
              );

              final filter = SizedBox(
                width: compact ? double.infinity : 150,
                child: MyDropdown(
                  hintText: 'All Types',
                  items: const [
                    'All Types',
                    'Meeting',
                    'Call',
                    'Email',
                    'Site Visit'
                  ],
                  onChanged: (String? newValue) {},
                  fillColor: AppColors.neutral100,
                ),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    search,
                    const SizedBox(height: 12),
                    filter,
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  const Expanded(child: search),
                  const SizedBox(width: 16),
                  filter,
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const InteractionDataTable(),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}

class InteractionDataTable extends StatelessWidget {
  const InteractionDataTable({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return _buildCards();
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.neutral100,
              child: const Row(
                children: [
                  Expanded(flex: 2, child: _HeaderText('Client')),
                  SizedBox(width: 14),
                  Expanded(flex: 2, child: _HeaderText('Subject')),
                  SizedBox(width: 14),
                  Expanded(child: _HeaderText('Type')),
                  SizedBox(width: 14),
                  Expanded(child: _HeaderText('Priority')),
                  SizedBox(width: 14),
                  Expanded(child: _HeaderText('Status')),
                  SizedBox(width: 14),
                  Expanded(child: _HeaderText('Date')),
                  SizedBox(width: 14),
                  Expanded(child: _HeaderText('Created By')),
                  SizedBox(width: 44),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.neutral200),
            ...interactionsMock.map(_buildRow),
          ],
        );
      },
    );
  }

  Widget _buildRow(ClientInteraction interaction) {
    final priorityColors = _getPriorityColors(interaction.priority);
    final statusColors = _getStatusColors(interaction.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(interaction.client,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: _buildSubject(interaction),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildSimpleTag(interaction.type,
                  backgroundColor: AppColors.neutral100,
                  textColor: Colors.black87),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildColoredTag(
                interaction.priority,
                backgroundColor: priorityColors['bg']!,
                textColor: priorityColors['text']!,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildColoredTag(
                interaction.status,
                backgroundColor: statusColors['bg']!,
                textColor: statusColors['text']!,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(interaction.date, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(interaction.createdBy, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(
            width: 44,
            child: IconButton(
              icon: Icon(Iconsax.eye, color: Colors.grey),
              onPressed: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCards() {
    return Column(
      children: interactionsMock.map((interaction) {
        final priorityColors = _getPriorityColors(interaction.priority);
        final statusColors = _getStatusColors(interaction.status);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.neutral200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      interaction.client,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildSimpleTag(interaction.type,
                      backgroundColor: AppColors.neutral100,
                      textColor: Colors.black87),
                ],
              ),
              const SizedBox(height: 10),
              _buildSubject(interaction),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildColoredTag(
                    interaction.priority,
                    backgroundColor: priorityColors['bg']!,
                    textColor: priorityColors['text']!,
                  ),
                  _buildColoredTag(
                    interaction.status,
                    backgroundColor: statusColors['bg']!,
                    textColor: statusColors['text']!,
                  ),
                  _buildMeta(Iconsax.calendar, interaction.date),
                  _buildMeta(Iconsax.user, interaction.createdBy),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubject(ClientInteraction interaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          interaction.subject,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          interaction.details,
          maxLines: 2,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMeta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSimpleTag(String text,
      {required Color backgroundColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildColoredTag(String text,
      {required Color backgroundColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
