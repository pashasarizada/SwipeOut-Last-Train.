# Tahta Okunurluğu (A+B) — Uygulama Planı

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tahta, bir sonraki dakikada ne olacağını yazı olmadan göstersin: makas yönü, hareket okları, bekliyor rozeti, çarpışma uyarısı, teslim parıltısı. Üst bilgi simgelerle sadeleşsin, kurallar duyuruya ve öğretici ele taşınsın.

**Architecture:**
- Motor, saf Dart bir `PulseForecast` üretir.
- `PulseController.forecast`, şimdiki `ghost`'un yerini alır.
- Tahtadaki yeni `ForecastPainter` okları, rozeti, çarpıyı ve parıltıyı çizer. `NetworkPainter` makas kollarını yeniden çizer.
- Platformda yeni widget'lar: `RunMeter` ve `TutorialHand`. `PlatformAnnouncement` bir `info` tonu kazanır.

**Tech Stack:** Flutter 3.32.8 / Dart 3.8.1. Yalnız `AnimationController` + `CustomPainter` kullanılır, yeni paket eklenmez.

**Spec:** `docs/superpowers/specs/2026-11-06-board-readability-design.md`

## Global Constraints

- `domain` ve `engine` saf Dart kalır (`test/architecture_test.dart`).
- Material bileşen yok, emoji yok, `Icons.`/`Icon(` yok (`test/.../ui_rules_test.dart`).
- Oyuncunun gördüğü metinler yalnız ARB'den gelir (TR + EN).
- Her commit'ten önce `scripts/check.sh` geçmeli. Komutlar `&&` ile zincirlenir, sonra `git push origin main`.
- Önizleme yalnız bir sonraki dakikayı gösterir.
- Bütün bölümler için 44 pt kuralı geçerli (`level_layout_test`).
- ~200 satırı geçen dosya bölünür.

## Review Focus

1. Önizleme ile gerçek dakika aynı olmalı. `forecast.conflict == null` olduğu halde dakika reddedilirse oyuncu yanıltılır. Kayıtlı çözümlerin her adımında `forecast` ile `simulatePulse` karşılaştırılır.
2. Sonsuz `_idle` animasyonu `pumpAndSettle`'ı asmamalı ve Reduced Motion açıkken durmalı.
3. `maxPulses` büyük olduğunda (14+) `RunMeter` taşmamalı; 320×568'de de sığmalı.
4. Tren durduğu yerde hem ok hem rozet çizilmemeli. Teslim edilmiş tren hiçbir şey çizmemeli.
5. Sırası bozulmuş bir öğretici çalışmada el yanlış yeri göstermemeli.

---

### Task 1: Motor tahmini

**Files:**
- Create: `lib/game/domain/pulse_forecast.dart`
- Modify: `lib/game/engine/pulse_engine.dart`, `lib/game/engine/game_session.dart`, `lib/game/presentation/game/pulse_controller.dart`
- Test: `test/game/engine/pulse_forecast_test.dart`, `test/game/presentation/pulse_controller_test.dart`

**Interfaces — Produces:**
- `final class TrainMove { String trainId; String from; String? to; }`
- `final class PulseForecast { List<TrainMove> moves; PulseFailed? conflict; Set<String> delivers; bool get ok => conflict == null; TrainMove? moveOf(String id); }`
- `PulseForecast PulseEngine.forecast(GameState, ControlAction?)`
- `PulseForecast GameSession.forecast(ControlAction?)`
- `PulseForecast? PulseController.forecast`. Bu, `ghost`'un yerini alır; `ghost` silinir.

Steps:
- [ ] Testleri yaz:
  - kalan tren `to == null` (kırmızı sinyal, pasif kol);
  - giden tren doğru `to`;
  - collision / headOn / blockedByStanding / wrongGoal için `conflict.reason` ve `nodeId` doğru;
  - `delivers` doğru;
  - 30 bölümün her çözüm adımında `forecast.ok`;
  - `simulatePulse` sonucu, `forecast.moves` uygulanınca aynı.
