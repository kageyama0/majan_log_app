import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column, Table;
import 'package:majan_log_app/db/database.dart';
import 'package:majan_log_app/providers/database_provider.dart';
import 'package:majan_log_app/screens/chip_settlement_screen.dart';
import 'package:majan_log_app/widgets/hanchan_score_form.dart';

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

  void _confirmDelete(AppDatabase db) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('対戦日を削除'),
        content: const Text(
          'この対戦日を削除しますか？\n'
          '半荘・スコア・チップ記録もすべて削除されます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await db.deleteGameDayCascade(widget.gameDayId);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('削除',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
            return StreamBuilder<List<GameDayPlayer>>(
              stream: (db.select(db.gameDayPlayers)
                    ..where(
                        (t) => t.gameDayId.equals(widget.gameDayId)))
                  .watch(),
              builder: (context, playersSnap) {
                final n = playersSnap.data?.length;
                final suffix = (n != null && n > gd.playerCount)
                    ? '・$n人'
                    : '';
                return Text(
                    '${gd.date.year}/${gd.date.month}/${gd.date.day} ($typeStr$suffix)');
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '対戦日を削除',
            onPressed: () => _confirmDelete(db),
          ),
        ],
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

/// インライン編集の対象（追加 or 既存半荘）。
class _InlineHanchanEditor {
  final Game? game; // null = 新規追加
  final int gameNumber;
  final Map<int, int> initialScores;
  final Set<int>? initialSittingOutIds;

  const _InlineHanchanEditor({
    required this.gameNumber,
    this.game,
    this.initialScores = const {},
    this.initialSittingOutIds,
  });
}

class _ScoreTab extends ConsumerStatefulWidget {
  final int gameDayId;
  const _ScoreTab({required this.gameDayId});

  @override
  ConsumerState<_ScoreTab> createState() => _ScoreTabState();
}

class _ScoreTabState extends ConsumerState<_ScoreTab> {
  _InlineHanchanEditor? _inlineEditor;
  final _inlineFormKey = GlobalKey();

  int get gameDayId => widget.gameDayId;

  @override
  Widget build(BuildContext context) {
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
      ..where(db.gameDayPlayers.gameDayId.equals(gameDayId))
      ..orderBy([OrderingTerm.asc(db.gameDayPlayers.id)]);

    return query.watch().map(
        (rows) => rows.map((r) => r.readTable(db.players)).toList());
  }

  Widget _buildScoreTable(
      BuildContext context,
      AppDatabase db,
      GameDay gameDay,
      List<Player> players,
      List<Game> games,
      List<GameScore> allScores) {
    final seatCount = gameDay.playerCount;
    final hasSitOut = players.length > seatCount;
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
      return Container(
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
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView(
        children: [
          if (hasSitOut)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '参加者${players.length}人 / 席$seatCount人'
                '（休みは半荘ごとにローテ・「休」表示）\n'
                '行をタップで編集 / 長押しで削除',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '行をタップで編集 / 長押しで削除',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
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
                final editingThis = _inlineEditor?.game?.id == game.id;
                return TableRow(
                  decoration: editingThis
                      ? BoxDecoration(color: Colors.blue.shade50)
                      : null,
                  children: [
                    GestureDetector(
                      onTap: () => _openEdit(
                        context,
                        db,
                        gameDay,
                        players,
                        scores,
                        game,
                        useModal: hasSitOut,
                      ),
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
                      final sittingOut =
                          hasSitOut && score == null;
                      return GestureDetector(
                        onTap: () => _openEdit(
                          context,
                          db,
                          gameDay,
                          players,
                          scores,
                          game,
                          useModal: hasSitOut,
                        ),
                        onLongPress: () => _showDeleteGameDialog(
                            context, db, game),
                        child: sittingOut
                            ? cell('休',
                                color: Colors.grey.shade600,
                                bg: Colors.grey.shade100)
                            : cell(
                                () {
                                  final value = score?.score ?? 0;
                                  return value >= 0
                                      ? '+$value'
                                      : '$value';
                                }(),
                                color: (score?.score ?? 0) >= 0
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
          if (_inlineEditor != null) ...[
            KeyedSubtree(
              key: _inlineFormKey,
              child: HanchanScoreForm(
                key: ValueKey(
                  'inline-${_inlineEditor!.game?.id ?? 'new'}-'
                  '${_inlineEditor!.gameNumber}',
                ),
                gameNumber: _inlineEditor!.gameNumber,
                seatCount: seatCount,
                players: players,
                initialScores: _inlineEditor!.initialScores,
                initialSittingOutIds:
                    _inlineEditor!.initialSittingOutIds,
                inline: true,
                onCancel: () =>
                    setState(() => _inlineEditor = null),
                onSave: ({
                  required sittingOutIds,
                  required scores,
                }) async {
                  await _persistHanchan(
                    db: db,
                    existing: _inlineEditor!.game,
                    gameNumber: _inlineEditor!.gameNumber,
                    scores: scores,
                  );
                  if (mounted) {
                    setState(() => _inlineEditor = null);
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
          ] else
            ElevatedButton.icon(
              onPressed: () => _openAdd(
                context,
                db,
                gameDay,
                players,
                games,
                useModal: hasSitOut,
              ),
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

  Map<int, int> _scoresForGame(List<GameScore> scores, int gameId) {
    return {
      for (final s in scores.where((s) => s.gameId == gameId))
        s.playerId: s.score,
    };
  }

  Set<int> _sittingOutForGame(
    List<Player> players,
    List<GameScore> scores,
    int gameId,
  ) {
    final scored = scores
        .where((s) => s.gameId == gameId)
        .map((s) => s.playerId)
        .toSet();
    return players
        .where((p) => !scored.contains(p.id))
        .map((p) => p.id)
        .toSet();
  }

  Future<void> _persistHanchan({
    required AppDatabase db,
    required Game? existing,
    required int gameNumber,
    required Map<int, int> scores,
  }) async {
    await db.transaction(() async {
      late final int gameId;
      if (existing == null) {
        gameId = await db.into(db.games).insert(
              GamesCompanion.insert(
                gameDayId: gameDayId,
                gameNumber: gameNumber,
              ),
            );
      } else {
        gameId = existing.id;
        await (db.delete(db.gameScores)
              ..where((t) => t.gameId.equals(gameId)))
            .go();
      }
      for (final entry in scores.entries) {
        await db.into(db.gameScores).insert(
              GameScoresCompanion.insert(
                gameId: gameId,
                playerId: entry.key,
                score: entry.value,
              ),
            );
      }
    });
  }

  void _openAdd(
    BuildContext context,
    AppDatabase db,
    GameDay gameDay,
    List<Player> players,
    List<Game> games, {
    required bool useModal,
  }) {
    final gameNumber = games.length + 1;
    if (useModal) {
      _showHanchanDialog(
        context: context,
        db: db,
        gameDay: gameDay,
        players: players,
        gameNumber: gameNumber,
        existing: null,
        initialScores: const {},
        initialSittingOutIds: null,
      );
      return;
    }
    setState(() {
      _inlineEditor = _InlineHanchanEditor(gameNumber: gameNumber);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _inlineFormKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openEdit(
    BuildContext context,
    AppDatabase db,
    GameDay gameDay,
    List<Player> players,
    List<GameScore> scores,
    Game game, {
    required bool useModal,
  }) {
    final initialScores = _scoresForGame(scores, game.id);
    final initialSitOut = players.length > gameDay.playerCount
        ? _sittingOutForGame(players, scores, game.id)
        : <int>{};

    if (useModal) {
      _showHanchanDialog(
        context: context,
        db: db,
        gameDay: gameDay,
        players: players,
        gameNumber: game.gameNumber,
        existing: game,
        initialScores: initialScores,
        initialSittingOutIds: initialSitOut,
      );
      return;
    }
    setState(() {
      _inlineEditor = _InlineHanchanEditor(
        game: game,
        gameNumber: game.gameNumber,
        initialScores: initialScores,
        initialSittingOutIds: initialSitOut,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _inlineFormKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showHanchanDialog({
    required BuildContext context,
    required AppDatabase db,
    required GameDay gameDay,
    required List<Player> players,
    required int gameNumber,
    required Game? existing,
    required Map<int, int> initialScores,
    required Set<int>? initialSittingOutIds,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => HanchanScoreForm(
        gameNumber: gameNumber,
        seatCount: gameDay.playerCount,
        players: players,
        initialScores: initialScores,
        initialSittingOutIds: initialSittingOutIds,
        onCancel: () => Navigator.pop(dialogContext),
        onSave: ({
          required sittingOutIds,
          required scores,
        }) async {
          await _persistHanchan(
            db: db,
            existing: existing,
            gameNumber: gameNumber,
            scores: scores,
          );
          if (dialogContext.mounted) {
            Navigator.pop(dialogContext);
          }
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
              if (mounted) {
                setState(() {
                  if (_inlineEditor?.game?.id == game.id) {
                    _inlineEditor = null;
                  }
                });
              }
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
      ..where(db.gameDayPlayers.gameDayId.equals(gameDayId))
      ..orderBy([OrderingTerm.asc(db.gameDayPlayers.id)]);

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
