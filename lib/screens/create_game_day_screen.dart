import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:majan_log_app/db/database.dart';
import 'package:majan_log_app/providers/database_provider.dart';
import 'package:majan_log_app/screens/game_day_detail_screen.dart';

class CreateGameDayScreen extends ConsumerStatefulWidget {
  const CreateGameDayScreen({super.key});

  @override
  ConsumerState<CreateGameDayScreen> createState() =>
      _CreateGameDayScreenState();
}

class _CreateGameDayScreenState
    extends ConsumerState<CreateGameDayScreen> {
  int _playerCount = 4;
  final Set<int> _selectedPlayerIds = {};
  DateTime _date = DateTime.now();
  final _scoreRateController = TextEditingController();
  final _chipRateController = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  Future<void> _loadDefaults() async {
    final db = ref.read(databaseProvider);
    final scoreRate = await db.getSetting('defaultScoreRate', 50);
    final chipRate = await db.getSetting('defaultChipRate', 100);
    _scoreRateController.text = '$scoreRate';
    _chipRateController.text = '$chipRate';
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _scoreRateController.dispose();
    _chipRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('新しい対戦日')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('新しい対戦日')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ListTile(
              title: const Text('日付'),
              subtitle: Text(
                  '${_date.year}/${_date.month}/${_date.day}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() => _date = picked);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('人数',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 3, label: Text('三麻')),
                ButtonSegment(value: 4, label: Text('四麻')),
              ],
              selected: {_playerCount},
              onSelectionChanged: (value) {
                setState(() {
                  _playerCount = value.first;
                  _selectedPlayerIds.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('レート',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _scoreRateController,
                    decoration: const InputDecoration(
                      labelText: '順位点',
                      border: OutlineInputBorder(),
                      suffixText: '円/点',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _chipRateController,
                    decoration: const InputDecoration(
                      labelText: 'チップ',
                      border: OutlineInputBorder(),
                      suffixText: '円/枚',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('メンバー選択 ($_playerCount人選んでください)',
                style:
                    const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<List<Player>>(
              stream: db.select(db.players).watch(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final players = snapshot.data!;
                if (players.isEmpty) {
                  return const Text(
                      'メンバーがいません。先にメンバーを追加してください。');
                }
                return Wrap(
                  spacing: 8,
                  children: players.map((p) {
                    final selected =
                        _selectedPlayerIds.contains(p.id);
                    return FilterChip(
                      label: Text(p.name),
                      selected: selected,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            if (_selectedPlayerIds.length <
                                _playerCount) {
                              _selectedPlayerIds.add(p.id);
                            }
                          } else {
                            _selectedPlayerIds.remove(p.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton:
          _selectedPlayerIds.length == _playerCount
              ? FloatingActionButton.extended(
                  onPressed: () => _create(db),
                  label: const Text('作成'),
                  icon: const Icon(Icons.check),
                )
              : null,
    );
  }

  Future<void> _create(AppDatabase db) async {
    final scoreRate =
        int.tryParse(_scoreRateController.text) ?? 50;
    final chipRate =
        int.tryParse(_chipRateController.text) ?? 100;

    final gameDayId = await db.into(db.gameDays).insert(
          GameDaysCompanion.insert(
            date: _date,
            playerCount: Value(_playerCount),
            scoreRate: Value(scoreRate),
            chipRate: Value(chipRate),
          ),
        );

    for (final playerId in _selectedPlayerIds) {
      await db.into(db.gameDayPlayers).insert(
            GameDayPlayersCompanion.insert(
              gameDayId: gameDayId,
              playerId: playerId,
            ),
          );
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              GameDayDetailScreen(gameDayId: gameDayId),
        ),
      );
    }
  }
}
