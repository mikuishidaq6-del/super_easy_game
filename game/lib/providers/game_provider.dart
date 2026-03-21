import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/game_models.dart';

/// ゲーム全体の状態を管理するProvider
class GameProvider extends ChangeNotifier {
  // --- ゲームバランス定数 ---
  static const int streakRecoveryCost = 15; // ストリーク回復に必要なコイン数
  static const int coinsPerStepCycle = 15;  // 歩数閾値達成ごとのコイン報酬

  // --- 永続化キー ---
  static const _keyExp = 'total_exp';
  static const _keyCoins = 'coins';
  static const _keyLoginStreak = 'login_streak';
  static const _keyLastLoginDate = 'last_login_date';
  static const _keyTodayFaceScale = 'today_face_scale';
  static const _keyTodaySteps = 'today_steps';
  static const _keyTodayActivities = 'today_activities';
  static const _keyGargleCount = 'today_gargle_count';
  static const _keyMedicineCount = 'today_medicine_count';
  static const _keyUsername = 'username';
  static const _keyPasswordHash = 'password_hash';
  static const _keyIsRegistered = 'is_registered';

  // --- 状態変数 ---
  int _totalExp = 0;
  int _coins = 0;
  int _loginStreak = 0;
  DateTime? _lastLoginDate;
  FaceScale? _todayFaceScale;
  int _todaySteps = 0;
  Set<String> _todayActivities = {};
  int _gargleCount = 0;
  int _medicineCount = 0;
  bool _initialized = false;
  String _username = '';
  String _passwordHash = '';
  bool _isRegistered = false;
  bool _isLoggedIn = false;

  // --- Getters ---
  int get totalExp => _totalExp;
  int get coins => _coins;
  int get loginStreak => _loginStreak;
  FaceScale? get todayFaceScale => _todayFaceScale;
  int get todaySteps => _todaySteps;
  Set<String> get todayActivities => Set.unmodifiable(_todayActivities);
  int get gargleCount => _gargleCount;
  int get medicineCount => _medicineCount;
  bool get initialized => _initialized;
  bool get hasTodayFaceInput => _todayFaceScale != null;
  String get username => _username;
  bool get isRegistered => _isRegistered;
  bool get isLoggedIn => _isLoggedIn;

  CharacterStage get characterStage => CharacterStage.fromExp(_totalExp);

  int get expToNextLevel {
    final stage = characterStage;
    if (stage == CharacterStage.legend) return 0;
    return stage.nextLevelExp - _totalExp;
  }

  double get levelProgress {
    final stage = characterStage;
    if (stage == CharacterStage.legend) return 1.0;
    final prevExp = _prevLevelExp(stage);
    final span = stage.nextLevelExp - prevExp;
    if (span <= 0) return 1.0;
    return (_totalExp - prevExp) / span;
  }

  int _prevLevelExp(CharacterStage stage) {
    switch (stage) {
      case CharacterStage.egg:
        return 0;
      case CharacterStage.baby:
        return 100;
      case CharacterStage.child:
        return 300;
      case CharacterStage.teen:
        return 700;
      case CharacterStage.adult:
        return 1500;
      case CharacterStage.legend:
        return 3000;
    }
  }

  /// 初期化（アプリ起動時に呼ぶ）
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _totalExp = prefs.getInt(_keyExp) ?? 0;
    _coins = prefs.getInt(_keyCoins) ?? 0;
    _loginStreak = prefs.getInt(_keyLoginStreak) ?? 0;

    final lastLoginStr = prefs.getString(_keyLastLoginDate);
    if (lastLoginStr != null) {
      _lastLoginDate = DateTime.tryParse(lastLoginStr);
    }

    final faceScaleValue = prefs.getInt(_keyTodayFaceScale);
    if (faceScaleValue != null) {
      _todayFaceScale = FaceScale.values.firstWhere(
        (f) => f.value == faceScaleValue,
        orElse: () => FaceScale.neutral,
      );
    }

    _todaySteps = prefs.getInt(_keyTodaySteps) ?? 0;
    final activitiesJson = prefs.getString(_keyTodayActivities);
    if (activitiesJson != null) {
      final List<dynamic> list = jsonDecode(activitiesJson);
      _todayActivities = list.cast<String>().toSet();
    }
    _gargleCount = prefs.getInt(_keyGargleCount) ?? 0;
    _medicineCount = prefs.getInt(_keyMedicineCount) ?? 0;

    _username = prefs.getString(_keyUsername) ?? '';
    _passwordHash = prefs.getString(_keyPasswordHash) ?? '';
    _isRegistered = prefs.getBool(_keyIsRegistered) ?? false;

