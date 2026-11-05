# SwipeOut: Last Train — Faz 0 + Faz 1 (Oynanabilir Çekirdek) Uygulama Planı

> **DURUM: YERİNİ ALDI (05.11.2026).** Oyun mekaniği `docs/GAME_DESIGN_V2.md` (V2.1, NIGHT PULSE) ile değişti. Bu plan ızgara + swipe mekaniği içindir; tamamlandı ama yeni plan `2026-11-05-v2-night-pulse-cekirdek.md` geçerlidir.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Saf Dart oyun motoru, BFS çözücü, seviye doğrulayıcı ve 3 öğretici bölümle uçtan uca oynanabilir, TR/EN destekli bir Flutter iskeleti üretmek.

**Architecture:** Katmanlı yapı: `domain` (immutable değer nesneleri) → `engine` (saf kurallar, oturum, çözücü, doğrulayıcı) → `data` (JSON codec, asset repository) → `ui` (ChangeNotifier controller + CustomPainter tahta). `domain` ve `engine` Flutter'a hiç bağımlı değildir (test ile zorlanır). Bağımlılıklar constructor ile enjekte edilir; service locator veya state-management paketi yok.

**Tech Stack:** Flutter 3.32.8 (stable), Dart 3.8.1, `flutter_localizations` + `intl` (gen-l10n), `flutter_lints`, `fake_async` (dev).

**Spec:** `SwipeOut_Claude_Master_Prompt.md` (repo kökü). Uygulayıcı her görevden önce ilgili spec bölümünü (özellikle §3 kurallar) okur.

**Kapsam dışı (sonraki planlar):** Faz 2 — 12 bölüm, şehir seçimi, bölüm haritası, `shared_preferences` ile ilerleme + yarım kalan seviyeyi geri yükleme, ayarlar (ses/titreşim). Faz 3 — 30 bölüm, ses, erişilebilirlik turu, bölüm 4–5 undo/restart öğreticisi. Faz 4 — yayın hazırlığı. Her biri ayrı plan olacak.

## Global Constraints

- Flutter 3.32.8 / Dart 3.8.1; `pubspec.yaml` SDK kısıtı `flutter create`'in ürettiği değer.
- İzinli paketler: `flutter_localizations` (sdk), `intl`, dev: `flutter_lints`, `fake_async`. Flame, Riverpod/Bloc/Provider, Firebase, reklam, analytics, ağ paketi YOK.
- `lib/game/domain/**` ve `lib/game/engine/**` içinde `package:flutter` veya `dart:ui` importu YOK.
- Kod tanımlayıcıları İngilizce; dokümanlar ve kullanıcıyla iletişim Türkçe. Arayüzdeki her metin ARB'den gelir (EN + TR), sabit string yok.
- Dikey ekran (portrait) zorunlu; en küçük hedef ekran 320×568 logical px (iPhone SE 1. nesil).
- Izgara 5×5 ile 7×7 arası; koordinat sistemi x sağa, y aşağı artar; `north` = y−1.
- Bir hamle = tek kare tren adımı **veya** tek makas değişimi. Geçersiz işlem durumu değiştirmez, hamle saymaz.
- Tren adım animasyonu 180 ms (`kMoveAnimation`); animasyon sürerken yeni girdi işlenmez.
- Yıldız: altın ≤ optimum+1, gümüş ≤ optimum+4, diğer her çözüm bronz.
- Renk tek bilgi kaynağı değil: her tren ve istasyonda harf sembolü (R, B, G, A).
- Öğretici metinler en fazla 2 satır.
- Geçici bundle id: `com.example.swipeout_last_train`. Üretim id'si kullanıcı onayı olmadan uydurulmaz.
- Git: tüm işler `claude/bootstrap-swipeout` branch'inde; `main`'e commit/merge yok, force push yok, gizli anahtar yok. Her commit mesajı `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` ile biter.
- Clean code: SOLID/KISS/DRY. Varsayılan `final class`, varyantlar için `sealed class`, dosya başına tek sorumluluk (~200 satırı geçen dosya bölünür), yorum yerine anlamlı isim.
- "Geçti" demeden önce `scripts/check.sh` çalıştırılır ve gerçek çıktı `PROGRESS.md`'ye yazılır.

## Review Focus

1. **Çok kısa veya çapraz kaydırma** — 24 px altı yok sayılır; çapraz kaydırmada baskın eksen seçilir. (Görev 9: `directionFromDelta` testleri)
2. **Animasyon sırasında ardışık hızlı swipe** — ikinci swipe yok sayılır, hamle sayısı 1 artar. (Görev 9: input lock testi)
3. **Bozuk seviye JSON'u** (bilinmeyen hücre tipi, eksik alan, geçersiz yön harfi) — `TypeError` değil, seviye id'sini içeren `LevelFormatException`. (Görev 7)
4. **iPhone SE (320×568) + 7×7 tahta** — overflow/exception yok, tüm düğmeler görünür. (Görev 11)
5. **Büyük durum uzayında ipucu** — çözücü `maxStates` sınırında `SearchLimitReached` döner, UI donmaz, "ipucu yok" mesajı çıkar. (Görev 6 + Görev 9)

---

## Dosya Yapısı

```
lib/
  main.dart                         # portrait kilidi + runApp
  app.dart                          # SwipeOutApp: tema, l10n, composition root
  l10n/app_en.arb, app_tr.arb, generated/   # gen-l10n çıktısı commit'lenir
  game/
    domain/  direction.dart grid_pos.dart train_color.dart cell.dart train.dart
             board_state.dart level_definition.dart move.dart move_result.dart
             star_rating.dart level_result.dart
    engine/  track_connectivity.dart game_rules.dart undo_history.dart
             game_session.dart level_solver.dart level_validator.dart
    data/    level_json_codec.dart level_repository.dart asset_level_repository.dart
    ui/
      theme/   app_colors.dart app_theme.dart motion.dart
      game/    game_controller.dart game_event.dart hint_runner.dart swipe_direction.dart
      board/   board_geometry.dart board_painter.dart train_token.dart board_view.dart
      screens/ home_screen.dart level_list_screen.dart game_screen.dart
      widgets/ game_hud.dart game_controls.dart level_complete_sheet.dart
assets/levels/ index.json level_001.json level_002.json level_003.json
tool/solve_levels.dart              # seviye yazarlığı: optimumu hesaplar/doğrular
scripts/check.sh scripts/bootstrap.sh
test/ architecture_test.dart support/level_builders.dart game/... levels/...
```

