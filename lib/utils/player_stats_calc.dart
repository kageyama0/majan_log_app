/// 連対率（1着＋2着の割合）。半荘数が 0 なら null。
double? rentaiRate({
  required int firstPlaceCount,
  required int secondPlaceCount,
  required int totalGames,
}) {
  if (totalGames <= 0) return null;
  return (firstPlaceCount + secondPlaceCount) / totalGames;
}

/// チップ純収支（貸し借り込み）。
///
/// `chipDiff` は清算画面で入力した差枚数。
/// 借りた枚数はマイナス、貸した枚数はプラスに補正する
/// （精算画面と同じ: `chipNet = chipDiff - borrowed + lent`）。
int chipNetBalance({
  required int chipDiff,
  required int borrowedAmount,
  required int lentAmount,
}) {
  return chipDiff - borrowedAmount + lentAmount;
}
