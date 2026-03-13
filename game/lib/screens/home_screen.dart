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
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
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
            label: '健康記録',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

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
              theme.colorScheme.primaryContainer.withOpacity(0.4),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー
                _buildHeader(context, game, theme),
                const SizedBox(height: 24),
                // キャラクターカード
                _buildCharacterCard(game, stage, theme),
                const SizedBox(height: 16),
                // 今日の調子
                if (game.todayFaceScale != null)
                  _buildTodayFaceCard(game, theme),
                const SizedBox(height: 16),
                // ステータスグリッド
                _buildStatusGrid(game, theme),
                const SizedBox(height: 16),
                // 連続ログインカード
                _buildStreakCard(context, game, theme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FaceInputScreen()),
        ),
        icon: const Icon(Icons.mood),
        label: const Text('調子を更新'),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, GameProvider game, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'こんにちは！',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '来てくれてありがとう 🌸',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        // コイン表示
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.shade400),
          ),
          child: Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              Text(
                '${game.coins}',
                style: TextStyle(
                  color: Colors.amber.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterCard(
      GameProvider game, CharacterStage stage, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              stage.emoji,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 8),
            Text(
              stage.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 経験値バー
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: game.levelProgress,
                minHeight: 12,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${game.totalExp} EXP',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (stage != CharacterStage.legend)
                  Text(
                    '次のレベルまで ${game.expToNextLevel} EXP',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  Text(
                    '最高レベル達成！ ✨',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayFaceCard(GameProvider game, ThemeData theme) {
    final face = game.todayFaceScale!;
    return Card(
      child: ListTile(
        leading: Text(face.emoji, style: const TextStyle(fontSize: 32)),
        title: Text(
          '今日の調子：${face.label}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          face.characterMessage,
          style: theme.textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildStatusGrid(GameProvider game, ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _StatusCard(
          icon: '👣',
          label: '今日の歩数',
          value: '${game.todaySteps}歩',
          theme: theme,
        ),
        _StatusCard(
          icon: '🔥',
          label: 'ログイン',
          value: '${game.loginStreak}日連続',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildStreakCard(
      BuildContext context, GameProvider game, ThemeData theme) {
    if (game.loginStreak < 2) return const SizedBox.shrink();
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${game.loginStreak}日連続ログイン！',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  Text(
                    '毎日来てくれてありがとう 💙',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
            if (game.coins >= GameProvider.streakRecoveryCost)
              TextButton(
                onPressed: () => _showStreakRecoveryDialog(context, game),
                child: Text(
                  'ストリーク回復\n(${GameProvider.streakRecoveryCost}🪙)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStreakRecoveryDialog(
      BuildContext context, GameProvider game) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ストリーク回復'),
        content: Text('${GameProvider.streakRecoveryCost}🪙コインを使ってログインストリークを回復しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
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

class _StatusCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _StatusCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
