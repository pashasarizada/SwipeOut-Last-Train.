import 'dart:ui';

import '../../domain/city.dart';
import 'ankara_art.dart';
import 'baku_art.dart';
import 'city_art.dart';
import 'london_art.dart';
import 'moscow_art.dart';
import 'paris_art.dart';

/// A city's own palette and artwork (docs/ART_DIRECTION.md).
final class CityTheme {
  const CityTheme._({
    required this.city,
    required this.background,
    required this.rail,
    required this.accent,
    required this.accentAlt,
    required this.lines,
    required this.art,
  });

  final CityId city;
  final Color background;
  final Color rail;

  /// Main highlight: lit lines, goal glow, stamp ink.
  final Color accent;

  /// Secondary highlight: patterns, borders.
  final Color accentAlt;

  /// Metro line colours on the board: two from the violet–magenta band,
  /// kept away from the train colours, and one muted city tone. Our own
  /// picks — not any operator's line colour scheme (D-036).
  final List<Color> lines;

  /// Pattern, skyline, ambience and passport stamp.
  final CityArt art;

  static const Map<CityId, CityTheme> _themes = {
    CityId.ankara: CityTheme._(
      city: CityId.ankara,
      background: Color(0xFF0E1020),
      rail: Color(0xFF8A93B2),
      accent: Color(0xFFE5484D),
      accentAlt: Color(0xFFF2C14E),
      lines: [Color(0xFF9D7BEA), Color(0xFFD46BB4), Color(0xFFB0A89A)],
      art: AnkaraArt(),
    ),
    CityId.baku: CityTheme._(
      city: CityId.baku,
      background: Color(0xFF0A1628),
      rail: Color(0xFF93A4C0),
      accent: Color(0xFF3BA3C7),
      accentAlt: Color(0xFFD9B98C),
      lines: [Color(0xFFA48BF0), Color(0xFFC77DDB), Color(0xFFC2B49C)],
      art: BakuArt(),
    ),
    CityId.paris: CityTheme._(
      city: CityId.paris,
      background: Color(0xFF121034),
      rail: Color(0xFFA8A2C8),
      accent: Color(0xFFF5A524),
      accentAlt: Color(0xFFF3E9D2),
      lines: [Color(0xFFE07AC0), Color(0xFF9A7CF0), Color(0xFFBDB6C9)],
      art: ParisArt(),
    ),
    CityId.london: CityTheme._(
      city: CityId.london,
      background: Color(0xFF14161C),
      rail: Color(0xFF8E96A3),
      accent: Color(0xFFE8C547),
      accentAlt: Color(0xFF8C2F39),
      lines: [Color(0xFFB07CD8), Color(0xFFB5C94A), Color(0xFFA3A8B0)],
      art: LondonArt(),
    ),
    CityId.moscow: CityTheme._(
      city: CityId.moscow,
      background: Color(0xFF0C1018),
      rail: Color(0xFF9AA6BC),
      accent: Color(0xFFA3262A),
      accentAlt: Color(0xFF5B8DEF),
      lines: [Color(0xFF9C84F0), Color(0xFFCF6FC0), Color(0xFFA8BCCC)],
      art: MoscowArt(),
    ),
  };

  static CityTheme of(CityId city) => _themes[city]!;
}
