import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../src/constants/colors.dart';

/// Honest UI state for a feature whose backend contract is not published.
class BackendCapabilityUnavailable extends StatelessWidget {
  final String featureName;
  final String explanation;
  final String contractRequirement;

  const BackendCapabilityUnavailable({
    super.key,
    required this.featureName,
    required this.explanation,
    required this.contractRequirement,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Card(
          elevation: 0,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderSubtle),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.info_circle,
                    size: 40, color: AppColors.warning),
                const SizedBox(height: 16),
                Text('$featureName is not available yet',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Text(explanation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                Text(contractRequirement,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
