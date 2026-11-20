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

    test('チップ換算も score × scoreRate（単一レート）', () {
      expect(
        ScoreRateMode.scoreToYen(
          scorePoints: 45,
          scoreRate: 100,
          chipRate: 999, // 無視される
          mode: ScoreRateMode.chip,
        ),
        4500,
      );
    });

    test('負の順位点も符号を保つ', () {
      expect(
        ScoreRateMode.scoreToYen(
          scorePoints: -20,
          scoreRate: 200,
          chipRate: 1,
          mode: ScoreRateMode.chip,
        ),
        -4000,
      );
    });
  });

  group('ScoreRateMode.chipDiffToYen', () {
    test('円換算は chipDiff × chipRate', () {
      expect(
        ScoreRateMode.chipDiffToYen(
          chipDiff: 3,
          scoreRate: 50,
          chipRate: 100,
          mode: ScoreRateMode.yen,
        ),
        300,
      );
    });

    test('チップ換算は chipDiff × scoreRate', () {
      expect(
        ScoreRateMode.chipDiffToYen(
          chipDiff: 3,
          scoreRate: 100,
          chipRate: 999,
          mode: ScoreRateMode.chip,
        ),
        300,
      );
    });
  });

  group('ScoreRateMode.scoreToChips', () {
    test('円換算時は 0', () {
      expect(
        ScoreRateMode.scoreToChips(
          scorePoints: 45,
          mode: ScoreRateMode.yen,
        ),
        0,
      );
    });

    test('チップ換算時は 1点=1枚', () {
      expect(
        ScoreRateMode.scoreToChips(
          scorePoints: 45,
          mode: ScoreRateMode.chip,
        ),
        45,
      );
    });
  });

  group('ScoreRateMode.homeRateLabel', () {
    test('チップ換算は単一レートのみ表示', () {
      expect(
        ScoreRateMode.homeRateLabel(
          scoreRate: 100,
          chipRate: 999,
          mode: ScoreRateMode.chip,
        ),
        '点100枚/円',
      );
    });
  });
}
