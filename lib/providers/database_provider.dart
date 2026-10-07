import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majan_log_app/db/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
