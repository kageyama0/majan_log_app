// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PlayersTable extends Players with TableInfo<$PlayersTable, Player> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(
    Insertable<Player> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Player map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Player(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }
}

class Player extends DataClass implements Insertable<Player> {
  final int id;
  final String name;
  final DateTime createdAt;
  const Player({required this.id, required this.name, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Player.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Player(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Player copyWith({int? id, String? name, DateTime? createdAt}) => Player(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  Player copyWithCompanion(PlayersCompanion data) {
    return Player(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Player(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Player &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class PlayersCompanion extends UpdateCompanion<Player> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PlayersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Player> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PlayersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return PlayersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GameDaysTable extends GameDays with TableInfo<$GameDaysTable, GameDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerCountMeta = const VerificationMeta(
    'playerCount',
  );
  @override
  late final GeneratedColumn<int> playerCount = GeneratedColumn<int>(
    'player_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _scoreRateMeta = const VerificationMeta(
    'scoreRate',
  );
  @override
  late final GeneratedColumn<int> scoreRate = GeneratedColumn<int>(
    'score_rate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(50),
  );
  static const VerificationMeta _chipRateMeta = const VerificationMeta(
    'chipRate',
  );
  @override
  late final GeneratedColumn<int> chipRate = GeneratedColumn<int>(
    'chip_rate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _venueFeeMeta = const VerificationMeta(
    'venueFee',
  );
  @override
  late final GeneratedColumn<int> venueFee = GeneratedColumn<int>(
    'venue_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    playerCount,
    scoreRate,
    chipRate,
    venueFee,
    memo,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('player_count')) {
      context.handle(
        _playerCountMeta,
        playerCount.isAcceptableOrUnknown(
          data['player_count']!,
          _playerCountMeta,
        ),
      );
    }
    if (data.containsKey('score_rate')) {
      context.handle(
        _scoreRateMeta,
        scoreRate.isAcceptableOrUnknown(data['score_rate']!, _scoreRateMeta),
      );
    }
    if (data.containsKey('chip_rate')) {
      context.handle(
        _chipRateMeta,
        chipRate.isAcceptableOrUnknown(data['chip_rate']!, _chipRateMeta),
      );
    }
    if (data.containsKey('venue_fee')) {
      context.handle(
        _venueFeeMeta,
        venueFee.isAcceptableOrUnknown(data['venue_fee']!, _venueFeeMeta),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameDay(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      playerCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_count'],
      )!,
      scoreRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_rate'],
      )!,
      chipRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chip_rate'],
      )!,
      venueFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}venue_fee'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GameDaysTable createAlias(String alias) {
    return $GameDaysTable(attachedDatabase, alias);
  }
}

class GameDay extends DataClass implements Insertable<GameDay> {
  final int id;
  final DateTime date;
  final int playerCount;
  final int scoreRate;
  final int chipRate;
  final int venueFee;
  final String? memo;
  final DateTime createdAt;
  const GameDay({
    required this.id,
    required this.date,
    required this.playerCount,
    required this.scoreRate,
    required this.chipRate,
    required this.venueFee,
    this.memo,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['player_count'] = Variable<int>(playerCount);
    map['score_rate'] = Variable<int>(scoreRate);
    map['chip_rate'] = Variable<int>(chipRate);
    map['venue_fee'] = Variable<int>(venueFee);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GameDaysCompanion toCompanion(bool nullToAbsent) {
    return GameDaysCompanion(
      id: Value(id),
      date: Value(date),
      playerCount: Value(playerCount),
      scoreRate: Value(scoreRate),
      chipRate: Value(chipRate),
      venueFee: Value(venueFee),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      createdAt: Value(createdAt),
    );
  }

  factory GameDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameDay(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      playerCount: serializer.fromJson<int>(json['playerCount']),
      scoreRate: serializer.fromJson<int>(json['scoreRate']),
      chipRate: serializer.fromJson<int>(json['chipRate']),
      venueFee: serializer.fromJson<int>(json['venueFee']),
      memo: serializer.fromJson<String?>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'playerCount': serializer.toJson<int>(playerCount),
      'scoreRate': serializer.toJson<int>(scoreRate),
      'chipRate': serializer.toJson<int>(chipRate),
      'venueFee': serializer.toJson<int>(venueFee),
      'memo': serializer.toJson<String?>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GameDay copyWith({
    int? id,
    DateTime? date,
    int? playerCount,
    int? scoreRate,
    int? chipRate,
    int? venueFee,
    Value<String?> memo = const Value.absent(),
    DateTime? createdAt,
  }) => GameDay(
    id: id ?? this.id,
    date: date ?? this.date,
    playerCount: playerCount ?? this.playerCount,
    scoreRate: scoreRate ?? this.scoreRate,
    chipRate: chipRate ?? this.chipRate,
    venueFee: venueFee ?? this.venueFee,
    memo: memo.present ? memo.value : this.memo,
    createdAt: createdAt ?? this.createdAt,
  );
  GameDay copyWithCompanion(GameDaysCompanion data) {
    return GameDay(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      playerCount: data.playerCount.present
          ? data.playerCount.value
          : this.playerCount,
      scoreRate: data.scoreRate.present ? data.scoreRate.value : this.scoreRate,
      chipRate: data.chipRate.present ? data.chipRate.value : this.chipRate,
      venueFee: data.venueFee.present ? data.venueFee.value : this.venueFee,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameDay(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('playerCount: $playerCount, ')
          ..write('scoreRate: $scoreRate, ')
          ..write('chipRate: $chipRate, ')
          ..write('venueFee: $venueFee, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    playerCount,
    scoreRate,
    chipRate,
    venueFee,
    memo,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameDay &&
          other.id == this.id &&
          other.date == this.date &&
          other.playerCount == this.playerCount &&
          other.scoreRate == this.scoreRate &&
          other.chipRate == this.chipRate &&
          other.venueFee == this.venueFee &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt);
}

class GameDaysCompanion extends UpdateCompanion<GameDay> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> playerCount;
  final Value<int> scoreRate;
  final Value<int> chipRate;
  final Value<int> venueFee;
  final Value<String?> memo;
  final Value<DateTime> createdAt;
  const GameDaysCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.playerCount = const Value.absent(),
    this.scoreRate = const Value.absent(),
    this.chipRate = const Value.absent(),
    this.venueFee = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GameDaysCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    this.playerCount = const Value.absent(),
    this.scoreRate = const Value.absent(),
    this.chipRate = const Value.absent(),
    this.venueFee = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : date = Value(date);
  static Insertable<GameDay> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? playerCount,
    Expression<int>? scoreRate,
    Expression<int>? chipRate,
    Expression<int>? venueFee,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (playerCount != null) 'player_count': playerCount,
      if (scoreRate != null) 'score_rate': scoreRate,
      if (chipRate != null) 'chip_rate': chipRate,
      if (venueFee != null) 'venue_fee': venueFee,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GameDaysCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? playerCount,
    Value<int>? scoreRate,
    Value<int>? chipRate,
    Value<int>? venueFee,
    Value<String?>? memo,
    Value<DateTime>? createdAt,
  }) {
    return GameDaysCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      playerCount: playerCount ?? this.playerCount,
      scoreRate: scoreRate ?? this.scoreRate,
      chipRate: chipRate ?? this.chipRate,
      venueFee: venueFee ?? this.venueFee,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (playerCount.present) {
      map['player_count'] = Variable<int>(playerCount.value);
    }
    if (scoreRate.present) {
      map['score_rate'] = Variable<int>(scoreRate.value);
    }
    if (chipRate.present) {
      map['chip_rate'] = Variable<int>(chipRate.value);
    }
    if (venueFee.present) {
      map['venue_fee'] = Variable<int>(venueFee.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameDaysCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('playerCount: $playerCount, ')
          ..write('scoreRate: $scoreRate, ')
          ..write('chipRate: $chipRate, ')
          ..write('venueFee: $venueFee, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GameDayPlayersTable extends GameDayPlayers
    with TableInfo<$GameDayPlayersTable, GameDayPlayer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameDayPlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameDayIdMeta = const VerificationMeta(
    'gameDayId',
  );
  @override
  late final GeneratedColumn<int> gameDayId = GeneratedColumn<int>(
    'game_day_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES game_days (id)',
    ),
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, gameDayId, playerId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_day_players';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameDayPlayer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_day_id')) {
      context.handle(
        _gameDayIdMeta,
        gameDayId.isAcceptableOrUnknown(data['game_day_id']!, _gameDayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameDayIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameDayPlayer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameDayPlayer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_day_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_id'],
      )!,
    );
  }

  @override
  $GameDayPlayersTable createAlias(String alias) {
    return $GameDayPlayersTable(attachedDatabase, alias);
  }
}

class GameDayPlayer extends DataClass implements Insertable<GameDayPlayer> {
  final int id;
  final int gameDayId;
  final int playerId;
  const GameDayPlayer({
    required this.id,
    required this.gameDayId,
    required this.playerId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_day_id'] = Variable<int>(gameDayId);
    map['player_id'] = Variable<int>(playerId);
    return map;
  }

  GameDayPlayersCompanion toCompanion(bool nullToAbsent) {
    return GameDayPlayersCompanion(
      id: Value(id),
      gameDayId: Value(gameDayId),
      playerId: Value(playerId),
    );
  }

  factory GameDayPlayer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameDayPlayer(
      id: serializer.fromJson<int>(json['id']),
      gameDayId: serializer.fromJson<int>(json['gameDayId']),
      playerId: serializer.fromJson<int>(json['playerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameDayId': serializer.toJson<int>(gameDayId),
      'playerId': serializer.toJson<int>(playerId),
    };
  }

  GameDayPlayer copyWith({int? id, int? gameDayId, int? playerId}) =>
      GameDayPlayer(
        id: id ?? this.id,
        gameDayId: gameDayId ?? this.gameDayId,
        playerId: playerId ?? this.playerId,
      );
  GameDayPlayer copyWithCompanion(GameDayPlayersCompanion data) {
    return GameDayPlayer(
      id: data.id.present ? data.id.value : this.id,
      gameDayId: data.gameDayId.present ? data.gameDayId.value : this.gameDayId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameDayPlayer(')
          ..write('id: $id, ')
          ..write('gameDayId: $gameDayId, ')
          ..write('playerId: $playerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, gameDayId, playerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameDayPlayer &&
          other.id == this.id &&
          other.gameDayId == this.gameDayId &&
          other.playerId == this.playerId);
}

class GameDayPlayersCompanion extends UpdateCompanion<GameDayPlayer> {
  final Value<int> id;
  final Value<int> gameDayId;
  final Value<int> playerId;
  const GameDayPlayersCompanion({
    this.id = const Value.absent(),
    this.gameDayId = const Value.absent(),
    this.playerId = const Value.absent(),
  });
  GameDayPlayersCompanion.insert({
    this.id = const Value.absent(),
    required int gameDayId,
    required int playerId,
  }) : gameDayId = Value(gameDayId),
       playerId = Value(playerId);
  static Insertable<GameDayPlayer> custom({
    Expression<int>? id,
    Expression<int>? gameDayId,
    Expression<int>? playerId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameDayId != null) 'game_day_id': gameDayId,
      if (playerId != null) 'player_id': playerId,
    });
  }

  GameDayPlayersCompanion copyWith({
    Value<int>? id,
    Value<int>? gameDayId,
    Value<int>? playerId,
  }) {
    return GameDayPlayersCompanion(
      id: id ?? this.id,
      gameDayId: gameDayId ?? this.gameDayId,
      playerId: playerId ?? this.playerId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameDayId.present) {
      map['game_day_id'] = Variable<int>(gameDayId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameDayPlayersCompanion(')
          ..write('id: $id, ')
          ..write('gameDayId: $gameDayId, ')
          ..write('playerId: $playerId')
          ..write(')'))
        .toString();
  }
}

class $GamesTable extends Games with TableInfo<$GamesTable, Game> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameDayIdMeta = const VerificationMeta(
    'gameDayId',
  );
  @override
  late final GeneratedColumn<int> gameDayId = GeneratedColumn<int>(
    'game_day_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES game_days (id)',
    ),
  );
  static const VerificationMeta _gameNumberMeta = const VerificationMeta(
    'gameNumber',
  );
  @override
  late final GeneratedColumn<int> gameNumber = GeneratedColumn<int>(
    'game_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, gameDayId, gameNumber, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(
    Insertable<Game> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_day_id')) {
      context.handle(
        _gameDayIdMeta,
        gameDayId.isAcceptableOrUnknown(data['game_day_id']!, _gameDayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameDayIdMeta);
    }
    if (data.containsKey('game_number')) {
      context.handle(
        _gameNumberMeta,
        gameNumber.isAcceptableOrUnknown(data['game_number']!, _gameNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_gameNumberMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Game map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Game(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_day_id'],
      )!,
      gameNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_number'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }
}

class Game extends DataClass implements Insertable<Game> {
  final int id;
  final int gameDayId;
  final int gameNumber;
  final DateTime createdAt;
  const Game({
    required this.id,
    required this.gameDayId,
    required this.gameNumber,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_day_id'] = Variable<int>(gameDayId);
    map['game_number'] = Variable<int>(gameNumber);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      gameDayId: Value(gameDayId),
      gameNumber: Value(gameNumber),
      createdAt: Value(createdAt),
    );
  }

  factory Game.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Game(
      id: serializer.fromJson<int>(json['id']),
      gameDayId: serializer.fromJson<int>(json['gameDayId']),
      gameNumber: serializer.fromJson<int>(json['gameNumber']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameDayId': serializer.toJson<int>(gameDayId),
      'gameNumber': serializer.toJson<int>(gameNumber),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Game copyWith({
    int? id,
    int? gameDayId,
    int? gameNumber,
    DateTime? createdAt,
  }) => Game(
    id: id ?? this.id,
    gameDayId: gameDayId ?? this.gameDayId,
    gameNumber: gameNumber ?? this.gameNumber,
    createdAt: createdAt ?? this.createdAt,
  );
  Game copyWithCompanion(GamesCompanion data) {
    return Game(
      id: data.id.present ? data.id.value : this.id,
      gameDayId: data.gameDayId.present ? data.gameDayId.value : this.gameDayId,
      gameNumber: data.gameNumber.present
          ? data.gameNumber.value
          : this.gameNumber,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Game(')
          ..write('id: $id, ')
          ..write('gameDayId: $gameDayId, ')
          ..write('gameNumber: $gameNumber, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, gameDayId, gameNumber, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Game &&
          other.id == this.id &&
          other.gameDayId == this.gameDayId &&
          other.gameNumber == this.gameNumber &&
          other.createdAt == this.createdAt);
}

class GamesCompanion extends UpdateCompanion<Game> {
  final Value<int> id;
  final Value<int> gameDayId;
  final Value<int> gameNumber;
  final Value<DateTime> createdAt;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.gameDayId = const Value.absent(),
    this.gameNumber = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GamesCompanion.insert({
    this.id = const Value.absent(),
    required int gameDayId,
    required int gameNumber,
    this.createdAt = const Value.absent(),
  }) : gameDayId = Value(gameDayId),
       gameNumber = Value(gameNumber);
  static Insertable<Game> custom({
    Expression<int>? id,
    Expression<int>? gameDayId,
    Expression<int>? gameNumber,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameDayId != null) 'game_day_id': gameDayId,
      if (gameNumber != null) 'game_number': gameNumber,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GamesCompanion copyWith({
    Value<int>? id,
    Value<int>? gameDayId,
    Value<int>? gameNumber,
    Value<DateTime>? createdAt,
  }) {
    return GamesCompanion(
      id: id ?? this.id,
      gameDayId: gameDayId ?? this.gameDayId,
      gameNumber: gameNumber ?? this.gameNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameDayId.present) {
      map['game_day_id'] = Variable<int>(gameDayId.value);
    }
    if (gameNumber.present) {
      map['game_number'] = Variable<int>(gameNumber.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('gameDayId: $gameDayId, ')
          ..write('gameNumber: $gameNumber, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GameScoresTable extends GameScores
    with TableInfo<$GameScoresTable, GameScore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameScoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id)',
    ),
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, gameId, playerId, score];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_scores';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameScore> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameScore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameScore(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_id'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
    );
  }

  @override
  $GameScoresTable createAlias(String alias) {
    return $GameScoresTable(attachedDatabase, alias);
  }
}

class GameScore extends DataClass implements Insertable<GameScore> {
  final int id;
  final int gameId;
  final int playerId;
  final int score;
  const GameScore({
    required this.id,
    required this.gameId,
    required this.playerId,
    required this.score,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_id'] = Variable<int>(gameId);
    map['player_id'] = Variable<int>(playerId);
    map['score'] = Variable<int>(score);
    return map;
  }

  GameScoresCompanion toCompanion(bool nullToAbsent) {
    return GameScoresCompanion(
      id: Value(id),
      gameId: Value(gameId),
      playerId: Value(playerId),
      score: Value(score),
    );
  }

  factory GameScore.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameScore(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<int>(json['gameId']),
      playerId: serializer.fromJson<int>(json['playerId']),
      score: serializer.fromJson<int>(json['score']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameId': serializer.toJson<int>(gameId),
      'playerId': serializer.toJson<int>(playerId),
      'score': serializer.toJson<int>(score),
    };
  }

  GameScore copyWith({int? id, int? gameId, int? playerId, int? score}) =>
      GameScore(
        id: id ?? this.id,
        gameId: gameId ?? this.gameId,
        playerId: playerId ?? this.playerId,
        score: score ?? this.score,
      );
  GameScore copyWithCompanion(GameScoresCompanion data) {
    return GameScore(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      score: data.score.present ? data.score.value : this.score,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameScore(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('playerId: $playerId, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, gameId, playerId, score);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameScore &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.playerId == this.playerId &&
          other.score == this.score);
}

class GameScoresCompanion extends UpdateCompanion<GameScore> {
  final Value<int> id;
  final Value<int> gameId;
  final Value<int> playerId;
  final Value<int> score;
  const GameScoresCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.score = const Value.absent(),
  });
  GameScoresCompanion.insert({
    this.id = const Value.absent(),
    required int gameId,
    required int playerId,
    required int score,
  }) : gameId = Value(gameId),
       playerId = Value(playerId),
       score = Value(score);
  static Insertable<GameScore> custom({
    Expression<int>? id,
    Expression<int>? gameId,
    Expression<int>? playerId,
    Expression<int>? score,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (playerId != null) 'player_id': playerId,
      if (score != null) 'score': score,
    });
  }

  GameScoresCompanion copyWith({
    Value<int>? id,
    Value<int>? gameId,
    Value<int>? playerId,
    Value<int>? score,
  }) {
    return GameScoresCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      score: score ?? this.score,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameScoresCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('playerId: $playerId, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }
}

class $ChipLoansTable extends ChipLoans
    with TableInfo<$ChipLoansTable, ChipLoan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChipLoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameDayIdMeta = const VerificationMeta(
    'gameDayId',
  );
  @override
  late final GeneratedColumn<int> gameDayId = GeneratedColumn<int>(
    'game_day_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES game_days (id)',
    ),
  );
  static const VerificationMeta _lenderIdMeta = const VerificationMeta(
    'lenderId',
  );
  @override
  late final GeneratedColumn<int> lenderId = GeneratedColumn<int>(
    'lender_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _borrowerIdMeta = const VerificationMeta(
    'borrowerId',
  );
  @override
  late final GeneratedColumn<int> borrowerId = GeneratedColumn<int>(
    'borrower_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameDayId,
    lenderId,
    borrowerId,
    amount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chip_loans';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChipLoan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_day_id')) {
      context.handle(
        _gameDayIdMeta,
        gameDayId.isAcceptableOrUnknown(data['game_day_id']!, _gameDayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameDayIdMeta);
    }
    if (data.containsKey('lender_id')) {
      context.handle(
        _lenderIdMeta,
        lenderId.isAcceptableOrUnknown(data['lender_id']!, _lenderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lenderIdMeta);
    }
    if (data.containsKey('borrower_id')) {
      context.handle(
        _borrowerIdMeta,
        borrowerId.isAcceptableOrUnknown(data['borrower_id']!, _borrowerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_borrowerIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChipLoan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChipLoan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_day_id'],
      )!,
      lenderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lender_id'],
      )!,
      borrowerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}borrower_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChipLoansTable createAlias(String alias) {
    return $ChipLoansTable(attachedDatabase, alias);
  }
}

class ChipLoan extends DataClass implements Insertable<ChipLoan> {
  final int id;
  final int gameDayId;
  final int lenderId;
  final int borrowerId;
  final int amount;
  final DateTime createdAt;
  const ChipLoan({
    required this.id,
    required this.gameDayId,
    required this.lenderId,
    required this.borrowerId,
    required this.amount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_day_id'] = Variable<int>(gameDayId);
    map['lender_id'] = Variable<int>(lenderId);
    map['borrower_id'] = Variable<int>(borrowerId);
    map['amount'] = Variable<int>(amount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChipLoansCompanion toCompanion(bool nullToAbsent) {
    return ChipLoansCompanion(
      id: Value(id),
      gameDayId: Value(gameDayId),
      lenderId: Value(lenderId),
      borrowerId: Value(borrowerId),
      amount: Value(amount),
      createdAt: Value(createdAt),
    );
  }

  factory ChipLoan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChipLoan(
      id: serializer.fromJson<int>(json['id']),
      gameDayId: serializer.fromJson<int>(json['gameDayId']),
      lenderId: serializer.fromJson<int>(json['lenderId']),
      borrowerId: serializer.fromJson<int>(json['borrowerId']),
      amount: serializer.fromJson<int>(json['amount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameDayId': serializer.toJson<int>(gameDayId),
      'lenderId': serializer.toJson<int>(lenderId),
      'borrowerId': serializer.toJson<int>(borrowerId),
      'amount': serializer.toJson<int>(amount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChipLoan copyWith({
    int? id,
    int? gameDayId,
    int? lenderId,
    int? borrowerId,
    int? amount,
    DateTime? createdAt,
  }) => ChipLoan(
    id: id ?? this.id,
    gameDayId: gameDayId ?? this.gameDayId,
    lenderId: lenderId ?? this.lenderId,
    borrowerId: borrowerId ?? this.borrowerId,
    amount: amount ?? this.amount,
    createdAt: createdAt ?? this.createdAt,
  );
  ChipLoan copyWithCompanion(ChipLoansCompanion data) {
    return ChipLoan(
      id: data.id.present ? data.id.value : this.id,
      gameDayId: data.gameDayId.present ? data.gameDayId.value : this.gameDayId,
      lenderId: data.lenderId.present ? data.lenderId.value : this.lenderId,
      borrowerId: data.borrowerId.present
          ? data.borrowerId.value
          : this.borrowerId,
      amount: data.amount.present ? data.amount.value : this.amount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChipLoan(')
          ..write('id: $id, ')
          ..write('gameDayId: $gameDayId, ')
          ..write('lenderId: $lenderId, ')
          ..write('borrowerId: $borrowerId, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, gameDayId, lenderId, borrowerId, amount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChipLoan &&
          other.id == this.id &&
          other.gameDayId == this.gameDayId &&
          other.lenderId == this.lenderId &&
          other.borrowerId == this.borrowerId &&
          other.amount == this.amount &&
          other.createdAt == this.createdAt);
}

class ChipLoansCompanion extends UpdateCompanion<ChipLoan> {
  final Value<int> id;
  final Value<int> gameDayId;
  final Value<int> lenderId;
  final Value<int> borrowerId;
  final Value<int> amount;
  final Value<DateTime> createdAt;
  const ChipLoansCompanion({
    this.id = const Value.absent(),
    this.gameDayId = const Value.absent(),
    this.lenderId = const Value.absent(),
    this.borrowerId = const Value.absent(),
    this.amount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChipLoansCompanion.insert({
    this.id = const Value.absent(),
    required int gameDayId,
    required int lenderId,
    required int borrowerId,
    required int amount,
    this.createdAt = const Value.absent(),
  }) : gameDayId = Value(gameDayId),
       lenderId = Value(lenderId),
       borrowerId = Value(borrowerId),
       amount = Value(amount);
  static Insertable<ChipLoan> custom({
    Expression<int>? id,
    Expression<int>? gameDayId,
    Expression<int>? lenderId,
    Expression<int>? borrowerId,
    Expression<int>? amount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameDayId != null) 'game_day_id': gameDayId,
      if (lenderId != null) 'lender_id': lenderId,
      if (borrowerId != null) 'borrower_id': borrowerId,
      if (amount != null) 'amount': amount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChipLoansCompanion copyWith({
    Value<int>? id,
    Value<int>? gameDayId,
    Value<int>? lenderId,
    Value<int>? borrowerId,
    Value<int>? amount,
    Value<DateTime>? createdAt,
  }) {
    return ChipLoansCompanion(
      id: id ?? this.id,
      gameDayId: gameDayId ?? this.gameDayId,
      lenderId: lenderId ?? this.lenderId,
      borrowerId: borrowerId ?? this.borrowerId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameDayId.present) {
      map['game_day_id'] = Variable<int>(gameDayId.value);
    }
    if (lenderId.present) {
      map['lender_id'] = Variable<int>(lenderId.value);
    }
    if (borrowerId.present) {
      map['borrower_id'] = Variable<int>(borrowerId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChipLoansCompanion(')
          ..write('id: $id, ')
          ..write('gameDayId: $gameDayId, ')
          ..write('lenderId: $lenderId, ')
          ..write('borrowerId: $borrowerId, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ChipSettlementsTable extends ChipSettlements
    with TableInfo<$ChipSettlementsTable, ChipSettlement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChipSettlementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameDayIdMeta = const VerificationMeta(
    'gameDayId',
  );
  @override
  late final GeneratedColumn<int> gameDayId = GeneratedColumn<int>(
    'game_day_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES game_days (id)',
    ),
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _chipDiffMeta = const VerificationMeta(
    'chipDiff',
  );
  @override
  late final GeneratedColumn<int> chipDiff = GeneratedColumn<int>(
    'chip_diff',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, gameDayId, playerId, chipDiff];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chip_settlements';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChipSettlement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_day_id')) {
      context.handle(
        _gameDayIdMeta,
        gameDayId.isAcceptableOrUnknown(data['game_day_id']!, _gameDayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameDayIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('chip_diff')) {
      context.handle(
        _chipDiffMeta,
        chipDiff.isAcceptableOrUnknown(data['chip_diff']!, _chipDiffMeta),
      );
    } else if (isInserting) {
      context.missing(_chipDiffMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChipSettlement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChipSettlement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_day_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_id'],
      )!,
      chipDiff: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chip_diff'],
      )!,
    );
  }

  @override
  $ChipSettlementsTable createAlias(String alias) {
    return $ChipSettlementsTable(attachedDatabase, alias);
  }
}

class ChipSettlement extends DataClass implements Insertable<ChipSettlement> {
  final int id;
  final int gameDayId;
  final int playerId;
  final int chipDiff;
  const ChipSettlement({
    required this.id,
    required this.gameDayId,
    required this.playerId,
    required this.chipDiff,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_day_id'] = Variable<int>(gameDayId);
    map['player_id'] = Variable<int>(playerId);
    map['chip_diff'] = Variable<int>(chipDiff);
    return map;
  }

  ChipSettlementsCompanion toCompanion(bool nullToAbsent) {
    return ChipSettlementsCompanion(
      id: Value(id),
      gameDayId: Value(gameDayId),
      playerId: Value(playerId),
      chipDiff: Value(chipDiff),
    );
  }

  factory ChipSettlement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChipSettlement(
      id: serializer.fromJson<int>(json['id']),
      gameDayId: serializer.fromJson<int>(json['gameDayId']),
      playerId: serializer.fromJson<int>(json['playerId']),
      chipDiff: serializer.fromJson<int>(json['chipDiff']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameDayId': serializer.toJson<int>(gameDayId),
      'playerId': serializer.toJson<int>(playerId),
      'chipDiff': serializer.toJson<int>(chipDiff),
    };
  }

  ChipSettlement copyWith({
    int? id,
    int? gameDayId,
    int? playerId,
    int? chipDiff,
  }) => ChipSettlement(
    id: id ?? this.id,
    gameDayId: gameDayId ?? this.gameDayId,
    playerId: playerId ?? this.playerId,
    chipDiff: chipDiff ?? this.chipDiff,
  );
  ChipSettlement copyWithCompanion(ChipSettlementsCompanion data) {
    return ChipSettlement(
      id: data.id.present ? data.id.value : this.id,
      gameDayId: data.gameDayId.present ? data.gameDayId.value : this.gameDayId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      chipDiff: data.chipDiff.present ? data.chipDiff.value : this.chipDiff,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChipSettlement(')
          ..write('id: $id, ')
          ..write('gameDayId: $gameDayId, ')
          ..write('playerId: $playerId, ')
          ..write('chipDiff: $chipDiff')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, gameDayId, playerId, chipDiff);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChipSettlement &&
          other.id == this.id &&
          other.gameDayId == this.gameDayId &&
          other.playerId == this.playerId &&
          other.chipDiff == this.chipDiff);
}

class ChipSettlementsCompanion extends UpdateCompanion<ChipSettlement> {
  final Value<int> id;
  final Value<int> gameDayId;
  final Value<int> playerId;
  final Value<int> chipDiff;
  const ChipSettlementsCompanion({
    this.id = const Value.absent(),
    this.gameDayId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.chipDiff = const Value.absent(),
  });
  ChipSettlementsCompanion.insert({
    this.id = const Value.absent(),
    required int gameDayId,
    required int playerId,
    required int chipDiff,
  }) : gameDayId = Value(gameDayId),
       playerId = Value(playerId),
       chipDiff = Value(chipDiff);
  static Insertable<ChipSettlement> custom({
    Expression<int>? id,
    Expression<int>? gameDayId,
    Expression<int>? playerId,
    Expression<int>? chipDiff,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameDayId != null) 'game_day_id': gameDayId,
      if (playerId != null) 'player_id': playerId,
      if (chipDiff != null) 'chip_diff': chipDiff,
    });
  }

  ChipSettlementsCompanion copyWith({
    Value<int>? id,
    Value<int>? gameDayId,
    Value<int>? playerId,
    Value<int>? chipDiff,
  }) {
    return ChipSettlementsCompanion(
      id: id ?? this.id,
      gameDayId: gameDayId ?? this.gameDayId,
      playerId: playerId ?? this.playerId,
      chipDiff: chipDiff ?? this.chipDiff,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameDayId.present) {
      map['game_day_id'] = Variable<int>(gameDayId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (chipDiff.present) {
      map['chip_diff'] = Variable<int>(chipDiff.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChipSettlementsCompanion(')
          ..write('id: $id, ')
          ..write('gameDayId: $gameDayId, ')
          ..write('playerId: $playerId, ')
          ..write('chipDiff: $chipDiff')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final int value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<int>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<int>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<int>(value),
    };
  }

  AppSetting copyWith({String? key, int? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<int> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required int value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<int>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<int>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $GameDaysTable gameDays = $GameDaysTable(this);
  late final $GameDayPlayersTable gameDayPlayers = $GameDayPlayersTable(this);
  late final $GamesTable games = $GamesTable(this);
  late final $GameScoresTable gameScores = $GameScoresTable(this);
  late final $ChipLoansTable chipLoans = $ChipLoansTable(this);
  late final $ChipSettlementsTable chipSettlements = $ChipSettlementsTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    players,
    gameDays,
    gameDayPlayers,
    games,
    gameScores,
    chipLoans,
    chipSettlements,
    appSettings,
  ];
}

typedef $$PlayersTableCreateCompanionBuilder =
    PlayersCompanion Function({
      Value<int> id,
      required String name,
      Value<DateTime> createdAt,
    });
typedef $$PlayersTableUpdateCompanionBuilder =
    PlayersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
    });

final class $$PlayersTableReferences
    extends BaseReferences<_$AppDatabase, $PlayersTable, Player> {
  $$PlayersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GameDayPlayersTable, List<GameDayPlayer>>
  _gameDayPlayersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameDayPlayers,
    aliasName: $_aliasNameGenerator(db.players.id, db.gameDayPlayers.playerId),
  );

  $$GameDayPlayersTableProcessedTableManager get gameDayPlayersRefs {
    final manager = $$GameDayPlayersTableTableManager(
      $_db,
      $_db.gameDayPlayers,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameDayPlayersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GameScoresTable, List<GameScore>>
  _gameScoresRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameScores,
    aliasName: $_aliasNameGenerator(db.players.id, db.gameScores.playerId),
  );

  $$GameScoresTableProcessedTableManager get gameScoresRefs {
    final manager = $$GameScoresTableTableManager(
      $_db,
      $_db.gameScores,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameScoresRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChipSettlementsTable, List<ChipSettlement>>
  _chipSettlementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chipSettlements,
    aliasName: $_aliasNameGenerator(db.players.id, db.chipSettlements.playerId),
  );

  $$ChipSettlementsTableProcessedTableManager get chipSettlementsRefs {
    final manager = $$ChipSettlementsTableTableManager(
      $_db,
      $_db.chipSettlements,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _chipSettlementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gameDayPlayersRefs(
    Expression<bool> Function($$GameDayPlayersTableFilterComposer f) f,
  ) {
    final $$GameDayPlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameDayPlayers,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameDayPlayersTableFilterComposer(
            $db: $db,
            $table: $db.gameDayPlayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gameScoresRefs(
    Expression<bool> Function($$GameScoresTableFilterComposer f) f,
  ) {
    final $$GameScoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameScores,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameScoresTableFilterComposer(
            $db: $db,
            $table: $db.gameScores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chipSettlementsRefs(
    Expression<bool> Function($$ChipSettlementsTableFilterComposer f) f,
  ) {
    final $$ChipSettlementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chipSettlements,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChipSettlementsTableFilterComposer(
            $db: $db,
            $table: $db.chipSettlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> gameDayPlayersRefs<T extends Object>(
    Expression<T> Function($$GameDayPlayersTableAnnotationComposer a) f,
  ) {
    final $$GameDayPlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameDayPlayers,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameDayPlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.gameDayPlayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gameScoresRefs<T extends Object>(
    Expression<T> Function($$GameScoresTableAnnotationComposer a) f,
  ) {
    final $$GameScoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameScores,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameScoresTableAnnotationComposer(
            $db: $db,
            $table: $db.gameScores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chipSettlementsRefs<T extends Object>(
    Expression<T> Function($$ChipSettlementsTableAnnotationComposer a) f,
  ) {
    final $$ChipSettlementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chipSettlements,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChipSettlementsTableAnnotationComposer(
            $db: $db,
            $table: $db.chipSettlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayersTable,
          Player,
          $$PlayersTableFilterComposer,
          $$PlayersTableOrderingComposer,
          $$PlayersTableAnnotationComposer,
          $$PlayersTableCreateCompanionBuilder,
          $$PlayersTableUpdateCompanionBuilder,
          (Player, $$PlayersTableReferences),
          Player,
          PrefetchHooks Function({
            bool gameDayPlayersRefs,
            bool gameScoresRefs,
            bool chipSettlementsRefs,
          })
        > {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PlayersCompanion(id: id, name: name, createdAt: createdAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => PlayersCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlayersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gameDayPlayersRefs = false,
                gameScoresRefs = false,
                chipSettlementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gameDayPlayersRefs) db.gameDayPlayers,
                    if (gameScoresRefs) db.gameScores,
                    if (chipSettlementsRefs) db.chipSettlements,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gameDayPlayersRefs)
                        await $_getPrefetchedData<
                          Player,
                          $PlayersTable,
                          GameDayPlayer
                        >(
                          currentTable: table,
                          referencedTable: $$PlayersTableReferences
                              ._gameDayPlayersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayersTableReferences(
                                db,
                                table,
                                p0,
                              ).gameDayPlayersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (gameScoresRefs)
                        await $_getPrefetchedData<
                          Player,
                          $PlayersTable,
                          GameScore
                        >(
                          currentTable: table,
                          referencedTable: $$PlayersTableReferences
                              ._gameScoresRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayersTableReferences(
                                db,
                                table,
                                p0,
                              ).gameScoresRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chipSettlementsRefs)
                        await $_getPrefetchedData<
                          Player,
                          $PlayersTable,
                          ChipSettlement
                        >(
                          currentTable: table,
                          referencedTable: $$PlayersTableReferences
                              ._chipSettlementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayersTableReferences(
                                db,
                                table,
                                p0,
                              ).chipSettlementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayersTable,
      Player,
      $$PlayersTableFilterComposer,
      $$PlayersTableOrderingComposer,
      $$PlayersTableAnnotationComposer,
      $$PlayersTableCreateCompanionBuilder,
      $$PlayersTableUpdateCompanionBuilder,
      (Player, $$PlayersTableReferences),
      Player,
      PrefetchHooks Function({
        bool gameDayPlayersRefs,
        bool gameScoresRefs,
        bool chipSettlementsRefs,
      })
    >;
typedef $$GameDaysTableCreateCompanionBuilder =
    GameDaysCompanion Function({
      Value<int> id,
      required DateTime date,
      Value<int> playerCount,
      Value<int> scoreRate,
      Value<int> chipRate,
      Value<int> venueFee,
      Value<String?> memo,
      Value<DateTime> createdAt,
    });
typedef $$GameDaysTableUpdateCompanionBuilder =
    GameDaysCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> playerCount,
      Value<int> scoreRate,
      Value<int> chipRate,
      Value<int> venueFee,
      Value<String?> memo,
      Value<DateTime> createdAt,
    });

final class $$GameDaysTableReferences
    extends BaseReferences<_$AppDatabase, $GameDaysTable, GameDay> {
  $$GameDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GameDayPlayersTable, List<GameDayPlayer>>
  _gameDayPlayersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameDayPlayers,
    aliasName: $_aliasNameGenerator(
      db.gameDays.id,
      db.gameDayPlayers.gameDayId,
    ),
  );

  $$GameDayPlayersTableProcessedTableManager get gameDayPlayersRefs {
    final manager = $$GameDayPlayersTableTableManager(
      $_db,
      $_db.gameDayPlayers,
    ).filter((f) => f.gameDayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameDayPlayersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GamesTable, List<Game>> _gamesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.games,
    aliasName: $_aliasNameGenerator(db.gameDays.id, db.games.gameDayId),
  );

  $$GamesTableProcessedTableManager get gamesRefs {
    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.gameDayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gamesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChipLoansTable, List<ChipLoan>>
  _chipLoansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chipLoans,
    aliasName: $_aliasNameGenerator(db.gameDays.id, db.chipLoans.gameDayId),
  );

  $$ChipLoansTableProcessedTableManager get chipLoansRefs {
    final manager = $$ChipLoansTableTableManager(
      $_db,
      $_db.chipLoans,
    ).filter((f) => f.gameDayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chipLoansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChipSettlementsTable, List<ChipSettlement>>
  _chipSettlementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chipSettlements,
    aliasName: $_aliasNameGenerator(
      db.gameDays.id,
      db.chipSettlements.gameDayId,
    ),
  );

  $$ChipSettlementsTableProcessedTableManager get chipSettlementsRefs {
    final manager = $$ChipSettlementsTableTableManager(
      $_db,
      $_db.chipSettlements,
    ).filter((f) => f.gameDayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _chipSettlementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GameDaysTableFilterComposer
    extends Composer<_$AppDatabase, $GameDaysTable> {
  $$GameDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playerCount => $composableBuilder(
    column: $table.playerCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scoreRate => $composableBuilder(
    column: $table.scoreRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chipRate => $composableBuilder(
    column: $table.chipRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get venueFee => $composableBuilder(
    column: $table.venueFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gameDayPlayersRefs(
    Expression<bool> Function($$GameDayPlayersTableFilterComposer f) f,
  ) {
    final $$GameDayPlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameDayPlayers,
      getReferencedColumn: (t) => t.gameDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameDayPlayersTableFilterComposer(
            $db: $db,
            $table: $db.gameDayPlayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gamesRefs(
    Expression<bool> Function($$GamesTableFilterComposer f) f,
  ) {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.gameDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chipLoansRefs(
    Expression<bool> Function($$ChipLoansTableFilterComposer f) f,
  ) {
    final $$ChipLoansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chipLoans,
      getReferencedColumn: (t) => t.gameDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChipLoansTableFilterComposer(
            $db: $db,
            $table: $db.chipLoans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chipSettlementsRefs(
    Expression<bool> Function($$ChipSettlementsTableFilterComposer f) f,
  ) {
    final $$ChipSettlementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chipSettlements,
      getReferencedColumn: (t) => t.gameDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChipSettlementsTableFilterComposer(
            $db: $db,
            $table: $db.chipSettlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GameDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $GameDaysTable> {
  $$GameDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playerCount => $composableBuilder(
    column: $table.playerCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scoreRate => $composableBuilder(
    column: $table.scoreRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chipRate => $composableBuilder(
    column: $table.chipRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get venueFee => $composableBuilder(
    column: $table.venueFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameDaysTable> {
  $$GameDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get playerCount => $composableBuilder(
    column: $table.playerCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scoreRate =>
      $composableBuilder(column: $table.scoreRate, builder: (column) => column);

  GeneratedColumn<int> get chipRate =>
      $composableBuilder(column: $table.chipRate, builder: (column) => column);

  GeneratedColumn<int> get venueFee =>
      $composableBuilder(column: $table.venueFee, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> gameDayPlayersRefs<T extends Object>(
    Expression<T> Function($$GameDayPlayersTableAnnotationComposer a) f,
  ) {
    final $$GameDayPlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameDayPlayers,
      getReferencedColumn: (t) => t.gameDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameDayPlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.gameDayPlayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gamesRefs<T extends Object>(
    Expression<T> Function($$GamesTableAnnotationComposer a) f,
  ) {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.gameDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chipLoansRefs<T extends Object>(
    Expression<T> Function($$ChipLoansTableAnnotationComposer a) f,
  ) {
    final $$ChipLoansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chipLoans,
      getReferencedColumn: (t) => t.gameDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChipLoansTableAnnotationComposer(
            $db: $db,
            $table: $db.chipLoans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chipSettlementsRefs<T extends Object>(
    Expression<T> Function($$ChipSettlementsTableAnnotationComposer a) f,
  ) {
    final $$ChipSettlementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chipSettlements,
      getReferencedColumn: (t) => t.gameDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChipSettlementsTableAnnotationComposer(
            $db: $db,
            $table: $db.chipSettlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GameDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameDaysTable,
          GameDay,
          $$GameDaysTableFilterComposer,
          $$GameDaysTableOrderingComposer,
          $$GameDaysTableAnnotationComposer,
          $$GameDaysTableCreateCompanionBuilder,
          $$GameDaysTableUpdateCompanionBuilder,
          (GameDay, $$GameDaysTableReferences),
          GameDay,
          PrefetchHooks Function({
            bool gameDayPlayersRefs,
            bool gamesRefs,
            bool chipLoansRefs,
            bool chipSettlementsRefs,
          })
        > {
  $$GameDaysTableTableManager(_$AppDatabase db, $GameDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> playerCount = const Value.absent(),
                Value<int> scoreRate = const Value.absent(),
                Value<int> chipRate = const Value.absent(),
                Value<int> venueFee = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GameDaysCompanion(
                id: id,
                date: date,
                playerCount: playerCount,
                scoreRate: scoreRate,
                chipRate: chipRate,
                venueFee: venueFee,
                memo: memo,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                Value<int> playerCount = const Value.absent(),
                Value<int> scoreRate = const Value.absent(),
                Value<int> chipRate = const Value.absent(),
                Value<int> venueFee = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GameDaysCompanion.insert(
                id: id,
                date: date,
                playerCount: playerCount,
                scoreRate: scoreRate,
                chipRate: chipRate,
                venueFee: venueFee,
                memo: memo,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GameDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gameDayPlayersRefs = false,
                gamesRefs = false,
                chipLoansRefs = false,
                chipSettlementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gameDayPlayersRefs) db.gameDayPlayers,
                    if (gamesRefs) db.games,
                    if (chipLoansRefs) db.chipLoans,
                    if (chipSettlementsRefs) db.chipSettlements,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gameDayPlayersRefs)
                        await $_getPrefetchedData<
                          GameDay,
                          $GameDaysTable,
                          GameDayPlayer
                        >(
                          currentTable: table,
                          referencedTable: $$GameDaysTableReferences
                              ._gameDayPlayersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GameDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).gameDayPlayersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameDayId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (gamesRefs)
                        await $_getPrefetchedData<
                          GameDay,
                          $GameDaysTable,
                          Game
                        >(
                          currentTable: table,
                          referencedTable: $$GameDaysTableReferences
                              ._gamesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GameDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).gamesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameDayId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chipLoansRefs)
                        await $_getPrefetchedData<
                          GameDay,
                          $GameDaysTable,
                          ChipLoan
                        >(
                          currentTable: table,
                          referencedTable: $$GameDaysTableReferences
                              ._chipLoansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GameDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).chipLoansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameDayId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chipSettlementsRefs)
                        await $_getPrefetchedData<
                          GameDay,
                          $GameDaysTable,
                          ChipSettlement
                        >(
                          currentTable: table,
                          referencedTable: $$GameDaysTableReferences
                              ._chipSettlementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GameDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).chipSettlementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameDayId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GameDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameDaysTable,
      GameDay,
      $$GameDaysTableFilterComposer,
      $$GameDaysTableOrderingComposer,
      $$GameDaysTableAnnotationComposer,
      $$GameDaysTableCreateCompanionBuilder,
      $$GameDaysTableUpdateCompanionBuilder,
      (GameDay, $$GameDaysTableReferences),
      GameDay,
      PrefetchHooks Function({
        bool gameDayPlayersRefs,
        bool gamesRefs,
        bool chipLoansRefs,
        bool chipSettlementsRefs,
      })
    >;
typedef $$GameDayPlayersTableCreateCompanionBuilder =
    GameDayPlayersCompanion Function({
      Value<int> id,
      required int gameDayId,
      required int playerId,
    });
typedef $$GameDayPlayersTableUpdateCompanionBuilder =
    GameDayPlayersCompanion Function({
      Value<int> id,
      Value<int> gameDayId,
      Value<int> playerId,
    });

final class $$GameDayPlayersTableReferences
    extends BaseReferences<_$AppDatabase, $GameDayPlayersTable, GameDayPlayer> {
  $$GameDayPlayersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GameDaysTable _gameDayIdTable(_$AppDatabase db) =>
      db.gameDays.createAlias(
        $_aliasNameGenerator(db.gameDayPlayers.gameDayId, db.gameDays.id),
      );

  $$GameDaysTableProcessedTableManager get gameDayId {
    final $_column = $_itemColumn<int>('game_day_id')!;

    final manager = $$GameDaysTableTableManager(
      $_db,
      $_db.gameDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _playerIdTable(_$AppDatabase db) =>
      db.players.createAlias(
        $_aliasNameGenerator(db.gameDayPlayers.playerId, db.players.id),
      );

  $$PlayersTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<int>('player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GameDayPlayersTableFilterComposer
    extends Composer<_$AppDatabase, $GameDayPlayersTable> {
  $$GameDayPlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$GameDaysTableFilterComposer get gameDayId {
    final $$GameDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameDayId,
      referencedTable: $db.gameDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameDaysTableFilterComposer(
            $db: $db,
            $table: $db.gameDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameDayPlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $GameDayPlayersTable> {
  $$GameDayPlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$GameDaysTableOrderingComposer get gameDayId {
    final $$GameDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameDayId,
      referencedTable: $db.gameDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameDaysTableOrderingComposer(
            $db: $db,
            $table: $db.gameDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameDayPlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameDayPlayersTable> {
  $$GameDayPlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$GameDaysTableAnnotationComposer get gameDayId {
    final $$GameDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameDayId,
      referencedTable: $db.gameDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.gameDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get playerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameDayPlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameDayPlayersTable,
          GameDayPlayer,
          $$GameDayPlayersTableFilterComposer,
          $$GameDayPlayersTableOrderingComposer,
          $$GameDayPlayersTableAnnotationComposer,
          $$GameDayPlayersTableCreateCompanionBuilder,
          $$GameDayPlayersTableUpdateCompanionBuilder,
          (GameDayPlayer, $$GameDayPlayersTableReferences),
          GameDayPlayer,
          PrefetchHooks Function({bool gameDayId, bool playerId})
        > {
  $$GameDayPlayersTableTableManager(
    _$AppDatabase db,
    $GameDayPlayersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameDayPlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameDayPlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameDayPlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameDayId = const Value.absent(),
                Value<int> playerId = const Value.absent(),
              }) => GameDayPlayersCompanion(
                id: id,
                gameDayId: gameDayId,
                playerId: playerId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameDayId,
                required int playerId,
              }) => GameDayPlayersCompanion.insert(
                id: id,
                gameDayId: gameDayId,
                playerId: playerId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GameDayPlayersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameDayId = false, playerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameDayId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameDayId,
                                referencedTable: $$GameDayPlayersTableReferences
                                    ._gameDayIdTable(db),
                                referencedColumn:
                                    $$GameDayPlayersTableReferences
                                        ._gameDayIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (playerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playerId,
                                referencedTable: $$GameDayPlayersTableReferences
                                    ._playerIdTable(db),
                                referencedColumn:
                                    $$GameDayPlayersTableReferences
                                        ._playerIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GameDayPlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameDayPlayersTable,
      GameDayPlayer,
      $$GameDayPlayersTableFilterComposer,
      $$GameDayPlayersTableOrderingComposer,
      $$GameDayPlayersTableAnnotationComposer,
      $$GameDayPlayersTableCreateCompanionBuilder,
      $$GameDayPlayersTableUpdateCompanionBuilder,
      (GameDayPlayer, $$GameDayPlayersTableReferences),
      GameDayPlayer,
      PrefetchHooks Function({bool gameDayId, bool playerId})
    >;
typedef $$GamesTableCreateCompanionBuilder =
    GamesCompanion Function({
      Value<int> id,
      required int gameDayId,
      required int gameNumber,
      Value<DateTime> createdAt,
    });
typedef $$GamesTableUpdateCompanionBuilder =
    GamesCompanion Function({
      Value<int> id,
      Value<int> gameDayId,
      Value<int> gameNumber,
      Value<DateTime> createdAt,
    });

final class $$GamesTableReferences
    extends BaseReferences<_$AppDatabase, $GamesTable, Game> {
  $$GamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GameDaysTable _gameDayIdTable(_$AppDatabase db) => db.gameDays
      .createAlias($_aliasNameGenerator(db.games.gameDayId, db.gameDays.id));

  $$GameDaysTableProcessedTableManager get gameDayId {
    final $_column = $_itemColumn<int>('game_day_id')!;

    final manager = $$GameDaysTableTableManager(
      $_db,
      $_db.gameDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GameScoresTable, List<GameScore>>
  _gameScoresRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameScores,
    aliasName: $_aliasNameGenerator(db.games.id, db.gameScores.gameId),
  );

  $$GameScoresTableProcessedTableManager get gameScoresRefs {
    final manager = $$GameScoresTableTableManager(
      $_db,
      $_db.gameScores,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameScoresRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gameNumber => $composableBuilder(
    column: $table.gameNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GameDaysTableFilterComposer get gameDayId {
    final $$GameDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameDayId,
      referencedTable: $db.gameDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameDaysTableFilterComposer(
            $db: $db,
            $table: $db.gameDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> gameScoresRefs(
    Expression<bool> Function($$GameScoresTableFilterComposer f) f,
  ) {
    final $$GameScoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameScores,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameScoresTableFilterComposer(
            $db: $db,
            $table: $db.gameScores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gameNumber => $composableBuilder(
    column: $table.gameNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GameDaysTableOrderingComposer get gameDayId {
    final $$GameDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameDayId,
      referencedTable: $db.gameDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameDaysTableOrderingComposer(
            $db: $db,
            $table: $db.gameDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get gameNumber => $composableBuilder(
    column: $table.gameNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GameDaysTableAnnotationComposer get gameDayId {
    final $$GameDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameDayId,
      referencedTable: $db.gameDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.gameDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> gameScoresRefs<T extends Object>(
    Expression<T> Function($$GameScoresTableAnnotationComposer a) f,
  ) {
    final $$GameScoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameScores,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameScoresTableAnnotationComposer(
            $db: $db,
            $table: $db.gameScores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamesTable,
          Game,
          $$GamesTableFilterComposer,
          $$GamesTableOrderingComposer,
          $$GamesTableAnnotationComposer,
          $$GamesTableCreateCompanionBuilder,
          $$GamesTableUpdateCompanionBuilder,
          (Game, $$GamesTableReferences),
          Game,
          PrefetchHooks Function({bool gameDayId, bool gameScoresRefs})
        > {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameDayId = const Value.absent(),
                Value<int> gameNumber = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GamesCompanion(
                id: id,
                gameDayId: gameDayId,
                gameNumber: gameNumber,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameDayId,
                required int gameNumber,
                Value<DateTime> createdAt = const Value.absent(),
              }) => GamesCompanion.insert(
                id: id,
                gameDayId: gameDayId,
                gameNumber: gameNumber,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GamesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({gameDayId = false, gameScoresRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (gameScoresRefs) db.gameScores],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameDayId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameDayId,
                                referencedTable: $$GamesTableReferences
                                    ._gameDayIdTable(db),
                                referencedColumn: $$GamesTableReferences
                                    ._gameDayIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gameScoresRefs)
                    await $_getPrefetchedData<Game, $GamesTable, GameScore>(
                      currentTable: table,
                      referencedTable: $$GamesTableReferences
                          ._gameScoresRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GamesTableReferences(db, table, p0).gameScoresRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.gameId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamesTable,
      Game,
      $$GamesTableFilterComposer,
      $$GamesTableOrderingComposer,
      $$GamesTableAnnotationComposer,
      $$GamesTableCreateCompanionBuilder,
      $$GamesTableUpdateCompanionBuilder,
      (Game, $$GamesTableReferences),
      Game,
      PrefetchHooks Function({bool gameDayId, bool gameScoresRefs})
    >;
typedef $$GameScoresTableCreateCompanionBuilder =
    GameScoresCompanion Function({
      Value<int> id,
      required int gameId,
      required int playerId,
      required int score,
    });
typedef $$GameScoresTableUpdateCompanionBuilder =
    GameScoresCompanion Function({
      Value<int> id,
      Value<int> gameId,
      Value<int> playerId,
      Value<int> score,
    });

final class $$GameScoresTableReferences
    extends BaseReferences<_$AppDatabase, $GameScoresTable, GameScore> {
  $$GameScoresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) => db.games.createAlias(
    $_aliasNameGenerator(db.gameScores.gameId, db.games.id),
  );

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _playerIdTable(_$AppDatabase db) => db.players
      .createAlias($_aliasNameGenerator(db.gameScores.playerId, db.players.id));

  $$PlayersTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<int>('player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GameScoresTableFilterComposer
    extends Composer<_$AppDatabase, $GameScoresTable> {
  $$GameScoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameScoresTableOrderingComposer
    extends Composer<_$AppDatabase, $GameScoresTable> {
  $$GameScoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameScoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameScoresTable> {
  $$GameScoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get playerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameScoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameScoresTable,
          GameScore,
          $$GameScoresTableFilterComposer,
          $$GameScoresTableOrderingComposer,
          $$GameScoresTableAnnotationComposer,
          $$GameScoresTableCreateCompanionBuilder,
          $$GameScoresTableUpdateCompanionBuilder,
          (GameScore, $$GameScoresTableReferences),
          GameScore,
          PrefetchHooks Function({bool gameId, bool playerId})
        > {
  $$GameScoresTableTableManager(_$AppDatabase db, $GameScoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameScoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameScoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameScoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameId = const Value.absent(),
                Value<int> playerId = const Value.absent(),
                Value<int> score = const Value.absent(),
              }) => GameScoresCompanion(
                id: id,
                gameId: gameId,
                playerId: playerId,
                score: score,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameId,
                required int playerId,
                required int score,
              }) => GameScoresCompanion.insert(
                id: id,
                gameId: gameId,
                playerId: playerId,
                score: score,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GameScoresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false, playerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameId,
                                referencedTable: $$GameScoresTableReferences
                                    ._gameIdTable(db),
                                referencedColumn: $$GameScoresTableReferences
                                    ._gameIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (playerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playerId,
                                referencedTable: $$GameScoresTableReferences
                                    ._playerIdTable(db),
                                referencedColumn: $$GameScoresTableReferences
                                    ._playerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GameScoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameScoresTable,
      GameScore,
      $$GameScoresTableFilterComposer,
      $$GameScoresTableOrderingComposer,
      $$GameScoresTableAnnotationComposer,
      $$GameScoresTableCreateCompanionBuilder,
      $$GameScoresTableUpdateCompanionBuilder,
      (GameScore, $$GameScoresTableReferences),
      GameScore,
      PrefetchHooks Function({bool gameId, bool playerId})
    >;
typedef $$ChipLoansTableCreateCompanionBuilder =
    ChipLoansCompanion Function({
      Value<int> id,
      required int gameDayId,
      required int lenderId,
      required int borrowerId,
      required int amount,
      Value<DateTime> createdAt,
    });
typedef $$ChipLoansTableUpdateCompanionBuilder =
    ChipLoansCompanion Function({
      Value<int> id,
      Value<int> gameDayId,
      Value<int> lenderId,
      Value<int> borrowerId,
      Value<int> amount,
      Value<DateTime> createdAt,
    });

final class $$ChipLoansTableReferences
    extends BaseReferences<_$AppDatabase, $ChipLoansTable, ChipLoan> {
  $$ChipLoansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GameDaysTable _gameDayIdTable(_$AppDatabase db) =>
      db.gameDays.createAlias(
        $_aliasNameGenerator(db.chipLoans.gameDayId, db.gameDays.id),
      );

  $$GameDaysTableProcessedTableManager get gameDayId {
    final $_column = $_itemColumn<int>('game_day_id')!;

    final manager = $$GameDaysTableTableManager(
      $_db,
      $_db.gameDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _lenderIdTable(_$AppDatabase db) => db.players
      .createAlias($_aliasNameGenerator(db.chipLoans.lenderId, db.players.id));

  $$PlayersTableProcessedTableManager get lenderId {
    final $_column = $_itemColumn<int>('lender_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lenderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _borrowerIdTable(_$AppDatabase db) =>
      db.players.createAlias(
        $_aliasNameGenerator(db.chipLoans.borrowerId, db.players.id),
      );

  $$PlayersTableProcessedTableManager get borrowerId {
    final $_column = $_itemColumn<int>('borrower_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_borrowerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChipLoansTableFilterComposer
    extends Composer<_$AppDatabase, $ChipLoansTable> {
  $$ChipLoansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GameDaysTableFilterComposer get gameDayId {
    final $$GameDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameDayId,
      referencedTable: $db.gameDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameDaysTableFilterComposer(
            $db: $db,
            $table: $db.gameDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get lenderId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lenderId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get borrowerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.borrowerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChipLoansTableOrderingComposer
    extends Composer<_$AppDatabase, $ChipLoansTable> {
  $$ChipLoansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GameDaysTableOrderingComposer get gameDayId {
    final $$GameDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameDayId,
      referencedTable: $db.gameDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameDaysTableOrderingComposer(
            $db: $db,
            $table: $db.gameDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get lenderId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lenderId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get borrowerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.borrowerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChipLoansTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChipLoansTable> {
  $$ChipLoansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GameDaysTableAnnotationComposer get gameDayId {
    final $$GameDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameDayId,
      referencedTable: $db.gameDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.gameDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get lenderId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lenderId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get borrowerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.borrowerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChipLoansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChipLoansTable,
          ChipLoan,
          $$ChipLoansTableFilterComposer,
          $$ChipLoansTableOrderingComposer,
          $$ChipLoansTableAnnotationComposer,
          $$ChipLoansTableCreateCompanionBuilder,
          $$ChipLoansTableUpdateCompanionBuilder,
          (ChipLoan, $$ChipLoansTableReferences),
          ChipLoan,
          PrefetchHooks Function({
            bool gameDayId,
            bool lenderId,
            bool borrowerId,
          })
        > {
  $$ChipLoansTableTableManager(_$AppDatabase db, $ChipLoansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChipLoansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChipLoansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChipLoansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameDayId = const Value.absent(),
                Value<int> lenderId = const Value.absent(),
                Value<int> borrowerId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChipLoansCompanion(
                id: id,
                gameDayId: gameDayId,
                lenderId: lenderId,
                borrowerId: borrowerId,
                amount: amount,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameDayId,
                required int lenderId,
                required int borrowerId,
                required int amount,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChipLoansCompanion.insert(
                id: id,
                gameDayId: gameDayId,
                lenderId: lenderId,
                borrowerId: borrowerId,
                amount: amount,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChipLoansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({gameDayId = false, lenderId = false, borrowerId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (gameDayId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gameDayId,
                                    referencedTable: $$ChipLoansTableReferences
                                        ._gameDayIdTable(db),
                                    referencedColumn: $$ChipLoansTableReferences
                                        ._gameDayIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (lenderId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.lenderId,
                                    referencedTable: $$ChipLoansTableReferences
                                        ._lenderIdTable(db),
                                    referencedColumn: $$ChipLoansTableReferences
                                        ._lenderIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (borrowerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.borrowerId,
                                    referencedTable: $$ChipLoansTableReferences
                                        ._borrowerIdTable(db),
                                    referencedColumn: $$ChipLoansTableReferences
                                        ._borrowerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ChipLoansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChipLoansTable,
      ChipLoan,
      $$ChipLoansTableFilterComposer,
      $$ChipLoansTableOrderingComposer,
      $$ChipLoansTableAnnotationComposer,
      $$ChipLoansTableCreateCompanionBuilder,
      $$ChipLoansTableUpdateCompanionBuilder,
      (ChipLoan, $$ChipLoansTableReferences),
      ChipLoan,
      PrefetchHooks Function({bool gameDayId, bool lenderId, bool borrowerId})
    >;
typedef $$ChipSettlementsTableCreateCompanionBuilder =
    ChipSettlementsCompanion Function({
      Value<int> id,
      required int gameDayId,
      required int playerId,
      required int chipDiff,
    });
typedef $$ChipSettlementsTableUpdateCompanionBuilder =
    ChipSettlementsCompanion Function({
      Value<int> id,
      Value<int> gameDayId,
      Value<int> playerId,
      Value<int> chipDiff,
    });

final class $$ChipSettlementsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ChipSettlementsTable, ChipSettlement> {
  $$ChipSettlementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GameDaysTable _gameDayIdTable(_$AppDatabase db) =>
      db.gameDays.createAlias(
        $_aliasNameGenerator(db.chipSettlements.gameDayId, db.gameDays.id),
      );

  $$GameDaysTableProcessedTableManager get gameDayId {
    final $_column = $_itemColumn<int>('game_day_id')!;

    final manager = $$GameDaysTableTableManager(
      $_db,
      $_db.gameDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _playerIdTable(_$AppDatabase db) =>
      db.players.createAlias(
        $_aliasNameGenerator(db.chipSettlements.playerId, db.players.id),
      );

  $$PlayersTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<int>('player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChipSettlementsTableFilterComposer
    extends Composer<_$AppDatabase, $ChipSettlementsTable> {
  $$ChipSettlementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chipDiff => $composableBuilder(
    column: $table.chipDiff,
    builder: (column) => ColumnFilters(column),
  );

  $$GameDaysTableFilterComposer get gameDayId {
    final $$GameDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameDayId,
      referencedTable: $db.gameDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameDaysTableFilterComposer(
            $db: $db,
            $table: $db.gameDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChipSettlementsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChipSettlementsTable> {
  $$ChipSettlementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chipDiff => $composableBuilder(
    column: $table.chipDiff,
    builder: (column) => ColumnOrderings(column),
  );

  $$GameDaysTableOrderingComposer get gameDayId {
    final $$GameDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameDayId,
      referencedTable: $db.gameDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameDaysTableOrderingComposer(
            $db: $db,
            $table: $db.gameDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChipSettlementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChipSettlementsTable> {
  $$ChipSettlementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chipDiff =>
      $composableBuilder(column: $table.chipDiff, builder: (column) => column);

  $$GameDaysTableAnnotationComposer get gameDayId {
    final $$GameDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameDayId,
      referencedTable: $db.gameDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.gameDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get playerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChipSettlementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChipSettlementsTable,
          ChipSettlement,
          $$ChipSettlementsTableFilterComposer,
          $$ChipSettlementsTableOrderingComposer,
          $$ChipSettlementsTableAnnotationComposer,
          $$ChipSettlementsTableCreateCompanionBuilder,
          $$ChipSettlementsTableUpdateCompanionBuilder,
          (ChipSettlement, $$ChipSettlementsTableReferences),
          ChipSettlement,
          PrefetchHooks Function({bool gameDayId, bool playerId})
        > {
  $$ChipSettlementsTableTableManager(
    _$AppDatabase db,
    $ChipSettlementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChipSettlementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChipSettlementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChipSettlementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameDayId = const Value.absent(),
                Value<int> playerId = const Value.absent(),
                Value<int> chipDiff = const Value.absent(),
              }) => ChipSettlementsCompanion(
                id: id,
                gameDayId: gameDayId,
                playerId: playerId,
                chipDiff: chipDiff,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameDayId,
                required int playerId,
                required int chipDiff,
              }) => ChipSettlementsCompanion.insert(
                id: id,
                gameDayId: gameDayId,
                playerId: playerId,
                chipDiff: chipDiff,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChipSettlementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameDayId = false, playerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameDayId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameDayId,
                                referencedTable:
                                    $$ChipSettlementsTableReferences
                                        ._gameDayIdTable(db),
                                referencedColumn:
                                    $$ChipSettlementsTableReferences
                                        ._gameDayIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (playerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playerId,
                                referencedTable:
                                    $$ChipSettlementsTableReferences
                                        ._playerIdTable(db),
                                referencedColumn:
                                    $$ChipSettlementsTableReferences
                                        ._playerIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChipSettlementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChipSettlementsTable,
      ChipSettlement,
      $$ChipSettlementsTableFilterComposer,
      $$ChipSettlementsTableOrderingComposer,
      $$ChipSettlementsTableAnnotationComposer,
      $$ChipSettlementsTableCreateCompanionBuilder,
      $$ChipSettlementsTableUpdateCompanionBuilder,
      (ChipSettlement, $$ChipSettlementsTableReferences),
      ChipSettlement,
      PrefetchHooks Function({bool gameDayId, bool playerId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required int value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<int> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required int value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$GameDaysTableTableManager get gameDays =>
      $$GameDaysTableTableManager(_db, _db.gameDays);
  $$GameDayPlayersTableTableManager get gameDayPlayers =>
      $$GameDayPlayersTableTableManager(_db, _db.gameDayPlayers);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
  $$GameScoresTableTableManager get gameScores =>
      $$GameScoresTableTableManager(_db, _db.gameScores);
  $$ChipLoansTableTableManager get chipLoans =>
      $$ChipLoansTableTableManager(_db, _db.chipLoans);
  $$ChipSettlementsTableTableManager get chipSettlements =>
      $$ChipSettlementsTableTableManager(_db, _db.chipSettlements);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
