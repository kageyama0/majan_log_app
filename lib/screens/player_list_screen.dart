import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majan_log_app/db/database.dart';
import 'package:majan_log_app/providers/database_provider.dart';
import 'package:majan_log_app/screens/player_detail_screen.dart';

class PlayerListScreen extends ConsumerWidget {
  const PlayerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('雀士一覧')),
      body: StreamBuilder<List<Player>>(
        stream: db.select(db.players).watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final players = snapshot.data!;
          if (players.isEmpty) {
            return const Center(
              child: Text('雀士がいません\n右下のボタンから追加してください',
                  textAlign: TextAlign.center),
            );
          }
          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return ListTile(
                title: Text(player.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          PlayerDetailScreen(playerId: player.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, db),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppDatabase db) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('雀士追加'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '名前'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                db
                    .into(db.players)
                    .insert(PlayersCompanion.insert(name: name));
                Navigator.pop(context);
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }
}
