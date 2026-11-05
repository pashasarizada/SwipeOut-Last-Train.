# Seviye Formatı (LEVEL_FORMAT)

Seviyeler `assets/levels/level_NNN.json` dosyalarında tutulur; sırası `assets/levels/index.json` ile belirlenir. Çözümleme `LevelJsonCodec`, kural denetimi `LevelValidator` ile yapılır.

## Örnek (Bölüm 1)

```json
{
  "id": "istanbul_001",
  "number": 1,
  "width": 5,
  "height": 5,
  "optimalMoves": 4,
  "tutorialKey": "tutorialSelectSwipe",
  "cells": [
    {"x": 0, "y": 2, "type": "depot", "ports": "E"},
    {"x": 1, "y": 2, "type": "straight", "ports": "WE"},
    {"x": 2, "y": 2, "type": "straight", "ports": "WE"},
    {"x": 3, "y": 2, "type": "straight", "ports": "WE"},
    {"x": 4, "y": 2, "type": "station", "ports": "W", "color": "red"}
  ],
  "trains": [{"id": "r1", "color": "red", "x": 0, "y": 2}]
}
```

## Alanlar

| Alan | Tip | Açıklama |
|---|---|---|
| `id` | string | Benzersiz kimlik, örn. `istanbul_001` |
| `number` | int | Bölüm sırası (1'den başlar, ardışık) |
| `width`, `height` | int | 5–7 |
| `optimalMoves` | int | Çözücünün bulduğu en kısa çözüm uzunluğu ile **aynı** olmalı |
| `tutorialKey` | string? | ARB anahtarı (`tutorialSelectSwipe`, `tutorialSwitch`, `tutorialOrder`) |
| `cells` | liste | Yalnız boş olmayan hücreler; listelenmeyen hücre `empty` |
| `trains` | liste | `id`, `color`, `x`, `y` |

**Koordinat:** `x` sağa, `y` aşağı artar; (0,0) sol üst. **Yönler:** `N` (y−1), `E` (x+1), `S` (y+1), `W` (x−1). **Renkler:** `red`, `blue`, `green`, `amber` (semboller R, B, G, A).

## Hücre tipleri

| `type` | Ek alanlar | Kural |
|---|---|---|
| `straight` | `ports` | Tam iki karşılıklı yön (`WE`, `NS`) |
| `corner` | `ports` | Tam iki bitişik yön (`NE`, `ES`, `SW`, `WN`) |
| `depot` | `ports` | 1–2 yön; trenlerin başlangıç hattı |
| `station` | `ports`, `color` | ≥1 yön; aynı renkteki tren girince teslim edilir |
| `switch` | `common`, `branches`, `selected?` | `common` + iki dal; üç yön birbirinden farklı. `branches: "ES"` → dal `a` = E, dal `b` = S. `selected` `a`/`b`, varsayılan `a`. Aktif portlar = `common` + seçili dal |
| `blocked` | — | Geçilemez |

## Doğrulama kuralları (`LevelValidator`)

Yapısal kurallar (biri bile bozuksa çözücü çalıştırılmaz):
- `invalidSize` — genişlik/yükseklik 5–7 dışında
- `noTrains` — hiç tren yok
- `missingStation` — bir trenin rengine ait istasyon yok
- `duplicateTrainPosition` — iki tren aynı karede
- `trainOutOfBounds` — tren tahta dışında
- `trainNotOnTrack` — tren ray/depo/makas dışında (istasyon, boş, engel)
- `invalidTrackShape` — tip ile portlar uyuşmuyor
- `invalidSwitch` — makasın yönleri tekrar ediyor
- `portMismatch` — bir port tahta dışına ya da karşı portu olmayan komşuya bakıyor (makaslar için üç yönün hepsi sayılır)

Çözücü kuralları:
- `unsolvable` — BFS çözüm bulamadı (veya durum sınırına ulaştı)
- `optimalMismatch` — `optimalMoves` çözücünün bulduğu uzunlukla aynı değil

Bozuk JSON (eksik alan, yanlış tip, bilinmeyen tip/yön/renk) `LevelFormatException(levelId, message)` fırlatır; `id` okunamazsa `levelId` = `?`.

## Yeni seviye eklemek
1. `assets/levels/level_NNN.json` oluştur, `index.json`'a ekle.
2. `dart run tool/solve_levels.dart` → optimumu ve çözümü yazar; `issues=0` değilse çıkış kodu 1.
3. `optimalMoves`'u çıktıya göre ayarla, `scripts/check.sh` çalıştır.
