import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:majan_log_app/db/database.dart';
import 'package:majan_log_app/providers/database_provider.dart';

enum _FilterMode { all, sanma, yonma }

class PlayerDetailScreen extends ConsumerStatefulWidget {
  final int playerId;

  const PlayerDetailScreen({super.key, required this.playerId});

  @override
  ConsumerState<PlayerDetailScreen> createState() =>
      _PlayerDetailScreenState();
}

class _PlayerDetailScreenState
    extends ConsumerState<PlayerDetailScreen> {
  _FilterMode _filter = _FilterMode.all;
  _PlayerDetail? _detail;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = ref.read(databaseProvider);
    final detail = await _load(db);
    if (mounted) setState(() => _detail = detail);
  }

  @override
  Widget build(BuildContext context) {
    if (_detail == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final detail = _detail!;
    final filtered = _applyFilter(detail);

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: '名前を変更',
            onPressed: () => _showEditDialog(detail.name),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: '削除',
            onPressed: () => _showDeleteDialog(detail.name),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<_FilterMode>(
            segments: const [
              ButtonSegment(
                  value: _FilterMode.all, label: Text('全体')),
              ButtonSegment(
                  value: _FilterMode.sanma, label: Text('三麻')),
              ButtonSegment(
                  value: _FilterMode.yonma, label: Text('四麻')),
            ],
            selected: {_filter},
            onSelectionChanged: (v) =>
                setState(() => _filter = v.first),
          ),
          const SizedBox(height: 16),
          _summaryCard(filtered),
          if (_filter != _FilterMode.all) ...[
            const SizedBox(height: 16),
            _rankCard(filtered),
          ],
          const SizedBox(height: 16),
          const Text('対戦履歴',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (filtered.gameDayRecords.isEmpty)
            const Text('まだ対戦記録がありません')
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  const DataColumn(label: Text('日付')),
                  if (_filter == _FilterMode.all)
                    const DataColumn(label: Text('形式')),
                  const DataColumn(label: Text('半荘数')),
                  const DataColumn(label: Text('スコア計')),
                  const DataColumn(label: Text('チップ純収支')),
                ],
                rows: filtered.gameDayRecords.map((r) {
                  return DataRow(cells: [
                    DataCell(Text(r.dateStr)),
                    if (_filter == _FilterMode.all)
                      DataCell(Text(r.type)),
                    DataCell(Text('${r.gameCount}')),
                    DataCell(Text(
                      _fmt(r.totalScore),
                      style: TextStyle(
                        color: r.totalScore >= 0
                            ? Colors.black
                            : Colors.red,
                      ),
                    )),
                    DataCell(Text(
                      _fmt(r.chipNet),
                      style: TextStyle(
                        color: r.chipNet >= 0
                            ? Colors.black
                            : Colors.red,
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  _FilteredDetail _applyFilter(_PlayerDetail detail) {
    List<_GameDayRecord> records;
    List<_GameRank> ranks;

    switch (_filter) {
      case _FilterMode.sanma:
        records = detail.gameDayRecords
            .where((r) => r.playerCount == 3)
            .toList();
        ranks = detail.gameRanks
            .where((r) => r.playerCount == 3)
            .toList();
      case _FilterMode.yonma:
        records = detail.gameDayRecords
            .where((r) => r.playerCount == 4)
            .toList();
        ranks = detail.gameRanks
            .where((r) => r.playerCount == 4)
            .toList();
      case _FilterMode.all:
        records = detail.gameDayRecords;
        ranks = detail.gameRanks;
    }

    final gameDayCount = records.length;
    final totalGames =
        records.fold<int>(0, (sum, r) => sum + r.gameCount);
    final totalScore =
        records.fold<int>(0, (sum, r) => sum + r.totalScore);
    final totalChipNet =
        records.fold<int>(0, (sum, r) => sum + r.chipNet);

    final maxRank = _filter == _FilterMode.sanma ? 3 : 4;
    final rankCounts = <int, int>{};
    for (int i = 1; i <= maxRank; i++) {
      rankCounts[i] = 0;
    }
    for (final r in ranks) {
      rankCounts[r.rank] = (rankCounts[r.rank] ?? 0) + 1;
    }

    return _FilteredDetail(
      gameDayCount: gameDayCount,
      totalGames: totalGames,
      totalScore: totalScore,
      totalChipNet: totalChipNet,
      rankCounts: rankCounts,
      gameDayRecords: records,
    );
  }

  Widget _summaryCard(_FilteredDetail detail) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statColumn('対戦日数', '${detail.gameDayCount}'),
                _statColumn('半荘数', '${detail.totalGames}'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statColumn('累計順位点', _fmt(detail.totalScore),
                    color: detail.totalScore >= 0
                        ? Colors.green
                        : Colors.red),
                _statColumn('累計チップ', _fmt(detail.totalChipNet),
                    color: detail.totalChipNet >= 0
                        ? Colors.green
                        : Colors.red),
              ],
            ),
            if (detail.totalGames > 0) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statColumn('平均スコア/半荘',
                      _fmtDouble(detail.totalScore / detail.totalGames)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _rankCard(_FilteredDetail detail) {
    if (detail.totalGames == 0) return const SizedBox.shrink();

    final rankCounts = detail.rankCounts;
    final total = detail.totalGames;
    final rankLabels = ['', '1着', '2着', '3着', '4着'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('順位分布',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...rankCounts.entries.map((entry) {
              final rank = entry.key;
              final count = entry.value;
              final pct =
                  total > 0 ? (count / total * 100) : 0.0;
              final ratio = total > 0 ? count / total : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(rankLabels[rank],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 20,
                          backgroundColor: Colors.grey.shade200,
                          color: _rankColor(rank),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        '  $count回 (${pct.toStringAsFixed(1)}%)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.blueGrey.shade300;
      case 3:
        return Colors.brown.shade300;
      default:
        return Colors.grey.shade400;
    }
  }

  Widget _statColumn(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }

  void _showEditDialog(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('名前を変更'),
        content: TextField(
          controller: controller,
          autofocus: true,
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
                final db = ref.read(databaseProvider);
                (db.update(db.players)
                      ..where(
                          (t) => t.id.equals(widget.playerId)))
                    .write(PlayersCompanion(name: Value(name)));
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('$name を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final db = ref.read(databaseProvider);
              (db.delete(db.players)
                    ..where(
                        (t) => t.id.equals(widget.playerId)))
                  .go();
              Navigator.pop(context);
              Navigator.of(this.context).pop();
            },
            child: const Text('削除',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) => n >= 0 ? '+$n' : '$n';
  String _fmtDouble(double n) =>
      n >= 0 ? '+${n.toStringAsFixed(1)}' : n.toStringAsFixed(1);

  Future<_PlayerDetail?> _load(AppDatabase db) async {
    final player = await (db.select(db.players)
          ..where((t) => t.id.equals(widget.playerId)))
        .getSingleOrNull();
    if (player == null) return null;

    final gdpRows = await (db.select(db.gameDayPlayers)
          ..where((t) => t.playerId.equals(widget.playerId)))
        .get();
    final gameDayIds = gdpRows.map((r) => r.gameDayId).toSet();

    final allGameDays = await db.select(db.gameDays).get();
    final allGames = await db.select(db.games).get();
    final allScores = await db.select(db.gameScores).get();
    final allChipSettlements = await (db.select(db.chipSettlements)
          ..where((t) => t.playerId.equals(widget.playerId)))
        .get();
    final allChipLoans = await db.select(db.chipLoans).get();

    final myScores = allScores
        .where((s) => s.playerId == widget.playerId)
        .toList();

    final records = <_GameDayRecord>[];
    final gameRanks = <_GameRank>[];

    for (final gdId in gameDayIds) {
      final gd = allGameDays.where((g) => g.id == gdId).firstOrNull;
      if (gd == null) continue;

      final games =
          allGames.where((g) => g.gameDayId == gdId).toList();
      final gameIds = games.map((g) => g.id).toSet();

      final scores = myScores
          .where((s) => gameIds.contains(s.gameId))
          .toList();
      final dayScore =
          scores.fold<int>(0, (sum, s) => sum + s.score);

      final chipSettlement = allChipSettlements
          .where((cs) => cs.gameDayId == gdId)
          .firstOrNull;
      final chipDiff = chipSettlement?.chipDiff ?? 0;

      int loanBalance = 0;
      for (final loan in allChipLoans) {
        if (loan.gameDayId != gdId) continue;
        if (loan.borrowerId == widget.playerId) {
          loanBalance += loan.amount;
        }
        if (loan.lenderId == widget.playerId) {
          loanBalance -= loan.amount;
        }
      }
      final chipNet = chipDiff - loanBalance;

      final dateStr =
          '${gd.date.year}/${gd.date.month}/${gd.date.day}';

      records.add(_GameDayRecord(
        dateStr: dateStr,
        type: gd.playerCount == 3 ? '三麻' : '四麻',
        playerCount: gd.playerCount,
        gameCount: games.length,
        totalScore: dayScore,
        chipNet: chipNet,
      ));

      for (final game in games) {
        final gameScores = allScores
            .where((s) => s.gameId == game.id)
            .toList();
        gameScores.sort((a, b) => b.score.compareTo(a.score));

        int rank = 1;
        for (final gs in gameScores) {
          if (gs.playerId == widget.playerId) {
            gameRanks.add(_GameRank(
              rank: rank,
              playerCount: gd.playerCount,
            ));
            break;
          }
          rank++;
        }
      }
    }

    records.sort((a, b) => b.dateStr.compareTo(a.dateStr));

    return _PlayerDetail(
      name: player.name,
      gameDayRecords: records,
      gameRanks: gameRanks,
    );
  }
}

class _PlayerDetail {
  final String name;
  final List<_GameDayRecord> gameDayRecords;
  final List<_GameRank> gameRanks;

  _PlayerDetail({
    required this.name,
    required this.gameDayRecords,
    required this.gameRanks,
  });
}

class _FilteredDetail {
  final int gameDayCount;
  final int totalGames;
  final int totalScore;
  final int totalChipNet;
  final Map<int, int> rankCounts;
  final List<_GameDayRecord> gameDayRecords;

  _FilteredDetail({
    required this.gameDayCount,
    required this.totalGames,
    required this.totalScore,
    required this.totalChipNet,
    required this.rankCounts,
    required this.gameDayRecords,
  });
}

class _GameDayRecord {
  final String dateStr;
  final String type;
  final int playerCount;
  final int gameCount;
  final int totalScore;
  final int chipNet;

  _GameDayRecord({
    required this.dateStr,
    required this.type,
    required this.playerCount,
    required this.gameCount,
    required this.totalScore,
    required this.chipNet,
  });
}

class _GameRank {
  final int rank;
  final int playerCount;

  _GameRank({required this.rank, required this.playerCount});
}
