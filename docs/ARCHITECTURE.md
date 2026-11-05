# Mimari

## Katmanlar

```
lib/game/domain   ← değer nesneleri (immutable): Direction, GridPos, Cell, Train, BoardState, Move, ...
      ↑
lib/game/engine   ← saf kurallar: TrackConnectivity, GameRules, UndoHistory, GameSession, LevelSolver, LevelValidator
      ↑
lib/game/data     ← dış dünya: LevelJsonCodec (JSON → domain), LevelRepository (arayüz), AssetLevelRepository
      ↑
lib/game/ui       ← Flutter: GameController (ChangeNotifier), BoardView/BoardPainter, ekranlar
lib/app.dart, lib/main.dart ← composition root (somut bağımlılıklar burada kurulur)
```

**Bağımlılık kuralı:** Oklar yalnız yukarı bakar. `domain` hiçbir şeye, `engine` yalnız `domain`'e bağımlıdır. Bu iki katmanda `package:flutter` / `dart:ui` importu yasaktır; `test/architecture_test.dart` bunu her test koşusunda doğrular. Böylece motor Flutter olmadan test edilir ve `dart run tool/...` ile çalışabilir.

## Durum modeli
- `LevelDefinition` — statik yapı (hücreler, başlangıç trenleri, başlangıç makas konumları, optimum).
- `BoardState` — dinamik durum (tren konumları/teslim bitleri + makas dalları). Immutable; eşitlik kanonik `key` üzerinden. Çözücü ziyaret kümesi ve undo testleri aynı kimliği kullanır (DRY).
- `GameSession` — aktif `BoardState` + `UndoHistory<BoardState>`. Hamle sayısı = geçmiş uzunluğu.
- `GameController` (UI) — oturumu sarar; seçim, giriş kilidi, ipucu ve tek seferlik `GameEvent` akışı.

## SOLID nerede?
- **SRP:** Dosya başına tek tip. Codec yalnız JSON yapısını çözer; oyun kuralı ihlallerini `LevelValidator` bulur. Controller yalnız olay yayar; haptik/sheet gibi yan etkileri ekran yapar.
- **OCP:** `sealed class Cell`, `Move`, `MoveResult`, `SolverOutcome`, `GameEvent` — yeni varyant eklemek `switch` ifadelerinde derleyici uyarısıyla yakalanır.
- **LSP:** `LevelRepository` uygulamaları (asset, test fake) birbirinin yerine geçer.
- **ISP:** Arayüzler tek metotlu ve dar (`LevelRepository.loadAll`, `HintRunner`).
- **DIP:** Ekranlar `LevelRepository`'ye, controller `HintRunner`'a, validator `LevelSolver`'a constructor ile bağlanır. Service locator yok.

## KISS / DRY
- State management paketi yok; `ChangeNotifier` + `ListenableBuilder`.
- Kurallar tek yerde (`GameRules.apply`); `legalMoves`, çözücü ve ipucu hepsi onu kullanır.
- Renkler `AppColors`, süreler `motion.dart`, metinler ARB — tek kaynak.
