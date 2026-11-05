import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/data/action_codec.dart';
import 'package:swipeout_last_train/game/data/level_format_exception.dart';
import 'package:swipeout_last_train/game/data/level_json_codec.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/node.dart';
import 'package:swipeout_last_train/game/domain/signal_aspect.dart';
import 'package:swipeout_last_train/game/domain/switch_def.dart';
import 'package:swipeout_last_train/game/domain/train_def.dart';

import '../../support/ank01_json.dart';
import '../../support/graph_builders.dart';

Matcher _formatError(String id) => throwsA(
  isA<LevelFormatException>().having((e) => e.levelId, 'levelId', id),
);

Map<String, Object?> _with(String key, Object? value) => {
  ...ank01Json(),
  key: value,
};

void main() {
  const codec = LevelJsonCodec();

  test('decodes the ANK-01 sample into the same level as the fixture', () {
    final level = codec.decode(ank01Json());
    final expected = ank01();

    expect(level.id, 'ANK-01');
    expect(level.city, CityId.ankara);
    expect(
      (level.number, level.maxPulses, level.parPulses, level.tutorial),
      (1, 5, 2, true),
    );
    expect(level.title.of('tr'), 'İlk Sefer');
    expect(level.nodes['B']!.kind, NodeKind.junction);
    expect(level.nodes['C']!.position.y, 0.25);
    expect(level.edges.keys, expected.edges.keys);
    expect(level.switches['B']!.branchBEdge, 'BD');
    expect(level.initialState, expected.initialState);
    expect(level.trains.single.symbol, TrainSymbol.circle);
    expect(level.trains.single.style, TrainStyle.coral);
    expect(level.tutorialSteps, hasLength(2));
    expect(level.solution, const [null, ToggleSwitch('B')]);
  });

  test('signals decode with their initial aspect', () {
    final json = _with('signals', [
      {'nodeId': 'S', 'initial': 'green'},
    ]);
    expect(codec.decode(json).initialSignals, {'S': SignalAspect.green});
  });

  test('a switch without selectedBranch starts on A', () {
    final json = _with('switches', [
      {
        'nodeId': 'B',
        'trunkEdge': 'AB',
        'branchAEdge': 'BC',
        'branchBEdge': 'BD',
      },
    ]);
    expect(codec.decode(json).initialSwitches['B'], SwitchBranch.a);
  });

  group('malformed input raises LevelFormatException', () {
    test('unknown node kind', () {
      expect(
        () => codec.decode(
          _with('nodes', [
            {'id': 'A', 'kind': 'bridge', 'x': 0.1, 'y': 0.1},
          ]),
        ),
        _formatError('ANK-01'),
      );
    });

    test('missing coordinate', () {
      expect(
        () => codec.decode(
          _with('nodes', [
            {'id': 'A', 'kind': 'depot', 'y': 0.1},
          ]),
        ),
        _formatError('ANK-01'),
      );
    });

    test('integer coordinates are accepted, strings are not', () {
      expect(
        codec
            .decode(
              _with('nodes', [
                {'id': 'A', 'kind': 'depot', 'x': 0, 'y': 1},
              ]),
            )
            .nodes['A']!
            .position
            .x,
        0.0,
      );
      expect(
        () => codec.decode(
          _with('nodes', [
            {'id': 'A', 'kind': 'depot', 'x': '0', 'y': 1},
          ]),
        ),
        _formatError('ANK-01'),
      );
    });

    test('duplicate node or edge ids', () {
      expect(
        () => codec.decode(
          _with('nodes', [
            {'id': 'A', 'kind': 'depot', 'x': 0.1, 'y': 0.1},
            {'id': 'A', 'kind': 'goal', 'x': 0.2, 'y': 0.2},
          ]),
        ),
        _formatError('ANK-01'),
      );
      expect(
        () => codec.decode(
          _with('edges', [
            {'id': 'AB', 'a': 'A', 'b': 'B'},
            {'id': 'AB', 'a': 'B', 'b': 'C'},
          ]),
        ),
        _formatError('ANK-01'),
      );
    });

    test('bad enum values', () {
      expect(
        () => codec.decode(_with('city', 'istanbul')),
        _formatError('ANK-01'),
      );
      expect(
        () => codec.decode(
          _with('trains', [
            {
              'id': 't',
              'startNode': 'A',
              'goalNode': 'C',
              'symbol': 'star',
              'style': 'coral',
            },
          ]),
        ),
        _formatError('ANK-01'),
      );
    });

    test('bad solution step', () {
      expect(
        () => codec.decode(_with('solution', ['jump:B'])),
        _formatError('ANK-01'),
      );
    });

    test('missing id reports "?"', () {
      expect(() => codec.decode({'city': 'ankara'}), _formatError('?'));
    });
  });

  group('ActionCodec', () {
    test('round-trips every action', () {
      for (final action in const [null, ToggleSwitch('B'), ToggleSignal('S')]) {
        expect(
          ActionCodec.decode(ActionCodec.encode(action), levelId: 'x'),
          action,
        );
      }
      expect(ActionCodec.encode(null), 'wait');
      expect(ActionCodec.encode(const ToggleSwitch('B')), 'switch:B');
    });

    test('rejects unknown steps', () {
      expect(
        () => ActionCodec.decode('switch:', levelId: 'x'),
        _formatError('x'),
      );
      expect(
        () => ActionCodec.decode('jump:B', levelId: 'x'),
        _formatError('x'),
      );
    });
  });
}
