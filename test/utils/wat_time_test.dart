import 'package:bomach_os/src/utils/wat_time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('WatTime Utility (Africa/Lagos, UTC+1)', () {
    test('converts UTC DateTime to West Africa Time (+1 hour)', () {
      final utc = DateTime.utc(2026, 9, 15, 4, 18, 38);
      final wat = WatTime.fromUtc(utc);

      expect(wat.year, 2026);
      expect(wat.month, 9);
      expect(wat.day, 15);
      expect(wat.hour, 5);
      expect(wat.minute, 18);
      expect(wat.second, 38);
      expect(wat.isUtc, isFalse);

      expect(DateFormat('hh:mm a').format(wat), '05:18 AM');
      expect(DateFormat('yyyy-MM-dd').format(wat), '2026-09-15');
    });

    test('parses naive backend timestamps without timezone as UTC and converts to WAT', () {
      // Backend returned naive UTC: "2026-09-15 04:18:38"
      final wat = WatTime.parse('2026-09-15 04:18:38');

      expect(wat.hour, 5);
      expect(wat.minute, 18);
      expect(wat.second, 38);
      expect(DateFormat('hh:mm a').format(wat), '05:18 AM');
    });

    test('parses ISO UTC timestamps with Z and converts to WAT', () {
      // Backend returned "2026-09-15T04:18:38Z"
      final wat = WatTime.parse('2026-09-15T04:18:38Z');

      expect(wat.hour, 5);
      expect(wat.minute, 18);
      expect(DateFormat('hh:mm a').format(wat), '05:18 AM');
    });

    test('parses timestamps with explicit offset and standardizes to WAT', () {
      final watFromUtcOffset = WatTime.parse('2026-09-15T04:18:38+00:00');
      final watFromWatOffset = WatTime.parse('2026-09-15T05:18:38+01:00');

      expect(watFromUtcOffset.hour, 5);
      expect(watFromUtcOffset.minute, 18);
      expect(watFromWatOffset.hour, 5);
      expect(watFromWatOffset.minute, 18);
    });

    test('applies server drift compensation to live now() in WAT', () {
      // If client device is 15 minutes slow relative to backend server
      const drift = Duration(minutes: 15);
      final rawWat = WatTime.now();
      final correctedWat = WatTime.now(drift);

      final diffMinutes = correctedWat.difference(rawWat).inMinutes;
      expect(diffMinutes, inInclusiveRange(14, 16));
    });

    test('handles date boundary rollover correctly (e.g. 23:30 UTC -> 00:30 next day WAT)', () {
      final lateUtc = DateTime.utc(2026, 9, 15, 23, 30, 0);
      final wat = WatTime.fromUtc(lateUtc);

      expect(wat.day, 16);
      expect(wat.hour, 0);
      expect(wat.minute, 30);
      expect(DateFormat('yyyy-MM-dd').format(wat), '2026-09-16');
      expect(DateFormat('hh:mm a').format(wat), '12:30 AM');
    });
  });
}
