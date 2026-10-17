import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:majan_log_app/utils/score_balance.dart';
import 'package:majan_log_app/utils/sit_out_rotation.dart';

/// 1半荘分のセル直打ち状態（休みあり／なし共用）。
class HanchanRowEditor {
  final int? gameId; // null = 未保存の新規行
  final int gameNumber;
  final List<int> playerIds;
  final int seatCount;
  final Map<int, TextEditingController> controllers;
  final Map<int, FocusNode> focusNodes;
  Set<int> sittingOutIds;
  int? autoFilledPlayerId;
  bool saving = false;

  /// ローカル編集中（ストリーム同期で上書きしない）
  bool dirty = false;

  /// 最後に DB へ書いたスコア（変更検知用）
  Map<int, int>? lastPersisted;

  HanchanRowEditor({
    required this.gameNumber,
    required this.playerIds,
    required this.seatCount,
    this.gameId,
    Map<int, int>? initialScores,
    Set<int>? initialSittingOutIds,
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
        sittingOutIds = _resolveInitialSitOut(
          playerIds: playerIds,
          seatCount: seatCount,
          gameNumber: gameNumber,
          initialScores: initialScores,
          initialSittingOutIds: initialSittingOutIds,
        ),
        lastPersisted =
            initialScores == null ? null : Map<int, int>.from(initialScores) {
    for (final id in sittingOutIds) {
      controllers[id]?.clear();
    }
  }

  static Set<int> _resolveInitialSitOut({
    required List<int> playerIds,
    required int seatCount,
    required int gameNumber,
    Map<int, int>? initialScores,
    Set<int>? initialSittingOutIds,
  }) {
    final excess = playerIds.length - seatCount;
    if (excess <= 0) return {};
    if (initialSittingOutIds != null) {
      return Set<int>.from(initialSittingOutIds);
    }
    if (initialScores != null) {
      return playerIds.where((id) => !initialScores.containsKey(id)).toSet();
    }
    return defaultSittingOutPlayerIds(
      participantIds: playerIds,
      seatCount: seatCount,
      gameNumber: gameNumber,
    ).toSet();
  }

  int get excess => playerIds.length - seatCount;

  bool get hasSitOut => excess > 0;

  List<int> get seatedIds => seatedPlayerIds(
        participantIds: playerIds,
        sittingOutIds: sittingOutIds,
      );

  bool get sitOutCountOk =>
      !hasSitOut || sittingOutIds.length == excess;

  bool get anyFocused => focusNodes.values.any((n) => n.hasFocus);

  bool isSittingOut(int playerId) => sittingOutIds.contains(playerId);

  void syncFromScores(Map<int, int> scores) {
    if (anyFocused || saving || dirty) return;
    if (hasSitOut) {
      sittingOutIds =
          playerIds.where((id) => !scores.containsKey(id)).toSet();
    } else {
      sittingOutIds = {};
    }
    for (final id in playerIds) {
      if (sittingOutIds.contains(id)) {
        if (controllers[id]!.text.isNotEmpty) {
          controllers[id]!.clear();
        }
      } else {
        final next = scores.containsKey(id) ? '${scores[id]}' : '';
        if (controllers[id]!.text != next) {
          controllers[id]!.text = next;
        }
      }
    }
    lastPersisted = Map<int, int>.from(scores);
    autoFilledPlayerId = null;
  }

  /// 休みトグル。枠が満杯なら入れ替え。
  void toggleSitOut(int playerId) {
    if (!hasSitOut || !playerIds.contains(playerId)) return;
    dirty = true;
    autoFilledPlayerId = null;
    if (sittingOutIds.contains(playerId)) {
      sittingOutIds.remove(playerId);
      return;
    }
    if (sittingOutIds.length < excess) {
      sittingOutIds.add(playerId);
      controllers[playerId]!.clear();
      return;
    }
    // 枠いっぱい: 先頭と入れ替え
    final removed = sittingOutIds.first;
    sittingOutIds.remove(removed);
    sittingOutIds.add(playerId);
    controllers[playerId]!.clear();
  }

  void dispose() {
    for (final n in focusNodes.values) {
      n.dispose();
    }
    for (final c in controllers.values) {
      c.dispose();
    }
  }

  /// 席上メンバーだけでゼロ和自動記入を試す。
  void autoCalcLast({int? skipPlayerId}) {
    final seated = seatedIds;
    if (seated.isEmpty) return;

    final texts = <int, String>{
      for (final id in seated) id: controllers[id]!.text,
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
        seated.contains(autoId) &&
        autoId != skipPlayerId &&
        autoId != focusedId) {
      final othersFilled = seated
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
    dirty = true;
  }

  /// 席上メンバー全員分パースでき、休み人数も正しければスコア Map。
  Map<int, int>? parsedScoresOrNull() {
    if (!sitOutCountOk) return null;
    final result = <int, int>{};
    for (final id in seatedIds) {
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
    // 休みメンバー集合も一致しているか
    if (hasSitOut) {
      final prevSit =
          playerIds.where((id) => !prev.containsKey(id)).toSet();
      if (prevSit.length != sittingOutIds.length ||
          !prevSit.containsAll(sittingOutIds)) {
        return false;
      }
    }
    return true;
  }

  /// 席上の次のプレイヤーへフォーカス。いなければ unfocus。
  void focusNextSeated(int currentPlayerId) {
    final seated = seatedIds;
    final idx = seated.indexOf(currentPlayerId);
    if (idx >= 0 && idx < seated.length - 1) {
      focusNodes[seated[idx + 1]]!.requestFocus();
    } else {
      focusNodes[currentPlayerId]?.unfocus();
    }
  }

  int? get firstSeatedId {
    final seated = seatedIds;
    return seated.isEmpty ? null : seated.first;
  }

  bool isLastSeated(int playerId) {
    final seated = seatedIds;
    return seated.isNotEmpty && seated.last == playerId;
  }
}

/// 表セル内の数値入力（枠なし・中央寄せ）。
///
/// 休み指定はプレイヤー名ヘッダーの長押しで行う（TextField と競合しない）。
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
    return ListenableBuilder(
      listenable: Listenable.merge([focusNode, controller]),
      builder: (context, _) {
        final v = int.tryParse(controller.text.trim());
        final field = TextField(
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
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            hintText: '—',
            hintStyle: TextStyle(color: Colors.black26),
          ),
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          onTapOutside: (_) => onEditingComplete(),
        );

        Widget body = ColoredBox(
          color: focusNode.hasFocus
              ? Colors.blue.shade50
              : Colors.transparent,
          child: field,
        );

        if (onLongPress != null) {
          // 余剰なし: 長押し削除（TextField と競合しやすいので #列推奨だが互換で残す）
          body = GestureDetector(
            onLongPress: onLongPress,
            behavior: HitTestBehavior.translucent,
            child: body,
          );
        }

        return body;
      },
    );
  }
}

/// 休みセル。「休」表示。タップで席に戻す。
class SitOutSpreadsheetCell extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const SitOutSpreadsheetCell({
    super.key,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade100,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '休',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'タップで復帰',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
