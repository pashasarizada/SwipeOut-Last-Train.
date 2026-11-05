# TASKS

Öncelik: **P0** şimdi, **P1** Faz 2, **P2** Faz 3–4. Ayrıntılı plan: `docs/superpowers/plans/2026-11-05-faz0-1-oynanabilir-cekirdek.md`.

## P0 — Faz 0 + Faz 1 (oynanabilir çekirdek)
- [ ] **T1 İskelet + dokümanlar** — Kabul: `flutter create` projesi, TR/EN ARB, portrait kilidi, `scripts/check.sh` yeşil.
- [ ] **T2 Domain tipleri** — Kabul: immutable tipler + domain/engine'de Flutter importu olmadığını doğrulayan test.
- [ ] **T3 Tren hareketi** — Kabul: port eşleşmesi, dolu kare, yanlış istasyon, teslim testleri yeşil.
- [ ] **T4 Makas + kazanma** — Kabul: toggle, üstünde tren varken red, `legalMoves` sırası, `isSolved` testleri.
- [ ] **T5 Oturum + undo** — Kabul: hamle sayımı, undo birebir geri getirir, restart testleri.
- [ ] **T6 Çözücü** — Kabul: BFS optimum 4/5/8, deterministik, `Unsolvable`, `SearchLimitReached`.
- [ ] **T7 JSON codec + validator** — Kabul: bozuk JSON → `LevelFormatException`, her kural için test, `docs/LEVEL_FORMAT.md`.
- [ ] **T8 Bölüm 1–3** — Kabul: asset'ler validator'dan sıfır sorunla geçer; `dart run tool/solve_levels.dart` çıkışı 0.
- [ ] **T9 GameController** — Kabul: seçim, giriş kilidi, olaylar, ipucu testleri.
- [ ] **T10 Tahta çizimi** — Kabul: geometri testleri, dokun/kaydır widget testleri.
- [ ] **T11 Ekranlar** — Kabul: bölüm 1 uçtan uca 3 yıldız widget testi, iPhone SE taşmasız, TR dil testi.
- [ ] **T12 Dokümanlar + son doğrulama** — Kabul: `AUTOMATION_SETUP.md`, `RELEASE_CHECKLIST.md`, web build, gerçek sonuçlar `PROGRESS.md`'de.

## P1 — Faz 2 (ürünleştirme)
- [ ] 12 doğrulanmış bölüm — Kabul: hepsi validator'dan geçer.
- [ ] Şehir seçimi (İstanbul oynanabilir, diğerleri `Yakında`) — Kabul: satın alınabilir gibi görünmez.
- [ ] Bölüm seçim haritası + kilit açma — Kabul: bölüm bitince sonraki açılır.
- [ ] `shared_preferences` ile ilerleme/yıldız/ayar kalıcılığı — Kabul: uygulama yeniden açılınca korunur (test).
- [ ] Yarım kalan seviyeyi geri yükleme — Kabul: arka plana alıp dönünce durum aynı.
- [ ] Ayarlar: ses, titreşim, dil — Kabul: kalıcı, TR/EN.

## P2 — Faz 3–4
- [ ] 30 doğrulanmış bölüm, bölüm 4–5 undo/restart öğreticisi.
- [ ] Ses efektleri, mini animasyonlar (switch dönüşü, teslim efekti).
- [ ] Erişilebilirlik turu (semantics, kontrast, büyük yazı).
- [ ] Yayın hazırlığı: ikon, ekran görüntüleri, lisans kontrolü, iOS/Android yerel doğrulama.
