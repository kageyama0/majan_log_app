import 'package:flutter_test/flutter_test.dart';
import 'package:majan_log_app/utils/settlement_transfers.dart';

void main() {
  const names = {1: 'A', 2: 'B', 3: 'C', 4: 'D'};

  Map<int, int> paidBy(List<SettlementTransfer> transfers) {
    final out = <int, int>{};
    for (final t in transfers) {
      final id = t.fromPlayerId;
      if (id == null) continue;
      out[id] = (out[id] ?? 0) + t.amount;
    }
    return out;
  }

  Map<int, int> receivedBy(List<SettlementTransfer> transfers) {
    final out = <int, int>{};
    for (final t in transfers) {
      final id = t.toPlayerId;
      if (id == null) continue;
      out[id] = (out[id] ?? 0) + t.amount;
    }
    return out;
  }

  int sinkReceived(List<SettlementTransfer> transfers) => transfers
      .where((t) => t.toPlayerId == null)
      .fold<int>(0, (s, t) => s + t.amount);

  group('calcSettlementTransfers', () {
    test('2債務者 / 2債権者（ゼロ和）', () {
      final balances = {1: -3000, 2: -2000, 3: 4000, 4: 1000};
      final transfers = calcSettlementTransfers(
        balances: balances,
        playerNames: names,
      );

      expect(paidBy(transfers), {1: 3000, 2: 2000});
      expect(receivedBy(transfers), {3: 4000, 4: 1000});
      expect(sinkReceived(transfers), 0);
      expect(
        transfers.map((t) => '${t.fromName}→${t.toName}:${t.amount}').toList(),
        ['A→C:3000', 'B→C:1000', 'B→D:1000'],
      );
    });

    test('2債務者 / 1債権者（ゼロ和）', () {
      final balances = {1: -3000, 2: -2000, 3: 5000};
      final transfers = calcSettlementTransfers(
        balances: balances,
        playerNames: names,
      );

      expect(paidBy(transfers), {1: 3000, 2: 2000});
      expect(receivedBy(transfers), {3: 5000});
      expect(
        transfers.map((t) => '${t.fromName}→${t.toName}:${t.amount}').toList(),
        ['A→C:3000', 'B→C:2000'],
      );
    });

    test('各人の支払・受取が |totalYen| と一致する', () {
      final balances = {1: -1200, 2: 800, 3: -500, 4: 900};
      final transfers = calcSettlementTransfers(
        balances: balances,
        playerNames: names,
      );

      final paid = paidBy(transfers);
      final received = receivedBy(transfers);
      for (final e in balances.entries) {
        if (e.value < 0) {
          expect(paid[e.key], -e.value, reason: 'debtor ${e.key}');
        } else if (e.value > 0) {
          expect(received[e.key], e.value, reason: 'creditor ${e.key}');
        } else {
          expect(paid.containsKey(e.key), isFalse);
          expect(received.containsKey(e.key), isFalse);
        }
      }
    });

    test('場代控除で非ゼロ和でも全債務者が支払いに現れ金額一致', () {
      // 再現: 債権者合計 500 < 債務 |合計| 3500 → 旧実装は B→A:500 の1件だけ
      final balances = {1: 500, 2: -2000, 3: -1500};
      final transfers = calcSettlementTransfers(
        balances: balances,
        playerNames: names,
      );

      expect(paidBy(transfers), {2: 2000, 3: 1500});
      expect(receivedBy(transfers), {1: 500});
      expect(sinkReceived(transfers), 3000);
      expect(transfers.any((t) => t.fromName == 'B'), isTrue);
      expect(transfers.any((t) => t.fromName == 'C'), isTrue);
      // 実プレイヤーへの支払いを場代より優先
      expect(transfers.first.fromName, 'B');
      expect(transfers.first.toName, 'A');
      expect(transfers.first.amount, 500);
    });

    test('場代あり・4人（トップ以外100円単位想定の端数後）', () {
      final balances = {1: 4750, 2: -2250, 3: -1750, 4: -1750};
      final transfers = calcSettlementTransfers(
        balances: balances,
        playerNames: names,
      );

      expect(paidBy(transfers), {2: 2250, 3: 1750, 4: 1750});
      expect(receivedBy(transfers), {1: 4750});
      expect(sinkReceived(transfers), 1000);
    });

    test('全員ゼロなら空', () {
      expect(
        calcSettlementTransfers(
          balances: {1: 0, 2: 0},
          playerNames: names,
        ),
        isEmpty,
      );
    });
  });
}
