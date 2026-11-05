# GAME_DESIGN — özet

**Bağlayıcı belge:** [`docs/GAME_DESIGN_V2.md`](docs/GAME_DESIGN_V2.md) (V2.1). Bu dosya yalnız hızlı özet.

**Tek cümle:** Bir makası çevir, bütün metro ağının kaderi değişsin.

## NIGHT PULSE
1. **Planla:** Tek bir kontrolü seç — makas A↔B veya sinyal kırmızı↔yeşil (`Kontrol: 1/1`). İstersen hiçbirini seçme (bekle). Seçim iptal edilebilir; henüz hiçbir şey değişmez.
2. **İlerlet:** `▶ 1 DAKİKA İLERLET` → kontrol uygulanır, **bütün trenler aynı anda** bir durak ilerler.
3. **Denetim:** Aynı düğüme iki tren, kafa kafaya geçiş, duran trene çarpma veya yanlış hedef → pulse hiç olmamış sayılır, plana dönülür.

## Kurallar (kodlanmış hali)
- Ağ = düğüm (`depot`, `track`, `switch`, `signal`, `goal`, `terminal`) + kenar. Her kenar 1 pulse.
- `track`/`signal`: gelinen kenar dışındaki tek kenardan çıkılır. Kırmızı sinyal bekletir.
- Makas: trunk'tan gelen seçili kola, seçili koldan gelen trunk'a gider; pasif koldan gelen bekler.
- `goal`/`terminal` çıkmazdır; trenler geri dönmez. Kendi hedefine giren tren teslim edilir ve yer kaplamaz.
- `maxPulses` dolarsa kayıp; Undo son başarılı pulse'ı (makas/sinyal dahil) geri alır.
- Yıldız: 3 ★ ≤ par, 2 ★ ≤ par+2, 1 ★ ≤ max. Öğretici bölümlerde yıldız yok.

## Şehirler
Ankara ★ → Bakü ★★ → Paris ★★★ (sinyal) → Londra ★★★★ (halka) → Moskova ★★★★★ (çift halka). Her şehir 6 bölüm; ilk hedef 6 Ankara + 6 Bakü. Haritalar gerçek şehirlerden **esinlenen kurgusal** çizimlerdir.
