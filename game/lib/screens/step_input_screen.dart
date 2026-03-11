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
  String? _resultMessage;
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
      setState(() => _errorText = '正しい歩数を入力してください');
      return;
    }
    if (steps > 100000) {
      setState(() => _errorText = '歩数が多すぎます（最大10万歩）');
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
      _resultMessage = null;
    });

    final game = context.read<GameProvider>();
    final result = await game.addSteps(steps);

    final threshold = game.todayFaceScale?.stepThreshold ?? 100;
    final cycles = steps ~/ threshold;

    setState(() {
      _isLoading = false;
      _controller.clear();
      if (result['exp']! > 0) {
        _resultMessage =
            '$steps歩を記録！\n+${result['exp']} EXP, +${result['coins']}🪙 コイン獲得！\n（${threshold}歩ごとにコインGET）';
      } else {
        _resultMessage =
            '$steps歩を記録しました！\nあと${threshold - (game.todaySteps % threshold)}歩でコインがもらえるよ';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = context.watch<GameProvider>();
    final threshold = game.todayFaceScale?.stepThreshold ?? 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('歩数を入力'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 今日の歩数サマリー
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('👣', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '今日の合計歩数',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${game.todaySteps}歩',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 体調による閾値の説明
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    game.todayFaceScale?.emoji ?? '😐',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '今日の体調では${threshold}歩ごとにコイン獲得 🪙',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 入力フィールド
            Text(
              '歩数を入力してください',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: '例: 3000',
                      errorText: _errorText,
                      border: const OutlineInputBorder(),
                      suffixText: '歩',
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('追加'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 結果メッセージ
            if (_resultMessage != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _resultMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            // 説明
            Card(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ℹ️ 歩数について',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 歩けない日でもゲームは楽しめます\n'
                      '• 体調によって閾値が変わります\n'
                      '  （体調が悪い日は少ない歩数でOK）\n'
                      '• コインを15枚貯めるとログインボーナスを回復できます',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
