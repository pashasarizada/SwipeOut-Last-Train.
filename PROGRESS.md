# PROGRESS

## 2026-11-06 — branch `claude/v2-ux`

**Bağlam:** Kullanıcı "Flutter uygulaması gibi görünmesin, gerçek metro havası, şehir temaları, Metro Passport" istedi. Plan: `docs/superpowers/plans/2026-11-05-v2-ux-oyun-hissi-ve-passport.md`; bağlayıcı kurallar `docs/UI_UX_GUIDELINES.md`.

**Tamamlanan işler (U1–U10):**
- Kabuk: "Last Train" adı, karanlık açılış, kullanıcının logosundan ikon/açılış (`scripts/build_branding.sh`).
- Gömülü OFL fontlar (Unbounded, IBM Plex Mono, Inter; TR/AZ/FR/Kiril glif testi), `CityTheme` ×5, `ui_rules_test` (yasak Material widget + emoji).
- Oyun UI kiti: GameButton, AdvanceLever, DepartureBoard, SplitFlapText, ControlTicket, SignalBackButton, PlatformAnnouncement, TrackLoader, GameScaffold.
- Çizilmiş metro vagonu sprite'ı (yönüne döner, farlar, sembol).
- Şehir sanatı: Ankara, Bakü, Paris, Londra, Moskova (desen + silüet + ortam efekti; Reduced Motion'da durur).
- Yerel ilerleme + yarım bölüm kaydı (`shared_preferences`, bozuk kayıt çökertmez).
- Metro Passport: şehir damgaları, Moskova altın damga, Night Dispatcher; eksik içerikli şehir erken damga almaz.
- Ekranlar: tünel girişi → ana ekran → şehir biletleri → hat haritası (bölüm kilitleri) → oyun platformu → split-flap sonuç panosu → pasaport.
- Çarpışma juice: trenler temas noktasına sokulup geri döner, tahta sarsılır; haptik dili (teslim 2× hafif, çarpışma ağır).
- Düzeltme: GameButton gölge animasyonu negatif blur üretip sayfa geçişlerinde `_dependents.isEmpty` zincirine yol açıyordu; gölge artık sabit.

**Çalıştırılan komutlar ve gerçek sonuçları:**
- `scripts/check.sh` → format 0 değişiklik · `flutter analyze`: No issues found! · `flutter test`: +177 All tests passed!
- `dart run tool/solve_levels.dart` → ANK-01 issues=0 optimal=2 par=2 · ANK-02 issues=0 optimal=3 par=3
- `flutter build web --release` → ✓ Built build/web
- `flutter build ios --simulator --debug` → ✓ Built Runner.app
- iOS Simülatör (iPhone 16e): tüm akış elle oynandı (ANK-01/02 kazanıldı, geri dönüşler, pasaport); hata yok.

**Simülatör görüntüleri** (`docs/images/v2-ux/`): 01-home · 02-city-ankara · 03-city-baku · 04-city-paris · 05-line-map · 06-platform · 07-line-cleared · 08-passport-cover · 09-passport-ankara

**Bilinen eksikler / blokerler:**
- Ankara'da 2 bölüm var; çarpışma efekti gerçek bölümde görülmedi (widget testleri kapsar).
- Londra/Moskova biletleri ve tünel girişi ekran görüntüsüne alınmadı.
- Fiziksel cihaz ve Android'de test edilmedi.
- `claude/v2-ux` henüz push edilmedi.

**Sıradaki küçük görev:** V2-B → ANK-03 "İki Vagon".

**Kullanıcıdan gereken onaylar:** `claude/v2-ux` branch'ini push etmek.

---
## 2026-11-05 (2) — branch `claude/v2-night-pulse`

**Bağlam:** Kullanıcı V2.1 tasarım belgesini ekledi (NIGHT PULSE, graf, Paris). Plan: `docs/superpowers/plans/2026-11-05-v2-night-pulse-cekirdek.md`. Animasyon kararı: `flutter_animate` + `animations` (D-020). Flutter 3.32.8'de kalındı, Flame yok (D-019).

**Tamamlanan işler (V1–V12):**
- Izgara/swipe mekaniği ve İstanbul bölümleri tamamen kaldırıldı.
- Saf Dart graf modeli; `PulseEngine.simulatePulse` (tek kontrol + tüm trenler aynı anda; çarpışma, kafa kafaya, duran trene giriş, yanlış hedef → atomik iptal); makas pasif kol bekleme; kırmızı/yeşil sinyal.
- `GameSession` (undo makas/sinyal dahil, maxPulses kayıp), `PulseSolver` (BFS, üretimde hedef testi, durum sınırı).
- V2 JSON formatı + `ActionCodec` + `LevelValidator` (yapısal kurallar, kayıtlı çözüm replay'i, çözücü optimumu); `docs/LEVEL_FORMAT.md`.
- ANK-01 "İlk Sefer" (par 2) ve ANK-02 "Kızılay Yönü" (par 3), çözücüyle doğrulandı.
- `PulseController`, `NetworkPainter` + `TrainLayer` (400 ms eş zamanlı tween, ışık dalgası, çarpışma flaşı, arka plana geçince sona sarma).
- Ekranlar: ana menü, şehir seçimi (5 şehir, 4'ü "Yakında", OpenContainer), şehir bölümleri, oyun ekranı (HUD, bekleyen kontrol çipi, `▶ 1 DAKİKA İLERLET`, Geri Al/Baştan, geri düğmesi), sonuç sayfaları.
- Dokümanlar: `GAME_DESIGN_V2.md`, `ART_DIRECTION.md`, `SOURCE_MAPS_AND_LICENSES.md`, `DECISIONS.md` (V2 çatışmaları, D-015…D-020), `ARCHITECTURE.md`, `CLAUDE.md`, `TASKS.md`.

**Çalıştırılan komutlar ve gerçek sonuçları:**
- `scripts/check.sh` → format 69 dosya / 0 değişiklik · `flutter analyze`: No issues found! · `flutter test`: +109 All tests passed!
- `dart run tool/solve_levels.dart` → ANK-01 issues=0 optimal=2 par=2 · ANK-02 issues=0 optimal=3 par=3 · çıkış 0
- `flutter build web --release` → ✓ Built build/web
- `flutter build ios --simulator --debug` → ✓ Built Runner.app
- iOS Simülatör (iPhone 16e, iOS 26.4) elle: home → şehir → Ankara → ANK-01 uçtan uca → Next → ANK-02; iki görsel hata bulunup düzeltildi.

**Bilinen eksikler / blokerler:**
- İlerleme ve yarım pulse kaydı yok (V2-B, P1). "Devam Et" şimdilik ANK-01'i açar.
- Undo/Restart animasyonsuz (trenler zıplar).
- Fiziksel cihaz ve Android'de test edilmedi. Bundle id'ler geçici.
- Bu oturumda GitHub'a push yapılmadı.

**Sıradaki küçük görev:** V2-B planı → ANK-03 "İki Vagon" (iki tren eş zamanlı).

**Kullanıcıdan gereken onaylar:** `claude/bootstrap-swipeout` ve `claude/v2-night-pulse` branch'lerini push etmek; PR'ı web arayüzünden açmak.

---

## 2026-11-05 (1) — branch `claude/bootstrap-swipeout`

Izgara + swipe prototipi (V1 planı, artık yerini aldı). Ortam: Flutter 3.32.8, Dart 3.8.1, Xcode 26.4.1, `gh` yok, remote boş repo. Ayrıntı git geçmişinde.
