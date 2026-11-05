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
  int number = 1,
  int width = 5,
  int height = 5,
  required Map<GridPos, Cell> cells,
  required List<Train> trains,
  Map<GridPos, SwitchBranch> switches = const {},
  int optimalMoves = 0,
}) => LevelDefinition(
  id: id,
  number: number,
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
  number: 2,
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
  number: 3,
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

/// 7x7 board for small-screen layout tests: blue must clear the main line.
LevelDefinition bigLevel7x7() => buildLevel(
  id: 'big',
  number: 4,
  width: 7,
  height: 7,
  cells: {
    const GridPos(0, 3): track('E'),
    const GridPos(1, 3): track('WE'),
    const GridPos(2, 3): track('WE'),
    const GridPos(3, 3): _junction,
    const GridPos(4, 3): track('WE'),
    const GridPos(5, 3): track('WE'),
    const GridPos(6, 3): station(TrainColor.blue, 'W'),
    const GridPos(3, 4): track('NS'),
    const GridPos(3, 5): track('NS'),
    const GridPos(3, 6): station(TrainColor.red, 'N'),
  },
  trains: [
    train('r1', TrainColor.red, 0, 3),
    train('b1', TrainColor.blue, 1, 3),
  ],
  switches: {const GridPos(3, 3): SwitchBranch.a},
  optimalMoves: 12,
);
