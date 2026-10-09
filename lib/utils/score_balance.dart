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
