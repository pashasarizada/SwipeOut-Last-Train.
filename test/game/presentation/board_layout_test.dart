import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/norm_point.dart';
import 'package:swipeout_last_train/game/presentation/board/board_layout.dart';
import 'package:swipeout_last_train/game/presentation/board/network_painter.dart';
import 'package:swipeout_last_train/game/presentation/board/train_layer.dart';

import '../../support/graph_builders.dart';

void main() {
  test('the unit square maps inside the padding of a square board', () {
    final layout = BoardLayout(size: const Size(300, 300), padding: 32);
    expect(layout.toScreen(const NormPoint(0, 0)), const Offset(32, 32));
    expect(layout.toScreen(const NormPoint(1, 1)), const Offset(268, 268));
  });

  test('a wide board stays square and centred', () {
    final layout = BoardLayout(size: const Size(400, 300), padding: 32);
    expect(layout.toScreen(const NormPoint(0, 0)), const Offset(82, 32));
    expect(layout.toScreen(const NormPoint(1, 1)), const Offset(318, 268));
  });

  test('nodeAt picks the nearest node within the hit radius', () {
    final layout = BoardLayout(size: const Size(300, 300));
    final nodes = ank01().nodes;
    final b = layout.toScreen(nodes['B']!.position);

    expect(layout.nodeAt(b + const Offset(20, 0), nodes), 'B');
    expect(layout.nodeAt(b + const Offset(0, 60), nodes), isNull);
  });

  test('a signal lamp stands clear of a train waiting on its node', () {
    expect(
      NetworkPainter.signalLampOffset.distance,
      greaterThan(TrainLayer.carLength / 2 + 8),
    );
  });
}
