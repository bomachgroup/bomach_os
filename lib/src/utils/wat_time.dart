/// Utility for West Africa Time (WAT / Africa/Lagos, UTC+1).
///
/// Nigeria and West Africa operate permanently on UTC+1 (WAT) year-round
/// without Daylight Saving Time. This utility ensures that attendance,
/// clock-in/out, live clocks, and history records ALWAYS display and register
/// in West Africa Time regardless of the client machine's local timezone or clock tampering.
class WatTime {
  WatTime._();

  /// West Africa Time is UTC+1.
  static const Duration offset = Duration(hours: 1);

  /// Converts any UTC or local [DateTime] to West Africa Time (UTC+1).
  ///
  /// Returns a local [DateTime] whose [year], [month], [day], [hour], [minute], [second]
  /// reflect the West Africa Time instant. This guarantees that standard formatters
  /// (e.g. `DateFormat('hh:mm a')`, `DateFormat('yyyy-MM-dd')`) format the exact
  /// West Africa Time without relying on or being skewed by the host device timezone.
  static DateTime fromUtc(DateTime utc) {
    final pureUtc = utc.isUtc ? utc : utc.toUtc();
    final wat = pureUtc.add(offset);
    return DateTime(
      wat.year,
      wat.month,
      wat.day,
      wat.hour,
      wat.minute,
      wat.second,
      wat.millisecond,
      wat.microsecond,
    );
  }

  /// Converts any [DateTime] (local, UTC, or unspecified) into West Africa Time.
  static DateTime toWat(DateTime dt) {
    return fromUtc(dt.toUtc());
  }

  /// Current time in West Africa Time (WAT, UTC+1), based on system UTC
  /// plus any verified server drift compensation.
  static DateTime now([Duration serverDrift = Duration.zero]) {
    final utcNow = DateTime.now().toUtc().add(serverDrift);
    return fromUtc(utcNow);
  }

  /// Parses an ISO or SQL timestamp string from backend (treated as UTC)
  /// and converts it directly to West Africa Time (UTC+1).
  static DateTime parse(dynamic raw) {
    if (raw == null) return now();
    if (raw is DateTime) return toWat(raw);
    final str = raw.toString().trim();
    if (str.isEmpty) return now();

    String normalizedStr = str.replaceFirst(' ', 'T');
    final hasTimezone = normalizedStr.endsWith('Z') ||
        normalizedStr.endsWith('z') ||
        (normalizedStr.contains(':') &&
            RegExp(r'[+-]\d{2}(:?\d{2})?$').hasMatch(normalizedStr));

    if (!hasTimezone) {
      normalizedStr = '${normalizedStr}Z';
    }

    final parsed = DateTime.tryParse(normalizedStr) ??
        DateTime.tryParse(str) ??
        DateTime.now().toUtc();
    return toWat(parsed);
  }
}
