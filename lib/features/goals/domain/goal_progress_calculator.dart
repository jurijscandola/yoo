import '../../activities/domain/entities/activity.dart';
import '../../activities/domain/entities/occurrence.dart';
import 'monthly_goal.dart';

/// Computes how far a monthly goal is, from the occurrences of the activities
/// linked to it.
///
/// progress = clamp(Σ ±impact × completion, 0, target), over the occurrences of
/// the goal's month (+ additive, − subtractive links). Skipped occurrences do
/// not count. The link is read from the activity's current settings.
class GoalProgressCalculator {
  const GoalProgressCalculator();

  /// Progress of [goal] as an amount, from 0 to its target. Partial
  /// activities contribute a share of their impact.
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
    return total.clamp(0, goal.target).toDouble();
  }

  /// Whether the "goal reached" notification must be sent now.
  bool shouldNotifyCompletion(MonthlyGoal goal, double progress) =>
      progress >= goal.target && goal.completionNotifiedAt == null;
}
