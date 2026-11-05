# Mimari (V2 — NIGHT PULSE)

## Katmanlar

```
lib/game/domain        ← değer nesneleri: Node, Edge, SwitchDef, TrainDef, TrainState, GameState, ControlAction, LevelDefinition
      ↑
lib/game/engine        ← saf kurallar: PulseEngine (simulatePulse), GameSession (undo), PulseSolver (BFS), LevelValidator
      ↑
lib/game/data          ← LevelJsonCodec, ActionCodec, LevelIndex, LevelRepository (arayüz) + AssetLevelRepository
      ↑
lib/game/presentation  ← PulseController (ChangeNotifier), NetworkPainter + TrainLayer, ekranlar, tema
lib/main.dart, lib/app.dart ← composition root
```

**Bağımlılık kuralı:** Oklar yalnız yukarı bakar. `domain` ve `engine` saf Dart (`test/architecture_test.dart` zorlar) → motor `dart run tool/solve_levels.dart` ile Flutter'sız çalışır.

## Bir pulse'ın yolu
1. Oyuncu bir makas/sinyal düğümüne dokunur → `PulseController.pending` (durum değişmez).
2. `▶` → `GameSession.pulse(pending)` → `PulseEngine.simulatePulse` **saf ve atomik**: ya yeni `GameState` (`PulseApplied`) ya hiçbir değişiklik (`PulseFailed`).
3. Başarıda controller `PulseCommitted(before, after)` yayar; `BoardView` `AnimationController` ile `before → after` tween'ini oynar, bitince `finishAnimation()` → giriş açılır.
4. Başarısızlıkta `PulseRejected` → kırmızı flaş + titreşim; `pending` korunur.

İş mantığı animasyondan bağımsızdır; uygulama arka plana geçerse animasyon sona sarılır, kayıt hep tam pulse sonrası durumdur.

## SOLID / KISS / DRY
- **SRP:** codec JSON yapısını, validator oyun kurallarını, solver aramayı, engine tek pulse'ı, controller ekran durumunu yönetir.
- **OCP:** `sealed` `ControlAction`, `PulseResult`, `SolveResult`, `GameEvent` — yeni varyant derleyicide yakalanır.
- **LSP / ISP:** `LevelRepository` tek metotlu (`loadCity`); asset ve test sahtesi birbirinin yerine geçer.
- **DIP:** ekranlar `LevelRepository`'ye, validator `PulseSolver`'a constructor ile bağlanır; service locator yok.
- **KISS:** state management paketi ve Flame yok; `ChangeNotifier` + `ListenableBuilder`.
- **DRY:** kurallar tek yerde (`PulseEngine`); solver, validator replay'i ve oyun aynı motoru kullanır. Renk/süre/metin tek kaynaktan (`AppColors`, `motion.dart`, ARB + seviye `{tr,en}`).
