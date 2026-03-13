import 'package:flutter/services.dart';
import 'game_models.dart';

/// CSVファイルを読み込んでgame_models.dartの形に変換するクラス
class DataLoader {
  /// CSVの1行をカンマで分割するヘルパー
  static List<String> _parseLine(String line) {
    return line.split(',').map((e) => e.trim()).toList();
  }

  /// レベルテーブルを読み込む
  /// 戻り値: { total_exp: level } のマップ
  /// 使い方: final table = await DataLoader.loadLevelTable();
  static Future<Map<int, int>> loadLevelTable() async {
    final raw = await rootBundle.loadString('data/level_table.csv');
    final lines = raw.trim().split('\n');
    final Map<int, int> result = {};

    for (int i = 1; i < lines.length; i++) {
      final cols = _parseLine(lines[i]);
      if (cols.length < 3) continue;
      final level = int.tryParse(cols[0]) ?? 0;
      final totalExp = int.tryParse(cols[2]) ?? 0;
      result[totalExp] = level;
    }
    return result;
  }

  /// 歩数報酬テーブルを読み込む
  /// 戻り値: { 'min': int, 'max': int, 'exp': int } のリスト
  /// 使い方: final rewards = await DataLoader.loadStepRewards();
  static Future<List<Map<String, int>>> loadStepRewards() async {
    final raw = await rootBundle.loadString('data/step_rewards.csv');
    final lines = raw.trim().split('\n');
    final List<Map<String, int>> result = [];

    for (int i = 1; i < lines.length; i++) {
      final cols = _parseLine(lines[i]);
      if (cols.length < 3) continue;
      result.add({
        'min': int.tryParse(cols[0]) ?? 0,
        'max': int.tryParse(cols[1]) ?? 0,
        'exp': int.tryParse(cols[2]) ?? 0,
      });
    }
    return result;
  }

  /// キャラクター状態テーブルを読み込む
  /// 戻り値: { 'min': int, 'max': int, 'state': String } のリスト
  /// 使い方: final states = await DataLoader.loadCharacterStates();
  static Future<List<Map<String, dynamic>>> loadCharacterStates() async {
    final raw = await rootBundle.loadString('data/character_state.csv');
    final lines = raw.trim().split('\n');
    final List<Map<String, dynamic>> result = [];

    for (int i = 1; i < lines.length; i++) {
      final cols = _parseLine(lines[i]);
      if (cols.length < 3) continue;
      result.add({
        'min': int.tryParse(cols[0]) ?? 0,
        'max': int.tryParse(cols[1]) ?? 0,
        'state': cols[2],
      });
    }
    return result;
  }

  /// 行動報酬テーブルを読み込む
  /// 戻り値: HealthActivityのリスト
  /// 使い方: final activities = await DataLoader.loadActionRewards();
  static Future<List<Map<String, dynamic>>> loadActionRewards() async {
    final raw = await rootBundle.loadString('data/action_rewards.csv');
    final lines = raw.trim().split('\n');
    final List<Map<String, dynamic>> result = [];

    for (int i = 1; i < lines.length; i++) {
      final cols = _parseLine(lines[i]);
      if (cols.length < 3) continue;
      result.add({
        'action': cols[0],
        'exp_reward': int.tryParse(cols[1]) ?? 0,
        'max_count': int.tryParse(cols[2]) ?? 1,
      });
    }
    return result;
  }

  /// 歩数からEXPを取得する
  /// 使い方: final exp = await DataLoader.getExpFromSteps(500);
  static Future<int> getExpFromSteps(int steps) async {
    // StepConfigの上限を適用
    final clampedSteps = steps.clamp(0, StepConfig.stepMax);
    final rewards = await loadStepRewards();
    for (final reward in rewards) {
      if (clampedSteps >= reward['min']! && clampedSteps <= reward['max']!) {
        return reward['exp']!;
      }
    }
    return 0;
  }

  /// 歩数からキャラクター状態を取得する
  /// 使い方: final state = await DataLoader.getStateFromSteps(500);
  static Future<String> getStateFromSteps(int steps) async {
    final states = await loadCharacterStates();
    for (final row in states) {
      if (steps >= row['min'] && steps <= row['max']) {
        return row['state'];
      }
    }
    return 'ふつう';
  }
}