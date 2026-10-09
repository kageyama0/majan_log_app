import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:majan_log_app/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<({int gdId, List<int> playerIds, int gameId})> seed() async {
    final playerIds = <int>[];
    for (final name in ['A', 'B', 'C', 'D']) {
      playerIds.add(
        await db.into(db.players).insert(PlayersCompanion.insert(name: name)),
      );
    }
    final gdId = await db.into(db.gameDays).insert(
          GameDaysCompanion.insert(
            date: DateTime(2026, 10, 9),
            playerCount: const Value(4),
          ),
        );
    for (final pid in playerIds) {
      await db.into(db.gameDayPlayers).insert(
            GameDayPlayersCompanion.insert(
              gameDayId: gdId,
              playerId: pid,
            ),
          );
    }
    final gameId = await db.into(db.games).insert(
          GamesCompanion.insert(gameDayId: gdId, gameNumber: 1),
        );
    final scores = [10, 20, -15, -15];
    for (var i = 0; i < 4; i++) {
      await db.into(db.gameScores).insert(
            GameScoresCompanion.insert(
              gameId: gameId,
              playerId: playerIds[i],
              score: scores[i],
            ),
          );
    }
    return (gdId: gdId, playerIds: playerIds, gameId: gameId);
  }

  test('半荘スコアを更新できる（編集）', () async {
    final seeded = await seed();
    final gameId = seeded.gameId;
    final playerIds = seeded.playerIds;

    await db.transaction(() async {
      await (db.delete(db.gameScores)
            ..where((t) => t.gameId.equals(gameId)))
          .go();
      final next = [30, -10, 5, -25];
      for (var i = 0; i < 4; i++) {
        await db.into(db.gameScores).insert(
              GameScoresCompanion.insert(
                gameId: gameId,
                playerId: playerIds[i],
                score: next[i],
              ),
            );
      }
    });

    final rows = await (db.select(db.gameScores)
          ..where((t) => t.gameId.equals(gameId)))
        .get();
    expect(rows, hasLength(4));
    final byPlayer = {for (final r in rows) r.playerId: r.score};
    expect(byPlayer[playerIds[0]], 30);
    expect(byPlayer[playerIds[1]], -10);
    expect(byPlayer[playerIds[2]], 5);
    expect(byPlayer[playerIds[3]], -25);
    expect(byPlayer.values.fold<int>(0, (a, b) => a + b), 0);
  });

  test('編集で休みメンバーを差し替えられる', () async {
    final playerIds = <int>[];
    for (final name in ['A', 'B', 'C', 'D', 'E']) {
      playerIds.add(
        await db.into(db.players).insert(PlayersCompanion.insert(name: name)),
      );
    }
    final gdId = await db.into(db.gameDays).insert(
          GameDaysCompanion.insert(
            date: DateTime(2026, 10, 9),
            playerCount: const Value(4),
          ),
        );
    for (final pid in playerIds) {
      await db.into(db.gameDayPlayers).insert(
            GameDayPlayersCompanion.insert(
              gameDayId: gdId,
              playerId: pid,
            ),
          );
    }
    final gameId = await db.into(db.games).insert(
          GamesCompanion.insert(gameDayId: gdId, gameNumber: 1),
        );
    // 最初は E 休み
    for (var i = 0; i < 4; i++) {
      await db.into(db.gameScores).insert(
            GameScoresCompanion.insert(
              gameId: gameId,
              playerId: playerIds[i],
              score: i == 0 ? 10 : (i == 1 ? 20 : (i == 2 ? -15 : -15)),
            ),
          );
    }

    // 編集: A 休み、E 参加
    await db.transaction(() async {
      await (db.delete(db.gameScores)
            ..where((t) => t.gameId.equals(gameId)))
          .go();
      final seated = [
        playerIds[1],
        playerIds[2],
        playerIds[3],
        playerIds[4],
      ];
      final scores = [20, -15, -15, 10];
      for (var i = 0; i < 4; i++) {
        await db.into(db.gameScores).insert(
              GameScoresCompanion.insert(
                gameId: gameId,
                playerId: seated[i],
                score: scores[i],
              ),
            );
      }
    });

    final rows = await (db.select(db.gameScores)
          ..where((t) => t.gameId.equals(gameId)))
        .get();
    expect(rows, hasLength(4));
    expect(rows.any((r) => r.playerId == playerIds[0]), isFalse);
    expect(rows.any((r) => r.playerId == playerIds[4]), isTrue);
  });
}