- [ ] Testi çalıştır, FAIL'i gör.
- [ ] Uygula: `simulatePulse` içindeki exits/_conflict hesabı `forecast`'a taşınır; `simulatePulse` = `forecast` + `_commit`.
- [ ] Controller: `forecast` getter'ı. `_canPlan` yanlışsa `null`. `ghost` ve kullanımları kaldırılır; `GhostPainter` Task 2'ye kadar `forecast`'tan beslenir.
- [ ] `scripts/check.sh`, commit `feat(engine): next-pulse forecast with intents and conflict`, push.

### Task 2: Makas yönü, hareket okları, bekliyor rozeti

**Files:**
- Create: `lib/game/presentation/board/forecast_painter.dart` (`ghost_painter.dart` silinir)
- Modify: `network_painter.dart`, `board_view.dart`
- Test: `test/game/presentation/board_view_test.dart`, yeni `forecast_painter_test.dart`

**Interfaces — Produces:**
- `ForecastPainter({level, state, forecast, layout, double flow /*0–1*/})`
- `ForecastPainter.arrowFor(TrainMove)`: test için okun ekran uçları `(Offset start, Offset end)`.
- `NetworkPainter.passiveGap = 14.0`

Steps:
- [ ] Testleri yaz:
  - BoardView, `ForecastPainter`'ı controller'ın `forecast`'ıyla çiziyor;
  - pending seçimi değişince painter'ın `forecast`'ı değişiyor;
  - teslim edilmiş tren için ne ok ne rozet var (`ForecastPainter.marksFor` sayımı).
- [ ] Testleri çalıştır, FAIL'i gör.
- [ ] Uygula:
  - pasif kol soluk çizilir ve makas merkezinden `passiveGap` önce kesilir;
  - bekleyen toggle kapanacak kolu kesik gösterir;
  - ok %30→%85, tren renginde; içinde `flow` ile akan noktalar;
  - kalan trende iki çubuklu rozet.
- [ ] `_idle` controller (1600 ms, repeat): yalnız `!isAnimating && forecast != null && !reduced` iken çalışır; `didChangeAppLifecycleState`'te durur.
- [ ] Simülatörde ekran görüntüsü al. Kontrol: `scripts/check.sh`. Commit `feat(board): open switch arm, forecast arrows, waiting badge`, push.

### Task 3: Çarpışma önizlemesi, kol uyarısı, teslim parıltısı

**Files:**
- Modify: `forecast_painter.dart`, `kit/advance_lever.dart`, `widgets/pulse_controls.dart`, ARB'ler (`forecastWarning`)
- Test: `forecast_painter_test.dart`, `kit_test.dart`, `screens_test.dart`

**Interfaces — Produces:**
- `AdvanceLever({..., bool warning = false, String? semanticsHint})`. `warning` iken renk `AppColors.danger`, ikon `GameIconKind.cross`.

Steps:
- [ ] Testleri yaz:
  - çarpışacak durumda kol `warning == true` ve basılabilir;
  - kolun semantics etiketi `forecastWarning` metnini içeriyor;
  - çakışan trenlerin okları kırmızı (`ForecastPainter.colorFor`);
  - `delivers` içindeki hedefte parıltı var.
- [ ] Testleri çalıştır, FAIL'i gör.
- [ ] Uygula:
  - çakışma düğümünde nabızlı çarpı (`GameIcon.paint` cross);
  - teslim halkası;
  - kolun semantics'i: advance + pending + warning.
- [ ] Simülatörde ekran görüntüsü al. Kontrol: `scripts/check.sh`. Commit `feat(board): crash preview on the board and the lever`, push.

### Task 4: RunMeter, jargon temizliği, bileti kaldırma