---

### Task 1: Proje iskeleti, yönetim dokümanları ve kontrol script'i

**Files:**
- Create: Flutter projesi (`flutter create`), `analysis_options.yaml` (düzenle), `l10n.yaml`, `lib/l10n/app_en.arb`, `lib/l10n/app_tr.arb`, `lib/main.dart`, `lib/app.dart`, `lib/game/ui/theme/{app_colors,app_theme,motion}.dart`, `scripts/check.sh`
- Create (docs): `README.md`, `CLAUDE.md`, `GAME_DESIGN.md`, `TASKS.md`, `PROGRESS.md`, `docs/DECISIONS.md`
- Test: `test/app_smoke_test.dart`

**Interfaces:**
- Produces: `SwipeOutApp({required Widget home, Locale? locale})` (MaterialApp, koyu tema, `AppLocalizations` delegeleri, `supportedLocales: [en, tr]`); `AppColors` token'ları; `const kMoveAnimation = Duration(milliseconds: 180)`; `scripts/check.sh` (format → analyze → test, ilk hatada çıkış kodu ≠ 0).

- [ ] **Step 1: Branch aç ve Flutter projesini oluştur**

```bash
cd /Applications/Projects/SwipeOut-Last-Train
git checkout -b claude/bootstrap-swipeout
flutter create --project-name swipeout_last_train --org com.example --platforms ios,android,web .
flutter pub add flutter_localizations --sdk=flutter
flutter pub add intl:any
flutter pub add --dev fake_async
```
Beklenen: `flutter create` mevcut `SwipeOut_Claude_Master_Prompt.md` dosyasına dokunmaz; `git status` yeni dosyaları gösterir.

- [ ] **Step 2: Lint ve l10n yapılandırması**

`analysis_options.yaml`: `include: package:flutter_lints/flutter.yaml`, `analyzer.language: {strict-casts: true, strict-inference: true, strict-raw-types: true}`, ek kurallar: `prefer_final_locals`, `prefer_const_constructors`, `always_declare_return_types`, `avoid_dynamic_calls`, `directives_ordering`.
`l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-dir: lib/l10n/generated`, `synthetic-package: false`, `nullable-getter: false`. `pubspec.yaml` → `flutter: generate: true`, `assets: [assets/levels/]`.
iOS `ios/Runner/Info.plist` ve Android manifest'te yalnızca portrait yönü bırak.

- [ ] **Step 3: ARB anahtarlarını yaz** (EN / TR — tüm planın metinleri burada)

| key | EN | TR |
|---|---|---|
| appTitle | SwipeOut: Last Train | SwipeOut: Last Train |
| play | Play | Oyna |
| cityIstanbul | ISTANBUL | İSTANBUL |
| levelLabel(number) | LEVEL {number} | BÖLÜM {number} |
| moves(count) | Moves: {count} | Hamle: {count} |
| undo / restart / hint | Undo / Restart / Hint | Geri Al / Baştan / İpucu |
| levelComplete | Line cleared! | Hat temiz! |
| next / replay | Next / Replay | Sonraki / Tekrar |
| tutorialSelectSwipe | Tap the train, then swipe to move it one square. | Trene dokun, sonra kaydırarak bir kare ilerlet. |
| tutorialSwitch | Tap the switch to change its route. Each tap is a move. | Yönü değiştirmek için makasa dokun. Her dokunuş bir hamle. |
| tutorialOrder | Trains can't pass each other. Choose who goes first. | Trenler birbirinin içinden geçemez. Önce kim gidecek, seç. |
| blockedWrongStation | Wrong station for this train. | Bu tren için yanlış istasyon. |
| blockedOccupied | Another train is in the way. | Yolda başka bir tren var. |
| blockedNoTrack | No track in that direction. | O yönde ray yok. |
| blockedSwitchOccupied | A train is on the switch. | Makasın üstünde tren var. |
| selectTrainFirst | Tap a train first. | Önce bir trene dokun. |
| hintUnavailable | No hint available right now. | Şu an ipucu yok. |

- [ ] **Step 4: Smoke testi yaz** — `test/app_smoke_test.dart`

```dart
testWidgets('app renders title on placeholder home', (tester) async {
  await tester.pumpWidget(const SwipeOutApp(home: _TitleProbe()));
  expect(find.text('SwipeOut: Last Train'), findsOneWidget);
});
// _TitleProbe: Text(AppLocalizations.of(context).appTitle)
```

- [ ] **Step 5: `lib/app.dart`, `lib/main.dart`, tema dosyalarını yaz.** `main` → `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`, geçici `home: Scaffold(body: Center(child: Text(l10n.appTitle)))`. `AppColors`: `background #0B1020`, `surface #141B2E`, `track #8A93B2`, `trackInactive #3A4260`, `accentTurquoise #2EC4B6`, `accentRed #E5484D`, `accentAmber #F5A524`, `trainBlue #3B82F6`, `trainGreen #22C55E`.

- [ ] **Step 6: `scripts/check.sh`** — `set -euo pipefail; dart format --output=none --set-exit-if-changed .; flutter analyze; flutter test`. `chmod +x`.

- [ ] **Step 7: Dokümanları yaz**
  - `CLAUDE.md`: Türkçe iletişim kuralı; oturum başı okuma sırası (`CLAUDE.md → GAME_DESIGN.md → TASKS.md → PROGRESS.md → docs/DECISIONS.md → git log -5`); test komutu `scripts/check.sh`; Global Constraints'teki katman/paket/git/güvenlik kuralları; "doğrulamadan iddia etme" kuralı.
  - `GAME_DESIGN.md`: spec §2–§4'ün özeti + bu plandaki kesin kurallar (koordinat, hamle, yıldız).
  - `TASKS.md`: P0 = bu plandaki 12 görev (her biri kabul kriteriyle), P1 = Faz 2 maddeleri, P2 = Faz 3–4.
  - `PROGRESS.md`: spec §8 formatında ilk kayıt (ortam: Flutter 3.32.8, Dart 3.8.1, Xcode 26.4.1, `gh` yok, remote boş repo).
  - `docs/DECISIONS.md`: D-001 state management paketi yok (ChangeNotifier yeterli); D-002 gen-l10n çıktısı commit'lenir (bulut ortamında analyze için); D-003 hamle sayısı = undo geçmişi uzunluğu (undo sayacı düşürür); D-004 koordinat sistemi y-aşağı; D-005 animasyon 180 ms. Sonraki görevler kendi kararlarını ekler.
  - `README.md`: tek paragraf tanım, `flutter run`, `scripts/check.sh`.

