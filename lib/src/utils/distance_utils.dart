class DistanceUtils {
  /// Formats a distance in meters into human-readable text:
  /// - Distances >= 1,000 meters are displayed in kilometers (e.g. "7.1 kilometers", "1 kilometer").
  /// - Distances < 1,000 meters are displayed with "meters" in full (e.g. "250 meters", "1 meter").
  static String format(num meters, {bool useAbbreviation = false}) {
    final nonNegative = meters < 0 ? 0 : meters;
    if (nonNegative >= 1000) {
      final km = nonNegative / 1000.0;
      final str = km.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      if (useAbbreviation) return '$str km';
      return '$str ${str == '1' ? 'kilometer' : 'kilometers'}';
    } else {
      final m = nonNegative.round();
      if (useAbbreviation) return '$m m';
      return '$m ${m == 1 ? 'meter' : 'meters'}';
    }
  }

  /// Replaces distance substrings like "7115m" or "25m" in a message with
  /// human-readable distance representations (e.g. "7.1 kilometers", "25 meters").
  static String formatInText(String text, {bool useAbbreviation = false}) {
    return text.replaceAllMapped(RegExp(r'(\d+(?:\.\d+)?)\s*m\b'), (match) {
      final val = num.tryParse(match.group(1) ?? '');
      if (val != null) {
        return format(val, useAbbreviation: useAbbreviation);
      }
      return match.group(0)!;
    });
  }
}
