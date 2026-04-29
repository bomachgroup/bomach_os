import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:flutter/material.dart';

/// Shimmering placeholder block. Compose into list rows, cards, stat rows,
/// and form skeletons below. No external `shimmer` dep — uses a simple
/// gradient slide animated by a controller.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? AppRadii.brSm;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: const Alignment(-1.5, 0),
              end: const Alignment(1.5, 0),
              stops: [
                (t - 0.3).clamp(0.0, 1.0),
                t.clamp(0.0, 1.0),
                (t + 0.3).clamp(0.0, 1.0),
              ],
              colors: const [
                AppColors.neutral100,
                AppColors.neutral200,
                AppColors.neutral100,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Composite skeletons — drop-in replacements for full-screen spinners while
/// lists, cards, and forms are loading.
class LoadingSkeleton {
  LoadingSkeleton._();

  /// Vertical stack of skeleton list rows.
  static Widget listRows({int count = 6, double rowHeight = 64}) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: i == count - 1 ? 0 : 12),
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: AppCardElevation.none,
            child: SizedBox(
              height: rowHeight - 24,
              child: const Row(
                children: [
                  SkeletonBox(
                    width: 40,
                    height: 40,
                    borderRadius: AppRadii.brPill,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 160, height: 12),
                        SizedBox(height: 8),
                        SkeletonBox(width: 120, height: 10),
                      ],
                    ),
                  ),
                  SkeletonBox(
                    width: 72,
                    height: 24,
                    borderRadius: AppRadii.brPill,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A row of stat cards — matches the standard 4-across dashboard pattern.
  static Widget statRow({int count = 4}) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 700;
      final perRow = isWide ? count : 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(count, (i) {
          final cardWidth =
              (constraints.maxWidth - ((perRow - 1) * 12)) / perRow;
          return SizedBox(
            width: cardWidth,
            child: const AppCard(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 80, height: 10),
                  SizedBox(height: 12),
                  SkeletonBox(width: 120, height: 20),
                  SizedBox(height: 8),
                  SkeletonBox(width: 60, height: 10),
                ],
              ),
            ),
          );
        }),
      );
    });
  }

  /// Generic card body skeleton — title + 3 paragraphs.
  static Widget card({int lines = 3}) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 180, height: 18),
          const SizedBox(height: 16),
          for (int i = 0; i < lines; i++) ...[
            SkeletonBox(
              width: i == lines - 1 ? 160 : double.infinity,
              height: 12,
            ),
            if (i != lines - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  /// Form-shape skeleton — label + field repeating.
  static Widget form({int fields = 4}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < fields; i++) ...[
          const SkeletonBox(width: 100, height: 10),
          const SizedBox(height: 8),
          const SkeletonBox(width: double.infinity, height: 44),
          if (i != fields - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}
