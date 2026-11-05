part of '../city_select_screen.dart';

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
