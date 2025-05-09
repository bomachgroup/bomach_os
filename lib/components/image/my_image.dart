// ignore_for_file: unused_local_variable

import 'package:bms_front_end/src/constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class MyImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final double radiusTop;
  final double radiusBottom;
  final double? width;
  final double? height;

  const MyImage(
    this.url, {
    super.key,
    this.radiusTop = 10,
    this.fit = BoxFit.cover,
    this.radiusBottom = 10,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radiusTop),
          topRight: Radius.circular(radiusTop),
          bottomLeft: Radius.circular(radiusBottom),
          bottomRight: Radius.circular(radiusBottom)),
      child: (url != null && !url!.startsWith('http'))
          ? ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radiusTop),
                topRight: Radius.circular(radiusTop),
                bottomLeft: Radius.circular(radiusBottom),
                bottomRight: Radius.circular(radiusBottom),
              ),
              child: Image.asset(
                url!,
                width: width,
                height: height,
                filterQuality: FilterQuality.high,
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: AppColors.grey5,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(radiusTop),
                        topRight: Radius.circular(radiusTop),
                        bottomLeft: Radius.circular(radiusBottom),
                        bottomRight: Radius.circular(radiusBottom),
                      ),
                    ),
                  );
                },
              ),
            )
          : CachedNetworkImage(
              imageUrl: _validateUrl(url),
              width: width,
              height: height,
              filterQuality: FilterQuality.high,
              fit: fit,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: AppColors.grey5,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(radiusTop),
                    topRight: Radius.circular(radiusTop),
                    bottomLeft: Radius.circular(radiusBottom),
                    bottomRight: Radius.circular(radiusBottom),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                    color: AppColors.grey5,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(radiusTop),
                        topRight: Radius.circular(radiusTop),
                        bottomLeft: Radius.circular(radiusBottom),
                        bottomRight: Radius.circular(radiusBottom))),
              ),
            ),
    );
  }

  String _validateUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    // Add https:// if missing
    return url.startsWith('http') ? url : 'https://$url';
  }
}
