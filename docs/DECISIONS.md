# Kararlar (DECISIONS)

Belirsiz noktalarda alınan en sade, sürdürülebilir kararlar. Format: **D-NNN — Karar.** Gerekçe.

- **D-001 — State management paketi yok.** `ChangeNotifier` + `ListenableBuilder` tek ekranlı oyun için yeterli; bağımlılık ve öğrenme maliyeti eklemez (KISS).
- **D-002 — gen-l10n çıktısı (`lib/l10n/generated/`) commit'lenir.** Bulut ortamında `flutter analyze` kod üretimi beklemeden çalışsın; `format: true` ile biçimli üretilir.
- **D-003 — Hamle sayısı = undo geçmişinin uzunluğu.** Undo sayacı da geri alır; tek doğruluk kaynağı (DRY).
- **D-004 — Koordinat sistemi y-aşağı.** Ekran koordinatıyla aynı; `north` = y−1.
- **D-005 — Tren adım animasyonu 180 ms.** Spec aralığı 120–250 ms'nin ortası; giriş kilidi de bu süreyi kullanır.
- **D-006 — Bölüm numarası iki haneli gösterilir (`LEVEL 01`).** HUD ve bölüm listesi aynı biçimi kullanır.
- **D-007 — `dart format` yalnız `lib test tool` dizinlerinde çalışır.** Platform klasörleri ve `build/` gereksiz yere taranmaz.
- **D-008 — Teslim edilen tren hücreyi boşaltır.** Tahtadan kalkar; aynı renkteki bir istasyon birden çok treni kabul eder. Teslim geri alınamaz bir engel yaratmaz, çözücü durumu küçülür.
- **D-009 — Harita dışına doğru hamle `noEntry` sayılır.** Ayrı bir "sınır dışı" sebebi UI'da farklı bir mesaj gerektirmiyor (KISS); geçerli seviyelerde validator zaten dışarı bakan portu reddeder.
- **D-010 — Validator, yapısal sorun varsa çözücüyü çalıştırmaz.** Bozuk bir seviyede `unsolvable` gürültüsü asıl hatayı gizlemesin.
- **D-011 — Codec yalnız JSON yapısını, validator oyun kurallarını denetler (SRP).** Codec hatası `LevelFormatException`, kural ihlali `LevelIssue` listesi.
- **D-012 — Tek teslim edilmemiş tren kaldığında otomatik seçilir.** Bölüm 1'de oyuncu ilk 30 saniyede doğrudan kaydırabilsin.
- **D-013 — İpucu çözücüsü `compute` ile arka isolate'ta çalışır.** 7×7 / 4 trenli bölümlerde UI donmasın; sonuç gelene kadar tahta değiştiyse ipucu atılır. İpucu bir tren hamlesiyse o tren seçilir.
- **D-014 — Giriş kilidi yalnız bir tren yer değiştirdiğinde başlar.** Hamle, undo ve restart trenleri animasyonla taşır; makas değişimi şimdilik animasyonsuz olduğu için kilitlemez. Simülatörde kilit, Restart/makas sonrası hızlı dokunuşu yutuyordu.
- **D-019 — Flutter şimdilik 3.32.8'de kalır; Flame kullanılmaz.** Makinede tek Flutter kurulumu var ve HeirLoam/meet2be-app de onu kullanıyor; yükseltme gerekirse fvm ile yalnız bu projeye yapılacak (kullanıcı 05.11.2026'da "şimdilik kalsın" dedi). Flame sıra tabanlı bu oyuna uymuyor; tahta animasyonları `AnimationController` + `CustomPainter` ile.

## V2.1 (NIGHT PULSE) ile çatışmalar — 05.11.2026

`docs/GAME_DESIGN_V2.md` oynanış, şehir, seviye ve görsellerde bağlayıcıdır. Eski master prompt ile çatışanlar:

