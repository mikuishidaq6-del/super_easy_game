# 来ただけで成長するゲーム 🌸

血液がん患者をそっと支える育成ゲームのプロトタイプです。

## コンセプト

体調が悪い日でも負担なく使える設計。来るだけでキャラクターが成長します。

## 機能

- **フェイス入力**: 5段階のフェイススケールで今日の調子を1タップ入力
- **キャラクター成長**: ログインするだけで経験値獲得・キャラクターが成長
- **連続ログインボーナス**: 毎日来るとストリークボーナス
- **歩数連動**: 手動で歩数を入力するとコイン・経験値獲得（体調で閾値変動）
- **健康記録**: 歯磨き・うがい（5回）・シャワー・お薬管理
- **コインシステム**: 15コインでストリーク途切れを回復

## セットアップ

### 前提条件

- [Flutter](https://flutter.dev/) 3.0.0 以上がインストールされていること
- Dart SDK 3.0.0 以上

### 実行手順

```bash
cd game
flutter pub get
flutter run
```

### テスト実行

```bash
cd game
flutter test
```

## プロジェクト構造

```
game/
├── lib/
│   ├── main.dart                    # アプリエントリーポイント
│   ├── models/
│   │   └── game_models.dart         # データモデル（FaceScale, CharacterStage等）
│   ├── providers/
│   │   └── game_provider.dart       # 状態管理（SharedPreferences永続化）
│   └── screens/
│       ├── face_input_screen.dart   # フェイス入力画面
│       ├── character_reaction_screen.dart  # キャラクター反応画面
│       ├── home_screen.dart         # ホーム画面
│       ├── step_input_screen.dart   # 歩数入力画面（手動入力）
│       └── activity_screen.dart    # 健康記録画面
└── test/
    └── game_models_test.dart        # モデルユニットテスト
```

## 仕様

詳細は [specifications/General.md](specifications/General.md) を参照してください。

## プロトタイプ特記事項

- 歩数は手動入力（センサー連携なし）
- データはデバイス内に保存（SharedPreferences使用）

