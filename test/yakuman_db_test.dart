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

  Future<({int gameDayId, int gameId, int playerId})> seed() async {
    final p1 = await db
        .into(db.players)
        .insert(PlayersCompanion.insert(name: 'A'));
    final p2 = await db
        .into(db.players)
        .insert(PlayersCompanion.insert(name: 'B'));
    final p3 = await db
        .into(db.players)
        .insert(PlayersCompanion.insert(name: 'C'));
    final p4 = await db
        .into(db.players)
        .insert(PlayersCompanion.insert(name: 'D'));

    final gdId = await db.into(db.gameDays).insert(
          GameDaysCompanion.insert(
            date: DateTime(2026, 10, 1),
            playerCount: const Value(4),
          ),
        );
    for (final pid in [p1, p2, p3, p4]) {
      await db.into(db.gameDayPlayers).insert(
            GameDayPlayersCompanion.insert(
                gameDayId: gdId, playerId: pid),
          );
    }
    final gameId = await db.into(db.games).insert(
          GamesCompanion.insert(gameDayId: gdId, gameNumber: 1),
        );
    for (final e in [
      [p1, 40],
      [p2, -10],
      [p3, -15],
      [p4, -15],
    ]) {
      await db.into(db.gameScores).insert(
            GameScoresCompanion.insert(
              gameId: gameId,
              playerId: e[0],
              score: e[1],
            ),
          );
    }
    return (gameDayId: gdId, gameId: gameId, playerId: p1);
  }

  test('役満を記録・雀士で取得できる', () async {
    final s = await seed();
    await db.into(db.yakumans).insert(
          YakumansCompanion.insert(
            gameId: s.gameId,
            playerId: s.playerId,
            yakumanName: '大三元',
          ),
        );

    final rows = await (db.select(db.yakumans)
          ..where((t) => t.playerId.equals(s.playerId)))
        .get();
    expect(rows, hasLength(1));
    expect(rows.first.yakumanName, '大三元');
  });

  test('対戦日削除で役満も消える', () async {
    final s = await seed();
    await db.into(db.yakumans).insert(
          YakumansCompanion.insert(
            gameId: s.gameId,
            playerId: s.playerId,
            yakumanName: '国士無双',
          ),
        );

    await db.deleteGameDayCascade(s.gameDayId);

    final left = await db.select(db.yakumans).get();
    expect(left, isEmpty);
    final games = await db.select(db.games).get();
    expect(games, isEmpty);
  });
}
