// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Yoo';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navHome => 'Home';

  @override
  String get navGoals => 'Goals';

  @override
  String get goalsTitle => 'Goals';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsExport => 'Export data';

  @override
  String get settingsExportSubtitle => 'One .txt file per month';

  @override
  String get settingsPersonalization => 'Personalization';

  @override
  String get settingsPersonalizationSubtitle => 'Colors, fonts, app icon';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languagePromptTitle => 'Choose your language';

  @override
  String get languagePromptSubtitle => 'You can change it later in Settings.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get moreOptions => 'More options';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get homeEmpty => 'Nothing planned for this day';

  @override
  String get homeEmptyHint => 'Tap + to create an activity';

  @override
  String get homeAllDone => 'All done for today';

  @override
  String get newActivity => 'New activity';

  @override
  String get editActivity => 'Edit activity';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldNameHint => 'e.g. Take vitamins';

  @override
  String get fieldNotification => 'Notification text';

  @override
  String get fieldNotificationHint => 'What the reminder should say';

  @override
  String get sectionRecurrence => 'Repeat';

  @override
  String get recurrenceDaily => 'Every day';

  @override
  String get recurrenceEveryOtherDay => 'Every other day';

  @override
  String get recurrenceWeekly => 'Every week';

  @override
  String get recurrenceMonthly => 'Once a month';

  @override
  String get recurrenceSpecificDays => 'Specific days';

  @override
  String get weekdayLabel => 'On';

  @override
  String get monthDayLabel => 'Day of the month';

  @override
  String get monthlyClampNote => 'In shorter months it falls on the last day.';

  @override
  String get specificDaysLabel => 'Days of the month';

  @override
  String get repeatNone => 'This month only';

  @override
  String get repeatNext => 'Also next month';

  @override
  String get repeatEvery => 'Every month';

  @override
  String get startDate => 'Starts on';

  @override
  String get sectionTimes => 'Times per day';

  @override
  String timeSlotLabel(int n) {
    return 'Time $n';
  }

  @override
  String get timeRandom => 'Random time in a range';

  @override
  String get timeFrom => 'From';

  @override
  String get timeTo => 'To';

  @override
  String get timeAt => 'At';

  @override
  String get sectionColor => 'Border color';

  @override
  String get sectionPartial => 'Partial completion';

  @override
  String get partialDescription => 'The notification asks how much you completed.';

  @override
  String get partialReminders => 'Extra reminders';

  @override
  String get partialUntil => 'Until';

  @override
  String get sectionGoal => 'Monthly goal';

  @override
  String get goalLinkToggle => 'Contributes to a goal';

  @override
  String get goalPick => 'Goal';

  @override
  String get goalNone => 'No goals yet: create them from the Calendar.';

  @override
  String get goalImpact => 'Impact';

  @override
  String get impactAdditive => 'Adds';

  @override
  String get impactSubtractive => 'Subtracts';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get errorEmptyName => 'Give the activity a name';

  @override
  String get errorNoDays => 'Select at least one day';

  @override
  String get errorTimeSlot => 'The end time must be after the start time';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionPostpone => 'Move to tomorrow';

  @override
  String get actionSkipDay => 'Remove only for this day';

  @override
  String get actionDeleteActivity => 'Delete the whole activity';

  @override
  String deleteConfirmTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteConfirmBody =>
      'It won\'t be planned anymore. Its history stays in the summaries.';

  @override
  String get postponed => 'Moved to tomorrow';

  @override
  String get cannotPostpone => 'Tomorrow already has this activity';

  @override
  String get progressTitle => 'How much did you complete?';

  @override
  String get progressDone => 'Done';

  @override
  String timesDone(int done, int total) {
    return '$done/$total';
  }

  @override
  String percent(int value) {
    return '$value%';
  }

  @override
  String get summaryTitle => 'Daily summary';

  @override
  String get summaryEmpty => 'No activities on this day';

  @override
  String get summaryPlanned => 'Planned';

  @override
  String get summaryMoved => 'Moved to the next day';

  @override
  String get summaryCompletedLater => 'Completed later';

  @override
  String get summaryPending => 'Still to do';

  @override
  String missedBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activities not completed',
      one: '1 activity not completed',
    );
    return '$_temp0';
  }

  @override
  String get missedPromptTitle => 'What should we do?';

  @override
  String get missedPromptSubtitle =>
      'These activities were not completed. Maybe you forgot to tick them? You can still mark them as completed.';

  @override
  String get missedDidIt => 'I did it';

  @override
  String get missedMoveToday => 'Do it today';

  @override
  String get missedLeave => 'Leave it';

  @override
  String get missedCannotMove => 'Already planned today';

  @override
  String get missedResolveAll => 'Decide later';

  @override
  String get notifDone => 'Done';

  @override
  String get notifFull => '100%';

  @override
  String get notifHalf => '50%';

  @override
  String get notifOther => 'Other %';

  @override
  String get notifInputLabel => 'Percentage (0-100)';

  @override
  String notifProgress(String name, int percent) {
    return '$name · $percent%';
  }

  @override
  String get goalReachedTitle => 'Goal reached!';

  @override
  String goalReachedBody(String title) {
    return '\"$title\" is at 100%';
  }

  @override
  String get channelReminders => 'Reminders';

  @override
  String get channelRemindersDescription => 'Reminders for your activities';

  @override
  String get channelGoals => 'Goals';

  @override
  String get channelGoalsDescription => 'When a monthly goal is reached';

  @override
  String get permTitle => 'Allow reminders';

  @override
  String get permBody =>
      'Yoo reminds you at the right time, even when the app is closed. Allow notifications on the next screen.';

  @override
  String get permExactTitle => 'Precise reminders';

  @override
  String get permExactBody =>
      'To remind you at the exact time, allow \"Alarms & reminders\" for Yoo on the next screen.';

  @override
  String get permContinue => 'Continue';

  @override
  String get permLater => 'Not now';

  @override
  String get settingsReliability => 'Reminder reliability';

  @override
  String get reliabilityNotifications => 'Notifications';

  @override
  String get reliabilityExact => 'Exact alarms';

  @override
  String get reliabilityBattery => 'Battery optimization';

  @override
  String get reliabilityBatteryHint =>
      'Some phones stop reminders to save battery. Open the app settings and set battery usage to \"Unrestricted\".';

  @override
  String get statusAllowed => 'Allowed';

  @override
  String get statusNotAllowed => 'Not allowed';

  @override
  String get openSettings => 'Open settings';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String calendarGoalsTitle(String month) {
    return 'Goals of $month';
  }

  @override
  String get goalsEmptyMonth => 'No goals for this month';

  @override
  String get goalsEmptyMonthHint => 'Add one, then link activities to it from their form.';

  @override
  String get goalAdd => 'Add goal';

  @override
  String get goalEdit => 'Edit goal';

  @override
  String get goalTitleLabel => 'Goal';

  @override
  String get goalTitleHint => 'e.g. Read 4 books';

  @override
  String get goalRename => 'Rename';

  @override
  String goalDeleteTitle(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get goalDeleteBody => 'Linked activities stay: they just stop counting for it.';

  @override
  String get goalReachedLabel => 'Reached';

  @override
  String get errorEmptyGoal => 'Give the goal a name';

  @override
  String get externalSectionTitle => 'From your calendars';

  @override
  String externalEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events in your calendars',
      one: '1 event in your calendars',
    );
    return '$_temp0';
  }

  @override
  String get externalAllDay => 'All day';

  @override
  String get externalAddAsActivity => 'Add as activity';

  @override
  String get externalReadOnly => 'Read only: Yoo never changes your calendars.';

  @override
  String get settingsCalendars => 'Device calendars';

  @override
  String get settingsCalendarsOff => 'Off';

  @override
  String get settingsCalendarsOn => 'Shown in Home and in the summaries';

  @override
  String get calendarsEnable => 'Show events from device calendars';

  @override
  String get calendarsDenied => 'Yoo is not allowed to read your calendars.';

  @override
  String get calendarsNone => 'No calendars on this device';

  @override
  String get calendarsPick => 'Calendars to show';

  @override
  String get exportDescription =>
      'A .txt file with the goals and activities of the month. Save it or send it from the share menu.';

  @override
  String exportButton(String month) {
    return 'Export $month';
  }

  @override
  String get exportEmpty => 'Nothing recorded in this month';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get exportPreview => 'Preview';

  @override
  String reportTitle(String month) {
    return 'Yoo · $month';
  }

  @override
  String reportExportedOn(String date) {
    return 'Exported on $date';
  }

  @override
  String get reportGoals => 'GOALS';

  @override
  String get reportNoGoals => 'No goals';

  @override
  String get reportActivities => 'ACTIVITIES';

  @override
  String get reportNoActivities => 'No activities';

  @override
  String reportTotal(int done, int total) {
    return 'Completed: $done of $total';
  }

  @override
  String get themePresets => 'Themes';

  @override
  String get presetPaper => 'Paper';

  @override
  String get presetMist => 'Mist';

  @override
  String get presetSage => 'Sage';

  @override
  String get presetNight => 'Night';

  @override
  String get presetInk => 'Ink';

  @override
  String get themeColors => 'Colors';

  @override
  String get colorText => 'Text';

  @override
  String get colorPage => 'Pages';

  @override
  String get colorSurface => 'Headers and sheets';

  @override
  String get colorCards => 'Cards';

  @override
  String get colorBar => 'Navigation bar';

  @override
  String get colorAccent => 'Buttons';

  @override
  String get colorNotification => 'Notifications';

  @override
  String get colorNotificationHint => 'Android only';

  @override
  String get colorDefault => 'Default';

  @override
  String get themeFont => 'Font';

  @override
  String get fontSystem => 'System';

  @override
  String get fontSample => 'A small step every day';

  @override
  String get appIcon => 'App icon';

  @override
  String get appIconHint => 'The final icons are on their way: these are previews.';

  @override
  String get appIconClassic => 'Classic';

  @override
  String get appIconLight => 'Light';

  @override
  String get appIconDark => 'Dark';

  @override
  String get appIconOcean => 'Ocean';

  @override
  String get appIconForest => 'Forest';

  @override
  String get appIconSunset => 'Sunset';

  @override
  String get themeReset => 'Reset to default';

  @override
  String get previewActivityOne => 'Morning walk';

  @override
  String get previewActivityTwo => 'Read 20 pages';
}
