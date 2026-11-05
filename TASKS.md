# TASKS (V2 — NIGHT PULSE)

Öncelik: **P0** şimdi (plan `docs/superpowers/plans/2026-11-05-v2-night-pulse-cekirdek.md`), **P1** V2-B, **P2** V2-C/D. Efor: S ≤ yarım gün, M ≈ 1 gün, L 2+ gün.

## P0 — V2 çekirdeği (ANK-01, ANK-02) — tamamlandı 05.11.2026
- [x] **V1 Dokümanlar** (S) — Kabul: GAME_DESIGN_V2, ART_DIRECTION, SOURCE_MAPS, DECISIONS çatışmaları.
- [x] **V2 Graf domain** (S, ←V1) — Kabul: immutable tipler, mimari test yeşil.
- [x] **V3 PulseEngine** (M, ←V2) — Kabul: hareket, makas, sinyal, 4 çarpışma türü, atomik commit testleri.
- [x] **V4 GameSession** (S, ←V3) — Kabul: undo makas/sinyal dahil, maxPulses kayıp/kurtarma.
- [x] **V5 PulseSolver** (S, ←V3) — Kabul: ANK-01 optimum 2, ANK-02 3, deterministik, sınır.
- [x] **V6 Format + validator** (M, ←V5) — Kabul: bozuk JSON → LevelFormatException, kayıtlı çözüm replay.
- [x] **V7 ANK-01/02** (S, ←V6) — Kabul: `dart run tool/solve_levels.dart` issues=0.
- [x] **V8 PulseController** (S, ←V4) — Kabul: pending seç/iptal, animasyon kilidi, kazan/kaybet olayları.
- [x] **V9 Tahta + animasyon** (M, ←V8) — Kabul: eş zamanlı tween, 320×568'de taşma yok.
- [x] **V10 Ekranlar** (M, ←V9) — Kabul: home → şehir → Ankara → ANK-01 uçtan uca, TR/EN, geri düğmesi.
- [x] **V11 Izgara kodunu sil** (S, ←V10) — Kabul: `GridPos`/swipe/İstanbul grep boş.
- [x] **V12 Doğrulama** (S) — Kabul: check + web + iOS sim build, PROGRESS gerçek çıktılarla.

## P0 — V2-UX: oyun hissi, şehir temaları, Metro Passport (plan `docs/superpowers/plans/2026-11-05-v2-ux-oyun-hissi-ve-passport.md`) — tamamlandı 06.11.2026
- [x] **U1 Uygulama kabuğu** (S) — Kabul: görünen ad "Last Train", karanlık açılış, kendi ikonumuz (Flutter logosu yok).
- [x] **U2 Fontlar + CityTheme + UI kuralı testi** (M, ←U1; font indirme kullanıcı onayı) — Kabul: TR/AZ/FR/Kiril glifleri çizilir; yasak widget/emoji testi var.
- [x] **U3 Oyun UI kiti** (M, ←U2) — Kabul: GameButton, AdvanceLever, DepartureBoard, SplitFlap, ControlTicket, SignalBackButton, Announcement, TrackLoader; ripple yok, ≥ 44 pt.
- [x] **U4 Tren vagonu sprite'ı** (S, ←U2) — Kabul: yönüne dönen vagon, farlar, sembol; emoji yok.
- [x] **U5 Şehir sanatı ×5** (L, ←U2) — Kabul: her şehir kendi desen + silüet + ortam efekti; Reduced Motion'da efekt yok.
- [x] **U6 İlerleme + yarım bölüm** (M) — Kabul: kapat-aç testi; bozuk kayıt çökertmez.
- [x] **U7 Metro Passport** (M, ←U5, U6) — Kabul: 6/6 şehir damgası, Moskova altın, 5 damga Night Dispatcher; eksik şehir erken damga almaz.
- [x] **U8 Ekranların yeniden tasarımı** (L, ←U3…U7) — Kabul: tünel → peron → biletler → hat haritası → oyun → split-flap; `ui_rules_test` yeşil.
- [x] **U9 Çarpışma juice + haptik dili** (S, ←U8) — Kabul: geri sıçrama + sarsıntı, durum değişmez.
- [x] **U10 Doğrulama** (S) — Kabul: tüm ekranların simülatör görüntüleri PROGRESS'te.

## P1 — V2-B (Ankara + Bakü kabuğu)
- [x] ANK-03 "İki Vagon" (S) — iki tren, iki makas, par 2; bekleme kafa kafaya çarpışma.
- [x] ANK-04 "Son Aktarma", ANK-05 "Bir Dakika Daha", ANK-06 "Başkent Finali" — Ankara 6/6, ilk damga basıldı (06.11.2026).
- [x] Bakü 6 bölüm (L) — BAK-01 karşı yönlü tek hat · 02 ortak ray + yan hat tuzağı · 03 aktarma öncesi çevre yol · 04 bekletme makası · 05 bekleme dakikası · 06 dar limitli final (06.11.2026).
- [x] Bölümlerin sırayla açılması (S, ←U6) — U8'de yapıldı.
- [ ] Ayarlar: ses, titreşim, Reduced Motion, High Contrast, dil (M).
- [ ] Sonraki pulse "hayalet tren" önizlemesi (S).

## P1 — Küçük ekran (320×568) kompakt oyun düzeni
- [ ] Tahta 320×568'de ~180 pt kalıyor; Geri Al/Baştan'ı ikonlu tek satıra al, ipuçlarını tek satıra indir; hedef: tüm bölümler 320×568'de 44 pt (D-029) (M).

## P1 — V2-UX son inceleme küçük bulguları (ertelendi)
- [ ] SplitFlapText değişmeyen karakteri çevirmesin (S).
- [ ] Kayıt yükleme kayıt-bazlı tolerans; `getString` try içinde (S).
- [ ] Restart/undo sonrası vagon yönünü sıfırla (S).
- [ ] Ortam parçacık döngüsü 8 sn'de sıçramasın; statik arka plan katmanlarını ayrı boya (S).
- [ ] GameButton devre dışıyken bırakma; CitySelect PageController dispose (S).
- [ ] 200 satırı aşan ekranları böl: city_map, city_select, pulse_game (M).
- [ ] Bakü bilet testi boşa dokunuyor — düzelt (S).
- [ ] Plan sapmaları: HUD tren glifi, parallax, Reduced Motion süre yarılama, ayar dişlisi, bilet yırtma animasyonu, yerel tarih biçimi, damga tekrar oynatma (M).
- [ ] ControlTicket `tearLabel` zorunlu; `saveRun` hata yakalama (S).

## P2 — V2-C/D
- [x] Paris 6 — PAR-01 çapraz rota · 02 ilk sinyal · 03 iki sinyal · 04 üç tren · 05 üç tren + iki kırmızı sinyal · 06 final, tüm kontroller (06.11.2026).
- [ ] Londra 6 (halka) · Moskova 6 (çift halka) (L her biri).
- [ ] Pasaport/rozet için Rive animasyonları değerlendirmesi (U7 sonrası).
- [ ] Ses efektleri (özgün sentetik), haptik paternleri.
- [ ] Yayın hazırlığı (`docs/RELEASE_CHECKLIST.md`).
