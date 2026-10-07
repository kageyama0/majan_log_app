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
          return ListView.builder(
            itemCount: gameDays.length,
            itemBuilder: (context, index) {
              final gd = gameDays[index];
              final dateStr =
                  '${gd.date.year}/${gd.date.month}/${gd.date.day}';
              final typeStr = gd.playerCount == 3 ? '三麻' : '四麻';
              final rateStr = '点${gd.scoreRate}円 / チップ${gd.chipRate}円';
              return ListTile(
                title: Text('$dateStr ($typeStr)'),
                subtitle: Text(
                  [rateStr, if (gd.memo != null) gd.memo!]
                      .join(' / '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          GameDayDetailScreen(gameDayId: gd.id),
                    ),
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
}
