# SwipeOut: Last Train — V2-UX: Oyun Hissi, Şehir Temaları ve Metro Passport Uygulama Planı

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Uygulamayı "Flutter/Material uygulaması" görünümünden çıkarıp gece yarısı metrosu hissi veren bir oyuna çevirmek: kendi oyun UI kiti, kendi çizdiğimiz tren vagonları, her şehre özgü tema, ilerleme kaydı ve şehir damgalı **Metro Passport**.

**Architecture:** Motor (`domain`/`engine`) değişmez. `presentation` altında yeni bir **oyun UI kiti** (`lib/game/presentation/kit/`) Material bileşenlerinin yerini alır; şehir görselleri tek bir `CityArt` arayüzünün beş uygulamasıdır (OCP). İlerleme `ProgressRepository` arayüzü arkasında (`shared_preferences`), yarım kalan bölüm **aksiyon geçmişinin motorla yeniden oynatılmasıyla** geri yüklenir (durum serileştirme yok, DRY). Pasaport, ilerlemeden türetilen saf bir modeldir.

**Tech Stack:** Flutter 3.32.8, Dart 3.8.1, `flutter_animate`, `animations`, yeni: `shared_preferences`; gömülü OFL fontlar.

**Spec:** `docs/UI_UX_GUIDELINES.md` (bağlayıcı), `docs/ART_DIRECTION.md`, `docs/GAME_DESIGN_V2.md` §2 (ekran akışı, ilerleme hissi) ve §7 (animasyon dili), `docs/DECISIONS.md` D-021…D-026.

**Kapsam dışı:** Yeni bölümler (ANK-03…, Bakü) — ayrı içerik planı; ses dosyaları (özgün sentetik SFX) — ayrı görev, bu planda yalnız haptik.

## Global Constraints

- Flutter 3.32.8 / Dart 3.8.1; global Flutter yükseltilmez (D-019). Flame yok.
- Yeni paket yalnız `shared_preferences`. Fontlar `assets/fonts/` altında gömülü, OFL; çalışma anında indirme yok.
- Oyuncuya görünen ekranlarda **yasak**: `AppBar`, `BackButton`, `ListTile`, `FilledButton`, `OutlinedButton`, `TextButton`, `ElevatedButton`, `InputChip`, `Chip`, `showModalBottomSheet`, `AlertDialog`, `SnackBar`, `CircularProgressIndicator`, `InkWell` ripple, emoji (D-021, D-022).
- Görsellerin tamamı bizim çizimimiz; resmî metro logosu/hat renk düzeni/fontu/anonsu ve Eyfel gece ışık gösterisi yok.
- Renk + sembol birlikte; dokunma alanı ≥ 44 pt; 320×568'de taşma yok; `Reduced Motion` açıkken sallanma/paralaks/nefes/kar kapalı, süreler yarıya.
- Bir şehir damgası yalnız şehrin **6 bölümünün tamamı** çözüldüğünde basılır (`kLevelsPerCity = 6`); şu an 2 bölümü olan Ankara erken damga almaz.
- Animasyon süreleri `motion.dart`'tan; değerler `ART_DIRECTION.md` tablosu.
- `domain`/`engine` Flutter'sız kalır; `data` katmanındaki `PrefsProgressRepository` tek Flutter-eklenti bağımlısıdır.
- Git: `claude/v2-ux` branch'i (`claude/v2-night-pulse` üzerinden), `main`'e merge yok, force push yok; commit sonu `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Push kullanıcı onayıyla.
- "Geçti" demeden önce `scripts/check.sh`; her ekran iOS simülatörde ekran görüntüsüyle doğrulanır.

## Review Focus

1. **Glif kapsamı** — `Memar Əcəmi`, `Châtelet`, `Добро пожаловать`, `İSTASYON` gömülü fontlarda kutu (tofu) çıkmadan çizilir. (Görev 2)
2. **Bozuk/eski kayıt** — `shared_preferences`'ta bozuk JSON veya artık var olmayan bölüm id'si → çökme yok, ilerleme sıfırlanır/atlanır. (Görev 6)
3. **Eksik içerikli şehir** — Ankara'da 2 bölüm varken ikisi de çözülünce damga **basılmaz**, pasaport "2/6" gösterir. (Görev 7)
4. **Reduced Motion** — açıkken sonsuz animasyon (nefes, kar, paralaks) yok; `pumpAndSettle` takılmaz. (Görev 3, 5)
5. **Yarım bölümün geri yüklenmesi** — kayıtlı aksiyon geçmişi motorda artık geçersizse (seviye dosyası değişti) bölüm baştan başlar, hata vermez. (Görev 6)

---

## Dosya Yapısı

```
lib/game/presentation/
  kit/      game_button.dart advance_lever.dart departure_board.dart split_flap_text.dart
            control_ticket.dart signal_back_button.dart platform_announcement.dart track_loader.dart
            game_scaffold.dart fonts.dart
  city/     city_theme.dart city_art.dart ankara_art.dart baku_art.dart paris_art.dart
            london_art.dart moscow_art.dart city_backdrop.dart
  board/    train_sprite.dart (yeni)  + mevcutlar
  passport/ passport_screen.dart passport_page.dart passport_stamp.dart
  screens/  tunnel_intro_screen.dart home_screen.dart city_select_screen.dart city_map_screen.dart pulse_game_screen.dart
  settings/ motion_settings.dart
