import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/database/app_database.dart';
import '../core/database/drift_key_value_store.dart';
import '../core/database/key_value_store.dart';
import '../core/time/clock.dart';
import '../core/time/local_date.dart';
import '../features/activities/data/drift_activity_repository.dart';
import '../features/activities/data/drift_occurrence_repository.dart';
import '../features/activities/data/drift_subtask_repository.dart';
import '../features/activities/domain/repositories/activity_repository.dart';
import '../features/activities/domain/repositories/occurrence_repository.dart';
import '../features/activities/domain/repositories/subtask_repository.dart';
import '../features/activities/domain/services/occurrence_planner.dart';
import '../features/goals/data/drift_goal_repository.dart';
import '../features/goals/domain/goal_repository.dart';

// Dependency graph of the app. Implementations are chosen here only, so a
// future cloud or backend implementation replaces one line (or one override).

/// The local database. Must be overridden at bootstrap with an opened one.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden at bootstrap'),
);

final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => DriftKeyValueStore(ref.watch(databaseProvider)),
);

final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => DriftActivityRepository(ref.watch(databaseProvider)),
);

final occurrenceRepositoryProvider = Provider<OccurrenceRepository>(
  (ref) => DriftOccurrenceRepository(ref.watch(databaseProvider)),
);

final subtaskRepositoryProvider = Provider<SubtaskRepository>(
  (ref) => DriftSubtaskRepository(ref.watch(databaseProvider)),
);

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => DriftGoalRepository(ref.watch(databaseProvider)),
);

/// Current time source (overridden in tests).
final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// Today's date. Invalidated by the day watcher on resume and at midnight.
final todayProvider = Provider<LocalDate>((ref) => ref.watch(clockProvider).today());

/// Unique id source for new entities.
final idGeneratorProvider = Provider<IdGenerator>((ref) => const Uuid().v4);
