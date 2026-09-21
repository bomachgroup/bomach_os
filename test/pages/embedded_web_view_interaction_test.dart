import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:bomach_os/pages/shared/embedded_web_view_interaction.dart';

void main() {
  test('embedded views stop receiving pointer events while the drawer is open',
      () {
    final interaction = EmbeddedWebViewInteraction();

    expect(interaction.pointerEvents, 'auto');

    interaction.setDrawerOpen(true);
    expect(interaction.pointerEvents, 'none');

    interaction.setDrawerOpen(false);
    expect(interaction.pointerEvents, 'auto');
  });

  test('webview listeners are removed during disposal, not retry scheduling',
      () {
    const webviewFiles = [
      'lib/pages/marketing/widget/marketing_webview_web.dart',
      'lib/pages/services/widget/services_webview_web.dart',
      'lib/pages/finance/widget/finance_webview_web.dart',
    ];

    for (final path in webviewFiles) {
      final source = File(path).readAsStringSync();
      final scheduleStart = source.indexOf('void _scheduleTokenRetries()');
      final disposeStart = source.indexOf('void dispose()');
      final disposeEnd = source.indexOf('super.dispose()', disposeStart);

      expect(scheduleStart, greaterThanOrEqualTo(0), reason: path);
      expect(disposeStart, greaterThan(scheduleStart), reason: path);
      expect(disposeEnd, greaterThan(disposeStart), reason: path);
      expect(
        source.substring(scheduleStart, disposeStart),
        isNot(contains('removeListener')),
        reason: '$path removes the drawer listener while scheduling retries',
      );
      expect(
        source.substring(disposeStart, disposeEnd),
        contains('removeListener'),
        reason: '$path must remove the drawer listener during disposal',
      );
    }
  });
}
