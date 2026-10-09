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
}
