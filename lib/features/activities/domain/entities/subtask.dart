/// A checklist item under an activity ("sotto attività"). Checks are stored
/// per day, so a recurring activity starts each day with an empty list.
class Subtask {
  const Subtask({
    required this.id,
    required this.activityId,
    required this.title,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String activityId;
  final String title;

  /// Order in the list (ascending).
  final int position;

  final DateTime createdAt;
  final DateTime updatedAt;

  Subtask copyWith({String? title, DateTime? updatedAt}) => Subtask(
    id: id,
    activityId: activityId,
    title: title ?? this.title,
    position: position,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
