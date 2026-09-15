import 'package:flutter_test/flutter_test.dart';
import 'package:bomach_os/src/utils/distance_utils.dart';

void main() {
  group('DistanceUtils.format', () {
    test('formats distance < 1000m with "meters" in full', () {
      expect(DistanceUtils.format(0), '0 meters');
      expect(DistanceUtils.format(1), '1 meter');
      expect(DistanceUtils.format(25), '25 meters');
      expect(DistanceUtils.format(250), '250 meters');
      expect(DistanceUtils.format(999), '999 meters');
    });

    test('formats distance >= 1000m in kilometers', () {
      expect(DistanceUtils.format(1000), '1 kilometer');
      expect(DistanceUtils.format(1000.0), '1 kilometer');
      expect(DistanceUtils.format(1200), '1.2 kilometers');
      expect(DistanceUtils.format(7115), '7.1 kilometers');
      expect(DistanceUtils.format(10500), '10.5 kilometers');
    });

    test('supports optional abbreviated mode if requested', () {
      expect(DistanceUtils.format(250, useAbbreviation: true), '250 m');
      expect(DistanceUtils.format(7115, useAbbreviation: true), '7.1 km');
    });
  });

  group('DistanceUtils.formatInText', () {
    test('replaces single-letter "m" with full units in messages', () {
      const input = 'You are 7115m away from your workspace "Office". Get within range to clock in.';
      final output = DistanceUtils.formatInText(input);
      expect(output, 'You are 7.1 kilometers away from your workspace "Office". Get within range to clock in.');
    });

    test('replaces smaller meter values with "meters" in full', () {
      const input = 'You are 150m from "Office" (allowed ~25m). Move closer and tap Retry.';
      final output = DistanceUtils.formatInText(input);
      expect(output, 'You are 150 meters from "Office" (allowed ~25 meters). Move closer and tap Retry.');
    });
  });
}