lib/game/domain/   progress.dart passport.dart
lib/game/data/     progress_repository.dart prefs_progress_repository.dart
assets/fonts/      <OFL fontlar + OFL.txt>
tool/render_icon_test.dart     # amblemi PNG'ye çizer (ikon üretimi)
test/ui_rules_test.dart
```

---

### Task 1: Uygulama kabuğu — ad, açılış ekranı, ikon

**Files:** Modify `ios/Runner/Info.plist` (`CFBundleDisplayName` = `Last Train`), `android/app/src/main/AndroidManifest.xml` (`android:label`), `ios/Runner/Base.lproj/LaunchScreen.storyboard` (zemin `#0B1020`), `android/app/src/main/res/drawable*/launch_background.xml`, `ios/Runner/Assets.xcassets/AppIcon.appiconset/*`, `android/app/src/main/res/mipmap-*/ic_launcher.png`; Create `lib/game/presentation/kit/emblem_painter.dart`, `tool/render_icon_test.dart`.

**Interfaces:** `EmblemPainter extends CustomPainter` — tren burnu + iki far + ray çizgisi, `AppColors` tokenlarıyla; ikon ve açılışta aynı amblem (DRY).

- [ ] **Step 1:** `test/app_shell_test.dart`: `Info.plist` içinde `<string>Last Train</string>`, manifest'te `android:label="Last Train"`, `LaunchScreen.storyboard`'da beyaz (`white="1"`) zemin **yok** — dosya okuyarak (FAIL).
- [ ] **Step 2:** Ad ve açılış zemini değişiklikleri → PASS.
- [ ] **Step 3:** `tool/render_icon_test.dart` — `flutter test tool/render_icon_test.dart` `EmblemPainter`'ı 1024×1024 PNG'ye çizer (`build/icon_1024.png`); `sips -z` ile iOS/Android boyutlarına çevrilip yerlerine kopyalanır (Flutter logosu kalmaz).
- [ ] **Step 4:** iOS simülatörde ana ekran ikonu ve açılış ekran görüntüsü; **Commit** — `feat(shell): Last Train name, dark launch screen and own icon`

---

### Task 2: Fontlar, tasarım tokenları, `CityTheme`, UI kuralı testi

**Files:** Create `assets/fonts/*` + `assets/fonts/OFL.txt`, `lib/game/presentation/kit/fonts.dart`, `lib/game/presentation/city/city_theme.dart`, `test/ui_rules_test.dart`, `test/game/presentation/fonts_test.dart`; Modify `pubspec.yaml` (fonts), `app_theme.dart` (`splashFactory: NoSplash.splashFactory`, font aileleri).

