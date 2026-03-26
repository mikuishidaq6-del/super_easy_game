import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_models.dart';
import '../providers/game_provider.dart';
import 'home_screen.dart';

/// キャラクター反応画面：フェイス入力後に表示
class CharacterReactionScreen extends StatefulWidget {
  final FaceScale face;
  final int expGained;

  const CharacterReactionScreen({
    super.key,
    required this.face,
    required this.expGained,
  });

  @override
  State<CharacterReactionScreen> createState() =>
      _CharacterReactionScreenState();
}

class _CharacterReactionScreenState extends State<CharacterReactionScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late Animation<double> _bounceAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOut,
    ));

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _bounceController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Color _getBgColor() {
    switch (widget.face) {
      case FaceScale.veryBad:
        return const Color(0xFFE8EAF6);
      case FaceScale.bad:
        return const Color(0xFFE3F2FD);
      case FaceScale.neutral:
        return const Color(0xFFF1F8E9);
      case FaceScale.good:
        return const Color(0xFFFFF9C4);
      case FaceScale.veryGood:
        return const Color(0xFFFFE0B2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = context.watch<GameProvider>();
    final stage = game.characterStage;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getBgColor(),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // キャラクターバウンスアニメ
                ScaleTransition(
                  scale: _bounceAnim,
                  child: Image.asset(
                    _getStageImage(stage),
                    height: 160,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Text(
                      stage.emoji,
                      style: const TextStyle(fontSize: 100),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // キャラクターの一言
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.face.characterMessage,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 経験値獲得表示
                        if (widget.expGained > 0)
                          _buildExpGainBadge(theme)
                        else
                          Text(
                            '今日の調子を更新したよ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        const SizedBox(height: 40),
                        // ホームへ進むボタン
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context)
                                .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const HomeScreen(),
                                  ),
                                  (route) => false,
                                ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                            child: const Text('ホームへ'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStageImage(CharacterStage stage) {
    switch (stage) {
      case CharacterStage.egg:    return 'assets/images/cat_stage_1.png';
      case CharacterStage.baby:   return 'assets/images/cat_stage_2.png';
      case CharacterStage.child:  return 'assets/images/cat_stage_3.png';
      case CharacterStage.teen:   return 'assets/images/cat_stage_4.png';
      case CharacterStage.adult:  return 'assets/images/cat_stage_5.png';
      case CharacterStage.legend: return 'assets/images/cat_stage_6.png';
    }
  }

  Widget _buildExpGainBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            '+${widget.expGained} EXP 獲得！',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.amber.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}