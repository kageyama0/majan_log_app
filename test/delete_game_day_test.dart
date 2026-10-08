import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:majan_log_app/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> insertGameDayWithData() async {
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
      [p1, 10],
      [p2, -5],
      [p3, 0],
      [p4, -5],
    ]) {
      await db.into(db.gameScores).insert(
            GameScoresCompanion.insert(
              gameId: gameId,
              playerId: e[0],
              score: e[1],
            ),
          );
    }

    await db.into(db.chipLoans).insert(
          ChipLoansCompanion.insert(
            gameDayId: gdId,
            lenderId: p1,
            borrowerId: p2,
            amount: 2,
          ),
        );
    await db.into(db.chipSettlements).insert(
          ChipSettlementsCompanion.insert(
            gameDayId: gdId,
            playerId: p1,
            chipDiff: 1,
          ),
        );

    return gdId;
  }

  test('deleteGameDayCascade は関連データごと削除し雀士は残す', () async {
    final gdId = await insertGameDayWithData();
    final otherGd = await db.into(db.gameDays).insert(
          GameDaysCompanion.insert(
            date: DateTime(2026, 10, 2),
            playerCount: const Value(3),
          ),
        );

    await db.deleteGameDayCascade(gdId);

    expect(await db.select(db.gameDays).get(),
        hasLength(1));
    expect((await db.select(db.gameDays).get()).single.id, otherGd);

    expect(await db.select(db.gameDayPlayers).get(), isEmpty);
    expect(await db.select(db.games).get(), isEmpty);
    expect(await db.select(db.gameScores).get(), isEmpty);
    expect(await db.select(db.chipLoans).get(), isEmpty);
    expect(await db.select(db.chipSettlements).get(), isEmpty);

    // 雀士マスタは残る
    expect(await db.select(db.players).get(), hasLength(4));
  });

  test('存在しない ID でも例外にならない', () async {
    await expectLater(db.deleteGameDayCascade(99999), completes);
  });
}
