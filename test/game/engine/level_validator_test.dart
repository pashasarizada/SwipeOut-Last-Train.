import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/cell.dart';
import 'package:swipeout_last_train/game/domain/direction.dart';
import 'package:swipeout_last_train/game/domain/grid_pos.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/train.dart';
import 'package:swipeout_last_train/game/domain/train_color.dart';
import 'package:swipeout_last_train/game/engine/level_validator.dart';

import '../../support/level_builders.dart';

Set<LevelIssueCode> _codes(LevelDefinition level) =>
    const LevelValidator().validate(level).map((i) => i.code).toSet();

LevelDefinition _lineWith({
  Map<GridPos, Cell> cells = const {},
  List<Train>? trains,
  int width = 5,
}) {
  final base = lineLevel();
  return buildLevel(
    width: width,
    cells: {...base.cells, ...cells},
    trains: trains ?? base.initialTrains,
    optimalMoves: base.optimalMoves,
  );
}

void main() {
  test('tutorial fixtures are valid', () {
    for (final level in [lineLevel(), switchLevel(), queueLevel()]) {
      expect(const LevelValidator().validate(level), isEmpty, reason: level.id);
    }
  });

  test('board size outside 5..7', () {
    expect(_codes(_lineWith(width: 4)), contains(LevelIssueCode.invalidSize));
  });

  test('no trains', () {
    expect(_codes(_lineWith(trains: [])), contains(LevelIssueCode.noTrains));
  });

  test('train colour without a station', () {
    final trains = [
      ...lineLevel().initialTrains,
      train('g1', TrainColor.green, 1, 2),
    ];
    expect(
      _codes(_lineWith(trains: trains)),
      contains(LevelIssueCode.missingStation),
    );
  });

  test('two trains on one cell', () {
    final trains = [
      train('r1', TrainColor.red, 0, 2),
      train('r2', TrainColor.red, 0, 2),
    ];
    expect(
      _codes(_lineWith(trains: trains)),
      contains(LevelIssueCode.duplicateTrainPosition),
    );
  });

  test('train outside the board', () {
    final trains = [train('r1', TrainColor.red, 9, 9)];
    expect(
      _codes(_lineWith(trains: trains)),
      contains(LevelIssueCode.trainOutOfBounds),
    );
  });

  test('train not standing on track', () {
    final trains = [train('r1', TrainColor.red, 4, 4)];
    expect(
      _codes(_lineWith(trains: trains)),
      contains(LevelIssueCode.trainNotOnTrack),
    );
  });

  test('straight track with bent ports', () {
    final bent = {
      const GridPos(1, 2): const TrackCell(TrackKind.straight, {
        Direction.west,
        Direction.north,
      }),
    };
    expect(
      _codes(_lineWith(cells: bent)),
      contains(LevelIssueCode.invalidTrackShape),
    );
  });

  test('switch with a repeated direction', () {
    final cells = {
      const GridPos(2, 2): const SwitchCell(
        common: Direction.west,
        branchA: Direction.west,
        branchB: Direction.east,
      ),
    };
    expect(
      _codes(_lineWith(cells: cells)),
      contains(LevelIssueCode.invalidSwitch),
    );
  });

  test('port pointing at a cell without the opposite port', () {
    final cells = {const GridPos(1, 2): track('NS')};
    expect(
      _codes(_lineWith(cells: cells)),
      contains(LevelIssueCode.portMismatch),
    );
  });

  test('port pointing off the board', () {
    final cells = {const GridPos(0, 2): track('WE')};
    expect(
      _codes(_lineWith(cells: cells)),
      contains(LevelIssueCode.portMismatch),
    );
  });

  test('structurally valid deadlock is unsolvable', () {
    final level = buildLevel(
      cells: {
        const GridPos(0, 2): station(TrainColor.blue, 'E'),
        const GridPos(1, 2): track('WE'),
        const GridPos(2, 2): track('WE'),
        const GridPos(3, 2): station(TrainColor.red, 'W'),
      },
      trains: [
        train('r1', TrainColor.red, 1, 2),
        train('b1', TrainColor.blue, 2, 2),
      ],
    );
    expect(_codes(level), {LevelIssueCode.unsolvable});
  });

  test('declared optimum differs from the solver', () {
    final base = queueLevel();
    final level = buildLevel(
      cells: base.cells,
      trains: base.initialTrains,
      switches: base.initialSwitches,
      optimalMoves: 7,
    );
    final issues = const LevelValidator().validate(level);

    expect(issues.single.code, LevelIssueCode.optimalMismatch);
    expect(issues.single.detail, contains('8'));
  });
}
