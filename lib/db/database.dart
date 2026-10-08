import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Players extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class GameDays extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get playerCount => integer().withDefault(const Constant(4))();
  IntColumn get scoreRate => integer().withDefault(const Constant(50))();
  IntColumn get chipRate => integer().withDefault(const Constant(100))();
  IntColumn get venueFee => integer().withDefault(const Constant(0))();
  TextColumn get memo => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  IntColumn get value => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

class GameDayPlayers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameDayId =>
      integer().references(GameDays, #id)();
  IntColumn get playerId =>
      integer().references(Players, #id)();
}

class Games extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameDayId =>
      integer().references(GameDays, #id)();
  IntColumn get gameNumber => integer()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class GameScores extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameId => integer().references(Games, #id)();
  IntColumn get playerId =>
      integer().references(Players, #id)();
  IntColumn get score => integer()();
}

class ChipLoans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameDayId =>
      integer().references(GameDays, #id)();
  IntColumn get lenderId =>
      integer().references(Players, #id)();
  IntColumn get borrowerId =>
      integer().references(Players, #id)();
  IntColumn get amount => integer()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class ChipSettlements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameDayId =>
      integer().references(GameDays, #id)();
  IntColumn get playerId =>
      integer().references(Players, #id)();
  IntColumn get chipDiff => integer()();
}

@DriftDatabase(tables: [
  Players,
  GameDays,
  GameDayPlayers,
  Games,
  GameScores,
  ChipLoans,
  ChipSettlements,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// テスト用（インメモリ等の [QueryExecutor] を直接渡す）。
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(gameDays, gameDays.scoreRate);
            await migrator.addColumn(gameDays, gameDays.chipRate);
            await migrator.createTable(appSettings);
          }
          if (from < 3) {
            await migrator.addColumn(gameDays, gameDays.venueFee);
          }
        },
      );

  Future<int> getSetting(String key, int defaultValue) async {
    final row = await (select(appSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value ?? defaultValue;
  }

  Future<void> setSetting(String key, int value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }

  /// 対戦日とその関連データ（半荘・スコア・参加者・チップ）を削除する。
  /// FK に ON DELETE CASCADE が無いため、依存順に明示削除する。
  Future<void> deleteGameDayCascade(int gameDayId) async {
    await transaction(() async {
      final dayGames = await (select(games)
            ..where((t) => t.gameDayId.equals(gameDayId)))
          .get();
      final gameIds = dayGames.map((g) => g.id).toList();

      if (gameIds.isNotEmpty) {
        await (delete(gameScores)
              ..where((t) => t.gameId.isIn(gameIds)))
            .go();
        await (delete(games)
              ..where((t) => t.id.isIn(gameIds)))
            .go();
      }

      await (delete(chipSettlements)
            ..where((t) => t.gameDayId.equals(gameDayId)))
          .go();
      await (delete(chipLoans)
            ..where((t) => t.gameDayId.equals(gameDayId)))
          .go();
      await (delete(gameDayPlayers)
            ..where((t) => t.gameDayId.equals(gameDayId)))
          .go();
      await (delete(gameDays)..where((t) => t.id.equals(gameDayId)))
          .go();
    });
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'majan_log.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  Future<void> seed() async {
    final existing = await select(players).get();
    if (existing.isNotEmpty) {
      await delete(chipSettlements).go();
      await delete(chipLoans).go();
      await delete(gameScores).go();
      await delete(games).go();
      await delete(gameDayPlayers).go();
      await delete(gameDays).go();
      await delete(players).go();
    }

    // 雀士5人
    final p1 = await into(players)
        .insert(PlayersCompanion.insert(name: '田中'));
    final p2 = await into(players)
        .insert(PlayersCompanion.insert(name: '鈴木'));
    final p3 = await into(players)
        .insert(PlayersCompanion.insert(name: '佐藤'));
    final p4 = await into(players)
        .insert(PlayersCompanion.insert(name: '山田'));
    final p5 = await into(players)
        .insert(PlayersCompanion.insert(name: '中村'));

    // デフォルトレート設定
    await setSetting('defaultScoreRate', 50);
    await setSetting('defaultChipRate', 100);

    // --- 対戦日1: 四麻 (7/20) テンゴ ---
    final gd1 = await into(gameDays).insert(
      GameDaysCompanion.insert(
        date: DateTime(2026, 7, 20),
        playerCount: Value(4),
        scoreRate: Value(50),
        chipRate: Value(100),
        memo: const Value('雀荘A'),
      ),
    );
    for (final pid in [p1, p2, p3, p4]) {
      await into(gameDayPlayers).insert(
          GameDayPlayersCompanion.insert(
              gameDayId: gd1, playerId: pid));
    }

    // 半荘1
    final g1 = await into(games).insert(
        GamesCompanion.insert(gameDayId: gd1, gameNumber: 1));
    for (final e in [
      [p1, 45], [p2, -15], [p3, -10], [p4, -20]
    ]) {
      await into(gameScores).insert(GameScoresCompanion.insert(
          gameId: g1, playerId: e[0], score: e[1]));
    }

    // 半荘2
    final g2 = await into(games).insert(
        GamesCompanion.insert(gameDayId: gd1, gameNumber: 2));
    for (final e in [
      [p1, -30], [p2, 55], [p3, -5], [p4, -20]
    ]) {
      await into(gameScores).insert(GameScoresCompanion.insert(
          gameId: g2, playerId: e[0], score: e[1]));
    }

    // 半荘3
    final g3 = await into(games).insert(
        GamesCompanion.insert(gameDayId: gd1, gameNumber: 3));
    for (final e in [
      [p1, 10], [p2, -25], [p3, 30], [p4, -15]
    ]) {
      await into(gameScores).insert(GameScoresCompanion.insert(
          gameId: g3, playerId: e[0], score: e[1]));
    }

    // 半荘4
    final g4 = await into(games).insert(
        GamesCompanion.insert(gameDayId: gd1, gameNumber: 4));
    for (final e in [
      [p1, -20], [p2, -10], [p3, -5], [p4, 35]
    ]) {
      await into(gameScores).insert(GameScoresCompanion.insert(
          gameId: g4, playerId: e[0], score: e[1]));
    }

    // チップ貸し借り
    await into(chipLoans).insert(ChipLoansCompanion.insert(
        gameDayId: gd1, lenderId: p1, borrowerId: p4, amount: 5));
    await into(chipLoans).insert(ChipLoansCompanion.insert(
        gameDayId: gd1, lenderId: p2, borrowerId: p3, amount: 3));

    // チップ清算
    for (final e in [
      [p1, 8], [p2, -3], [p3, -7], [p4, 2]
    ]) {
      await into(chipSettlements).insert(
          ChipSettlementsCompanion.insert(
              gameDayId: gd1, playerId: e[0], chipDiff: e[1]));
    }

    // --- 対戦日2: 四麻 (7/27) テンピン ---
    final gd2 = await into(gameDays).insert(
      GameDaysCompanion.insert(
        date: DateTime(2026, 7, 27),
        playerCount: Value(4),
        scoreRate: Value(100),
        chipRate: Value(200),
        memo: const Value('雀荘B'),
      ),
    );
    for (final pid in [p1, p2, p3, p5]) {
      await into(gameDayPlayers).insert(
          GameDayPlayersCompanion.insert(
              gameDayId: gd2, playerId: pid));
    }

    // 半荘1
    final g5 = await into(games).insert(
        GamesCompanion.insert(gameDayId: gd2, gameNumber: 1));
    for (final e in [
      [p1, -40], [p2, 20], [p3, 35], [p5, -15]
    ]) {
      await into(gameScores).insert(GameScoresCompanion.insert(
          gameId: g5, playerId: e[0], score: e[1]));
    }

    // 半荘2
    final g6 = await into(games).insert(
        GamesCompanion.insert(gameDayId: gd2, gameNumber: 2));
    for (final e in [
      [p1, 60], [p2, -10], [p3, -30], [p5, -20]
    ]) {
      await into(gameScores).insert(GameScoresCompanion.insert(
          gameId: g6, playerId: e[0], score: e[1]));
    }

    // 半荘3
    final g7 = await into(games).insert(
        GamesCompanion.insert(gameDayId: gd2, gameNumber: 3));
    for (final e in [
      [p1, -15], [p2, -25], [p3, 10], [p5, 30]
    ]) {
      await into(gameScores).insert(GameScoresCompanion.insert(
          gameId: g7, playerId: e[0], score: e[1]));
    }

    // チップ貸し借り
    await into(chipLoans).insert(ChipLoansCompanion.insert(
        gameDayId: gd2, lenderId: p5, borrowerId: p1, amount: 10));

    // チップ清算
    for (final e in [
      [p1, -5], [p2, 4], [p3, 3], [p5, -2]
    ]) {
      await into(chipSettlements).insert(
          ChipSettlementsCompanion.insert(
              gameDayId: gd2, playerId: e[0], chipDiff: e[1]));
    }

    // --- 対戦日3: 三麻 (8/2) テンゴ ---
    final gd3 = await into(gameDays).insert(
      GameDaysCompanion.insert(
        date: DateTime(2026, 8, 2),
        playerCount: Value(3),
        scoreRate: Value(50),
        chipRate: Value(100),
      ),
    );
    for (final pid in [p1, p2, p4]) {
      await into(gameDayPlayers).insert(
          GameDayPlayersCompanion.insert(
              gameDayId: gd3, playerId: pid));
    }

    // 半荘1
    final g8 = await into(games).insert(
        GamesCompanion.insert(gameDayId: gd3, gameNumber: 1));
    for (final e in [
      [p1, 30], [p2, -10], [p4, -20]
    ]) {
      await into(gameScores).insert(GameScoresCompanion.insert(
          gameId: g8, playerId: e[0], score: e[1]));
    }

    // 半荘2
    final g9 = await into(games).insert(
        GamesCompanion.insert(gameDayId: gd3, gameNumber: 2));
    for (final e in [
      [p1, -25], [p2, 40], [p4, -15]
    ]) {
      await into(gameScores).insert(GameScoresCompanion.insert(
          gameId: g9, playerId: e[0], score: e[1]));
    }

    // 半荘3
    final g10 = await into(games).insert(
        GamesCompanion.insert(gameDayId: gd3, gameNumber: 3));
    for (final e in [
      [p1, 15], [p2, -5], [p4, -10]
    ]) {
      await into(gameScores).insert(GameScoresCompanion.insert(
          gameId: g10, playerId: e[0], score: e[1]));
    }

    // チップ貸し借り
    await into(chipLoans).insert(ChipLoansCompanion.insert(
        gameDayId: gd3, lenderId: p1, borrowerId: p2, amount: 4));

    // チップ清算
    for (final e in [
      [p1, 6], [p2, -2], [p4, -4]
    ]) {
      await into(chipSettlements).insert(
          ChipSettlementsCompanion.insert(
              gameDayId: gd3, playerId: e[0], chipDiff: e[1]));
    }

    // --- 対戦日4: 四麻5人ローテ (8/9) ---
    // 半荘ごとに1人休み。休みは GameScores 行なし。
    final gd4 = await into(gameDays).insert(
      GameDaysCompanion.insert(
        date: DateTime(2026, 8, 9),
        playerCount: Value(4),
        scoreRate: Value(50),
        chipRate: Value(100),
        memo: const Value('5人打ちローテ'),
      ),
    );
    for (final pid in [p1, p2, p3, p4, p5]) {
      await into(gameDayPlayers).insert(
          GameDayPlayersCompanion.insert(
              gameDayId: gd4, playerId: pid));
    }

    // 半荘1: p1休み
    final g11 = await into(games).insert(
        GamesCompanion.insert(gameDayId: gd4, gameNumber: 1));
    for (final e in [
      [p2, 40], [p3, -10], [p4, -5], [p5, -25]
    ]) {
      await into(gameScores).insert(GameScoresCompanion.insert(
          gameId: g11, playerId: e[0], score: e[1]));
    }

    // 半荘2: p2休み
    final g12 = await into(games).insert(
        GamesCompanion.insert(gameDayId: gd4, gameNumber: 2));
    for (final e in [
      [p1, -20], [p3, 35], [p4, -15], [p5, 0]
    ]) {
      await into(gameScores).insert(GameScoresCompanion.insert(
          gameId: g12, playerId: e[0], score: e[1]));
    }

    // 半荘3: p3休み
    final g13 = await into(games).insert(
        GamesCompanion.insert(gameDayId: gd4, gameNumber: 3));
    for (final e in [
      [p1, 25], [p2, -30], [p4, 10], [p5, -5]
    ]) {
      await into(gameScores).insert(GameScoresCompanion.insert(
          gameId: g13, playerId: e[0], score: e[1]));
    }

    // 半荘4: p4休み
    final g14 = await into(games).insert(
        GamesCompanion.insert(gameDayId: gd4, gameNumber: 4));
    for (final e in [
      [p1, -5], [p2, 15], [p3, -20], [p5, 10]
    ]) {
      await into(gameScores).insert(GameScoresCompanion.insert(
          gameId: g14, playerId: e[0], score: e[1]));
    }

    // 半荘5: p5休み
    final g15 = await into(games).insert(
        GamesCompanion.insert(gameDayId: gd4, gameNumber: 5));
    for (final e in [
      [p1, 10], [p2, -5], [p3, 20], [p4, -25]
    ]) {
      await into(gameScores).insert(GameScoresCompanion.insert(
          gameId: g15, playerId: e[0], score: e[1]));
    }

    for (final e in [
      [p1, 2], [p2, -1], [p3, 3], [p4, -2], [p5, -2]
    ]) {
      await into(chipSettlements).insert(
          ChipSettlementsCompanion.insert(
              gameDayId: gd4, playerId: e[0], chipDiff: e[1]));
    }
  }
}
