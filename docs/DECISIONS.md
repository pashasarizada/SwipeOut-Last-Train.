# Kararlar (DECISIONS)

Belirsiz noktalarda alınan en sade, sürdürülebilir kararlar. Format: **D-NNN — Karar.** Gerekçe.

- **D-001 — State management paketi yok.** `ChangeNotifier` + `ListenableBuilder` tek ekranlı oyun için yeterli; bağımlılık ve öğrenme maliyeti eklemez (KISS).
- **D-002 — gen-l10n çıktısı (`lib/l10n/generated/`) commit'lenir.** Bulut ortamında `flutter analyze` kod üretimi beklemeden çalışsın; `format: true` ile biçimli üretilir.
- **D-003 — Hamle sayısı = undo geçmişinin uzunluğu.** Undo sayacı da geri alır; tek doğruluk kaynağı (DRY).
- **D-004 — Koordinat sistemi y-aşağı.** Ekran koordinatıyla aynı; `north` = y−1.
- **D-005 — Tren adım animasyonu 180 ms.** Spec aralığı 120–250 ms'nin ortası; giriş kilidi de bu süreyi kullanır.
- **D-006 — Bölüm numarası iki haneli gösterilir (`LEVEL 01`).** HUD ve bölüm listesi aynı biçimi kullanır.
- **D-007 — `dart format` yalnız `lib test tool` dizinlerinde çalışır.** Platform klasörleri ve `build/` gereksiz yere taranmaz.
