import '../../activities/domain/services/activity_service.dart';
import '../domain/notification_planner.dart';
import '../domain/reminder_gateway.dart';

/// Applies an action pressed on a reminder notification.
///
/// Runs in the UI isolate when the app is open and in a background isolate
/// when it is not: both paths go through [ActivityService], so the same rules
/// (and the reminder refresh triggered by its change hook) apply.
class NotificationActionHandler {
  NotificationActionHandler(this._activities);

  final ActivityService _activities;

  /// Handles [actionId] for the notification carrying [payload]. [input] is
  /// the text typed in the notification, if any. Returns whether the action
  /// changed something.
  Future<bool> handle({required String? actionId, required String? payload, String? input}) async {
    final target = ReminderPayload.tryDecode(payload);
    if (target == null || actionId == null || actionId.isEmpty) return false;

    switch (actionId) {
      case ReminderActions.done:
        return await _activities.markTimeDone(target.activityId, target.date) != null;
      case ReminderActions.full:
        return await _activities.setProgress(target.activityId, target.date, 100) != null;
      case ReminderActions.half:
        return await _activities.setProgress(target.activityId, target.date, 50) != null;
      case ReminderActions.input:
        final percent = ReminderActions.parsePercent(input);
        if (percent == null) return false;
        return await _activities.setProgress(target.activityId, target.date, percent) != null;
      default:
        return false;
    }
  }
}
