import '../../../../core/time/local_date.dart';
import '../entities/occurrence.dart';

/// Access to stored occurrences (past days, today and moved copies).
abstract interface class OccurrenceRepository {
  /// Emits the occurrences between [from] and [to] (inclusive) on change.
  Stream<List<Occurrence>> watchBetween(LocalDate from, LocalDate to);

  /// Returns the occurrences between [from] and [to] (inclusive).
  Future<List<Occurrence>> getBetween(LocalDate from, LocalDate to);

  /// Returns the occurrences on [from] and every later day.
  Future<List<Occurrence>> getFrom(LocalDate from);

  /// Emits missed occurrences still waiting for the user's decision.
  Stream<List<Occurrence>> watchUnresolvedMissed();

  /// Returns missed occurrences still waiting for the user's decision.
  Future<List<Occurrence>> getUnresolvedMissed();

  /// Returns the occurrence of [activityId] on [date], if stored.
  Future<Occurrence?> find(String activityId, LocalDate date);

  /// Returns the occurrence with [id], if stored.
  Future<Occurrence?> getById(String id);

  /// Inserts or replaces all [occurrences] in one transaction.
  Future<void> saveAll(List<Occurrence> occurrences);
}
