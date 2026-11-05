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

part 'city_select/city_ticket.dart';
part 'city_select/under_construction.dart';

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
