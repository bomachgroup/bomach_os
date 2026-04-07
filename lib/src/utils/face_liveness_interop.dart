import 'dart:js_interop';

@JS()
external void startLivenessCheck(JSString videoElementId);

@JS()
external void stopLivenessCheck();

// Callbacks set from Dart to be called by JS
@JS('window.onBiometricSuccess')
external set onBiometricSuccess(JSFunction callback);

@JS('window.onBiometricError')
external set onBiometricError(JSFunction callback);

@JS('window.onBiometricProgress')
external set onBiometricProgress(JSFunction callback);
