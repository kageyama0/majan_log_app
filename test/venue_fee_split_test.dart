import 'package:flutter_test/flutter_test.dart';
import 'package:majan_log_app/utils/venue_fee_split.dart';

void main() {
  group('rankPlayersForVenueFee', () {
    test('場代前収支が最優先', () {
      final ranked = rankPlayersForVenueFee(
        playerIds: [1, 2, 3],
        preVenueBalanceYen: {1: 100, 2: 500, 3: 200},
        scorePoints: {1: 99, 2: 0, 3: 50},
      );
      expect(ranked, [2, 3, 1]);
    });

    test('収支同点なら順位点、それも同点なら id 昇順', () {
      final ranked = rankPlayersForVenueFee(
        playerIds: [3, 1, 2],
        preVenueBalanceYen: {1: 0, 2: 0, 3: 0},
        scorePoints: {1: 10, 2: 10, 3: 5},
      );
      expect(ranked, [1, 2, 3]);
    });
  });

  group('splitVenueFee', () {
    test('1000円・3人は100円単位で余りはトップ', () {
      final result = splitVenueFee(
        total: 1000,
        rankedPlayerIds: [10, 20, 30],
      );
      expect(result.unit, 100);
      expect(result.discarded, 0);
      expect(result.feesByPlayerId[10], 400);
      expect(result.feesByPlayerId[20], 300);
      expect(result.feesByPlayerId[30], 300);
      expect(result.allocatedTotal, 1000);
    });

    test('1070円・3人は非トップ300・トップ470', () {
      final result = splitVenueFee(
        total: 1070,
        rankedPlayerIds: [10, 20, 30],
      );
      expect(result.unit, 100);
      expect(result.discarded, 0);
      expect(result.feesByPlayerId[10], 470);
      expect(result.feesByPlayerId[20], 300);
      expect(result.feesByPlayerId[30], 300);
      expect(result.allocatedTotal, 1070);
    });

    test('1050円も非トップは100円単位・余りはトップ', () {
      final result = splitVenueFee(
        total: 1050,
        rankedPlayerIds: [1, 2, 3],
      );
      expect(result.unit, 100);
      expect(result.discarded, 0);
      expect(result.feesByPlayerId, {1: 450, 2: 300, 3: 300});
      expect(result.allocatedTotal, 1050);
    });

    test('余りはすべてトップのみが負担', () {
      final result = splitVenueFee(
        total: 1000,
        rankedPlayerIds: [1, 2, 3, 4, 5, 6, 7],
      );
      expect(result.unit, 100);
      // 非トップは各 100、余り 400 はトップのみ
      expect(result.feesByPlayerId[1], 400);
      expect(result.feesByPlayerId[2], 100);
      expect(result.feesByPlayerId[3], 100);
      expect(result.feesByPlayerId[4], 100);
      expect(result.feesByPlayerId[7], 100);
      expect(result.allocatedTotal, 1000);
    });

    test('100円未満の端数もトップが負担（切捨てなし）', () {
      final result = splitVenueFee(
        total: 1005,
        rankedPlayerIds: [1, 2],
      );
      expect(result.unit, 100);
      expect(result.discarded, 0);
      expect(result.allocatedTotal, 1005);
      expect(result.feesByPlayerId[1], 505);
      expect(result.feesByPlayerId[2], 500);
    });
  });
}
