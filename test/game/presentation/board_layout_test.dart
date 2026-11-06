import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/node.dart';
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

  test('a tap near a switch picks the switch, even nearer another stop', () {
    // A depot 50 pt above a switch, as when a train waits on the switch
    // and the player taps the car's roof (playtest, London 02).
    final layout = BoardLayout(size: const Size(300, 300), padding: 0);
    final nodes = {
      for (final n in [
        node('D', NodeKind.depot, 0.5, 0.4),
        node('S', NodeKind.junction, 0.5, 0.4 + 50 / 300),
        node('X', NodeKind.track, 0.2, 0.9),
      ])
        n.id: n,
    };
    final s = layout.toScreen(nodes['S']!.position);
    final tap = s + const Offset(0, -30);
    expect(layout.nodeAt(tap, nodes), 'D', reason: 'nearest stop');
    expect(layout.controlAt(tap, nodes), 'S');
    expect(layout.controlAt(s + const Offset(0, 40), nodes), isNull);
  });

  test('a signal lamp stands clear of a train waiting on its node', () {
    expect(
      NetworkPainter.signalLampOffset.distance,
      greaterThan(TrainLayer.carLength / 2 + 8),
    );
  });
}
