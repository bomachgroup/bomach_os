import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

import 'my_network_image_stub.dart'
    if (dart.library.js_interop) 'my_network_image_web.dart' as platform;

/// A network image widget that works on both web (bypasses CORS via HTML <img>)
/// and native platforms (uses standard Image.network).
class MyNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorPlaceholder;

  const MyNetworkImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return ClipRect(
        child: platform.buildWebImage(
          url,
          width: width,
          height: height,
          fit: fit,
          errorPlaceholder: errorPlaceholder,
        ),
      );
    }

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorPlaceholder != null
          ? (context, error, stackTrace) => errorPlaceholder!
          : null,
    );
  }
}
