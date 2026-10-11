import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:majan_log_app/utils/score_balance.dart';

/// 1半荘分のセル直打ち状態（余剰なしスプレッドシート用）。
class HanchanRowEditor {
  final int? gameId; // null = 未保存の新規行
  final int gameNumber;
  final List<int> playerIds;
  final Map<int, TextEditingController> controllers;
  final Map<int, FocusNode> focusNodes;
  int? autoFilledPlayerId;
  bool saving = false;

  /// 最後に DB へ書いたスコア（変更検知用）
  Map<int, int>? lastPersisted;

  HanchanRowEditor({
    required this.gameNumber,
    required this.playerIds,
    this.gameId,
    Map<int, int>? initialScores,
  })  : controllers = {
          for (final id in playerIds)
            id: TextEditingController(
              text: initialScores != null && initialScores.containsKey(id)
                  ? '${initialScores[id]}'
                  : '',
            ),
        },
        focusNodes = {
          for (final id in playerIds) id: FocusNode(),
        },
        lastPersisted =
            initialScores == null ? null : Map<int, int>.from(initialScores);

  bool get anyFocused => focusNodes.values.any((n) => n.hasFocus);

  void syncFromScores(Map<int, int> scores) {
    if (anyFocused || saving) return;
    for (final id in playerIds) {
      final next = scores.containsKey(id) ? '${scores[id]}' : '';
      if (controllers[id]!.text != next) {
        controllers[id]!.text = next;
      }
    }
    lastPersisted = Map<int, int>.from(scores);
    autoFilledPlayerId = null;
  }

  void dispose() {
    for (final n in focusNodes.values) {
      n.dispose();
    }
    for (final c in controllers.values) {
      c.dispose();
    }
  }

  /// 入力中プレイヤー以外でゼロ和自動記入を試す。
  void autoCalcLast({int? skipPlayerId}) {
    final texts = <int, String>{
      for (final id in playerIds) id: controllers[id]!.text,
    };

    final autoId = autoFilledPlayerId;
    int? focusedId;
    for (final e in focusNodes.entries) {
      if (e.value.hasFocus) {
        focusedId = e.key;
        break;
      }
    }

    if (autoId != null &&
        playerIds.contains(autoId) &&
        autoId != skipPlayerId &&
        autoId != focusedId) {
      final othersFilled = playerIds
          .where((id) => id != autoId)
          .every((id) => texts[id]!.trim().isNotEmpty);
      if (othersFilled) {
        texts[autoId] = '';
      }
    }

    final result = computeBalancingScore(texts);
    if (result == null) return;

    final skip = skipPlayerId ?? focusedId;
    if (result.playerId == skip) return;

    final controller = controllers[result.playerId]!;
    final next = '${result.score}';
    if (controller.text != next) {
      controller.text = next;
      controller.selection = TextSelection.collapsed(offset: next.length);
    }
    autoFilledPlayerId = result.playerId;
  }

  /// 全員分パースできればスコア Map、否则 null。
  Map<int, int>? parsedScoresOrNull() {
    final result = <int, int>{};
    for (final id in playerIds) {
      final text = controllers[id]!.text.trim();
      if (text.isEmpty) return null;
      final v = int.tryParse(text);
      if (v == null) return null;
      result[id] = v;
    }
    return result;
  }

  bool isUnchanged(Map<int, int> scores) {
    final prev = lastPersisted;
    if (prev == null || prev.length != scores.length) return false;
    for (final e in scores.entries) {
      if (prev[e.key] != e.value) return false;
    }
    return true;
  }
}

/// 表セル内の数値入力（枠なし・中央寄せ）。
class ScoreSpreadsheetCell extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLastInRow;
  final ValueChanged<String> onChanged;
  final VoidCallback onEditingComplete;
  final VoidCallback? onLongPress;

  const ScoreSpreadsheetCell({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isLastInRow,
    required this.onChanged,
    required this.onEditingComplete,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: ListenableBuilder(
        listenable: Listenable.merge([focusNode, controller]),
        builder: (context, _) {
          final v = int.tryParse(controller.text.trim());
          return ColoredBox(
            color: focusNode.hasFocus
                ? Colors.blue.shade50
                : Colors.transparent,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: (v != null && v < 0) ? Colors.red : Colors.black,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(signed: true),
              textInputAction:
                  isLastInRow ? TextInputAction.done : TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
              ],
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                hintText: '—',
                hintStyle: TextStyle(color: Colors.black26),
              ),
              onChanged: onChanged,
              onEditingComplete: onEditingComplete,
              onTapOutside: (_) => onEditingComplete(),
            ),
          );
        },
      ),
    );
  }
}