- [ ] **Step 8: Doğrula**

Run: `flutter pub get && scripts/check.sh`
Expected: format temiz, `No issues found!`, `All tests passed!`

- [ ] **Step 9: Commit** — `chore: bootstrap flutter project, docs and check script`

---

### Task 2: Domain değer nesneleri + katman sınırı testi

**Files:**
- Create: `lib/game/domain/{direction,grid_pos,train_color,cell,train,board_state,level_definition,move,move_result,star_rating,level_result}.dart`, `docs/ARCHITECTURE.md`
- Test: `test/game/domain/domain_test.dart`, `test/architecture_test.dart`

**Interfaces (Produces):**
```dart
enum Direction { north(0, -1, 'N'), east(1, 0, 'E'), south(0, 1, 'S'), west(-1, 0, 'W');
  final int dx, dy; final String code; Direction get opposite; }
final class GridPos { const GridPos(this.x, this.y); final int x, y; GridPos step(Direction d); } // ==, hashCode, toString
enum TrainColor { red('R'), blue('B'), green('G'), amber('A'); final String symbol; }
enum TrackKind { straight, corner, depot }
enum SwitchBranch { a, b; SwitchBranch get toggled; }
sealed class Cell { const Cell(); }
final class EmptyCell extends Cell {}      final class BlockedCell extends Cell {}
final class TrackCell extends Cell { const TrackCell(this.kind, this.ports); final TrackKind kind; final Set<Direction> ports; }
final class StationCell extends Cell { const StationCell(this.color, this.ports); final TrainColor color; final Set<Direction> ports; }
final class SwitchCell extends Cell { const SwitchCell({required this.common, required this.branchA, required this.branchB});
  final Direction common, branchA, branchB; Set<Direction> portsFor(SwitchBranch b); }
final class Train { const Train({required this.id, required this.color, required this.position, this.delivered = false});
  Train copyWith({GridPos? position, bool? delivered}); }                    // ==, hashCode
final class BoardState { BoardState({required List<Train> trains, required Map<GridPos, SwitchBranch> switches});
  // trains id'ye göre sıralı + unmodifiable saklanır
  List<Train> get trains; Map<GridPos, SwitchBranch> get switches;
  Train? trainById(String id); Train? trainAt(GridPos p) /* teslim edilmemiş olanlar */; bool get allDelivered;
  BoardState withTrain(Train t); BoardState withSwitch(GridPos p, SwitchBranch b);
  String get key; }                                                       // ==/hashCode key üzerinden
final class LevelDefinition { const LevelDefinition({required this.id, required this.number, required this.width,
  required this.height, required this.cells, required this.initialTrains, this.initialSwitches = const {},
  required this.optimalMoves, this.tutorialKey});
  bool contains(GridPos p); Cell cellAt(GridPos p) /* listelenmemiş → EmptyCell, dışarısı → BlockedCell */;
  BoardState get initialState; }
sealed class Move { const Move(); }
final class TrainMove extends Move { const TrainMove(this.trainId, this.direction); }   // ==
final class SwitchToggle extends Move { const SwitchToggle(this.position); }            // ==
enum RejectReason { unknownTrain, trainDelivered, noExit, noEntry, occupied, wrongStation, notASwitch, switchOccupied }
sealed class MoveResult { const MoveResult(); }
final class MoveApplied extends MoveResult { const MoveApplied(this.state, {this.deliveredTrainId}); }
final class MoveRejected extends MoveResult { const MoveRejected(this.reason); }
enum StarRating { bronze(1), silver(2), gold(3); final int stars;
  static StarRating forMoves({required int moves, required int optimal}); }
final class LevelResult { const LevelResult({required this.levelId, required this.moves, required this.rating}); }
```
`BoardState.key`: switch'ler (y,x) sırasıyla + trenler id sırasıyla, örn. `r1@1,2;b1@D|2,2:a` — çözücü ve eşitlik bunu kullanır (DRY).

- [ ] **Step 1: Failing testleri yaz**

```dart
expect(Direction.north.opposite, Direction.south);
expect(Direction.east.opposite, Direction.west);
expect(const GridPos(2, 2).step(Direction.north), const GridPos(2, 1));
expect(const GridPos(2, 2).step(Direction.east), const GridPos(3, 2));
final sw = const SwitchCell(common: Direction.west, branchA: Direction.east, branchB: Direction.south);
expect(sw.portsFor(SwitchBranch.a), {Direction.west, Direction.east});
expect(sw.portsFor(SwitchBranch.b), {Direction.west, Direction.south});
expect(SwitchBranch.a.toggled, SwitchBranch.b);
// BoardState: aynı içerik, farklı liste sırası → eşit, aynı key
expect(BoardState(trains: [b1, r1], switches: {}), BoardState(trains: [r1, b1], switches: {}));
// trainAt teslim edilmiş treni görmez
expect(BoardState(trains: [r1.copyWith(delivered: true)], switches: {}).trainAt(r1.position), isNull);
// LevelDefinition sınırları (level5x5: testte elle kurulan, yalnız (0,0) hücresi listelenmiş 5×5 seviye)
expect(level5x5.cellAt(const GridPos(3, 3)), isA<EmptyCell>());   // listelenmemiş
expect(level5x5.cellAt(const GridPos(5, 0)), isA<BlockedCell>()); // dışarıda
expect(level5x5.contains(const GridPos(-1, 0)), isFalse);
// StarRating (optimum 4)
expect([4, 5, 6, 8, 9].map((m) => StarRating.forMoves(moves: m, optimal: 4)),
    [StarRating.gold, StarRating.gold, StarRating.silver, StarRating.silver, StarRating.bronze]);
```
`test/architecture_test.dart`: `lib/game/domain` ve `lib/game/engine` altındaki her `.dart` dosyası için `expect(content, isNot(contains('package:flutter')))` ve `isNot(contains('dart:ui'))`.

