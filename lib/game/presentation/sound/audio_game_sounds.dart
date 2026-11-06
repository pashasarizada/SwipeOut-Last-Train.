import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'game_sounds.dart';

/// Real sound through `audioplayers` (D-032). Ambient on iOS: it obeys the
/// silent switch and mixes with the player's own music instead of stopping
/// it. Each cue gets a small pool so quick repeats overlap.
final class AudioGameSounds implements GameSounds {
  AudioGameSounds._(this._pools);

  final Map<SoundCue, AudioPool> _pools;

  static final AudioContext _ambient = AudioContext(
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  /// Loads every cue; on any failure the game simply stays silent.
  static Future<GameSounds> load() async {
    try {
      await AudioPlayer.global.setAudioContext(_ambient);
      final pools = <SoundCue, AudioPool>{
        for (final cue in SoundCue.values)
          cue: await AudioPool.createFromAsset(
            path: 'sounds/${cue.file}.wav',
            maxPlayers: 3,
            playerMode: PlayerMode.lowLatency,
          ),
      };
      return AudioGameSounds._(pools);
    } on Object catch (error) {
      debugPrint('Sounds unavailable: $error');
      return const SilentGameSounds();
    }
  }

  @override
  void play(SoundCue cue) {
    _pools[cue]?.start().ignore();
  }

  @override
  void dispose() {
    for (final pool in _pools.values) {
      pool.dispose().ignore();
    }
  }
}
