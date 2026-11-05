import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/grid_pos.dart';
import 'package:swipeout_last_train/game/ui/board/board_geometry.dart';

void main() {
  final geometry = BoardGeometry(
    columns: 5,
    rows: 5,
    available: const Size(350, 400),
  );

  test('square cells fit the tighter axis', () {
    expect(geometry.cellSize, 70);
    expect(geometry.boardSize, const Size(350, 350));
  });

  test('centerOf returns the middle of a cell', () {
    expect(geometry.centerOf(const GridPos(0, 0)), const Offset(35, 35));
    expect(geometry.centerOf(const GridPos(4, 2)), const Offset(315, 175));
  });

  test('cellAt maps points inside the board and rejects the rest', () {
    expect(geometry.cellAt(const Offset(80, 10)), const GridPos(1, 0));
    expect(geometry.cellAt(const Offset(349, 349)), const GridPos(4, 4));
    expect(geometry.cellAt(const Offset(-1, 10)), isNull);
    expect(geometry.cellAt(const Offset(10, 351)), isNull);
  });
}
