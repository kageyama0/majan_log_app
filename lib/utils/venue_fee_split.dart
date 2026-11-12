/// 場代端数配分の結果。
class VenueFeeSplitResult {
  /// プレイヤー ID → 負担額（円）。合計は [allocatedTotal]。
  final Map<int, int> feesByPlayerId;

  /// 非トップに使う単位（常に 100）。
  final int unit;

  /// 配分できず切り捨てた端数（現行アルゴリズムでは常に 0）。
  final int discarded;

  /// 実際に配分した合計（= total - discarded）。
  int get allocatedTotal =>
      feesByPlayerId.values.fold(0, (sum, v) => sum + v);

  const VenueFeeSplitResult({
    required this.feesByPlayerId,
    required this.unit,
    required this.discarded,
  });
}

/// 「一番勝ってる」順位（先頭が最上位）。
///
/// 判定:
/// 1. 場代控除前の合計収支（順位点¥ + チップ¥）が高い順
/// 2. 同点なら当日の順位点合計が高い順
/// 3. それでも同点なら playerId 昇順（安定・決定的）
///
/// 全員同点などで勝ちが決まらない場合も 3 により一意に並べる。
List<int> rankPlayersForVenueFee({
  required Iterable<int> playerIds,
  required Map<int, int> preVenueBalanceYen,
  required Map<int, int> scorePoints,
}) {
  final ids = playerIds.toList();
  ids.sort((a, b) {
    final byBalance = (preVenueBalanceYen[b] ?? 0)
        .compareTo(preVenueBalanceYen[a] ?? 0);
    if (byBalance != 0) return byBalance;
    final byScore =
        (scorePoints[b] ?? 0).compareTo(scorePoints[a] ?? 0);
    if (byScore != 0) return byScore;
    return a.compareTo(b);
  });
  return ids;
}

/// 場代 [total] を [rankedPlayerIds]（勝ち順）で割る。
///
/// - **トップ以外**は **100 円単位**（切り捨て）
/// - **余った金額はすべてトップ**が負担（1 円単位の端数も含む）
///
/// 例: 全体 1070・3 人 → 非トップ 300 ずつ・トップ 470。
/// 例: 全体 1000・3 人 → 非トップ 300 ずつ・トップ 400。
VenueFeeSplitResult splitVenueFee({
  required int total,
  required List<int> rankedPlayerIds,
}) {
  final n = rankedPlayerIds.length;
  if (total <= 0 || n == 0) {
    return VenueFeeSplitResult(
      feesByPlayerId: {for (final id in rankedPlayerIds) id: 0},
      unit: 100,
      discarded: 0,
    );
  }

  const unit = 100;
  // 均等割の切り捨てを 100 円単位にした額が非トップの負担。
  final nonTopFee = (total ~/ n ~/ unit) * unit;

  final fees = <int, int>{};
  var othersTotal = 0;
  for (var i = 1; i < n; i++) {
    fees[rankedPlayerIds[i]] = nonTopFee;
    othersTotal += nonTopFee;
  }
  // 余り（100 円未満の端数 + 均等割の余り）はすべてトップへ。
  fees[rankedPlayerIds[0]] = total - othersTotal;

  return VenueFeeSplitResult(
    feesByPlayerId: fees,
    unit: unit,
    discarded: 0,
  );
}
