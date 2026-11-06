import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'game_sounds.dart';

/// Real sound through `audioplayers` (D-032). Ambient on iOS: it obeys the
/// silent switch and mixes with the player's own music instead of stopping
/// it. Each cue gets a small pool so quick repeats overlap; players return
/// to the pool when their sound ends. Loading runs in the background and
/// never delays the launch: cues asked for before it finishes stay silent.
final class AudioGameSounds implements GameSounds {
  AudioGameSounds() {
    unawaited(_load().timeout(_loadLimit).catchError(_unavailable));
  }

  static const Duration _loadLimit = Duration(seconds: 5);

  final Map<SoundCue, AudioPool> _pools = {};

  static final AudioContext _ambient = AudioContext(
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  Future<void> _load() async {
    await AudioPlayer.global.setAudioContext(_ambient);
    for (final cue in SoundCue.values) {
      _pools[cue] = await AudioPool.createFromAsset(
        path: 'sounds/${cue.file}.wav',
        maxPlayers: 3,
      );
    }
  }

  static void _unavailable(Object error) =>
      debugPrint('Sounds unavailable: $error');

  @override
  void play(SoundCue cue) {
    _pools[cue]?.start().then((_) {}, onError: _unavailable).ignore();
  }

  @override
  void dispose() {
    for (final pool in _pools.values) {
      pool.dispose().ignore();
    }
  }
}
