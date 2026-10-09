import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:majan_log_app/db/database.dart';
import 'package:majan_log_app/utils/score_balance.dart';
import 'package:majan_log_app/utils/sit_out_rotation.dart';

/// 半荘の点数入力フォーム（モーダル・インライン共用）。
class HanchanScoreForm extends StatefulWidget {
  final int gameNumber;
  final int seatCount;
  final List<Player> players;

  /// 編集時は既存スコア。追加時は空。
  final Map<int, int> initialScores;

  /// 編集時の初期休み。追加かつ余剰ありのときはローテ既定を使う。
  final Set<int>? initialSittingOutIds;

  final VoidCallback? onCancel;
  final Future<void> Function({
    required Set<int> sittingOutIds,
    required Map<int, int> scores,
  }) onSave;

  /// true なら外側の枠（カード風）なし。インライン用。
  final bool inline;

  const HanchanScoreForm({
    super.key,
    required this.gameNumber,
    required this.seatCount,
    required this.players,
    required this.onSave,
    this.initialScores = const {},
    this.initialSittingOutIds,
    this.onCancel,
    this.inline = false,
  });

  @override
  State<HanchanScoreForm> createState() => HanchanScoreFormState();
}

class HanchanScoreFormState extends State<HanchanScoreForm> {
  late final Map<int, TextEditingController> _controllers;
  late final Map<int, FocusNode> _focusNodes;
  late Set<int> _sittingOutIds;
  int? _autoFilledPlayerId;
  bool _saving = false;

  List<int> get _participantIds =>
      widget.players.map((p) => p.id).toList();

  int get _excess => widget.players.length - widget.seatCount;

