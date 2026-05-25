import 'package:bomach_os/src/constants/colors.dart';
import 'package:flutter/material.dart';

class MyText extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;
  final int? weight;
  final String? fontFamily;
  final int? maxLines;
  final TextAlign? textAlign;
  final bool isSelectable;
  final TextStyle? style;
  final void Function()? onTap;

  const MyText(
    this.text, {
    super.key,
    this.size,
    this.weight,
    this.color,
    this.fontFamily,
    this.maxLines,
    this.textAlign,
    this.isSelectable = true,
    this.style,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    TextStyle finalStyle = style?.copyWith(
          fontFamily: fontFamily,
          color: color,
          fontSize: size,
          fontWeight: getWeight(),
        ) ??
        TextStyle(
          fontFamily: fontFamily,
          color: color ?? AppColors.black,
          fontSize: size,
          fontWeight: getWeight(),
        );

    if (isMobile) {
      final double currentSize = finalStyle.fontSize ?? 14;
      double newSize = currentSize;

      if (currentSize >= 32)
        newSize = currentSize * 0.75; // 32 -> 24
      else if (currentSize >= 24)
        newSize = currentSize * 0.83; // 24 -> 20
      else if (currentSize >= 18)
        newSize = currentSize * 0.88; // 18 -> 16
      else if (currentSize >= 14) newSize = currentSize * 0.92; // 14 -> 13

      finalStyle = finalStyle.copyWith(fontSize: newSize);
    }

    if (isSelectable && onTap == null) {
      return SelectableRegion(
        focusNode: FocusNode(),
        selectionControls: materialTextSelectionControls,
        child: Text(
          text,
          textAlign: textAlign,
          overflow: TextOverflow.ellipsis,
          maxLines: maxLines,
          style: finalStyle,
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
        maxLines: maxLines,
        style: finalStyle,
      ),
    );
  }

  FontWeight? getWeight() {
    final data = {
      100: FontWeight.w100,
      200: FontWeight.w200,
      300: FontWeight.w300,
      400: FontWeight.w400,
      500: FontWeight.w500,
      600: FontWeight.w600,
      700: FontWeight.w700,
      800: FontWeight.w800,
      900: FontWeight.w900,
    };
    return data[weight];
  }
}
