import '../domain/cell.dart';
import '../domain/direction.dart';
import '../domain/grid_pos.dart';
import '../domain/level_definition.dart';
import 'level_solver.dart';

enum LevelIssueCode {
  invalidSize,
  noTrains,
  missingStation,
  duplicateTrainPosition,
  trainOutOfBounds,
  trainNotOnTrack,
  invalidTrackShape,
  invalidSwitch,
  portMismatch,
  unsolvable,
  optimalMismatch,
}

final class LevelIssue {
  const LevelIssue(this.code, {this.at, this.detail = ''});

  final LevelIssueCode code;
  final GridPos? at;
  final String detail;

  @override
  String toString() =>
      '${code.name}${at == null ? '' : ' @$at'}${detail.isEmpty ? '' : ': $detail'}';
}

/// Checks that a level is well-formed, solvable and declares its optimum.
/// The solver only runs on structurally valid levels.
final class LevelValidator {
  const LevelValidator({this.solver = const LevelSolver()});

  static const int minSize = 5;
  static const int maxSize = 7;

  final LevelSolver solver;

  List<LevelIssue> validate(LevelDefinition level) {
    final issues = [
      ..._sizeIssues(level),
      ..._trainIssues(level),
      for (final entry in level.cells.entries)
        ..._cellIssues(level, entry.key, entry.value),
    ];
    return issues.isEmpty ? _solverIssues(level) : issues;
  }

  Iterable<LevelIssue> _sizeIssues(LevelDefinition level) sync* {
    bool inRange(int v) => v >= minSize && v <= maxSize;
    if (!inRange(level.width) || !inRange(level.height)) {
      yield LevelIssue(
        LevelIssueCode.invalidSize,
        detail: '${level.width}x${level.height}',
      );
    }
  }

  Iterable<LevelIssue> _trainIssues(LevelDefinition level) sync* {
    final trains = level.initialTrains;
    if (trains.isEmpty) yield const LevelIssue(LevelIssueCode.noTrains);

    final stationColors = {
      for (final cell in level.cells.values)
        if (cell is StationCell) cell.color,
    };
    final seen = <GridPos>{};
    for (final train in trains) {
      final at = train.position;
      if (!stationColors.contains(train.color)) {
        yield LevelIssue(
          LevelIssueCode.missingStation,
          detail: '${train.id} (${train.color.name})',
        );
      }
      if (!seen.add(at)) {
        yield LevelIssue(LevelIssueCode.duplicateTrainPosition, at: at);
      }
      if (!level.contains(at)) {
        yield LevelIssue(LevelIssueCode.trainOutOfBounds, at: at);
      } else if (level.cellAt(at) is! TrackCell &&
          level.cellAt(at) is! SwitchCell) {
        yield LevelIssue(LevelIssueCode.trainNotOnTrack, at: at);
      }
    }
  }

  Iterable<LevelIssue> _cellIssues(
    LevelDefinition level,
    GridPos at,
    Cell cell,
  ) sync* {
    if (!_hasValidShape(cell)) {
      yield LevelIssue(LevelIssueCode.invalidTrackShape, at: at);
    }
    if (cell is SwitchCell &&
        {cell.common, cell.branchA, cell.branchB}.length != 3) {
      yield LevelIssue(LevelIssueCode.invalidSwitch, at: at);
    }
    for (final direction in _allPorts(cell)) {
      final neighbour = at.step(direction);
      final linked =
          level.contains(neighbour) &&
          _allPorts(level.cellAt(neighbour)).contains(direction.opposite);
      if (!linked) {
        yield LevelIssue(
          LevelIssueCode.portMismatch,
          at: at,
          detail: direction.code,
        );
      }
    }
  }

  List<LevelIssue> _solverIssues(LevelDefinition level) => switch (solver.solve(
    level,
  )) {
    Solved(:final moves) when moves.length != level.optimalMoves => [
      LevelIssue(
        LevelIssueCode.optimalMismatch,
        detail: 'declared ${level.optimalMoves}, solver found ${moves.length}',
      ),
    ],
    Solved() => const [],
    Unsolvable() => const [LevelIssue(LevelIssueCode.unsolvable)],
    SearchLimitReached() => const [
      LevelIssue(LevelIssueCode.unsolvable, detail: 'state limit reached'),
    ],
  };

  static bool _hasValidShape(Cell cell) {
    if (cell is StationCell) return cell.ports.isNotEmpty;
    if (cell is! TrackCell) return true;
    final ports = cell.ports;
    final isOppositePair =
        ports.length == 2 && ports.contains(ports.first.opposite);
    return switch (cell.kind) {
      TrackKind.straight => isOppositePair,
      TrackKind.corner => ports.length == 2 && !isOppositePair,
      TrackKind.depot => ports.length == 1 || ports.length == 2,
    };
  }

  /// Every port a cell can ever open (a switch counts all three directions).
  static Set<Direction> _allPorts(Cell cell) => switch (cell) {
    TrackCell(:final ports) || StationCell(:final ports) => ports,
    SwitchCell(:final common, :final branchA, :final branchB) => {
      common,
      branchA,
      branchB,
    },
    EmptyCell() || BlockedCell() => const {},
  };
}
