import 'cell.dart';
import 'grid_pos.dart';
import 'train.dart';

/// Immutable dynamic state of a level: train positions and switch branches.
final class BoardState {
  BoardState({
    required List<Train> trains,
    required Map<GridPos, SwitchBranch> switches,
  }) : trains = List<Train>.unmodifiable(
         <Train>[...trains]..sort((a, b) => a.id.compareTo(b.id)),
       ),
       switches = Map<GridPos, SwitchBranch>.unmodifiable(switches);

  /// Sorted by id so equal states compare equal regardless of input order.
  final List<Train> trains;
  final Map<GridPos, SwitchBranch> switches;

  /// Canonical identity used for equality and by the solver's visited set.
  late final String key = _buildKey();

  Train? trainById(String id) {
    for (final train in trains) {
      if (train.id == id) return train;
    }
    return null;
  }

  /// The undelivered train standing on [pos], if any.
  Train? trainAt(GridPos pos) {
    for (final train in trains) {
      if (!train.delivered && train.position == pos) return train;
    }
    return null;
  }

  /// Current branch of the switch at [pos]; unset switches default to `a`.
  SwitchBranch branchAt(GridPos pos) => switches[pos] ?? SwitchBranch.a;

  bool get allDelivered => trains.every((t) => t.delivered);

  BoardState withTrain(Train updated) => BoardState(
    trains: [for (final t in trains) t.id == updated.id ? updated : t],
    switches: switches,
  );

  BoardState withSwitch(GridPos pos, SwitchBranch branch) =>
      BoardState(trains: trains, switches: {...switches, pos: branch});

  String _buildKey() {
    final trainPart = trains
        .map((t) => '${t.id}@${t.delivered ? 'D' : t.position}')
        .join(';');
    final switchKeys = switches.keys.toList()
      ..sort((a, b) => a.y != b.y ? a.y - b.y : a.x - b.x);
    final switchPart = switchKeys
        .map((p) => '$p:${switches[p]!.name}')
        .join(';');
    return '$trainPart|$switchPart';
  }

  @override
  bool operator ==(Object other) => other is BoardState && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'BoardState($key)';
}
