import '../../../l10n/generated/app_localizations.dart';
import '../../domain/city.dart';
import '../../domain/control_action.dart';
import '../../domain/level_definition.dart';
import '../../domain/pulse_result.dart';

/// The single place that maps game data to localized copy (DRY).
extension GameTexts on AppLocalizations {
  String cityName(CityId city) => switch (city) {
    CityId.ankara => cityAnkara,
    CityId.baku => cityBaku,
    CityId.paris => cityParis,
    CityId.london => cityLondon,
    CityId.moscow => cityMoscow,
  };

  /// The local-language welcome shown on a city's pages.
  String greeting(CityId city) => switch (city) {
    CityId.ankara => greetingAnkara,
    CityId.baku => greetingBaku,
    CityId.paris => greetingParis,
    CityId.london => greetingLondon,
    CityId.moscow => greetingMoscow,
  };

  /// The last service leaves at 23:50; every pulse is one minute.
  static String clock(int pulses) {
    final minutes = 23 * 60 + 50 + pulses;
    final h = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  /// `ANKARA 01`.
  String levelCode(LevelDefinition level) =>
      '${cityName(level.city)} ${level.number.toString().padLeft(2, '0')}';

  String pendingLabel(ControlAction action) => switch (action) {
    ToggleSwitch(:final nodeId) => pendingSwitch(nodeId),
    ToggleSignal(:final nodeId) => pendingSignal(nodeId),
  };

  /// Null for failures the UI already prevents.
  String? failureMessage(PulseFailure reason) => switch (reason) {
    PulseFailure.collision => failCollision,
    PulseFailure.headOn => failHeadOn,
    PulseFailure.blockedByStanding => failBlocked,
    PulseFailure.wrongGoal => failWrongGoal,
    PulseFailure.outOfPulses => failOutOfPulses,
    PulseFailure.alreadySolved || PulseFailure.invalidControl => null,
  };
}
