import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:majan_log_app/db/database.dart';
import 'package:majan_log_app/providers/database_provider.dart';
import 'package:majan_log_app/screens/game_day_detail_screen.dart';
import 'package:majan_log_app/screens/player_list_screen.dart';
import 'package:majan_log_app/screens/create_game_day_screen.dart';
import 'package:majan_log_app/screens/settings_screen.dart';
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('麻雀ログ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: '雀士一覧',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PlayerListScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'レート設定',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<GameDay>>(
        stream: (db.select(db.gameDays)
              ..orderBy([
                (t) => OrderingTerm(
                    expression: t.date, mode: OrderingMode.desc)
              ]))
            .watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final gameDays = snapshot.data!;
          if (gameDays.isEmpty) {
            return const Center(
              child: Text('対戦日がありません\n右下のボタンから追加してください',
                  textAlign: TextAlign.center),
            );
          }
          return StreamBuilder<List<GameDayPlayer>>(
            stream: db.select(db.gameDayPlayers).watch(),
            builder: (context, gdpSnap) {
              final counts = <int, int>{};
              for (final row in gdpSnap.data ?? const <GameDayPlayer>[]) {
                counts[row.gameDayId] =
                    (counts[row.gameDayId] ?? 0) + 1;
              }
              return ListView.builder(
                itemCount: gameDays.length,
                itemBuilder: (context, index) {
                  final gd = gameDays[index];
                  final dateStr =
                      '${gd.date.year}/${gd.date.month}/${gd.date.day}';
                  final typeStr =
                      gd.playerCount == 3 ? '三麻' : '四麻';
                  final n = counts[gd.id];
                  final peopleSuffix =
                      (n != null && n > gd.playerCount)
                          ? '・$n人'
                          : '';
                  final rateStr =
                      '点${gd.scoreRate}円 / チップ${gd.chipRate}円';
                  return ListTile(
                    title:
                        Text('$dateStr ($typeStr$peopleSuffix)'),
                    subtitle: Text(
                      [rateStr, if (gd.memo != null) gd.memo!]
                          .join(' / '),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: '対戦日を削除',
                      onPressed: () =>
                          _confirmDeleteGameDay(context, db, gd),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GameDayDetailScreen(
                              gameDayId: gd.id),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateGameDayScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDeleteGameDay(
      BuildContext context, AppDatabase db, GameDay gd) {
    final dateStr =
        '${gd.date.year}/${gd.date.month}/${gd.date.day}';
    final typeStr = gd.playerCount == 3 ? '三麻' : '四麻';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('対戦日を削除'),
        content: Text(
          '$dateStr ($typeStr) を削除しますか？\n'
          '半荘・スコア・チップ記録もすべて削除されます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await db.deleteGameDayCascade(gd.id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('削除',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
