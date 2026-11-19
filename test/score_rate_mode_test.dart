import 'package:flutter_test/flutter_test.dart';
import 'package:majan_log_app/utils/score_rate_mode.dart';

void main() {
  group('ScoreRateMode.scoreToYen', () {
    test('円換算は score × scoreRate', () {
      expect(
        ScoreRateMode.scoreToYen(
          scorePoints: 45,
          scoreRate: 50,
          chipRate: 100,
          mode: ScoreRateMode.yen,
        ),
        2250,
      );
    });

    test('チップ換算は score × scoreRate × chipRate', () {
      expect(
        ScoreRateMode.scoreToYen(
          scorePoints: 45,
          scoreRate: 1,
          chipRate: 100,
          mode: ScoreRateMode.chip,
        ),
        4500,
      );
    });

    test('負の順位点も符号を保つ', () {
      expect(
        ScoreRateMode.scoreToYen(
          scorePoints: -20,
          scoreRate: 1,
          chipRate: 200,
          mode: ScoreRateMode.chip,
        ),
        -4000,
      );
    });
  });

  group('ScoreRateMode.scoreToChips', () {
    test('円換算時は 0', () {
      expect(
        ScoreRateMode.scoreToChips(
          scorePoints: 45,
          scoreRate: 50,
          mode: ScoreRateMode.yen,
        ),
        0,
      );
    });

    test('チップ換算時は score × scoreRate', () {
      expect(
        ScoreRateMode.scoreToChips(
          scorePoints: 45,
          scoreRate: 2,
          mode: ScoreRateMode.chip,
        ),
        90,
      );
    });
  });
}
