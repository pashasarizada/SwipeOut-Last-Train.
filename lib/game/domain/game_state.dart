import 'signal_aspect.dart';
import 'switch_def.dart';
import 'train_state.dart';

/// Immutable dynamic state after a whole number of pulses.
final class GameState {
  GameState({
    required List<TrainState> trains,
    required Map<String, SwitchBranch> switches,
    required Map<String, SignalAspect> signals,
    this.pulse = 0,
  }) : trains = List<TrainState>.unmodifiable(
         <TrainState>[...trains]..sort((a, b) => a.id.compareTo(b.id)),
       ),
       switches = Map<String, SwitchBranch>.unmodifiable(switches),
       signals = Map<String, SignalAspect>.unmodifiable(signals);

  /// Sorted by id so equal states compare equal regardless of input order.
  final List<TrainState> trains;
  final Map<String, SwitchBranch> switches;
  final Map<String, SignalAspect> signals;
  final int pulse;

  /// Identity without the pulse counter; used by the solver's visited set.
  late final String searchKey = _buildSearchKey();

  TrainState? trainById(String id) {
    for (final t in trains) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// The undelivered train standing on [nodeId], if any.
  TrainState? trainAt(String nodeId) {
    for (final t in trains) {
      if (!t.delivered && t.nodeId == nodeId) return t;
    }
    return null;
  }

  Iterable<TrainState> get activeTrains => trains.where((t) => !t.delivered);

  bool get allDelivered => trains.every((t) => t.delivered);

  GameState withTrain(TrainState updated) => copyWith(
    trains: [for (final t in trains) t.id == updated.id ? updated : t],
  );

  GameState copyWith({
    List<TrainState>? trains,
    Map<String, SwitchBranch>? switches,
    Map<String, SignalAspect>? signals,
    int? pulse,
  }) => GameState(
    trains: trains ?? this.trains,
    switches: switches ?? this.switches,
    signals: signals ?? this.signals,
    pulse: pulse ?? this.pulse,
  );

  String _buildSearchKey() {
    String sorted<T extends Enum>(Map<String, T> map) =>
        (map.keys.toList()..sort()).map((k) => '$k:${map[k]!.name}').join(',');
    final trainPart = trains.map((t) => t.key).join(';');
    return '$trainPart|${sorted(switches)}|${sorted(signals)}';
  }

  @override
  bool operator ==(Object other) =>
      other is GameState &&
      other.pulse == pulse &&
      other.searchKey == searchKey;

  @override
  int get hashCode => Object.hash(searchKey, pulse);

  @override
  String toString() => 'GameState(#$pulse $searchKey)';
}
