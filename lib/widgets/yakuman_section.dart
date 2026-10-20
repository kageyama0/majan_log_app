import 'package:flutter/material.dart';
import 'package:majan_log_app/db/database.dart';
import 'package:majan_log_app/utils/yakuman_presets.dart';

/// 対戦日のスコアタブ下部に載せる役満一覧＋追加 UI。
class YakumanSection extends StatelessWidget {
  final AppDatabase db;
  final int gameDayId;
  final List<Player> players;
  final List<Game> games;

  const YakumanSection({
    super.key,
    required this.db,
    required this.gameDayId,
    required this.players,
    required this.games,
  });

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return const SizedBox.shrink();
    }

    final gameIds = games.map((g) => g.id).toSet();
    final playerMap = {for (final p in players) p.id: p.name};
    final gameNumberMap = {for (final g in games) g.id: g.gameNumber};

    return StreamBuilder<List<Yakuman>>(
      stream: db.select(db.yakumans).watch(),
      builder: (context, snapshot) {
        final rows = (snapshot.data ?? [])
            .where((y) => gameIds.contains(y.gameId))
            .toList()
          ..sort((a, b) {
            final ga = gameNumberMap[a.gameId] ?? 0;
            final gb = gameNumberMap[b.gameId] ?? 0;
            if (ga != gb) return ga.compareTo(gb);
            return a.id.compareTo(b.id);
          });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  '役満記録',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showAddDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('追加'),
                ),
              ],
            ),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'まだありません（半荘保存後に追加できます）',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              )
            else
              ...rows.map((y) {
                final gameNo = gameNumberMap[y.gameId] ?? '?';
                final name = playerMap[y.playerId] ?? '?';
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('$name ／ ${y.yakumanName}'),
                  subtitle: Text('半荘 $gameNo'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    tooltip: '削除',
                    onPressed: () async {
                      await (db.delete(db.yakumans)
                            ..where((t) => t.id.equals(y.id)))
                          .go();
                    },
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    Game? selectedGame = games.last;
    Player? selectedPlayer = players.isNotEmpty ? players.first : null;
    String? selectedPreset;
    final customController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('役満を記録'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('半荘',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    DropdownButton<int>(
                      value: selectedGame?.id,
                      isExpanded: true,
                      hint: const Text('選択'),
                      items: games
                          .map(
                            (g) => DropdownMenuItem(
                              value: g.id,
                              child: Text('半荘 ${g.gameNumber}'),
                            ),
                          )
                          .toList(),
                      onChanged: (id) {
                        setLocal(() {
                          selectedGame =
                              games.where((g) => g.id == id).firstOrNull;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('雀士',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    DropdownButton<int>(
                      value: selectedPlayer?.id,
                      isExpanded: true,
                      hint: const Text('選択'),
                      items: players
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name),
                            ),
                          )
                          .toList(),
                      onChanged: (id) {
                        setLocal(() {
                          selectedPlayer =
                              players.where((p) => p.id == id).firstOrNull;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('役満名', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: kYakumanPresets.map((name) {
                        final selected = selectedPreset == name;
                        return FilterChip(
                          label: Text(name, style: const TextStyle(fontSize: 12)),
                          selected: selected,
                          onSelected: (_) {
                            setLocal(() {
                              selectedPreset = name;
                              customController.clear();
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: customController,
                      decoration: const InputDecoration(
                        labelText: '自由入力',
                        border: OutlineInputBorder(),
                        hintText: 'プリセット以外の役満名',
                      ),
                      onChanged: (v) {
                        if (v.trim().isNotEmpty) {
                          setLocal(() => selectedPreset = null);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('キャンセル'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );

    final custom = customController.text.trim();
    customController.dispose();
    if (ok != true) return;

    final name = custom.isNotEmpty ? custom : (selectedPreset ?? '');
    if (name.isEmpty || selectedGame == null || selectedPlayer == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('半荘・雀士・役満名を入力してください')),
        );
      }
      return;
    }

    await db.into(db.yakumans).insert(
          YakumansCompanion.insert(
            gameId: selectedGame!.id,
            playerId: selectedPlayer!.id,
            yakumanName: name,
          ),
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${selectedPlayer!.name} の $name を記録しました')),
      );
    }
  }
}
