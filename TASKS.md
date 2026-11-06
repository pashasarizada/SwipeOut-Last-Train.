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

## P0 — Tahta okunurluğu: Paket A + B (plan `docs/superpowers/plans/2026-11-06-board-readability.md`) — tamamlandı 06.11.2026

- [x] Motor tahmini `forecast` (niyet + çatışma), 30 bölümde gerçek dakikayla aynı
- [x] Açık makas kolu, hareket okları, bekliyor rozeti
- [x] Çarpışma önizlemesi (çarpı + kırmızı ok + kırmızı kol), teslim parıltısı
- [x] `RunMeter`: tren jetonları + dakika noktaları; "PULSE/Kontrol" ve bilet kalktı
- [x] Kurallar sakin anons; öğretici bölümlerde çizilmiş el
- [x] Paket C: ipucu düğmesi (3. yıldız bedeli), özgün sesler + ses ayarı, teslim kutlaması (06.11.2026)
- [ ] Sonra: günün bulmacası, ek görevler (ör. "hiç beklemeden bitir")

## P1 — V2-B (Ankara + Bakü kabuğu)
- [x] ANK-03 "İki Vagon" (S) — iki tren, iki makas, par 2; bekleme kafa kafaya çarpışma.
- [x] ANK-04 "Son Aktarma", ANK-05 "Bir Dakika Daha", ANK-06 "Başkent Finali" — Ankara 6/6, ilk damga basıldı (06.11.2026).
- [x] Bakü 6 bölüm (L) — BAK-01 karşı yönlü tek hat · 02 ortak ray + yan hat tuzağı · 03 aktarma öncesi çevre yol · 04 bekletme makası · 05 bekleme dakikası · 06 dar limitli final (06.11.2026).
- [x] Bölümlerin sırayla açılması (S, ←U6) — U8'de yapıldı.
- [x] Ayarlar: titreşim, Reduced Motion, dil (M) — ana ekrandaki çizilmiş dişliden; sinyal anahtarları; dil anında değişir; tüm haptikler tek kapıdan (06.11.2026).
- [x] Ayarlar: ses, High Contrast (S).
- [x] Sonraki pulse "hayalet tren" önizlemesi (S) — yer değiştirecek trenin varacağı düğümde soluk halka; yalnız bir pulse ileri (§3.2/5).

## P1 — Küçük ekran (320×568) kompakt oyun düzeni — tamamlandı 06.11.2026
- [x] Yükseklik < 700 pt'de: tek ipucu satırı, daha sıkı kontroller, kol `large` boy; 30 bölümün hepsi 320×568 + ×1.3 yazıda 44 pt (D-029).

## P1 — V2-UX son inceleme küçük bulguları (ertelendi)
- [x] SplitFlapText değişmeyen karakteri çevirmesin (S).
- [x] Kayıt yükleme kayıt-bazlı tolerans; `getString` try içinde (S).
- [x] Restart/undo sonrası vagon yönünü sıfırla (S).
- [x] Ortam parçacık döngüsü 8 sn'de sıçramasın; statik arka plan katmanlarını ayrı boya (S).
- [x] GameButton devre dışıyken bırakma; CitySelect PageController dispose (S).
- [x] 200 satırı aşan ekranları böl: city_map, city_select, pulse_game (M).
- [x] Bakü bilet testi boşa dokunuyor — düzelt (S).
- [ ] Plan sapmaları kalan: parallax, Reduced Motion süre yarılama, bilet yırtma animasyonu, damga tekrar oynatma (M). (Yapıldı: HUD "TREN" etiketi, ayar dişlisi, yerel tarih biçimi.)
- [x] ControlTicket `tearLabel` zorunlu; `saveRun` hata yakalama (S).

## P2 — V2-C/D
- [x] Paris 6 — PAR-01 çapraz rota · 02 ilk sinyal · 03 iki sinyal · 04 üç tren · 05 üç tren + iki kırmızı sinyal · 06 final, tüm kontroller (06.11.2026).
- [x] Londra 6 — LON-01 halka girişi · 02 üç tren tek halka · 03 tam tur · 04 paralel koridorlar · 05 halka kapısında sinyal · 06 final, par = max (06.11.2026).
- [x] Moskova 6 — MOS-01 köprülü çift halka · 02 iç halka · 03 köprüde sinyal · 04 ilk dört tren, merkez kilidi · 05 dört tren + sinyal, par = max · 06 SON TREN: 19 düğüm, 4 tren, 10 makasın hepsi (06.11.2026). **30/30 bölüm.**
- [ ] Pasaport/rozet için Rive animasyonları değerlendirmesi (U7 sonrası).
- [x] Ses efektleri (özgün sentetik), haptik paternleri.
- [x] Süre sınırı affedici: her bölümde en az par + 3 dakika (D-035), doğrulayıcı zorlar.
- [x] Metro haritası görünümü: renkli hatlar, 45° yollar, duraklar, hedef istasyon adları (D-036).
- [ ] Şehir haritası ekranını (bölüm seçimi) aynı metro diline taşımak (M).

## P1 — Oyun testi bulguları (AI oyuncu, 06.11.2026, `docs/playtest/2026-11-06-agent-playtest.md`)
- [ ] 3★ hedefini görünür yap: bölüm başında ve bitiş ekranında "3★ için ≤ N dakika"; ipucu kullanıldıysa "ipucu: en fazla 2★" yaz (S).
- [ ] RunMeter yıldız işaretleri kafa karıştırıyor (★ 9. sırada görünüyor, hedef 8 dakika) (S).
- [ ] Saat her bölümde 23:50'den başlıyor; süre 10 dakikayı aşınca 00:00'ı geçiyor. Saati `00:00 − maxPulses`'tan başlat (S).
- [ ] Londra 03, Londra 02 ile aynı harita; yeni bir yerleşim tasarla (M).
- [ ] Kural kartının tabelaya dokununca geri geldiği keşfedilmiyor; görünür bir ipucu ekle (S).
- [ ] Makas üstünde duran trene dokunmak makası seçmeli (dokunma alanı) (S).
- [ ] "Bekliyor" rozetinin nedeni (sinyal / makas / önde tren) belirsiz (M).
- [ ] Zorluk eğrisi: Bakü ortasında tekrar hissi, Paris 05–06'da sıçrama; insan testiyle doğrula (M).
- [ ] Gerçek metro ağlarından esinlenen bölüm topolojisi (bölüm tasarımı, birebir kopya değil) (L).
- [ ] Yayın hazırlığı (`docs/RELEASE_CHECKLIST.md`).
