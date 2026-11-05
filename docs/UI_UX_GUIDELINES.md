# UI / UX Kuralları — "Bu bir uygulama değil, gece yarısı metrosu"

> **Bağlayıcı.** Her yeni ekran, widget ve animasyon bu belgeye uymak zorundadır. `docs/ART_DIRECTION.md` renk/süre değerlerini, bu belge **davranış ve his** kurallarını tanımlar. Kaynak: kullanıcı yönergesi 05.11.2026 (D-021…D-025).

## 0. Altın kural
Oyuncu hiçbir ekranda "bu bir Flutter/Material uygulaması" hissine kapılmamalı. Liste, form, ayarlar uygulaması, varsayılan düğme **yok**. Her ekran bir **metro mekânıdır**: peron, gişe, kalkış panosu, bilet, pasaport, tünel.

Hedef his: *gece, son sefer, sessiz istasyon, uzaktan gelen far ışığı, tatmin edici "klak" sesi ve titreşim.*

## 1. Yasak listesi (oyun ekranlarında)
Aşağıdakiler oyuncuya görünen hiçbir yerde **kullanılmaz** (testte/iç araçta serbest):

| Yasak | Yerine |
|---|---|
| `AppBar`, `BackButton` | `SignalBackButton` (sinyal lambası biçimli geri), ekran başlığı `DepartureBoard` |
| `ListTile`, `ListView` ile düz liste | Şehir **bilet kartları** karuseli, şehir **hat haritası** (istasyon noktaları) |
| `FilledButton`, `OutlinedButton`, `TextButton`, `ElevatedButton` | `GameButton` (fiziksel basma derinliği, ışıklı kenar, haptik) |
| `InputChip`, `Chip` | `ControlTicket` (bekleyen kontrol: delikli bilet şeridi) |
| `showModalBottomSheet` varsayılan görünüm, `AlertDialog`, `SnackBar` | `SplitFlapBoard` sonuç panosu, `PlatformAnnouncement` (anons şeridi) |
| `CircularProgressIndicator` | `TrackLoader` (ray üzerinde ilerleyen far) |
| Material ripple / `InkWell` sıçraması | `splashFactory: NoSplash`; basınca ölçek 0.96 + parıltı |
| Sistem fontu (Roboto/SF) | Paketlenmiş OFL fontlar (§4) |
| **Emoji** (🚆, ⭐ vb.) | Kendi çizdiğimiz ikon/sprite (`CustomPainter` veya kendi SVG'miz) |
| Flutter varsayılan uygulama ikonu, beyaz açılış ekranı, "swipeout_last_train" adı | Özel ikon, karanlık temalı açılış (§8), görünen ad **Last Train** |

`test/ui_rules_test.dart` (UX planı Görev 2) `lib/game/presentation/screens/**` içinde bu sınıfların kullanımını yasaklar.

## 2. Oyun akışı ve ekranlar

```
[TÜNEL AÇILIŞI ≤2 sn, dokununca geçer]  farlar yaklaşır → logo split-flap ile belirir
        ↓
[ANA PERON]  şehir silüeti paralaks · kalkış panosu "SON SEFER 23:59" · büyük DEVAM ET bilet-düğmesi · METRO PASSPORT · ayarlar (dişli)
        ↓
[ŞEHİR BİLETLERİ]  yatay karusel; her şehir kendi temasında bir bilet · zorluk = sinyal lambaları · gelecek şehirler "HAT YAPIM AŞAMASINDA" bariyer şeridi
        ↓
[ŞEHİR HAT HARİTASI]  6 bölüm = tek hat üzerinde 6 istasyon · çözülen hat parçası yanar · istasyona dokun → ön izleme kartı (ad, par, en iyi yıldız)
        ↓
[OYUN PERONU]  kalkış panosu HUD · şehir desenli zemin · tahta · bekleyen kontrol bileti · büyük "1 DAKİKA İLERLET" kolu
        ↓
[SPLIT-FLAP SONUÇ]  "HAT TEMİZ" harfleri tek tek döner · yıldızlar damga gibi basılır · şehir bitince PASAPORT DAMGASI sahnesi
```

## 3. Bileşen kuralları
- **GameButton:** yuvarlatılmış "bilet" gövde, 2 katmanlı (gölge tabanı + yüz), basınca yüz 3 pt aşağı iner (80 ms), bırakınca yaylanır (`Curves.easeOutBack`), `HapticFeedback.selectionClick`. Devre dışı: soluk + kilit deseni, asla gri Material.
- **Pulse kolu (`AdvanceLever`):** ekranın en büyük öğesi, alt kenara oturur, başparmakla erişilir. Basınca saat ibresi 1 dakika ilerler (HUD'da 23:54 → 23:55), raylarda ışık dalgası, orta şiddette haptik.
- **DepartureBoard (HUD):** koyu panel, amber nokta-vuruşlu (dot-matrix) rakamlar: `MOSKOVA 05 · 23:54 · 7/10 PULSE · ▣ 2/4 · KONTROL 1/1`. Rakam değişince split-flap dönüşü (120 ms).
- **ControlTicket:** bekleyen makas/sinyal, delikli bilet görünümü; iptal = bileti yırtma animasyonu (sola kayıp kaybolur).
- **SignalBackButton:** küçük sinyal direği; basınca kırmızıdan yeşile döner, sonra geri gider.
- **PlatformAnnouncement:** hata/uyarı mesajı, ekranın üstünden kayan anons şeridi (ör. "İki tren aynı durakta karşılaştı."), 1.6 sn; ses açıksa kısa özgün "ding-dong".
- **Kartlar:** keskin değil, 18–24 pt köşe; ince parlak çerçeve; şehir deseni %6–10 opaklıkta.

## 4. Tipografi
- **Gösterim (başlık):** paketlenmiş OFL font, tabela/peron havası (aday: *Unbounded*, *Bebas Neue*). 
- **Pano/rakam:** nokta vuruşlu veya monospace OFL font (aday: *Share Tech Mono*, *DotGothic16*).
- **Gövde:** okunaklı OFL sans (aday: *Inter*, *Manrope*).
- **Zorunlu glif kapsamı:** Türkçe (ğüşıöçİ), Azerbaycanca (**ə**), Fransızca (éèàçœ), Rusça Kiril (Moskova istasyon adları için). Seçim, bu glifleri çizen bir testle doğrulanır; yoksa font değiştirilir.
- Fontlar `assets/fonts/` altına **gömülür** (oyun offline; çalışma anında indirme yok). Lisanslar `SOURCE_MAPS_AND_LICENSES.md`'de.

## 5. Trenler ve animasyon
- Tren = **kendi çizdiğimiz metro vagonu sprite'ı** (`TrainSprite` painter): yuvarlak burunlu gövde, pencere şeridi, renkli livre şeridi (tren stili), burunda sembol (● ▲ ■ ◆), ön farlar.
- Vagon **gittiği yöne döner** (kenar açısı), pulse boyunca hafif ileri-geri salınım, farlardan önüne düşen ışık konisi.
- Durakta bekleyen tren: farlar yarı kısık, hafif "nefes" parıltısı (2 sn döngü — yalnız idle'da, testte kapatılabilir).
- Teslim: tren istasyon halkasına girer, halka şehir vurgu rengiyle parlar, vagon küçülüp ✓ damgasına dönüşür (300 ms).
- Çarpışma: iki vagon temas noktasına kadar gidip geri sıçrar, ekran 6 pt sarsılır (300 ms), kırmızı flaş, ağır haptik. Durum değişmez (atomik kural).
- Makas: ray kolu fiziksel olarak döner (180 ms), metalik "klak" sesi; sinyal: lamba fade + hafif titreşim.
- Tüm süreler `motion.dart`; `Reduced Motion` açıkken sallanma/paralaks/nefes kapanır, süreler yarıya iner.

## 6. Şehir temaları — aitlik hissi
Her şehir kendi **renk paleti + yerel desen + silüet + ortam efekti + selamlama + ses + damga** ile gelir (`CityTheme`). Ayrıntılı paletler `ART_DIRECTION.md`'de.

| Şehir | Yerel desen | Silüet (stilize, kendi çizimimiz) | Ortam | Selamlama |
|---|---|---|---|---|
| Ankara | Hitit güneş kursu esinli geometrik halkalar, Selçuklu yıldız geçmesi | Kale surları, Anıtkabir kolonadı ritmi, Atakule çizgisi | sabah öncesi loş sarı ışık, toz zerreleri | "Hoş geldin, başkent!" |
| Bakü | *Buta* motifi, halı geometrisi, İçerişehir kemerleri | Alev kuleleri silüeti, Kız Kalesi | Hazar dalga yansıması, hafif rüzgâr | "Xoş gəlmisən!" |
| Paris | Art Nouveau kıvrım çerçeveler, Haussmann balkon ızgarası | Eyfel **gündüz siluet çizgisi** (aydınlatma gösterisi yok), çatılar, Seine kıvrımı | amber sokak lambaları, yağmur sonrası parlama | "Bienvenue !" |
| Londra | kırmızı tuğla kemer, Viktorya demir işçiliği | Saat kulesi, köprü kuleleri | ince yağmur, ıslak zemin yansıması | "Welcome aboard!" |
| Moskova | *Hohloma* tarzı bitkisel ornament, mozaik tavan geometrisi | soğan kubbeler, yedi kız kardeş yüksek yapı ritmi | kar taneleri (kapatılabilir), soğuk mavi buhar | "Добро пожаловать!" |

Kurallar:
- Desen ve silüetler **bizim çizdiğimiz** vektör/`CustomPainter` çizimlerdir; fotoğraf kullanılacaksa yalnız kendi çekimimiz veya lisansı belgelenmiş (CC0/CC-BY) görsel, `SOURCE_MAPS_AND_LICENSES.md`'ye kayıtla.
- **Yasak:** resmî metro logoları (EGO, Bakı Metropoliteni, RATP, TfL roundel/"UNDERGROUND", Moskova "M"), resmî hat renk kombinasyonları, resmî fontlar (Johnston, Parisine vb.), resmî anons kayıtları. Eyfel'in **gece ışık gösterisi** telifli olduğu için çizilmez.
- Siyasi/dini semboller kullanılmaz; kültürel motifler saygılı ve dekoratif.
- Her şehirde arayüz metni yerel bir dokunuş taşır (selamlama, istasyon adlarının yerel yazımı: *Memar Əcəmi*, *Châtelet*), oyun dili TR/EN kalır.

## 7. Metro Passport (aitlik ve ilerleme)
- Oyuncunun **Metro Passport**'u vardır; ana peronda ve her şehir bitişinde açılır.
- Bir şehrin tüm bölümleri bitince o şehrin **damgası** basılır: Ankara, Bakü, Paris, Londra damgaları şehir renginde; **Moskova özel altın damga**.
- Damga sahnesi: pasaport sayfası açılır → damga yukarıdan iner, -8°…+8° rastgele açıyla "küt" diye basar (ölçek 1.4→1, 220 ms), mürekkep hafif dağılır, ağır haptik, tarih yerel saatle basılır. Tekrar izlenebilir.
- Henüz bitmeyen şehir: damga yeri soluk kesik çizgi + "3/6".
- Beş damga tamam: hareketli **"Night Dispatcher"** rütbe sayfası.
- Pasaport kozmetiktir; hesap/ağ yok. Oyuncu isterse pasaporta takma adını yazar (yalnız cihazda). Pasaport numarası cihazda üretilir.
- Kapak: lacivert deri dokusu, kabartma "METRO PASSPORT" + kendi tren amblemimiz; sayfa çevirme animasyonu.

## 8. Uygulama kabuğu
- Görünen ad: **Last Train** (iOS `CFBundleDisplayName`, Android `android:label`).
- Açılış ekranı (native launch): koyu zemin `#0B1020` + amblem; beyaz flaş yok.
- Uygulama ikonu ve logo: `assets/branding/logo_source.png` (gece silüeti, turkuaz vagon, amber farlar, raylarda makas motifi); ikon çerçeve içinden kırpılır, açılış ve oyun içi logo yuvarlak hâliyle kullanılır. Üretim: `scripts/build_branding.sh`. Flutter logosu kalmaz.
- Durum çubuğu açık renk ikon; tam ekran his, sistem çubukları temaya uyar.

## 9. Ses ve haptik
- Haptik dili: seçim `selectionClick`, pulse `mediumImpact`, teslim `lightImpact` ×2, çarpışma `heavyImpact`, damga `heavyImpact`.
- Sesler özgün/sentetik (makas klak, pulse tık, teslim çan, damga küt); ses kapalıyken oyun tam anlaşılır.

## 10. Erişilebilirlik (değişmez)
Renk + sembol birlikte; dokunma alanı ≥ 44 pt; `Reduced Motion` ve `High Contrast`; TR/EN metinler taşmaz (320×568 testi); dekoratif efektler FPS düşerse ilk kapananlardır.

## 11. Kabul ölçütleri (her ekran için)
1. Yasak listesinden hiçbir widget yok (`ui_rules_test`).
2. Şehir ekranlarında doğru `CityTheme` (palet + desen + silüet) görünüyor.
3. Her etkileşimde görsel + haptik geri bildirim var.
4. 320×568'de taşma yok, 60 FPS hedefi.
5. iOS simülatörde ekran görüntüsüyle elle doğrulandı, `PROGRESS.md`'ye yazıldı.
