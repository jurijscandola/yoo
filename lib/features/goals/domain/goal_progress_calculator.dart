import '../../activities/domain/entities/activity.dart';
import '../../activities/domain/entities/occurrence.dart';
import 'monthly_goal.dart';

/// Computes how far a monthly goal is, from the occurrences of the activities
/// linked to it.
///
/// progress = clamp(Σ ±impact × completion, 0, 100), over the occurrences of
/// the goal's month (+ additive, − subtractive links). Skipped occurrences do
/// not count. The link is read from the activity's current settings.
class GoalProgressCalculator {
  const GoalProgressCalculator();

  /// Progress of [goal] in percent (0–100).
  double progressOf({
    required MonthlyGoal goal,
    required Map<String, Activity> activitiesById,
    required Iterable<Occurrence> occurrences,
  }) {
    var total = 0.0;
    for (final o in occurrences) {
      if (!goal.contains(o.date) || o.status == OccurrenceStatus.skipped) continue;
      final activity = activitiesById[o.activityId];
      final link = activity?.goalLink;
      if (activity == null || link == null || link.goalId != goal.id) continue;
      total += link.signedImpact * o.completionFor(activity);
    }
    return total.clamp(0, 100).toDouble();
  }

  /// Whether the "goal reached" notification must be sent now.
  bool shouldNotifyCompletion(MonthlyGoal goal, double progress) =>
      progress >= 100 && goal.completionNotifiedAt == null;
}
