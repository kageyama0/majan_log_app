import 'package:flutter_test/flutter_test.dart';
import 'package:majan_log_app/utils/player_stats_calc.dart';

void main() {
  group('rentaiRate', () {
    test('1着+2着 / 半荘数', () {
      expect(
        rentaiRate(
          firstPlaceCount: 3,
          secondPlaceCount: 2,
          totalGames: 10,
        ),
        0.5,
      );
    });

    test('半荘0は null', () {
      expect(
        rentaiRate(
          firstPlaceCount: 0,
          secondPlaceCount: 0,
          totalGames: 0,
        ),
        isNull,
      );
    });
  });

  group('chipNetBalance', () {
    test('借りはマイナス補正（精算と同じ）', () {
      expect(
        chipNetBalance(
          chipDiff: 8,
          borrowedAmount: 5,
          lentAmount: 0,
        ),
        3,
      );
    });

    test('貸しはプラス補正', () {
      expect(
        chipNetBalance(
          chipDiff: -3,
          borrowedAmount: 0,
          lentAmount: 3,
        ),
        0,
      );
    });

    test('貸借両方', () {
      expect(
        chipNetBalance(
          chipDiff: 10,
          borrowedAmount: 4,
          lentAmount: 2,
        ),
        8,
      );
    });
  });
}
