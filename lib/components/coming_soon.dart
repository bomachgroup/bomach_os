import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../src/constants/colors.dart';

class ComingSoonTab extends StatelessWidget {
  final String? featureName;
  const ComingSoonTab({super.key, this.featureName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.clock, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              featureName != null ? '$featureName - Coming Soon' : 'Coming Soon',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'This feature is under development and will be available in a future release.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
