import '../../../../core/time/clock.dart';
import '../../../../core/time/local_date.dart';
import '../entities/subtask.dart';
import '../repositories/subtask_repository.dart';
import 'occurrence_planner.dart';

/// Use cases around the subtasks of an activity.
class SubtaskService {
  SubtaskService({required this._subtasks, required this._clock, required this._newId});

  final SubtaskRepository _subtasks;
  final Clock _clock;
  final IdGenerator _newId;

  /// Adds a subtask at the end of the list of [activityId]. Blank titles are
  /// ignored.
  Future<Subtask?> add(String activityId, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return null;
    final existing = await _subtasks.getForActivity(activityId);
    final last = existing.isEmpty ? -1 : existing.last.position;
    final now = _clock.now();
    final subtask = Subtask(
      id: _newId(),
      activityId: activityId,
      title: trimmed,
      position: last + 1,
      createdAt: now,
      updatedAt: now,
    );
    await _subtasks.save(subtask);
    return subtask;
  }

  /// Renames [subtask]; a blank title leaves it unchanged.
  Future<void> rename(Subtask subtask, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty || trimmed == subtask.title) return;
    await _subtasks.save(subtask.copyWith(title: trimmed, updatedAt: _clock.now()));
  }

  Future<void> delete(Subtask subtask) => _subtasks.delete(subtask.id);

  /// Checks or unchecks [subtask] on [date].
  Future<void> setChecked(Subtask subtask, LocalDate date, {required bool checked}) =>
      _subtasks.setChecked(subtask.id, date, checked: checked, at: _clock.now());
}
