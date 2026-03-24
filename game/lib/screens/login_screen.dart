import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

/// ログイン・新規登録画面
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 未登録の場合は最初から登録モードにする
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = context.read<GameProvider>();
      if (!game.isRegistered) {
        setState(() {
          _isRegisterMode = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final game = context.read<GameProvider>();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    bool success;
    if (_isRegisterMode) {
      success = await game.register(username, password);
      if (!success && mounted) {
        setState(() {
          _errorMessage = 'アカウントの作成に失敗しました。';
        });
      }
    } else {
      success = await game.login(username, password);
      if (!success && mounted) {
        setState(() {
          _errorMessage = 'ユーザー名またはパスワードが間違っています。';
        });
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    final game = context.read<GameProvider>();
    final result = await game.loginWithGoogle();

    if (mounted) {
      setState(() {
        _isGoogleLoading = false;
      });
      if (result != null && result != 'success') {
        setState(() {
          _errorMessage = 'Googleログインに失敗しました。もう一度お試しください。';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // アプリロゴ・タイトル
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sports_esports,
                    size: 56,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '来ただけで成長するゲーム',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isRegisterMode ? 'アカウントを作成してください' : 'ログインしてください',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 32),

                // Googleログインボタン
                _GoogleSignInButton(
                  isLoading: _isGoogleLoading,
                  onPressed: _signInWithGoogle,
                ),
                const SizedBox(height: 16),

                // 区切り線
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'または',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // フォームカード（ユーザー名・パスワード）
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ユーザー名フィールド
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'ユーザー名',
                              hintText: '例: たろう',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'ユーザー名を入力してください';
                              }
                              if (value.trim().length < 2) {
                                return 'ユーザー名は2文字以上にしてください';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // パスワードフィールド
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'パスワード',
                              hintText: '4文字以上',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            textInputAction: _isRegisterMode
                                ? TextInputAction.next
                                : TextInputAction.done,
                            onFieldSubmitted:
                                _isRegisterMode ? null : (_) => _submit(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'パスワードを入力してください';
                              }
                              if (value.length < 4) {
                                return 'パスワードは4文字以上にしてください';
                              }
                              return null;
                            },
                          ),

                          // 登録モード時：パスワード確認フィールド
                          if (_isRegisterMode) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirm,
                              decoration: InputDecoration(
                                labelText: 'パスワード（確認）',
                                hintText: 'もう一度入力してください',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirm = !_obscureConfirm;
                                    });
                                  },
                                ),
                              ),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'パスワードをもう一度入力してください';
                                }
                                if (value != _passwordController.text) {
                                  return 'パスワードが一致しません';
                                }
                                return null;
                              },
                            ),
                          ],

                          // エラーメッセージ
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: colorScheme.error,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],

                          const SizedBox(height: 24),

                          // 送信ボタン
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isRegisterMode ? 'アカウントを作成' : 'ログイン',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ログイン / 登録 切り替え（登録済みの場合のみ表示）
                if (context.watch<GameProvider>().isRegistered)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isRegisterMode = !_isRegisterMode;
                        _errorMessage = null;
                        _usernameController.clear();
                        _passwordController.clear();
                        _confirmPasswordController.clear();
                      });
                    },
                    child: Text(
                      _isRegisterMode
                          ? 'すでにアカウントをお持ちの方はこちら'
                          : 'アカウントをお持ちでない方はこちら',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Googleログインボタン（Googleブランドガイドライン準拠スタイル）
class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _GoogleSignInButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F1F1F),
          side: const BorderSide(color: Color(0xFFDADCE0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Googleのカラーアイコン
                  _GoogleLogo(),
                  const SizedBox(width: 12),
                  const Text(
                    'Googleでログイン',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Google "G" ロゴを描画するウィジェット
class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(24, 24),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 青（右上）
    final paintBlue = Paint()..color = const Color(0xFF4285F4);
    // 赤（右下）
    final paintRed = Paint()..color = const Color(0xFFEA4335);
    // 黄（左下）
    final paintYellow = Paint()..color = const Color(0xFFFBBC05);
    // 緑（左上）
    final paintGreen = Paint()..color = const Color(0xFF34A853);

    // 4分割の円弧で G のカラー部分を描画
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // -90度（上）
      1.57,  // 90度 → 右上（青）
      true,
      paintBlue,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,    // 0度（右）
      1.57, // 90度 → 右下（赤）
      true,
      paintRed,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.57,  // 90度（下）
      1.57,  // 90度 → 左下（黄）
      true,
      paintYellow,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14,  // 180度（左）
      1.57,  // 90度 → 左上（緑）
      true,
      paintGreen,
    );

    // 中央の白い円（ドーナツ効果）
    final paintWhite = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.6, paintWhite);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
