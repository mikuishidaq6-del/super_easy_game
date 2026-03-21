import 'package:flutter_test/flutter_test.dart';
import 'package:super_easy_game/models/Calculations.dart';

void main() {
  group('step normalization', () {
    test('12000 -> 10000 (upper cap)', () {
      expect(Calculations.normalizeSteps(12000), 10000);
    });

    test('8000 -> 8000 (within range)', () {
      expect(Calculations.normalizeSteps(8000), 8000);
    });

    test('null -> 0', () {
      expect(Calculations.normalizeSteps(null), 0);
    });

    test('negative -> 0', () {
      expect(Calculations.normalizeSteps(-100), 0);
    });
  });

  group('valid steps to exp conversion', () {
    final rewards = <Map<String, int>>[
      {'min': 0, 'max': 99, 'exp': 5},
      {'min': 100, 'max': 299, 'exp': 15},
      {'min': 300, 'max': 599, 'exp': 30},
      {'min': 600, 'max': 999, 'exp': 50},
      {'min': 1000, 'max': 2000, 'exp': 70},
      {'min': 2001, 'max': 10000, 'exp': 100},
    ];

    test('0 steps returns lower-tier exp', () {
      expect(Calculations.getExpFromValidSteps(0, rewards), 5);
    });

    test('8000 steps returns high-tier exp', () {
      expect(Calculations.getExpFromValidSteps(8000, rewards), 100);
    });

    test('12000 valid steps input is capped to 10000 then converted', () {
      expect(Calculations.getExpFromValidSteps(12000, rewards), 100);
    });
  });
}
