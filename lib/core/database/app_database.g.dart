// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ActivitiesTable extends Activities with TableInfo<$ActivitiesTable, ActivityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notificationTextMeta = const VerificationMeta('notificationText');
  @override
  late final GeneratedColumn<String> notificationText = GeneratedColumn<String>(
    'notification_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _borderColorIndexMeta = const VerificationMeta('borderColorIndex');
  @override
  late final GeneratedColumn<int> borderColorIndex = GeneratedColumn<int>(
    'border_color_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurrenceJsonMeta = const VerificationMeta('recurrenceJson');
  @override
  late final GeneratedColumn<String> recurrenceJson = GeneratedColumn<String>(
    'recurrence_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeSlotsJsonMeta = const VerificationMeta('timeSlotsJson');
  @override
  late final GeneratedColumn<String> timeSlotsJson = GeneratedColumn<String>(
    'time_slots_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partialJsonMeta = const VerificationMeta('partialJson');
  @override
  late final GeneratedColumn<String> partialJson = GeneratedColumn<String>(
    'partial_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalLinkJsonMeta = const VerificationMeta('goalLinkJson');
  @override
  late final GeneratedColumn<String> goalLinkJson = GeneratedColumn<String>(
    'goal_link_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    notificationText,
    borderColorIndex,
    recurrenceJson,
    timeSlotsJson,
    startDate,
    partialJson,
    goalLinkJson,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notification_text')) {
      context.handle(
        _notificationTextMeta,
        notificationText.isAcceptableOrUnknown(data['notification_text']!, _notificationTextMeta),
      );
    } else if (isInserting) {
      context.missing(_notificationTextMeta);
    }
    if (data.containsKey('border_color_index')) {
      context.handle(
        _borderColorIndexMeta,
        borderColorIndex.isAcceptableOrUnknown(data['border_color_index']!, _borderColorIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_borderColorIndexMeta);
    }
    if (data.containsKey('recurrence_json')) {
      context.handle(
        _recurrenceJsonMeta,
        recurrenceJson.isAcceptableOrUnknown(data['recurrence_json']!, _recurrenceJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_recurrenceJsonMeta);
    }
    if (data.containsKey('time_slots_json')) {
      context.handle(
        _timeSlotsJsonMeta,
        timeSlotsJson.isAcceptableOrUnknown(data['time_slots_json']!, _timeSlotsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_timeSlotsJsonMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('partial_json')) {
      context.handle(
        _partialJsonMeta,
        partialJson.isAcceptableOrUnknown(data['partial_json']!, _partialJsonMeta),
      );
    }
    if (data.containsKey('goal_link_json')) {
      context.handle(
        _goalLinkJsonMeta,
        goalLinkJson.isAcceptableOrUnknown(data['goal_link_json']!, _goalLinkJsonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      notificationText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_text'],
      )!,
      borderColorIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}border_color_index'],
      )!,
      recurrenceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_json'],
      )!,
      timeSlotsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_slots_json'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      partialJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partial_json'],
      ),
      goalLinkJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_link_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class ActivityRow extends DataClass implements Insertable<ActivityRow> {
  final String id;
  final String name;
  final String notificationText;
  final int borderColorIndex;
  final String recurrenceJson;
  final String timeSlotsJson;
  final String startDate;
  final String? partialJson;
  final String? goalLinkJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ActivityRow({
    required this.id,
    required this.name,
    required this.notificationText,
    required this.borderColorIndex,
    required this.recurrenceJson,
    required this.timeSlotsJson,
    required this.startDate,
    this.partialJson,
    this.goalLinkJson,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['notification_text'] = Variable<String>(notificationText);
    map['border_color_index'] = Variable<int>(borderColorIndex);
    map['recurrence_json'] = Variable<String>(recurrenceJson);
    map['time_slots_json'] = Variable<String>(timeSlotsJson);
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || partialJson != null) {
      map['partial_json'] = Variable<String>(partialJson);
    }
    if (!nullToAbsent || goalLinkJson != null) {
      map['goal_link_json'] = Variable<String>(goalLinkJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      name: Value(name),
      notificationText: Value(notificationText),
      borderColorIndex: Value(borderColorIndex),
      recurrenceJson: Value(recurrenceJson),
      timeSlotsJson: Value(timeSlotsJson),
      startDate: Value(startDate),
      partialJson: partialJson == null && nullToAbsent ? const Value.absent() : Value(partialJson),
      goalLinkJson: goalLinkJson == null && nullToAbsent
          ? const Value.absent()
          : Value(goalLinkJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
    );
  }

  factory ActivityRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      notificationText: serializer.fromJson<String>(json['notificationText']),
      borderColorIndex: serializer.fromJson<int>(json['borderColorIndex']),
      recurrenceJson: serializer.fromJson<String>(json['recurrenceJson']),
      timeSlotsJson: serializer.fromJson<String>(json['timeSlotsJson']),
      startDate: serializer.fromJson<String>(json['startDate']),
      partialJson: serializer.fromJson<String?>(json['partialJson']),
      goalLinkJson: serializer.fromJson<String?>(json['goalLinkJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'notificationText': serializer.toJson<String>(notificationText),
      'borderColorIndex': serializer.toJson<int>(borderColorIndex),
      'recurrenceJson': serializer.toJson<String>(recurrenceJson),
      'timeSlotsJson': serializer.toJson<String>(timeSlotsJson),
      'startDate': serializer.toJson<String>(startDate),
      'partialJson': serializer.toJson<String?>(partialJson),
      'goalLinkJson': serializer.toJson<String?>(goalLinkJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ActivityRow copyWith({
    String? id,
    String? name,
    String? notificationText,
    int? borderColorIndex,
    String? recurrenceJson,
    String? timeSlotsJson,
    String? startDate,
    Value<String?> partialJson = const Value.absent(),
    Value<String?> goalLinkJson = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ActivityRow(
    id: id ?? this.id,
    name: name ?? this.name,
    notificationText: notificationText ?? this.notificationText,
    borderColorIndex: borderColorIndex ?? this.borderColorIndex,
    recurrenceJson: recurrenceJson ?? this.recurrenceJson,
    timeSlotsJson: timeSlotsJson ?? this.timeSlotsJson,
    startDate: startDate ?? this.startDate,
    partialJson: partialJson.present ? partialJson.value : this.partialJson,
    goalLinkJson: goalLinkJson.present ? goalLinkJson.value : this.goalLinkJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ActivityRow copyWithCompanion(ActivitiesCompanion data) {
    return ActivityRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      notificationText: data.notificationText.present
          ? data.notificationText.value
          : this.notificationText,
      borderColorIndex: data.borderColorIndex.present
          ? data.borderColorIndex.value
          : this.borderColorIndex,
      recurrenceJson: data.recurrenceJson.present ? data.recurrenceJson.value : this.recurrenceJson,
      timeSlotsJson: data.timeSlotsJson.present ? data.timeSlotsJson.value : this.timeSlotsJson,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      partialJson: data.partialJson.present ? data.partialJson.value : this.partialJson,
      goalLinkJson: data.goalLinkJson.present ? data.goalLinkJson.value : this.goalLinkJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notificationText: $notificationText, ')
          ..write('borderColorIndex: $borderColorIndex, ')
          ..write('recurrenceJson: $recurrenceJson, ')
          ..write('timeSlotsJson: $timeSlotsJson, ')
          ..write('startDate: $startDate, ')
          ..write('partialJson: $partialJson, ')
          ..write('goalLinkJson: $goalLinkJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    notificationText,
    borderColorIndex,
    recurrenceJson,
    timeSlotsJson,
    startDate,
    partialJson,
    goalLinkJson,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.notificationText == this.notificationText &&
          other.borderColorIndex == this.borderColorIndex &&
          other.recurrenceJson == this.recurrenceJson &&
          other.timeSlotsJson == this.timeSlotsJson &&
          other.startDate == this.startDate &&
          other.partialJson == this.partialJson &&
          other.goalLinkJson == this.goalLinkJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ActivitiesCompanion extends UpdateCompanion<ActivityRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> notificationText;
  final Value<int> borderColorIndex;
  final Value<String> recurrenceJson;
  final Value<String> timeSlotsJson;
  final Value<String> startDate;
  final Value<String?> partialJson;
  final Value<String?> goalLinkJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.notificationText = const Value.absent(),
    this.borderColorIndex = const Value.absent(),
    this.recurrenceJson = const Value.absent(),
    this.timeSlotsJson = const Value.absent(),
    this.startDate = const Value.absent(),
    this.partialJson = const Value.absent(),
    this.goalLinkJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    required String id,
    required String name,
    required String notificationText,
    required int borderColorIndex,
    required String recurrenceJson,
    required String timeSlotsJson,
    required String startDate,
    this.partialJson = const Value.absent(),
    this.goalLinkJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       notificationText = Value(notificationText),
       borderColorIndex = Value(borderColorIndex),
       recurrenceJson = Value(recurrenceJson),
       timeSlotsJson = Value(timeSlotsJson),
       startDate = Value(startDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ActivityRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? notificationText,
    Expression<int>? borderColorIndex,
    Expression<String>? recurrenceJson,
    Expression<String>? timeSlotsJson,
    Expression<String>? startDate,
    Expression<String>? partialJson,
    Expression<String>? goalLinkJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (notificationText != null) 'notification_text': notificationText,
      if (borderColorIndex != null) 'border_color_index': borderColorIndex,
      if (recurrenceJson != null) 'recurrence_json': recurrenceJson,
      if (timeSlotsJson != null) 'time_slots_json': timeSlotsJson,
      if (startDate != null) 'start_date': startDate,
      if (partialJson != null) 'partial_json': partialJson,
      if (goalLinkJson != null) 'goal_link_json': goalLinkJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? notificationText,
    Value<int>? borderColorIndex,
    Value<String>? recurrenceJson,
    Value<String>? timeSlotsJson,
    Value<String>? startDate,
    Value<String?>? partialJson,
    Value<String?>? goalLinkJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      notificationText: notificationText ?? this.notificationText,
      borderColorIndex: borderColorIndex ?? this.borderColorIndex,
      recurrenceJson: recurrenceJson ?? this.recurrenceJson,
      timeSlotsJson: timeSlotsJson ?? this.timeSlotsJson,
      startDate: startDate ?? this.startDate,
      partialJson: partialJson ?? this.partialJson,
      goalLinkJson: goalLinkJson ?? this.goalLinkJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notificationText.present) {
      map['notification_text'] = Variable<String>(notificationText.value);
    }
    if (borderColorIndex.present) {
      map['border_color_index'] = Variable<int>(borderColorIndex.value);
    }
    if (recurrenceJson.present) {
      map['recurrence_json'] = Variable<String>(recurrenceJson.value);
    }
    if (timeSlotsJson.present) {
      map['time_slots_json'] = Variable<String>(timeSlotsJson.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (partialJson.present) {
      map['partial_json'] = Variable<String>(partialJson.value);
    }
    if (goalLinkJson.present) {
      map['goal_link_json'] = Variable<String>(goalLinkJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notificationText: $notificationText, ')
          ..write('borderColorIndex: $borderColorIndex, ')
          ..write('recurrenceJson: $recurrenceJson, ')
          ..write('timeSlotsJson: $timeSlotsJson, ')
          ..write('startDate: $startDate, ')
          ..write('partialJson: $partialJson, ')
          ..write('goalLinkJson: $goalLinkJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OccurrencesTable extends Occurrences with TableInfo<$OccurrencesTable, OccurrenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityIdMeta = const VerificationMeta('activityId');
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalDateMeta = const VerificationMeta('originalDate');
  @override
  late final GeneratedColumn<String> originalDate = GeneratedColumn<String>(
    'original_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedCountMeta = const VerificationMeta('completedCount');
  @override
  late final GeneratedColumn<int> completedCount = GeneratedColumn<int>(
    'completed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _progressMeta = const VerificationMeta('progress');
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _resolutionMeta = const VerificationMeta('resolution');
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retroactiveMeta = const VerificationMeta('retroactive');
  @override
  late final GeneratedColumn<bool> retroactive = GeneratedColumn<bool>(
    'retroactive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("retroactive" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activityId,
    date,
    originalDate,
    status,
    completedCount,
    progress,
    resolution,
    completedAt,
    retroactive,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<OccurrenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('original_date')) {
      context.handle(
        _originalDateMeta,
        originalDate.isAcceptableOrUnknown(data['original_date']!, _originalDateMeta),
      );
    } else if (isInserting) {
      context.missing(_originalDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('completed_count')) {
      context.handle(
        _completedCountMeta,
        completedCount.isAcceptableOrUnknown(data['completed_count']!, _completedCountMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(data['completed_at']!, _completedAtMeta),
      );
    }
    if (data.containsKey('retroactive')) {
      context.handle(
        _retroactiveMeta,
        retroactive.isAcceptableOrUnknown(data['retroactive']!, _retroactiveMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OccurrenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OccurrenceRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      date: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      originalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_count'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      retroactive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}retroactive'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OccurrencesTable createAlias(String alias) {
    return $OccurrencesTable(attachedDatabase, alias);
  }
}

class OccurrenceRow extends DataClass implements Insertable<OccurrenceRow> {
  final String id;
  final String activityId;
  final String date;
  final String originalDate;
  final String status;
  final int completedCount;
  final int progress;
  final String? resolution;
  final DateTime? completedAt;
  final bool retroactive;
  final DateTime updatedAt;
  const OccurrenceRow({
    required this.id,
    required this.activityId,
    required this.date,
    required this.originalDate,
    required this.status,
    required this.completedCount,
    required this.progress,
    this.resolution,
    this.completedAt,
    required this.retroactive,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['activity_id'] = Variable<String>(activityId);
    map['date'] = Variable<String>(date);
    map['original_date'] = Variable<String>(originalDate);
    map['status'] = Variable<String>(status);
    map['completed_count'] = Variable<int>(completedCount);
    map['progress'] = Variable<int>(progress);
    if (!nullToAbsent || resolution != null) {
      map['resolution'] = Variable<String>(resolution);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['retroactive'] = Variable<bool>(retroactive);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OccurrencesCompanion toCompanion(bool nullToAbsent) {
    return OccurrencesCompanion(
      id: Value(id),
      activityId: Value(activityId),
      date: Value(date),
      originalDate: Value(originalDate),
      status: Value(status),
      completedCount: Value(completedCount),
      progress: Value(progress),
      resolution: resolution == null && nullToAbsent ? const Value.absent() : Value(resolution),
      completedAt: completedAt == null && nullToAbsent ? const Value.absent() : Value(completedAt),
      retroactive: Value(retroactive),
      updatedAt: Value(updatedAt),
    );
  }

  factory OccurrenceRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OccurrenceRow(
      id: serializer.fromJson<String>(json['id']),
      activityId: serializer.fromJson<String>(json['activityId']),
      date: serializer.fromJson<String>(json['date']),
      originalDate: serializer.fromJson<String>(json['originalDate']),
      status: serializer.fromJson<String>(json['status']),
      completedCount: serializer.fromJson<int>(json['completedCount']),
      progress: serializer.fromJson<int>(json['progress']),
      resolution: serializer.fromJson<String?>(json['resolution']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      retroactive: serializer.fromJson<bool>(json['retroactive']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'activityId': serializer.toJson<String>(activityId),
      'date': serializer.toJson<String>(date),
      'originalDate': serializer.toJson<String>(originalDate),
      'status': serializer.toJson<String>(status),
      'completedCount': serializer.toJson<int>(completedCount),
      'progress': serializer.toJson<int>(progress),
      'resolution': serializer.toJson<String?>(resolution),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'retroactive': serializer.toJson<bool>(retroactive),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OccurrenceRow copyWith({
    String? id,
    String? activityId,
    String? date,
    String? originalDate,
    String? status,
    int? completedCount,
    int? progress,
    Value<String?> resolution = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    bool? retroactive,
    DateTime? updatedAt,
  }) => OccurrenceRow(
    id: id ?? this.id,
    activityId: activityId ?? this.activityId,
    date: date ?? this.date,
    originalDate: originalDate ?? this.originalDate,
    status: status ?? this.status,
    completedCount: completedCount ?? this.completedCount,
    progress: progress ?? this.progress,
    resolution: resolution.present ? resolution.value : this.resolution,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    retroactive: retroactive ?? this.retroactive,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OccurrenceRow copyWithCompanion(OccurrencesCompanion data) {
    return OccurrenceRow(
      id: data.id.present ? data.id.value : this.id,
      activityId: data.activityId.present ? data.activityId.value : this.activityId,
      date: data.date.present ? data.date.value : this.date,
      originalDate: data.originalDate.present ? data.originalDate.value : this.originalDate,
      status: data.status.present ? data.status.value : this.status,
      completedCount: data.completedCount.present ? data.completedCount.value : this.completedCount,
      progress: data.progress.present ? data.progress.value : this.progress,
      resolution: data.resolution.present ? data.resolution.value : this.resolution,
      completedAt: data.completedAt.present ? data.completedAt.value : this.completedAt,
      retroactive: data.retroactive.present ? data.retroactive.value : this.retroactive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OccurrenceRow(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('date: $date, ')
          ..write('originalDate: $originalDate, ')
          ..write('status: $status, ')
          ..write('completedCount: $completedCount, ')
          ..write('progress: $progress, ')
          ..write('resolution: $resolution, ')
          ..write('completedAt: $completedAt, ')
          ..write('retroactive: $retroactive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    activityId,
    date,
    originalDate,
    status,
    completedCount,
    progress,
    resolution,
    completedAt,
    retroactive,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OccurrenceRow &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.date == this.date &&
          other.originalDate == this.originalDate &&
          other.status == this.status &&
          other.completedCount == this.completedCount &&
          other.progress == this.progress &&
          other.resolution == this.resolution &&
          other.completedAt == this.completedAt &&
          other.retroactive == this.retroactive &&
          other.updatedAt == this.updatedAt);
}

class OccurrencesCompanion extends UpdateCompanion<OccurrenceRow> {
  final Value<String> id;
  final Value<String> activityId;
  final Value<String> date;
  final Value<String> originalDate;
  final Value<String> status;
  final Value<int> completedCount;
  final Value<int> progress;
  final Value<String?> resolution;
  final Value<DateTime?> completedAt;
  final Value<bool> retroactive;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const OccurrencesCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.date = const Value.absent(),
    this.originalDate = const Value.absent(),
    this.status = const Value.absent(),
    this.completedCount = const Value.absent(),
    this.progress = const Value.absent(),
    this.resolution = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.retroactive = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OccurrencesCompanion.insert({
    required String id,
    required String activityId,
    required String date,
    required String originalDate,
    required String status,
    this.completedCount = const Value.absent(),
    this.progress = const Value.absent(),
    this.resolution = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.retroactive = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       activityId = Value(activityId),
       date = Value(date),
       originalDate = Value(originalDate),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<OccurrenceRow> custom({
    Expression<String>? id,
    Expression<String>? activityId,
    Expression<String>? date,
    Expression<String>? originalDate,
    Expression<String>? status,
    Expression<int>? completedCount,
    Expression<int>? progress,
    Expression<String>? resolution,
    Expression<DateTime>? completedAt,
    Expression<bool>? retroactive,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (date != null) 'date': date,
      if (originalDate != null) 'original_date': originalDate,
      if (status != null) 'status': status,
      if (completedCount != null) 'completed_count': completedCount,
      if (progress != null) 'progress': progress,
      if (resolution != null) 'resolution': resolution,
      if (completedAt != null) 'completed_at': completedAt,
      if (retroactive != null) 'retroactive': retroactive,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OccurrencesCompanion copyWith({
    Value<String>? id,
    Value<String>? activityId,
    Value<String>? date,
    Value<String>? originalDate,
    Value<String>? status,
    Value<int>? completedCount,
    Value<int>? progress,
    Value<String?>? resolution,
    Value<DateTime?>? completedAt,
    Value<bool>? retroactive,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return OccurrencesCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      date: date ?? this.date,
      originalDate: originalDate ?? this.originalDate,
      status: status ?? this.status,
      completedCount: completedCount ?? this.completedCount,
      progress: progress ?? this.progress,
      resolution: resolution ?? this.resolution,
      completedAt: completedAt ?? this.completedAt,
      retroactive: retroactive ?? this.retroactive,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (originalDate.present) {
      map['original_date'] = Variable<String>(originalDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedCount.present) {
      map['completed_count'] = Variable<int>(completedCount.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (retroactive.present) {
      map['retroactive'] = Variable<bool>(retroactive.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('date: $date, ')
          ..write('originalDate: $originalDate, ')
          ..write('status: $status, ')
          ..write('completedCount: $completedCount, ')
          ..write('progress: $progress, ')
          ..write('resolution: $resolution, ')
          ..write('completedAt: $completedAt, ')
          ..write('retroactive: $retroactive, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, GoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completionNotifiedAtMeta = const VerificationMeta(
    'completionNotifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completionNotifiedAt = GeneratedColumn<DateTime>(
    'completion_notified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    year,
    month,
    title,
    completionNotifiedAt,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(Insertable<GoalRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('year')) {
      context.handle(_yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('month')) {
      context.handle(_monthMeta, month.isAcceptableOrUnknown(data['month']!, _monthMeta));
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('completion_notified_at')) {
      context.handle(
        _completionNotifiedAtMeta,
        completionNotifiedAt.isAcceptableOrUnknown(
          data['completion_notified_at']!,
          _completionNotifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      year: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}year'])!,
      month: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}month'])!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      completionNotifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completion_notified_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class GoalRow extends DataClass implements Insertable<GoalRow> {
  final String id;
  final int year;
  final int month;
  final String title;
  final DateTime? completionNotifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const GoalRow({
    required this.id,
    required this.year,
    required this.month,
    required this.title,
    this.completionNotifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['year'] = Variable<int>(year);
    map['month'] = Variable<int>(month);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || completionNotifiedAt != null) {
      map['completion_notified_at'] = Variable<DateTime>(completionNotifiedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      year: Value(year),
      month: Value(month),
      title: Value(title),
      completionNotifiedAt: completionNotifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completionNotifiedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
    );
  }

  factory GoalRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalRow(
      id: serializer.fromJson<String>(json['id']),
      year: serializer.fromJson<int>(json['year']),
      month: serializer.fromJson<int>(json['month']),
      title: serializer.fromJson<String>(json['title']),
      completionNotifiedAt: serializer.fromJson<DateTime?>(json['completionNotifiedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'year': serializer.toJson<int>(year),
      'month': serializer.toJson<int>(month),
      'title': serializer.toJson<String>(title),
      'completionNotifiedAt': serializer.toJson<DateTime?>(completionNotifiedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  GoalRow copyWith({
    String? id,
    int? year,
    int? month,
    String? title,
    Value<DateTime?> completionNotifiedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => GoalRow(
    id: id ?? this.id,
    year: year ?? this.year,
    month: month ?? this.month,
    title: title ?? this.title,
    completionNotifiedAt: completionNotifiedAt.present
        ? completionNotifiedAt.value
        : this.completionNotifiedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  GoalRow copyWithCompanion(GoalsCompanion data) {
    return GoalRow(
      id: data.id.present ? data.id.value : this.id,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
      title: data.title.present ? data.title.value : this.title,
      completionNotifiedAt: data.completionNotifiedAt.present
          ? data.completionNotifiedAt.value
          : this.completionNotifiedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalRow(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('title: $title, ')
          ..write('completionNotifiedAt: $completionNotifiedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, year, month, title, completionNotifiedAt, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalRow &&
          other.id == this.id &&
          other.year == this.year &&
          other.month == this.month &&
          other.title == this.title &&
          other.completionNotifiedAt == this.completionNotifiedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class GoalsCompanion extends UpdateCompanion<GoalRow> {
  final Value<String> id;
  final Value<int> year;
  final Value<int> month;
  final Value<String> title;
  final Value<DateTime?> completionNotifiedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.title = const Value.absent(),
    this.completionNotifiedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required int year,
    required int month,
    required String title,
    this.completionNotifiedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       year = Value(year),
       month = Value(month),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<GoalRow> custom({
    Expression<String>? id,
    Expression<int>? year,
    Expression<int>? month,
    Expression<String>? title,
    Expression<DateTime>? completionNotifiedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (title != null) 'title': title,
      if (completionNotifiedAt != null) 'completion_notified_at': completionNotifiedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? id,
    Value<int>? year,
    Value<int>? month,
    Value<String>? title,
    Value<DateTime?>? completionNotifiedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      title: title ?? this.title,
      completionNotifiedAt: completionNotifiedAt ?? this.completionNotifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (completionNotifiedAt.present) {
      map['completion_notified_at'] = Variable<DateTime>(completionNotifiedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('title: $title, ')
          ..write('completionNotifiedAt: $completionNotifiedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KeyValuesTable extends KeyValues with TableInfo<$KeyValuesTable, KeyValueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyValuesTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<KeyValueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KeyValueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyValueRow(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $KeyValuesTable createAlias(String alias) {
    return $KeyValuesTable(attachedDatabase, alias);
  }
}

class KeyValueRow extends DataClass implements Insertable<KeyValueRow> {
  final String key;
  final String? value;
  const KeyValueRow({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  KeyValuesCompanion toCompanion(bool nullToAbsent) {
    return KeyValuesCompanion(
      key: Value(key),
      value: value == null && nullToAbsent ? const Value.absent() : Value(value),
    );
  }

  factory KeyValueRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyValueRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  KeyValueRow copyWith({String? key, Value<String?> value = const Value.absent()}) =>
      KeyValueRow(key: key ?? this.key, value: value.present ? value.value : this.value);
  KeyValueRow copyWithCompanion(KeyValuesCompanion data) {
    return KeyValueRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyValueRow(')
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
      (other is KeyValueRow && other.key == this.key && other.value == this.value);
}

class KeyValuesCompanion extends UpdateCompanion<KeyValueRow> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const KeyValuesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeyValuesCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<KeyValueRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeyValuesCompanion copyWith({Value<String>? key, Value<String?>? value, Value<int>? rowid}) {
    return KeyValuesCompanion(
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
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyValuesCompanion(')
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
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $OccurrencesTable occurrences = $OccurrencesTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $KeyValuesTable keyValues = $KeyValuesTable(this);
  late final Index occurrencesDate = Index(
    'occurrences_date',
    'CREATE INDEX occurrences_date ON occurrences (date)',
  );
  late final Index occurrencesActivityDate = Index(
    'occurrences_activity_date',
    'CREATE INDEX occurrences_activity_date ON occurrences (activity_id, date)',
  );
  late final Index goalsMonth = Index(
    'goals_month',
    'CREATE INDEX goals_month ON goals (year, month)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    activities,
    occurrences,
    goals,
    keyValues,
    occurrencesDate,
    occurrencesActivityDate,
    goalsMonth,
  ];
}

typedef $$ActivitiesTableCreateCompanionBuilder =
    ActivitiesCompanion Function({
      required String id,
      required String name,
      required String notificationText,
      required int borderColorIndex,
      required String recurrenceJson,
      required String timeSlotsJson,
      required String startDate,
      Value<String?> partialJson,
      Value<String?> goalLinkJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ActivitiesTableUpdateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> notificationText,
      Value<int> borderColorIndex,
      Value<String> recurrenceJson,
      Value<String> timeSlotsJson,
      Value<String> startDate,
      Value<String?> partialJson,
      Value<String?> goalLinkJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$ActivitiesTableFilterComposer extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notificationText => $composableBuilder(
    column: $table.notificationText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get borderColorIndex => $composableBuilder(
    column: $table.borderColorIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceJson =>
      $composableBuilder(column: $table.recurrenceJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeSlotsJson =>
      $composableBuilder(column: $table.timeSlotsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partialJson =>
      $composableBuilder(column: $table.partialJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get goalLinkJson =>
      $composableBuilder(column: $table.goalLinkJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$ActivitiesTableOrderingComposer extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notificationText => $composableBuilder(
    column: $table.notificationText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get borderColorIndex => $composableBuilder(
    column: $table.borderColorIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceJson => $composableBuilder(
    column: $table.recurrenceJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeSlotsJson => $composableBuilder(
    column: $table.timeSlotsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partialJson =>
      $composableBuilder(column: $table.partialJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get goalLinkJson =>
      $composableBuilder(column: $table.goalLinkJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$ActivitiesTableAnnotationComposer extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notificationText =>
      $composableBuilder(column: $table.notificationText, builder: (column) => column);

  GeneratedColumn<int> get borderColorIndex =>
      $composableBuilder(column: $table.borderColorIndex, builder: (column) => column);

  GeneratedColumn<String> get recurrenceJson =>
      $composableBuilder(column: $table.recurrenceJson, builder: (column) => column);

  GeneratedColumn<String> get timeSlotsJson =>
      $composableBuilder(column: $table.timeSlotsJson, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get partialJson =>
      $composableBuilder(column: $table.partialJson, builder: (column) => column);

  GeneratedColumn<String> get goalLinkJson =>
      $composableBuilder(column: $table.goalLinkJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          ActivityRow,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (ActivityRow, BaseReferences<_$AppDatabase, $ActivitiesTable, ActivityRow>),
          ActivityRow,
          PrefetchHooks Function()
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> notificationText = const Value.absent(),
                Value<int> borderColorIndex = const Value.absent(),
                Value<String> recurrenceJson = const Value.absent(),
                Value<String> timeSlotsJson = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String?> partialJson = const Value.absent(),
                Value<String?> goalLinkJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                name: name,
                notificationText: notificationText,
                borderColorIndex: borderColorIndex,
                recurrenceJson: recurrenceJson,
                timeSlotsJson: timeSlotsJson,
                startDate: startDate,
                partialJson: partialJson,
                goalLinkJson: goalLinkJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String notificationText,
                required int borderColorIndex,
                required String recurrenceJson,
                required String timeSlotsJson,
                required String startDate,
                Value<String?> partialJson = const Value.absent(),
                Value<String?> goalLinkJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion.insert(
                id: id,
                name: name,
                notificationText: notificationText,
                borderColorIndex: borderColorIndex,
                recurrenceJson: recurrenceJson,
                timeSlotsJson: timeSlotsJson,
                startDate: startDate,
                partialJson: partialJson,
                goalLinkJson: goalLinkJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivitiesTable, ActivityRow>(table),
                  BaseReferences<_$AppDatabase, $ActivitiesTable, ActivityRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      ActivityRow,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (ActivityRow, BaseReferences<_$AppDatabase, $ActivitiesTable, ActivityRow>),
      ActivityRow,
      PrefetchHooks Function()
    >;
typedef $$OccurrencesTableCreateCompanionBuilder =
    OccurrencesCompanion Function({
      required String id,
      required String activityId,
      required String date,
      required String originalDate,
      required String status,
      Value<int> completedCount,
      Value<int> progress,
      Value<String?> resolution,
      Value<DateTime?> completedAt,
      Value<bool> retroactive,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$OccurrencesTableUpdateCompanionBuilder =
    OccurrencesCompanion Function({
      Value<String> id,
      Value<String> activityId,
      Value<String> date,
      Value<String> originalDate,
      Value<String> status,
      Value<int> completedCount,
      Value<int> progress,
      Value<String?> resolution,
      Value<DateTime?> completedAt,
      Value<bool> retroactive,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$OccurrencesTableFilterComposer extends Composer<_$AppDatabase, $OccurrencesTable> {
  $$OccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityId =>
      $composableBuilder(column: $table.activityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalDate =>
      $composableBuilder(column: $table.originalDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedCount =>
      $composableBuilder(column: $table.completedCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolution =>
      $composableBuilder(column: $table.resolution, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get retroactive =>
      $composableBuilder(column: $table.retroactive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$OccurrencesTableOrderingComposer extends Composer<_$AppDatabase, $OccurrencesTable> {
  $$OccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityId =>
      $composableBuilder(column: $table.activityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalDate =>
      $composableBuilder(column: $table.originalDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedCount => $composableBuilder(
    column: $table.completedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolution =>
      $composableBuilder(column: $table.resolution, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get retroactive =>
      $composableBuilder(column: $table.retroactive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$OccurrencesTableAnnotationComposer extends Composer<_$AppDatabase, $OccurrencesTable> {
  $$OccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activityId =>
      $composableBuilder(column: $table.activityId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get originalDate =>
      $composableBuilder(column: $table.originalDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get completedCount =>
      $composableBuilder(column: $table.completedCount, builder: (column) => column);

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get resolution =>
      $composableBuilder(column: $table.resolution, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<bool> get retroactive =>
      $composableBuilder(column: $table.retroactive, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$OccurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OccurrencesTable,
          OccurrenceRow,
          $$OccurrencesTableFilterComposer,
          $$OccurrencesTableOrderingComposer,
          $$OccurrencesTableAnnotationComposer,
          $$OccurrencesTableCreateCompanionBuilder,
          $$OccurrencesTableUpdateCompanionBuilder,
          (OccurrenceRow, BaseReferences<_$AppDatabase, $OccurrencesTable, OccurrenceRow>),
          OccurrenceRow,
          PrefetchHooks Function()
        > {
  $$OccurrencesTableTableManager(_$AppDatabase db, $OccurrencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$OccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$OccurrencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OccurrencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> activityId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> originalDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> completedCount = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<bool> retroactive = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OccurrencesCompanion(
                id: id,
                activityId: activityId,
                date: date,
                originalDate: originalDate,
                status: status,
                completedCount: completedCount,
                progress: progress,
                resolution: resolution,
                completedAt: completedAt,
                retroactive: retroactive,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String activityId,
                required String date,
                required String originalDate,
                required String status,
                Value<int> completedCount = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<bool> retroactive = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => OccurrencesCompanion.insert(
                id: id,
                activityId: activityId,
                date: date,
                originalDate: originalDate,
                status: status,
                completedCount: completedCount,
                progress: progress,
                resolution: resolution,
                completedAt: completedAt,
                retroactive: retroactive,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OccurrencesTable, OccurrenceRow>(table),
                  BaseReferences<_$AppDatabase, $OccurrencesTable, OccurrenceRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OccurrencesTable,
      OccurrenceRow,
      $$OccurrencesTableFilterComposer,
      $$OccurrencesTableOrderingComposer,
      $$OccurrencesTableAnnotationComposer,
      $$OccurrencesTableCreateCompanionBuilder,
      $$OccurrencesTableUpdateCompanionBuilder,
      (OccurrenceRow, BaseReferences<_$AppDatabase, $OccurrencesTable, OccurrenceRow>),
      OccurrenceRow,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      required String id,
      required int year,
      required int month,
      required String title,
      Value<DateTime?> completionNotifiedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<String> id,
      Value<int> year,
      Value<int> month,
      Value<String> title,
      Value<DateTime?> completionNotifiedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completionNotifiedAt => $composableBuilder(
    column: $table.completionNotifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$GoalsTableOrderingComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completionNotifiedAt => $composableBuilder(
    column: $table.completionNotifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$GoalsTableAnnotationComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get completionNotifiedAt =>
      $composableBuilder(column: $table.completionNotifiedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          GoalRow,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (GoalRow, BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>),
          GoalRow,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime?> completionNotifiedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                year: year,
                month: month,
                title: title,
                completionNotifiedAt: completionNotifiedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int year,
                required int month,
                required String title,
                Value<DateTime?> completionNotifiedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                year: year,
                month: month,
                title: title,
                completionNotifiedAt: completionNotifiedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GoalsTable, GoalRow>(table),
                  BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      GoalRow,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (GoalRow, BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>),
      GoalRow,
      PrefetchHooks Function()
    >;
typedef $$KeyValuesTableCreateCompanionBuilder =
    KeyValuesCompanion Function({required String key, Value<String?> value, Value<int> rowid});
typedef $$KeyValuesTableUpdateCompanionBuilder =
    KeyValuesCompanion Function({Value<String> key, Value<String?> value, Value<int> rowid});

class $$KeyValuesTableFilterComposer extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$KeyValuesTableOrderingComposer extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$KeyValuesTableAnnotationComposer extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$KeyValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KeyValuesTable,
          KeyValueRow,
          $$KeyValuesTableFilterComposer,
          $$KeyValuesTableOrderingComposer,
          $$KeyValuesTableAnnotationComposer,
          $$KeyValuesTableCreateCompanionBuilder,
          $$KeyValuesTableUpdateCompanionBuilder,
          (KeyValueRow, BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValueRow>),
          KeyValueRow,
          PrefetchHooks Function()
        > {
  $$KeyValuesTableTableManager(_$AppDatabase db, $KeyValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$KeyValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$KeyValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeyValuesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeyValuesCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KeyValuesTable, KeyValueRow>(table),
                  BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValueRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KeyValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KeyValuesTable,
      KeyValueRow,
      $$KeyValuesTableFilterComposer,
      $$KeyValuesTableOrderingComposer,
      $$KeyValuesTableAnnotationComposer,
      $$KeyValuesTableCreateCompanionBuilder,
      $$KeyValuesTableUpdateCompanionBuilder,
      (KeyValueRow, BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValueRow>),
      KeyValueRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$OccurrencesTableTableManager get occurrences =>
      $$OccurrencesTableTableManager(_db, _db.occurrences);
  $$GoalsTableTableManager get goals => $$GoalsTableTableManager(_db, _db.goals);
  $$KeyValuesTableTableManager get keyValues => $$KeyValuesTableTableManager(_db, _db.keyValues);
}