- [ ] **Step 2: Çalıştır, FAIL gör** — `flutter test test/game/domain test/architecture_test.dart` → derleme hatası (tipler yok).
- [ ] **Step 3: Domain dosyalarını yaz** (her tip kendi dosyasında; koleksiyonlar `List.unmodifiable` / `Map.unmodifiable`).
- [ ] **Step 4: `docs/ARCHITECTURE.md`** — katman diyagramı (domain → engine → data → ui), bağımlılık yönü kuralı, DI yaklaşımı, hangi SOLID ilkesinin nerede uygulandığı (SRP: dosya başına tip; OCP: `sealed Cell/Move`; DIP: `LevelRepository`, `HintRunner`, `LevelSolver` enjeksiyonu).
- [ ] **Step 5: PASS doğrula** — `flutter test test/game/domain test/architecture_test.dart`
- [ ] **Step 6: Commit** — `feat(domain): add immutable game domain types`

---

### Task 3: Ray bağlantısı ve tren hareket kuralları

**Files:**
- Create: `lib/game/engine/track_connectivity.dart`, `lib/game/engine/game_rules.dart`, `test/support/level_builders.dart`
- Test: `test/game/engine/train_movement_test.dart`

**Interfaces:**
- Consumes: Görev 2 tipleri.
- Produces:
```dart
final class TrackConnectivity { const TrackConnectivity(this.level);
  Set<Direction> openPorts(GridPos p, BoardState s); } // Track/Station: ports; Switch: portsFor(seçili); diğer: {}
final class GameRules { const GameRules(this.level); final LevelDefinition level;
  MoveResult apply(BoardState s, Move m); }            // Görev 4 SwitchToggle + legalMoves + isSolved ekler
// test/support/level_builders.dart
TrackCell track(String ports);   // "WE"→straight, "NE"→corner, tek harf→depot
StationCell station(TrainColor c, String ports);
Train train(String id, TrainColor c, int x, int y);
LevelDefinition lineLevel();     // Bölüm 1 şekli (aşağıda)
LevelDefinition switchLevel();   // Bölüm 2 şekli
LevelDefinition queueLevel();    // Bölüm 3 şekli
```
Fixture şekilleri (5×5, satır y=2; Görev 8'deki asset'lerle birebir):
- `lineLevel`: (0,2) depot E · (1,2)(2,2)(3,2) `WE` · (4,2) red station W · r1 red @ (0,2) · optimal 4
- `switchLevel`: (0,2) depot E · (1,2) `WE` · (2,2) switch common W, a=E, b=S, başlangıç **b** · (3,2) `WE` · (4,2) red station W · (2,3) `NS` · (2,4) blue station N · r1 red @ (0,2) · optimal 5
- `queueLevel`: switchLevel ile aynı raylar ama (4,2) **blue** station, (2,4) **red** station, switch başlangıç **a** · r1 red @ (0,2), b1 blue @ (1,2) · optimal 8

`apply(TrainMove)` algoritması (sıra önemli, ilk tutan sebep döner): tren yok → `unknownTrain`; teslim edilmiş → `trainDelivered`; mevcut hücrede o yönde açık port yok → `noExit`; hedef dışarıda veya hedefte karşı port açık değil → `noEntry`; hedefte tren var → `occupied`; hedef farklı renkte istasyon → `wrongStation`; hedef doğru istasyon → `MoveApplied(delivered: true, deliveredTrainId)`; aksi halde konum güncellenir.

- [ ] **Step 1: Failing testler**

```dart
test('moves one cell along matching ports', ...) // lineLevel, east → MoveApplied, r1 @ (1,2)
test('rejects direction with no exit port', ...) // lineLevel, north → MoveRejected(noExit)
test('rejects target without opposite port', ...) // (1,2)=track('NS') olan varyant → noEntry
test('rejects occupied target', ...)              // queueLevel, r1 east → occupied
test('rejects wrong-colour station and keeps state', ...) // switchLevel: r1 E,E,S → S hamlesi wrongStation; state değişmez
test('delivers on matching station and vacates cell', ...) // lineLevel 4×east → deliveredTrainId 'r1', trainAt((4,2)) null
test('delivered train cannot move', ...)          // → trainDelivered
test('unknown train id', ...)                     // → unknownTrain
test('cannot enter switch through inactive branch', ...) // switchLevel switch=a, tren (2,3)'te, north → noEntry
test('train on switch leaves only through active ports', ...) // switch=a iken switch üstündeki tren south → noExit
```
- [ ] **Step 2: FAIL doğrula** — `flutter test test/game/engine/train_movement_test.dart`
- [ ] **Step 3: `TrackConnectivity` ve `GameRules.apply(TrainMove)` yaz.** `apply` içindeki `SwitchToggle` dalı bu görevde geçici olarak `MoveRejected(RejectReason.notASwitch)` döner; gerçek davranış Görev 4'te testiyle gelir.
- [ ] **Step 4: PASS doğrula**
- [ ] **Step 5: DECISIONS** — D-006 teslim edilen tren hücreyi boşaltır ve istasyon aynı renkte birden çok tren kabul eder; D-007 harita dışı hedef `noEntry` sayılır.
- [ ] **Step 6: Commit** — `feat(engine): train movement and track port rules`

---

### Task 4: Makas değişimi, legal hamleler, kazanma

**Files:**
- Modify: `lib/game/engine/game_rules.dart`
- Test: `test/game/engine/switch_and_goal_test.dart`

