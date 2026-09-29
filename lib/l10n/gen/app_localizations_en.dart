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
}
