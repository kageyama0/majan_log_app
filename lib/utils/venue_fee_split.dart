/// 場代端数配分の結果。
class VenueFeeSplitResult {
  /// プレイヤー ID → 負担額（円）。合計は [allocatedTotal]。
  final Map<int, int> feesByPlayerId;

  /// 使った単位（100 or 10）。
  final int unit;

  /// 10 円未満で配分できず切り捨てた端数（通常 0）。
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
/// 全員同点などで勝ちが決まらない場合も 3 により一意に並べ、
/// 端数ユニットは並べた先頭から順に載せる。
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
/// - 基本は **100 円単位**（[total] が 100 の倍数のとき）
/// - そうでなければ **10 円単位**
/// - 1 円単位では割らない。10 円未満の端数は [VenueFeeSplitResult.discarded]
/// - 各人の基本額を揃えたうえで、余った単位は勝ち側（リスト先頭）から順に +1 単位
///
/// 例: 全体 1000・3 人 → 単位 100・基本 300・余り 100
/// → 1 位 400、他 300 ずつ。
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

  late final int unit;
  late final int allocatable;
  if (total % 100 == 0) {
    unit = 100;
    allocatable = total;
  } else {
    unit = 10;
    allocatable = (total ~/ 10) * 10;
  }
  final discarded = total - allocatable;

  final chunks = allocatable ~/ unit;
  final baseChunks = chunks ~/ n;
  final extraChunks = chunks % n;

  final fees = <int, int>{};
  for (var i = 0; i < n; i++) {
    final extra = i < extraChunks ? 1 : 0;
    fees[rankedPlayerIds[i]] = (baseChunks + extra) * unit;
  }

  return VenueFeeSplitResult(
    feesByPlayerId: fees,
    unit: unit,
    discarded: discarded,
  );
}
