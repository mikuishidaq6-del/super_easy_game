import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';

/// 健康アクティビティ記録画面
/// 歯磨き・うがい・シャワー・お薬管理
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  static const double _pageHorizontalPadding = 16;
  static const double _sectionGap = 24;
  static const double _cardRadius = 20;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(
          '健康記録',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            _pageHorizontalPadding,
            8,
            _pageHorizontalPadding,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(game, theme),
              const SizedBox(height: _sectionGap),
              _SectionTitle(
                title: '今日の記録',
                subtitle: 'からだのケアを記録して、経験値とコインを獲得しよう',
              ),
              const SizedBox(height: 12),
              ...HealthActivity.all
                  .where((activity) => activity.id != 'medicine')
                  .map(
                    (activity) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ActivityCard(activity: activity),
                    ),
                  ),
              const SizedBox(height: _sectionGap - 4),
              _SectionTitle(
                title: 'お薬',
                subtitle: '飲めたら記録。1日${game.medicineLimit}回まで記録できます。',
              ),
              const SizedBox(height: 12),
              _buildMedicineSection(context, game, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(GameProvider game, ThemeData theme) {
    final doneTasks = HealthActivity.all
        .where((a) =>
            a.id != 'medicine' && a.id != 'gargle' && game.isActivityDone(a.id))
        .length;
    final gargleDone = game.gargleCount;
    final medicineDone = game.medicineCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_cardRadius),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF7F8FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日の達成状況',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '今日できたことがひと目でわかります',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7A7F8A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryMetricCard(
                  label: '清潔ケア',
                  value: '$doneTasks/2',
                  accentColor: const Color(0xFF5A67D8),
                  icon: Icons.self_improvement_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetricCard(
                  label: 'うがい',
                  value: '$gargleDone/5',
                  accentColor: const Color(0xFF2B90D9),
                  icon: Icons.water_drop_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetricCard(
                  label: 'お薬',
                  value: '$medicineDone/${game.medicineLimit}',
                  accentColor: const Color(0xFF9C51D8),
                  icon: Icons.medication_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineSection(
      BuildContext context, GameProvider game, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_cardRadius),
        color: const Color(0xFFF7ECFF),
        border: Border.all(
          color: const Color(0xFFE9D4FA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '💊',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'お薬の記録',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF5F2D86),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: Color(0xFF9C51D8)),
                tooltip: '上限回数を変更',
                onPressed: () =>
                    _showMedicineLimitDialog(context, game),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '飲めたタイミングで記録しましょう。最大${game.medicineLimit}回まで記録できます。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7C5A97),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const _MedicineTracker(),
        ],
      ),
    );
  }

  Future<void> _showMedicineLimitDialog(
      BuildContext context, GameProvider game) async {
    int selectedLimit = game.medicineLimit;
    final newLimit = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('お薬の上限回数'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('1日に記録できるお薬の上限回数を設定します。'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('上限回数：'),
                  Text(
                    '$selectedLimit 回',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF9C51D8),
                    ),
                  ),
                ],
              ),
              Slider(
                value: selectedLimit.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: '$selectedLimit 回',
                activeColor: const Color(0xFF9C51D8),
                onChanged: (v) =>
                    setDialogState(() => selectedLimit = v.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(selectedLimit),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF9C51D8),
              ),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );

    if (newLimit != null) {
      await game.setMedicineLimit(newLimit);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7A7F8A),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;
  final IconData icon;

  const _SummaryMetricCard({
    required this.label,
    required this.value,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 16,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: const Color(0xFF6E7380),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap(GameProvider game) async {
    if (widget.activity.id == 'medicine') return;

    final expGained = await game.recordActivity(widget.activity);
    if (expGained > 0) {
      _controller.forward().then((_) => _controller.reverse());
      setState(() {
        _feedbackMessage =
            '+$expGained EXP / +${widget.activity.coinReward} コイン';
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _feedbackMessage = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = context.watch<GameProvider>();

    if (widget.activity.id == 'gargle') {
      return _GargleCard(activity: widget.activity);
    }
    if (widget.activity.id == 'medicine') {
      return const SizedBox.shrink();
    }

    final isDone = game.isActivityDone(widget.activity.id);

    return ScaleTransition(
      scale: _scaleAnim,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFF0FAF2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDone ? const Color(0xFFB9E7C0) : const Color(0xFFE8EAF0),
          ),
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
            _ActivityIcon(
              emoji: widget.activity.emoji,
              isDone: isDone,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.activity.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF222222),
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      _feedbackMessage ??
                          '+${widget.activity.expReward} EXP / +${widget.activity.coinReward} コイン',
                      key: ValueKey(_feedbackMessage ?? 'default'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _feedbackMessage != null
                            ? const Color(0xFF2E9B52)
                            : const Color(0xFF7A7F8A),
                        fontWeight: _feedbackMessage != null
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            isDone
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFF5E4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '完了',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  )
                : FilledButton(
                    onPressed: () => _onTap(game),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF5A67D8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      '記録',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _ActivityIcon extends StatelessWidget {
  final String emoji;
  final bool isDone;

  const _ActivityIcon({
    required this.emoji,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFFE8F7EC) : const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 30),
          ),
        ),
        if (isDone)
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFF34A853),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
      ],
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
        _feedbackMessage =
            '+$expGained EXP / +${widget.activity.coinReward} コイン';
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _feedbackMessage = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = context.watch<GameProvider>();
    final count = game.gargleCount;
    final isDone = count >= 5;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFF0FAF2) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone ? const Color(0xFFB9E7C0) : const Color(0xFFE8EAF0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ActivityIcon(
                emoji: widget.activity.emoji,
                isDone: isDone,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.activity.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${widget.activity.expReward} EXP / +${widget.activity.coinReward} コイン（1回ごと）',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF7A7F8A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(5, (i) {
              final filled = i < count;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == 4 ? 0 : 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 44,
                    decoration: BoxDecoration(
                      color: filled
                          ? const Color(0xFF5AAAE7)
                          : const Color(0xFFF1F4F8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: filled
                            ? const Color(0xFF5AAAE7)
                            : const Color(0xFFE0E5EB),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      filled ? '✓' : '${i + 1}',
                      style: TextStyle(
                        color: filled ? Colors.white : const Color(0xFF8B93A1),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            '今日の記録：$count / 5回',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6F7683),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          if (_feedbackMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8EF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _feedbackMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF2E9B52),
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else if (!isDone)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _onTap(game),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'うがいを記録する',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2B90D9),
                  side: const BorderSide(
                    color: Color(0xFFB8D8EE),
                  ),
                  backgroundColor: const Color(0xFFF9FCFF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFDFF5E4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                '今日のうがい完了',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// お薬トラッカー（1日5回まで）
class _MedicineTracker extends StatefulWidget {
  const _MedicineTracker();

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
      setState(() => _feedbackMessage = '+$expGained EXP / +2 コイン');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _feedbackMessage = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = context.watch<GameProvider>();
    final count = game.medicineCount;
    final limit = game.medicineLimit;
    final isDone = count >= limit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(limit, (i) {
            final filled = i < count;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == limit - 1 ? 0 : 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 52,
                  decoration: BoxDecoration(
                    color: filled
                        ? const Color(0xFFA955E8)
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: filled
                          ? const Color(0xFFA955E8)
                          : const Color(0xFFE6D5F6),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    filled ? '✓' : '💊',
                    style: TextStyle(
                      fontSize: 22,
                      color: filled ? Colors.white : const Color(0xFFA955E8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Text(
          '今日の記録：$count / $limit回',
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF7C5A97),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        if (_feedbackMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _feedbackMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF7A3FB3),
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else if (!isDone)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _onTap(game),
              icon: const Text('💊'),
              label: Text(
                'お薬を記録する ($count/$limit)',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFA955E8),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '今日のお薬完了',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6A348F),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
