/// 点棒合計がゼロ和になるよう、未入力がちょうど1人のときの点数を求める。
///
/// [scoresByPlayerId] は席上メンバーのみ。値が `null` またはパース不能は未入力。
/// 未入力が1人のとき、そのプレイヤー ID と埋めるべき点数を返す。それ以外は `null`。
({int playerId, int score})? computeBalancingScore(
  Map<int, String> scoresByPlayerId,
) {
  int? emptyPlayerId;
  var emptyCount = 0;
  var filledSum = 0;

  for (final entry in scoresByPlayerId.entries) {
    final text = entry.value.trim();
    if (text.isEmpty) {
      emptyPlayerId = entry.key;
      emptyCount++;
      continue;
    }
    final parsed = int.tryParse(text);
    if (parsed == null) {
      emptyPlayerId = entry.key;
      emptyCount++;
      continue;
    }
    filledSum += parsed;
  }

  if (emptyCount != 1 || emptyPlayerId == null) {
    return null;
  }
  return (playerId: emptyPlayerId, score: -filledSum);
}

/// フォーカスした欄が「唯一の未入力」ならゼロ和で埋める値を返す。
///
/// 順位点・チップ差枚など、整数のゼロ和入力で共用。
/// [autoFilledPlayerId] が focused と同じなら、その欄は空として再計算する。
/// 手動入力済み（非空かつ autoFilled でない）は null。
({int playerId, int value})? computeZeroSumAutoFillOnFocus({
  required int focusedPlayerId,
  required Map<int, String> textsByPlayerId,
  int? autoFilledPlayerId,
}) {
  if (!textsByPlayerId.containsKey(focusedPlayerId)) return null;

  final focusedText = textsByPlayerId[focusedPlayerId]!.trim();
  // 手動上書き済みなら触らない
  if (focusedText.isNotEmpty && autoFilledPlayerId != focusedPlayerId) {
    return null;
  }

  final texts = Map<int, String>.from(textsByPlayerId);
  // 自動記入済みなら空として再計算
  if (autoFilledPlayerId == focusedPlayerId) {
    texts[focusedPlayerId] = '';
  }

  final result = computeBalancingScore(texts);
  if (result == null || result.playerId != focusedPlayerId) return null;
  return (playerId: result.playerId, value: result.score);
}
