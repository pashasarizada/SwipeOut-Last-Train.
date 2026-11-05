import '../domain/control_action.dart';
import 'level_format_exception.dart';

/// Solution steps in level files: `wait`, `switch:<node>`, `signal:<node>`.
abstract final class ActionCodec {
  static const String _wait = 'wait';
  static const String _switch = 'switch';
  static const String _signal = 'signal';

  static String encode(ControlAction? action) => switch (action) {
    null => _wait,
    ToggleSwitch(:final nodeId) => '$_switch:$nodeId',
    ToggleSignal(:final nodeId) => '$_signal:$nodeId',
  };

  static ControlAction? decode(String raw, {required String levelId}) {
    if (raw == _wait) return null;
    final parts = raw.split(':');
    if (parts.length == 2 && parts[1].isNotEmpty) {
      switch (parts[0]) {
        case _switch:
          return ToggleSwitch(parts[1]);
        case _signal:
          return ToggleSignal(parts[1]);
      }
    }
    throw LevelFormatException(levelId, 'unknown solution step "$raw"');
  }
}
