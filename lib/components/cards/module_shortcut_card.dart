import 'package:bomach_os/src/constants/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation tile surfaced on every module dashboard. Each card represents
/// one sub-module (same route the sidebar uses). When [enabled] is false,
/// the card renders locked and is not tappable — role visibility is gated
/// at the dashboard level, interactivity per card.
class ModuleShortcutCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String route;
  final bool enabled;
  final Color? accentColor;

  const ModuleShortcutCard({
    super.key,
    required this.icon,
    required this.title,
    required this.route,
    this.subtitle,
    this.enabled = true,
    this.accentColor,
  });

  @override
  State<ModuleShortcutCard> createState() => _ModuleShortcutCardState();
}

class _ModuleShortcutCardState extends State<ModuleShortcutCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.primary;
    final disabled = !widget.enabled;

    final tooltip = disabled
        ? 'You do not have permission to access this section'
        : (widget.subtitle ?? widget.title);

    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: disabled ? null : () => context.go(widget.route),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: disabled
                  ? AppColors.neutral100
                  : (_hovering ? AppColors.surfaceMuted : Colors.white),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: disabled
                    ? AppColors.borderSubtle
                    : (_hovering ? accent : AppColors.borderSubtle),
                width: 1,
              ),
              boxShadow: disabled
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: _hovering ? 0.08 : 0.04),
                        blurRadius: _hovering ? 14 : 8,
                        offset: Offset(0, _hovering ? 4 : 2),
                      ),
                    ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                        accent.withValues(alpha: disabled ? 0.08 : 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    color: disabled ? AppColors.neutral400 : accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: disabled
                                    ? AppColors.neutral500
                                    : AppColors.neutral800,
                              ),
                            ),
                          ),
                          if (disabled)
                            const Icon(
                              Iconsax.lock,
                              size: 14,
                              color: AppColors.neutral400,
                            )
                          else
                            Icon(
                              Iconsax.arrow_right_3,
                              size: 16,
                              color: _hovering ? accent : AppColors.neutral400,
                            ),
                        ],
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: disabled
                                ? AppColors.neutral400
                                : AppColors.neutral500,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
