class LanguageHelper {
  static const Map<String, String> _displayToCode = {
    'English (Nigeria)': 'en-GB',
    'English (UK)': 'en-GB',
    'English (US)': 'en-US',
    'French': 'fr',
    'Spanish': 'es',
  };

  static const Map<String, String> _codeToDisplay = {
    'en-GB': 'English (UK)',
    'en-US': 'English (US)',
    'fr': 'French',
    'es': 'Spanish',
  };

  /// Maps a human-readable display language string to a backend-supported ISO code.
  /// Falls back to 'en-GB' if not found.
  static String toCode(String? displayLanguage) {
    if (displayLanguage == null) return 'en-GB';
    return _displayToCode[displayLanguage] ?? 'en-GB';
  }

  /// Maps a backend-supported ISO code to a human-readable display language string.
  /// Falls back to 'English (UK)' if the code is empty or unknown.
  static String toDisplay(String? code) {
    if (code == null || code.isEmpty) return 'English (UK)';
    return _codeToDisplay[code] ?? 'English (UK)';
  }
}