    _initialized = true;
    notifyListeners();
  }

  /// 新規ユーザー登録
  Future<bool> register(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    _username = username.trim();
    _passwordHash = _hashPassword(password);
    _isRegistered = true;
    _isLoggedIn = true;
    await prefs.setString(_keyUsername, _username);
    await prefs.setString(_keyPasswordHash, _passwordHash);
    await prefs.setBool(_keyIsRegistered, true);
    notifyListeners();
    return true;
  }

  /// ログイン
  Future<bool> login(String username, String password) async {
    if (username.trim() != _username) return false;
    if (_hashPassword(password) != _passwordHash) return false;
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  /// ログアウト
  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  /// パスワードの簡易ハッシュ（ローカル端末専用アプリ向け）
  ///
  /// 注意: このハッシュ関数は個人端末専用アプリのプライバシー保護のみを目的と
  /// しており、暗号学的な安全性は提供しません。サーバー通信や複数ユーザーが
  /// 共有する環境では使用しないでください。
  String _hashPassword(String password) {
    // XOR-fold + base64 encode: 個人端末でのプライバシー目的のみ
    final bytes = utf8.encode(password);
    final hash = List<int>.filled(16, 0);
    for (var i = 0; i < bytes.length; i++) {
      hash[i % 16] ^= bytes[i];
    }
    return base64Encode(hash);
  }

  /// フェイスを選択して経験値を加算
  Future<int> selectFaceScale(FaceScale face) async {
    final today = _todayString();
    final isNewDay = _lastLoginDate == null ||
        DateFormat('yyyy-MM-dd').format(_lastLoginDate!) != today;

    int expGained = 0;
    int streakBonus = 0;

    if (isNewDay) {
      // ログインストリーク更新
      final yesterday = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1)));
      if (_lastLoginDate != null &&
          DateFormat('yyyy-MM-dd').format(_lastLoginDate!) == yesterday) {
        _loginStreak++;
      } else if (_lastLoginDate == null) {
        _loginStreak = 1;
      } else {
        _loginStreak = 1; // ストリーク途切れ
      }

      // ベース経験値（ログインボーナス）
      expGained = (20 * face.expMultiplier).round();

      // 連続ログインボーナス（7日ごとに大ボーナス）
      if (_loginStreak % 7 == 0) {
        streakBonus = 50;
      } else if (_loginStreak > 1) {
        streakBonus = (_loginStreak * 2).clamp(0, 30);
      }
      expGained += streakBonus;

      _lastLoginDate = DateTime.now();
      _todayFaceScale = face;
      // 新しい日のアクティビティをリセット
      _todayActivities = {};
      _gargleCount = 0;
      _medicineCount = 0;
    } else {
      // 同じ日は再入力のみ（経験値は初回のみ）
      _todayFaceScale = face;
      expGained = 0;
    }

    _totalExp += expGained;
    await _save();
    notifyListeners();
    return expGained;
  }

  /// 歩数を手動入力して経験値とコインを加算
  Future<Map<String, int>> addSteps(int steps) async {
    final threshold = _todayFaceScale?.stepThreshold ?? 100;
    final prevCycles = _todaySteps ~/ threshold;
    _todaySteps += steps;
    final newCycles = _todaySteps ~/ threshold;
    final cyclesGained = newCycles - prevCycles;

    final coinsGained = cyclesGained * coinsPerStepCycle;
    final expGained = cyclesGained * 10;

    _coins += coinsGained;
    _totalExp += expGained;

    await _save();
    notifyListeners();
    return {'exp': expGained, 'coins': coinsGained};
  }

  /// コインを使って連続ログインボーナスを回復
  Future<bool> useCoinsForStreakRecovery() async {
    if (_coins < streakRecoveryCost) return false;
    _coins -= streakRecoveryCost;
    // ストリークを復活させる（途切れた日を1日戻す）
    if (_loginStreak == 1) _loginStreak = 2;
    await _save();
    notifyListeners();
    return true;
  }

  /// 健康アクティビティを記録
  Future<int> recordActivity(HealthActivity activity) async {
    // うがいは1日5回まで
    if (activity.id == 'gargle') {
      if (_gargleCount >= 5) return 0;
      _gargleCount++;
    } else if (activity.id == 'medicine') {
      // お薬は1日に複数回記録可能（最大3回）
      if (_medicineCount >= 3) return 0;
      _medicineCount++;
    } else {
      // その他は1日1回
      if (_todayActivities.contains(activity.id)) return 0;
      _todayActivities.add(activity.id);
    }

    _totalExp += activity.expReward;
    _coins += activity.coinReward;

    await _save();
    notifyListeners();
    return activity.expReward;
  }

  bool isActivityDone(String activityId) {
    if (activityId == 'gargle') return _gargleCount >= 5;
    if (activityId == 'medicine') return _medicineCount >= 3;
    return _todayActivities.contains(activityId);
  }

  int activityCount(String activityId) {
    if (activityId == 'gargle') return _gargleCount;
    if (activityId == 'medicine') return _medicineCount;
    return _todayActivities.contains(activityId) ? 1 : 0;
  }

  String _todayString() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyExp, _totalExp);
    await prefs.setInt(_keyCoins, _coins);
    await prefs.setInt(_keyLoginStreak, _loginStreak);
    if (_lastLoginDate != null) {
      await prefs.setString(
          _keyLastLoginDate, _lastLoginDate!.toIso8601String());
    }
    if (_todayFaceScale != null) {
      await prefs.setInt(_keyTodayFaceScale, _todayFaceScale!.value);
    }
    await prefs.setInt(_keyTodaySteps, _todaySteps);
    await prefs.setString(
        _keyTodayActivities, jsonEncode(_todayActivities.toList()));
    await prefs.setInt(_keyGargleCount, _gargleCount);
    await prefs.setInt(_keyMedicineCount, _medicineCount);
  }
}
