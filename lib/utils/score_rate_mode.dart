/// 順位点レートの換算モード（[GameDays.scoreRateMode]）。
///
/// - [yen]: 順位点 × scoreRate → 円（従来どおり）
/// - [chip]: 順位点 × scoreRate → チップ枚数 → × chipRate → 円
abstract final class ScoreRateMode {
  static const int yen = 0;
  static const int chip = 1;

  static bool isChip(int mode) => mode == chip;

  static bool isYen(int mode) => mode != chip;

  /// 順位点合計を円に換算する。
  static int scoreToYen({
    required int scorePoints,
    required int scoreRate,
    required int chipRate,
    required int mode,
  }) {
    if (isChip(mode)) {
      return scorePoints * scoreRate * chipRate;
    }
    return scorePoints * scoreRate;
  }

  /// チップ換算時の順位点→チップ枚数。円換算時は 0。
  static int scoreToChips({
    required int scorePoints,
    required int scoreRate,
    required int mode,
  }) {
    if (!isChip(mode)) return 0;
    return scorePoints * scoreRate;
  }

  static String scoreRateSuffix(int mode) =>
      isChip(mode) ? '枚/円' : '円/点';

  static String homeRateLabel({
    required int scoreRate,
    required int chipRate,
    required int mode,
  }) {
    if (isChip(mode)) {
      return '点$scoreRate枚 / チップ$chipRate円';
    }
    return '点$scoreRate円 / チップ$chipRate円';
  }
}
