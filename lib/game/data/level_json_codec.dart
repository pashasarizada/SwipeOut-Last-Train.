import '../domain/cell.dart';
import '../domain/direction.dart';
import '../domain/grid_pos.dart';
import '../domain/level_definition.dart';
import '../domain/train.dart';
import '../domain/train_color.dart';

/// Thrown when a level file is structurally malformed. Rule violations of a
/// well-formed file are reported by `LevelValidator` instead.
final class LevelFormatException implements Exception {
  const LevelFormatException(this.levelId, this.message);

  final String levelId;
  final String message;

  @override
  String toString() => 'LevelFormatException($levelId): $message';
}

/// Decodes the JSON level format documented in `docs/LEVEL_FORMAT.md`.
final class LevelJsonCodec {
  const LevelJsonCodec();

  LevelDefinition decode(Map<String, Object?> json) {
    final id = json['id'];
    final reader = _Reader(id is String ? id : '?');
    final root = reader.object(json, 'level');
    final switches = <GridPos, SwitchBranch>{};
    final cells = <GridPos, Cell>{};

    for (final raw in reader.list(root, 'cells')) {
      final cellJson = reader.object(raw, 'cell');
      final pos = reader.pos(cellJson);
      cells[pos] = reader.cell(cellJson);
      if (cells[pos] is SwitchCell) switches[pos] = reader.branch(cellJson);
    }

    return LevelDefinition(
      id: reader.string(root, 'id'),
      number: reader.integer(root, 'number'),
      width: reader.integer(root, 'width'),
      height: reader.integer(root, 'height'),
      optimalMoves: reader.integer(root, 'optimalMoves'),
      tutorialKey: reader.optionalString(root, 'tutorialKey'),
      cells: cells,
      initialSwitches: switches,
      initialTrains: [
        for (final raw in reader.list(root, 'trains'))
          reader.train(reader.object(raw, 'train')),
      ],
    );
  }
}

/// Typed field access that reports failures against one level id.
final class _Reader {
  const _Reader(this.levelId);

  final String levelId;

  Never _fail(String message) => throw LevelFormatException(levelId, message);

  T _field<T>(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is T) return value;
    _fail('"$key" must be a $T, got ${value.runtimeType}');
  }

  Map<String, Object?> object(Object? value, String what) {
    if (value is Map<String, Object?>) return value;
    _fail('$what must be a JSON object');
  }

  List<Object?> list(Map<String, Object?> json, String key) =>
      _field<List<Object?>>(json, key);

  String string(Map<String, Object?> json, String key) =>
      _field<String>(json, key);

  int integer(Map<String, Object?> json, String key) => _field<int>(json, key);

  String? optionalString(Map<String, Object?> json, String key) =>
      json[key] == null ? null : string(json, key);

  GridPos pos(Map<String, Object?> json) =>
      GridPos(integer(json, 'x'), integer(json, 'y'));

  Direction direction(String code) => Direction.values.firstWhere(
    (d) => d.code == code,
    orElse: () => _fail('unknown direction "$code"'),
  );

  Set<Direction> ports(Map<String, Object?> json, String key) =>
      string(json, key).split('').map(direction).toSet();

  TrainColor color(Map<String, Object?> json) {
    final name = string(json, 'color');
    return TrainColor.values.firstWhere(
      (c) => c.name == name,
      orElse: () => _fail('unknown colour "$name"'),
    );
  }

  Cell cell(Map<String, Object?> json) {
    final type = string(json, 'type');
    return switch (type) {
      'straight' => TrackCell(TrackKind.straight, ports(json, 'ports')),
      'corner' => TrackCell(TrackKind.corner, ports(json, 'ports')),
      'depot' => TrackCell(TrackKind.depot, ports(json, 'ports')),
      'station' => StationCell(color(json), ports(json, 'ports')),
      'blocked' => const BlockedCell(),
      'switch' => _switchCell(json),
      _ => _fail('unknown cell type "$type"'),
    };
  }

  SwitchCell _switchCell(Map<String, Object?> json) {
    final branches = string(json, 'branches');
    if (branches.length != 2) _fail('"branches" must have two directions');
    return SwitchCell(
      common: direction(string(json, 'common')),
      branchA: direction(branches[0]),
      branchB: direction(branches[1]),
    );
  }

  SwitchBranch branch(Map<String, Object?> json) {
    final selected = optionalString(json, 'selected') ?? 'a';
    return SwitchBranch.values.firstWhere(
      (b) => b.name == selected,
      orElse: () => _fail('"selected" must be "a" or "b"'),
    );
  }

  Train train(Map<String, Object?> json) =>
      Train(id: string(json, 'id'), color: color(json), position: pos(json));
}
