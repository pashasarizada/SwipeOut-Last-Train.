import 'package:swipeout_last_train/game/domain/cell.dart';
import 'package:swipeout_last_train/game/domain/direction.dart';
import 'package:swipeout_last_train/game/domain/grid_pos.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/train.dart';
import 'package:swipeout_last_train/game/domain/train_color.dart';

Set<Direction> _ports(String codes) => {
  for (final code in codes.split(''))
    Direction.values.firstWhere((d) => d.code == code),
};

/// "WE" → straight, "NE" → corner, single letter → depot.
TrackCell track(String ports) {
  final set = _ports(ports);
  if (set.length == 1) return TrackCell(TrackKind.depot, set);
  final isStraight = set.contains(set.first.opposite);
  return TrackCell(isStraight ? TrackKind.straight : TrackKind.corner, set);
}

StationCell station(TrainColor color, String ports) =>
    StationCell(color, _ports(ports));

Train train(String id, TrainColor color, int x, int y) =>
    Train(id: id, color: color, position: GridPos(x, y));

LevelDefinition buildLevel({
  String id = 'test',
  int width = 5,
  int height = 5,
  required Map<GridPos, Cell> cells,
  required List<Train> trains,
  Map<GridPos, SwitchBranch> switches = const {},
  int optimalMoves = 0,
}) => LevelDefinition(
  id: id,
  number: 1,
  width: width,
  height: height,
  cells: cells,
  initialTrains: trains,
  initialSwitches: switches,
  optimalMoves: optimalMoves,
);

const _junction = SwitchCell(
  common: Direction.west,
  branchA: Direction.east,
  branchB: Direction.south,
);

/// Level 1 shape: one red train, straight line to a red station.
LevelDefinition lineLevel() => buildLevel(
  id: 'line',
  cells: {
    const GridPos(0, 2): track('E'),
    const GridPos(1, 2): track('WE'),
    const GridPos(2, 2): track('WE'),
    const GridPos(3, 2): track('WE'),
    const GridPos(4, 2): station(TrainColor.red, 'W'),
  },
  trains: [train('r1', TrainColor.red, 0, 2)],
  optimalMoves: 4,
);

Map<GridPos, Cell> _junctionCells({
  required TrainColor eastStation,
  required TrainColor southStation,
}) => {
  const GridPos(0, 2): track('E'),
  const GridPos(1, 2): track('WE'),
  const GridPos(2, 2): _junction,
  const GridPos(3, 2): track('WE'),
  const GridPos(4, 2): station(eastStation, 'W'),
  const GridPos(2, 3): track('NS'),
  const GridPos(2, 4): station(southStation, 'N'),
};

/// Level 2 shape: one switch, initially routed to the wrong (blue) station.
LevelDefinition switchLevel() => buildLevel(
  id: 'switch',
  cells: _junctionCells(
    eastStation: TrainColor.red,
    southStation: TrainColor.blue,
  ),
  trains: [train('r1', TrainColor.red, 0, 2)],
  switches: {const GridPos(2, 2): SwitchBranch.b},
  optimalMoves: 5,
);

/// Level 3 shape: blue train blocks red; blue must clear the line first.
LevelDefinition queueLevel() => buildLevel(
  id: 'queue',
  cells: _junctionCells(
    eastStation: TrainColor.blue,
    southStation: TrainColor.red,
  ),
  trains: [
    train('r1', TrainColor.red, 0, 2),
    train('b1', TrainColor.blue, 1, 2),
  ],
  switches: {const GridPos(2, 2): SwitchBranch.a},
  optimalMoves: 8,
);