**Interfaces:**
```dart
abstract final class GameFonts { static const display = '…'; static const board = '…'; static const body = '…'; }
final class CityTheme extends ThemeExtension<CityTheme> { // palet + selamlama anahtarı + CityArt
  const CityTheme({required this.city, required this.background, required this.rail,
    required this.accent, required this.accentAlt, required this.art});
  static CityTheme of(CityId city);            // her şehir için kayıt
  static CityTheme fromContext(BuildContext c); }
```
- [ ] **Step 1 (izin):** Font dosyalarını indirmek **kullanıcı onayı gerektirir** (kaynak: `github.com/google/fonts`, OFL). Onaydan önce dosya adları, kaynak ve boyut listelenir. Adaylar: gösterim *Unbounded*, pano *Share Tech Mono*, gövde *Inter*; glif kapsamı yetmezse alternatif aranır.
- [ ] **Step 2: Failing testler** — `fonts_test`: her font ailesi için `TextPainter` ile `ə`, `İ`, `ç`, `Д` çizildiğinde glif genişliği `.notdef` kutusundan farklı (veya `ParagraphBuilder` fallback yok) · `CityTheme.of` her `CityId` için tanımlı · `ui_rules_test`: `lib/game/presentation/screens/**` ve `passport/**` dosyalarında yasak listesindeki sınıf adları ve emoji kod noktaları (U+1F300–U+1FAFF, U+2600–U+27BF) **yok**.
- [ ] **Step 3:** Fontları ve `CityTheme`'i ekle (paletler `ART_DIRECTION.md`). `ui_rules_test` şimdilik mevcut ekranlarda FAIL eder — bu beklenen durumdur; testi `skip: 'Görev 8'de ekranlar yenilenince açılır'` ile işaretle, Görev 8'de skip kaldırılır.
- [ ] **Step 4:** PASS; **Commit** — `feat(ui): bundled OFL fonts, city themes and UI rules test`

---

### Task 3: Oyun UI kiti

**Files:** Create `lib/game/presentation/kit/{game_button,advance_lever,departure_board,split_flap_text,control_ticket,signal_back_button,platform_announcement,track_loader,game_scaffold}.dart`, `lib/game/presentation/settings/motion_settings.dart`. Test: `test/game/presentation/kit_test.dart`.

**Interfaces:**
```dart
final class GameButton extends StatefulWidget { const GameButton({required this.label, this.onPressed, this.icon, this.size = GameButtonSize.large}); }
final class AdvanceLever extends StatefulWidget { const AdvanceLever({required this.label, this.onPressed}); }
final class SplitFlapText extends StatefulWidget { const SplitFlapText(this.text, {this.style}); } // harf başına 120 ms döner
final class DepartureBoard extends StatelessWidget { const DepartureBoard({required this.lines}); } // amber pano
final class ControlTicket extends StatelessWidget { const ControlTicket({required this.label, required this.onTear}); }
final class SignalBackButton extends StatefulWidget { const SignalBackButton({this.onPressed}); } // varsayılan: Navigator.maybePop
final class PlatformAnnouncement extends StatelessWidget { const PlatformAnnouncement({required this.message}); }
final class TrackLoader extends StatefulWidget { const TrackLoader(); }
final class GameScaffold extends StatelessWidget { const GameScaffold({required this.city, required this.body, this.header}); } // CityBackdrop + SafeArea
final class MotionSettings extends InheritedWidget { final bool reduced; static bool reducedOf(BuildContext c); } // MediaQuery.disableAnimations varsayılanı
```
- [ ] **Step 1: Failing testler** — `GameButton` basılıyken yüz 3 pt aşağıda (`Transform` ofseti), bırakınca `onPressed` 1 kez, haptik kanalına `HapticFeedback.selectionClick` (SystemChannels.platform mock'u ile); `onPressed: null` iken dokunma yok; `SplitFlapText('HAT TEMİZ')` `pumpAndSettle` sonrası tam metni gösterir ve `reduced` iken anında; `ControlTicket` yırtma (sola sürükleme ≥ 40 pt veya ✕) → `onTear`, ✕ dokunma alanı ≥ 44 pt (V2 review I3); `SignalBackButton` → `Navigator.maybePop`; widget ağacında `InkWell`/`Material` ripple yok; her kit bileşeni 44×44 pt'ten küçük değil.
- [ ] **Step 2–4:** FAIL → Implement → PASS
- [ ] **Step 5: Commit** — `feat(ui): game UI kit replacing Material widgets`

---

### Task 4: Tren vagonu sprite'ı (emoji yok)

**Files:** Create `lib/game/presentation/board/train_sprite.dart`; Modify `train_layer.dart` (TrainToken → TrainSprite), `pulse_hud.dart` (🚆 yerine `TrainGlyph` küçük painter), ARB (`trainsDelivered` → `{done}/{total}`); Delete `train_token.dart`. Test: `test/game/presentation/train_sprite_test.dart`.

**Interfaces:**
```dart
double headingOf(Offset from, Offset to);                   // radyan; from == to → önceki yön korunur (çağıran verir)
final class TrainSprite extends StatelessWidget { const TrainSprite({required this.train, required this.heading, this.headlights = 1, this.length = 34}); }
final class TrainGlyph extends StatelessWidget { const TrainGlyph({this.size = 16}); } // HUD için
```
`TrainLayer` her tren için son bilinen yönü tutar: hareket varsa `headingOf(before, after)`, yoksa önceki; idle trende farlar 0.4, pulse'da 1.0.
- [ ] **Step 1: Failing testler** — `headingOf(Offset(0,0), Offset(10,0)) == 0`, `(0,0)→(0,10) == π/2`; pulse sırasında sprite `Transform.rotate` açısı kenar yönüyle eşleşir; ARB dosyalarında emoji kod noktası yok; `TrainSprite` sembol glifini (● ▲ ■ ◆) çizer.
- [ ] **Step 2–4:** FAIL → Implement → PASS (mevcut board/screen testleri `TrainToken` yerine `TrainSprite` bulacak şekilde güncellenir)
- [ ] **Step 5: Commit** — `feat(board): drawn metro car sprite with heading and headlights`

---

### Task 5: Şehir sanatı — beş `CityArt`

**Files:** Create `lib/game/presentation/city/{city_art,ankara_art,baku_art,paris_art,london_art,moscow_art,city_backdrop}.dart`. Test: `test/game/presentation/city_art_test.dart`.

**Interfaces:**
```dart
abstract interface class CityArt {
  void paintPattern(Canvas canvas, Size size, CityTheme theme);
  void paintSkyline(Canvas canvas, Size size, CityTheme theme, {double parallax = 0});
  void paintStamp(Canvas canvas, Size size, {required bool gold});
  AmbientEffect get ambient; }                                   // dust | waves | lamps | rain | snow
