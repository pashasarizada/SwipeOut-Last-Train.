/// Bundled OFL font families (docs/UI_UX_GUIDELINES.md §4, D-025).
abstract final class GameFonts {
  /// Station-sign headlines.
  static const String display = 'Unbounded';

  /// Departure-board figures and HUD.
  static const String board = 'IBMPlexMono';

  /// Readable body text; also draws the train symbols ● ▲ ■ ◆.
  static const String body = 'Inter';

  /// Family → font file, for coverage checks.
  static const Map<String, String> files = {
    display: 'assets/fonts/Unbounded-Variable.ttf',
    board: 'assets/fonts/IBMPlexMono-SemiBold.ttf',
    body: 'assets/fonts/Inter-Variable.ttf',
  };
}
