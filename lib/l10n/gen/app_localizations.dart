import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('it')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Yoo'**
  String get appTitle;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get navGoals;

  /// No description provided for @goalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get settingsExport;

  /// No description provided for @settingsExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One .txt file per month'**
  String get settingsExportSubtitle;

  /// No description provided for @settingsPersonalization.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get settingsPersonalization;

  /// No description provided for @settingsPersonalizationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Colors, fonts, app icon'**
  String get settingsPersonalizationSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languagePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languagePromptTitle;

  /// No description provided for @languagePromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change it later in Settings.'**
  String get languagePromptSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @homeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for this day'**
  String get homeEmpty;

  /// No description provided for @homeEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create an activity'**
  String get homeEmptyHint;

  /// No description provided for @homeAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done for today'**
  String get homeAllDone;

  /// No description provided for @newActivity.
  ///
  /// In en, this message translates to:
  /// **'New activity'**
  String get newActivity;

  /// No description provided for @editActivity.
  ///
  /// In en, this message translates to:
  /// **'Edit activity'**
  String get editActivity;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Take vitamins'**
  String get fieldNameHint;

  /// No description provided for @fieldNotification.
  ///
  /// In en, this message translates to:
  /// **'Notification text'**
  String get fieldNotification;

  /// No description provided for @fieldNotificationHint.
  ///
  /// In en, this message translates to:
  /// **'What the reminder should say'**
  String get fieldNotificationHint;

  /// No description provided for @sectionRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get sectionRecurrence;

  /// No description provided for @recurrenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get recurrenceDaily;

  /// No description provided for @recurrenceEveryOtherDay.
  ///
  /// In en, this message translates to:
  /// **'Every other day'**
  String get recurrenceEveryOtherDay;

  /// No description provided for @recurrenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get recurrenceWeekly;

  /// No description provided for @recurrenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'Once a month'**
  String get recurrenceMonthly;

  /// No description provided for @recurrenceSpecificDays.
  ///
  /// In en, this message translates to:
  /// **'Specific days'**
  String get recurrenceSpecificDays;

  /// No description provided for @weekdayLabel.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get weekdayLabel;

  /// No description provided for @monthDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day of the month'**
  String get monthDayLabel;

  /// No description provided for @monthlyClampNote.
  ///
  /// In en, this message translates to:
  /// **'In shorter months it falls on the last day.'**
  String get monthlyClampNote;

  /// No description provided for @specificDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days of the month'**
  String get specificDaysLabel;

  /// No description provided for @repeatNone.
  ///
  /// In en, this message translates to:
  /// **'This month only'**
  String get repeatNone;

  /// No description provided for @repeatNext.
  ///
  /// In en, this message translates to:
  /// **'Also next month'**
  String get repeatNext;

  /// No description provided for @repeatEvery.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get repeatEvery;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Starts on'**
  String get startDate;

  /// No description provided for @sectionTimes.
  ///
  /// In en, this message translates to:
  /// **'Times per day'**
  String get sectionTimes;

  /// No description provided for @timeSlotLabel.
  ///
  /// In en, this message translates to:
  /// **'Time {n}'**
  String timeSlotLabel(int n);

  /// No description provided for @timeRandom.
  ///
  /// In en, this message translates to:
  /// **'Random time in a range'**
  String get timeRandom;

  /// No description provided for @timeFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get timeFrom;

  /// No description provided for @timeTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get timeTo;

  /// No description provided for @timeAt.
  ///
  /// In en, this message translates to:
  /// **'At'**
  String get timeAt;

  /// No description provided for @sectionColor.
  ///
  /// In en, this message translates to:
  /// **'Border color'**
  String get sectionColor;

  /// No description provided for @sectionPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial completion'**
  String get sectionPartial;

  /// No description provided for @partialDescription.
  ///
  /// In en, this message translates to:
  /// **'The notification asks how much you completed.'**
  String get partialDescription;

  /// No description provided for @partialReminders.
  ///
  /// In en, this message translates to:
  /// **'Extra reminders'**
  String get partialReminders;

  /// No description provided for @partialUntil.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get partialUntil;

  /// No description provided for @sectionGoal.
  ///
  /// In en, this message translates to:
  /// **'Monthly goal'**
  String get sectionGoal;

  /// No description provided for @goalLinkToggle.
  ///
  /// In en, this message translates to:
  /// **'Contributes to a goal'**
  String get goalLinkToggle;

  /// No description provided for @goalPick.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goalPick;

  /// No description provided for @goalNone.
  ///
  /// In en, this message translates to:
  /// **'No goals yet: create them from the Calendar.'**
  String get goalNone;

  /// No description provided for @goalImpact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get goalImpact;

  /// No description provided for @impactAdditive.
  ///
  /// In en, this message translates to:
  /// **'Adds'**
  String get impactAdditive;

  /// No description provided for @impactSubtractive.
  ///
  /// In en, this message translates to:
  /// **'Subtracts'**
  String get impactSubtractive;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @errorEmptyName.
  ///
  /// In en, this message translates to:
  /// **'Give the activity a name'**
  String get errorEmptyName;

  /// No description provided for @errorNoDays.
  ///
  /// In en, this message translates to:
  /// **'Select at least one day'**
  String get errorNoDays;

  /// No description provided for @errorTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'The end time must be after the start time'**
  String get errorTimeSlot;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionPostpone.
  ///
  /// In en, this message translates to:
  /// **'Move to tomorrow'**
  String get actionPostpone;

  /// No description provided for @actionSkipDay.
  ///
  /// In en, this message translates to:
  /// **'Remove only for this day'**
  String get actionSkipDay;

  /// No description provided for @actionDeleteActivity.
  ///
  /// In en, this message translates to:
  /// **'Delete the whole activity'**
  String get actionDeleteActivity;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteConfirmTitle(String name);

  /// No description provided for @deleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It won\'t be planned anymore. Its history stays in the summaries.'**
  String get deleteConfirmBody;

  /// No description provided for @postponed.
  ///
  /// In en, this message translates to:
  /// **'Moved to tomorrow'**
  String get postponed;

  /// No description provided for @cannotPostpone.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow already has this activity'**
  String get cannotPostpone;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'How much did you complete?'**
  String get progressTitle;

  /// No description provided for @progressDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get progressDone;

  /// No description provided for @timesDone.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total}'**
  String timesDone(int done, int total);

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percent(int value);

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily summary'**
  String get summaryTitle;

  /// No description provided for @summaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activities on this day'**
  String get summaryEmpty;

  /// No description provided for @summaryPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get summaryPlanned;

  /// No description provided for @summaryMoved.
  ///
  /// In en, this message translates to:
  /// **'Moved to the next day'**
  String get summaryMoved;

  /// No description provided for @summaryCompletedLater.
  ///
  /// In en, this message translates to:
  /// **'Completed later'**
  String get summaryCompletedLater;

  /// No description provided for @summaryPending.
  ///
  /// In en, this message translates to:
  /// **'Still to do'**
  String get summaryPending;

  /// No description provided for @missedBanner.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 activity not completed} other{{count} activities not completed}}'**
  String missedBanner(int count);

  /// No description provided for @missedPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we do?'**
  String get missedPromptTitle;

  /// No description provided for @missedPromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These activities were not completed. Maybe you forgot to tick them? You can still mark them as completed.'**
  String get missedPromptSubtitle;

  /// No description provided for @missedDidIt.
  ///
  /// In en, this message translates to:
  /// **'I did it'**
  String get missedDidIt;

  /// No description provided for @missedMoveToday.
  ///
  /// In en, this message translates to:
  /// **'Do it today'**
  String get missedMoveToday;

  /// No description provided for @missedLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave it'**
  String get missedLeave;

  /// No description provided for @missedCannotMove.
  ///
  /// In en, this message translates to:
  /// **'Already planned today'**
  String get missedCannotMove;

  /// No description provided for @missedResolveAll.
  ///
  /// In en, this message translates to:
  /// **'Decide later'**
  String get missedResolveAll;

  /// No description provided for @notifDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get notifDone;

  /// No description provided for @notifFull.
  ///
  /// In en, this message translates to:
  /// **'100%'**
  String get notifFull;

  /// No description provided for @notifHalf.
  ///
  /// In en, this message translates to:
  /// **'50%'**
  String get notifHalf;

  /// No description provided for @notifOther.
  ///
  /// In en, this message translates to:
  /// **'Other %'**
  String get notifOther;

  /// No description provided for @notifInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Percentage (0-100)'**
  String get notifInputLabel;

  /// No description provided for @notifProgress.
  ///
  /// In en, this message translates to:
  /// **'{name} · {percent}%'**
  String notifProgress(String name, int percent);

  /// No description provided for @goalReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal reached!'**
  String get goalReachedTitle;

  /// No description provided for @goalReachedBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" is at 100%'**
  String goalReachedBody(String title);

  /// No description provided for @channelReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get channelReminders;

  /// No description provided for @channelRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminders for your activities'**
  String get channelRemindersDescription;

  /// No description provided for @channelGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get channelGoals;

  /// No description provided for @channelGoalsDescription.
  ///
  /// In en, this message translates to:
  /// **'When a monthly goal is reached'**
  String get channelGoalsDescription;

  /// No description provided for @permTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow reminders'**
  String get permTitle;

  /// No description provided for @permBody.
  ///
  /// In en, this message translates to:
  /// **'Yoo reminds you at the right time, even when the app is closed. Allow notifications on the next screen.'**
  String get permBody;

  /// No description provided for @permExactTitle.
  ///
  /// In en, this message translates to:
  /// **'Precise reminders'**
  String get permExactTitle;

  /// No description provided for @permExactBody.
  ///
  /// In en, this message translates to:
  /// **'To remind you at the exact time, allow \"Alarms & reminders\" for Yoo on the next screen.'**
  String get permExactBody;

  /// No description provided for @permContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get permContinue;

  /// No description provided for @permLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get permLater;

  /// No description provided for @settingsReliability.
  ///
  /// In en, this message translates to:
  /// **'Reminder reliability'**
  String get settingsReliability;

  /// No description provided for @reliabilityNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get reliabilityNotifications;

  /// No description provided for @reliabilityExact.
  ///
  /// In en, this message translates to:
  /// **'Exact alarms'**
  String get reliabilityExact;

  /// No description provided for @reliabilityBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery optimization'**
  String get reliabilityBattery;

  /// No description provided for @reliabilityBatteryHint.
  ///
  /// In en, this message translates to:
  /// **'Some phones stop reminders to save battery. Open the app settings and set battery usage to \"Unrestricted\".'**
  String get reliabilityBatteryHint;

  /// No description provided for @statusAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get statusAllowed;

  /// No description provided for @statusNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get statusNotAllowed;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @calendarGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals of {month}'**
  String calendarGoalsTitle(String month);

  /// No description provided for @goalsEmptyMonth.
  ///
  /// In en, this message translates to:
  /// **'No goals for this month'**
  String get goalsEmptyMonth;

  /// No description provided for @goalsEmptyMonthHint.
  ///
  /// In en, this message translates to:
  /// **'Add one, then link activities to it from their form.'**
  String get goalsEmptyMonthHint;

  /// No description provided for @goalAdd.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get goalAdd;

  /// No description provided for @goalEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get goalEdit;

  /// No description provided for @goalTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goalTitleLabel;

  /// No description provided for @goalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Read 4 books'**
  String get goalTitleHint;

  /// No description provided for @goalRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get goalRename;

  /// No description provided for @goalDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String goalDeleteTitle(String title);

  /// No description provided for @goalDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Linked activities stay: they just stop counting for it.'**
  String get goalDeleteBody;

  /// No description provided for @goalReachedLabel.
  ///
  /// In en, this message translates to:
  /// **'Reached'**
  String get goalReachedLabel;

  /// No description provided for @errorEmptyGoal.
  ///
  /// In en, this message translates to:
  /// **'Give the goal a name'**
  String get errorEmptyGoal;

  /// No description provided for @externalSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'From your calendars'**
  String get externalSectionTitle;

  /// No description provided for @externalEventsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event in your calendars} other{{count} events in your calendars}}'**
  String externalEventsCount(int count);

  /// No description provided for @externalAllDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get externalAllDay;

  /// No description provided for @externalAddAsActivity.
  ///
  /// In en, this message translates to:
  /// **'Add as activity'**
  String get externalAddAsActivity;

  /// No description provided for @externalReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read only: Yoo never changes your calendars.'**
  String get externalReadOnly;

  /// No description provided for @settingsCalendars.
  ///
  /// In en, this message translates to:
  /// **'Device calendars'**
  String get settingsCalendars;

  /// No description provided for @settingsCalendarsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsCalendarsOff;

  /// No description provided for @settingsCalendarsOn.
  ///
  /// In en, this message translates to:
  /// **'Shown in Home and in the summaries'**
  String get settingsCalendarsOn;

  /// No description provided for @calendarsEnable.
  ///
  /// In en, this message translates to:
  /// **'Show events from device calendars'**
  String get calendarsEnable;

  /// No description provided for @calendarsDenied.
  ///
  /// In en, this message translates to:
  /// **'Yoo is not allowed to read your calendars.'**
  String get calendarsDenied;

  /// No description provided for @calendarsNone.
  ///
  /// In en, this message translates to:
  /// **'No calendars on this device'**
  String get calendarsNone;

  /// No description provided for @calendarsPick.
  ///
  /// In en, this message translates to:
  /// **'Calendars to show'**
  String get calendarsPick;

  /// No description provided for @exportDescription.
  ///
  /// In en, this message translates to:
  /// **'A .txt file with the goals and activities of the month. Save it or send it from the share menu.'**
  String get exportDescription;

  /// No description provided for @exportButton.
  ///
  /// In en, this message translates to:
  /// **'Export {month}'**
  String exportButton(String month);

  /// No description provided for @exportEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded in this month'**
  String get exportEmpty;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @exportPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get exportPreview;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Yoo · {month}'**
  String reportTitle(String month);

  /// No description provided for @reportExportedOn.
  ///
  /// In en, this message translates to:
  /// **'Exported on {date}'**
  String reportExportedOn(String date);

  /// No description provided for @reportGoals.
  ///
  /// In en, this message translates to:
  /// **'GOALS'**
  String get reportGoals;

  /// No description provided for @reportNoGoals.
  ///
  /// In en, this message translates to:
  /// **'No goals'**
  String get reportNoGoals;

  /// No description provided for @reportActivities.
  ///
  /// In en, this message translates to:
  /// **'ACTIVITIES'**
  String get reportActivities;

  /// No description provided for @reportNoActivities.
  ///
  /// In en, this message translates to:
  /// **'No activities'**
  String get reportNoActivities;

  /// No description provided for @reportTotal.
  ///
  /// In en, this message translates to:
  /// **'Completed: {done} of {total}'**
  String reportTotal(int done, int total);

  /// No description provided for @themePresets.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themePresets;

  /// No description provided for @presetPaper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get presetPaper;

  /// No description provided for @presetMist.
  ///
  /// In en, this message translates to:
  /// **'Mist'**
  String get presetMist;

  /// No description provided for @presetSage.
  ///
  /// In en, this message translates to:
  /// **'Sage'**
  String get presetSage;

  /// No description provided for @presetNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get presetNight;

  /// No description provided for @presetInk.
  ///
  /// In en, this message translates to:
  /// **'Ink'**
  String get presetInk;

  /// No description provided for @themeColors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get themeColors;

  /// No description provided for @colorText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get colorText;

  /// No description provided for @colorPage.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get colorPage;

  /// No description provided for @colorSurface.
  ///
  /// In en, this message translates to:
  /// **'Headers and sheets'**
  String get colorSurface;

  /// No description provided for @colorCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get colorCards;

  /// No description provided for @colorBar.
  ///
  /// In en, this message translates to:
  /// **'Navigation bar'**
  String get colorBar;

  /// No description provided for @colorAccent.
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get colorAccent;

  /// No description provided for @colorNotification.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get colorNotification;

  /// No description provided for @colorNotificationHint.
  ///
  /// In en, this message translates to:
  /// **'Android only'**
  String get colorNotificationHint;

  /// No description provided for @colorDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get colorDefault;

  /// No description provided for @themeFont.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get themeFont;

  /// No description provided for @fontSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get fontSystem;

  /// No description provided for @fontSample.
  ///
  /// In en, this message translates to:
  /// **'A small step every day'**
  String get fontSample;

  /// No description provided for @appIcon.
  ///
  /// In en, this message translates to:
  /// **'App icon'**
  String get appIcon;

  /// No description provided for @appIconHint.
  ///
  /// In en, this message translates to:
  /// **'The final icons are on their way: these are previews.'**
  String get appIconHint;

  /// No description provided for @appIconClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get appIconClassic;

  /// No description provided for @appIconLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appIconLight;

  /// No description provided for @appIconDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appIconDark;

  /// No description provided for @appIconOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get appIconOcean;

  /// No description provided for @appIconForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get appIconForest;

  /// No description provided for @appIconSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get appIconSunset;

  /// No description provided for @themeReset.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get themeReset;

  /// No description provided for @previewActivityOne.
  ///
  /// In en, this message translates to:
  /// **'Morning walk'**
  String get previewActivityOne;

  /// No description provided for @previewActivityTwo.
  ///
  /// In en, this message translates to:
  /// **'Read 20 pages'**
  String get previewActivityTwo;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
