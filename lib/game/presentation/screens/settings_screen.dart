import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../domain/city.dart';
import '../../domain/game_settings.dart';
import '../game/settings_store.dart';
import '../kit/departure_board.dart';
import '../kit/game_button.dart';
import '../kit/game_scaffold.dart';
import '../kit/signal_back_button.dart';
import '../kit/signal_toggle.dart';
import '../theme/app_colors.dart';

/// Vibration, a Reduced Motion override and the language, on the current
/// city's platform. Every change applies and saves at once.
final class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.city = CityId.ankara});

  final CityId city;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final store = SettingsScope.maybeOf(context)!;
    final settings = store.settings;
    void set(GameSettings next) => store.update(next);
    return GameScaffold(
      city: city,
      backdropOpacity: 0.35,
      header: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 12, 8),
        child: Row(
          children: [
            const SignalBackButton(),
            const SizedBox(width: 4),
            Expanded(child: DepartureBoard(lines: [l.settings])),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          _SwitchRow(
            label: l.vibration,
            value: settings.vibration,
            onChanged: (v) => set(settings.copyWith(vibration: v)),
          ),
          _SwitchRow(
            label: l.sound,
            value: settings.sound,
            onChanged: (v) => set(settings.copyWith(sound: v)),
          ),
          _SwitchRow(
            label: l.reduceMotion,
            value: settings.reducedMotion,
            onChanged: (v) => set(settings.copyWith(reducedMotion: v)),
          ),
          const SizedBox(height: 24),
          Text(l.language, style: _labelStyle),
          const SizedBox(height: 12),
          for (final (language, name) in [
            (GameLanguage.system, l.languagePhone),
            (GameLanguage.tr, l.languageTurkish),
            (GameLanguage.en, l.languageEnglish),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GameButton(
                label: name,
                size: GameButtonSize.small,
                color: settings.language == language
                    ? AppColors.accentTurquoise
                    : AppColors.track,
                onPressed: () => set(settings.copyWith(language: language)),
              ),
            ),
        ],
      ),
    );
  }
}

const TextStyle _labelStyle = TextStyle(
  color: AppColors.textPrimary,
  fontSize: 17,
  fontWeight: FontWeight.w600,
);

final class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(label, style: _labelStyle)),
        SignalToggle(value: value, label: label, onChanged: onChanged),
      ],
    ),
  );
}
