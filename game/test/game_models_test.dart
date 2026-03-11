import 'package:flutter_test/flutter_test.dart';
import 'package:super_easy_game/models/game_models.dart';

void main() {
  group('FaceScale tests', () {
    test('FaceScale has 5 values', () {
      expect(FaceScale.values.length, 5);
    });

    test('FaceScale values are 1-5', () {
      expect(FaceScale.veryBad.value, 1);
      expect(FaceScale.bad.value, 2);
      expect(FaceScale.neutral.value, 3);
      expect(FaceScale.good.value, 4);
      expect(FaceScale.veryGood.value, 5);
    });

    test('stepThreshold changes by face scale', () {
      expect(FaceScale.veryBad.stepThreshold, 30);
      expect(FaceScale.neutral.stepThreshold, 100);
      expect(FaceScale.veryGood.stepThreshold, 100);
    });

    test('expMultiplier increases with face scale', () {
      for (int i = 0; i < FaceScale.values.length - 1; i++) {
        expect(
          FaceScale.values[i].expMultiplier <=
              FaceScale.values[i + 1].expMultiplier,
          isTrue,
        );
      }
    });
  });

  group('CharacterStage tests', () {
    test('fromExp returns egg for 0 exp', () {
      expect(CharacterStage.fromExp(0), CharacterStage.egg);
    });

    test('fromExp returns baby for 100 exp', () {
      expect(CharacterStage.fromExp(100), CharacterStage.baby);
    });

    test('fromExp returns legend for 3000+ exp', () {
      expect(CharacterStage.fromExp(3000), CharacterStage.legend);
      expect(CharacterStage.fromExp(9999), CharacterStage.legend);
    });

    test('Character stages have correct order', () {
      expect(CharacterStage.egg.level, 0);
      expect(CharacterStage.baby.level, 1);
      expect(CharacterStage.legend.level, 5);
    });
  });

  group('HealthActivity tests', () {
    test('All activities are defined', () {
      expect(HealthActivity.all.length, 4);
    });

    test('Gargle activity has correct id', () {
      final gargle = HealthActivity.all.firstWhere((a) => a.id == 'gargle');
      expect(gargle.name, 'うがい');
    });

    test('Medicine activity has exp reward', () {
      final medicine =
          HealthActivity.all.firstWhere((a) => a.id == 'medicine');
      expect(medicine.expReward, greaterThan(0));
    });
  });
}
