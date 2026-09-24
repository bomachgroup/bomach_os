import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web manifest declares the installed BOMACH OS app and icons', () {
    final manifest = jsonDecode(File('web/manifest.json').readAsStringSync())
        as Map<String, dynamic>;

    expect(manifest['name'], 'Bomach OS');
    expect(manifest['id'], '/');
    expect(manifest['start_url'], '/');
    expect(manifest['scope'], '/');
    expect(manifest['display'], 'standalone');
    expect(manifest['theme_color'], '#2563EB');
    expect(manifest['description'], isNot(contains('Flutter project')));

    final icons = (manifest['icons'] as List).cast<Map<String, dynamic>>();
    for (final icon in icons) {
      expect(File('web/${icon['src']}').existsSync(), isTrue,
          reason: '${icon['src']} must ship with the app');
    }
    expect(icons.any((icon) => icon['sizes'] == '192x192'), isTrue);
    expect(icons.any((icon) => icon['sizes'] == '512x512'), isTrue);
    expect(
      icons.any((icon) => icon['purpose'] == 'maskable'),
      isTrue,
      reason: 'Android launchers need a maskable icon asset',
    );
  });

  test('web document links the manifest and advertises the app theme', () {
    final html = File('web/index.html').readAsStringSync();
    expect(html, contains('<link rel="manifest" href="manifest.json">'));
    expect(html, contains('name="theme-color" content="#2563EB"'));
    expect(html, contains('apple-mobile-web-app-capable'));
  });
}
