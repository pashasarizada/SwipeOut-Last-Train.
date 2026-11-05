# GAME_DESIGN — SwipeOut: Last Train

**Bir cümle:** Gecenin son metro seferinde, küçük ray ağlarında farklı renkli trenleri birbirine çarptırmadan doğru renkli istasyonlarına ulaştır; makasları aç-kapa, hareket sırasını planla.

**Oyuncu vaadi:** "Tek bir makası çevirmek, üç trenin kaderini değiştirir."

Tek parmakla, sıra tabanlı, 2–5 dakikalık oturumlar; internetsiz; zaman baskısı yok.

## Tahta
- 5×5 ile 7×7 arası kare ızgara. Koordinat: x sağa, y aşağı artar; `north` = y−1.
- Hücre türleri: `empty`, `straight`, `corner`, `depot`, `switch`, `station`, `blocked`.
- Her ray hücresi N/E/S/W portlarından hangilerine açık olduğunu tutar. İki komşu hücre arasında hareket için karşılıklı portların ikisi de açık olmalı.
- İstasyonların bir rengi ve harf sembolü vardır (R, B, G, A). Renk tek bilgi kaynağı değildir.
- Bir karede en çok bir tren bulunur.

## Hamleler
- **Trene dokun** → seçilir. Tahtada tek tren kaldıysa otomatik seçilidir.
- **Kaydır (swipe)** → seçili tren o yönde tam bir kare ilerlemeye çalışır. Bir swipe = bir hamle.
- Adım şu sırayla reddedilir: mevcut hücrede o yönde port yok → hedef dışarıda ya da karşı port kapalı → hedefte tren var → hedef başka renkte istasyon.
- Doğru renkteki istasyona giren tren **teslim edilir**, tahtadan kalkar, bir daha hareket etmez.
- **Makasa dokun** → `common + seçili dal` bağlantısı diğer dala geçer. Bu da 1 hamledir. Üzerinde tren varken çevrilemez.
- Geçersiz işlem durumu değiştirmez, hamle saymaz.
- **Undo** son geçerli hamleyi bütünüyle geri alır (teslim edilen tren geri gelir), sınırsız. Hamle sayacı da düşer.
- **Restart** başlangıç durumuna döner.
- Tren animasyonu 180 ms; bu sürede yeni girdi işlenmez.

## Kazanma ve yıldız
- Tüm trenler kendi renk istasyonlarına teslim edilince bölüm biter.
- Her bölümün çözücüyle doğrulanmış optimum hamle sayısı vardır.
- Altın: ≤ optimum+1 · Gümüş: ≤ optimum+4 · Bronz: diğer her çözüm.

## Öğretici akış
1. Tek tren, düz yol: seç ve swipe.
2. Tek makas: dokunarak çevir, doğru çıkışı aç.
3. İki tren, iki hedef: sırayı doğru seç.
4–5. Undo/Restart ile sıkışmayı çözme (Faz 3).
6–15 artan makas/engel · 16–25 üç renk, çok kavşak · 26–30 3–4 tren, en fazla 3 makas.

Öğretici metinler en fazla iki satır.

## Görsel kimlik
Gece yarısı metrosu: lacivert/kömür zemin, net ray hatları, turkuaz/kırmızı/amber vurgular. Üstte `LAST TRAIN / ISTANBUL · LEVEL 07` ve hamle sayacı, ortada tahta, altta Undo / Restart / Hint. İstanbul'dan **esinlenen özgün** harita; resmî logo veya harita kopyası yok.

## MVP dışı
Sunucu, hesap, Firebase, leaderboard, multiplayer, gerçek zamanlı fizik, reklam, ödeme, 3D, otomatik store yayını.
