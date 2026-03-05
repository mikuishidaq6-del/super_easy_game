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

  /// フェイススケールに応じた経験値ボーナス（1〜1.5倍）
  double get expMultiplier {
    switch (this) {
      case FaceScale.veryBad:
        return 1.0;
      case FaceScale.bad:
        return 1.1;
      case FaceScale.neutral:
        return 1.2;
      case FaceScale.good:
        return 1.3;
      case FaceScale.veryGood:
        return 1.5;
    }
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

  static CharacterStage fromExp(int exp) {
    if (exp < 100) return CharacterStage.egg;
    if (exp < 300) return CharacterStage.baby;
    if (exp < 700) return CharacterStage.child;
    if (exp < 1500) return CharacterStage.teen;
    if (exp < 3000) return CharacterStage.adult;
    return CharacterStage.legend;
  }

  int get nextLevelExp {
    switch (this) {
      case CharacterStage.egg:
        return 100;
      case CharacterStage.baby:
        return 300;
      case CharacterStage.child:
        return 700;
      case CharacterStage.teen:
        return 1500;
      case CharacterStage.adult:
        return 3000;
      case CharacterStage.legend:
        return 3000;
    }
  }
}

/// 健康アクティビティ
class HealthActivity {
  final String id;
  final String name;
  final String emoji;
  final int expReward;
  final int coinReward;

  const HealthActivity({
    required this.id,
    required this.name,
    required this.emoji,
    required this.expReward,
    required this.coinReward,
  });

  static const List<HealthActivity> all = [
    HealthActivity(id: 'teeth', name: '歯磨き', emoji: '🪥', expReward: 10, coinReward: 1),
    HealthActivity(id: 'gargle', name: 'うがい', emoji: '🫧', expReward: 5, coinReward: 1),
    HealthActivity(id: 'shower', name: 'シャワー・体拭き', emoji: '🚿', expReward: 20, coinReward: 2),
    HealthActivity(id: 'medicine', name: 'お薬のめたね', emoji: '💊', expReward: 15, coinReward: 2),
  ];
}
