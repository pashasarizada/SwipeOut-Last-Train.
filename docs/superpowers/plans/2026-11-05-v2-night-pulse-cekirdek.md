# SwipeOut: Last Train V2 — NIGHT PULSE Çekirdeği (Ankara 01–02) Uygulama Planı

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Izgara + swipe mekaniğini, graf tabanlı ve tüm trenlerin aynı anda ilerlediği NIGHT PULSE motoruyla değiştirmek; ANK-01 ve ANK-02'yi animasyonlu, uçtan uca oynanır hale getirmek.

**Architecture:** Katmanlar aynı kalır (`domain` → `engine` → `data` → `presentation`), `domain`/`engine` saf Dart. Yeni çekirdek: `Node`/`Edge` grafı, tek bir saf `PulseEngine.simulatePulse` (atomik: ya hepsi commit edilir ya hiçbiri), BFS `PulseSolver`, `LevelValidator` + kayıtlı çözüm replay'i. Ekran tarafında `PulseController` (ChangeNotifier) iş mantığını tutar; `AnimationController` önceki/sonraki durum arasında tween yapar (iş mantığı animasyondan bağımsız).

**Tech Stack:** Flutter 3.32.8, Dart 3.8.1, `flutter_localizations` + `intl`. Tahta animasyonları yalnız Flutter'ın kendi `AnimationController` + `CustomPainter`'ı ile. UI süsleme paketi (Görev 10) kullanıcı kararına bağlı — varsayılan öneri `flutter_animate` + `animations`.

**Spec:** `docs/GAME_DESIGN_V2.md` (V2.1, bağlayıcı: oynanış, şehirler, seviyeler, görseller). Güvenlik/test/Türkçe/PR kuralları için `SwipeOut_Claude_Master_Prompt.md` + `CLAUDE.md` geçerli kalır.

