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
  String get play => 'Play';

  @override
  String get cityIstanbul => 'ISTANBUL';

  @override
  String levelLabel(String number) {
    return 'LEVEL $number';
  }

  @override
  String moves(int count) {
    return 'Moves: $count';
  }

  @override
  String get undo => 'Undo';

  @override
  String get restart => 'Restart';

  @override
  String get hint => 'Hint';

  @override
  String get levelComplete => 'Line cleared!';

  @override
  String get next => 'Next';

  @override
  String get replay => 'Replay';

  @override
  String get tutorialSelectSwipe =>
      'Tap the train, then swipe to move it one square.';

  @override
  String get tutorialSwitch =>
      'Tap the switch to change its route. Each tap is a move.';

  @override
  String get tutorialOrder =>
      'Trains can\'t pass each other. Choose who goes first.';

  @override
  String get blockedWrongStation => 'Wrong station for this train.';

  @override
  String get blockedOccupied => 'Another train is in the way.';

  @override
  String get blockedNoTrack => 'No track in that direction.';

  @override
  String get blockedSwitchOccupied => 'A train is on the switch.';

  @override
  String get selectTrainFirst => 'Tap a train first.';

  @override
  String get hintUnavailable => 'No hint available right now.';
}
