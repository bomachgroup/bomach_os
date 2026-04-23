import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
    this.text, {
    super.key,
    required this.style,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.letterSpacing,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  // Factory methods for convenience
  factory AppText.displayLg(String text, {Color? color, double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      AppText(text, style: AppTextStyles.displayLg, color: color, fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, letterSpacing: letterSpacing, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.displayMd(String text, {Color? color, double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      AppText(text, style: AppTextStyles.displayMd, color: color, fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, letterSpacing: letterSpacing, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.h1(String text, {Color? color, double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      AppText(text, style: AppTextStyles.h1, color: color, fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, letterSpacing: letterSpacing, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.h2(String text, {Color? color, double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      AppText(text, style: AppTextStyles.h2, color: color, fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, letterSpacing: letterSpacing, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.h3(String text, {Color? color, double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      AppText(text, style: AppTextStyles.h3, color: color, fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, letterSpacing: letterSpacing, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.h4(String text, {Color? color, double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      AppText(text, style: AppTextStyles.h4, color: color, fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, letterSpacing: letterSpacing, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.bodyLg(String text, {Color? color, double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      AppText(text, style: AppTextStyles.bodyLg, color: color, fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, letterSpacing: letterSpacing, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.bodyMd(String text, {Color? color, double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      AppText(text, style: AppTextStyles.bodyMd, color: color, fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, letterSpacing: letterSpacing, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.bodySm(String text, {Color? color, double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      AppText(text, style: AppTextStyles.bodySm, color: color, fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, letterSpacing: letterSpacing, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.label(String text, {Color? color, double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      AppText(text, style: AppTextStyles.label, color: color, fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, letterSpacing: letterSpacing, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory AppText.caption(String text, {Color? color, double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      AppText(text, style: AppTextStyles.caption, color: color, fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, letterSpacing: letterSpacing, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
    );
  }
}

