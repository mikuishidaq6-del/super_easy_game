import 'game_models.dart';
import 'data_loader.dart';

/// ゲームの判定関数をまとめたクラス
class Calculations {
  /// 歩数からEXPを取得する
  /// 使い方: final exp = await Calculations.getExpFromSteps(500);
  static Future<int> getExpFromSteps(int steps) async {
    // StepConfigの上限を適用
    final clampedSteps = steps.clamp(0, StepConfig.stepMax);
    final rewards = await DataLoader.loadStepRewards();
    for (final reward in rewards) {
      if (clampedSteps >= reward['min']! && clampedSteps <= reward['max']!) {
        return reward['exp']!;
      }
    }
    return 0;
  }

  /// 歩数からキャラクター状態を取得する
  /// 使い方: final state = await Calculations.getStateFromSteps(500);
  static Future<String> getStateFromSteps(int steps) async {
    final states = await DataLoader.loadCharacterStates();
    for (final row in states) {
      if (steps >= row['min'] && steps <= row['max']) {
        return row['state'];
      }
    }
    return 'ふつう';
  }

  /// 経験値からレベルを取得する
  /// 使い方: final level = await Calculations.getLevelFromExp(800);
  static Future<int> getLevelFromExp(int exp) async {
    final table = await DataLoader.loadLevelTable();
    int level = 1;
    for (final entry in table.entries) {
      if (exp >= entry.key) {
        level = entry.value;
      }
    }
    return level;
  }
}