# Kaynak Haritalar ve Lisanslar

## Referans ≠ ticari yeniden kullanım
Aşağıdaki resmî haritalar yalnız **araştırma ve ilham** içindir. İnternette erişilebilir olmaları, PDF'leri, logoları, tipografileri, renk düzenlerini, ikonları veya anonsları ücretli/ücretsiz bir oyuna koyma izni **vermez**. Oyundaki tüm ağlar bağımsız çizilmiş **kurgusal bulmaca diyagramlarıdır**; gerçek güzergâh veya sefer bilgisi olarak sunulmaz. Hiçbir metro işletmesinden onay alınmış gibi davranılmaz.

Erişim tarihi: 05.11.2026. Yayın öncesi linkler yeniden kontrol edilmeli.

| # | Şehir | Kaynak | Not |
|---|---|---|---|
| 1 | Ankara | https://www.ego.gov.tr/tr/sayfa/1075/rayli | EGO raylı sistem haritası |
| 2 | Bakü | https://metro.gov.az/storage/files/file/6683/KQryEyShr7RYJFPIh5slWi55a8BeVmezYd4an3Yq.pdf | Resmî hat haritası (PDF) |
| 3 | Bakü | https://metro.gov.az/en/page/xetlerimiz/umumi-melumat | 28 May ortak kullanım bilgisi |
| 4 | Paris | https://www.ratp.fr/en/plan-metro · https://www.ratp.fr/en/plans | RATP; işaret, font, logo kopyalanmaz |
| 5 | Londra | https://content.tfl.gov.uk/standard-tube-map.pdf | TfL Tube haritası |
| 6 | Londra | https://tfl.gov.uk/info-for/business-and-advertisers/map-licensing | **Ticari çoğaltma lisans ister** |
| 7 | Moskova | https://transport.mos.ru/metro/map | Metro + MCC + MCD şeması |
| 8 | Berlin (sonraki sürüm) | https://www.bvg.de/en/connections/network-maps-and-routes | |
| 9 | Tokyo (sonraki sürüm) | https://www.tokyometro.jp/en/subwaymap/index.html | |
| 10 | OSM | https://www.openstreetmap.org/copyright | ODbL: atıf + paylaşım koşulları |
| 11 | OSM | https://osmfoundation.org/wiki/Licence_and_Legal_FAQ | Oyunlarda kullanım SSS |

OSM verisi kullanılırsa ODbL atıf ve "share-alike" yükümlülükleri ayrıca incelenecek. Şu an kullanılmıyor.

## Kullanılan paketler

| Paket | Lisans | Neden |
|---|---|---|
| Flutter SDK, `flutter_localizations` | BSD-3-Clause | Uygulama + TR/EN |
| `intl` | BSD-3-Clause | Yerelleştirme biçimleri |
| `flutter_animate` | BSD-3-Clause | UI süsleme animasyonları (D-020) |
| `animations` | BSD-3-Clause | Ekran geçişleri (D-020) |
| Material Icons | Apache-2.0 | Yalnız geçici; oyun UI kitiyle kendi ikonlarımıza geçilecek (D-021) |
| `shared_preferences` (planlı) | BSD-3-Clause | İlerleme + Metro Passport (D-026) |
| Unbounded (`assets/fonts/Unbounded-Variable.ttf`) | SIL OFL 1.1 — `OFL-Unbounded.txt` | Başlık; kaynak github.com/google/fonts (05.11.2026) |
| IBM Plex Mono SemiBold | SIL OFL 1.1 — `OFL-IBMPlexMono.txt` | Kalkış panosu/HUD |
| Inter | SIL OFL 1.1 — `OFL-Inter.txt` | Gövde + tren sembolleri |

Ses ve görsel asset'ler: yalnız kendi üretimimiz veya lisansı belgelenmiş kaynaklar; resmî metro anonsları kullanılmaz.

## Görsel kaynak kuralları (V2.2)
- Şehir desenleri, silüetler, tren sprite'ları, damgalar ve ikonlar **bizim çizimimiz** (vektör / `CustomPainter`).
- Fotoğraf yalnız kendi çekimimiz veya CC0/CC-BY lisanslıysa; her biri bu tabloya kaynak + lisans + atıf ile eklenir.
- Yasak: EGO / Bakı Metropoliteni / RATP / TfL (roundel, "UNDERGROUND", Johnston fontu) / Moskova Metrosu "M" logoları; resmî hat renk düzenleri; resmî anons kayıtları; Eyfel Kulesi'nin gece ışık gösterisi (telifli).

## Marka görselleri
| Dosya | Kaynak | Not |
|---|---|---|
| `assets/branding/logo_source.png` | Proje sahibi tarafından sağlandı (05.11.2026) | Uygulama ikonu, açılış ve oyun içi logo bundan üretilir (`scripts/build_branding.sh`). Ticari kullanım hakkının (ör. üretildiği aracın koşulları) yayın öncesi teyit edilmesi gerekir. |

## Ses efektleri

`assets/sounds/*.wav` (switch_clack, pulse_tick, delivery, crash, level_won, stamp) **projenin kendi üretimidir**: `tool/make_sounds.py` sinüs/kare dalga ve tohumlu gürültüden sentezler; hiçbir örnek, kayıt veya resmî metro anonsu kullanılmaz. Yeniden üretmek için: `python3 tool/make_sounds.py`. Oynatma eklentisi `audioplayers` MIT lisanslıdır (D-032).

## İstasyon adları ve hat renkleri (D-036)

Hedef istasyonların yanında görünen adlar (Kızılay, 28 May, Châtelet, Paddington, Arbatskaya…) gerçek istasyon veya semt adlarıdır ve yalnız **tematik bilgi** olarak kullanılır. Oyundaki ağ, resmî haritaların kopyası değildir ve bir güzergâh iddiası taşımaz. Adlar özel ad olarak iki dilde aynı yazılır; Moskova adları Latin harfle yazılır. Tahtadaki hat renkleri (`CityTheme.lines`) bizim seçimimizdir: mor–eflatun bandından iki ton ve bir sönük şehir tonu. Hiçbir işletmenin hat renk düzeni taklit edilmez.
