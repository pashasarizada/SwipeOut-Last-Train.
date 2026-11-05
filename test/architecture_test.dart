import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Domain and engine must stay pure Dart so they are testable and portable.
void main() {
  for (final layer in ['lib/game/domain', 'lib/game/engine']) {
    test('$layer has no Flutter dependency', () {
      final dir = Directory(layer);
      expect(dir.existsSync(), isTrue, reason: '$layer must exist');

      final files = dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      for (final file in files) {
        final content = file.readAsStringSync();
        expect(content, isNot(contains('package:flutter')), reason: file.path);
        expect(content, isNot(contains('dart:ui')), reason: file.path);
      }
    });
  }
}
