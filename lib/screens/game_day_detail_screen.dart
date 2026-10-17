import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column, Table;
import 'package:majan_log_app/db/database.dart';
import 'package:majan_log_app/providers/database_provider.dart';
import 'package:majan_log_app/screens/chip_settlement_screen.dart';
import 'package:majan_log_app/utils/sit_out_rotation.dart';
import 'package:majan_log_app/widgets/hanchan_row_editor.dart';

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


class _ScoreTab extends ConsumerStatefulWidget {
  final int gameDayId;
  const _ScoreTab({required this.gameDayId});

  @override
  ConsumerState<_ScoreTab> createState() => _ScoreTabState();
}

class _ScoreTabState extends ConsumerState<_ScoreTab> {
  /// 既存半荘のセル直打ち状態
  final Map<int, HanchanRowEditor> _rowEditors = {};

  /// 未保存の新規半荘行
  HanchanRowEditor? _draftRow;

  int get gameDayId => widget.gameDayId;

  @override
  void dispose() {
    for (final e in _rowEditors.values) {
      e.dispose();
    }
    _draftRow?.dispose();
    super.dispose();
  }

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
              return const Center(child: CircularProgressIndicator());
            }
            final players = playersSnapshot.data!;

            return StreamBuilder<List<Game>>(
              stream: (db.select(db.games)
                    ..where((t) => t.gameDayId.equals(gameDayId))
                    ..orderBy([(t) => OrderingTerm.asc(t.gameNumber)]))
                  .watch(),
              builder: (context, gamesSnapshot) {
                if (!gamesSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final games = gamesSnapshot.data!;

                return StreamBuilder<List<GameScore>>(
                  stream: db.select(db.gameScores).watch(),
                  builder: (context, scoresSnapshot) {
                    if (!scoresSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final allScores = scoresSnapshot.data!;
                    return _buildScoreTable(
                        context, db, gameDay, players, games, allScores);
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

  void _syncSpreadsheetEditors(
    List<Player> players,
    List<Game> games,
    List<GameScore> scores,
    int seatCount,
  ) {
    final playerIds = players.map((p) => p.id).toList();
    final liveIds = games.map((g) => g.id).toSet();

    for (final id in _rowEditors.keys.toList()) {
      if (!liveIds.contains(id)) {
        _rowEditors.remove(id)?.dispose();
      }
    }

    for (final game in games) {
      final gameScores = _scoresForGame(scores, game.id);
      final existing = _rowEditors[game.id];
      if (existing == null) {
        _rowEditors[game.id] = HanchanRowEditor(
          gameId: game.id,
          gameNumber: game.gameNumber,
          playerIds: playerIds,
          seatCount: seatCount,
          initialScores: gameScores,
          initialSittingOutIds: players.length > seatCount
              ? _sittingOutForGame(players, scores, game.id)
              : const {},
        );
      } else {
        existing.syncFromScores(gameScores);
      }
    }

    if (_draftRow != null &&
        (!_listEquals(_draftRow!.playerIds, playerIds) ||
            _draftRow!.seatCount != seatCount)) {
      final prevNumber = _draftRow!.gameNumber;
      _draftRow!.dispose();
      _draftRow = HanchanRowEditor(
        gameNumber: prevNumber,
        playerIds: playerIds,
        seatCount: seatCount,
        initialSittingOutIds: defaultSittingOutPlayerIds(
          participantIds: playerIds,
          seatCount: seatCount,
          gameNumber: prevNumber,
        ).toSet(),
      );
    }
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Widget _buildScoreTable(
    BuildContext context,
    AppDatabase db,
    GameDay gameDay,
    List<Player> players,
    List<Game> games,
    List<GameScore> allScores,
  ) {
    final seatCount = gameDay.playerCount;
    final hasSitOut = players.length > seatCount;
    final gameIds = games.map((g) => g.id).toSet();
    final scores =
        allScores.where((s) => gameIds.contains(s.gameId)).toList();

    _syncSpreadsheetEditors(players, games, scores, seatCount);

    final totals = <int, int>{};
    for (final p in players) {
      totals[p.id] = 0;
    }
    for (final s in scores) {
      totals[s.playerId] = (totals[s.playerId] ?? 0) + s.score;
    }

    final colWidths = <int, TableColumnWidth>{
      0: const FixedColumnWidth(40),
    };
    for (int i = 1; i <= players.length; i++) {
      colWidths[i] = const FlexColumnWidth(1);
    }

    Widget cell(String text,
        {bool bold = false, Color? color, Color? bg}) {
      return Container(
        color: bg,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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

    final hint = hasSitOut
        ? '参加者${players.length}人 / 席$seatCount人\n'
            '点数はセル入力・名前長押しで休み指定・「休」マスタップで復帰 / #長押しで削除'
        : 'セルをタップして直接入力（次へで隣へ） / #長押しで削除';

    final activeEditor = hasSitOut ? _resolveActiveEditor(games) : null;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              hint,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
          Table(
            border: TableBorder.all(color: Colors.grey.shade400),
            columnWidths: colWidths,
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade200),
                children: [
                  cell('#', bold: true),
                  ...players.map((p) {
                    final nameCell = cell(p.name, bold: true);
                    if (!hasSitOut) return nameCell;
                    // 名前は Text（TextFieldではない）なので長押しが確実に効く
                    return GestureDetector(
                      onLongPress: () => _onPlayerNameLongPress(
                        db: db,
                        games: games,
                        playerId: p.id,
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: nameCell,
                    );
                  }),
                ],
              ),
              ...games.map((game) {
                final editor = _rowEditors[game.id]!;
                return _spreadsheetTableRow(
                  db: db,
                  players: players,
                  editor: editor,
                  existing: game,
                  gameNumberLabel: '${game.gameNumber}',
                  decoration: null,
                  onDelete: () =>
                      _showDeleteGameDialog(context, db, game),
                  cell: cell,
                );
              }),
              if (_draftRow != null)
                _spreadsheetTableRow(
                  db: db,
                  players: players,
                  editor: _draftRow!,
                  existing: null,
                  gameNumberLabel: '${games.length + 1}',
                  decoration: BoxDecoration(color: Colors.amber.shade50),
                  onDelete: null,
                  cell: cell,
                ),
              TableRow(
                children: [
                  cell(''),
                  ...players.map((_) => cell('')),
                ],
              ),
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade100),
                children: [
                  cell('計', bold: true),
                  ...players.map((p) {
                    final total = totals[p.id] ?? 0;
                    return cell(
                      total >= 0 ? '+$total' : '$total',
                      bold: true,
                      color: total >= 0 ? Colors.black : Colors.red,
                    );
                  }),
                ],
              ),
              TableRow(
                decoration: BoxDecoration(color: Colors.green.shade50),
                children: [
                  cell('円', bold: true),
                  ...players.map((p) {
                    final total = totals[p.id] ?? 0;
                    final yen = total * gameDay.scoreRate;
                    return cell(
                      '${yen >= 0 ? "+" : ""}${_formatYen(yen)}',
                      bold: true,
                      color: yen >= 0 ? Colors.black : Colors.red,
                    );
                  }),
                ],
              ),
            ],
          ),
          if (hasSitOut &&
              activeEditor != null &&
              !activeEditor.sitOutCountOk)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '休みはちょうど ${activeEditor.excess} 人にしてください'
                '（名前を長押し／「休」マスをタップ）',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openAdd(db, gameDay, players, games),
            icon: const Icon(Icons.add),
            label: Text(
              _draftRow != null ? '入力中の半荘があります' : '半荘を追加',
            ),
          ),
          if (_draftRow != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _draftRow?.dispose();
                  _draftRow = null;
                });
              },
              child: const Text('新規行をキャンセル'),
            ),
        ],
      ),
    );
  }

  /// 入力中の半荘: フォーカス中の行 → 新規ドラフト行 → dirty な既存行。
  HanchanRowEditor? _resolveActiveEditor(List<Game> games) {
    for (final game in games) {
      final editor = _rowEditors[game.id];
      if (editor != null && editor.anyFocused) return editor;
    }
    if (_draftRow != null && _draftRow!.anyFocused) return _draftRow;
    if (_draftRow != null) return _draftRow;
    for (final game in games) {
      final editor = _rowEditors[game.id];
      if (editor != null && editor.dirty) return editor;
    }
    return null;
  }

  Game? _gameForEditor(List<Game> games, HanchanRowEditor editor) {
    final id = editor.gameId;
    if (id == null) return null;
    for (final g in games) {
      if (g.id == id) return g;
    }
    return null;
  }

  void _onPlayerNameLongPress({
    required AppDatabase db,
    required List<Game> games,
    required int playerId,
  }) {
    final editor = _resolveActiveEditor(games);
    if (editor == null || !editor.hasSitOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '編集中の半荘がありません。'
            '半荘を追加するか、点数セルをタップしてから名前を長押ししてください',
          ),
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => editor.toggleSitOut(playerId));
    _maybePersistSpreadsheetRow(
      db: db,
      editor: editor,
      existing: _gameForEditor(games, editor),
    );
  }

  TableRow _spreadsheetTableRow({
    required AppDatabase db,
    required List<Player> players,
    required HanchanRowEditor editor,
    required Game? existing,
    required String gameNumberLabel,
    required BoxDecoration? decoration,
    required VoidCallback? onDelete,
    required Widget Function(String text,
            {bool bold, Color? color, Color? bg})
        cell,
  }) {
    return TableRow(
      decoration: decoration,
      children: [
        GestureDetector(
          onLongPress: onDelete,
          child: cell(gameNumberLabel),
        ),
        ...players.map((p) {
          if (editor.isSittingOut(p.id)) {
            return SitOutSpreadsheetCell(
              onTap: () {
                setState(() => editor.toggleSitOut(p.id));
                _maybePersistSpreadsheetRow(
                  db: db,
                  editor: editor,
                  existing: existing,
                );
              },
              onLongPress: onDelete,
            );
          }
          return ScoreSpreadsheetCell(
            controller: editor.controllers[p.id]!,
            focusNode: editor.focusNodes[p.id]!,
            isLastInRow: editor.isLastSeated(p.id),
            onLongPress: editor.hasSitOut ? null : onDelete,
            onChanged: (_) {
              editor.dirty = true;
              if (editor.autoFilledPlayerId == p.id) {
                editor.autoFilledPlayerId = null;
              }
              editor.autoCalcLast(skipPlayerId: p.id);
              if (editor.parsedScoresOrNull() != null &&
                  editor.autoFilledPlayerId != null) {
                _maybePersistSpreadsheetRow(
                  db: db,
                  editor: editor,
                  existing: existing,
                );
              }
            },
            onEditingComplete: () {
              editor.autoCalcLast();
              editor.focusNextSeated(p.id);
              _maybePersistSpreadsheetRow(
                db: db,
                editor: editor,
                existing: existing,
              );
            },
          );
        }),
      ],
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

  Future<void> _maybePersistSpreadsheetRow({
    required AppDatabase db,
    required HanchanRowEditor editor,
    required Game? existing,
  }) async {
    editor.autoCalcLast();
    final scores = editor.parsedScoresOrNull();
    if (scores == null || editor.saving) return;
    if (editor.isUnchanged(scores)) return;

    editor.saving = true;
    try {
      final gameNumber = existing?.gameNumber ?? editor.gameNumber;
      await _persistHanchan(
        db: db,
        existing: existing,
        gameNumber: gameNumber,
        scores: scores,
      );
      editor.lastPersisted = Map<int, int>.from(scores);
      editor.dirty = false;
      if (existing == null && mounted) {
        setState(() {
          if (identical(_draftRow, editor)) {
            _draftRow?.dispose();
            _draftRow = null;
          }
        });
      }
    } finally {
      editor.saving = false;
    }
  }

  void _openAdd(
    AppDatabase db,
    GameDay gameDay,
    List<Player> players,
    List<Game> games,
  ) {
    final gameNumber = games.length + 1;
    final playerIds = players.map((p) => p.id).toList();
    final seatCount = gameDay.playerCount;

    if (_draftRow != null) {
      final first = _draftRow!.firstSeatedId;
      if (first != null) {
        _draftRow!.focusNodes[first]?.requestFocus();
      }
      return;
    }

    setState(() {
      _draftRow = HanchanRowEditor(
        gameNumber: gameNumber,
        playerIds: playerIds,
        seatCount: seatCount,
        initialSittingOutIds: defaultSittingOutPlayerIds(
          participantIds: playerIds,
          seatCount: seatCount,
          gameNumber: gameNumber,
        ).toSet(),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final first = _draftRow?.firstSeatedId;
      if (first != null) {
        _draftRow?.focusNodes[first]?.requestFocus();
      }
    });
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
                  _rowEditors.remove(game.id)?.dispose();
                });
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
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
