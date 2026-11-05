import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/presentation/city/city_theme.dart';
import 'package:swipeout_last_train/game/presentation/kit/game_fonts.dart';

import '../../support/ttf_cmap.dart';

/// Text every shipped font must draw: Turkish, Azerbaijani, French, Russian.
const _languages = 'ğĞüÜşŞıİöÖçÇ əƏ éèàçœÉ ДобропжалвтьМск 0123456789:/·';
const _symbols = '●▲■◆✓';

void main() {
  for (final font in GameFonts.files.entries) {
    test('${font.key} covers TR, AZ, FR and Cyrillic', () {
      final points = ttfCodePoints(font.value);
      final missing = _languages.runes.where(
        (r) => r != 32 && !points.contains(r),
      );
      expect(String.fromCharCodes(missing), isEmpty);
    });
  }

  test('the body font also draws the train symbols', () {
    final points = ttfCodePoints(GameFonts.files[GameFonts.body]!);
    expect(
      String.fromCharCodes(_symbols.runes.where((r) => !points.contains(r))),
      isEmpty,
    );
  });

  test('every city has its own theme', () {
    final themes = CityId.values.map(CityTheme.of).toList();
    expect(themes.map((t) => t.city), CityId.values);
    expect(
      themes.map((t) => t.accent).toSet(),
      hasLength(CityId.values.length),
    );
  });
}