**Interfaces (Produces, `GameRules`'a eklenir):**
```dart
// apply(SwitchToggle): hücre SwitchCell değil → notASwitch; üstünde teslim edilmemiş tren → switchOccupied; aksi halde toggled.
Iterable<Move> legalMoves(BoardState s); // sıra: trenler id sırasıyla × [N,E,S,W], sonra switch'ler (y,x) sırasıyla; yalnız MoveApplied verenler
bool isSolved(BoardState s);             // s.allDelivered
```
- [ ] **Step 1: Failing testler**

```dart
expect((rules.apply(s, const SwitchToggle(GridPos(2, 2))) as MoveApplied).state.switches[const GridPos(2, 2)], SwitchBranch.a); // switchLevel b→a
expect(rules.apply(stateWithTrainOnSwitch, const SwitchToggle(GridPos(2, 2))), const MoveRejected(RejectReason.switchOccupied));
expect(rules.apply(s, const SwitchToggle(GridPos(1, 2))), const MoveRejected(RejectReason.notASwitch));
expect(GameRules(lineLevel()).legalMoves(lineLevel().initialState).toList(), [const TrainMove('r1', Direction.east)]);
expect(GameRules(switchLevel()).legalMoves(switchLevel().initialState).toList(),
    [const TrainMove('r1', Direction.east), const SwitchToggle(GridPos(2, 2))]);
expect(rules.isSolved(lineLevel().initialState), isFalse); // 4×east sonrası isTrue
```
- [ ] **Step 2: FAIL doğrula** — `flutter test test/game/engine/switch_and_goal_test.dart`
- [ ] **Step 3: Implement** — `legalMoves`, adayları `apply` ile süzer (kural tekrarı yok, DRY).
- [ ] **Step 4: PASS doğrula** — `flutter test test/game/engine`
- [ ] **Step 5: Commit** — `feat(engine): switch toggling, legal moves and win check`

---

### Task 5: UndoHistory ve GameSession

**Files:**
- Create: `lib/game/engine/undo_history.dart`, `lib/game/engine/game_session.dart`
- Test: `test/game/engine/game_session_test.dart`

**Interfaces (Produces):**
```dart
final class UndoHistory<T> { void push(T v); T? pop(); void clear(); int get length; bool get canUndo; }
final class GameSession { GameSession(this.level, {GameRules? rules});
  final LevelDefinition level; BoardState get state; int get moveCount; // = history.length
  bool get isSolved; bool get canUndo;
  MoveResult play(Move m);   // MoveApplied → önceki state history'ye, yeni state aktif
  bool undo();               // boşsa false
  void restart(); }          // initialState + history.clear()
```
- [ ] **Step 1: Failing testler**

```dart
test('valid move counts, rejected does not', ...)       // lineLevel: east → 1; north → hâlâ 1
test('undo restores the exact previous state', ...)     // before = s.state; play; undo → expect(s.state, before), moveCount 0
test('undo brings a delivered train back', ...)         // 4×east → isSolved; undo → trainById('r1')!.delivered false, position (3,2)
test('undo on fresh session returns false', ...)
test('restart resets state, count and history', ...)    // expect(s.state, level.initialState); moveCount 0; canUndo false
test('UndoHistory is LIFO', ...)                        // push 1,2 → pop 2, pop 1, pop null
```
- [ ] **Step 2: FAIL doğrula** · **Step 3: Implement** · **Step 4: PASS doğrula** — `flutter test test/game/engine/game_session_test.dart`
- [ ] **Step 5: Commit** — `feat(engine): game session with unlimited undo and restart`

---

### Task 6: LevelSolver (BFS)

**Files:**
- Create: `lib/game/engine/level_solver.dart`
- Test: `test/game/engine/level_solver_test.dart`

**Interfaces (Produces):**
```dart
sealed class SolverOutcome { const SolverOutcome(); }
final class Solved extends SolverOutcome { const Solved(this.moves); final List<Move> moves; }
final class Unsolvable extends SolverOutcome { const Unsolvable(); }
final class SearchLimitReached extends SolverOutcome { const SearchLimitReached(); }
final class LevelSolver { const LevelSolver({this.maxStates = 200000}); final int maxStates;
  SolverOutcome solve(LevelDefinition level, {BoardState? from}); }
```
Algoritma: `Queue<BoardState>` ile BFS; `visited: Map<String, (String? parentKey, Move? move)>` `state.key` üzerinden; genişletme `GameRules.legalMoves` sırasıyla (determinizm bu sıradan gelir); ilk `isSolved` durumda parent zinciri geri izlenip hamle listesi döner; `visited.length > maxStates` → `SearchLimitReached`; kuyruk boşalırsa `Unsolvable`. Başlangıç zaten çözülmüşse `Solved([])`.

- [ ] **Step 1: Failing testler** (yardımcı: `BoardState replay(level, moves)` → her hamleyi `GameRules.apply` ile uygular, Rejected görürse `fail`)

```dart
expect((solver.solve(lineLevel()) as Solved).moves, List.filled(4, const TrainMove('r1', Direction.east)));
final s2 = solver.solve(switchLevel()) as Solved;  expect(s2.moves, hasLength(5));
expect(GameRules(switchLevel()).isSolved(replay(switchLevel(), s2.moves)), isTrue);
expect((solver.solve(queueLevel()) as Solved).moves, hasLength(8));
expect((solver.solve(queueLevel()) as Solved).moves, (solver.solve(queueLevel()) as Solved).moves); // deterministik
expect(solver.solve(unreachableStationLevel), isA<Unsolvable>()); // istasyona ray bağlı değil
expect(const LevelSolver(maxStates: 3).solve(queueLevel()), isA<SearchLimitReached>());
expect((solver.solve(lineLevel(), from: afterTwoEastMoves) as Solved).moves, hasLength(2));
```
- [ ] **Step 2: FAIL** · **Step 3: Implement** · **Step 4: PASS** — `flutter test test/game/engine/level_solver_test.dart`
- [ ] **Step 5: Commit** — `feat(engine): deterministic BFS level solver with state limit`

---

### Task 7: Seviye JSON codec'i, LevelValidator ve format dokümanı

**Files:**
- Create: `lib/game/data/level_json_codec.dart`, `lib/game/engine/level_validator.dart`, `docs/LEVEL_FORMAT.md`
- Test: `test/game/data/level_json_codec_test.dart`, `test/game/engine/level_validator_test.dart`

**Interfaces (Produces):**
```dart
final class LevelFormatException implements Exception { const LevelFormatException(this.levelId, this.message); }
final class LevelJsonCodec { const LevelJsonCodec(); LevelDefinition decode(Map<String, Object?> json); }
enum LevelIssueCode { invalidSize, noTrains, missingStation, duplicateTrainPosition, trainOutOfBounds,
  trainNotOnTrack, invalidTrackShape, invalidSwitch, portMismatch, unsolvable, optimalMismatch }
final class LevelIssue { const LevelIssue(this.code, {this.at, this.detail = ''}); }
final class LevelValidator { const LevelValidator({this.solver = const LevelSolver()});
  List<LevelIssue> validate(LevelDefinition level); }
```
JSON formatı (Bölüm 1 örneği; `docs/LEVEL_FORMAT.md` bunu ve tüm kuralları anlatır):
```json
{ "id": "istanbul_001", "number": 1, "width": 5, "height": 5, "optimalMoves": 4,
  "tutorialKey": "tutorialSelectSwipe",
  "cells": [
    {"x": 0, "y": 2, "type": "depot", "ports": "E"},
    {"x": 1, "y": 2, "type": "straight", "ports": "WE"},
    {"x": 2, "y": 2, "type": "straight", "ports": "WE"},
    {"x": 3, "y": 2, "type": "straight", "ports": "WE"},
    {"x": 4, "y": 2, "type": "station", "ports": "W", "color": "red"}
  ],
  "trains": [{"id": "r1", "color": "red", "x": 0, "y": 2}] }
```
Switch hücresi: `{"x":2,"y":2,"type":"switch","common":"W","branches":"ES","selected":"b"}` → `branchA = E`, `branchB = S`, `initialSwitches[(2,2)] = b`. Tipler: `straight | corner | depot | station | switch | blocked`. Listelenmeyen hücre = empty.

Doğrulama kuralları: genişlik/yükseklik 5–7 (`invalidSize`); ≥1 tren; her tren rengi için ≥1 aynı renk istasyon; tren konumları benzersiz ve içeride; tren track/depot/switch hücresinde; straight = karşılıklı iki port, corner = bitişik iki port, depot 1–2 port, station ≥1 port; switch'in üç yönü birbirinden farklı; her port içerideki komşuya bakar ve komşunun (switch ise üç yönünden birinde) karşı portu vardır (`portMismatch`); çözücü `Solved` döner, aksi `unsolvable`; `moves.length == optimalMoves`, aksi `optimalMismatch` (detail'de bulunan değer).

