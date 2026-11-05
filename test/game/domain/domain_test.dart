import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/board_state.dart';
import 'package:swipeout_last_train/game/domain/cell.dart';
import 'package:swipeout_last_train/game/domain/direction.dart';
import 'package:swipeout_last_train/game/domain/grid_pos.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/move.dart';
import 'package:swipeout_last_train/game/domain/star_rating.dart';
import 'package:swipeout_last_train/game/domain/train.dart';
import 'package:swipeout_last_train/game/domain/train_color.dart';

void main() {
  const r1 = Train(id: 'r1', color: TrainColor.red, position: GridPos(0, 2));
  const b1 = Train(id: 'b1', color: TrainColor.blue, position: GridPos(1, 2));

  group('Direction', () {
    test('opposite pairs', () {
      expect(Direction.north.opposite, Direction.south);
      expect(Direction.south.opposite, Direction.north);
      expect(Direction.east.opposite, Direction.west);
      expect(Direction.west.opposite, Direction.east);
    });
  });

  group('GridPos', () {
    test('step moves exactly one cell', () {
      expect(const GridPos(2, 2).step(Direction.north), const GridPos(2, 1));
      expect(const GridPos(2, 2).step(Direction.east), const GridPos(3, 2));
      expect(const GridPos(2, 2).step(Direction.south), const GridPos(2, 3));
      expect(const GridPos(2, 2).step(Direction.west), const GridPos(1, 2));
    });
  });

  group('SwitchCell', () {
    const sw = SwitchCell(
      common: Direction.west,
      branchA: Direction.east,
      branchB: Direction.south,
    );

    test('portsFor opens common plus the selected branch', () {
      expect(sw.portsFor(SwitchBranch.a), {Direction.west, Direction.east});
      expect(sw.portsFor(SwitchBranch.b), {Direction.west, Direction.south});
    });

    test('branch toggles', () {
      expect(SwitchBranch.a.toggled, SwitchBranch.b);
      expect(SwitchBranch.b.toggled, SwitchBranch.a);
    });
  });

  group('BoardState', () {
    test('equality ignores input order of trains', () {
      final first = BoardState(trains: [b1, r1], switches: const {});
      final second = BoardState(trains: [r1, b1], switches: const {});

      expect(first, second);
      expect(first.key, second.key);
      expect(first.hashCode, second.hashCode);
    });

    test('key differs when a switch differs', () {
      final a = BoardState(
        trains: [r1],
        switches: {const GridPos(2, 2): SwitchBranch.a},
      );
      final b = a.withSwitch(const GridPos(2, 2), SwitchBranch.b);

      expect(a, isNot(b));
      expect(b.switches[const GridPos(2, 2)], SwitchBranch.b);
    });

    test('trainAt ignores delivered trains', () {
      final state = BoardState(
        trains: [r1.copyWith(delivered: true)],
        switches: const {},
      );

      expect(state.trainAt(r1.position), isNull);
      expect(state.allDelivered, isTrue);
    });

    test('withTrain replaces the train with the same id', () {
      final state = BoardState(trains: [r1, b1], switches: const {});
      final moved = state.withTrain(r1.copyWith(position: const GridPos(0, 3)));

      expect(moved.trainById('r1')!.position, const GridPos(0, 3));
      expect(moved.trainAt(const GridPos(0, 2)), isNull);
      expect(moved.trainAt(const GridPos(1, 2)), b1);
      expect(moved.allDelivered, isFalse);
    });
  });

  group('LevelDefinition', () {
    final level5x5 = LevelDefinition(
      id: 'test',
      number: 1,
      width: 5,
      height: 5,
      cells: {
        const GridPos(0, 0): const TrackCell(TrackKind.depot, {Direction.east}),
      },
      initialTrains: const [
        Train(id: 'r1', color: TrainColor.red, position: GridPos(0, 0)),
      ],
      initialSwitches: const {},
      optimalMoves: 0,
    );

    test('bounds and default cells', () {
      expect(level5x5.cellAt(const GridPos(0, 0)), isA<TrackCell>());
      expect(level5x5.cellAt(const GridPos(3, 3)), isA<EmptyCell>());
      expect(level5x5.cellAt(const GridPos(5, 0)), isA<BlockedCell>());
      expect(level5x5.contains(const GridPos(-1, 0)), isFalse);
      expect(level5x5.contains(const GridPos(4, 4)), isTrue);
    });

    test('initialState mirrors initial trains and switches', () {
      expect(level5x5.initialState.trains.single.id, 'r1');
      expect(level5x5.initialState.switches, isEmpty);
    });
  });

  group('Move', () {
    test('value equality', () {
      expect(
        const TrainMove('r1', Direction.east),
        const TrainMove('r1', Direction.east),
      );
      expect(
        const SwitchToggle(GridPos(2, 2)),
        const SwitchToggle(GridPos(2, 2)),
      );
      expect(
        const TrainMove('r1', Direction.east),
        isNot(const TrainMove('r1', Direction.west)),
      );
    });
  });

  group('StarRating', () {
    test('gold <= optimal+1, silver <= optimal+4, else bronze', () {
      expect(
        [4, 5, 6, 8, 9].map((m) => StarRating.forMoves(moves: m, optimal: 4)),
        [
          StarRating.gold,
          StarRating.gold,
          StarRating.silver,
          StarRating.silver,
          StarRating.bronze,
        ],
      );
      expect(StarRating.gold.stars, 3);
      expect(StarRating.bronze.stars, 1);
    });
  });
}
