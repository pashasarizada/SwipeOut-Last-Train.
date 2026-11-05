import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SwipeOut: Last Train'**
  String get appTitle;

  /// No description provided for @brandLastTrain.
  ///
  /// In en, this message translates to:
  /// **'LAST TRAIN'**
  String get brandLastTrain;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'THE LAST SERVICE IS LEAVING'**
  String get homeHeadline;

  /// No description provided for @continueGame.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueGame;

  /// No description provided for @chooseCity.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE CITY'**
  String get chooseCity;

  /// No description provided for @fictionalNotice.
  ///
  /// In en, this message translates to:
  /// **'Fictional metro puzzles inspired by real cities.'**
  String get fictionalNotice;

  /// No description provided for @nightmareNetwork.
  ///
  /// In en, this message translates to:
  /// **'NIGHTMARE NETWORK'**
  String get nightmareNetwork;

  /// No description provided for @cityAnkara.
  ///
  /// In en, this message translates to:
  /// **'ANKARA'**
  String get cityAnkara;

  /// No description provided for @cityBaku.
  ///
  /// In en, this message translates to:
  /// **'BAKU'**
  String get cityBaku;

  /// No description provided for @cityParis.
  ///
  /// In en, this message translates to:
  /// **'PARIS'**
  String get cityParis;

  /// No description provided for @cityLondon.
  ///
  /// In en, this message translates to:
  /// **'LONDON'**
  String get cityLondon;

  /// No description provided for @cityMoscow.
  ///
  /// In en, this message translates to:
  /// **'MOSCOW'**
  String get cityMoscow;

  /// No description provided for @pulseCounter.
  ///
  /// In en, this message translates to:
  /// **'{current}/{max} PULSE'**
  String pulseCounter(int current, int max);

  /// No description provided for @trainsDelivered.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} TRAINS'**
  String trainsDelivered(int done, int total);

  /// No description provided for @controlsLeft.
  ///
  /// In en, this message translates to:
  /// **'Control: {left}/1'**
  String controlsLeft(int left);

  /// No description provided for @advance.
  ///
  /// In en, this message translates to:
  /// **'▶  ADVANCE 1 MINUTE'**
  String get advance;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'RESTART'**
  String get restart;

  /// No description provided for @pendingSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch {node}'**
  String pendingSwitch(String node);

  /// No description provided for @pendingSignal.
  ///
  /// In en, this message translates to:
  /// **'Signal {node}'**
  String pendingSignal(String node);

  /// No description provided for @levelComplete.
  ///
  /// In en, this message translates to:
  /// **'LINE CLEARED'**
  String get levelComplete;

  /// No description provided for @pulsesUsed.
  ///
  /// In en, this message translates to:
  /// **'{count} pulses'**
  String pulsesUsed(int count);

  /// No description provided for @levelLost.
  ///
  /// In en, this message translates to:
  /// **'NO MINUTES LEFT'**
  String get levelLost;

  /// No description provided for @levelJammed.
  ///
  /// In en, this message translates to:
  /// **'THE LINE IS JAMMED'**
  String get levelJammed;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'PLAY AGAIN'**
  String get playAgain;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// No description provided for @backToCity.
  ///
  /// In en, this message translates to:
  /// **'BACK TO CITY'**
  String get backToCity;

  /// No description provided for @failCollision.
  ///
  /// In en, this message translates to:
  /// **'Two trains met at the same stop.'**
  String get failCollision;

  /// No description provided for @failHeadOn.
  ///
  /// In en, this message translates to:
  /// **'Head-on! Two trains on one track.'**
  String get failHeadOn;

  /// No description provided for @failBlocked.
  ///
  /// In en, this message translates to:
  /// **'A train ran into a waiting one.'**
  String get failBlocked;

  /// No description provided for @failWrongGoal.
  ///
  /// In en, this message translates to:
  /// **'Wrong line: that stop belongs to another train.'**
  String get failWrongGoal;

  /// No description provided for @failOutOfPulses.
  ///
  /// In en, this message translates to:
  /// **'No minutes left.'**
  String get failOutOfPulses;

  /// No description provided for @metroPassport.
  ///
  /// In en, this message translates to:
  /// **'METRO PASSPORT'**
  String get metroPassport;

  /// No description provided for @stampEarned.
  ///
  /// In en, this message translates to:
  /// **'Stamp earned!'**
  String get stampEarned;

  /// No description provided for @stampedOn.
  ///
  /// In en, this message translates to:
  /// **'Stamped {date}'**
  String stampedOn(String date);

  /// No description provided for @nightDispatcher.
  ///
  /// In en, this message translates to:
  /// **'NIGHT DISPATCHER'**
  String get nightDispatcher;

  /// No description provided for @nightDispatcherBody.
  ///
  /// In en, this message translates to:
  /// **'All five cities stamped. The night network is yours.'**
  String get nightDispatcherBody;

  /// No description provided for @cityProgress.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total}'**
  String cityProgress(int done, int total);

  /// No description provided for @greetingAnkara.
  ///
  /// In en, this message translates to:
  /// **'Hoş geldin, başkent!'**
  String get greetingAnkara;

  /// No description provided for @greetingBaku.
  ///
  /// In en, this message translates to:
  /// **'Xoş gəlmisən!'**
  String get greetingBaku;

  /// No description provided for @greetingParis.
  ///
  /// In en, this message translates to:
  /// **'Bienvenue !'**
  String get greetingParis;

  /// No description provided for @greetingLondon.
  ///
  /// In en, this message translates to:
  /// **'Welcome aboard!'**
  String get greetingLondon;

  /// No description provided for @greetingMoscow.
  ///
  /// In en, this message translates to:
  /// **'Добро пожаловать!'**
  String get greetingMoscow;

  /// No description provided for @board.
  ///
  /// In en, this message translates to:
  /// **'BOARD'**
  String get board;

  /// No description provided for @openPassport.
  ///
  /// In en, this message translates to:
  /// **'OPEN PASSPORT'**
  String get openPassport;

  /// No description provided for @lineUnderConstruction.
  ///
  /// In en, this message translates to:
  /// **'LINE UNDER CONSTRUCTION'**
  String get lineUnderConstruction;

  /// No description provided for @homeBoardLine.
  ///
  /// In en, this message translates to:
  /// **'LAST SERVICE 23:59'**
  String get homeBoardLine;

  /// No description provided for @parLabel.
  ///
  /// In en, this message translates to:
  /// **'PAR {par}'**
  String parLabel(int par);

  /// No description provided for @bestLabel.
  ///
  /// In en, this message translates to:
  /// **'BEST {pulses}'**
  String bestLabel(int pulses);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
