import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:majan_log_app/db/database.dart';
import 'package:majan_log_app/providers/database_provider.dart';
import 'package:majan_log_app/utils/score_balance.dart';
import 'package:majan_log_app/utils/signed_int_input.dart';
import 'package:majan_log_app/utils/venue_fee_split.dart';

class ChipSettlementScreen extends ConsumerStatefulWidget {
  final int gameDayId;

  const ChipSettlementScreen({super.key, required this.gameDayId});

  @override
  ConsumerState<ChipSettlementScreen> createState() =>
      _ChipSettlementScreenState();
}

class _ChipSettlementScreenState
    extends ConsumerState<ChipSettlementScreen> {
  List<Player> _players = [];
  List<ChipLoan> _loans = [];
  GameDay? _gameDay;
  Map<int, int> _scoreTotals = {};
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, FocusNode> _focusNodes = {};
  final _venueFeeController = TextEditingController();
  int? _autoFilledPlayerId;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = ref.read(databaseProvider);

    final gameDayRow = await (db.select(db.gameDays)
          ..where((t) => t.id.equals(widget.gameDayId)))
        .getSingle();

    final playerRows = await (db.select(db.players).join([
      innerJoin(db.gameDayPlayers,
          db.gameDayPlayers.playerId.equalsExp(db.players.id)),
    ])
          ..where(
              db.gameDayPlayers.gameDayId.equals(widget.gameDayId)))
        .get();
    final players =
        playerRows.map((r) => r.readTable(db.players)).toList();

    final loans = await (db.select(db.chipLoans)
          ..where((t) => t.gameDayId.equals(widget.gameDayId)))
        .get();

    final games = await (db.select(db.games)
          ..where((t) => t.gameDayId.equals(widget.gameDayId)))
        .get();
    final gameIds = games.map((g) => g.id).toSet();

    final allScores = await db.select(db.gameScores).get();
    final scores =
        allScores.where((s) => gameIds.contains(s.gameId)).toList();

    final scoreTotals = <int, int>{};
    for (final p in players) {
      scoreTotals[p.id] = 0;
    }
    for (final s in scores) {
      scoreTotals[s.playerId] =
          (scoreTotals[s.playerId] ?? 0) + s.score;
    }

    final existing = await (db.select(db.chipSettlements)
          ..where((t) => t.gameDayId.equals(widget.gameDayId)))
        .get();

    setState(() {
      _gameDay = gameDayRow;
      _players = players;
      _loans = loans;
      _scoreTotals = scoreTotals;
      _venueFeeController.text =
          gameDayRow.venueFee > 0 ? '${gameDayRow.venueFee}' : '';
      for (final p in players) {
        final prev =
            existing.where((s) => s.playerId == p.id).firstOrNull;
        _controllers[p.id] = TextEditingController(
          text: prev != null ? '${prev.chipDiff}' : '',
        );
        final focus = FocusNode();
        focus.addListener(() => _handleChipDiffFocus(p.id));
        _focusNodes[p.id] = focus;
      }
      _autoFilledPlayerId = null;
      _saved = existing.isNotEmpty;
    });
  }

  @override
  void dispose() {
    for (final n in _focusNodes.values) {
      n.dispose();
    }
    for (final c in _controllers.values) {
      c.dispose();
    }
    _venueFeeController.dispose();
    super.dispose();
  }

  void _handleChipDiffFocus(int playerId) {
    if (!(_focusNodes[playerId]?.hasFocus ?? false)) return;
    if (_tryAutoFillChipDiffOnFocus(playerId)) {
      setState(() {});
    }
  }

  /// フォーカスした欄が「唯一の未入力」ならゼロ和で埋める（順位点と同じ）。
  bool _tryAutoFillChipDiffOnFocus(int focusedPlayerId) {
    final texts = <int, String>{
      for (final p in _players) p.id: _controllers[p.id]?.text ?? '',
    };
    final result = computeZeroSumAutoFillOnFocus(
      focusedPlayerId: focusedPlayerId,
      textsByPlayerId: texts,
      autoFilledPlayerId: _autoFilledPlayerId,
    );
    if (result == null) return false;

    final controller = _controllers[result.playerId]!;
    final next = '${result.value}';
    if (controller.text != next) {
      controller.text = next;
      controller.selection =
          TextSelection.collapsed(offset: next.length);
    }
    _autoFilledPlayerId = result.playerId;
    return true;
  }

  Map<int, int> _calcLoanBalance() {
    final balance = <int, int>{};
    for (final p in _players) {
      balance[p.id] = 0;
    }
    for (final loan in _loans) {
      balance[loan.lenderId] =
          (balance[loan.lenderId] ?? 0) - loan.amount;
      balance[loan.borrowerId] =
          (balance[loan.borrowerId] ?? 0) + loan.amount;
    }
    return balance;
  }

  int _parseChipDiff(int playerId) =>
      parseSignedInt(_controllers[playerId]?.text ?? '') ?? 0;

  Map<int, int> _calcChipNet() {
    final loanBalance = _calcLoanBalance();
    final net = <int, int>{};
    for (final p in _players) {
      final chipDiff = _parseChipDiff(p.id);
      final borrowed = loanBalance[p.id] ?? 0;
      net[p.id] = chipDiff - borrowed;
    }
    return net;
  }

  /// 場代の全体額（入力値）。DB にもこの全体額を保存する。
  int _getVenueFeeTotal() =>
      int.tryParse(_venueFeeController.text.trim()) ?? 0;

  /// 場代控除前の合計収支（順位点¥ + チップ¥）。
  Map<int, int> _calcPreVenueBalanceYen() {
    final chipNet = _calcChipNet();
    final gd = _gameDay!;
    final balance = <int, int>{};
    for (final p in _players) {
      final scoreYen = (_scoreTotals[p.id] ?? 0) * gd.scoreRate;
      final chipYen = (chipNet[p.id] ?? 0) * gd.chipRate;
      balance[p.id] = scoreYen + chipYen;
    }
    return balance;
  }

  VenueFeeSplitResult _splitVenueFees() {
    final ranked = rankPlayersForVenueFee(
      playerIds: _players.map((p) => p.id),
      preVenueBalanceYen: _calcPreVenueBalanceYen(),
      scorePoints: _scoreTotals,
    );
    return splitVenueFee(
      total: _getVenueFeeTotal(),
      rankedPlayerIds: ranked,
    );
  }

  Map<int, int> _calcTotalYen(Map<int, int> venueFees) {
    final pre = _calcPreVenueBalanceYen();
    return {
      for (final p in _players)
        p.id: (pre[p.id] ?? 0) - (venueFees[p.id] ?? 0),
    };
  }

  String _venueFeeHelperText(VenueFeeSplitResult split) {
    final total = _getVenueFeeTotal();
    if (total <= 0 || _players.isEmpty) {
      return '参加者全員で割ります（100円単位・余りは勝ち側）';
    }
    final nameOf = {for (final p in _players) p.id: p.name};
    final ranked = rankPlayersForVenueFee(
      playerIds: _players.map((p) => p.id),
      preVenueBalanceYen: _calcPreVenueBalanceYen(),
      scorePoints: _scoreTotals,
    );
    final parts = ranked
        .map((id) => '${nameOf[id]}${split.feesByPlayerId[id]}')
        .join('・');
    final discard = split.discarded > 0 ? '・端数${split.discarded}切捨' : '';
    return '$parts（${split.unit}円単位・余りは勝ち側$discard）';
  }

  List<String> _calcTransfers(Map<int, int> totalYen) {
    final playerName = {for (final p in _players) p.id: p.name};
    final remaining = {
      for (final e in totalYen.entries) e.key: e.value
    };
    final transfers = <String>[];

    final debtors = totalYen.entries
        .where((e) => e.value < 0)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final creditors = totalYen.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    int i = 0, j = 0;
    while (i < debtors.length && j < creditors.length) {
      final debtorId = debtors[i].key;
      final creditorId = creditors[j].key;
      final debtAmt = -remaining[debtorId]!;
      final creditAmt = remaining[creditorId]!;
      final transfer = debtAmt < creditAmt ? debtAmt : creditAmt;

      if (transfer > 0) {
        transfers.add(
            '${playerName[debtorId]} → ${playerName[creditorId]}: ${_formatYenDisplay(transfer)}');
      }

      remaining[debtorId] = remaining[debtorId]! + transfer;
      remaining[creditorId] = remaining[creditorId]! - transfer;

      if (remaining[debtorId] == 0) i++;
      if (remaining[creditorId] == 0) j++;
    }

    return transfers;
  }

  @override
  Widget build(BuildContext context) {
    if (_players.isEmpty || _gameDay == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('精算')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final gd = _gameDay!;
    final venueFeeTotal = _getVenueFeeTotal();
    final venueFeeSplit = _splitVenueFees();
    final venueFees = venueFeeSplit.feesByPlayerId;
    final loanBalance = _calcLoanBalance();
    final chipNet = _calcChipNet();
    final totalYen = _calcTotalYen(venueFees);
    final transfers = _calcTransfers(totalYen);

    return Scaffold(
      appBar: AppBar(title: const Text('精算')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'チップ差枚数を入力',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...(_players.map((p) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextField(
                controller: _controllers[p.id],
                focusNode: _focusNodes[p.id],
                decoration: InputDecoration(
                  labelText: p.name,
                  border: const OutlineInputBorder(),
                  suffixText: '枚',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(
                        signed: true, decimal: false),
                inputFormatters: const [
                  SignedIntegerTextInputFormatter(),
                ],
                onChanged: (_) => setState(() {}),
              ),
            );
          })),
          const SizedBox(height: 16),
          TextField(
            controller: _venueFeeController,
            decoration: InputDecoration(
              labelText: '場代（全体）',
              border: const OutlineInputBorder(),
              helperText: _venueFeeHelperText(venueFeeSplit),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(_saved ? '更新' : '保存'),
          ),
          if (_saved) ...[
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              '収支内訳',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                columns: [
                  const DataColumn(label: Text('名前')),
                  const DataColumn(label: Text('順位点')),
                  const DataColumn(label: Text('チップ')),
                  if (venueFeeTotal > 0)
                    const DataColumn(label: Text('場代')),
                  const DataColumn(label: Text('合計')),
                ],
                rows: _players.map((p) {
                  final scoreTotal = _scoreTotals[p.id] ?? 0;
                  final scoreYen = scoreTotal * gd.scoreRate;
                  final chipNetVal = chipNet[p.id] ?? 0;
                  final chipYen = chipNetVal * gd.chipRate;
                  final venueFee = venueFees[p.id] ?? 0;
                  final total = totalYen[p.id] ?? 0;
                  return DataRow(cells: [
                    DataCell(Text(p.name)),
                    DataCell(Text(
                      '${scoreYen >= 0 ? "+" : "-"}${_formatYenDisplay(scoreYen.abs())}',
                      style: TextStyle(
                        color: scoreYen >= 0
                            ? Colors.black
                            : Colors.red,
                      ),
                    )),
                    DataCell(Text(
                      '${chipYen >= 0 ? "+" : "-"}${_formatYenDisplay(chipYen.abs())}',
                      style: TextStyle(
                        color: chipYen >= 0
                            ? Colors.black
                            : Colors.red,
                      ),
                    )),
                    if (venueFeeTotal > 0)
                      DataCell(Text(
                        '-${_formatYenDisplay(venueFee)}',
                        style: const TextStyle(color: Colors.red),
                      )),
                    DataCell(Text(
                      '${total >= 0 ? "+" : "-"}${_formatYenDisplay(total.abs())}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: total >= 0
                            ? Colors.green.shade700
                            : Colors.red,
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'チップ補正',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            ..._players.map((p) {
              final chipDiff = _parseChipDiff(p.id);
              final borrowed = loanBalance[p.id] ?? 0;
              final net = chipNet[p.id] ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${p.name}: 差${_formatNum(chipDiff)} − 借${_formatNum(borrowed)} = 純${_formatNum(net)}',
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }),
            if (transfers.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                '精算',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...transfers.map((t) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(t,
                          style: const TextStyle(fontSize: 16)),
                    ),
                  )),
            ],
          ],
        ],
      ),
    );
  }

  String _formatNum(int n) => n >= 0 ? '+$n' : '$n';

  String _formatYenDisplay(int yen) {
    if (yen >= 10000) {
      final man = yen ~/ 10000;
      final rest = yen % 10000;
      if (rest == 0) return '$man万';
      return '$man万$rest';
    }
    return '$yen';
  }

  Future<void> _save() async {
    final db = ref.read(databaseProvider);

    final venueFeeTotal = _getVenueFeeTotal();
    await (db.update(db.gameDays)
          ..where((t) => t.id.equals(widget.gameDayId)))
        .write(GameDaysCompanion(venueFee: Value(venueFeeTotal)));

    await (db.delete(db.chipSettlements)
          ..where((t) => t.gameDayId.equals(widget.gameDayId)))
        .go();

    for (final p in _players) {
      final chipDiff = _parseChipDiff(p.id);
      await db.into(db.chipSettlements).insert(
            ChipSettlementsCompanion.insert(
              gameDayId: widget.gameDayId,
              playerId: p.id,
              chipDiff: chipDiff,
            ),
          );
    }

    setState(() => _saved = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存しました')),
      );
    }
  }
}
