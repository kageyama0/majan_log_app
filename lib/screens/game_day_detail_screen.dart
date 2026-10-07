import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column, Table;
import 'package:majan_log_app/db/database.dart';
import 'package:majan_log_app/providers/database_provider.dart';
import 'package:majan_log_app/screens/chip_settlement_screen.dart';

class GameDayDetailScreen extends ConsumerStatefulWidget {
  final int gameDayId;

  const GameDayDetailScreen({super.key, required this.gameDayId});

  @override
  ConsumerState<GameDayDetailScreen> createState() =>
      _GameDayDetailScreenState();
}

class _GameDayDetailScreenState
    extends ConsumerState<GameDayDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<GameDay>(
          stream: (db.select(db.gameDays)
                ..where((t) => t.id.equals(widget.gameDayId)))
              .watchSingle(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('...');
            final gd = snapshot.data!;
            final typeStr = gd.playerCount == 3 ? '三麻' : '四麻';
            return Text(
                '${gd.date.year}/${gd.date.month}/${gd.date.day} ($typeStr)');
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'スコア'),
            Tab(text: 'チップ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ScoreTab(gameDayId: widget.gameDayId),
          _ChipTab(gameDayId: widget.gameDayId),
        ],
      ),
      persistentFooterButtons: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChipSettlementScreen(
                      gameDayId: widget.gameDayId),
                ),
              );
            },
            icon: const Icon(Icons.flag),
            label: const Text('終了・精算'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreTab extends ConsumerWidget {
  final int gameDayId;
  const _ScoreTab({required this.gameDayId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return StreamBuilder<GameDay>(
      stream: (db.select(db.gameDays)
            ..where((t) => t.id.equals(gameDayId)))
          .watchSingle(),
      builder: (context, gdSnapshot) {
        if (!gdSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final gameDay = gdSnapshot.data!;

        return StreamBuilder<List<Player>>(
          stream: _watchPlayers(db),
          builder: (context, playersSnapshot) {
            if (!playersSnapshot.hasData) {
              return const Center(
                  child: CircularProgressIndicator());
            }
            final players = playersSnapshot.data!;

            return StreamBuilder<List<Game>>(
              stream: (db.select(db.games)
                    ..where(
                        (t) => t.gameDayId.equals(gameDayId))
                    ..orderBy([
                      (t) => OrderingTerm.asc(t.gameNumber)
                    ]))
                  .watch(),
              builder: (context, gamesSnapshot) {
                if (!gamesSnapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final games = gamesSnapshot.data!;

                return StreamBuilder<List<GameScore>>(
                  stream: db.select(db.gameScores).watch(),
                  builder: (context, scoresSnapshot) {
                    if (!scoresSnapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    final allScores = scoresSnapshot.data!;

                    return _buildScoreTable(context, db,
                        gameDay, players, games, allScores);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Stream<List<Player>> _watchPlayers(AppDatabase db) {
    final query = db.select(db.players).join([
      innerJoin(db.gameDayPlayers,
          db.gameDayPlayers.playerId.equalsExp(db.players.id)),
    ])
      ..where(db.gameDayPlayers.gameDayId.equals(gameDayId));

    return query.watch().map(
        (rows) => rows.map((r) => r.readTable(db.players)).toList());
  }

  Widget _buildScoreTable(BuildContext context, AppDatabase db,
      GameDay gameDay, List<Player> players, List<Game> games,
      List<GameScore> allScores) {
    final gameIds = games.map((g) => g.id).toSet();
    final scores =
        allScores.where((s) => gameIds.contains(s.gameId)).toList();

    final totals = <int, int>{};
    for (final p in players) {
      totals[p.id] = 0;
    }
    for (final s in scores) {
      totals[s.playerId] = (totals[s.playerId] ?? 0) + s.score;
    }

    final colCount = players.length + 1;
    final colWidths = <int, TableColumnWidth>{
      0: const FixedColumnWidth(40),
    };
    for (int i = 1; i < colCount; i++) {
      colWidths[i] = const FlexColumnWidth(1);
    }

    Widget cell(String text,
        {bool bold = false, Color? color, Color? bg}) {
      return GestureDetector(
        child: Container(
          color: bg,
          padding: const EdgeInsets.symmetric(
              vertical: 10, horizontal: 8),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : null,
              color: color,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView(
        children: [
          Table(
            border: TableBorder.all(color: Colors.grey.shade400),
            columnWidths: colWidths,
            children: [
              TableRow(
                decoration:
                    BoxDecoration(color: Colors.grey.shade200),
                children: [
                  cell('#', bold: true),
                  ...players
                      .map((p) => cell(p.name, bold: true)),
                ],
              ),
              ...games.map((game) {
                return TableRow(
                  children: [
                    GestureDetector(
                      onLongPress: () =>
                          _showDeleteGameDialog(context, db, game),
                      child: cell('${game.gameNumber}'),
                    ),
                    ...players.map((p) {
                      final score = scores
                          .where((s) =>
                              s.gameId == game.id &&
                              s.playerId == p.id)
                          .firstOrNull;
                      final value = score?.score ?? 0;
                      return GestureDetector(
                        onLongPress: () =>
                            _showDeleteGameDialog(
                                context, db, game),
                        child: cell(
                          value >= 0 ? '+$value' : '$value',
                          color: value >= 0
                              ? Colors.black
                              : Colors.red,
                        ),
                      );
                    }),
                  ],
                );
              }),
              TableRow(
                children: [
                  cell(''),
                  ...players.map((_) => cell('')),
                ],
              ),
              TableRow(
                decoration:
                    BoxDecoration(color: Colors.grey.shade100),
                children: [
                  cell('計', bold: true),
                  ...players.map((p) {
                    final total = totals[p.id] ?? 0;
                    return cell(
                      total >= 0 ? '+$total' : '$total',
                      bold: true,
                      color:
                          total >= 0 ? Colors.black : Colors.red,
                    );
                  }),
                ],
              ),
              TableRow(
                decoration:
                    BoxDecoration(color: Colors.green.shade50),
                children: [
                  cell('円', bold: true),
                  ...players.map((p) {
                    final total = totals[p.id] ?? 0;
                    final yen = total * gameDay.scoreRate;
                    return cell(
                      '${yen >= 0 ? "+" : ""}${_formatYen(yen)}',
                      bold: true,
                      color:
                          yen >= 0 ? Colors.black : Colors.red,
                    );
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                _showAddScoreDialog(context, db, players, games),
            icon: const Icon(Icons.add),
            label: const Text('半荘を追加'),
          ),
        ],
      ),
    );
  }

  String _formatYen(int yen) {
    final abs = yen.abs();
    if (abs >= 10000) {
      final man = abs ~/ 10000;
      final rest = abs % 10000;
      if (rest == 0) return '$man万';
      return '$man万$rest';
    }
    return '$abs';
  }

  void _showAddScoreDialog(BuildContext context, AppDatabase db,
      List<Player> players, List<Game> games) {
    final controllers = <int, TextEditingController>{};
    final focusNodes = <int, FocusNode>{};
    for (final p in players) {
      controllers[p.id] = TextEditingController();
      focusNodes[p.id] = FocusNode();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          void autoCalcLast() {
            final filled = <int, int>{};
            int? emptyPlayerId;
            int emptyCount = 0;
            for (final entry in controllers.entries) {
              final text = entry.value.text.trim();
              if (text.isEmpty) {
                emptyPlayerId = entry.key;
                emptyCount++;
              } else {
                filled[entry.key] =
                    int.tryParse(text) ?? 0;
              }
            }
            if (emptyCount == 1 &&
                filled.length == players.length - 1 &&
                emptyPlayerId != null) {
              final sum =
                  filled.values.fold<int>(0, (a, b) => a + b);
              controllers[emptyPlayerId]!.text = '${-sum}';
            }
          }

          for (final p in players) {
            focusNodes[p.id]!.addListener(() {
              if (!focusNodes[p.id]!.hasFocus) {
                autoCalcLast();
              }
            });
          }

          return AlertDialog(
            title: Text('半荘 ${games.length + 1}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: players.map((p) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4),
                    child: TextField(
                      controller: controllers[p.id],
                      focusNode: focusNodes[p.id],
                      decoration: InputDecoration(
                        labelText: p.name,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(
                              signed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^-?\d*')),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  final gameNumber = games.length + 1;
                  final gameId =
                      await db.into(db.games).insert(
                            GamesCompanion.insert(
                              gameDayId: gameDayId,
                              gameNumber: gameNumber,
                            ),
                          );
                  for (final p in players) {
                    final score = int.tryParse(
                            controllers[p.id]!.text.trim()) ??
                        0;
                    await db.into(db.gameScores).insert(
                          GameScoresCompanion.insert(
                            gameId: gameId,
                            playerId: p.id,
                            score: score,
                          ),
                        );
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('保存'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteGameDialog(
      BuildContext context, AppDatabase db, Game game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('半荘 ${game.gameNumber} を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await (db.delete(db.gameScores)
                    ..where((t) => t.gameId.equals(game.id)))
                  .go();
              await (db.delete(db.games)
                    ..where((t) => t.id.equals(game.id)))
                  .go();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('削除',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ChipTab extends ConsumerWidget {
  final int gameDayId;
  const _ChipTab({required this.gameDayId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return StreamBuilder<List<Player>>(
      stream: _watchPlayers(db),
      builder: (context, playersSnapshot) {
        if (!playersSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final players = playersSnapshot.data!;

        return StreamBuilder<List<ChipLoan>>(
          stream: (db.select(db.chipLoans)
                ..where((t) => t.gameDayId.equals(gameDayId))
                ..orderBy([
                  (t) => OrderingTerm.asc(t.createdAt)
                ]))
              .watch(),
          builder: (context, loansSnapshot) {
            if (!loansSnapshot.hasData) {
              return const Center(
                  child: CircularProgressIndicator());
            }
            final loans = loansSnapshot.data!;

            return _buildChipTable(
                context, db, players, loans);
          },
        );
      },
    );
  }

  Stream<List<Player>> _watchPlayers(AppDatabase db) {
    final query = db.select(db.players).join([
      innerJoin(db.gameDayPlayers,
          db.gameDayPlayers.playerId.equalsExp(db.players.id)),
    ])
      ..where(db.gameDayPlayers.gameDayId.equals(gameDayId));

    return query.watch().map(
        (rows) => rows.map((r) => r.readTable(db.players)).toList());
  }

  Widget _buildChipTable(BuildContext context, AppDatabase db,
      List<Player> players, List<ChipLoan> loans) {
    final playerMap = {for (final p in players) p.id: p.name};

    Widget cell(String text, {bool bold = false}) {
      return Container(
        padding: const EdgeInsets.symmetric(
            vertical: 10, horizontal: 8),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : null,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView(
        children: [
          Table(
            border: TableBorder.all(color: Colors.grey.shade400),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
              2: FixedColumnWidth(60),
            },
            children: [
              TableRow(
                decoration:
                    BoxDecoration(color: Colors.grey.shade200),
                children: [
                  cell('貸し手', bold: true),
                  cell('借り手', bold: true),
                  cell('枚数', bold: true),
                ],
              ),
              ...loans.map((loan) {
                return TableRow(
                  children: [
                    GestureDetector(
                      onLongPress: () =>
                          _showDeleteLoanDialog(context, db, loan),
                      child: cell(
                          playerMap[loan.lenderId] ?? '?'),
                    ),
                    GestureDetector(
                      onLongPress: () =>
                          _showDeleteLoanDialog(context, db, loan),
                      child: cell(
                          playerMap[loan.borrowerId] ?? '?'),
                    ),
                    GestureDetector(
                      onLongPress: () =>
                          _showDeleteLoanDialog(context, db, loan),
                      child: cell('${loan.amount}'),
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                _showAddLoanDialog(context, db, players),
            icon: const Icon(Icons.add),
            label: const Text('貸し借りを追加'),
          ),
        ],
      ),
    );
  }

  void _showAddLoanDialog(
      BuildContext context, AppDatabase db, List<Player> players) {
    int? lenderId;
    int? borrowerId;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('チップ貸し借り'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('貸し手',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                DropdownButton<int>(
                  value: lenderId,
                  isExpanded: true,
                  hint: const Text('選択'),
                  items: players
                      .map((p) => DropdownMenuItem(
                          value: p.id, child: Text(p.name)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => lenderId = v),
                ),
                const SizedBox(height: 8),
                const Text('借り手',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                DropdownButton<int>(
                  value: borrowerId,
                  isExpanded: true,
                  hint: const Text('選択'),
                  items: players
                      .map((p) => DropdownMenuItem(
                          value: p.id, child: Text(p.name)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => borrowerId = v),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  decoration:
                      const InputDecoration(labelText: '枚数'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                if (lenderId != null &&
                    borrowerId != null &&
                    lenderId != borrowerId &&
                    amountController.text.isNotEmpty) {
                  final amount =
                      int.tryParse(amountController.text) ?? 0;
                  if (amount > 0) {
                    await db.into(db.chipLoans).insert(
                          ChipLoansCompanion.insert(
                            gameDayId: gameDayId,
                            lenderId: lenderId!,
                            borrowerId: borrowerId!,
                            amount: amount,
                          ),
                        );
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteLoanDialog(
      BuildContext context, AppDatabase db, ChipLoan loan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('この貸し借り記録を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await (db.delete(db.chipLoans)
                    ..where((t) => t.id.equals(loan.id)))
                  .go();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('削除',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