- [ ] **Step 1: Failing codec testleri**

```dart
final level = codec.decode(level001Json);
expect(level.cellAt(const GridPos(4, 2)), isA<StationCell>().having((c) => c.color, 'color', TrainColor.red));
expect(level.initialTrains.single.position, const GridPos(0, 2));
expect(codec.decode(switchJson).initialSwitches[const GridPos(2, 2)], SwitchBranch.b);
Matcher formatErrorFor(String id) => throwsA(isA<LevelFormatException>().having((e) => e.levelId, 'levelId', id));
expect(() => codec.decode(withCellType('bridge')), formatErrorFor('t_bad'));
expect(() => codec.decode(withoutCellX()), formatErrorFor('t_bad'));
expect(() => codec.decode(withPorts('WQ')), formatErrorFor('t_bad'));
expect(() => codec.decode({'width': 5}), formatErrorFor('?'));   // id yoksa '?'
```
- [ ] **Step 2: Failing validator testleri** — `lineLevel/switchLevel/queueLevel` → `isEmpty`; her kod için fixture'ı tek noktadan bozan bir test (`codes(validator.validate(mutated))` `contains(LevelIssueCode.X)`), ör. `queueLevel` optimal 7 yapılınca `optimalMismatch`, (1,2) `WN` olunca `invalidTrackShape` + `portMismatch`.
- [ ] **Step 3: FAIL doğrula** — `flutter test test/game/data test/game/engine/level_validator_test.dart`
- [ ] **Step 4: Codec ve validator'ı yaz.** Codec yalnızca yapı/tip hatası atar; oyun kuralı ihlalleri validator'ın işidir (SRP).
- [ ] **Step 5: PASS doğrula**
- [ ] **Step 6: Commit** — `feat(data): level JSON codec, validator and format doc`

---

### Task 8: Öğretici bölümler 001–003, asset repository ve çözüm aracı

**Files:**
- Create: `assets/levels/index.json`, `assets/levels/level_00{1,2,3}.json`, `lib/game/data/level_repository.dart`, `lib/game/data/asset_level_repository.dart`, `tool/solve_levels.dart`
- Test: `test/levels/level_assets_test.dart`, `test/game/data/asset_level_repository_test.dart`

**Interfaces (Produces):**
```dart
abstract interface class LevelRepository { Future<List<LevelDefinition>> loadAll(); } // number sırasıyla
final class AssetLevelRepository implements LevelRepository {
  AssetLevelRepository(this.bundle, {this.codec = const LevelJsonCodec()}); final AssetBundle bundle; }
```
`index.json`: `{"city": "istanbul", "levels": ["level_001.json", "level_002.json", "level_003.json"]}`. Bölüm içerikleri = Görev 3'teki `lineLevel / switchLevel / queueLevel` şekilleri; tutorialKey sırasıyla `tutorialSelectSwipe`, `tutorialSwitch`, `tutorialOrder`.
`tool/solve_levels.dart` (yalnız `dart:io` + pure lib importları): index'teki her dosya için `level_001.json  optimal=4  issues=0  solution=E E E E` yazar; herhangi bir issue varsa exit code 1.

- [ ] **Step 1: Failing testler**

```dart
// level_assets_test.dart — dart:io ile assets/levels okunur
for (final file in indexFiles) {
  test(file, () => expect(const LevelValidator().validate(codec.decode(readJson(file))), isEmpty));
}
test('numbers are 1..n and ids unique', ...);
// asset_level_repository_test.dart — TestWidgetsFlutterBinding.ensureInitialized(); rootBundle
expect((await AssetLevelRepository(rootBundle).loadAll()).map((l) => l.number), [1, 2, 3]);
```
- [ ] **Step 2: FAIL doğrula** — `flutter test test/levels test/game/data/asset_level_repository_test.dart`
- [ ] **Step 3: JSON dosyalarını, repository'yi ve aracı yaz.**
- [ ] **Step 4: Doğrula** — `dart run tool/solve_levels.dart` → üç satır, `issues=0`, optimumlar 4 / 5 / 8; ardından testler PASS.
- [ ] **Step 5: Commit** — `feat(levels): add verified tutorial levels 1-3 and asset repository`

---

### Task 9: GameController, olaylar, ipucu ve swipe yönü

