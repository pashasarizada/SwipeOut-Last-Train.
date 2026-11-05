# PROGRESS

## 2026-11-06 (3) — branch `main`

**Bağlam:** Kullanıcı tek branch (`main`) ve her commit'te doğrudan push istedi (D-028). Gece boyu kesintisiz çalışma.

**Tamamlanan:**
- `main` oluşturuldu (en güncel `claude/v2-b` hâliyle), kural `CLAUDE.md` + D-028'e yazıldı.
- ANK-04 "Son Aktarma" (7 düğüm, par 4): ortak aktarmadan önce kim geçecek; beklemek "duran trene giriş" reddi.
- ANK-05 "Bir Dakika Daha" (7 düğüm, par 4 = max 4): ilk kez dar saat; ilk dakikayı boşa harcamak çözümsüz (çözücü testi).
- ANK-06 "Başkent Finali" (8 düğüm, par 5): koridorda iki tren aynı anda; Ankara tamamlandı.

**Çalıştırılan komutlar ve gerçek sonuçları:**
- `dart run tool/solve_levels.dart` → ANK-04 optimal=4 par=4 · ANK-05 optimal=4 par=4 max=4 · ANK-06 optimal=5 par=5; hepsi issues=0
- `scripts/check.sh` → No issues found! · +190 All tests passed!
- iOS Simülatör: ANK-04, 05, 06 uçtan uca 3 yıldızla oynandı; ANK-06 sonunda "PASAPORTU AÇ" → **Ankara damgası basıldı** (`docs/images/v2-ux/10-ankara-stamp.png`).

**Bakü (aynı gece):**
- BAK-01 "Hazar Gecesi" — tek hat, iki yön (par 5) · BAK-02 "28 May" — ortak ray + yan hat tuzağı (par 5) · BAK-03 "Memar Əcəmi" — kırmızı çevre yola, mavi aktarmaya (par 4) · BAK-04 "Kırmızı mı Yeşil mi?" — eş zamanlı varış, bir treni beklet; her dakika bir makas (par 6) · BAK-05 "Kapanan Koridor" — bekleme dakikası (par 6) · BAK-06 "Son Bakı Seferi" — 4 makas, par = max = 8.
- `dart run tool/solve_levels.dart` → 12 bölümün hepsi issues=0, optimal = par. Araç artık çözücünün planını da yazdırıyor.
- `scripts/check.sh` → No issues found! · +202 All tests passed!
- Simülatör: BAK-01 uçtan uca oynandı (ana ekran Bakü temasına geçti); BAK-02…06 tahtaları render edilip okunurluk kontrol edildi, **elle oynanmadı**.

**Paris (aynı gece):**
- PAR-01 "Gece Aktarması" (par 6) · PAR-02 "Kırmızı Sinyal" — ilk sinyal (par 6) · PAR-03 "Châtelet Kavşağı" — iki sinyal (par 7) · PAR-04 "République Önceliği" — ilk üç tren, her dakika bir kontrol (par 10) · PAR-05 "Üç Son Sefer" — iki kırmızı sinyal (par 8, max 9) · PAR-06 "Paris Gece Finali" — tüm makas ve sinyaller (par 10).
- Sinyal UX düzeltmesi: ışık artık direğin ucunda (bekleyen trenin altında kaybolmuyordu), bekleyen bilette sinyal ikonu.
- Yeni test: her bölüm 375×667 + yazı ×1.3'te düğümler ≥ 44 pt (D-029). Anons satırı tahtanın üstüne bindirildi.
- `scripts/check.sh` → No issues found! · +234 All tests passed! · 18 bölümün hepsi optimal = par.
- Simülatör: Paris bileti/haritası açıldı, PAR-01 uçtan uca çözüldü, PAR-02'de sinyal kırmızı → tren bekledi → yeşil → devam etti; PAR-03…06 elle oynanmadı (çözücü + replay testleri kapsar).

**BLOCKED / bilinen:** 320×568'de tahta ~180 pt; 44 pt hedefi orada tutmuyor (taşma yok). Kompakt düzen TASKS P1'de.

**Londra (aynı gece):** LON-01 "Halka Girişi" (par 5) · LON-02 "Bir Tur Daha" — üç tren tek halka (par 7) · LON-03 "Son Aktarma" — mavi tam tur atar (par 8) · LON-04 "Paralel Hatlar" (par 7) · LON-05 "Gece Yarısı Sinyali" (par 8) · LON-06 "Son Halka" — par = max = 9. `scripts/check.sh` → +252 All tests passed. Londra bölümleri simülatörde elle oynanmadı (çözücü + replay + 44 pt düzen testleri kapsar).

**BLOCKED — GitHub push:** `b37ef89` (LON-01) ve sonrası `remote: fatal error in commit_refs` ile reddediliyor; GitHub durum sayfası "All Systems Operational", `git fsck` temiz, tek fast-forward commit de reddedildi. Commit'ler yerelde `main`'de güvende; force push yapılmadı. Sabah tekrar denenmeli (`git push origin main`).

**Sıradaki küçük görev:** MOS-01 (Moskova, çift halka).

---

## 2026-11-06 (2) — branch `claude/v2-b`

**Bağlam:** V2-B'nin ilk görevi: ANK-03 "İki Vagon" (GAME_DESIGN_V2 §6: iki tren aynı anda, ~6 düğüm).

**Tamamlanan:** `assets/levels/ANK-03.json` — 6 düğüm (2 depo, 2 makas, 2 hedef), kırmızı ve mavi tren. İki makas da baştan ortak JK bağlantısına bakar; beklemek kafa kafaya çarpışma verir. Dakikada tek kontrol olduğu için önce J, sonra K çevrilir (par 2, max 4). İlk yıldızlı bölüm (`tutorial: false`).

**Çalıştırılan komutlar ve gerçek sonuçları:**
- `dart run tool/solve_levels.dart` → ANK-03 issues=0 optimal=2 par=2 max=4 solution=switch:J switch:K
- `scripts/check.sh` → No issues found! · +184 All tests passed!
- `flutter build ios --simulator --debug` → ✓ Built Runner.app
- iOS Simülatör: DEVAM → ANK-03; bekle-bekle çarpışma reddi (pulse 1/4'te kaldı), RESTART, J → K ile çözüldü, 3 yıldız.

**Bilinen eksikler:** Çarpışma sıçraması/duyurusu simülatör ekran görüntüsünde yakalanamadı (görüntü bir adım gecikmeli); widget testleri kapsar. İnsan oyuncu testi yapılmadı.

**Sıradaki küçük görev:** ANK-04 "Son Aktarma" (önce kimin geçeceğini bul).

---

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
- `scripts/check.sh` → format 0 değişiklik · `flutter analyze`: No issues found! · `flutter test`: +181 All tests passed! (son inceleme düzeltmeleri sonrası)
- `dart run tool/solve_levels.dart` → ANK-01 issues=0 optimal=2 par=2 · ANK-02 issues=0 optimal=3 par=3
- `flutter build web --release` → ✓ Built build/web
- `flutter build ios --simulator --debug` → ✓ Built Runner.app
- iOS Simülatör (iPhone 16e): tüm akış elle oynandı (ANK-01/02 kazanıldı, geri dönüşler, pasaport); hata yok.

- Son branch incelemesi (bağımsız reviewer): 0 kritik, 3 önemli (yetim sonuç panosu, kaybedilmiş kaydın geri yüklenmesi, Material ikonlar) → düzeltildi, testlerle; 13 küçük bulgu ertelendi (ledger'dan `TASKS.md`'ye taşınacak).

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
