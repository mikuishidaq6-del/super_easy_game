# Google ログイン セットアップガイド

このドキュメントでは、**来ただけで成長するゲーム** アプリに Google アカウントログインを有効にするための設定手順を説明します。

---

## 前提条件

- [Google Cloud Console](https://console.cloud.google.com/) アカウントを持っていること
- Android ビルド用に **デバッグ用 SHA-1 フィンガープリント** を取得できること（後述）
- iOS ビルドには **Mac + Xcode** が必要です

---

## 共通手順：Google Cloud Console でプロジェクトを設定する

1. [Google Cloud Console](https://console.cloud.google.com/) を開く
2. 上部のプロジェクト選択欄から **「新しいプロジェクト」** を作成（または既存のプロジェクトを選択）
3. 左側メニューから **「APIとサービス」→「OAuth 同意画面」** を選択
4. ユーザーの種類として **「外部」** を選び、必要事項（アプリ名、サポートメールなど）を入力して保存
5. 左側メニューから **「APIとサービス」→「認証情報」** を選択

---

## Android の設定

### 1. SHA-1 フィンガープリントを取得する

ターミナルで以下のコマンドを実行してデバッグ用フィンガープリントを取得します。

```bash
# Mac / Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

出力の `SHA1:` の行をメモしてください。

### 2. OAuth クライアント ID（Android）を作成する

1. Cloud Console の **「認証情報」** ページで **「認証情報を作成」→「OAuthクライアントID」** をクリック
2. アプリケーションの種類: **「Android」** を選択
3. 以下を入力して保存：
   - **名前**: 任意（例: `super_easy_game Android`）
   - **パッケージ名**: `com.example.super_easy_game`
   - **SHA-1 証明書フィンガープリント**: 上記で取得した SHA-1 値

### 3. `google-services.json` を配置する

1. 作成後に表示される画面（または認証情報一覧）から **「google-services.json をダウンロード」** をクリック
2. ダウンロードしたファイルを以下のパスに配置します：

   ```
   game/android/app/google-services.json
   ```

### 4. `build.gradle.kts` のコメントを外す

`game/android/app/build.gradle.kts` を開き、以下のコメントアウトを解除します：

```kotlin
// 変更前
// id("com.google.gms.google-services")

// 変更後
id("com.google.gms.google-services")
```

また、ルートの `game/android/build.gradle.kts` に classpath の依存関係が必要な場合は追加してください（google-services プラグインのバージョンによります）：

```kotlin
// game/android/build.gradle.kts の allprojects ブロック内
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}
```

---

## iOS の設定

### 1. OAuth クライアント ID（iOS）を作成する

1. Cloud Console の **「認証情報」** ページで **「認証情報を作成」→「OAuthクライアントID」** をクリック
2. アプリケーションの種類: **「iOS」** を選択
3. 以下を入力して保存：
   - **名前**: 任意（例: `super_easy_game iOS`）
   - **バンドルID**: `com.example.superEasyGame`（Xcode のプロジェクト設定で確認してください）

### 2. `GoogleService-Info.plist` を配置する

1. 作成後に **「GoogleService-Info.plist をダウンロード」** をクリック
2. ダウンロードしたファイルを以下のパスに配置します：

   ```
   game/ios/Runner/GoogleService-Info.plist
   ```

   > **注意**: Xcode でプロジェクトを開いた際に、このファイルをプロジェクトツリーに追加してください（ドラッグ&ドロップで "Runner" グループ内に追加）。

### 3. `Info.plist` の URL スキームを更新する

`game/ios/Runner/Info.plist` の `CFBundleURLTypes` セクションにある URL スキームを、  
`GoogleService-Info.plist` に記載されている **`REVERSED_CLIENT_ID`** の値で置き換えます。

```xml
<!-- 変更前（プレースホルダー） -->
<string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>

<!-- 変更後（GoogleService-Info.plist の REVERSED_CLIENT_ID の値） -->
<!-- 例: com.googleusercontent.apps.123456789012-abcdefghijklmnopqrstuvwxyz012345 -->
<string>com.googleusercontent.apps.実際のCLIENT_IDをここに入力</string>
```

`REVERSED_CLIENT_ID` は `GoogleService-Info.plist` を開いて以下のキーで確認できます：

```xml
<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.xxxxxxxx-xxxx</string>
```

---

## 動作確認

設定が完了したら、アプリを起動してログイン画面の **「Googleでログイン」** ボタンをタップし、Google アカウントの選択画面が表示されることを確認してください。

| 確認項目 | 期待する動作 |
|----------|-------------|
| ボタンタップ | Google アカウント選択ダイアログが開く |
| アカウント選択後 | アプリにログインしてホーム画面へ遷移 |
| キャンセル時 | ログイン画面に戻り、エラーは表示されない |
| エラー発生時 | 「Googleログインに失敗しました。もう一度お試しください。」と表示 |

---

## トラブルシューティング

| 症状 | 原因と対処法 |
|------|-------------|
| `PlatformException: sign_in_failed` | `google-services.json` / `GoogleService-Info.plist` が正しい場所にない、または SHA-1 が違う |
| Android でダイアログが開かない | `build.gradle.kts` の `google-services` プラグインがコメントアウトされている |
| iOS でリダイレクトが戻らない | `Info.plist` の `CFBundleURLSchemes` に正しい `REVERSED_CLIENT_ID` が設定されていない |
| `ApiException: 10` | SHA-1 フィンガープリントが Cloud Console に登録されていない |
| `ApiException: 12500` | OAuth 同意画面が設定されていない |

---

## 参考リンク

- [google_sign_in パッケージ (pub.dev)](https://pub.dev/packages/google_sign_in)
- [Google Sign-In for Flutter (公式ドキュメント)](https://developers.google.com/identity/sign-in/android/start)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Flutter - Android の SHA-1 取得方法](https://developers.google.com/android/guides/client-auth)
