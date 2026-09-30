import '../../../../core/time/local_date.dart';
import '../entities/subtask.dart';

/// Access to the subtasks of activities and their daily checks.
abstract interface class SubtaskRepository {
  /// Emits the subtasks of [activityId], ordered by position.
  Stream<List<Subtask>> watchForActivity(String activityId);

  /// Returns the subtasks of [activityId], ordered by position.
  Future<List<Subtask>> getForActivity(String activityId);

  /// Emits the ids of the subtasks of [activityId] checked on [date].
  Stream<Set<String>> watchChecked(String activityId, LocalDate date);

  /// Inserts or replaces [subtask].
  Future<void> save(Subtask subtask);

  /// Removes [subtaskId] and all its checks.
  Future<void> delete(String subtaskId);

  /// Checks or unchecks [subtaskId] on [date].
  Future<void> setChecked(String subtaskId, LocalDate date, {required bool checked, DateTime? at});
}
