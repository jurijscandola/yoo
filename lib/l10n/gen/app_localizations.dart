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
