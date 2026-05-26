class LanguageHelper {
  static const Map<String, String> _displayToCode = {
    'english (nigeria)': 'en-GB',
    'english (uk)': 'en-GB',
    'english (us)': 'en-US',
    'french': 'fr',
    'spanish': 'es',
  };

  static const Map<String, String> _codeToDisplay = {
    'en-gb': 'English (UK)',
    'en-us': 'English (US)',
    'fr': 'French',
    'es': 'Spanish',
  };

  /// Maps a human-readable display language string to a backend-supported ISO code (case-insensitive).
  /// Falls back to 'en-GB' if not found.
  static String toCode(String? displayLanguage) {
    if (displayLanguage == null) return 'en-GB';
    final normalized = displayLanguage.trim().toLowerCase();
    return _displayToCode[normalized] ?? 'en-GB';
  }

  /// Maps a backend-supported ISO code to a human-readable display language string (case-insensitive).
  /// Falls back to 'English (UK)' if the code is empty or unknown.
  static String toDisplay(String? code) {
    if (code == null || code.isEmpty) return 'English (UK)';
    final normalized = code.trim().toLowerCase();
    return _codeToDisplay[normalized] ?? 'English (UK)';
  }
}
