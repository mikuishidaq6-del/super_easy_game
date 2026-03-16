import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import 'face_input_screen.dart';
import 'step_input_screen.dart';
import 'activity_screen.dart';

/// ホーム画面：キャラクター状態・各機能へのナビゲーション
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _tabs = [
    _HomeTab(),
    StepInputScreen(),
    ActivityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        height: 74,
        backgroundColor: const Color(0xFFF7F8FC),
        indicatorColor: const Color(0xFFDCEBFF),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_walk_outlined),
            selectedIcon: Icon(Icons.directions_walk),
            label: '歩数',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'セルフケアの記録',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  static const double _pagePadding = 16;
  static const double _cardRadius = 20;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = context.watch<GameProvider>();
    final stage = game.characterStage;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            _pagePadding,
            18,
            _pagePadding,
            110,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(game, theme),
              const SizedBox(height: 16),
              _buildCharacterCard(game, stage, theme),
              const SizedBox(height: 16),
              if (game.todayFaceScale != null) ...[
                _buildTodayFaceCard(game, theme),
                const SizedBox(height: 16),
              ],
              _buildQuickStats(game, theme),
              if (game.loginStreak >= 2) ...[
                const SizedBox(height: 16),
                _buildStreakCard(context, game, theme),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 1,
        backgroundColor: const Color(0xFFDCEBFF),
        foregroundColor: const Color(0xFF355C8A),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FaceInputScreen()),
        ),
        icon: const Icon(Icons.mood_outlined),
        label: const Text(
          '調子を更新',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildHeader(GameProvider game, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'こんにちは！',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '来てくれてありがとう 🌸',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF7A7F8A),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE8A3),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFF1C85C)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 4),
              Text(
                '${game.coins}',
                style: const TextStyle(
                  color: Color(0xFF8B6413),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterCard(
    GameProvider game,
    CharacterStage stage,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                _buildCharacterImage(stage),
                const SizedBox(height: 10),
                Text(
                  stage.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'すくすく成長中',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9A84A7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  '${game.totalExp} EXP',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6F7683),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  stage != CharacterStage.legend
                      ? '次まで ${game.expToNextLevel} EXP'
                      : '最高レベル達成！',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: stage != CharacterStage.legend
                        ? const Color(0xFF6F7683)
                        : const Color(0xFFA98FEF),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterImage(CharacterStage stage) {
    final imagePath = _getStageImage(stage);

    return SizedBox(
      height: 150,
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
        return 'assets/images/cat_stage_5.png';
    }
  }

  Widget _buildTodayFaceCard(GameProvider game, ThemeData theme) {
    final face = game.todayFaceScale!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EAF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D9),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              face.emoji,
              style: const TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '今日の調子：${face.label}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  face.characterMessage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF727886),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF9AA1AE),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(GameProvider game, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: '👣',
            title: '今日の歩数',
            value: '${game.todaySteps}歩',
            bgColor: const Color(0xFFEAF4FF),
            accentColor: const Color(0xFF4D8FE3),
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: '🔥',
            title: 'ログイン',
            value: '${game.loginStreak}日連続',
            bgColor: const Color(0xFFFFF1E7),
            accentColor: const Color(0xFFE58A3C),
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(
    BuildContext context,
    GameProvider game,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF7D5B5)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text(
              '🔥',
              style: TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${game.loginStreak}日連続ログイン！',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFA85A14),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '毎日来てくれてありがとう',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFB06C2D),
                  ),
                ),
              ],
            ),
          ),
          if (game.coins >= GameProvider.streakRecoveryCost)
            TextButton(
              onPressed: () => _showStreakRecoveryDialog(context, game),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFA85A14),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              child: Text(
                '回復\n(${GameProvider.streakRecoveryCost}🪙)',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showStreakRecoveryDialog(
    BuildContext context,
    GameProvider game,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ストリーク回復'),
        content: Text(
          '${GameProvider.streakRecoveryCost}🪙コインを使ってログインストリークを回復しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('回復する'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await game.useCoinsForStreakRecovery();
    }
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String title;
  final String value;
  final Color bgColor;
  final Color accentColor;
  final ThemeData theme;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.bgColor,
    required this.accentColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EAF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF7A8190),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
