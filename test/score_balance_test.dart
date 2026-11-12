import 'package:flutter_test/flutter_test.dart';
import 'package:majan_log_app/utils/score_balance.dart';

void main() {
  group('computeBalancingScore', () {
    test('四麻: 3人入力済みなら4人目はゼロ和', () {
      final result = computeBalancingScore({
        1: '30',
        2: '10',
        3: '-20',
        4: '',
      });
      expect(result, isNotNull);
      expect(result!.playerId, 4);
      expect(result.score, -20); // 30+10-20=20 → -20
    });

    test('三麻: 2人入力済みなら3人目はゼロ和', () {
      final result = computeBalancingScore({
        1: '40',
        2: '-15',
        3: '',
      });
      expect(result, isNotNull);
      expect(result!.playerId, 3);
      expect(result.score, -25);
    });

    test('未入力が2人以上なら null', () {
      expect(
        computeBalancingScore({
          1: '10',
          2: '',
          3: '',
          4: '0',
        }),
        isNull,
      );
    });

    test('全員入力済みなら null', () {
      expect(
        computeBalancingScore({
          1: '10',
          2: '20',
          3: '-15',
          4: '-15',
        }),
        isNull,
      );
    });

    test('合計0のときの最後の人は0', () {
      final result = computeBalancingScore({
        1: '10',
        2: '-5',
        3: '-5',
        4: '',
      });
      expect(result!.score, 0);
    });

    test('パース不能は未入力扱い', () {
      final result = computeBalancingScore({
        1: '10',
        2: '20',
        3: '-30',
        4: '-',
      });
      expect(result, isNotNull);
      expect(result!.playerId, 4);
      expect(result.score, 0);
    });
  });

  group('computeZeroSumAutoFillOnFocus', () {
    test('n-1 入力後、空き欄フォーカスでゼロ和', () {
      final result = computeZeroSumAutoFillOnFocus(
        focusedPlayerId: 4,
        textsByPlayerId: {
          1: '5',
          2: '-2',
          3: '1',
          4: '',
        },
      );
      expect(result, isNotNull);
      expect(result!.playerId, 4);
      expect(result.value, -4); // 5-2+1=4 → -4
    });

    test('未入力が2人以上なら null', () {
      expect(
        computeZeroSumAutoFillOnFocus(
          focusedPlayerId: 4,
          textsByPlayerId: {
            1: '5',
            2: '',
            3: '1',
            4: '',
          },
        ),
        isNull,
      );
    });

    test('手動入力済みの最終欄は上書きしない', () {
      expect(
        computeZeroSumAutoFillOnFocus(
          focusedPlayerId: 4,
          textsByPlayerId: {
            1: '5',
            2: '-2',
            3: '1',
            4: '99',
          },
        ),
        isNull,
      );
    });

    test('自動記入済みなら再フォーカスで再計算', () {
      final result = computeZeroSumAutoFillOnFocus(
        focusedPlayerId: 4,
        textsByPlayerId: {
          1: '10',
          2: '-2',
          3: '1',
          4: '-4',
        },
        autoFilledPlayerId: 4,
      );
      expect(result, isNotNull);
      expect(result!.value, -9); // 10-2+1=9 → -9
    });

    test('マイナス合計でもゼロ和（差枚マイナス維持）', () {
      final result = computeZeroSumAutoFillOnFocus(
        focusedPlayerId: 3,
        textsByPlayerId: {
          1: '-10',
          2: '-5',
          3: '',
        },
      );
      expect(result, isNotNull);
      expect(result!.value, 15);
    });
  });
}