**Kapsam dışı (sonraki planlar):** V2-B: ANK-03…06 + Bakü 6 + şehir haritası + ilerleme/yarım pulse kaydı (`shared_preferences`) + ayarlar. V2-C: Paris (sinyal UI'ı ilk kez öğretilir) + Londra (halka). V2-D: Moskova + cilalama + yayın.

## Neler korunur, neler gider

| Korunur (yeniden kullanılır) | Gider (Görev 11'de silinir) |
|---|---|
| Proje iskeleti, `scripts/check.sh`, `bootstrap.sh`, lint, gen-l10n, tema token'ları, `UndoHistory<T>`, `LevelRepository` arayüzü, `LevelIndex` deseni, `GameTexts` deseni, mimari test, dokümanların çoğu | `Direction`, `GridPos`, `Cell`/`TrackCell`/`StationCell`, `TrackConnectivity`, `GameRules`, `LevelSolver` (ızgara), swipe yönü, `BoardGeometry`, ızgara `BoardPainter`, İstanbul `level_00x.json`, `GameController` (swipe) |

## Global Constraints

- Flutter 3.32.8 / Dart 3.8.1. **Flame kullanılmaz** (güncel Flame ≥1.36 Flutter ≥3.41 ister; sıra tabanlı oyunda oyun döngüsüne ihtiyaç yok — spec §7 de zorunlu tutmuyor).
- `lib/game/domain/**` ve `lib/game/engine/**` içinde `package:flutter` / `dart:ui` yok (mimari test).
- Kod tanımlayıcıları İngilizce, dokümanlar ve iletişim Türkçe; oyun metinleri TR + EN (ARB veya seviye JSON'undaki `{tr, en}`).
- Şehir sırası sabit: Ankara → Bakü → Paris → Londra → Moskova. İstanbul ve `IST-*` hiçbir yerde kalmaz.
- Seviye ID'leri `ANK-01` biçimi; dosya `assets/levels/ANK-01.json`.
- Bir pulse = en fazla **1** kontrol değişimi (makas A↔B veya sinyal kırmızı↔yeşil) + tüm aktif trenlerin aynı anda bir kenar ilerlemesi. Kontrolsüz pulse ("bekle") geçerlidir.
- Başarısız pulse hiçbir durumu değiştirmez ve pulse harcamaz; `pendingAction` korunur.
- Trenler geri vitese takmaz; düğüm başına en çok 1 tren; teslim edilen tren doluluk yaratmaz.
- Renk tek ayıraç değil: her trende ve hedefinde sembol (`●`, `▲`, `■`, `◆`).
- Animasyon süreleri (spec §7): tren hareketi **400 ms**, makas **180 ms**, sinyal **150 ms**, pulse ışık dalgası **100 ms**, hedefe varış **300 ms**, çarpışma flaşı **300 ms**, bölüm bitişi **700 ms**. Animasyon sürerken komut alınmaz.
- Yıldız: 3 ★ `pulses ≤ parPulses`, 2 ★ `≤ parPulses + 2`, 1 ★ `≤ maxPulses`. `tutorial: true` bölümlerde yıldız gösterilmez, yalnız başarı.
- Resmî metro haritası/logo/font/anons kopyalanmaz; haritalar özgün çizilir.
- Git: `claude/v2-night-pulse` branch'i (`claude/bootstrap-swipeout` üzerinden), `main`'e merge yok, force push yok. Commit sonu: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- SOLID/KISS/DRY: `final class` varsayılan, varyantlar `sealed`, dosya başına tek sorumluluk (~200 satır), DI constructor ile, service locator yok.
- "Geçti" demeden önce `scripts/check.sh` çalıştırılır, gerçek çıktı `PROGRESS.md`'ye yazılır.

## Review Focus

1. **Zincir hareket ve 3'lü döngü** — A→B, B→C aynı pulse'da (B boşalıyor) geçerli; A→B, B→A kafa kafaya çarpışma; A→B→C→A döngüsü geçerli. (Görev 3)
2. **Pasif koldan gelen tren** — makas değişene kadar bekler; üzerindeyken makas değişirse yeni seçime göre çıkar. (Görev 3)
3. **maxPulses sınırında** — son pulse'da çözüm → kazanılır; çözülmeden dolarsa kayıp, undo ile kurtulur. (Görev 4)
4. **Animasyon sırasında hızlı dokunuş / pulse basışı** — yok sayılır, durum bir kez ilerler. (Görev 8)
5. **16 düğümlü tahta 320×568'de** — düğüm dokunma alanı ≥ 44 pt, taşma yok. (Görev 9)

---

## Dosya Yapısı

```
lib/game/domain/   norm_point.dart node.dart edge.dart switch_def.dart signal_aspect.dart
                   train_def.dart train_state.dart game_state.dart control_action.dart
                   pulse_result.dart level_definition.dart city.dart localized_text.dart
                   star_rating.dart level_result.dart          (son ikisi güncellenir)
lib/game/engine/   pulse_engine.dart game_session.dart pulse_solver.dart level_validator.dart undo_history.dart
lib/game/data/     level_json_codec.dart action_codec.dart level_index.dart level_repository.dart asset_level_repository.dart
lib/game/presentation/
  board/   board_layout.dart network_painter.dart train_layer.dart board_view.dart
  game/    pulse_controller.dart game_event.dart
  screens/ home_screen.dart city_select_screen.dart city_levels_screen.dart pulse_game_screen.dart
  widgets/ pulse_hud.dart pulse_controls.dart level_complete_sheet.dart game_texts.dart
  theme/   (mevcut app_colors/app_theme/motion → buraya taşınır)
assets/levels/ index.json ANK-01.json ANK-02.json
tool/solve_levels.dart
docs/ GAME_DESIGN_V2.md LEVEL_FORMAT.md ART_DIRECTION.md SOURCE_MAPS_AND_LICENSES.md DECISIONS.md ARCHITECTURE.md
```

---

### Task 1: V2 dokümanları ve branch

**Files:** Modify `CLAUDE.md`, `GAME_DESIGN.md` (V2'ye yönlendiren kısa özet), `TASKS.md`, `PROGRESS.md`, `docs/DECISIONS.md`, `docs/ARCHITECTURE.md`; Create `docs/ART_DIRECTION.md`, `docs/SOURCE_MAPS_AND_LICENSES.md`.

- [ ] **Step 1:** `git checkout -b claude/v2-night-pulse`
- [ ] **Step 2: `docs/DECISIONS.md`** — "V2 çatışmaları" bölümü: swipe → NIGHT PULSE; İstanbul → kaldırıldı (Paris 3. şehir); ızgara → graf; ipucu düğmesi kaldırıldı (spec "tam çözüm otomatik gösterilmez"); yıldız hamle değil pulse üzerinden; D-008/D-012/D-014 (ızgara/swipe kararları) geçersiz. Yeni kararlar: D-015 makasın üstünde tren varken de makas değiştirilebilir (spec yasaklamıyor; çıkış yeni seçime göre); D-016 çözücü durum anahtarı pulse sayacını içermez, derinlik `maxPulses` ile budanır (BFS en kısa yolu yine bulur, durum uzayı küçülür); D-017 her seviye JSON'unda kayıtlı `solution` zorunlu, validator replay eder (Moskova'da çözücü sınıra takılırsa güvence); D-018 başlangıç düğümü yalnız `depot`.
- [ ] **Step 3: `docs/SOURCE_MAPS_AND_LICENSES.md`** — spec §13'teki 11 URL; "referans ≠ ticari yeniden kullanım" açıklaması; TfL lisans notu; OSM/ODbL notu; kullanılan paketlerin lisansları.
- [ ] **Step 4: `docs/ART_DIRECTION.md`** — "Midnight Transit"; 5 şehir paleti (Ankara kırmızı-altın, Bakü Hazar laciverti + kumtaşı, Paris indigo + krem + amber, Londra yağmur grisi + sarı/bordo, Moskova kar beyazı + koyu kırmızı + soğuk mavi; resmî hat renkleri değil); bileşenler (`NetworkPainter`, `TrainLayer`); Global Constraints'teki animasyon süreleri; kabul kriterleri (16 düğüm 320 pt genişlikte okunur, sembol + renk).
- [ ] **Step 5:** `CLAUDE.md` okuma sırasına `docs/GAME_DESIGN_V2.md` (ilk sıraya) eklenir; `TASKS.md` V2 P0/P1/P2 + efor + bağımlılık + kabul kriteriyle yeniden yazılır; `ARCHITECTURE.md` graf modeline göre güncellenir.
- [ ] **Step 6:** `scripts/check.sh` → yeşil. **Commit:** `docs: adopt V2.1 NIGHT PULSE design`

---

### Task 2: Graf domain modeli

**Files:** Create `lib/game/domain/{norm_point,node,edge,switch_def,signal_aspect,train_def,train_state,game_state,control_action,pulse_result,level_definition,city,localized_text}.dart`; Modify `star_rating.dart`. Test: `test/game/domain/graph_domain_test.dart`.

**Interfaces (Produces):**
```dart
final class NormPoint { const NormPoint(this.x, this.y); final double x, y; }           // 0.0–1.0
enum NodeKind { depot, track, junction, signal, goal, terminal }                      // JSON "switch" → junction
final class Node { const Node({required this.id, required this.kind, required this.position, this.label}); }
final class Edge { const Edge({required this.id, required this.a, required this.b}); String other(String nodeId); bool touches(String nodeId); }
enum SwitchBranch { a, b; SwitchBranch get toggled; }
final class SwitchDef { const SwitchDef({required this.nodeId, required this.trunkEdge, required this.branchAEdge, required this.branchBEdge});
  String edgeFor(SwitchBranch b); }
enum SignalAspect { red, green; SignalAspect get toggled; }
enum TrainSymbol { circle('●'), triangle('▲'), square('■'), diamond('◆'); final String glyph; }
enum TrainStyle { coral, azure, lime, amber }
final class TrainDef { const TrainDef({required this.id, required this.startNode, required this.goalNode, required this.symbol, required this.style}); }
final class TrainState { const TrainState({required this.id, required this.nodeId, this.incomingEdgeId, this.delivered = false});
  TrainState copyWith({String? nodeId, String? incomingEdgeId, bool? delivered}); }             // ==
final class GameState { GameState({required List<TrainState> trains, required Map<String, SwitchBranch> switches,
  required Map<String, SignalAspect> signals, this.pulse = 0});
  TrainState? trainAt(String nodeId);  // teslim edilmemiş
  bool get allDelivered; String get searchKey; /* pulse hariç */ GameState copyWith({...}); }   // == tüm alanlar (pulse dahil)
sealed class ControlAction { const ControlAction(); }
final class ToggleSwitch extends ControlAction { const ToggleSwitch(this.nodeId); }           // ==
final class ToggleSignal extends ControlAction { const ToggleSignal(this.nodeId); }           // ==
enum PulseFailure { collision, headOn, blockedByStanding, wrongGoal, outOfPulses, alreadySolved, invalidControl }
sealed class PulseResult { const PulseResult(); }
final class PulseApplied extends PulseResult { const PulseApplied(this.state, {this.delivered = const []}); }
final class PulseFailed extends PulseResult { const PulseFailed(this.reason, {this.trainIds = const [], this.nodeId}); }
enum CityId { ankara(1), baku(2), paris(3), london(4), moscow(5); final int difficulty; }
final class LocalizedText { const LocalizedText({required this.tr, required this.en}); String of(String languageCode); }
final class LevelDefinition { const LevelDefinition({required this.id, required this.city, required this.number,
  required this.title, required this.maxPulses, required this.parPulses, this.tutorial = false,
  required this.nodes, required this.edges, this.switches = const {}, this.initialSwitches = const {},
  this.initialSignals = const {}, required this.trains, this.tutorialSteps = const [], this.solution = const []});
  // nodes/edges/switches: Map<String, …> id → değer;  solution: List<ControlAction?> (null = bekle)
  List<Edge> edgesOf(String nodeId); GameState get initialState; }
// star_rating.dart → StarRating.forPulses({required int pulses, required int par})
```

- [ ] **Step 1: Failing testler**
```dart
expect(const Edge(id: 'AB', a: 'A', b: 'B').other('A'), 'B');
expect(SwitchBranch.a.toggled, SwitchBranch.b); expect(SignalAspect.red.toggled, SignalAspect.green);
expect(sw.edgeFor(SwitchBranch.b), 'BD');
expect(GameState(trains: [t2, t1], switches: {}, signals: {}), GameState(trains: [t1, t2], switches: {}, signals: {}));
expect(s.copyWith(pulse: 3).searchKey, s.searchKey);  expect(s.copyWith(pulse: 3), isNot(s));
expect(GameState(trains: [t1.copyWith(delivered: true)], switches: {}, signals: {}).trainAt(t1.nodeId), isNull);
expect(ank01.edgesOf('B').map((e) => e.id), unorderedEquals(['AB', 'BC', 'BD']));
expect([2, 3, 4, 5].map((p) => StarRating.forPulses(pulses: p, par: 2)),
    [StarRating.gold, StarRating.silver, StarRating.silver, StarRating.bronze]);
expect(const LocalizedText(tr: 'İlk Sefer', en: 'First Departure').of('tr'), 'İlk Sefer');
```
`test/support/graph_builders.dart` aynı görevde: `ank01()` (spec §8 JSON'unun birebir Dart karşılığı) ve `ank02()` (Görev 7'deki şekil), `chainLevel()`, `headOnLevel()`, `cycleLevel()`, `signalLevel()` (Görev 3 testleri için, aşağıda).
- [ ] **Step 2:** FAIL doğrula — `flutter test test/game/domain/graph_domain_test.dart`
- [ ] **Step 3:** Domain dosyalarını yaz (koleksiyonlar unmodifiable; `GameState` trenleri id'ye göre sıralı).
- [ ] **Step 4:** PASS + `test/architecture_test.dart` PASS.
- [ ] **Step 5: Commit** — `feat(domain): graph model for NIGHT PULSE`

---

### Task 3: PulseEngine — hareket, makas, sinyal, çarpışma

**Files:** Create `lib/game/engine/pulse_engine.dart`. Test: `test/game/engine/pulse_engine_test.dart`.

**Interfaces (Produces):**
```dart
final class PulseEngine { PulseEngine(this.level);
  GameState applyAction(GameState s, ControlAction? a);   // yalnız kontrol değişimi; tren hareketi yok
  String? nextNodeOf(GameState s, TrainState t);          // null = bu pulse bekler
  PulseResult simulatePulse(GameState s, ControlAction? a);
  Iterable<ControlAction?> actions(GameState s);          // [null, switch'ler id sırasıyla, sinyaller id sırasıyla]
  bool isSolved(GameState s); bool isOutOfPulses(GameState s); }
```
**Çıkış kuralı (`nextNodeOf`)**, gelen kenar `in`:
- teslim edilmiş → null · `signal` düğümü ve kırmızı → null
- `depot` (`in == null`) → tek kenarı · `track`/`signal` → `in` dışındaki tek kenar
- `junction`: `in == trunk` → seçili kol; `in == seçili kol` → trunk; `in == pasif kol` → null (bekle)
- `goal`/`terminal` → null (çıkmaz; geri dönüş yok)

**`simulatePulse` sırası (spec §3.2-B):** (1) `isSolved` → `PulseFailed(alreadySolved)`; `pulse >= maxPulses` → `outOfPulses`; aksiyon geçersiz düğüme ise `invalidControl`. (2) `applyAction`. (3) Her aktif tren için hedef, **aynı başlangıç durumundan** hesaplanır. (4) Denetim, ilk tutan hata döner: aynı hedef → `collision`; karşılıklı yer değiştirme → `headOn`; hedefte duran (bu pulse hareket etmeyen) tren → `blockedByStanding`; başka trenin `goal`'üne giriş → `wrongGoal`. (5) Hepsi geçerse tek seferde commit: konum + `incomingEdgeId` güncellenir, kendi hedefine giren `delivered = true`, `pulse + 1`.

- [ ] **Step 1: Failing testler** (spec §9 testleri 1–7)
```dart
test('single train advances one edge per pulse')          // ank01: pulse(null) → red_1 @B, incoming AB, pulse 1
test('switch routes trunk traffic to the selected branch')  // ank01 @B: pulse(ToggleSwitch('B')) → @C delivered
test('wrong branch leads to the terminal')                 // ank01 @B: pulse(null) → @D (terminal), sonraki pulse bekler
test('train arriving on the passive branch waits')         // ank02: A→B branch a'dan gelir, seçili b → nextNodeOf null
test('toggling under a waiting train releases it')         // ank02 @B: pulse(ToggleSwitch('B')) → @C
test('two trains into one empty node collide, state untouched') // PulseFailed(collision); s aynen
test('head-on swap collides')                              // headOnLevel → PulseFailed(headOn)
test('entering a node that is being vacated is allowed')   // chainLevel → PulseApplied
test('three-train rotation is allowed')                    // cycleLevel → PulseApplied
test('standing train blocks the node behind it')           // PulseFailed(blockedByStanding)
test('wrong goal is rejected')                             // PulseFailed(wrongGoal)
test('red signal holds, green lets go')                    // signalLevel
test('delivered train no longer occupies its goal')        // teslimden sonra trainAt(goal) null
test('a failed pulse keeps pulse count')                   // pulse değişmez
test('actions offer wait plus one toggle per control')     // ank01: [null, ToggleSwitch('B')]
```
- [ ] **Step 2:** FAIL · **Step 3:** Implement · **Step 4:** PASS — `flutter test test/game/engine/pulse_engine_test.dart`
- [ ] **Step 5: Commit** — `feat(engine): simultaneous pulse simulation with collision rules`

---

### Task 4: GameSession (undo, restart, maxPulses)

**Files:** Rewrite `lib/game/engine/game_session.dart` (aynı dosya adı, yeni içerik). Test: `test/game/engine/pulse_session_test.dart`.

**Interfaces:** `GameSession(LevelDefinition level)` · `GameState get state` · `int get pulses` · `bool get isSolved / isLost / canUndo` · `PulseResult pulse(ControlAction? a)` · `bool undo()` · `void restart()`. `isLost` = `isOutOfPulses(state)`.

- [ ] **Step 1: Failing testler** (spec §9 testleri 8–9)
```dart
test('successful pulse is undoable and restores switches too')  // toggle+pulse; undo → state == önceki (makas dahil)
test('failed pulse does not enter history')                     // canUndo false kalır
test('running out of pulses is a loss, undo recovers')          // maxPulses kadar yanlış pulse → isLost; undo → !isLost
test('winning on the last allowed pulse counts as solved')
test('restart returns to the initial state')
```
- [ ] **Step 2–4:** FAIL → Implement → PASS
- [ ] **Step 5: Commit** — `feat(engine): pulse session with undo and pulse limit`

---

### Task 5: PulseSolver

**Files:** Create `lib/game/engine/pulse_solver.dart`. Test: `test/game/engine/pulse_solver_test.dart`.

**Interfaces:** `sealed class SolveResult` → `Solved(List<ControlAction?> plan)`, `Unsolvable()`, `SearchLimitReached()`; `final class PulseSolver { const PulseSolver({this.maxStates = 200000}); SolveResult solve(LevelDefinition level, {GameState? from}); }`.
Algoritma: BFS, ziyaret anahtarı `searchKey` (D-016), genişletme `PulseEngine.actions` sırasıyla, yalnız `PulseApplied` dalları, derinlik `> maxPulses` budanır, `visited.length > maxStates` → `SearchLimitReached`.

- [ ] **Step 1: Failing testler**
```dart
expect((solver.solve(ank01()) as Solved).plan, [null, const ToggleSwitch('B')]);   // par 2; ilk bulunan bekle-sonra-çevir
expect((solver.solve(ank02()) as Solved).plan, hasLength(3));
expect(solver.solve(deadlockLevel), isA<Unsolvable>());
expect(const PulseSolver(maxStates: 2).solve(ank02()), isA<SearchLimitReached>());
expect(solver.solve(ank02()), solver.solve(ank02()));   // deterministik (plan listeleri eşit)
```
> Not: ANK-01'de `[ToggleSwitch('B'), null]` da 2 pulse'lık geçerli çözüm; BFS sırası `null`'ı önce dener — test bu sırayı sabitler.
- [ ] **Step 2–4:** FAIL → Implement → PASS
- [ ] **Step 5: Commit** — `feat(engine): BFS pulse solver`

---

### Task 6: JSON codec, aksiyon kodlaması, validator, LEVEL_FORMAT

**Files:** Rewrite `lib/game/data/level_json_codec.dart`; Create `lib/game/data/action_codec.dart`; Rewrite `lib/game/engine/level_validator.dart`, `docs/LEVEL_FORMAT.md`. Tests: `test/game/data/level_json_codec_test.dart`, `test/game/engine/level_validator_test.dart` (eski içerik silinir).

**Format:** spec §8 JSON'u + iki ek alan: `"number": 1`, `"tutorial": true|false`, `"solution": ["wait", "switch:B"]`; sinyal: `"signals": [{"nodeId": "S1", "initial": "red"}]`. Aksiyon dizgesi: `wait` | `switch:<nodeId>` | `signal:<nodeId>` (`ActionCodec.decode/encode`).

**Validator kodları:** `duplicateId`, `unknownReference`, `positionOutOfRange`, `ambiguousTrack` (track/signal ≠ 2 kenar), `badDegree` (depot/goal/terminal ≠ 1 kenar, junction ≠ 3), `invalidSwitch` (3 kenar farklı ve hepsi o düğüme bağlı değil / düğüm junction değil), `signalOnNonSignalNode`, `trainNotOnDepot`, `goalNotGoalNode`, `sharedGoalOrStart`, `parExceedsMax`, `solutionFails` (kayıtlı çözüm replay'de çözmüyor veya uzunluğu ≠ `parPulses`), `parBelowOptimum` (çözücü daha kısa bulmuş → `parPulses` yükseltilmeli değil düşürülmeli; detail'de optimum), `unsolvable` (çözücü `Unsolvable`; `SearchLimitReached` ise **hata değil**, replay yeterli — D-017).

- [ ] **Step 1: Failing testler** — codec: spec §8 ANK-01 JSON'u → `ank01()` ile alan alan eşit; `"kind": "bridge"` / eksik `"x"` / bilinmeyen kenar referansı → `LevelFormatException(levelId: 'ANK-01')`; `ActionCodec.decode('switch:B') == ToggleSwitch('B')`, `decode('wait') == null`, `decode('jump:B')` → exception. Validator: `ank01()`/`ank02()` → `isEmpty`; her kod için tek noktadan bozulmuş fixture.
- [ ] **Step 2–4:** FAIL → Implement → PASS
- [ ] **Step 5: Commit** — `feat(data): V2 level format, action codec and validator`

---

### Task 7: ANK-01, ANK-02 asset'leri, repository, araç

**Files:** Delete `assets/levels/level_00{1,2,3}.json`; Create `assets/levels/ANK-01.json`, `ANK-02.json`; Rewrite `assets/levels/index.json`, `lib/game/data/level_index.dart`, `asset_level_repository.dart`, `tool/solve_levels.dart`; `LevelRepository.loadAll()` → `Future<List<LevelDefinition>> loadCity(CityId city)`. Tests: `test/levels/level_assets_test.dart`, `test/game/data/asset_level_repository_test.dart`.

**index.json:** `{"cities": [{"id": "ankara", "levels": ["ANK-01.json", "ANK-02.json"]}, {"id": "baku", "levels": []}, {"id": "paris", "levels": []}, {"id": "london", "levels": []}, {"id": "moscow", "levels": []}]}`
**ANK-01:** spec §8 JSON'u aynen + `number: 1`, `tutorial: true`, `solution: ["wait", "switch:B"]`.
**ANK-02 "Kızılay Yönü"** (5 düğüm, 1 tren, tutorial: true): `A` depot (0.12, 0.30) —`AB` (makasın **A kolu**)— `B` junction (0.45, 0.50) —`BC` (trunk)— `C` track (0.70, 0.50) —`CD`— `D` goal (0.90, 0.50); `B` —`BE` (B kolu)— `E` terminal (0.40, 0.85). Başlangıç seçili kol **b** (E'ye açık). Tren A'dan B'ye pasif koldan gelir ve bekler. `maxPulses: 6`, `parPulses: 3`, `solution: ["switch:B", "wait", "wait"]`. Öğretici: `{"tr": "Tren kapalı koldan gelirse bekler.", "en": "A train on a closed branch waits."}`.

- [ ] **Step 1: Failing testler** — her indeksli dosya validator'dan `isEmpty`; ID'ler benzersiz ve `ANK-0n`; `loadCity(CityId.ankara)` → `['ANK-01', 'ANK-02']`; `loadCity(CityId.baku)` → boş.
- [ ] **Step 2–4:** FAIL → JSON + repository + araç → PASS; `dart run tool/solve_levels.dart` → `ANK-01 issues=0 optimal=2 par=2`, `ANK-02 issues=0 optimal=3 par=3`, çıkış 0.
- [ ] **Step 5: Commit** — `feat(levels): ANK-01 and ANK-02 for NIGHT PULSE`

---

### Task 8: PulseController

**Files:** Create `lib/game/presentation/game/{pulse_controller,game_event}.dart`. Test: `test/game/presentation/pulse_controller_test.dart`.

**Interfaces:**
```dart
sealed class GameEvent; PulseCommitted(GameState before, GameState after, List<String> delivered);
PulseRejected(PulseFailure reason, List<String> trainIds, String? nodeId); LevelWon(LevelResult r); LevelLost();
final class PulseController extends ChangeNotifier { PulseController({required LevelDefinition level});
  GameState get state; ControlAction? get pending; int get pulses; int get maxPulses;
  bool get isAnimating; bool get isSolved; bool get isLost; bool get canUndo; Stream<GameEvent> get events;
  void tapNode(String nodeId);   // junction → ToggleSwitch, signal → ToggleSignal; aynı düğüm tekrar → iptal; başkası → değiştir; diğer düğüm → yok
  void cancelPending(); void advance(); void undo(); void restart();
  void finishAnimation(); }       // ekran, tween bitince çağırır; isAnimating false olur
```
Davranış: `advance` başarılıysa `pending = null`, `isAnimating = true`, `PulseCommitted` yayılır; çözümse `LevelWon`, `isLost` olduysa `LevelLost` (animasyon bitince UI gösterir). Başarısızsa `PulseRejected`, `pending` korunur. `isAnimating` iken `tapNode/advance/undo/restart` yok sayılır. `LevelResult.rating` tutorial'da null.

- [ ] **Step 1: Failing testler** — seçme/değiştirme/iptal (pulse ve state değişmez); başarılı advance → event + `isAnimating`; animasyon sırasında ikinci `advance` yok sayılır (pulses 1); `finishAnimation` sonrası ikinci advance işler; çarpışmada `PulseRejected` + pending korunur; ANK-01 2 pulse → `LevelWon` (tutorial → rating null); `maxPulses` dolunca `LevelLost`; undo → pulses ve makas geri.
- [ ] **Step 2–4:** FAIL → Implement → PASS
- [ ] **Step 5: Commit** — `feat(presentation): pulse controller with pending action`

---

### Task 9: Tahta çizimi ve pulse animasyonu

**Files:** Create `lib/game/presentation/board/{board_layout,network_painter,train_layer,board_view}.dart`. Tests: `test/game/presentation/board_layout_test.dart`, `board_view_test.dart`.

**Interfaces:**
- `BoardLayout({required Size size, double padding = 32})` → `Offset toScreen(NormPoint p)`; `String? nodeAt(Offset local, Map<String, Node> nodes, {double hitRadius = 28})` (en yakın düğüm, yarıçap içinde).
- `NetworkPainter({level, state, pending, layout, double pulseWave /*0..1*/})` — kenarlar; makasın aktif kolu parlak, pasif kol soluk, `pending` makas/sinyal için önizleme (seçilecek kol vurgulu); sinyal ışığı; hedefler tren sembolü + rengiyle; terminal çizgi sonu; `pulseWave` ile kenarlar boyunca kısa ışık dalgası.
- `TrainLayer({level, before, after, Animation<double> progress, layout})` — her tren `lerp(toScreen(before.node), toScreen(after.node), Curves.easeInOut(progress))`; teslim edilen tren son %25'te küçülüp ✓'e döner.
- `BoardView({controller})` — `StatefulWidget` + `SingleTickerProviderStateMixin`; `AnimationController(duration: kPulseMove /*400ms*/)`; `PulseCommitted` gelince `forward(from: 0)` → bitince `controller.finishAnimation()`; `PulseRejected` → 300 ms kırmızı flaş + `HapticFeedback.heavyImpact`; `onTapUp` → `nodeAt` → `tapNode`. Uygulama arka plana geçerse (`AppLifecycleState.paused`) animasyon anında sona sarılır (spec §7).
- `motion.dart`'a sabitler: `kPulseMove 400`, `kSwitchFlip 180`, `kSignalFade 150`, `kPulseWave 100`, `kArrival 300`, `kCollisionFlash 300`, `kLevelComplete 700` ms.

- [ ] **Step 1: Failing testler** — `toScreen(NormPoint(0,0))` = `Offset(32,32)`, `(1,1)` = `size - 32`; `nodeAt` yarıçap içi/dışı; widget: ANK-01'de B'ye dokun → `pending == ToggleSwitch('B')`; advance + `pump(200ms)` → tren A ile B arasında; `pumpAndSettle` → B'de ve `isAnimating` false; 16 düğümlü fixture 320×568'de `takeException()` null.
- [ ] **Step 2–4:** FAIL → Implement → PASS
- [ ] **Step 5: Commit** — `feat(presentation): network painter and simultaneous pulse animation`

---

### Task 10: Ekranlar + UI süsleme paketi (kullanıcı kararı)

**Files:** Create `lib/game/presentation/screens/{home_screen,city_select_screen,city_levels_screen,pulse_game_screen}.dart`, `widgets/{pulse_hud,pulse_controls,level_complete_sheet,game_texts}.dart`; Modify ARB'ler, `main.dart`. Test: `test/game/presentation/screens_test.dart`.

- **HomeScreen:** "SON SEFER BAŞLIYOR" · `DEVAM ET` (Faz V2-B'de kayıtla dolacak; şimdilik Ankara-01'i açar) · `ŞEHİR SEÇ`.
- **CitySelectScreen:** 5 kart, zorluk yıldızları (★☆☆☆☆…), Moskova alt yazısı "NIGHTMARE NETWORK"; bölümü olmayan şehir `Yakında` (satın alınabilir gibi değil); altta "Gerçek şehirlerden esinlenen kurgusal metro bulmacaları."
- **CityLevelsScreen:** şehrin bölümleri nokta/kart listesi (`ANK-01 İlk Sefer`).
- **PulseGameScreen:** HUD `LAST TRAIN · ANKARA 01` / `1/5 PULSE · 🚆 0/1` / `Kontrol: 1/1`; öğretici adımları (≤ 2 satır); `BoardView`; bekleyen kontrol çipi + `İptal`; `Geri Al` / `Baştan`; büyük `▶ 1 DAKİKA İLERLET` düğmesi; olaylar → kayıp sayfası (`Geri Al` / `Tekrar Oyna`), başarı sayfası (tutorial'da yıldızsız).
- **Paket kararı:** Kullanıcı onaylarsa `flutter_animate` (düğme/çip/yıldız/sayfa girişleri, çarpışma sallanması) + `animations` (ekran geçişleri: shared axis / fade through) eklenir, sürümler `docs/DECISIONS.md` ve `SOURCE_MAPS_AND_LICENSES.md`'ye yazılır. Onay yoksa aynı efektler `AnimatedSwitcher`/`AnimatedScale`/`PageRouteBuilder` ile yapılır. **Tahta animasyonları her iki durumda da Görev 9'daki yerleşik çözümle kalır.**
- [ ] **Step 1: Failing testler** — home → şehir seçimi → Ankara → ANK-01; ANK-01'i B'ye dokun + iki kez `1 DAKİKA İLERLET` ile bitir → başarı sayfası; Bakü kartı `Yakında` ve dokununca bir şey açmaz; çarpışma fixture'ında reddedilen pulse sonrası pulse sayacı değişmez; TR dilinde `1 DAKİKA İLERLET`, EN'de `ADVANCE 1 MINUTE`; 320×568'de taşma yok.
- [ ] **Step 2–4:** FAIL → Implement → PASS; iOS simülatörde ANK-01 ve ANK-02 elle oynanır, sonuç `PROGRESS.md`'ye.
- [ ] **Step 5: Commit** — `feat(presentation): city flow and pulse game screen`

---

### Task 11: Eski ızgara mekaniğini kaldır

**Files:** Delete: `lib/game/domain/{direction,grid_pos,cell,train,board_state,move,move_result}.dart`, `lib/game/engine/{track_connectivity,game_rules,level_solver}.dart`, `lib/game/ui/**` (tema dosyaları `presentation/theme/`'e `git mv`), ilgili testler (`test/game/domain/domain_test.dart`, `train_movement_test.dart`, `switch_and_goal_test.dart`, `level_solver_test.dart`, `test/game/ui/**`, `test/support/level_builders.dart`). ARB'den kullanılmayan anahtarlar (`blocked*`, `hint*`, `tutorialSelectSwipe` …) silinir. Mimari test yolları güncellenir.

- [ ] **Step 1:** `grep -rn "GridPos\|TrackCell\|swipe\|Istanbul\|istanbul\|IST-" lib test assets docs/LEVEL_FORMAT.md` → yalnız silinecek dosyalarda.
- [ ] **Step 2:** Sil/taşı; `scripts/check.sh` → yeşil; `grep` tekrar → boş.
- [ ] **Step 3: Commit** — `refactor: remove grid and swipe mechanic`

---

### Task 12: Son doğrulama ve teslim

- [ ] `scripts/check.sh`, `dart run tool/solve_levels.dart`, `flutter build web --release`, `flutter build ios --simulator --debug` → gerçek çıktılar `PROGRESS.md`'ye; `TASKS.md` kutuları; sıradaki görev = V2-B planı (ANK-03…06).
- [ ] **Commit** — `docs: V2 core progress`. Push yalnız kullanıcı onayıyla.