final class CityBackdrop extends StatefulWidget { const CityBackdrop({required this.city, this.parallax = 0}); }
```
Motifler `ART_DIRECTION.md` "Şehir sanatı" tablosundaki gibi; tamamı `Path` ile kendi çizimimiz.
- [ ] **Step 1: Failing testler** — her `CityId` için `CityTheme.of(city).art` farklı sınıf; her `paint*` bir `PictureRecorder` kanvasına exception'sız çizer (320×568 ve 1024×1024); `CityBackdrop` `reduced` iken ortam efekti animasyonu çalışmaz (`pumpAndSettle` biter).
- [ ] **Step 2–4:** FAIL → Implement → PASS; iOS simülatörde beş şehrin zemin ekran görüntüleri `PROGRESS.md`'ye.
- [ ] **Step 5: Commit** — `feat(city): Ankara, Baku, Paris, London and Moscow art`

---

### Task 6: İlerleme kaydı ve yarım bölümü geri yükleme

**Files:** Create `lib/game/domain/progress.dart`, `lib/game/data/{progress_repository,prefs_progress_repository}.dart`; Modify `pubspec.yaml` (`shared_preferences`), `PulseController` (aksiyon geçmişi + `restore`). Test: `test/game/data/progress_repository_test.dart`, `test/game/presentation/pulse_restore_test.dart`.

**Interfaces:**
```dart
final class LevelRecord { const LevelRecord({required this.levelId, required this.bestPulses, this.rating}); }
final class SavedRun { const SavedRun({required this.levelId, required this.actions}); } // List<ControlAction?>, ActionCodec ile
final class Progress { const Progress({this.records = const {}, this.run, this.stampDates = const {}});
  bool isSolved(String levelId); int solvedIn(CityId city, List<String> levelIds); }
