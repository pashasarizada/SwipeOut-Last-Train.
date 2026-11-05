import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/data/level_json_codec.dart';
import 'package:swipeout_last_train/game/domain/cell.dart';
import 'package:swipeout_last_train/game/domain/direction.dart';
import 'package:swipeout_last_train/game/domain/grid_pos.dart';
import 'package:swipeout_last_train/game/domain/train_color.dart';

Map<String, Object?> _level001() => {
  'id': 'istanbul_001',
  'number': 1,
  'width': 5,
  'height': 5,
  'optimalMoves': 4,
  'tutorialKey': 'tutorialSelectSwipe',
  'cells': [
    {'x': 0, 'y': 2, 'type': 'depot', 'ports': 'E'},
    {'x': 1, 'y': 2, 'type': 'straight', 'ports': 'WE'},
    {'x': 4, 'y': 2, 'type': 'station', 'ports': 'W', 'color': 'red'},
    {
      'x': 2,
      'y': 2,
      'type': 'switch',
      'common': 'W',
      'branches': 'ES',
      'selected': 'b',
    },
    {'x': 3, 'y': 3, 'type': 'blocked'},
  ],
  'trains': [
    {'id': 'r1', 'color': 'red', 'x': 0, 'y': 2},
  ],
};

Map<String, Object?> _badWithCell(Map<String, Object?> cell) => {
  ..._level001(),
  'id': 't_bad',
  'cells': [cell],
};

Matcher _formatErrorFor(String id) => throwsA(
  isA<LevelFormatException>().having((e) => e.levelId, 'levelId', id),
);

void main() {
  const codec = LevelJsonCodec();

  test('decodes header, tracks, stations and trains', () {
    final level = codec.decode(_level001());

    expect(level.id, 'istanbul_001');
    expect(level.number, 1);
    expect((level.width, level.height), (5, 5));
    expect(level.optimalMoves, 4);
    expect(level.tutorialKey, 'tutorialSelectSwipe');
    expect(
      level.cellAt(const GridPos(1, 2)),
      isA<TrackCell>().having((c) => c.kind, 'kind', TrackKind.straight).having(
        (c) => c.ports,
        'ports',
        {Direction.west, Direction.east},
      ),
    );
    expect(
      level.cellAt(const GridPos(4, 2)),
      isA<StationCell>().having((c) => c.color, 'color', TrainColor.red),
    );
    expect(level.cellAt(const GridPos(3, 3)), isA<BlockedCell>());
    expect(level.initialTrains.single.position, const GridPos(0, 2));
    expect(level.initialTrains.single.color, TrainColor.red);
  });

  test('decodes a switch and its initial branch', () {
    final level = codec.decode(_level001());

    expect(
      level.cellAt(const GridPos(2, 2)),
      isA<SwitchCell>()
          .having((c) => c.common, 'common', Direction.west)
          .having((c) => c.branchA, 'branchA', Direction.east)
          .having((c) => c.branchB, 'branchB', Direction.south),
    );
    expect(level.initialSwitches[const GridPos(2, 2)], SwitchBranch.b);
  });

  test('a switch without "selected" starts on branch a', () {
    final json = _badWithCell({
      'x': 2,
      'y': 2,
      'type': 'switch',
      'common': 'W',
      'branches': 'ES',
    });

    expect(
      codec.decode(json).initialSwitches[const GridPos(2, 2)],
      SwitchBranch.a,
    );
  });

  group('malformed input raises LevelFormatException', () {
    test('unknown cell type', () {
      expect(
        () => codec.decode(_badWithCell({'x': 0, 'y': 0, 'type': 'bridge'})),
        _formatErrorFor('t_bad'),
      );
    });

    test('missing coordinate', () {
      expect(
        () => codec.decode(_badWithCell({'y': 0, 'type': 'blocked'})),
        _formatErrorFor('t_bad'),
      );
    });

    test('invalid direction letter', () {
      expect(
        () => codec.decode(
          _badWithCell({'x': 0, 'y': 0, 'type': 'straight', 'ports': 'WQ'}),
        ),
        _formatErrorFor('t_bad'),
      );
    });

    test('unknown colour', () {
      expect(
        () => codec.decode(
          _badWithCell({
            'x': 0,
            'y': 0,
            'type': 'station',
            'ports': 'W',
            'color': 'pink',
          }),
        ),
        _formatErrorFor('t_bad'),
      );
    });

    test('wrong value type', () {
      expect(
        () => codec.decode({..._level001(), 'id': 't_bad', 'width': '5'}),
        _formatErrorFor('t_bad'),
      );
    });

    test('missing id reports "?"', () {
      expect(() => codec.decode({'width': 5}), _formatErrorFor('?'));
    });
  });
}
