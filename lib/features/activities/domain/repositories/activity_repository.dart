import '../entities/activity.dart';

/// Access to the user's activities.
///
/// Today backed by the local database; a future backend implementation can add
/// shared activities and sync without changing callers.
abstract interface class ActivityRepository {
  /// Emits all activities (optionally including soft-deleted ones) on change.
  Stream<List<Activity>> watchAll({bool includeDeleted = false});

  /// Returns all activities once.
  Future<List<Activity>> getAll({bool includeDeleted = false});

  /// Returns the activity with [id], deleted or not.
  Future<Activity?> getById(String id);

  /// Inserts or replaces [activity].
  Future<void> save(Activity activity);
}
