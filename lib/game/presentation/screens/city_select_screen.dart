import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../domain/city.dart';
import '../../domain/passport.dart';
import '../city/city_backdrop.dart';
import '../city/city_theme.dart';
import '../game/game_scope.dart';
import '../kit/departure_board.dart';
import '../kit/game_fonts.dart';
import '../kit/signal_back_button.dart';
import '../theme/app_colors.dart';
import '../widgets/game_texts.dart';
import 'city_map_screen.dart';

/// City tickets in a carousel, each in its own city's colours and art.
final class CitySelectScreen extends StatefulWidget {
  const CitySelectScreen({super.key});

  @override
  State<CitySelectScreen> createState() => _CitySelectScreenState();
}

class _CitySelectScreenState extends State<CitySelectScreen> {
  final PageController _pages = PageController(viewportFraction: 0.84);

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 8),
              child: Row(
                children: [
                  const SignalBackButton(),
                  const SizedBox(width: 4),
                  Expanded(
                    child: DepartureBoard(
                      lines: [l.chooseCity, l.fictionalNotice],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                children: [
                  for (final city in CityId.values) _CityTicket(city: city),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

final class _CityTicket extends StatelessWidget {
  const _CityTicket({required this.city});

  final CityId city;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final store = GameScope.of(context);
    final theme = CityTheme.of(city);
    final stamp = store.passport.stampFor(city);
    final open = store.levelsOf(city).isNotEmpty;
    return GestureDetector(
      key: ValueKey('ticket-${city.name}'),
      behavior: HitTestBehavior.opaque,
      onTap: open
          ? () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CityMapScreen(city: city),
              ),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: ClipPath(
          clipper: const _TicketClipper(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CityBackdrop(city: city),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.background.withValues(alpha: 0.2),
                      theme.background.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SignalLamps(lit: city.difficulty, color: theme.accent),
                    const Spacer(),
                    if (city == CityId.moscow)
                      Text(
                        l.nightmareNetwork,
                        style: TextStyle(
                          color: theme.accent,
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                    Text(
                      l.cityName(city),
                      style: TextStyle(
                        fontFamily: GameFonts.display,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        color: open
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      l.greeting(city),
                      style: TextStyle(color: theme.accentAlt, fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l.cityProgress(stamp.solved, kLevelsPerCity),
                      style: const TextStyle(
                        fontFamily: GameFonts.board,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!open) _UnderConstruction(label: l.lineUnderConstruction),
            ],
          ),
        ),
      ),
    );
  }
}

/// Difficulty as five signal lamps.
final class _SignalLamps extends StatelessWidget {
  const _SignalLamps({required this.lit, required this.color});

  final int lit;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < CityId.values.length; i++)
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < lit ? color : AppColors.trackInactive,
            boxShadow: i < lit
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.7),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        ),
    ],
  );
}

/// Barrier tape across a city that is not open yet (never "for sale").
final class _UnderConstruction extends StatelessWidget {
  const _UnderConstruction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Transform.rotate(
      angle: -0.18,
      child: CustomPaint(
        painter: const _TapePainter(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: GameFonts.board,
              fontWeight: FontWeight.w600,
              color: AppColors.background,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    ),
  );
}

final class _TapePainter extends CustomPainter {
  const _TapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(-40, 0, size.width + 80, size.height);
    canvas.drawRect(rect, Paint()..color = AppColors.accentAmber);
    final stripe = Paint()
      ..color = AppColors.background.withValues(alpha: 0.85);
    for (var x = rect.left; x < rect.right; x += 26) {
      canvas.drawPath(
        Path()
          ..moveTo(x, rect.bottom)
          ..lineTo(x + 10, rect.bottom)
          ..lineTo(x + 18, rect.bottom - 6)
          ..lineTo(x + 8, rect.bottom - 6)
          ..close(),
        stripe,
      );
    }
  }

  @override
  bool shouldRepaint(_TapePainter old) => false;
}

/// A ticket with punched notches halfway down each side.
final class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper();

  @override
  Path getClip(Size size) {
    final body = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
      );
    final notches = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(0, size.height * 0.72), radius: 14),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width, size.height * 0.72),
          radius: 14,
        ),
      );
    return Path.combine(PathOperation.difference, body, notches);
  }

  @override
  bool shouldReclip(_TicketClipper old) => false;
}