  bool get _canSave {
    final seated = seatedPlayerIds(
      participantIds: _participantIds,
      sittingOutIds: _sittingOutIds,
    );
    return seated.length == widget.seatCount;
  }

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final p in widget.players)
        p.id: TextEditingController(
          text: widget.initialScores.containsKey(p.id)
              ? '${widget.initialScores[p.id]}'
              : '',
        ),
    };
    _focusNodes = {
      for (final p in widget.players) p.id: FocusNode(),
    };
    for (final node in _focusNodes.values) {
      node.addListener(_onFocusChange);
    }

    if (widget.initialSittingOutIds != null) {
      _sittingOutIds = Set<int>.from(widget.initialSittingOutIds!);
    } else if (_excess > 0) {
      _sittingOutIds = defaultSittingOutPlayerIds(
        participantIds: _participantIds,
        seatCount: widget.seatCount,
        gameNumber: widget.gameNumber,
      ).toSet();
    } else {
      _sittingOutIds = {};
    }

    // 休みの人の入力はクリア
    for (final id in _sittingOutIds) {
      _controllers[id]?.clear();
    }
  }

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.removeListener(_onFocusChange);
      node.dispose();
    }
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    // フォーカスが外れたタイミングでもゼロ和を試す
    if (!_focusNodes.values.any((n) => n.hasFocus)) {
      _autoCalcLast();
    }
  }

  int? get _focusedPlayerId {
    for (final e in _focusNodes.entries) {
      if (e.value.hasFocus) return e.key;
    }
    return null;
  }

  void _autoCalcLast({int? skipPlayerId}) {
    final seated = seatedPlayerIds(
      participantIds: _participantIds,
      sittingOutIds: _sittingOutIds,
    );
    final texts = <int, String>{
      for (final id in seated) id: _controllers[id]!.text,
    };

    // 自動記入済み欄を再計算対象にする場合:
    // フォーカス中でなければ、その欄を空扱いにして再計算する。
    final autoId = _autoFilledPlayerId;
    if (autoId != null &&
        seated.contains(autoId) &&
        autoId != skipPlayerId &&
        autoId != _focusedPlayerId) {
      final nonAutoFilled = seated
          .where((id) => id != autoId)
          .every((id) => texts[id]!.trim().isNotEmpty);
      if (nonAutoFilled) {
        texts[autoId] = '';
      }
    }

    final result = computeBalancingScore(texts);
    if (result == null) return;

    final skip = skipPlayerId ?? _focusedPlayerId;
    if (result.playerId == skip) return;

    final controller = _controllers[result.playerId]!;
    final next = '${result.score}';
    if (controller.text != next) {
      controller.text = next;
      controller.selection = TextSelection.collapsed(offset: next.length);
    }
    _autoFilledPlayerId = result.playerId;
  }

  Future<void> _handleSave() async {
    if (!_canSave || _saving) return;
    _autoCalcLast();
    setState(() => _saving = true);
    try {
      final seated = seatedPlayerIds(
        participantIds: _participantIds,
        sittingOutIds: _sittingOutIds,
      );
      final scores = <int, int>{
        for (final id in seated)
          id: int.tryParse(_controllers[id]!.text.trim()) ?? 0,
      };
      await widget.onSave(
        sittingOutIds: Set<int>.from(_sittingOutIds),
        scores: scores,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final seated = seatedPlayerIds(
      participantIds: _participantIds,
      sittingOutIds: _sittingOutIds,
    );
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.inline)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '半荘 ${widget.gameNumber}'
              '${widget.initialScores.isEmpty ? '（追加）' : '（編集）'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (_excess > 0) ...[
          const Text(
            '休み（タップで変更）',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: widget.players.map((p) {
              final resting = _sittingOutIds.contains(p.id);
              return FilterChip(
                label: Text(p.name),
                selected: resting,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      if (_sittingOutIds.length < _excess) {
                        _sittingOutIds.add(p.id);
                        _controllers[p.id]!.clear();
                      } else if (_sittingOutIds.length == _excess) {
                        _sittingOutIds.remove(_sittingOutIds.first);
                        _sittingOutIds.add(p.id);
                        _controllers[p.id]!.clear();
                      }
                    } else {
                      _sittingOutIds.remove(p.id);
                    }
                    _autoFilledPlayerId = null;
                  });
                },
              );
            }).toList(),
          ),
          if (!_canSave)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '休みはちょうど $_excess 人選んでください'
                '（卓は ${widget.seatCount} 人）',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
        ],
        ...widget.players.map((p) {
          final resting = _sittingOutIds.contains(p.id);
          if (resting) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '${p.name}（休み）',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                child: Text(
                  '休',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            );
          }
          final isLastHint = seated.length > 1 &&
              seated.last == p.id &&
              _autoFilledPlayerId == p.id;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: TextField(
              controller: _controllers[p.id],
              focusNode: _focusNodes[p.id],
              decoration: InputDecoration(
                labelText: p.name,
                border: const OutlineInputBorder(),
                helperText: isLastHint ? '他の点数から自動計算（上書き可）' : null,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
              ],
              onChanged: (_) {
                if (_autoFilledPlayerId == p.id) {
                  // 手動上書き: 自動再計算の対象から外す
                  _autoFilledPlayerId = null;
                }
                _autoCalcLast(skipPlayerId: p.id);
              },
              onEditingComplete: () {
                _autoCalcLast();
                FocusScope.of(context).nextFocus();
              },
              onTapOutside: (_) => _autoCalcLast(),
            ),
          );
        }),
        if (widget.inline) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (widget.onCancel != null)
                TextButton(
                  onPressed: _saving ? null : widget.onCancel,
                  child: const Text('キャンセル'),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: !_canSave || _saving ? null : _handleSave,
                child: Text(_saving ? '保存中…' : '保存'),
              ),
            ],
          ),
        ],
      ],
    );

    if (widget.inline) {
      return Material(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: body,
        ),
      );
    }

    return AlertDialog(
      title: Text('半荘 ${widget.gameNumber}'),
      content: SingleChildScrollView(child: body),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
                  widget.onCancel?.call();
                },
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: !_canSave || _saving ? null : _handleSave,
          child: Text(_saving ? '保存中…' : '保存'),
        ),
      ],
    );
  }
}
