import 'package:bomach_os/components/cards/module_shortcut_card.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:flutter/material.dart';

/// Unified module landing page layout. Every module dashboard in the app
/// uses this to surface its sub-modules as a consistent clickable grid.
///
/// Role-awareness is handled by the caller: build the [shortcuts] list with
/// `enabled` reflecting the user's permission for each route. The dashboard
/// itself is always rendered so users with the same role see the same
/// layout; only interactivity varies per role.
class ModuleDashboard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? headerTrailing;
  final Widget? statsRow;
  final List<ModuleShortcutCard> shortcuts;
  final List<Widget> extraSections;
  final EdgeInsetsGeometry padding;

  const ModuleDashboard({
    super.key,
    required this.title,
    required this.shortcuts,
    this.subtitle,
    this.headerTrailing,
    this.statsRow,
    this.extraSections = const [],
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            title: title,
            subtitle: subtitle,
            trailing: headerTrailing,
          ),
          const SizedBox(height: 20),
          if (statsRow != null) ...[
            statsRow!,
            const SizedBox(height: 24),
          ],
          const _SectionLabel(label: 'Modules'),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1200
                  ? 4
                  : width >= 900
                      ? 3
                      : width >= 560
                          ? 2
                          : 1;
              return _ShortcutGrid(
                columns: columns,
                cards: shortcuts,
              );
            },
          ),
          for (final section in extraSections) ...[
            const SizedBox(height: 28),
            section,
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _Header({required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral800,
      ),
    );
  }
}

/// Standalone shortcut grid for existing dashboards that are not ready to
/// adopt the full [ModuleDashboard] layout. Drop this at the top of a
/// module page and pass the same shortcut cards the sidebar would surface.
class ModuleQuickNav extends StatelessWidget {
  final String label;
  final List<ModuleShortcutCard> shortcuts;

  const ModuleQuickNav({
    super.key,
    this.label = 'Quick Navigation',
    required this.shortcuts,
  });

  @override
  Widget build(BuildContext context) {
    if (shortcuts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral800,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1200
                ? 4
                : width >= 900
                    ? 3
                    : width >= 560
                        ? 2
                        : 1;
            return _ShortcutGrid(columns: columns, cards: shortcuts);
          },
        ),
      ],
    );
  }
}

class _ShortcutGrid extends StatelessWidget {
  final int columns;
  final List<ModuleShortcutCard> cards;

  const _ShortcutGrid({required this.columns, required this.cards});

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: const Text(
          'No modules available for your role.',
          style: TextStyle(color: AppColors.neutral500, fontSize: 14),
        ),
      );
    }

    const spacing = 12.0;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        mainAxisExtent: 104,
      ),
      itemBuilder: (_, i) => cards[i],
    );
  }
}