abstract interface class ProgressRepository { Future<Progress> load(); Future<void> save(Progress p); }
final class PrefsProgressRepository implements ProgressRepository { PrefsProgressRepository(this.prefs); }
// PulseController: List<ControlAction?> get history; static PulseController restore({required LevelDefinition level, required List<ControlAction?> actions});
```
Geri yükleme: kayıtlı aksiyonlar `GameSession.pulse` ile sırayla oynatılır; herhangi biri `PulseFailed` ise oturum baştan başlar (Review Focus 5). Kayıt her **başarılı pulse** sonrası ve bölüm bitince yapılır (yarım animasyon kaydedilmez — spec §9 test 10).
- [ ] **Step 1: Failing testler** — `SharedPreferences.setMockInitialValues({})` ile kaydet/yükle tur testi; bozuk JSON → boş `Progress`; daha iyi pulse sayısı rekoru günceller, kötüsü güncellemez; `restore` ANK-02'de `[switch:B, wait]` → 2 pulse sonrası durum aynı; geçersiz geçmiş → başlangıç durumu.
- [ ] **Step 2–4:** FAIL → Implement → PASS; `docs/DECISIONS.md` D-026 notu.
- [ ] **Step 5: Commit** — `feat(data): local progress and resumable runs`

---

### Task 7: Metro Passport

**Files:** Create `lib/game/domain/passport.dart`, `lib/game/presentation/passport/{passport_screen,passport_page,passport_stamp}.dart`; ARB anahtarları (`metroPassport`, `stampEarned`, `nightDispatcher`, `cityProgress(done,total)`, şehir selamlamaları). Test: `test/game/domain/passport_test.dart`, `test/game/presentation/passport_screen_test.dart`.

**Interfaces:**
```dart
const int kLevelsPerCity = 6;
final class CityStamp { const CityStamp({required this.city, required this.solved, required this.earnedOn, required this.gold});
  bool get earned => earnedOn != null; }
final class Passport { factory Passport.from(Progress progress, Map<CityId, List<String>> levelIds);
  List<CityStamp> get stamps; bool get isNightDispatcher; }        // 5 damga
