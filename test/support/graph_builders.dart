import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/edge.dart';
import 'package:swipeout_last_train/game/domain/game_state.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/localized_text.dart';
import 'package:swipeout_last_train/game/domain/node.dart';
import 'package:swipeout_last_train/game/domain/norm_point.dart';
import 'package:swipeout_last_train/game/domain/signal_aspect.dart';
import 'package:swipeout_last_train/game/domain/switch_def.dart';
import 'package:swipeout_last_train/game/domain/train_def.dart';
import 'package:swipeout_last_train/game/domain/train_state.dart';

Node node(String id, NodeKind kind, [double x = 0.5, double y = 0.5]) =>
    Node(id: id, kind: kind, position: NormPoint(x, y));

/// `'AB'` → edge AB between nodes A and B (single-letter node ids).
Edge edge(String id) => Edge(id: id, a: id[0], b: id[1]);

TrainDef trainDef(
  String id,
  String start,
  String goal, {
  TrainSymbol symbol = TrainSymbol.circle,
  TrainStyle style = TrainStyle.coral,
}) => TrainDef(
  id: id,
  startNode: start,
  goalNode: goal,
  symbol: symbol,
  style: style,
);

LevelDefinition buildLevel({
  String id = 'TEST-01',
  int number = 1,
  LocalizedText title = const LocalizedText(tr: 'Test', en: 'Test'),
  List<LocalizedText> tutorialSteps = const [],
  required List<Node> nodes,
  required List<String> edges,
  List<SwitchDef> switches = const [],
  Map<String, SwitchBranch> initialSwitches = const {},
  Map<String, SignalAspect> initialSignals = const {},
  required List<TrainDef> trains,
  int maxPulses = 10,
  int parPulses = 1,
  bool tutorial = false,
  List<ControlAction?> solution = const [],
}) => LevelDefinition(
  id: id,
  city: CityId.ankara,
  number: number,
  title: title,
  tutorialSteps: tutorialSteps,
  maxPulses: maxPulses,
  parPulses: parPulses,
  tutorial: tutorial,
  nodes: {for (final n in nodes) n.id: n},
  edges: {for (final e in edges.map(edge)) e.id: e},
  switches: {for (final s in switches) s.nodeId: s},
  initialSwitches: initialSwitches,
  initialSignals: initialSignals,
  trains: trains,
  solution: solution,
);

/// Places trains explicitly (for engine tests that start mid-journey).
GameState stateOf(LevelDefinition level, List<TrainState> trains) =>
    level.initialState.copyWith(trains: trains);

TrainState at(String id, String nodeId, [String? incoming]) =>
    TrainState(id: id, nodeId: nodeId, incomingEdgeId: incoming);

/// ANK-01 "İlk Sefer" from the design doc §8.
LevelDefinition ank01() => buildLevel(
  id: 'ANK-01',
  title: const LocalizedText(tr: 'İlk Sefer', en: 'First Departure'),
  tutorialSteps: const [
    LocalizedText(
      tr: 'Trenler her dakikada bir durak ilerler.',
      en: 'Trains move one stop each minute.',
    ),
    LocalizedText(
      tr: 'Makası doğru raya çevir.',
      en: 'Switch to the correct track.',
    ),
  ],
  nodes: [
    node('A', NodeKind.depot, 0.13, 0.50),
    node('B', NodeKind.junction, 0.48, 0.50),
    node('C', NodeKind.goal, 0.84, 0.25),
    node('D', NodeKind.terminal, 0.84, 0.76),
  ],
  edges: ['AB', 'BC', 'BD'],
  switches: [
    const SwitchDef(
      nodeId: 'B',
      trunkEdge: 'AB',
      branchAEdge: 'BC',
      branchBEdge: 'BD',
    ),
  ],
  initialSwitches: {'B': SwitchBranch.b},
  trains: [trainDef('red_1', 'A', 'C')],
  maxPulses: 5,
  parPulses: 2,
  tutorial: true,
  solution: const [null, ToggleSwitch('B')],
);

/// ANK-02 "Kızılay Yönü": the train arrives on the closed branch and waits.
LevelDefinition ank02() => buildLevel(
  id: 'ANK-02',
  number: 2,
  title: const LocalizedText(tr: 'Kızılay Yönü', en: 'Towards Kızılay'),
  tutorialSteps: const [
    LocalizedText(
      tr: 'Tren kapalı koldan gelirse bekler.',
      en: 'A train on a closed branch waits.',
    ),
    LocalizedText(
      tr: 'Makası treninin geldiği yöne çevir.',
      en: 'Turn the switch towards your train.',
    ),
  ],
  nodes: [
    node('A', NodeKind.depot, 0.12, 0.30),
    node('B', NodeKind.junction, 0.45, 0.50),
    node('C', NodeKind.track, 0.70, 0.50),
    node('D', NodeKind.goal, 0.90, 0.50),
    node('E', NodeKind.terminal, 0.40, 0.85),
  ],
  edges: ['AB', 'BC', 'CD', 'BE'],
  switches: [
    const SwitchDef(
      nodeId: 'B',
      trunkEdge: 'BC',
      branchAEdge: 'AB',
      branchBEdge: 'BE',
    ),
  ],
  initialSwitches: {'B': SwitchBranch.b},
  trains: [trainDef('red_1', 'A', 'D')],
  maxPulses: 6,
  parPulses: 3,
  tutorial: true,
  solution: const [ToggleSwitch('B'), null, null],
);

/// L(depot a) — M — N — R(depot b): the first pulse is fine, after it the
/// trains face each other and every pulse is a head-on crash (a jam).
LevelDefinition jamLevel() => buildLevel(
  id: 'JAM-01',
  nodes: [
    node('L', NodeKind.depot, 0.1, 0.5),
    node('M', NodeKind.track, 0.4, 0.5),
    node('N', NodeKind.track, 0.6, 0.5),
    node('R', NodeKind.depot, 0.9, 0.5),
    node('G', NodeKind.goal, 0.1, 0.9),
    node('H', NodeKind.goal, 0.9, 0.9),
  ],
  edges: const ['LM', 'MN', 'NR'],
  trains: [trainDef('a', 'L', 'G'), trainDef('b', 'R', 'H')],
);

/// Switch J points the train at the wrong goal G; turning J sends it home
/// to H. Switch K is unrelated, so choosing it still ends on the wrong line.
LevelDefinition wrongWayLevel() => buildLevel(
  id: 'WRONG-01',
  nodes: [
    node('A', NodeKind.depot, 0.1, 0.5),
    node('J', NodeKind.junction, 0.4, 0.5),
    node('G', NodeKind.goal, 0.8, 0.2),
    node('H', NodeKind.goal, 0.8, 0.8),
    node('K', NodeKind.junction, 0.4, 0.9),
    node('T', NodeKind.terminal, 0.1, 0.9),
    node('U', NodeKind.terminal, 0.6, 0.95),
    node('V', NodeKind.terminal, 0.6, 0.75),
  ],
  edges: const ['AJ', 'JG', 'JH', 'KT', 'KU', 'KV'],
  switches: [
    const SwitchDef(
      nodeId: 'J',
      trunkEdge: 'AJ',
      branchAEdge: 'JG',
      branchBEdge: 'JH',
    ),
    const SwitchDef(
      nodeId: 'K',
      trunkEdge: 'KT',
      branchAEdge: 'KU',
      branchBEdge: 'KV',
    ),
  ],
  trains: [trainDef('a', 'A', 'H')],
);
