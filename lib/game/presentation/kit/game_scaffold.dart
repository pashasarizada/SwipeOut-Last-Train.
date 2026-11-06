import 'package:flutter/material.dart';

import '../../domain/city.dart';
import '../city/city_backdrop.dart';
import '../city/city_theme.dart';
import 'contrast_settings.dart';

/// Every player-facing screen sits on its city's platform: themed
/// background with its living artwork, safe area, optional header.
final class GameScaffold extends StatelessWidget {
  const GameScaffold({
    super.key,
    required this.city,
    required this.body,
    this.header,
    this.backdrop = true,
    this.backdropOpacity = 1,
  });

  final CityId city;
  final Widget body;
  final Widget? header;

  /// Draw the living city artwork behind the screen.
  final bool backdrop;
  final double backdropOpacity;

  @override
  Widget build(BuildContext context) {
    final theme = CityTheme.of(city);
    return Scaffold(
      backgroundColor: theme.background,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.6),
            radius: 1.2,
            colors: [
              Color.lerp(theme.background, theme.accentAlt, 0.10)!,
              theme.background,
            ],
          ),
        ),
        child: Stack(
          children: [
            if (backdrop)
              Positioned.fill(
                child: Opacity(
                  // High Contrast quiets the city behind the board.
                  opacity: ContrastSettings.highOf(context)
                      ? backdropOpacity * 0.4
                      : backdropOpacity,
                  child: CityBackdrop(city: city),
                ),
              ),
            SafeArea(
              child: Column(
                children: [
                  if (header case final header?) header,
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
