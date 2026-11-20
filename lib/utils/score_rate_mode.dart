/// 順位点レートの換算モード（[GameDays.scoreRateMode]）。
///
/// - [yen]: 順位点 × scoreRate → 円。チップ差は別途 chipRate（円/枚）。
/// - [chip]: 順位点 × scoreRate → 円（単一レート・単位 枚/円）。
///   チップ差も同じ scoreRate を円換算に使う（独立した chipRate 入力はなし）。
abstract final class ScoreRateMode {
  static const int yen = 0;
  static const int chip = 1;

  static bool isChip(int mode) => mode == chip;

  static bool isYen(int mode) => mode != chip;

  /// 順位点合計を円に換算する。
  ///
  /// 円換算・チップ換算とも `score × scoreRate`。
  /// [chipRate] / [mode] は呼び出し側の対称性のため受け取るが、換算には使わない
  ///（チップ換算では保存・migration 時に chipRate を scoreRate へ畳み込む）。
  static int scoreToYen({
    required int scorePoints,
    required int scoreRate,
    required int chipRate,
    required int mode,
  }) {
    assert(chipRate >= 0);
    assert(mode == yen || mode == chip);
    return scorePoints * scoreRate;
  }

  /// チップ差枚数を円に換算するレート（円/枚相当）。
  ///
  /// - 円換算: [chipRate]
  /// - チップ換算: [scoreRate]（単一レートを共用）
  static int chipYenRate({
    required int scoreRate,
    required int chipRate,
    required int mode,
  }) {
    return isChip(mode) ? scoreRate : chipRate;
  }

  /// チップ差枚 → 円。
  static int chipDiffToYen({
    required int chipDiff,
    required int scoreRate,
    required int chipRate,
    required int mode,
  }) {
    return chipDiff *
        chipYenRate(
          scoreRate: scoreRate,
          chipRate: chipRate,
          mode: mode,
        );
  }

  /// チップ換算時の順位点→チップ枚数（1点=1枚）。円換算時は 0。
  static int scoreToChips({
    required int scorePoints,
    required int mode,
  }) {
    if (!isChip(mode)) return 0;
    return scorePoints;
  }

  static String scoreRateSuffix(int mode) =>
      isChip(mode) ? '枚/円' : '円/点';

  static String homeRateLabel({
    required int scoreRate,
    required int chipRate,
    required int mode,
  }) {
    if (isChip(mode)) {
      return '点$scoreRate枚/円';
    }
    return '点$scoreRate円 / チップ$chipRate円';
  }
}