- Swipe ile tek tren sürme → **NIGHT PULSE** (tek kontrol + bütün trenler aynı anda). D-008, D-009, D-012, D-014 (ızgara/swipe kararları) geçersiz.
- Kare ızgara → **düğüm/kenar grafı** (normalize 0–1 koordinatlar).
- İstanbul → **kaldırıldı**; şehirler Ankara → Bakü → Paris → Londra → Moskova. `IST-*` ve İstanbul bölümleri silinir.
- İpucu düğmesi → **kaldırıldı** (spec: tam çözüm otomatik gösterilmez; en fazla bir sonraki pulse önizlemesi).
- Yıldızlar hamle değil **pulse** üzerinden; öğretici bölümlerde yıldız yok.

- **D-015 — Üzerinde tren duran makas da değiştirilebilir.** Spec yasaklamıyor; tren bir sonraki pulse'da yeni seçime göre çıkar (pasif koldan geldiyse bekler).
- **D-016 — Çözücü durum anahtarı pulse sayacını içermez; derinlik `maxPulses` ile budanır.** BFS en kısa yolu yine bulur, durum uzayı küçülür.
- **D-017 — Her seviye JSON'unda kayıtlı `solution` zorunlu; validator replay eder.** Çözücü durum sınırına takılırsa (Moskova) güvence budur; sınır hata sayılmaz.
- **D-018 — Tren yalnız `depot` düğümünde başlar.** Başlangıçta "gelen kenar" belirsizliği olmasın.
- **D-020 — UI süsleme: `flutter_animate` + `animations`.** Kullanıcı seçimi (05.11.2026). Düğme/çip/yıldız/sayfa girişleri `flutter_animate`, ekran geçişleri `animations`; tahta yalnız yerleşik `AnimationController` + `CustomPainter`.

## V2.2 — Oyun hissi ve Metro Passport (kullanıcı yönergesi, 05.11.2026)

- **D-021 — Oyuncuya görünen hiçbir yerde Material/Flutter varsayılan görünümü yok.** AppBar, ListTile, varsayılan düğmeler, Chip, bottom sheet/dialog/snackbar, ripple, sistem fontu ve Flutter ikonu/açılışı yerine oyun UI kiti (`UI_UX_GUIDELINES.md` §1). Bir test bu kuralı zorlar.
- **D-022 — Emoji yok; trenler kendi çizdiğimiz vagon sprite'ı.** Emoji platforma göre farklı görünür ve ucuz durur; sprite yönüne döner, far ışığı ve livre taşır.
- **D-023 — Her şehir kendi teması (`CityTheme` + `CityArt`).** Palet, yerel desen, silüet, ortam efekti, selamlama, damga. Görseller bizim çizimimiz; fotoğraf yalnız lisansı kayıtlıysa.
- **D-024 — Metro Passport.** Şehir tamamlanınca damga; Moskova altın damga; beş damga → Night Dispatcher. İlerleme kaydına (`shared_preferences`) dayanır, kozmetik, offline.
- **D-025 — Fontlar OFL ve uygulamaya gömülü.** TR + AZ (ə) + FR + Kiril glif kapsamı testle doğrulanır; çalışma anında font indirme yok (offline kuralı).
- **D-026 — Yeni paket: `shared_preferences`** (ilerleme + pasaport). Küçük, resmî Flutter eklentisi; BSD-3.
- **D-027 — Fontlar: Unbounded (başlık), IBM Plex Mono SemiBold (pano), Inter (gövde).** Share Tech Mono elendi: ğ, ş, İ ve ə gliflerini içermiyor (cmap testi). Kapsam `test/game/presentation/fonts_test.dart` ile sürekli doğrulanır.

## Çalışma düzeni (kullanıcı kararı, 06.11.2026)

