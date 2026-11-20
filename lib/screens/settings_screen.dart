import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majan_log_app/providers/database_provider.dart';
import 'package:majan_log_app/utils/score_rate_mode.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _scoreRateController = TextEditingController();
  final _chipRateController = TextEditingController();
  int _scoreRateMode = ScoreRateMode.yen;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final scoreRate = await db.getSetting('defaultScoreRate', 50);
    final chipRate = await db.getSetting('defaultChipRate', 100);
    final scoreRateMode =
        await db.getSetting('defaultScoreRateMode', ScoreRateMode.yen);
    _scoreRateController.text = '$scoreRate';
    _chipRateController.text = '$chipRate';
    setState(() {
      _scoreRateMode = scoreRateMode == ScoreRateMode.chip
          ? ScoreRateMode.chip
          : ScoreRateMode.yen;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _scoreRateController.dispose();
    _chipRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('レート設定')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('レート設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('デフォルトレート',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('新しい対戦日を作成するときの初期値です',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          const Text('順位点の換算',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: ScoreRateMode.yen,
                label: Text('円換算'),
              ),
              ButtonSegment(
                value: ScoreRateMode.chip,
                label: Text('チップ換算'),
              ),
            ],
            selected: {_scoreRateMode},
            onSelectionChanged: (value) {
              setState(() {
                final next = value.first;
                if (ScoreRateMode.isChip(next) &&
                    ScoreRateMode.isYen(_scoreRateMode)) {
                  // チップ換算へ切替時はチップレートを単一欄へ引き継ぐ
                  _scoreRateController.text = _chipRateController.text;
                }
                _scoreRateMode = next;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _scoreRateController,
            decoration: InputDecoration(
              labelText: ScoreRateMode.isChip(_scoreRateMode)
                  ? 'チップレート'
                  : '順位点レート',
              border: const OutlineInputBorder(),
              suffixText: ScoreRateMode.scoreRateSuffix(_scoreRateMode),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          if (ScoreRateMode.isYen(_scoreRateMode)) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _chipRateController,
              decoration: const InputDecoration(
                labelText: 'チップレート',
                border: OutlineInputBorder(),
                suffixText: '円 / 1枚',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    final scoreRate =
        int.tryParse(_scoreRateController.text) ?? 50;
    await db.setSetting('defaultScoreRate', scoreRate);
    await db.setSetting('defaultScoreRateMode', _scoreRateMode);
    // 円換算のときだけ独立チップレートを保存（チップ換算に戻しても消えない）。
    if (ScoreRateMode.isYen(_scoreRateMode)) {
      final chipRate =
          int.tryParse(_chipRateController.text) ?? 100;
      await db.setSetting('defaultChipRate', chipRate);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存しました')),
      );
    }
  }
}
