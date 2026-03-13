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
    await Future.delayed(const Duration(milliseconds: 300));

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
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = context.watch<GameProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.6),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // ストリーク表示
                _buildStreakBadge(game),
                const SizedBox(height: 32),
                // キャラクター
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Text(
                    game.characterStage.emoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'きょうの調子は？',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '1タップで大丈夫。今日も来てくれてありがとう',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // フェイスボタン列
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: FaceScale.values.map((face) {
                    final isSelected = _selected == face;
                    return _FaceButton(
                      face: face,
                      isSelected: isSelected,
                      onTap: () => _onFaceTap(face),
                    );
                  }).toList(),
                ),
                const Spacer(),
                // レベル情報
                _buildLevelInfo(game, theme),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakBadge(GameProvider game) {
    if (game.loginStreak == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            '${game.loginStreak}日連続ログイン中！',
            style: TextStyle(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelInfo(GameProvider game, ThemeData theme) {
    final stage = game.characterStage;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stage.emoji} ${stage.name}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '${game.coins}コイン',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: game.levelProgress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '経験値: ${game.totalExp} EXP',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
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
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_FaceButton oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: widget.isSelected
                ? Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  )
                : null,
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                widget.face.emoji,
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 4),
              Text(
                widget.face.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: widget.isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: widget.isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
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