**Files:**
- Create: `lib/game/presentation/widgets/run_meter.dart`
- Modify: `pulse_hud.dart`, `pulse_controls.dart`, ARB'ler
- Test: `test/game/presentation/run_meter_test.dart`, `screens_test.dart`

**Interfaces — Produces:**
- `RunMeter({required List<TrainMark> trains, required int used, required int max, required int par})`
- `TrainMark(style, delivered)`
- `RunMeter.dotLimit = 16`. Fazlası çubukla gösterilir.

Steps:
- [ ] Testleri yaz:
  - HUD'da "PULSE" ve "Kontrol" yok;
  - RunMeter'de `max` adet nokta ve `used` adet dolu;
  - `par` ve `par+2`'de yıldız ayracı;
  - `max > 16` olunca çubuk;
  - semantics içinde `pulseCounter` ve `trainsDelivered`;
  - pending varken `ControlTicket` yok;
  - TR "DAKİKA", EN "MIN".
- [ ] Testleri çalıştır, FAIL'i gör.
- [ ] Uygula:
  - tabela iki satır olur;
  - RunMeter tabelanın altına gelir;
  - `controlsLeft` kaldırılır;
  - `pulseCounter` ve `pulsesUsed` metinleri dakika olur;
  - bilet alanı kalkar.
- [ ] `level_layout_test`, 320×568 dahil yeşil olmalı. Simülatörde ekran görüntüsü al. Kontrol: `scripts/check.sh`. Commit `feat(hud): run meter replaces pulse jargon and the ticket`, push.

### Task 5: Kural duyurusu ve öğretici el

**Files:**
- Create: `lib/game/presentation/widgets/tutorial_hand.dart`, `lib/game/presentation/game/tutorial_guide.dart` (saf mantık, Flutter'sız)
- Modify: `kit/platform_announcement.dart` (`AnnouncementTone {alarm, info}`), `pulse_game_screen.dart`, `pulse_hud.dart` (tabela dokunuşu)
- Test: `test/game/presentation/tutorial_guide_test.dart`, `screens_test.dart`, `kit_test.dart`

**Interfaces — Produces:**
- `sealed class GuideTarget`, varyantları: `GuideNode(nodeId)`, `GuideLever()`, `GuideUndo()`.
- `GuideTarget? TutorialGuide.next({required LevelDefinition level, required List<ControlAction?> history, required ControlAction? pending})`. `!level.tutorial` ya da çözüm bitmişse `null`.
- `PulseHud({..., VoidCallback? onBoardTap})`

Steps:
- [ ] Testleri yaz:
  - Guide: başta çözümün ilk kontrolünü gösteriyor; pending doğruysa kol; adım bekleme ise kol; yanlış pending ise o düğüm; sapmış geçmiş ise Geri Al; öğretici olmayan bölümde `null`.
  - Ekran: tahtanın üstünde `tutorialSteps` metni yok; açılışta info duyurusunda var; ilk dokunuşta kayboluyor; tabelaya dokununca geri geliyor; çarpışma duyurusu onun yerine geçiyor.
- [ ] Testleri çalıştır, FAIL'i gör.
- [ ] Uygula. El, çizilmiş bir parmak ve dokunma halkası olacak. Hedef konumu için `GlobalKey`'ler kullanılır (kol, Geri Al) ve düğüm konumu `BoardLayout`'tan alınır.
- [ ] Simülatörde ANK-01 ve ANK-02 baştan sona oynanır. Kontrol: `scripts/check.sh`. Commit `feat(tutorial): drawn hand guide and rules as a platform notice`, push.

### Task 6: Kapanış

- [ ] `docs/DECISIONS.md`: D-030 ve D-031.
- [ ] `TASKS.md` ve `PROGRESS.md` güncellenir; ekran görüntüleri `docs/images/v2-ux/13–16`.
- [ ] Bütün dalın bağımsız incelemesi yapılır (code-reviewer). Critical/Important bulgular test ile düzeltilir.
- [ ] Commit, push.
