import 'dart:ui';

import '../../domain/city.dart';

/// A city's own palette (docs/ART_DIRECTION.md). Art and ambience are added
/// by `CityArt` (V2-UX Task 5).
final class CityTheme {
  const CityTheme._({
    required this.city,
    required this.background,
    required this.rail,
    required this.accent,
    required this.accentAlt,
  });

  final CityId city;
  final Color background;
  final Color rail;

  /// Main highlight: lit lines, goal glow, stamp ink.
  final Color accent;

  /// Secondary highlight: patterns, borders.
  final Color accentAlt;

  static const Map<CityId, CityTheme> _themes = {
    CityId.ankara: CityTheme._(
      city: CityId.ankara,
      background: Color(0xFF0E1020),
      rail: Color(0xFF8A93B2),
      accent: Color(0xFFE5484D),
      accentAlt: Color(0xFFF2C14E),
    ),
    CityId.baku: CityTheme._(
      city: CityId.baku,
      background: Color(0xFF0A1628),
      rail: Color(0xFF93A4C0),
      accent: Color(0xFF3BA3C7),
      accentAlt: Color(0xFFD9B98C),
    ),
    CityId.paris: CityTheme._(
      city: CityId.paris,
      background: Color(0xFF121034),
      rail: Color(0xFFA8A2C8),
      accent: Color(0xFFF5A524),
      accentAlt: Color(0xFFF3E9D2),
    ),
    CityId.london: CityTheme._(
      city: CityId.london,
      background: Color(0xFF14161C),
      rail: Color(0xFF8E96A3),
      accent: Color(0xFFE8C547),
      accentAlt: Color(0xFF8C2F39),
    ),
    CityId.moscow: CityTheme._(
      city: CityId.moscow,
      background: Color(0xFF0C1018),
      rail: Color(0xFF9AA6BC),
      accent: Color(0xFFA3262A),
      accentAlt: Color(0xFF5B8DEF),
    ),
  };

  static CityTheme of(CityId city) => _themes[city]!;
}
