import 'package:flutter/material.dart';
import 'package:bms_front_end/src/constants/spaces.dart';

/// A row that automatically adjusts its layout based on available width.
///
/// On desktop (>= 1100), it renders as a single [Row] with [Expanded] cards.
/// On tablet (>= 720), it renders as a [Wrap] with two cards per row.
/// On mobile, it renders as a [Column] (implicitly via Wrap's default behavior if not constrained).
class ResponsiveStatRow extends StatelessWidget {
  const ResponsiveStatRow({super.key, required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;

      if (width >= 1100) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) kSizedBoxWidth,
              Expanded(child: cards[i]),
            ],
          ],
        );
      }

      if (width >= 720) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards
              .map((card) => SizedBox(
                    width: (width - 16) / 2,
                    child: card,
                  ))
              .toList(),
        );
      }

      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) kSizedBox,
            cards[i],
          ],
        ],
      );
    });
  }
}
