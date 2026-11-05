// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SwipeOut: Last Train';

  @override
  String get brandLastTrain => 'LAST TRAIN';

  @override
  String get homeHeadline => 'THE LAST SERVICE IS LEAVING';

  @override
  String get continueGame => 'CONTINUE';

  @override
  String get chooseCity => 'CHOOSE CITY';

  @override
  String get fictionalNotice =>
      'Fictional metro puzzles inspired by real cities.';

  @override
  String get nightmareNetwork => 'NIGHTMARE NETWORK';

  @override
  String get cityAnkara => 'ANKARA';

  @override
  String get cityBaku => 'BAKU';

  @override
  String get cityParis => 'PARIS';

  @override
  String get cityLondon => 'LONDON';

  @override
  String get cityMoscow => 'MOSCOW';

  @override
  String pulseCounter(int current, int max) {
    return '$current/$max PULSE';
  }

  @override
  String trainsDelivered(int done, int total) {
    return '$done/$total TRAINS';
  }

  @override
  String controlsLeft(int left) {
    return 'Control: $left/1';
  }

  @override
  String get advance => '▶  ADVANCE 1 MINUTE';

  @override
  String get cancel => 'Cancel';

  @override
  String get undo => 'UNDO';

  @override
  String get restart => 'RESTART';

  @override
  String pendingSwitch(String node) {
    return 'Switch $node';
  }

  @override
  String pendingSignal(String node) {
    return 'Signal $node';
  }

  @override
  String get levelComplete => 'LINE CLEARED';

  @override
  String pulsesUsed(int count) {
    return '$count pulses';
  }

  @override
  String get levelLost => 'NO MINUTES LEFT';

  @override
  String get levelJammed => 'THE LINE IS JAMMED';

  @override
  String get playAgain => 'PLAY AGAIN';

  @override
  String get next => 'NEXT';

  @override
  String get backToCity => 'BACK TO CITY';

  @override
  String get failCollision => 'Two trains met at the same stop.';

  @override
  String get failHeadOn => 'Head-on! Two trains on one track.';

  @override
  String get failBlocked => 'A train ran into a waiting one.';

  @override
  String get failWrongGoal => 'Wrong line: that stop belongs to another train.';

  @override
  String get failOutOfPulses => 'No minutes left.';

  @override
  String get metroPassport => 'METRO PASSPORT';

  @override
  String get stampEarned => 'Stamp earned!';

  @override
  String stampedOn(String date) {
    return 'Stamped $date';
  }

  @override
  String get nightDispatcher => 'NIGHT DISPATCHER';

  @override
  String get nightDispatcherBody =>
      'All five cities stamped. The night network is yours.';

  @override
  String cityProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String get greetingAnkara => 'Hoş geldin, başkent!';

  @override
  String get greetingBaku => 'Xoş gəlmisən!';

  @override
  String get greetingParis => 'Bienvenue !';

  @override
  String get greetingLondon => 'Welcome aboard!';

  @override
  String get greetingMoscow => 'Добро пожаловать!';

  @override
  String get board => 'BOARD';

  @override
  String get openPassport => 'OPEN PASSPORT';

  @override
  String get lineUnderConstruction => 'LINE UNDER CONSTRUCTION';

  @override
  String get homeBoardLine => 'LAST SERVICE 23:59';

  @override
  String parLabel(int par) {
    return 'PAR $par';
  }

  @override
  String bestLabel(int pulses) {
    return 'BEST $pulses';
  }
}
