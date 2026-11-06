import 'pulse_result.dart';

/// Why a train stays put this pulse.
enum WaitReason {
  /// It stands at a red signal.
  redSignal,

  /// It came in on a switch arm the switch is not set to.
  switchAgainst,

  /// There is no way on from here.
  deadEnd,
}

/// Where one active train goes in the next pulse: [to] is null when it
/// stays, and [waitReason] then says why.
final class TrainMove {
  const TrainMove({
    required this.trainId,
    required this.from,
    this.to,
    this.waitReason,
  });

  final String trainId;
  final String from;
  final String? to;
  final WaitReason? waitReason;

  bool get moves => to != null;

  @override
  bool operator ==(Object other) =>
      other is TrainMove &&
      other.trainId == trainId &&
      other.from == from &&
      other.to == to &&
      other.waitReason == waitReason;

  @override
  int get hashCode => Object.hash(trainId, from, to, waitReason);

  @override
  String toString() => 'TrainMove($trainId $from→$to)';
}

/// What the next pulse would do, worked out without playing it: every
/// active train's intent, the conflict that would reject the pulse, and
/// the trains it would deliver (docs/GAME_DESIGN_V2.md §3.2/5).
final class PulseForecast {
  PulseForecast({
    required List<TrainMove> moves,
    this.conflict,
    Set<String> delivers = const {},
  }) : moves = List.unmodifiable(moves),
       delivers = Set.unmodifiable(delivers);

  final List<TrainMove> moves;

  /// Why the pulse would be rejected, or null when it would go through.
  final PulseFailed? conflict;

  /// Trains that would reach their own goal (empty when [conflict] is set).
  final Set<String> delivers;

  bool get ok => conflict == null;

  TrainMove? moveOf(String trainId) {
    for (final move in moves) {
      if (move.trainId == trainId) return move;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is PulseForecast &&
      _listEquals(other.moves, moves) &&
      other.conflict?.toString() == conflict?.toString() &&
      other.delivers.length == delivers.length &&
      other.delivers.containsAll(delivers);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(moves), conflict?.toString(), delivers.length);
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
