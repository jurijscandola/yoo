import '../../../core/time/local_date.dart';

/// A goal for a given month, fed by the activities linked to it.
class MonthlyGoal {
  const MonthlyGoal({
    required this.id,
    required this.year,
    required this.month,
    required this.title,
    required this.target,
    required this.createdAt,
    required this.updatedAt,
    this.completionNotifiedAt,
    this.deletedAt,
  });

  final String id;
  final int year;
  final int month;
  final String title;

  /// Amount to reach (e.g. 4 books, or 1 for a single event). Completing a
  /// linked activity adds or removes its impact from the progress.
  final int target;

  /// When the "goal reached" notification was sent (sent only once).
  final DateTime? completionNotifiedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Soft-delete marker.
  final DateTime? deletedAt;

  /// Whether [date] falls in this goal's month.
  bool contains(LocalDate date) => date.year == year && date.month == month;

  MonthlyGoal copyWith({
    String? title,
    int? target,
    DateTime? Function()? completionNotifiedAt,
    DateTime? updatedAt,
    DateTime? Function()? deletedAt,
  }) {
    return MonthlyGoal(
      id: id,
      year: year,
      month: month,
      title: title ?? this.title,
      target: target ?? this.target,
      completionNotifiedAt: completionNotifiedAt != null
          ? completionNotifiedAt()
          : this.completionNotifiedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }
}