final class PassportStamp extends StatefulWidget { const PassportStamp({required this.stamp, this.animateIn = false}); }
final class PassportScreen extends StatelessWidget { const PassportScreen({required this.passport, this.highlight}); }
```
Kurallar: şehir damgası `solved == kLevelsPerCity` ve o şehrin tüm indeksli bölümleri çözülmüşse; Moskova `gold: true`; damga tarihi ilk kazanıldığı gün (`Progress.stampDates`). Şehir son bölümü bitince sonuç panosundan sonra **damga sahnesi** açılır (`PassportScreen(highlight: city)`, damga `animateIn`).
- [ ] **Step 1: Failing testler** — 6/6 Ankara → Ankara damgası, altın değil; 6/6 Moskova → `gold`; Ankara'da yalnız 2 bölüm indeksli ve ikisi çözülmüş → damga yok, `solved 2` (Review Focus 3); 5 damga → `isNightDispatcher`; damga animasyonu `pumpAndSettle` ile biter, `reduced` iken anında; ekranda emoji ve yasak widget yok.
- [ ] **Step 2–4:** FAIL → Implement → PASS
- [ ] **Step 5: Commit** — `feat(passport): Metro Passport with city stamps and gold Moscow stamp`

---

### Task 8: Ekranların yeniden tasarımı

**Files:** Create `screens/tunnel_intro_screen.dart`, `screens/city_map_screen.dart`; Rewrite `home_screen.dart`, `city_select_screen.dart`, `pulse_game_screen.dart`, `widgets/pulse_hud.dart` (→ `DepartureBoard`), `widgets/pulse_controls.dart` (→ `ControlTicket` + `GameButton` + `AdvanceLever`), `widgets/level_outcome_sheet.dart` (→ `SplitFlapBoard` overlay); Delete `city_levels_screen.dart`; `main.dart` composition root'a `ProgressRepository`. Test: `test/game/presentation/screens_test.dart` (yeniden), `ui_rules_test` skip kaldırılır.

Ekranlar `UI_UX_GUIDELINES.md` §2–§3'teki gibi:
- **Tünel açılışı** (≤ 2 sn, dokununca atlanır; `reduced` iken atlanır).
- **Ana peron:** son oynanan şehrin `CityBackdrop`'u (paralaks), `DepartureBoard` "SON SEFER 23:59", `DEVAM ET` (kayıtlı `SavedRun` veya ilk çözülmemiş bölüm), `METRO PASSPORT`, ayarlar.
- **Şehir biletleri:** `PageView` karusel; her bilet `CityTheme` paleti + deseni + silüeti; zorluk = 5 sinyal lambası; bölümsüz şehir "HAT YAPIM AŞAMASINDA" bariyer şeridi, dokunulamaz.
- **Şehir hat haritası:** 6 istasyon tek hat üzerinde; çözülen parçalar yanar; olmayan bölüm istasyonu "yakında" soluk; istasyona dokun → ön izleme kartı (ad, par, en iyi yıldız) + `GameButton` "BİN".
- **Oyun peronu:** `DepartureBoard` HUD (şehir · saat `23:50 + pulse` · pulse · teslim · kontrol), şehir deseni zemin, `ControlTicket`, Geri Al/Baştan `GameButton(size: small)`, `AdvanceLever`; `PlatformAnnouncement` hata şeridi.
- **Sonuç:** split-flap "HAT TEMİZ" / "DAKİKA KALMADI", yıldızlar damga gibi basılır; şehir bitince Passport damga sahnesine geçiş.
- [ ] **Step 1: Failing testler** — (V2 review I3) 16 düğümlü seviye `PulseGameScreen` içinde 320×568, metin ölçeği 1.0 ve 1.3'te: ekrandaki en yakın iki düğüm arası ≥ 44 pt ve `meetsGuideline(androidTapTargetGuideline)` · (review M7) Android geri tuşu sonuç panosunu kapatmaz (`PopScope`) · (review M9) `DEVAM ET`'ten girilen bölümde "Şehre Dön" şehir hat haritasına gider · tünel → ana peron → şehir biletleri → Ankara → hat haritası → ANK-01 → oyna → split-flap sonuç; Bakü bileti dokununca açılmaz; HUD saati 23:50 → 23:51; `ui_rules_test` skip'siz PASS; 320×568 TR/EN taşma yok; `DEVAM ET` kayıtlı yarım bölümü açar.
- [ ] **Step 2–4:** FAIL → Implement → PASS; iOS simülatörde her ekranın ekran görüntüsü `PROGRESS.md`'ye.
- [ ] **Step 5: Commit** — `feat(screens): metro-themed game flow`

---

### Task 9: Çarpışma "juice" ve haptik dili

**Files:** Modify `board_view.dart`, `train_layer.dart`, `pulse_game_screen.dart`. Test: `test/game/presentation/collision_feedback_test.dart`.

- Çarpışmada ilgili trenler temas noktasının %35'ine kadar ilerleyip geri döner (300 ms), tahta 6 pt sarsılır, kırmızı flaş, `heavyImpact`; durum değişmez.
- Haptik dili `UI_UX_GUIDELINES.md` §9 tablosu (pulse `mediumImpact`, teslim `lightImpact` ×2, damga `heavyImpact`).
- [ ] **Step 1: Failing testler** — çarpışma sonrası tren konumları başlangıçtakiyle aynı ve animasyon `pumpAndSettle` ile biter; haptik çağrı sırası beklenen; `reduced` iken sarsıntı yok.
- [ ] **Step 2–4:** FAIL → Implement → PASS
- [ ] **Step 5: Commit** — `feat(board): collision bounce, shake and haptic language`

---

### Task 10: Son doğrulama

- [ ] `scripts/check.sh`, `dart run tool/solve_levels.dart`, `flutter build web --release`, `flutter build ios --simulator --debug`; iOS simülatörde tüm akış + Passport ekran görüntüleri; `PROGRESS.md`, `TASKS.md` güncel.
- [ ] **Commit** — `docs: V2-UX progress`. Push kullanıcı onayıyla.
