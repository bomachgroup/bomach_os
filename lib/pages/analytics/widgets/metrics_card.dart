import 'package:flutter/material.dart';

class AnalyticsMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String? imgPath;
  final IconData? icon;
  final Color? color;
  final bool isBearish;
  final bool showtrend;

  const AnalyticsMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.icon,
    this.imgPath,
    this.color,
    this.isBearish = false,
    this.showtrend = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 220;
        final textTheme = Theme.of(context).textTheme;

        return Container(
          constraints: const BoxConstraints(
            minWidth: 200,
            minHeight: 120,
            maxHeight: 130,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.labelMedium?.copyWith(
                        fontSize: isWide ? 14 : 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (imgPath != null)
                    Image.asset(
                      imgPath!,
                      height: isWide ? 24 : 18,
                      width: isWide ? 24 : 18,
                      color: color,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.broken_image,
                        size: isWide ? 24 : 18,
                        color: color,
                      ),
                    )
                  else if (icon != null)
                    Icon(
                      icon,
                      color: color,
                      size: isWide ? 24 : 18,
                    )
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: textTheme.titleLarge?.copyWith(
                  fontSize: isWide ? 22 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                spacing: 4,
                children: [
                  if (showtrend == true)
                    Icon(
                      isBearish ? Icons.trending_down : Icons.trending_up,
                      size: isWide ? 20 : 16,
                      color: isBearish ? Colors.red : Colors.green,
                    ),
                  Flexible(
                    child: Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: isWide ? 12 : 11,
                        color: showtrend
                            ? isBearish
                                ? Colors.red
                                : Colors.green
                            : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