- **D-028 — Tek branch: `main`, her commit doğrudan push.** Zincir hâlindeki `claude/*` branch'leri (bootstrap → v2-night-pulse → v2-ux → v2-b) en güncel hâliyle (`claude/v2-b`) `main`'e alındı. Gerekçe: tek kişi + AI geliştirmede PR zinciri takibi zorlaştırıyordu; güvenlik ağı artık her commit öncesi zorunlu `scripts/check.sh` (format + analyze + test) ve force push yasağı. Eski `claude/*` branch'leri önce arşiv olarak kaldı; 06.11.2026'da kullanıcının açık onayıyla silindi (hepsinin commit'leri `main`'de, kayıp yok). GitHub'da varsayılan branch `main` yapıldı ve son kalan `claude/v2-night-pulse` de silindi; repoda yalnız `main` var.
- **D-029 — Dokunma hedefi kuralı 375×667 (iPhone SE 2/3) + yazı ×1.3'te bölüm bazında zorlanır.** `test/levels/level_layout_test.dart` her bölümü gerçek oyun ekranında açar, en yakın iki düğüm ≥ 44 pt. Güncelleme (06.11.2026): yükseklik < 700 pt'de kompakt oyun düzeni (tek ipucu satırı, sıkı kontroller, `large` kol) ile test 320×568'i de kapsıyor; 30 bölümün hepsi geçiyor. Anons satırı tahtanın üstüne bindirildi (her ekranda +44 pt tahta).

## Tahta okunurluğu — Paket A + B (kullanıcı onayı, 06.11.2026)

Tasarım: `docs/superpowers/specs/2026-11-06-board-readability-design.md`, plan: `docs/superpowers/plans/2026-11-06-board-readability.md`.

- **D-030 — Bir sonraki dakika yazısız gösterilir, çarpışma dahil.** `PulseEngine.forecast` her trenin niyetini ve dakikayı reddedecek çatışmayı verir; `simulatePulse` ile aynı hesabı paylaşır, bu yüzden önizleme ile gerçek dakika ayrışamaz (30 bölümün her çözüm adımında test). Tahtada: kapalı makas kolu soluk ve makastan 30 pt önce kesik; hareket eden trene kendi renginde ok, kalan trene "bekliyor" rozeti; çatışmada kırmızı ok + trenlerin üstünde, duran trenin önünde çarpı (renk + şekil); teslim edilecek hedefte parıltı. Kol kırmızıya döner ama basılabilir kalır. Yine yalnız **bir** dakika ileri (V2 §3.2/5); çözüm gösterilmez. Okların noktaları her değişiklikten sonra 3 tur akar ve durur (pil). Gerekçe: mağaza yorumları araştırması (Into the Breach, Hitman GO, Railbound) — oyuncu sonucu önceden görünce kaybı "kendi hatası" sayar.
- **D-031 — Üst bilgi ve kurallar yazısız.** "PULSE / Kontrol 1/1" yerine çizilmiş `RunMeter` (tren jetonları + dakika noktaları, par ve par+2'de yıldız işareti, 16'dan uzun koşu çubuk); ekran okuyucu "DAKİKA/MIN" duyar. "Makas M" bileti oyun ekranından kalktı (seçim tahtada parlıyor, kolun etiketi söylüyor). Kural yazısı tahtadan kalktı: sakin `info` anonsu olarak açılır, ilk hamlede kaybolur, tabelaya dokununca geri gelir (zamanlayıcı yok: test ve okuma hızı için). Öğretici bölümlerde çizilmiş el kayıtlı çözümü izler: seçilecek makas → kol; yanlış seçimde o düğüm (iptal); sapmış koşuda Geri Al.

## Paket C — ipucu ve ses (kullanıcı onayı, 06.11.2026)

Tasarım: `docs/superpowers/specs/2026-11-06-package-c-hint-sound-design.md`.

