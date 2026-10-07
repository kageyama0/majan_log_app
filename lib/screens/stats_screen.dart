import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majan_log_app/db/database.dart';
import 'package:majan_log_app/providers/database_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('累計収支')),
      body: FutureBuilder<List<_PlayerStats>>(
        future: _loadStats(db),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = snapshot.data!;
          if (stats.isEmpty) {
            return const Center(child: Text('データがありません'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('メンバー')),
                  DataColumn(label: Text('対戦数')),
                  DataColumn(label: Text('半荘数')),
                  DataColumn(label: Text('スコア計')),
                  DataColumn(label: Text('チップ計')),
                ],
                rows: stats.map((s) {
                  return DataRow(cells: [
                    DataCell(Text(s.name)),
                    DataCell(Text('${s.gameDayCount}')),
                    DataCell(Text('${s.gameCount}')),
                    DataCell(Text(
                      _formatNum(s.totalScore),
                      style: TextStyle(
                        color: s.totalScore >= 0
                            ? Colors.black
                            : Colors.red,
                      ),
                    )),
                    DataCell(Text(
                      _formatNum(s.totalChipNet),
                      style: TextStyle(
                        color: s.totalChipNet >= 0
                            ? Colors.black
                            : Colors.red,
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatNum(int n) => n >= 0 ? '+$n' : '$n';

  Future<List<_PlayerStats>> _loadStats(AppDatabase db) async {
    final players = await db.select(db.players).get();
    final allScores = await db.select(db.gameScores).get();
    final allGames = await db.select(db.games).get();
    final allGameDayPlayers =
        await db.select(db.gameDayPlayers).get();
    final allChipSettlements =
        await db.select(db.chipSettlements).get();
    final allChipLoans = await db.select(db.chipLoans).get();

    final gameToGameDay = <int, int>{};
    for (final g in allGames) {
      gameToGameDay[g.id] = g.gameDayId;
    }

    final stats = <_PlayerStats>[];

    for (final player in players) {
      final gameDayIds = allGameDayPlayers
          .where((gdp) => gdp.playerId == player.id)
          .map((gdp) => gdp.gameDayId)
          .toSet();

      final playerScores = allScores
          .where((s) => s.playerId == player.id)
          .toList();

      final gameIds = playerScores.map((s) => s.gameId).toSet();

      final totalScore =
          playerScores.fold<int>(0, (sum, s) => sum + s.score);

      final chipDiffs = allChipSettlements
          .where((cs) => cs.playerId == player.id)
          .fold<int>(0, (sum, cs) => sum + cs.chipDiff);

      int loanBalance = 0;
      for (final loan in allChipLoans) {
        if (loan.borrowerId == player.id) {
          loanBalance += loan.amount;
        }
        if (loan.lenderId == player.id) {
          loanBalance -= loan.amount;
        }
      }

      final totalChipNet = chipDiffs - loanBalance;

      stats.add(_PlayerStats(
        name: player.name,
        gameDayCount: gameDayIds.length,
        gameCount: gameIds.length,
        totalScore: totalScore,
        totalChipNet: totalChipNet,
      ));
    }

    stats.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return stats;
  }
}

class _PlayerStats {
  final String name;
  final int gameDayCount;
  final int gameCount;
  final int totalScore;
  final int totalChipNet;

  _PlayerStats({
    required this.name,
    required this.gameDayCount,
    required this.gameCount,
    required this.totalScore,
    required this.totalChipNet,
  });
}
