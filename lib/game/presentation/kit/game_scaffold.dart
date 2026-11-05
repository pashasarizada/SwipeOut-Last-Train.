import 'package:flutter/material.dart';

import '../../domain/city.dart';
import '../city/city_theme.dart';

/// Every player-facing screen sits on its city's platform: themed
/// background, safe area, optional header. City art is layered in by
/// `CityBackdrop` (V2-UX Task 5).
final class GameScaffold extends StatelessWidget {
  const GameScaffold({
    super.key,
    required this.city,
    required this.body,
    this.header,
  });

  final CityId city;
  final Widget body;
  final Widget? header;

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
        child: SafeArea(
          child: Column(
            children: [
              if (header case final header?) header,
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