- **D-032 — Yeni paket: `audioplayers` (MIT); iOS hedefi 12.0 → 13.0.** Kısa efektleri düşük gecikmeyle ve havuzla çalan, iOS + Android'i destekleyen olgun eklenti. iOS ses kategorisi `ambient`: sessiz düğmesine uyar, kullanıcının müziğini kesmez. `audioplayers_darwin` iOS 13 istiyor; iOS 12 cihaz payı ihmal edilebilir. Sesler `tool/make_sounds.py` ile saf Python'da sentezlenir (örnek/kayıt yok). Ses yüklenemezse oyun sessiz devam eder.
- **D-033 — İpucu: sınırsız ve ücretsiz, bedeli o koşunun 3. yıldızı.** Önceki "ipucu düğmesi kaldırıldı" kararının yerini alır (mağaza yorumları: ipucu yoksa oyuncu bırakıyor, parayla satılınca kızıyor). Yalnız **bir** hamle gösterilir (kayıtlı çözüm izleniyorsa ondan, değilse çözücüden, çözüm yoksa Geri Al); çözücü ayrı isolate'te çalışır. Geri Al bedeli kaldırmaz, Baştan kaldırır; yarım koşu kaydında ipucu tutulmaz (bilinçli basitlik). Öğretici bölümlerde düğme yok.
- **D-034 — High Contrast: telefon ayarı veya Ayarlar anahtarı.** `ContrastSettings` (MotionSettings gibi) telefonun "kontrastı artır" ayarını izler; Ayarlar'daki anahtar zorla açar. Etkisi: açık raylar beyaz ve 8 pt, kapalı kollar ince ama görünür gri, tahmin okları 7 pt + koyu kenar + tam opak, şehir arka planı %60 sönük. Renk tek başına bilgi taşımaz (çarpı, rozet, kesik kol şekil olarak da var). `UI_UX_GUIDELINES.md` §10'un zorunlu maddesi.

## Zorluk — süre payı (kullanıcı onayı, 06.11.2026)

- **D-035 — Süre sınırı affeder, yıldız ödüllendirir.** Her bölümde `maxPulses ≥ parPulses + 3` (`LevelValidator.minSpareMinutes`, `tightLimit` sorunu). 27 bölümün sınırı yükseldi (ör. ANK-05 4→7, BAK-06 8→11, MOS-05 12→15); optimumlar ve kayıtlı çözümler değişmedi. Önceki "son bölümde hiç pay yok" tasarımının yerini alır. Gerekçe: dar sınırda tek hata kaybettirir ve haksızlık gibi gelir (mağaza yorumlarında bulmaca oyunu bırakma sebebi); zorluk altın yıldızda (yalnız par) kalır. Rastgele "kırmızı kolu atlayan" oyuncu simülasyonu: Londra/Moskova'da kazanma ~%0, yani gevşeme oyunu kolaylaştırmaz, yalnız insan hatasını affeder.

## Metro haritası görünümü (kullanıcı onayı, 06.11.2026)

Tasarım: `docs/superpowers/specs/2026-11-06-metro-map-look-design.md`, plan: `docs/superpowers/plans/2026-11-06-metro-map-look.md`.

- **D-036 — Tahta metro haritası diliyle çizilir; bölüm mantığı değişmez.**
  - `RailGeometry` her rayı 0°/45°/90° parçalardan ve 14 pt yuvarlak köşelerle çizer. Düğümler taşınmaz. 8°'den az sapan raylar tek düz parça kalır. 314 rayın hiçbiri düz yedeğe düşmüyor.
  - Raylar, trenler, önizleme okları, çarpı ve kapalı kol boşluğu aynı yolu kullanır.
  - `MetroLines` rayları hatlara ayırır: makasta ana gövde en düz dala devam eder. Renkler açgözlü boyamayla verilir, böylece buluşan hatlar farklı renkte olur.
  - Hat renkleri tren renklerinden ve önizleme turkuazından en az 30° renk tonu uzaktadır (sönük gri/kum tonu bu kuraldan muaf). Bir şehrin iki ana rengi arasında en az 45° fark vardır.
  - Duraklar çentik, depolar hat renginde çerçeve, çıkmaz uçlar tampon çizgisi olarak çizilir.
  - Yalnız hedef istasyonlara gerçek istasyon adı yazılır (`GAME_DESIGN_V2` "yalnız kritik istasyonlar" kuralıyla uyumlu). 12 aday yerden ilki seçilir. İsim; düğümlere, raylara, sinyal lambasına, bekliyor rozetine ve çarpı işaretinin olası yerine değmez. Yer yoksa isim atlanır. Yerleşme oranı tahta kenarına göre: 360 pt'de 70/75, 260 pt'de 59/75, 180 pt'de 44/75. Testler 360 pt'de ≥%90, 260 pt'de ≥%75 ister.
  - İnceleme sonrası:
    - çarpışma sarsıntısı eğri rayı izler;
    - isim yazıları ve ray parçaları tahta başına bir kez hesaplanır (karede bir değil);
    - bir düğümden çıkan raylar en az ~29° ayrılır.
  - High Contrast: beyaz kalın raylar, koyu zeminli isimler.

