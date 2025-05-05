import 'package:bms_front_end/src/constants/colors.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    final finalStyle = style?.copyWith(
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

    if (isSelectable) {
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

    return Text(
      text,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
      style: finalStyle,
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
