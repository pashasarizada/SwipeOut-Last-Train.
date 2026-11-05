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

## P1 — V2-B (Ankara + Bakü kabuğu)
- [ ] ANK-03…06 (M) — Kabul: her biri validator + replay, iki tren eş zamanlı.
- [ ] Bakü 6 bölüm (L) — Kabul: ortak ray darboğazı, aynı haritanın renk değişikliği değil.
- [ ] Şehir haritası + 6 bölüm noktası, sırayla açılma (M).
- [ ] İlerleme + tam pulse sonrası durum kaydı (`shared_preferences`) (M) — Kabul: kapat-aç testi.
- [ ] Ayarlar: ses, titreşim, Reduced Motion, High Contrast, dil (M).
- [ ] Sonraki pulse "hayalet tren" önizlemesi (S).

## P2 — V2-C/D
- [ ] Paris 6 (sinyal UI'ı ilk kez) · Londra 6 (halka) · Moskova 6 (çift halka) (L her biri).
- [ ] Şehir bitirme damgası, Night Dispatcher rozeti (Rive değerlendirmesi).
- [ ] Ses efektleri (özgün sentetik), haptik paternleri.
- [ ] Yayın hazırlığı (`docs/RELEASE_CHECKLIST.md`).