## Oyun testi düzeltmeleri (kullanıcı onayı "yapalım devam edelim", 06.11.2026)

- **D-037 — Yıldız hedefi yazıyla, saat gece yarısında biter.**
  - Tabelanın 2. satırında saat ve hedef yazar: "3 YILDIZ ≤ N DK". İpucu kullanılınca bu yazı "İPUCU: EN ÇOK 2 YILDIZ" olur. Tabela fontunda ★ olmadığı için yazıyla yazılır.
  - Bitiş ekranı, 3. yıldızın neden kaçtığını söyler: dakika hedefi ya da ipucu.
  - Sayaçta ★ artık par (ve par+2) dakikasının kendisidir. Önceden noktaların arasında duran bir işaretti ve oyuncu onu 9. dakika sanıyordu. Dakika oynanınca ★ dolar.
  - Saat `00:00 − maxPulses`'tan başlar, süre bitince tam 00:00'ı gösterir. 23:50 sabit başlangıcı ve D-035'ten sonra gece yarısını geçmesi düzeltildi.
  - Dokunma: 36 pt içindeki makas ve sinyal, daha yakın başka duraklara göre önceliklidir. Makasın üstünde duran trene dokunmak makası seçer.
  - Kurallar gizliyken tabelanın köşesinde küçük bir "i" rozeti durur; tabelaya dokunmanın kuralları geri getirdiğini gösterir.
- **D-038 — Bekleme sebebi görünür; haritalar tekrar etmez.**
  - `TrainMove.waitReason` üç değer alır: kırmızı sinyal, ters makas, çıkmaz. Motor bunu beklemeyle aynı kuraldan hesaplar.
  - Kırmızı sinyalde ayrı rozet çizilmez, sinyal lambası parlar. Rozet ile lamba üst üste biniyordu (oyun testi).
  - Ters makasta turuncu çatal rozeti çizilir, çıkmazda ⏸.
  - Londra 03'e yeni harita: tek yönlü 7 makaslı halka ve ortada aktarma hattı (N–M–S), iç hedefe tek yol. En kısa çözüm 9, sınır 12, rastgele kazanma ~%0.
  - `level_assets_test` iki bölümün aynı haritayı kullanmasına izin vermiyor.
  - Bulunan iki tekrar da yeni haritayla çözüldü:
    - Londra 06: alttaki tek kırmızı sinyalden bütün trenlerin geçtiği halka finali. En kısa çözüm 10, sınır 13.
    - Moskova 02: iç içe iki halka ve iki bağlantı. En kısa çözüm 11, sınır 14.
  - İstasyon isimleri artık hedefin çevresinde ikinci, biraz daha uzak bir halkada da yer arıyor. 360 pt tahtada 68/75, 260 pt'de 59/75 isim yerleşiyor.

## Uygulama kimliği (kullanıcı kararı, 06.11.2026)

- **D-039 — Paket ve bundle kimliği: `tr.com.pinet.lasttrain`.**
  - Android `namespace` ve `applicationId` bu değerde; `MainActivity` aynı pakete taşındı.
  - iOS `PRODUCT_BUNDLE_IDENTIFIER` da bu değerde; testlerde `tr.com.pinet.lasttrain.RunnerTests`.
  - `com.example` hiçbir yerde kalmadı.
  - Mağazaya çıktıktan sonra değiştirilemez; yeni kimlik yeni uygulama demektir.
  - Not: Simülatörde eski `com.example.swipeoutLastTrain` kurulumu ayrı bir uygulama olarak duruyor; yeni kimlikle ilerleme kaydı sıfırdan başlar.

