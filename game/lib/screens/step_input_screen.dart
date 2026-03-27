import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

/// 歩数手入力画面
class StepInputScreen extends StatefulWidget {
  const StepInputScreen({super.key});

  @override
  State<StepInputScreen> createState() => _StepInputScreenState();
}

class _StepInputScreenState extends State<StepInputScreen> {
  final _controller = TextEditingController();
  String? _errorText;
  StepRewardResult? _rewardResult;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    final steps = int.tryParse(text);

    if (steps == null || steps <= 0) {
      setState(() {
        _errorText = '1歩以上の数字を入力してください';
      });
      return;
    }

    if (steps > 100000) {
      setState(() {
        _errorText = '歩数が多すぎます（最大10万歩）';
      });
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
      _rewardResult = null;
    });

    final game = context.read<GameProvider>();
    final beforeTodaySteps = game.todaySteps;
    final threshold = game.todayFaceScale?.stepThreshold ?? 100;

    final result = await game.addSteps(steps);

    final afterTodaySteps = game.todaySteps;
    final gainedCoins = result['coins'] ?? 0;
    final gainedExp = result['exp'] ?? 0;

    final remainder = afterTodaySteps % threshold;
    final stepsToNextCoin = remainder == 0 ? threshold : threshold - remainder;

    setState(() {
      _isLoading = false;
      _controller.clear();
      _rewardResult = StepRewardResult(
        inputSteps: steps,
        gainedCoins: gainedCoins,
        gainedExp: gainedExp,
        threshold: threshold,
        totalStepsAfter: afterTodaySteps,
        stepsToNextCoin: stepsToNextCoin,
        hadCoinReward: gainedCoins > 0,
        praiseMessage: _buildPraiseMessage(
          steps: steps,
          gainedCoins: gainedCoins,
          gainedExp: gainedExp,
        ),
        subMessage: _buildSubMessage(
          steps: steps,
          gainedCoins: gainedCoins,
          threshold: threshold,
          stepsToNextCoin: stepsToNextCoin,
          beforeTodaySteps: beforeTodaySteps,
          afterTodaySteps: afterTodaySteps,
        ),
      );
    });
  }

  String _buildPraiseMessage({
    required int steps,
    required int gainedCoins,
    required int gainedExp,
  }) {
    if (steps >= 10000) {
      return 'すごい！かなり歩けました';
    }
    if (steps >= 5000) {
      return 'とてもいい調子です';
    }
    if (steps >= 2000) {
      return 'しっかり積み上げられました';
    }
    if (gainedCoins > 0 || gainedExp > 0) {
      return 'ナイス記録です';
    }
    return '入力できただけでも前進です';
  }

  String _buildSubMessage({
    required int steps,
    required int gainedCoins,
    required int threshold,
    required int stepsToNextCoin,
    required int beforeTodaySteps,
    required int afterTodaySteps,
  }) {
    if (gainedCoins > 0) {
      return '$steps歩を記録しました。報酬を獲得しています。';
    }

    if (afterTodaySteps > beforeTodaySteps) {
      return '次のコインまであと$stepsToNextCoin歩です。';
    }

    return '記録は完了しました。';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = context.watch<GameProvider>();
    final threshold = game.todayFaceScale?.stepThreshold ?? 100;
    final faceEmoji = game.todayFaceScale?.emoji ?? '😐';

    return Scaffold(
      appBar: AppBar(
        title: const Text('歩数入力'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TodaySummaryCard(
                totalSteps: game.todaySteps,
                threshold: threshold,
                emoji: faceEmoji,
              ),
              const SizedBox(height: 20),
              _InputHeroCard(
                controller: _controller,
                errorText: _errorText,
                isLoading: _isLoading,
                threshold: threshold,
                onSubmit: _submit,
              ),
              const SizedBox(height: 18),
              _RewardGuideCard(
                threshold: threshold,
                emoji: faceEmoji,
              ),
              const SizedBox(height: 18),
              if (_rewardResult != null) ...[
                _RewardResultCard(result: _rewardResult!),
                const SizedBox(height: 18),
              ],
              _StepTipsCard(
                threshold: threshold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodaySummaryCard extends StatelessWidget {
  final int totalSteps;
  final int threshold;
  final String emoji;

  const _TodaySummaryCard({
    required this.totalSteps,
    required this.threshold,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日の歩数',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    '👣',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  '$totalSteps歩',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimaryContainer,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: emoji,
                label: '今日の体調',
              ),
              _InfoChip(
                icon: '🪙',
                label: '$threshold歩ごとにコイン',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InputHeroCard extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final bool isLoading;
  final int threshold;
  final VoidCallback onSubmit;

  const _InputHeroCard({
    required this.controller,
    required this.errorText,
    required this.isLoading,
    required this.threshold,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '歩数を入力',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '入力した歩数に応じてEXPとコインを獲得できます。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            decoration: InputDecoration(
              labelText: '歩数',
              hintText: '例：3000',
              errorText: errorText,
              suffixText: '歩',
              filled: true,
              fillColor:
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onSubmit,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_circle_outline),
              label: Text(
                isLoading ? '記録中...' : 'この歩数を記録する',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withOpacity(0.55),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text(
                  '💡',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$threshold歩ごとにコイン1枚。少しの歩数でもちゃんと前進です。',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
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

class _RewardGuideCard extends StatelessWidget {
  final int threshold;
  final String emoji;

  const _RewardGuideCard({
    required this.threshold,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '報酬ルール',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.amber.shade900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _GuideBadge(
                emoji: emoji,
                text: '今日の体調',
              ),
              const SizedBox(width: 8),
              _GuideBadge(
                emoji: '🪙',
                text: '$threshold歩ごとに1枚',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '歩いた分だけ経験値がたまり、コインも増えます。報酬が出たことを一目でわかるように、入力後に大きく表示します。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.brown.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardResultCard extends StatelessWidget {
  final StepRewardResult result;

  const _RewardResultCard({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasReward = result.hadCoinReward || result.gainedExp > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasReward
              ? [
                  Colors.green.shade50,
                  Colors.lightGreen.shade50,
                ]
              : [
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasReward
              ? Colors.green.shade300
              : theme.colorScheme.outlineVariant,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                hasReward ? '🎉' : '👏',
                style: const TextStyle(fontSize: 34),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result.praiseMessage,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: hasReward
                        ? Colors.green.shade900
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.subMessage,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: hasReward
                  ? Colors.green.shade900
                  : theme.colorScheme.onSurfaceVariant,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _RewardStatChip(
                icon: '👣',
                label: '今回',
                value: '${result.inputSteps}歩',
              ),
              _RewardStatChip(
                icon: '✨',
                label: 'EXP',
                value: '+${result.gainedExp}',
              ),
              _RewardStatChip(
                icon: '🪙',
                label: 'コイン',
                value: '+${result.gainedCoins}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (result.hadCoinReward)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${result.threshold}歩ごとの報酬を獲得しました。今日の合計は${result.totalStepsAfter}歩です。',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '次のコインまであと${result.stepsToNextCoin}歩です。',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepTipsCard extends StatelessWidget {
  final int threshold;

  const _StepTipsCard({
    required this.threshold,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.55),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '歩数入力のポイント',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _TipRow(text: '体調に応じて、今日は$threshold歩ごとにコインがもらえます。'),
          const SizedBox(height: 10),
          const _TipRow(text: 'たくさん歩けない日でも、入力できたこと自体に価値があります。'),
          const SizedBox(height: 10),
          const _TipRow(text: 'コインをためると、ゲーム内の行動を回復できます。'),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideBadge extends StatelessWidget {
  final String emoji;
  final String text;

  const _GuideBadge({
    required this.emoji,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.brown.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardStatChip extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _RewardStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;

  const _TipRow({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Text('•', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class StepRewardResult {
  final int inputSteps;
  final int gainedExp;
  final int gainedCoins;
  final int threshold;
  final int totalStepsAfter;
  final int stepsToNextCoin;
  final bool hadCoinReward;
  final String praiseMessage;
  final String subMessage;

  StepRewardResult({
    required this.inputSteps,
    required this.gainedExp,
    required this.gainedCoins,
    required this.threshold,
    required this.totalStepsAfter,
    required this.stepsToNextCoin,
    required this.hadCoinReward,
    required this.praiseMessage,
    required this.subMessage,
  });
}
