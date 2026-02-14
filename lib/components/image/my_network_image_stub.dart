import 'package:flutter/widgets.dart';

Widget buildWebImage(
  String url, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? errorPlaceholder,
}) {
  return Image.network(
    url,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorPlaceholder != null
        ? (context, error, stackTrace) => errorPlaceholder
        : null,
  );
}