**Files:**
- Create: `lib/game/ui/game/{game_controller,game_event,hint_runner,swipe_direction}.dart`
- Test: `test/game/ui/game_controller_test.dart`, `test/game/ui/swipe_direction_test.dart`

**Interfaces (Produces):**
```dart
Direction? directionFromDelta(double dx, double dy, {double minDistance = 24}); // baskın eksen; kısa → null
typedef HintRunner = Future<SolverOutcome> Function(LevelDefinition level, BoardState from);
Future<SolverOutcome> computeHint(LevelDefinition level, BoardState from); // foundation.compute ile arka isolate
sealed class GameEvent { const GameEvent(); }
final class MoveBlocked extends GameEvent { const MoveBlocked(this.reason); }
final class TrainDelivered extends GameEvent { const TrainDelivered(this.trainId); }
final class LevelCompleted extends GameEvent { const LevelCompleted(this.result); }
final class SelectTrainFirst extends GameEvent { const SelectTrainFirst(); }
final class HintUnavailable extends GameEvent { const HintUnavailable(); }
final class GameController extends ChangeNotifier {
  GameController({required LevelDefinition level, HintRunner hintRunner = computeHint, Duration inputLock = kMoveAnimation});
  LevelDefinition get level; BoardState get state; int get moveCount; bool get isSolved; bool get isBusy;
  String? get selectedTrainId; Move? get hint; Stream<GameEvent> get events; // broadcast
  void tapCell(GridPos p);   // tren → seç; switch → SwitchToggle oyna; diğer → no-op
  void swipe(Direction d);   // seçili tren yoksa SelectTrainFirst
  void undo(); void restart(); Future<void> requestHint(); }
```
Davranış: tek teslim edilmemiş tren kaldığında otomatik seçilir (D-008); başarılı hamle → `isBusy` `inputLock` süresince true, bu sürede `tapCell/swipe/undo/restart` yok sayılır; başarılı hamle ipucunu temizler; teslimde `HapticFeedback.selectionClick()` UI tarafında (controller yalnız olay yayar — SRP); çözümde `LevelCompleted(LevelResult(rating: StarRating.forMoves(...)))`; çözülmüş seviyede swipe/tap yok sayılır, undo serbest.

- [ ] **Step 1: Failing testler**

```dart
expect(directionFromDelta(30, 5), Direction.east);   expect(directionFromDelta(-30, 5), Direction.west);
expect(directionFromDelta(5, -30), Direction.north); expect(directionFromDelta(30, 29), Direction.east);
expect(directionFromDelta(10, 10), isNull);          expect(directionFromDelta(0, 0), isNull);
// controller (fakeAsync)
expect(GameController(level: lineLevel()).selectedTrainId, 'r1');                     // otomatik seçim
// queueLevel: seçim yok → swipe → events emits SelectTrainFirst, moveCount 0
// queueLevel: tapCell((0,2)) → 'r1'; tapCell((1,2)) → 'b1'
// queueLevel: r1 seçiliyken east → emits MoveBlocked(RejectReason.occupied)
// switchLevel: tapCell((2,2)) → moveCount 1; tapCell((4,4)) boş → moveCount değişmez
// lineLevel: swipe(east); swipe(east) aynı anda → moveCount 1; async.elapse(180ms); swipe(east) → 2
// lineLevel: 4×(swipe + elapse) → emits LevelCompleted, result.rating StarRating.gold, moves 4
// hintRunner: (_, __) async => Solved([TrainMove('r1', east)]) → requestHint → hint == TrainMove('r1', east); swipe sonrası hint null
// hintRunner: (_, __) async => const SearchLimitReached() → emits HintUnavailable, hint null
```
- [ ] **Step 2: FAIL** · **Step 3: Implement** · **Step 4: PASS** — `flutter test test/game/ui`
- [ ] **Step 5: DECISIONS** — D-008 tek tren otomatik seçim; D-009 ipucu çözücüsü `compute` ile ana thread dışında.
- [ ] **Step 6: Commit** — `feat(ui): game controller with input lock, events and hints`

---

### Task 10: Tahta çizimi ve dokunma/kaydırma katmanı

**Files:**
- Create: `lib/game/ui/board/{board_geometry,board_painter,train_token,board_view}.dart`; Modify: `lib/game/ui/theme/app_colors.dart` (`Color colorForTrain(TrainColor)`)
- Test: `test/game/ui/board_geometry_test.dart`, `test/game/ui/board_view_test.dart`

**Interfaces (Produces):**
```dart
final class BoardGeometry { BoardGeometry({required int columns, required int rows, required Size available});
  double get cellSize; Size get boardSize; Offset centerOf(GridPos p); GridPos? cellAt(Offset local); }
final class BoardPainter extends CustomPainter { BoardPainter({required this.level, required this.state,
  required this.geometry, this.hint}); } // shouldRepaint: state/hint/geometry değiştiyse
final class TrainToken extends StatelessWidget { const TrainToken({required this.train, required this.selected, required this.size}); }
final class BoardView extends StatelessWidget { const BoardView({required this.controller}); }
```
Çizim: her açık port için hücre merkezinden kenara ray çizgisi; switch'in pasif dalı `trackInactive`; istasyon = yuvarlak kare + renk + sembol harfi; blocked = koyu dolgu; ipucu = hedef hücrede turkuaz ok veya switch çevresinde halka. Trenler `AnimatedPositioned(duration: kMoveAnimation)` ile `ValueKey(train.id)`; teslim edilenler tahtadan kalkar, istasyonda ✓ gösterilir. Gesture: `onTapUp` → `cellAt` → `tapCell`; `onPanStart` başlangıç hücresinde tren varsa onu seçer; `onPanEnd` toplam delta → `directionFromDelta` → `swipe`. `ListenableBuilder` yalnız `BoardView`'ı yeniden kurar.

- [ ] **Step 1: Failing testler**

