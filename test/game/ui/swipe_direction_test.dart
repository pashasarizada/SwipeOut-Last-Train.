import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/direction.dart';
import 'package:swipeout_last_train/game/ui/game/swipe_direction.dart';

void main() {
  test('dominant axis decides the direction', () {
    expect(directionFromDelta(30, 5), Direction.east);
    expect(directionFromDelta(-30, 5), Direction.west);
    expect(directionFromDelta(5, -30), Direction.north);
    expect(directionFromDelta(5, 30), Direction.south);
    expect(directionFromDelta(30, 29), Direction.east);
  });

  test('short drags are ignored', () {
    expect(directionFromDelta(10, 10), isNull);
    expect(directionFromDelta(0, 0), isNull);
    expect(directionFromDelta(23, 0), isNull);
    expect(directionFromDelta(24, 0), Direction.east);
  });
}
