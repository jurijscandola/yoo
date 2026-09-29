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
}
