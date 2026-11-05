import '../domain/city.dart';
import '../domain/edge.dart';
import '../domain/level_definition.dart';
import '../domain/localized_text.dart';
import '../domain/node.dart';
import '../domain/norm_point.dart';
import '../domain/signal_aspect.dart';
import '../domain/switch_def.dart';
import '../domain/train_def.dart';
import 'action_codec.dart';
import 'json_reader.dart';

/// Decodes the level format documented in `docs/LEVEL_FORMAT.md`.
/// Checks structure only; game rules are `LevelValidator`'s job.
final class LevelJsonCodec {
  const LevelJsonCodec();

  static const Map<String, NodeKind> _kinds = {
    'depot': NodeKind.depot,
    'track': NodeKind.track,
    'switch': NodeKind.junction,
    'signal': NodeKind.signal,
    'goal': NodeKind.goal,
    'terminal': NodeKind.terminal,
  };

  LevelDefinition decode(Map<String, Object?> json) {
    final id = json['id'];
    final r = JsonReader(id is String ? id : '?');
    final switches = r.objects(json, 'switches', required: false);
    final signals = r.objects(json, 'signals', required: false);

    return LevelDefinition(
      id: r.field<String>(json, 'id'),
      city: r.byName(CityId.values, r.field<String>(json, 'city'), 'city'),
      number: r.field<int>(json, 'number'),
      title: _text(r, r.object(json['title'], '"title"')),
      maxPulses: r.field<int>(json, 'maxPulses'),
      parPulses: r.field<int>(json, 'parPulses'),
      tutorial: r.optional<bool>(json, 'tutorial') ?? false,
      nodes: _unique(r, 'node', [
        for (final n in r.objects(json, 'nodes')) _node(r, n),
      ], (n) => n.id),
      edges: _unique(r, 'edge', [
        for (final e in r.objects(json, 'edges'))
          Edge(
            id: r.field<String>(e, 'id'),
            a: r.field<String>(e, 'a'),
            b: r.field<String>(e, 'b'),
          ),
      ], (e) => e.id),
      switches: _unique(r, 'switch', [
        for (final s in switches) _switch(r, s),
      ], (s) => s.nodeId),
      initialSwitches: {
        for (final s in switches)
          r.field<String>(s, 'nodeId'): _branch(
            r,
            r.optional<String>(s, 'selectedBranch') ?? 'A',
          ),
      },
      initialSignals: {
        for (final s in signals)
          r.field<String>(s, 'nodeId'): r.byName(
            SignalAspect.values,
            r.optional<String>(s, 'initial') ?? 'red',
            'signal aspect',
          ),
      },
      trains: [for (final t in r.objects(json, 'trains')) _train(r, t)],
      tutorialSteps: [
        for (final t in r.objects(json, 'tutorialSteps', required: false))
          _text(r, t),
      ],
      solution: [
        for (final step
            in r.optional<List<Object?>>(json, 'solution') ?? const <Object?>[])
          ActionCodec.decode(
            step is String ? step : r.fail('solution steps must be strings'),
            levelId: r.levelId,
          ),
      ],
    );
  }

  Node _node(JsonReader r, Map<String, Object?> json) {
    final kind = r.field<String>(json, 'kind');
    return Node(
      id: r.field<String>(json, 'id'),
      kind: _kinds[kind] ?? r.fail('unknown node kind "$kind"'),
      position: NormPoint(r.number(json, 'x'), r.number(json, 'y')),
      label: r.optional<String>(json, 'label'),
    );
  }

  SwitchDef _switch(JsonReader r, Map<String, Object?> json) => SwitchDef(
    nodeId: r.field<String>(json, 'nodeId'),
    trunkEdge: r.field<String>(json, 'trunkEdge'),
    branchAEdge: r.field<String>(json, 'branchAEdge'),
    branchBEdge: r.field<String>(json, 'branchBEdge'),
  );

  SwitchBranch _branch(JsonReader r, String raw) => switch (raw) {
    'A' => SwitchBranch.a,
    'B' => SwitchBranch.b,
    _ => r.fail('"selectedBranch" must be "A" or "B"'),
  };

  TrainDef _train(JsonReader r, Map<String, Object?> json) => TrainDef(
    id: r.field<String>(json, 'id'),
    startNode: r.field<String>(json, 'startNode'),
    goalNode: r.field<String>(json, 'goalNode'),
    symbol: r.byName(
      TrainSymbol.values,
      r.field<String>(json, 'symbol'),
      'symbol',
    ),
    style: r.byName(TrainStyle.values, r.field<String>(json, 'style'), 'style'),
  );

  LocalizedText _text(JsonReader r, Map<String, Object?> json) => LocalizedText(
    tr: r.field<String>(json, 'tr'),
    en: r.field<String>(json, 'en'),
  );

  /// Maps by id; a repeated id cannot be represented, so it is a format error.
  Map<String, T> _unique<T>(
    JsonReader r,
    String what,
    List<T> items,
    String Function(T) idOf,
  ) {
    final map = <String, T>{};
    for (final item in items) {
      if (map.containsKey(idOf(item))) {
        r.fail('duplicate $what id "${idOf(item)}"');
      }
      map[idOf(item)] = item;
    }
    return map;
  }
}
