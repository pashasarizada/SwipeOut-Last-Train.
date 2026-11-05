import 'city.dart';
import 'control_action.dart';
import 'edge.dart';
import 'game_state.dart';
import 'localized_text.dart';
import 'node.dart';
import 'signal_aspect.dart';
import 'switch_def.dart';
import 'train_def.dart';
import 'train_state.dart';

/// Static description of one puzzle as authored in `assets/levels/*.json`.
/// All collections are copied and frozen.
final class LevelDefinition {
  LevelDefinition({
    required this.id,
    required this.city,
    required this.number,
    required this.title,
    required this.maxPulses,
    required this.parPulses,
    this.tutorial = false,
    required Map<String, Node> nodes,
    required Map<String, Edge> edges,
    Map<String, SwitchDef> switches = const {},
    Map<String, SwitchBranch> initialSwitches = const {},
    Map<String, SignalAspect> initialSignals = const {},
    required List<TrainDef> trains,
    List<LocalizedText> tutorialSteps = const [],
    List<ControlAction?> solution = const [],
  }) : nodes = Map.unmodifiable(nodes),
       edges = Map.unmodifiable(edges),
       switches = Map.unmodifiable(switches),
       initialSwitches = Map.unmodifiable(initialSwitches),
       initialSignals = Map.unmodifiable(initialSignals),
       trains = List.unmodifiable(trains),
       tutorialSteps = List.unmodifiable(tutorialSteps),
       solution = List.unmodifiable(solution);

  final String id;
  final CityId city;
  final int number;
  final LocalizedText title;
  final int maxPulses;
  final int parPulses;

  /// Tutorial levels show success without star pressure.
  final bool tutorial;
  final Map<String, Node> nodes;
  final Map<String, Edge> edges;
  final Map<String, SwitchDef> switches;
  final Map<String, SwitchBranch> initialSwitches;
  final Map<String, SignalAspect> initialSignals;
  final List<TrainDef> trains;
  final List<LocalizedText> tutorialSteps;

  /// A known solution, one entry per pulse (`null` = wait). Replayed by tests.
  final List<ControlAction?> solution;

  late final Map<String, List<Edge>> _adjacency = {
    for (final id in nodes.keys)
      id: List.unmodifiable(edges.values.where((e) => e.touches(id))),
  };

  List<Edge> edgesOf(String nodeId) => _adjacency[nodeId] ?? const [];

  TrainDef? trainDef(String id) {
    for (final t in trains) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Every switch and signal is explicit, so equal boards have equal keys.
  late final GameState initialState = GameState(
    trains: [for (final t in trains) TrainState(id: t.id, nodeId: t.startNode)],
    switches: {
      for (final id in switches.keys) id: initialSwitches[id] ?? SwitchBranch.a,
    },
    signals: {
      for (final n in nodes.values)
        if (n.kind == NodeKind.signal)
          n.id: initialSignals[n.id] ?? SignalAspect.red,
    },
  );
}
