import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';

/// 健康アクティビティ記録画面
/// 歯磨き・うがい・シャワー・お薬管理
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('健康記録'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 今日の達成状況サマリー
            _buildSummaryCard(game, theme),
            const SizedBox(height: 16),
            Text(
              '今日の記録',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // 各アクティビティカード
            ...HealthActivity.all.map(
              (activity) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ActivityCard(activity: activity),
              ),
            ),
            const SizedBox(height: 8),
            // お薬管理セクション
            _buildMedicineSection(game, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(GameProvider game, ThemeData theme) {
    final doneTasks = HealthActivity.all
        .where((a) => a.id != 'medicine' && game.isActivityDone(a.id))
        .length;
    final gargleDone = game.gargleCount;
    final medicineDone = game.medicineCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日の達成状況 ✨',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(label: '基本ケア', value: '$doneTasks/2完了'),
                _SummaryItem(label: 'うがい', value: '$gargleDone/5回'),
                _SummaryItem(label: 'お薬', value: '$medicineDone/3回'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineSection(GameProvider game, ThemeData theme) {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💊', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  'お薬のめたね',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'お薬を飲んだら記録しよう。1日3回まで記録できます。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(height: 12),
            _MedicineTracker(),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatefulWidget {
  final HealthActivity activity;

  const _ActivityCard({required this.activity});

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap(GameProvider game) async {
    if (widget.activity.id == 'medicine') return; // medicineは別ウィジェットで処理

    final expGained = await game.recordActivity(widget.activity);
    if (expGained > 0) {
      _controller.forward().then((_) => _controller.reverse());
      setState(() {
        _feedbackMessage = '+$expGained EXP, +${widget.activity.coinReward}🪙';
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _feedbackMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = context.watch<GameProvider>();

    // うがいカードは専用表示
    if (widget.activity.id == 'gargle') {
      return _GargleCard(activity: widget.activity);
    }
    if (widget.activity.id == 'medicine') {
      return const SizedBox.shrink(); // medicineはスキップ（別セクションで表示）
    }

    final isDone = game.isActivityDone(widget.activity.id);

    return ScaleTransition(
      scale: _scaleAnim,
      child: Card(
        color: isDone ? Colors.green.shade50 : null,
        child: ListTile(
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Text(
                widget.activity.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              if (isDone)
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            widget.activity.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: _feedbackMessage != null
              ? Text(
                  _feedbackMessage!,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Text(
                  '+${widget.activity.expReward} EXP, +${widget.activity.coinReward}🪙',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
          trailing: isDone
              ? Chip(
                  label: const Text('完了'),
                  backgroundColor: Colors.green.shade100,
                  labelStyle: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 12,
                  ),
                )
              : ElevatedButton(
                  onPressed: () => _onTap(game),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                  child: const Text('記録'),
                ),
        ),
      ),
    );
  }
}

/// うがいは1日5回まで記録できる専用カード
class _GargleCard extends StatefulWidget {
  final HealthActivity activity;

  const _GargleCard({required this.activity});

  @override
  State<_GargleCard> createState() => _GargleCardState();
}

class _GargleCardState extends State<_GargleCard> {
  String? _feedbackMessage;

  Future<void> _onTap(GameProvider game) async {
    final expGained = await game.recordActivity(widget.activity);
    if (expGained > 0) {
      setState(() {
        _feedbackMessage = '+$expGained EXP, +${widget.activity.coinReward}🪙';
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _feedbackMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = context.watch<GameProvider>();
    final count = game.gargleCount;
    final isDone = count >= 5;

    return Card(
      color: isDone ? Colors.green.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.activity.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.activity.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '+${widget.activity.expReward} EXP, +${widget.activity.coinReward}🪙 (1回ごと)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 5つの丸でカウント表示
            Row(
              children: List.generate(5, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: i < count
                          ? Colors.blue.shade400
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        i < count ? '✓' : '${i + 1}',
                        style: TextStyle(
                          color: i < count ? Colors.white : Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              // スペース確保
            ),
            const SizedBox(height: 12),
            if (_feedbackMessage != null)
              Text(
                _feedbackMessage!,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (!isDone)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _onTap(game),
                  icon: const Icon(Icons.add),
                  label: Text('うがいした ($count/5)'),
                ),
              )
            else
              Center(
                child: Chip(
                  label: const Text('今日のうがい完了！'),
                  backgroundColor: Colors.green.shade100,
                  labelStyle: TextStyle(color: Colors.green.shade800),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// お薬トラッカー（1日3回まで）
class _MedicineTracker extends StatefulWidget {
  @override
  State<_MedicineTracker> createState() => _MedicineTrackerState();
}

class _MedicineTrackerState extends State<_MedicineTracker> {
  String? _feedbackMessage;

  Future<void> _onTap(GameProvider game) async {
    const activity = HealthActivity(
      id: 'medicine',
      name: 'お薬のめたね',
      emoji: '💊',
      expReward: 15,
      coinReward: 2,
    );
    final expGained = await game.recordActivity(activity);
    if (expGained > 0) {
      setState(() => _feedbackMessage = '+$expGained EXP, +2🪙');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _feedbackMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = context.watch<GameProvider>();
    final count = game.medicineCount;
    final isDone = count >= 3;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: i < count
                      ? Colors.purple.shade400
                      : Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    i < count ? '✓' : '💊',
                    style: TextStyle(
                      fontSize: 24,
                      color: i < count ? Colors.white : Colors.purple.shade400,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        if (_feedbackMessage != null)
          Text(
            _feedbackMessage!,
            style: TextStyle(
              color: Colors.purple.shade700,
              fontWeight: FontWeight.bold,
            ),
          )
        else if (!isDone)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _onTap(game),
              icon: const Text('💊'),
              label: Text('のめたね ($count/3回)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade400,
                foregroundColor: Colors.white,
              ),
            ),
          )
        else
          Chip(
            label: const Text('今日のお薬完了！お疲れ様です 💙'),
            backgroundColor: Colors.purple.shade100,
            labelStyle: TextStyle(color: Colors.purple.shade900),
          ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
