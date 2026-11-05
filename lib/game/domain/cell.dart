import 'direction.dart';
import 'train_color.dart';

enum TrackKind { straight, corner, depot }

enum SwitchBranch {
  a,
  b;

  SwitchBranch get toggled =>
      this == SwitchBranch.a ? SwitchBranch.b : SwitchBranch.a;
}

/// Static board structure. Dynamic data (trains, switch positions) lives in
/// `BoardState`.
sealed class Cell {
  const Cell();
}

final class EmptyCell extends Cell {
  const EmptyCell();
}

final class BlockedCell extends Cell {
  const BlockedCell();
}

final class TrackCell extends Cell {
  const TrackCell(this.kind, this.ports);

  final TrackKind kind;
  final Set<Direction> ports;
}

final class StationCell extends Cell {
  const StationCell(this.color, this.ports);

  final TrainColor color;
  final Set<Direction> ports;
}

/// A switch connects [common] with exactly one of its two branches.
final class SwitchCell extends Cell {
  const SwitchCell({
    required this.common,
    required this.branchA,
    required this.branchB,
  });

  final Direction common;
  final Direction branchA;
  final Direction branchB;

  Set<Direction> portsFor(SwitchBranch branch) => {
    common,
    branch == SwitchBranch.a ? branchA : branchB,
  };
}
