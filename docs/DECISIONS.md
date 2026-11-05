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
