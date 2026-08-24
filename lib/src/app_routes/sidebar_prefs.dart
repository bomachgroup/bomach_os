/// Pure, web-free sidebar decision helpers.
///
/// Lives outside `side_menu.dart` so tests (and the auth controller's
/// logout cleanup) can import it without dragging the widget graph —
/// `package:web` is unreachable in VM test builds.
///
/// RED phase: this module intentionally does not exist yet; the suites in
/// `test/nav/menu_state_test.dart` specify its full contract.

// Implementation lands with Batch 6 (GREEN).
