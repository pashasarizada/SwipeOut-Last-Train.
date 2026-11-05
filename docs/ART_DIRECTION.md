# Sanat Yönetimi — "Midnight Transit"

Koyu gece zemini, yüksek kontrastlı özgün raylar, yuvarlatılmış düğümler, küçük tren kapsülleri, hafif neon istasyon ışıkları. Gerçek metro haritalarının fontu, renk düzeni ve logosu taklit edilmez.

## Şehir paletleri (resmî hat renkleri değildir)

| Şehir | Zemin | Ray | Vurgu | Atmosfer |
|---|---|---|---|---|
| Ankara | `#0E1020` | `#8A93B2` | kırmızı `#E5484D`, altın `#F2C14E` | sabah öncesi loş yeraltı |
| Bakü | `#0A1628` (Hazar laciverti) | `#93A4C0` | kumtaşı `#D9B98C`, deniz yansıması `#3BA3C7` | gece deniz |
| Paris | `#121034` (indigo) | `#A8A2C8` | amber `#F5A524`, krem `#F3E9D2` | Seine kıvrımı yalnız dekor |
| Londra | `#14161C` | `#8E96A3` | sarı `#E8C547`, bordo `#8C2F39` | yağmurlu gece, taş |
| Moskova | `#0C1018` | `#9AA6BC` | koyu kırmızı `#A3262A`, soğuk mavi `#5B8DEF` | karlı gece (kapatılabilir efekt) |

Tren stilleri (tüm şehirlerde aynı, sembolle birlikte): `coral` ● · `azure` ▲ · `lime` ■ · `amber` ◆.

## Bileşenler
- `NetworkPainter` — kenarlar (yuvarlak uçlu çizgi), makasın aktif kolu parlak / pasif kolu soluk, bekleyen kontrol önizlemesi, sinyal ışığı, hedef halkası + sembol, terminal çizgi sonu, pulse ışık dalgası.
- `TrainLayer` — trenler `before → after` arasında tween; teslimde halka parlar, ✓ eklenir (sembol kalır).
- UI süsleme `flutter_animate` (düğme/çip/yıldız/kart girişleri, çarpışma sallanması), ekran geçişleri `animations`.

## Animasyon süreleri (`lib/game/presentation/theme/motion.dart`)

| Olay | Süre |
|---|---|
| Tren hareketi (pulse) | 400 ms |
| Makas dokunuşu | 180 ms |
| Sinyal değişimi | 150 ms |
| Pulse ışık dalgası | 100 ms |
| Hedefe varış | 300 ms |
| Çarpışma flaşı | 300 ms |
| Bölüm bitişi | 700 ms |
| Ekran açılışı | 450 ms |

Animasyon sürerken komut alınmaz. `Reduced Motion` (Faz V2-B) süreleri kısaltır.

## Görsel kabul kriterleri
- 16 düğümlü tahta 320 pt genişlikte okunur; düğüm dokunma alanı ≥ 44 pt.
- Her tren ve hedefi renk **ve** sembolle ayırt edilir; gri tonlamada da ayırt edilebilir.
- İsimler yalnız seçili/kritik düğümlerde görünür.
- 60 FPS hedefi; dekoratif efektler (kar, dalga) FPS düşerse ilk kapatılanlardır.
