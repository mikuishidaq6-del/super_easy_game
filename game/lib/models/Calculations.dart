import 'game_models.dart';
import 'data_loader.dart';

/// ゲームの判定関数をまとめたクラス
class Calculations {
  /// 生歩数をゲーム内で使う有効歩数に正規化する
  ///
  /// 仕様:
  /// - validSteps = min(rawSteps, 10000)
  /// - rawSteps が null の場合は 0
  /// - rawSteps が負の値の場合は 0
  static int normalizeSteps(int? rawSteps) {
    if (rawSteps == null || rawSteps < 0) {
      return StepConfig.stepDefault;
    }
    return rawSteps.clamp(0, StepConfig.stepMax).toInt();
  }

  /// 有効歩数からEXPを計算する
  ///
  /// `validSteps` には念のため再度上限・下限を適用する。
  static int getExpFromValidSteps(
    int validSteps,
    List<Map<String, int>> rewards,
  ) {
    final normalizedValidSteps = normalizeSteps(validSteps);
    for (final reward in rewards) {
      if (normalizedValidSteps >= reward['min']! &&
          normalizedValidSteps <= reward['max']!) {
        return reward['exp']!;
      }
    }
    return 0;
  }

  /// 歩数からEXPを取得する
  /// 使い方: final exp = await Calculations.getExpFromSteps(500);
  static Future<int> getExpFromSteps(int? rawSteps) async {
    final validSteps = normalizeSteps(rawSteps);
    final rewards = await DataLoader.loadStepRewards();
    return getExpFromValidSteps(validSteps, rewards);
  }

  /// 歩数からキャラクター状態を取得する
  /// 使い方: final state = await Calculations.getStateFromSteps(500);
  static Future<String> getStateFromSteps(int steps) async {
    final validSteps = normalizeSteps(steps);
    final states = await DataLoader.loadCharacterStates();
    for (final row in states) {
      if (validSteps >= row['min'] && validSteps <= row['max']) {
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