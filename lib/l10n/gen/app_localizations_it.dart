// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Yoo';

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navHome => 'Home';

  @override
  String get navGoals => 'Obiettivi';

  @override
  String get goalsTitle => 'Obiettivi';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsExport => 'Esporta dati';

  @override
  String get settingsExportSubtitle => 'Un file .txt per ogni mese';

  @override
  String get settingsPersonalization => 'Personalizzazione';

  @override
  String get settingsPersonalizationSubtitle => 'Colori, font, icona dell\'app';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get languagePromptTitle => 'Scegli la lingua';

  @override
  String get languagePromptSubtitle => 'Potrai cambiarla nelle Impostazioni.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get moreOptions => 'Altre opzioni';

  @override
  String get today => 'Oggi';

  @override
  String get yesterday => 'Ieri';

  @override
  String get tomorrow => 'Domani';

  @override
  String get homeEmpty => 'Nessuna attività per questo giorno';

  @override
  String get homeEmptyHint => 'Tocca + per creare un\'attività';

  @override
  String get homeAllDone => 'Tutto fatto per oggi';

  @override
  String get newActivity => 'Nuova attività';

  @override
  String get editActivity => 'Modifica attività';

  @override
  String get fieldName => 'Nome';

  @override
  String get fieldNameHint => 'es. Prendi le vitamine';

  @override
  String get fieldNotification => 'Testo della notifica';

  @override
  String get fieldNotificationHint => 'Cosa deve dire il promemoria';

  @override
  String get sectionRecurrence => 'Ricorrenza';

  @override
  String get recurrenceOnce => 'Solo un giorno';

  @override
  String get recurrenceDaily => 'Tutti i giorni';

  @override
  String get recurrenceEveryOtherDay => 'Un giorno sì e uno no';

  @override
  String get recurrenceWeekly => 'Ogni settimana';

  @override
  String get recurrenceEveryNWeeks => 'Ogni X settimane';

  @override
  String get recurrenceMonthly => 'Una volta al mese';

  @override
  String get recurrenceSpecificDays => 'Giorni specifici';

  @override
  String get weekdayLabel => 'Il giorno';

  @override
  String everyWeeks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ogni $n settimane',
      one: 'Ogni settimana',
    );
    return '$_temp0';
  }

  @override
  String weeklyFirstTime(String date) {
    return 'Prima volta $date, poi a intervalli regolari anche nei mesi successivi.';
  }

  @override
  String get monthDayLabel => 'Giorno del mese';

  @override
  String get monthlyClampNote => 'Nei mesi più corti cade l\'ultimo giorno del mese.';

  @override
  String get specificDaysLabel => 'Giorni del mese';

  @override
  String get repeatNone => 'Solo questo mese';

  @override
  String get repeatNext => 'Anche il mese prossimo';

  @override
  String get repeatEvery => 'Tutti i mesi';

  @override
  String get onceDate => 'Il giorno';

  @override
  String get startDate => 'Inizia il';

  @override
  String get sectionTimes => 'Volte al giorno';

  @override
  String timeSlotLabel(int n) {
    return 'Volta $n';
  }

  @override
  String get timeRandom => 'Orario casuale in una fascia';

  @override
  String get timeFrom => 'Dalle';

  @override
  String get timeTo => 'Alle';

  @override
  String get timeAt => 'Alle';

  @override
  String get colorStyleHint => 'Il bordo o l\'ombra seguono lo stile scelto in Personalizzazione.';

  @override
  String get colorPreviewName => 'La tua attività';

  @override
  String get sectionColor => 'Colore del pulsante';

  @override
  String get sectionPartial => 'Completamento parziale';

  @override
  String get partialDescription => 'La notifica chiede quanto hai completato.';

  @override
  String get partialReminders => 'Promemoria aggiuntivi';

  @override
  String get partialUntil => 'Fino alle';

  @override
  String get sectionGoal => 'Obiettivo mensile';

  @override
  String get goalLinkToggle => 'Contribuisce a un obiettivo';

  @override
  String get goalPick => 'Obiettivo';

  @override
  String get goalNone => 'Nessun obiettivo: creali dal Calendario.';

  @override
  String get goalImpact => 'Valore';

  @override
  String get impactAdditive => 'Aggiunge';

  @override
  String get impactSubtractive => 'Sottrae';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get errorEmptyName => 'Dai un nome all\'attività';

  @override
  String get errorNoDays => 'Seleziona almeno un giorno';

  @override
  String get errorTimeSlot => 'L\'orario di fine deve essere dopo quello di inizio';

  @override
  String get actionEdit => 'Modifica';

  @override
  String get actionPostpone => 'Sposta a domani';

  @override
  String get actionSkipDay => 'Rimuovi solo per questo giorno';

  @override
  String get actionDeleteActivity => 'Elimina l\'intera attività';

  @override
  String deleteConfirmTitle(String name) {
    return 'Eliminare \"$name\"?';
  }

  @override
  String get deleteConfirmBody => 'Non verrà più pianificata. Lo storico resta nei riepiloghi.';

  @override
  String get postponed => 'Spostata a domani';

  @override
  String get cannotPostpone => 'Domani c\'è già questa attività';

  @override
  String get progressTitle => 'Quanto hai completato?';

  @override
  String get progressDone => 'Fatto';

  @override
  String timesDone(int done, int total) {
    return '$done/$total';
  }

  @override
  String percent(int value) {
    return '$value%';
  }

  @override
  String get summaryTitle => 'Riepilogo giornaliero';

  @override
  String get summaryEmpty => 'Nessuna attività in questo giorno';

  @override
  String get summaryPlanned => 'Pianificata';

  @override
  String get summaryMoved => 'Spostata al giorno dopo';

  @override
  String get summaryCompletedLater => 'Completata in seguito';

  @override
  String get summaryPending => 'Ancora da fare';

  @override
  String missedBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attività non completate',
      one: '1 attività non completata',
    );
    return '$_temp0';
  }

  @override
  String get missedPromptTitle => 'Cosa facciamo?';

  @override
  String get missedPromptSubtitle =>
      'Queste attività non sono state completate. Forse hai dimenticato di spuntarle? Puoi ancora segnarle come completate.';

  @override
  String get missedDidIt => 'L\'ho fatta';

  @override
  String get missedMoveToday => 'Falla oggi';

  @override
  String get missedLeave => 'Lascia stare';

  @override
  String get missedCannotMove => 'Già pianificata oggi';

  @override
  String get missedResolveAll => 'Decido dopo';

  @override
  String get notifDone => 'Fatto';

  @override
  String get notifFull => '100%';

  @override
  String get notifHalf => '50%';

  @override
  String get notifOther => 'Altra %';

  @override
  String get notifInputLabel => 'Percentuale (0-100)';

  @override
  String notifProgress(String name, int percent) {
    return '$name · $percent%';
  }

  @override
  String get goalReachedTitle => 'Obiettivo raggiunto!';

  @override
  String goalReachedBody(String title) {
    return 'Hai completato \"$title\"';
  }

  @override
  String get channelReminders => 'Promemoria';

  @override
  String get channelRemindersDescription => 'Promemoria delle tue attività';

  @override
  String get channelGoals => 'Obiettivi';

  @override
  String get channelGoalsDescription => 'Quando un obiettivo mensile viene raggiunto';

  @override
  String get permTitle => 'Consenti i promemoria';

  @override
  String get permBody =>
      'Yoo ti avvisa al momento giusto, anche ad app chiusa. Consenti le notifiche nella schermata successiva.';

  @override
  String get permExactTitle => 'Promemoria puntuali';

  @override
  String get permExactBody =>
      'Per avvisarti all\'orario esatto, consenti \"Sveglie e promemoria\" per Yoo nella schermata successiva.';

  @override
  String get permContinue => 'Continua';

  @override
  String get permLater => 'Non ora';

  @override
  String get settingsReliability => 'Affidabilità dei promemoria';

  @override
  String get reliabilityNotifications => 'Notifiche';

  @override
  String get reliabilityExact => 'Sveglie esatte';

  @override
  String get reliabilityBattery => 'Ottimizzazione batteria';

  @override
  String get reliabilityBatteryHint =>
      'Alcuni telefoni bloccano i promemoria per risparmiare batteria. Apri le impostazioni dell\'app e imposta l\'uso della batteria su \"Senza restrizioni\".';

  @override
  String get statusAllowed => 'Consentito';

  @override
  String get statusNotAllowed => 'Non consentito';

  @override
  String get openSettings => 'Apri impostazioni';

  @override
  String get previousMonth => 'Mese precedente';

  @override
  String get nextMonth => 'Mese successivo';

  @override
  String calendarGoalsTitle(String month) {
    return 'Obiettivi di $month';
  }

  @override
  String get goalsEmptyMonth => 'Nessun obiettivo per questo mese';

  @override
  String get goalsEmptyMonthHint => 'Aggiungine uno, poi collega le attività dal loro modulo.';

  @override
  String get goalAdd => 'Aggiungi obiettivo';

  @override
  String get goalEdit => 'Modifica obiettivo';

  @override
  String get goalTitleLabel => 'Obiettivo';

  @override
  String get goalTitleHint => 'es. Leggere 4 libri';

  @override
  String get goalRename => 'Rinomina';

  @override
  String goalDeleteTitle(String title) {
    return 'Eliminare \"$title\"?';
  }

  @override
  String get goalDeleteBody =>
      'Le attività collegate restano: smettono solo di contare per questo obiettivo.';

  @override
  String get subtasksToggle => 'Sotto attività';

  @override
  String get subtaskAdd => 'Aggiungi sotto attività';

  @override
  String get subtaskHint => 'Nuova sotto attività';

  @override
  String get subtaskEdit => 'Modifica sotto attività';

  @override
  String get goalTargetLabel => 'Quantità da raggiungere';

  @override
  String get goalTargetHelp =>
      'Ogni attività collegata aggiunge o toglie il suo valore. Usa 1 per un evento singolo.';

  @override
  String get errorGoalTarget => 'Inserisci un numero da 1 in su';

  @override
  String get goalImpactHelp =>
      'Quanto aggiunge o toglie all\'obiettivo ogni volta che la completi.';

  @override
  String goalAmount(int value, int target) {
    return '$value / $target';
  }

  @override
  String get goalReachedLabel => 'Raggiunto';

  @override
  String get errorEmptyGoal => 'Dai un nome all\'obiettivo';

  @override
  String get externalSectionTitle => 'Dai tuoi calendari';

  @override
  String externalEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventi nei tuoi calendari',
      one: '1 evento nei tuoi calendari',
    );
    return '$_temp0';
  }

  @override
  String get externalAllDay => 'Tutto il giorno';

  @override
  String get externalAddAsActivity => 'Aggiungi come attività';

  @override
  String get externalReadOnly => 'Sola lettura: Yoo non modifica mai i tuoi calendari.';

  @override
  String get settingsCalendars => 'Calendari del dispositivo';

  @override
  String get settingsCalendarsOff => 'Disattivati';

  @override
  String get settingsCalendarsOn => 'Mostrati in Home e nei riepiloghi';

  @override
  String get calendarsEnable => 'Mostra gli eventi dei calendari del dispositivo';

  @override
  String get calendarsDenied => 'Yoo non ha il permesso di leggere i tuoi calendari.';

  @override
  String get calendarsNone => 'Nessun calendario su questo dispositivo';

  @override
  String get calendarsPick => 'Calendari da mostrare';

  @override
  String get exportDescription =>
      'Un file .txt con gli obiettivi e le attività del mese. Salvalo o invialo dal menu di condivisione.';

  @override
  String exportButton(String month) {
    return 'Esporta $month';
  }

  @override
  String get exportEmpty => 'Nessun dato registrato in questo mese';

  @override
  String get exportFailed => 'Esportazione non riuscita';

  @override
  String get exportPreview => 'Anteprima';

  @override
  String reportTitle(String month) {
    return 'Yoo · $month';
  }

  @override
  String reportExportedOn(String date) {
    return 'Esportato il $date';
  }

  @override
  String get reportGoals => 'OBIETTIVI';

  @override
  String get reportNoGoals => 'Nessun obiettivo';

  @override
  String get reportActivities => 'ATTIVITÀ';

  @override
  String get reportNoActivities => 'Nessuna attività';

  @override
  String reportTotal(int done, int total) {
    return 'Completate: $done su $total';
  }

  @override
  String get themePresets => 'Temi';

  @override
  String get presetPaper => 'Carta';

  @override
  String get presetMist => 'Nebbia';

  @override
  String get presetSage => 'Salvia';

  @override
  String get presetNight => 'Notte';

  @override
  String get presetInk => 'Inchiostro';

  @override
  String get themeColors => 'Colori';

  @override
  String get colorText => 'Testo';

  @override
  String get colorPage => 'Pagine';

  @override
  String get colorSurface => 'Intestazioni e pannelli';

  @override
  String get colorCards => 'Card';

  @override
  String get colorBar => 'Barra di navigazione';

  @override
  String get colorAccent => 'Pulsanti';

  @override
  String get colorNotification => 'Notifiche';

  @override
  String get colorNotificationHint => 'Solo Android';

  @override
  String get colorDefault => 'Predefinito';

  @override
  String get themeCardStyle => 'Stile delle card';

  @override
  String get cardStyleStandard => 'Standard';

  @override
  String get cardStyleStandardHint => 'Bordo intero e ombra leggera';

  @override
  String get cardStyleShadow => 'Ombra colorata';

  @override
  String get cardStyleShadowHint =>
      'Niente bordo: il colore resta sul pulsante e in un\'ombra leggera';

  @override
  String get cardStyleHalf => 'Mezzo bordo';

  @override
  String get cardStyleHalfHint => 'Bordo solo nella metà bassa, sfumato verso l\'alto';

  @override
  String get cardStyleButton => 'Solo pulsante';

  @override
  String get cardStyleButtonHint => 'Niente bordo: colorato solo il pulsante, ombra leggerissima';

  @override
  String get cardStylePaper => 'Taccuino';

  @override
  String get cardStylePaperHint =>
      'Le attività sono righe di un blocco note, con un quadratino da spuntare a sinistra';

  @override
  String get themeActivityText => 'Testo delle attività';

  @override
  String themeActivityTextHint(String size) {
    return '$size · nomi, dettagli e sotto attività, anche nel widget. L\'anteprima in alto si aggiorna subito.';
  }

  @override
  String get themeFont => 'Carattere';

  @override
  String get fontSystem => 'Sistema';

  @override
  String get fontSample => 'Un piccolo passo ogni giorno';

  @override
  String get appIcon => 'Icona dell\'app';

  @override
  String get appIconHint => 'Le icone definitive sono in arrivo: queste sono anteprime.';

  @override
  String get appIconClassic => 'Classica';

  @override
  String get appIconLight => 'Chiara';

  @override
  String get appIconDark => 'Scura';

  @override
  String get appIconOcean => 'Oceano';

  @override
  String get appIconForest => 'Foresta';

  @override
  String get appIconSunset => 'Tramonto';

  @override
  String get themeReset => 'Ripristina predefiniti';

  @override
  String get previewActivityOne => 'Passeggiata mattutina';

  @override
  String get previewActivityTwo => 'Leggere 20 pagine';

  @override
  String get settingsAbout => 'Informazioni su Yoo';

  @override
  String get settingsAboutSubtitle => 'Licenze open source';

  @override
  String get aboutLegalese => 'Piccole attività ricorrenti, promemoria affidabili.';

  @override
  String get widgetStale => 'Apri Yoo per aggiornare';

  @override
  String get reopenTooltip => 'Segna come da fare';

  @override
  String reopenTitle(String name) {
    return 'Segnare \"$name\" come da fare?';
  }

  @override
  String get reopenBody => 'Torna nella Home e i promemoria ripartono.';

  @override
  String get reopenConfirm => 'Da fare';
}