```dart
final g = BoardGeometry(columns: 5, rows: 5, available: const Size(350, 400));
expect(g.cellSize, 70); expect(g.boardSize, const Size(350, 350));
expect(g.centerOf(const GridPos(0, 0)), const Offset(35, 35));
expect(g.cellAt(const Offset(80, 10)), const GridPos(1, 0)); expect(g.cellAt(const Offset(-1, 10)), isNull);
expect(g.cellAt(const Offset(10, 351)), isNull);
// board_view_test: queueLevel; tap (1,2) merkezi → controller.selectedTrainId 'b1'
// lineLevel: (0,2) merkezinden +60px yatay drag → moveCount 1; pumpAndSettle sonrası TrainToken (1,2) merkezinde
```
- [ ] **Step 2: FAIL** · **Step 3: Implement** · **Step 4: PASS** — `flutter test test/game/ui`
- [ ] **Step 5: Commit** — `feat(ui): board painter, train tokens and gesture layer`

---

### Task 11: Ekranlar — ana menü, bölüm listesi, oyun ekranı, sonuç

**Files:**
- Create: `lib/game/ui/screens/{home_screen,level_list_screen,game_screen}.dart`, `lib/game/ui/widgets/{game_hud,game_controls,level_complete_sheet}.dart`; Modify: `lib/app.dart`, `lib/main.dart`
- Test: `test/game/ui/screens_test.dart` (`test/support/fake_level_repository.dart` ile)

**Interfaces:**
- Consumes: `LevelRepository`, `GameController`, `BoardView`, `GameEvent`.
- Produces: `HomeScreen({required LevelRepository repository})`; `LevelListScreen({required LevelRepository repository})` (FutureBuilder, `LEVEL 01` kartları); `GameScreen({required LevelDefinition level, VoidCallback? onNext})` (controller'ı kendisi oluşturur/dispose eder); `LevelCompleteSheet({required LevelResult result, required VoidCallback onReplay, VoidCallback? onNext})`. Composition root `main.dart`: `SwipeOutApp(home: HomeScreen(repository: AssetLevelRepository(rootBundle)))`.

Düzen: üstte HUD `LAST TRAIN / ISTANBUL · LEVEL 01` + `Moves: n`; altında öğretici metin (`maxLines: 2`); ortada `Expanded(BoardView)`; altta `Undo / Restart / Hint`; `SafeArea`. Olaylar: `MoveBlocked/SelectTrainFirst/HintUnavailable` → HUD altında 1.2 sn görünen kısa mesaj; `TrainDelivered` → haptic; `LevelCompleted` → `showModalBottomSheet(LevelCompleteSheet)` (kazanılan yıldız `Icons.star`, kalan `Icons.star_border`).
Eşlemeler `game_hud.dart` içinde tek yerde (DRY): `String? tutorialText(AppLocalizations l, String? key)` (3 öğretici anahtarı → ARB metni, bilinmeyen → null); `String? blockedMessage(AppLocalizations l, RejectReason r)` (`noExit/noEntry` → `blockedNoTrack`, `occupied`, `wrongStation`, `switchOccupied` → kendi metni; `unknownTrain/trainDelivered/notASwitch` → null, mesaj yok). `test/support/level_builders.dart`'a `bigLevel7x7()` eklenir (7×7, iki tren, bir switch; validator'dan geçer).

- [ ] **Step 1: Failing testler**

```dart
testWidgets('home → level list shows tutorial levels', ...) // FakeLevelRepository([line, switch, queue]); Play'e dokun → 'LEVEL 1'..'LEVEL 3'
testWidgets('playing level 1 to the end shows 3 stars', ...) // 4× drag east + pump(200ms) → find.byIcon(Icons.star) findsNWidgets(3)
testWidgets('blocked move shows message', ...)               // queueLevel, r1 east → 'Another train is in the way.'
testWidgets('fits iPhone SE with a 7x7 board', ...)          // tester.view.physicalSize = Size(320, 568), devicePixelRatio = 1;
                                                              // 7×7 fixture → tester.takeException() isNull; Undo/Restart/Hint görünür
testWidgets('Turkish locale', ...)                           // locale: Locale('tr') → 'Geri Al' bulunur
```
- [ ] **Step 2: FAIL** · **Step 3: Implement** · **Step 4: PASS** — `scripts/check.sh`
- [ ] **Step 5: iOS simülatörde elle doğrula** — `flutter run -d <iPhone simülatörü>`; bölüm 1–3 baştan sona oynanır, ekran görüntüsü alınır. Sonuç `PROGRESS.md`'ye yazılır (geçmediyse BLOCKED + sebep).
- [ ] **Step 6: Commit** — `feat(ui): home, level list, game screen and completion sheet`

---

### Task 12: Otomasyon/yayın dokümanları, son doğrulama, GitHub'a sunum

**Files:**
- Create: `docs/AUTOMATION_SETUP.md`, `docs/RELEASE_CHECKLIST.md`, `scripts/bootstrap.sh`; Modify: `TASKS.md`, `PROGRESS.md`

- [ ] **Step 1: `scripts/bootstrap.sh`** — `flutter` yoksa kurulum yönergesini yazıp exit 1; varsa `flutter --version`, `flutter pub get`, `scripts/check.sh`.
- [ ] **Step 2: `docs/AUTOMATION_SETUP.md`** — spec §9'daki manuel adımlar: GitHub App yetkisi (`https://claude.ai/code`, yalnız bu repo), `https://claude.ai/code/routines` → New task → Cloud → repo → 01:07 TR saati → prompt (CLAUDE.md okuma sırası + tek küçük görev) → Run now; bulutta Xcode/simülatör olmadığı, Max plan limitleri.
- [ ] **Step 3: `docs/RELEASE_CHECKLIST.md`** — iOS (bundle id onayı, imzalama, ikon, ekran görüntüleri), Android (applicationId, keystore yerelde), lisans/asset kontrolü; hiçbir otomatik yayın yok.
- [ ] **Step 4: Tam doğrulama** — `scripts/check.sh` ve `flutter build web --release`. Gerçek çıktılar `PROGRESS.md`'ye; `TASKS.md` P0 kutuları işaretlenir, sıradaki görev = Faz 2 planı.
- [ ] **Step 5: Commit** — `docs: automation setup, release checklist and progress`
- [ ] **Step 6: Push (kullanıcı onayıyla)** — `git push -u origin claude/bootstrap-swipeout`. `gh` kurulu olmadığı için PR GitHub web arayüzünden açılır (veya kullanıcı isterse `brew install gh`). Push/PR yapılmadıysa `PROGRESS.md`'de açıkça belirtilir.
