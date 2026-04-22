import 'package:flutter/material.dart';

/// Semantic color tokens for Bomach OS.
///
/// Prefer the semantic names (`primary`, `textPrimary`, `success`, etc.) in
/// new code. Legacy names (`blue`, `grey1`–`grey7`, `sideMenu`, etc.) are kept
/// as `@Deprecated` aliases so existing pages continue to build — they will be
/// migrated opportunistically.
class AppColors {
  // ─── Brand ──────────────────────────────────────────────────────────────
  static const primary = Color(0xFF2563EB);
  static const primaryHover = Color(0xFF1D4ED8);
  static const primaryPressed = Color(0xFF1E40AF);
  static const primarySubtle = Color(0xFFEFF4FF);
  static const primarySoft = Color(0xFFDBE6FE);

  // ─── Neutrals (Slate scale) ─────────────────────────────────────────────
  static const neutral50 = Color(0xFFF8FAFC);
  static const neutral100 = Color(0xFFF1F5F9);
  static const neutral200 = Color(0xFFE2E8F0);
  static const neutral300 = Color(0xFFCBD5E1);
  static const neutral400 = Color(0xFF94A3B8);
  static const neutral500 = Color(0xFF64748B);
  static const neutral600 = Color(0xFF475569);
  static const neutral700 = Color(0xFF334155);
  static const neutral800 = Color(0xFF1E293B);
  static const neutral900 = Color(0xFF0F172A);

  // ─── Semantic ───────────────────────────────────────────────────────────
  static const success = Color(0xFF16A34A);
  static const successSubtle = Color(0xFFDCFCE7);
  static const warning = Color(0xFFD97706);
  static const warningSubtle = Color(0xFFFEF3C7);
  static const danger = Color(0xFFDC2626);
  static const dangerSubtle = Color(0xFFFEE2E2);
  static const info = Color(0xFF0284C7);
  static const infoSubtle = Color(0xFFE0F2FE);

  // ─── Surfaces ───────────────────────────────────────────────────────────
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF1F5F9);
  static const borderSubtle = Color(0xFFE2E8F0);
  static const borderStrong = Color(0xFFCBD5E1);

  // ─── Text ───────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textMuted = Color(0xFF94A3B8);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // ─── Utilities ──────────────────────────────────────────────────────────
  static const transparent = Colors.transparent;
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // ─── Legacy aliases (migrate opportunistically) ─────────────────────────
  // These keep existing pages building while the codebase is migrated to the
  // semantic tokens above. Do not add new references to these.

  @Deprecated('Use AppColors.primary')
  static const blue = primary;

  @Deprecated('Use AppColors.primaryHover or primary')
  static const blue2 = Color(0xFF3589FF);

  @Deprecated('Use AppColors.neutral800')
  static const darkBlue = Color(0xFF252C58);

  @Deprecated('Use AppColors.primaryPressed')
  static const darkBlue2 = Color(0xFF203C9C);

  @Deprecated('Use AppColors.primarySubtle')
  static const lightBlue = Color(0xFFDADAFC);

  @Deprecated('Use AppColors.danger')
  static const red = danger;

  @Deprecated('Use AppColors.warning')
  static const orange = Color(0xFFECBA04);

  @Deprecated('Use AppColors.textMuted or neutral400')
  static const sideMenueItem = Color(0xFF8E92BC);

  @Deprecated('Use AppColors.primarySubtle or primarySoft')
  static const sideMenueTile = Color(0xFFA1C1FF);

  @Deprecated('Use AppColors.borderSubtle')
  static const card = Color(0xFFE0E0E0);

  @Deprecated('Use AppColors.borderSubtle')
  static const border = Color(0xFFE8E8E8);

  @Deprecated('Use AppColors.surfaceMuted or primarySubtle')
  static const sideMenu = Color(0xFFEFF5FF);

  @Deprecated('Use AppColors.success or pick a specific secondary')
  static const secondary = Color(0xFF2E7176);

  @Deprecated('Use AppColors.textPrimary')
  static const sideMenueText = Color(0xFF313131);

  @Deprecated('Use AppColors.success')
  static const green = success;

  @Deprecated('Use AppColors.success')
  static const green2 = Color(0xFF13CF09);

  @Deprecated('Use AppColors.background')
  static const greyBg = background;

  @Deprecated('Use AppColors.neutral500')
  static const grey1 = Color(0xFF7E7E7E);

  @Deprecated('Use AppColors.neutral400')
  static const grey2 = Color(0xFFA2A1A8);

  @Deprecated('Use AppColors.neutral400')
  static const grey3 = Color(0xFFA2A1A8);

  @Deprecated('Use AppColors.neutral300')
  static const grey4 = Color(0xFFB5B5B5);

  @Deprecated('Use AppColors.neutral100')
  static const grey5 = Color(0xFFF1F1F1);

  @Deprecated('Use AppColors.neutral100')
  static const grey6 = Color(0xFFF0F0F0);

  @Deprecated('Use AppColors.neutral200')
  static const grey7 = Color(0xFFE5E7EB);

  @Deprecated('Use AppColors.neutral500')
  static const darkGrey1 = Color(0xFF787878);

  @Deprecated('Use AppColors.neutral400')
  static const darkGrey2 = Color(0xFFA2A1A8);

  @Deprecated('Use AppColors.textPrimary')
  static const darkGrey3 = Color(0xFF16151C);

  @Deprecated('Use AppColors.textPrimary')
  static const black2 = Color(0xFF262626);
}
