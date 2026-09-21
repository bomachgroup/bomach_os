import 'package:flutter/foundation.dart';

/// Coordinates HTML platform views with Flutter's drawer-based navigation.
///
/// Flutter drawers are painted in the Flutter layer while embedded iframes are
/// HTML platform views. When the drawer is open, the iframe must stop hit
/// testing so the drawer can receive pointer events.
class EmbeddedWebViewInteraction extends ValueNotifier<bool> {
  EmbeddedWebViewInteraction() : super(false);

  String get pointerEvents => value ? 'none' : 'auto';

  void setDrawerOpen(bool isOpen) {
    if (value != isOpen) value = isOpen;
  }
}

final embeddedWebViewInteraction = EmbeddedWebViewInteraction();
