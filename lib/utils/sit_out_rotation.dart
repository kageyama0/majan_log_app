/// 参加者数が席数より多いときの休み（待機）ローテーション。
///
/// 半荘単位で [excess] 人が休み。参加者の並び順を固定し、
/// 半荘番号に応じてローテで回す。
List<int> defaultSittingOutPlayerIds({
  required List<int> participantIds,
  required int seatCount,
  required int gameNumber,
}) {
  if (participantIds.isEmpty || seatCount <= 0 || gameNumber < 1) {
    return const [];
  }
  final excess = participantIds.length - seatCount;
  if (excess <= 0) return const [];

  final n = participantIds.length;
  final start = ((gameNumber - 1) * excess) % n;
  return List.generate(
    excess,
    (i) => participantIds[(start + i) % n],
  );
}

/// 指定プレイヤーが休む半荘かどうかを判定する。
bool isSittingOut({
  required int playerId,
  required List<int> participantIds,
  required int seatCount,
  required int gameNumber,
}) {
  return defaultSittingOutPlayerIds(
    participantIds: participantIds,
    seatCount: seatCount,
    gameNumber: gameNumber,
  ).contains(playerId);
}

/// 対局するプレイヤー ID（休み以外）。
List<int> seatedPlayerIds({
  required List<int> participantIds,
  required Set<int> sittingOutIds,
}) {
  return participantIds
      .where((id) => !sittingOutIds.contains(id))
      .toList();
}
