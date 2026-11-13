/// 精算の 1 件の支払い提案（A → B）。
class SettlementTransfer {
  /// 支払い元プレイヤー ID。仮想債務者のときは null。
  final int? fromPlayerId;

  /// 支払い先プレイヤー ID。仮想債権者（場代など）のときは null。
  final int? toPlayerId;

  final String fromName;
  final String toName;
  final int amount;

  const SettlementTransfer({
    required this.fromPlayerId,
    required this.toPlayerId,
    required this.fromName,
    required this.toName,
    required this.amount,
  });

  @override
  String toString() => '$fromName → $toName: $amount';
}

const int _kSinkId = -1;
const int _kSourceId = -2;

/// [balances]（プレイヤー ID → 合計収支円）から greedy で支払い提案を作る。
///
/// 場代控除後の合計はゼロ和にならないため、合計が負なら [sinkName] を
/// 仮想債権者として足し、正なら [sourceName] を仮想債務者として足す。
/// これにより各債務者の支払合計が |balances| と一致する。
///
/// 実プレイヤーへの支払いを場代より優先する（同額なら ID 昇順で安定）。
List<SettlementTransfer> calcSettlementTransfers({
  required Map<int, int> balances,
  required Map<int, String> playerNames,
  String sinkName = '場代',
  String sourceName = '調整',
}) {
  if (balances.isEmpty) return const [];

  final remaining = <int, int>{
    for (final e in balances.entries) e.key: e.value,
  };
  final names = <int, String>{
    for (final e in playerNames.entries) e.key: e.value,
  };

  final sum = remaining.values.fold<int>(0, (a, b) => a + b);
  if (sum < 0) {
    remaining[_kSinkId] = -sum;
    names[_kSinkId] = sinkName;
  } else if (sum > 0) {
    remaining[_kSourceId] = -sum;
    names[_kSourceId] = sourceName;
  }

  final debtors = remaining.entries.where((e) => e.value < 0).toList()
    ..sort((a, b) {
      final byAmount = a.value.compareTo(b.value);
      if (byAmount != 0) return byAmount;
      return a.key.compareTo(b.key);
    });

  // 仮想債権者（場代）は後回しにし、まず実プレイヤーへ払う。
  final creditors = remaining.entries.where((e) => e.value > 0).toList()
    ..sort((a, b) {
      final aVirtual = a.key < 0;
      final bVirtual = b.key < 0;
      if (aVirtual != bVirtual) return aVirtual ? 1 : -1;
      final byAmount = b.value.compareTo(a.value);
      if (byAmount != 0) return byAmount;
      return a.key.compareTo(b.key);
    });

  final transfers = <SettlementTransfer>[];
  var i = 0;
  var j = 0;
  while (i < debtors.length && j < creditors.length) {
    final debtorId = debtors[i].key;
    final creditorId = creditors[j].key;
    final debtAmt = -remaining[debtorId]!;
    final creditAmt = remaining[creditorId]!;
    final transfer = debtAmt < creditAmt ? debtAmt : creditAmt;

    if (transfer <= 0) break;

    transfers.add(
      SettlementTransfer(
        fromPlayerId: debtorId < 0 ? null : debtorId,
        toPlayerId: creditorId < 0 ? null : creditorId,
        fromName: names[debtorId]!,
        toName: names[creditorId]!,
        amount: transfer,
      ),
    );

    remaining[debtorId] = remaining[debtorId]! + transfer;
    remaining[creditorId] = remaining[creditorId]! - transfer;

    if (remaining[debtorId] == 0) i++;
    if (remaining[creditorId] == 0) j++;
  }

  return transfers;
}
