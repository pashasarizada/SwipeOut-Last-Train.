import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../domain/city.dart';
import '../../domain/passport.dart';
import '../kit/game_fonts.dart';
import '../kit/signal_back_button.dart';
import '../theme/app_colors.dart';
import 'passport_page.dart';

/// The Metro Passport booklet: cover, one page per city, and the Night
/// Dispatcher page once all five stamps are in. [highlight] opens on that
/// city and presses its stamp.
final class PassportScreen extends StatefulWidget {
  const PassportScreen({super.key, required this.passport, this.highlight});

  final Passport passport;
  final CityId? highlight;

  @override
  State<PassportScreen> createState() => _PassportScreenState();
}

class _PassportScreenState extends State<PassportScreen> {
  late final PageController _pages = PageController(
    initialPage: widget.highlight == null ? 0 : widget.highlight!.index + 1,
    viewportFraction: 0.92,
  );

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passport = widget.passport;
    return Scaffold(
      backgroundColor: const Color(0xFF070B18),
      body: SafeArea(
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: SignalBackButton(),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                children: [
                  const _Cover(),
                  for (final stamp in passport.stamps)
                    PassportPage(
                      stamp: stamp,
                      highlight: stamp.city == widget.highlight,
                    ),
                  if (passport.isNightDispatcher) const _NightDispatcherPage(),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

final class _Cover extends StatelessWidget {
  const _Cover();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF16224A), Color(0xFF0A1230)],
          ),
          border: Border.all(
            color: AppColors.accentAmber.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Image.asset(
                'assets/branding/logo_512.png',
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l.metroPassport,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: GameFonts.display,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: AppColors.accentAmber,
                  shadows: [
                    Shadow(
                      color: AppColors.accentAmber.withValues(alpha: 0.5),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _NightDispatcherPage extends StatelessWidget {
  const _NightDispatcherPage();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
                l.nightDispatcher,
                style: const TextStyle(
                  fontFamily: GameFonts.display,
                  fontSize: 28,
                  color: Color(0xFFD4AF37),
                  letterSpacing: 3,
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              l.nightDispatcherBody,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
