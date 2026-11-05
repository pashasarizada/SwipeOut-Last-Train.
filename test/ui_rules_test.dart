import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// docs/UI_UX_GUIDELINES.md §1: no Material look and no emoji on screens the
/// player sees.
const _forbidden = [
  'AppBar(',
  'BackButton(',
  'ListTile(',
  'FilledButton',
  'OutlinedButton',
  'TextButton',
  'ElevatedButton',
  'InputChip(',
  'Chip(',
  'showModalBottomSheet',
  'AlertDialog',
  'SnackBar',
  'CircularProgressIndicator',
  'InkWell(',
];

final _emoji = RegExp('[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]', unicode: true);

const _playerFacing = [
  'lib/game/presentation/screens',
  'lib/game/presentation/widgets',
  'lib/game/presentation/passport',
];

void main() {
  final files = [
    for (final dir in _playerFacing)
      if (Directory(dir).existsSync())
        ...Directory(dir)
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart')),
  ];

  test('player-facing screens use the game kit, never Material widgets', () {
    for (final file in files) {
      final code = file.readAsStringSync();
      for (final name in _forbidden) {
        // Whole names only: SignalBackButton is ours, BackButton is not.
        final pattern = RegExp(r'\b' + RegExp.escape(name));
        expect(
          pattern.hasMatch(code),
          isFalse,
          reason: '${file.path} uses $name',
        );
      }
    }
  });

  test('no emoji in player-facing code or translations', () {
    for (final file in [
      ...files,
      File('lib/l10n/app_en.arb'),
      File('lib/l10n/app_tr.arb'),
    ]) {
      expect(
        _emoji.hasMatch(file.readAsStringSync()),
        isFalse,
        reason: file.path,
      );
    }
  });
}
