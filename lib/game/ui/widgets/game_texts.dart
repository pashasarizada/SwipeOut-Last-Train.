import '../../../l10n/generated/app_localizations.dart';
import '../../domain/move_result.dart';

/// Single place that maps game data to localized copy (DRY).
extension GameTexts on AppLocalizations {
  /// `LEVEL 01` style label shared by the HUD and the level list.
  String levelTitle(int number) =>
      levelLabel(number.toString().padLeft(2, '0'));

  String? tutorialText(String? key) => switch (key) {
    'tutorialSelectSwipe' => tutorialSelectSwipe,
    'tutorialSwitch' => tutorialSwitch,
    'tutorialOrder' => tutorialOrder,
    _ => null,
  };

  /// Null when the rejection needs no explanation to the player.
  String? blockedMessage(RejectReason reason) => switch (reason) {
    RejectReason.noExit || RejectReason.noEntry => blockedNoTrack,
    RejectReason.occupied => blockedOccupied,
    RejectReason.wrongStation => blockedWrongStation,
    RejectReason.switchOccupied => blockedSwitchOccupied,
    RejectReason.unknownTrain ||
    RejectReason.trainDelivered ||
    RejectReason.notASwitch => null,
  };
}
