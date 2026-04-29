import 'package:bomach_os/src/constants/colors.dart';
import 'package:flutter/material.dart';

/// Semantic typography tiers for Bomach OS.
///
/// Prefer the semantic names (`h1`, `bodyMd`, `label`, etc.) in new code.
/// Legacy names (`black_600_32`, `sideMWhite_400_14`, etc.) are kept as
/// `@Deprecated` aliases so existing pages continue to build.
class AppTextStyles {
  AppTextStyles._();

  // ─── Display ────────────────────────────────────────────────────────────
  static const TextStyle displayLg = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.3,
  );
  static const TextStyle displayMd = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.2,
  );

  // ─── Headings ───────────────────────────────────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  );
  static const TextStyle h4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ─── Body ───────────────────────────────────────────────────────────────
  static const TextStyle bodyLg = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  static const TextStyle bodyMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  static const TextStyle bodySm = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ─── Labels / captions ──────────────────────────────────────────────────
  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    height: 1.4,
    letterSpacing: 0.6,
  );

  // ─── Legacy aliases (migrate opportunistically) ─────────────────────────
  // Existing pages use these names; keep them building. Do not add new
  // references — reach for the semantic tiers above.

  @Deprecated('Use AppTextStyles.bodyLg with color override or .copyWith(color: AppColors.white)')
  static const white_400_18 =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white);

  @Deprecated('Use AppTextStyles.displayLg with color override')
  static const white_600_32 =
      TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: Colors.white);

  @Deprecated('Use AppTextStyles.h2 with color override')
  static const white_600_20 =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white);

  @Deprecated('Use AppTextStyles.bodyLg with color override')
  static const white_400_16 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white);

  @Deprecated('Use AppTextStyles.bodyLg with color override')
  static const white_300_16 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: Colors.white);

  @Deprecated('Use AppTextStyles.h4 with color override')
  static const white_600_16 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);

  @Deprecated('Use AppTextStyles.bodyMd with color override')
  static const sideMWhite_400_14 =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white);

  @Deprecated('Use AppTextStyles.displayLg')
  static const black_600_32 = TextStyle(
      fontSize: 32, fontWeight: FontWeight.w400, color: AppColors.neutral900);

  @Deprecated('Use AppTextStyles.label.copyWith(fontWeight: FontWeight.w600) or h4')
  static const black_600_14 = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.neutral900);

  @Deprecated('Use AppTextStyles.h1')
  static const black_500_24 = TextStyle(
      fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.neutral900);

  @Deprecated('Use AppTextStyles.bodyLg or h4')
  static const black_500_16 = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.neutral900);

  @Deprecated('Use AppTextStyles.displayLg')
  static const black_500_32 = TextStyle(
      fontSize: 32, fontWeight: FontWeight.w500, color: AppColors.neutral900);

  @Deprecated('Use AppTextStyles.h2')
  static const black_500_20 = TextStyle(
      fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.neutral900);

  @Deprecated('Use AppTextStyles.displayMd')
  static const black_500_28 = TextStyle(
      fontSize: 28, fontWeight: FontWeight.w500, color: AppColors.neutral900);

  @Deprecated('Use AppTextStyles.bodyMd')
  static const black_400_14 = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF000000));

  @Deprecated('Use AppTextStyles.bodyLg')
  static const black_300_16 = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w300, color: Color(0xFF000000));

  @Deprecated('Use AppTextStyles.bodyLg')
  static const black_400_16 = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF000000));

  @Deprecated('Use AppTextStyles.h4')
  static const black_600_16 = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF000000));

  @Deprecated('Use AppTextStyles.h4.copyWith(color: AppColors.primary)')
  static const blue_600_16 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue);

  @Deprecated('Use AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)')
  static const sideM_600_14 = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF8E92BC));

  @Deprecated('Use AppTextStyles.bodyMd')
  static const sideMblack_400_14 = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF000000));

  @Deprecated('Use AppTextStyles.bodyMd with color override')
  static const sideMText_300_14 = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w300, color: AppColors.neutral800);

  @Deprecated('Use AppTextStyles.bodyMd with color override')
  static const sideMText_400_14 = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.neutral800);

  @Deprecated('Use AppTextStyles.bodyLg with color override')
  static const sideMText_300_16 = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w300, color: AppColors.neutral800);

  @Deprecated('Use AppTextStyles.bodyMd.copyWith(color: AppColors.primary)')
  static const sideMBlueText_300_14 = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w300, color: AppColors.primary);

  @Deprecated('Use AppTextStyles.bodyMd.copyWith(color: AppColors.primary)')
  static const sideMBlueText_400_14 = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.primary);
}
