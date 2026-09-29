import 'package:drift/drift.dart';

import 'app_database.dart';
import 'key_value_store.dart';

/// [KeyValueStore] backed by the `key_values` table.
class DriftKeyValueStore implements KeyValueStore {
  DriftKeyValueStore(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$KeyValuesTable, KeyValueRow> _byKey(String key) =>
      _db.select(_db.keyValues)..where((t) => t.key.equals(key));

  @override
  Future<String?> read(String key) async => (await _byKey(key).getSingleOrNull())?.value;

  @override
  Stream<String?> watch(String key) => _byKey(key).watchSingleOrNull().map((row) => row?.value);

  @override
  Future<void> write(String key, String? value) async {
    await _db
        .into(_db.keyValues)
        .insertOnConflictUpdate(KeyValuesCompanion.insert(key: key, value: Value(value)));
  }
}
