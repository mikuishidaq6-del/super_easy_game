// モデル：ゲームの状態を管理するデータモデル

/// フェイススケール（1〜5の5段階）
enum FaceScale {
  veryBad(1, '😞', 'とても辛い', '今日は休む日でも大丈夫だよ'),
  bad(2, '😕', '辛い', 'ゆっくりでいいよ'),
  neutral(3, '😐', '普通', '今日も来てくれてありがとう'),
  good(4, '🙂', 'まあまあ良い', 'いい感じだね！'),
  veryGood(5, '😄', 'とても良い', 'いい日だね！一緒に楽しもう！');

  const FaceScale(this.value, this.emoji, this.label, this.characterMessage);
  final int value;
  final String emoji;
  final String label;
  final String characterMessage;

  /// フェイススケールに応じた経験値ボーナス
  /// パターンB：どの体調でも同じEXP（来ただけでOKの精神）
  double get expMultiplier {
    return 1.0;
  }

  /// 体調に応じた歩数の閾値（100歩ごとのコイン獲得ベース）
  int get stepThreshold {
    switch (this) {
      case FaceScale.veryBad:
        return 30; // 体調が悪い日は30歩でOK
      case FaceScale.bad:
        return 50;
      case FaceScale.neutral:
        return 100;
      case FaceScale.good:
        return 100;
      case FaceScale.veryGood:
        return 100;
    }
  }
}

/// キャラクターの成長段階
enum CharacterStage {
  egg(0, 'たまご', '🥚'),
  baby(1, 'ひよこ', '🐣'),
  child(2, 'こども', '🐥'),
  teen(3, 'せいちょう', '🐔'),
  adult(4, 'おとな', '🦅'),
  legend(5, 'でんせつ', '🦄');

  const CharacterStage(this.level, this.name, this.emoji);
  final int level;
  final String name;
  final String emoji;

  /// level_table.csvのtotal_expに合わせた閾値
  /// egg  : L1〜L5   (0〜750)
  /// baby : L5〜L15  (750〜9650)
  /// child: L15〜L30 (9650〜33900)
  /// teen : L30〜L50 (33900〜94700)
  /// adult: L50〜L80 (94700〜323650)
  /// legend: L80〜   (323650〜)
  static CharacterStage fromExp(int exp) {
    if (exp < 750) return CharacterStage.egg;      // L1〜L5
    if (exp < 9650) return CharacterStage.baby;    // L5〜L15
    if (exp < 33900) return CharacterStage.child;  // L15〜L30
    if (exp < 94700) return CharacterStage.teen;   // L30〜L50
    if (exp < 323650) return CharacterStage.adult; // L50〜L80
    return CharacterStage.legend;                  // L80〜
  }

  int get nextLevelExp {
    switch (this) {
      case CharacterStage.egg:
        return 750;
      case CharacterStage.baby:
        return 9650;
      case CharacterStage.child:
        return 33900;
      case CharacterStage.teen:
        return 94700;
      case CharacterStage.adult:
        return 323650;
      case CharacterStage.legend:
        return 323650;
    }
  }
}

/// ユーザーデータ
class User {
  int level;
  int exp;
  int coin;
  int streakDays;
  String lastLoginDate;

  User({
    required this.level,
    required this.exp,
    required this.coin,
    required this.streakDays,
    required this.lastLoginDate,
  });
}

/// 日々の記録
class DailyRecord {
  String date;
  int faceScale;
  int steps;
  bool toothBrushed;
  int gargleCount;
  bool bodyCare;
  bool shower;
  bool medicationTaken;

  DailyRecord({
    required this.date,
    required this.faceScale,
    required this.steps,
    required this.toothBrushed,
    required this.gargleCount,
    required this.bodyCare,
    required this.shower,
    required this.medicationTaken,
  });
}

/// アイテムデータ
class Item {
  String itemId;
  String itemName;
  int ownedCount;

  Item({
    required this.itemId,
    required this.itemName,
    required this.ownedCount,
  });
}

/// 健康アクティビティ
/// action_rewards.csvに合わせた値
class HealthActivity {
  final String id;
  final String name;
  final String emoji;
  final int expReward;
  final int coinReward;
  final int maxCount; // 1日の最大実施回数

  const HealthActivity({
    required this.id,
    required this.name,
    required this.emoji,
    required this.expReward,
    required this.coinReward,
    required this.maxCount,
  });

  static const List<HealthActivity> all = [
    HealthActivity(id: 'teeth', name: '歯磨き', emoji: '🪥', expReward: 10, coinReward: 1, maxCount: 1),
    HealthActivity(id: 'gargle', name: 'うがい', emoji: '🫧', expReward: 5, coinReward: 1, maxCount: 5),
    HealthActivity(id: 'body_care', name: '体拭き', emoji: '🧴', expReward: 10, coinReward: 1, maxCount: 1),
    HealthActivity(id: 'shower', name: 'シャワー', emoji: '🚿', expReward: 15, coinReward: 2, maxCount: 1),
    HealthActivity(id: 'medicine', name: 'お薬のめたね', emoji: '💊', expReward: 15, coinReward: 2, maxCount: 3),
  ];
}

/// 歩数設定
class StepConfig {
  /// 歩数の上限値（これ以上はカウントしない）
  static const int stepMax = 10000;

  /// 未取得時のデフォルト歩数
  static const int stepDefault = 0;

  /// 同じ日付のデータは上書きする
  static const bool overwriteSameDate = true;
}