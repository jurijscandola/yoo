import 'dart:convert';

/// Why a file could not be read as a backup.
enum BackupProblem {
  /// Not a Yoo backup (or damaged).
  invalid,

  /// Made by a newer version of Yoo, with data this one does not know.
  tooNew,
}

/// A backup could not be read.
class BackupFormatException implements Exception {
  const BackupFormatException(this.problem, [this.detail]);

  final BackupProblem problem;
  final String? detail;

  @override
  String toString() => 'BackupFormatException(${problem.name}${detail == null ? '' : ': $detail'})';
}

/// A full backup of Yoo: every row of the user's tables, plus the language
/// and the appearance. Stored as JSON (`Yoo-backup-YYYY-MM-DD.json`).
///
/// Rows are kept as plain maps (one per table, see the data layer), so the
/// file follows the database schema it was made with ([schemaVersion]).
class BackupFile {
  const BackupFile({
    required this.exportedAt,
    required this.schemaVersion,
    required this.tables,
    this.settings,
  });

  /// Marks the file as a Yoo backup.
  static const format = 'yoo-backup';

  /// Version of this envelope (not of the database schema).
  static const version = 1;

  final DateTime exportedAt;

  /// Database schema the rows follow.
  final int schemaVersion;

  /// Rows by table name.
  final Map<String, List<Map<String, Object?>>> tables;

  /// Language and appearance (`localeCode`, `theme`), if saved.
  final Map<String, Object?>? settings;

  List<Map<String, Object?>> rowsOf(String table) => tables[table] ?? const [];

  /// Activities in the backup (not deleted).
  int get activityCount => rowsOf('activities').where((r) => r['deletedAt'] == null).length;

  /// Days with a stored history.
  int get dayCount => {for (final r in rowsOf('occurrences')) r['date']}.length;

  /// Goals in the backup (not deleted).
  int get goalCount => rowsOf('goals').where((r) => r['deletedAt'] == null).length;

  String encode() => jsonEncode({
    'format': format,
    'version': version,
    'exportedAt': exportedAt.toUtc().toIso8601String(),
    'schemaVersion': schemaVersion,
    'settings': settings,
    'tables': tables,
  });

  /// Reads a backup made by this or an older version of Yoo, whose database
  /// is at [currentSchema]. Throws [BackupFormatException] otherwise.
  static BackupFile parse(String text, {required int currentSchema}) {
    // Some editors and the share sheet may add a byte order mark.
    final clean = text.startsWith('﻿') ? text.substring(1) : text;
    final Object? json;
    try {
      json = jsonDecode(clean);
    } on FormatException catch (e) {
      throw BackupFormatException(BackupProblem.invalid, e.message);
    }
    if (json is! Map<String, Object?> || json['format'] != format) {
      throw const BackupFormatException(BackupProblem.invalid, 'not a Yoo backup');
    }
    final fileVersion = json['version'];
    final schema = json['schemaVersion'];
    if (fileVersion is! int || schema is! int) {
      throw const BackupFormatException(BackupProblem.invalid, 'missing version');
    }
    if (fileVersion > version || schema > currentSchema) {
      throw const BackupFormatException(BackupProblem.tooNew);
    }
    try {
      final rawTables = json['tables']! as Map<String, Object?>;
      return BackupFile(
        exportedAt: DateTime.parse(json['exportedAt']! as String).toLocal(),
        schemaVersion: schema,
        settings: json['settings'] as Map<String, Object?>?,
        tables: {
          for (final MapEntry(:key, :value) in rawTables.entries)
            key: [for (final row in value! as List<Object?>) row! as Map<String, Object?>],
        },
      );
    } catch (e) {
      throw BackupFormatException(BackupProblem.invalid, '$e');
    }
  }
}

/// What an import changed.
class BackupImportResult {
  const BackupImportResult({required this.added, required this.updated});

  /// Rows that were missing and have been added.
  final int added;

  /// Rows replaced by a newer version from the backup.
  final int updated;
}
