import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_models.dart';
import '../providers/game_provider.dart';
import 'character_reaction_screen.dart';

/// フェイス選択画面：「きょうの調子は？」
class FaceInputScreen extends StatefulWidget {
  const FaceInputScreen({super.key});

  @override
  State<FaceInputScreen> createState() => _FaceInputScreenState();
}

class _FaceInputScreenState extends State<FaceInputScreen>
    with TickerProviderStateMixin {
  FaceScale? _selected;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const double _cardRadius = 20;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _onFaceTap(FaceScale face) async {
    setState(() => _selected = face);
    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;
    final game = context.read<GameProvider>();
    final expGained = await game.selectFaceScale(face);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CharacterReactionScreen(
          face: face,
          expGained: expGained,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(
          '今日の調子',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF222222),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              if (game.loginStreak > 0) ...[
                _buildStreakBadge(game),
                const SizedBox(height: 16),
              ],
              _buildCharacterCard(game, theme),
              const SizedBox(height: 16),
              _buildQuestionCard(theme),
              const SizedBox(height: 16),
              _buildFaceSelector(theme),
              const SizedBox(height: 20),
              _buildLevelInfo(game, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakBadge(GameProvider game) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF7D5B5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            '${game.loginStreak}日連続ログイン中',
            style: const TextStyle(
              color: Color(0xFFA85A14),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCard(GameProvider game, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: _buildCharacterImage(game.characterStage),
                ),
                const SizedBox(height: 10),
                Text(
                  game.characterStage.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '今日の気分を教えてね',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8A90A0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Text(
            'きょうの調子は？',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF222222),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '1タップで大丈夫です。\n今日も来てくれてありがとう。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF727886),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFaceSelector(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: FaceScale.values.map((face) {
          final isSelected = _selected == face;
          return _FaceButton(
            face: face,
            isSelected: isSelected,
            onTap: () => _onFaceTap(face),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLevelInfo(GameProvider game, ThemeData theme) {
    final stage = game.characterStage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${stage.name} の成長',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF222222),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8A3),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFF1C85C)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${game.coins}',
                      style: const TextStyle(
                        color: Color(0xFF8B6413),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: game.levelProgress.clamp(0, 1),
              minHeight: 10,
              backgroundColor: const Color(0xFFE9EDF5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFA98FEF),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '経験値: ${game.totalExp} EXP',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6F7683),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterImage(CharacterStage stage) {
    final imagePath = _getStageImage(stage);

    return SizedBox(
      height: 140,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Text(
            '🐱',
            style: TextStyle(fontSize: 82),
          );
        },
      ),
    );
  }

  String _getStageImage(CharacterStage stage) {
    switch (stage) {
      case CharacterStage.egg:
        return 'assets/images/cat_stage_1.png';
      case CharacterStage.baby:
        return 'assets/images/cat_stage_2.png';
      case CharacterStage.child:
        return 'assets/images/cat_stage_3.png';
      case CharacterStage.teen:
        return 'assets/images/cat_stage_4.png';
      case CharacterStage.adult:
        return 'assets/images/cat_stage_5.png';
      case CharacterStage.legend:
        return 'assets/images/cat_stage_6.png';
    }
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(_cardRadius),
      border: Border.all(color: const Color(0xFFE7EAF1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

class _FaceButton extends StatefulWidget {
  final FaceScale face;
  final bool isSelected;
  final VoidCallback onTap;

  const _FaceButton({
    required this.face,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FaceButton> createState() => _FaceButtonState();
}

class _FaceButtonState extends State<_FaceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(covariant _FaceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward();
    } else if (!widget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _backgroundColor(FaceScale face, bool isSelected) {
    if (isSelected) {
      switch (face) {
        case FaceScale.veryBad:
          return const Color(0xFFFFECEC);
        case FaceScale.bad:
          return const Color(0xFFFFF3E8);
        case FaceScale.neutral:
          return const Color(0xFFF2F4F8);
        case FaceScale.good:
          return const Color(0xFFEAF4FF);
        case FaceScale.veryGood:
          return const Color(0xFFEAF8EF);
      }
    }

    switch (face) {
      case FaceScale.veryBad:
        return const Color(0xFFFFF7F7);
      case FaceScale.bad:
        return const Color(0xFFFFFAF4);
      case FaceScale.neutral:
        return const Color(0xFFF8FAFC);
      case FaceScale.good:
        return const Color(0xFFF7FAFF);
      case FaceScale.veryGood:
        return const Color(0xFFF4FBF6);
    }
  }

  Color _borderColor(FaceScale face, bool isSelected) {
    if (!isSelected) return const Color(0xFFE4E8F0);

    switch (face) {
      case FaceScale.veryBad:
        return const Color(0xFFE5A3A3);
      case FaceScale.bad:
        return const Color(0xFFF0C28A);
      case FaceScale.neutral:
        return const Color(0xFFB8C2D1);
      case FaceScale.good:
        return const Color(0xFF8EB7F2);
      case FaceScale.veryGood:
        return const Color(0xFF8FCB9B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 92,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: _backgroundColor(widget.face, widget.isSelected),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _borderColor(widget.face, widget.isSelected),
              width: widget.isSelected ? 1.6 : 1.0,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: _borderColor(widget.face, true).withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.face.emoji,
                style: const TextStyle(fontSize: 34),
              ),
              const SizedBox(height: 6),
              Text(
                widget.face.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF4F5768),
                  fontWeight:
                      widget.isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
