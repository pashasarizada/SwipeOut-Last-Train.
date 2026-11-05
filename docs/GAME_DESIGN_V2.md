# SWIPEOUT: LAST TRAIN — OYUN TASARIMI VE CLAUDE CODE UYGULAMA TALİMATI

**Belge sürümü:** 2.1 — 05.11.2026 (İstanbul yerine Paris güncellemesi)  
**Tür:** Offline, dikey ekran, tek parmakla oynanan sıra tabanlı metro bulmacası  
**Hedef:** iOS + Android / Flutter  
**Dil:** Kullanıcıyla ve geliştiriciyle Türkçe iletişim. Oyunda ilk sürüm Türkçe + İngilizce.  
**Üretim koşulu:** 1 ana geliştirici + Claude Code; yaklaşık 20–30 günlük geliştirme penceresi.  
**Çalışma deposu:** Bu oyun için ayrı/private GitHub repo. HeirLoam projesine dokunma.

**Şehir değişikliği (V2.1):** Önceki dokümanlarda yer alan İstanbul tamamen çıkarıldı; üçüncü şehir **Paris** oldu. `IST-*` seviye ID’leri yerine `PAR-*` kullanılacak. Beş şehir sırası sabit: Ankara → Bakü → Paris → Londra → Moskova. Eski `IST-*` JSON’ları, tema asset’leri ve referans URL’leri yeni üretime taşınmayacak.

> **Claude Code için öncelik talimatı:** Bu belge, daha önce yazılmış `SwipeOut_Claude_Master_Prompt.md` veya `GAME_DESIGN.md` ile çelişirse **oynanış, şehirler, seviye kapsamı ve görseller bakımından BU V2.1 BELGESİ GEÇERLİDİR**. Eski belgedeki güvenlik, test, Türkçe iletişim ve PR kuralları korunur. Önce V2'yi `docs/GAME_DESIGN_V2.md` olarak repoya ekle. Ardından uygulama mimarisini bu kurallara göre güncelle. Yalnızca açıklama yazma: dosyaları ve çalışır kodu üret. Yapamadığın işlemi yapılmış gibi bildirme.

---

## 0. Oyun 20 saniyede nasıl anlatılır?

Gecenin son metro seferi. **Sistemde kalan bütün trenleri doğru son istasyona ulaştırman gerekiyor.** Treni doğrudan sürmüyorsun; bir **makası değiştiriyor** veya bir **sinyali açıp kapatıyorsun**. Sonra `1 DAKİKA İLERLET` düğmesine basıyorsun. Bütün trenler **aynı anda bir durak ilerliyor**. Tek bir kararın üç ayrı treni etkileyebiliyor. Çarpışma veya hatalı çıkış olursa anında geri alıp yeniden planlıyorsun.

**Tek cümlelik vaat:** “Bir makası çevir. Bütün metro ağının kaderi değişsin.”

**Kritik yaratıcı mekanik:** `NIGHT PULSE` — Oyuncu her tur yalnızca **bir kontrol noktasına müdahale edebilir**; sonra tüm trenlerin eş zamanlı hareketini izler. Gerçek zamanlı refleks yerine birkaç hamle sonrasını düşünmek gerekir. Doğru çözüm, küçücük bir domino animasyonuna dönüşür.

**Farkımız sadece şehir teması değildir:** tek hamlenin zincirleme sonuçları, aynı anda ilerleyen trenler, sınırlı kontrol hakkı ve şehir bazlı özel ağ geometrileri oyunun esasını oluşturur. Bunun bütünüyle benzersiz olduğunu iddia etme; rakip/benzer oyun araştırması yayın öncesi ayrıca yapılmalıdır.

---

## 1. Ürün kararı ve değişmeyecek sınırlar

- Dikey ekran; telefon tek elle tutulurken oynanabilir.
- Her bölüm hedef süre **45 saniye–3 dakika**, daha zor bölümler **3–5 dakika**; canlı geri sayım yok.
- Telefon çekmese de bütün bölüm ve kayıt sistemi çalışır.
- 2D grafik: haritadan esinlenen ama **oyun için yeniden çizilmiş**, sade, temiz ve animasyonlu ray şeması.
- 3D tren sürüşü, açık dünya, gerçek bilet/turnike, metro şirketinin resmî uygulaması, gerçek sefer takvimi YOK.
- Oyuncu trenlerin hızını sürgüyle kontrol etmez; fizik simülasyonu YOK.
- İstasyon sayısı şehir ağının tamamı kadar değil; her bölümde **6–16 düğümlü** küçük, okunur bir alt bulmaca.
- Oyunun omurgası **beş şehir ve otuz doğrulanmış bulmaca**: Ankara → Bakü → Paris → Londra → Moskova. **Moskova açık ara en zor dünya.**
- Geliştirme riski nedeniyle önce **6 Ankara + 6 Bakü** bölümü sağlamlaştır; sonra diğer şehirleri aynı motor ve veri şemasıyla ekle. **30 bölüm ilk yayın için hedef, kalite bozulursa yapay biçimde şişirme.**
- Uygulama sahte, resmî metro haritası gibi görünmeyecek. Açıklama: “Gerçek şehirlerden esinlenen kurgusal metro bulmacaları.”
- İlk prototipte reklam, AdMob, IAP, Firebase, backend, canlı servis, multiplayer yok. Gelir modeli gerçek oyuncu testi sonrası kararlaştırılır.

### Oyuncunun öğrenme sırası

1. “Dakikayı ilerlet; tren hareket etsin.”
2. “Makası değiştir; tren farklı raya girsin.”
3. “İki tren aynı anda hareket eder.”
4. “Tek turda yalnızca bir kontrol değiştirilebilir.”
5. “Bazen bekletmek ve doğru anı seçmek gerekir.”
6. “Ağ karmaşıklaşır: hat birleşimi, sinyal, halka ve senkronizasyon.”

---

## 2. Oyun ekranları ve gezinti akışı

```text
[SPLASH — 2 sn, opsiyonel]
     ↓
[ANA MENÜ]  "SON SEFER BAŞLIYOR"
     ├── DEVAM ET
     ├── ŞEHİR SEÇ
     ├── NASIL OYNANIR
     └── AYARLAR
           ↓
[2 MINI TUTORIAL — ilk açılışta]
           ↓
[ŞEHİR SEÇİMİ — stilize dünya haritası / kartlar]
     ├── ANKARA ★☆☆☆☆
     ├── BAKÜ ★★☆☆☆
     ├── PARİS ★★★☆☆
     ├── LONDRA ★★★★☆
     └── MOSKOVA ★★★★★  "NIGHTMARE NETWORK"
           ↓
[ŞEHRİN KÜÇÜK METRO HARİTASI + 6 LEVEL NOKTASI]
           ↓
[OYUN TAHTASI] → [BAŞARI / YENİDEN DENE]
           ↓
[ŞEHİR HARİTASINA DÖN / SONRAKİ BÖLÜM]
```

**Şehir seçimi ilk öğreticiden sonra serbest** olsun; kullanıcı Paris'i veya Bakü'yü doğrudan açabilsin. Zorluk etiketini görsün. Moskova kilitli bir ödeme duvarı değil, isteğe bağlı **ağır meydan okuma** olsun. Her şehir içinde bölüm 1 açıktır; sonraki bölümler sırayla açılır. Böylece “oyuna girince şehrini seç” beklentisi karşılanır.

**İlerleme hissi:** Her çözülen bölümde şehir haritasındaki küçük bir hat parçası aydınlanır. Şehrin 6 bölümü bitince **“SON SEFER TAMAMLANDI”** damgası kazanılır; beş şehri bitirene özel hareketli “Night Dispatcher” rozeti. Bu ödüller kozmetiktir.

---

## 3. GERÇEK OYNANIŞ — kesin ve kodlanabilir kurallar

### 3.1 Harita modeli

Sahne bir **graf (graph)**: istasyon/kavşak düğümleri (`Node`) ve bu düğümler arasındaki ray bağlantıları (`Edge`). Düğümlerin `x,y` koordinatları 0.0–1.0 arasında normalize tutulur. Şehirleri birebir haritaya dönüştürmeye çalışma; istasyon adları/tasarımlar yalnızca temayı destekler.

Düğüm türleri:
- `depot`: Tren başlangıcı.
- `track`: Normal geçiş; gelen tren mümkünse geldiği bağlantı dışındaki tek yoldan çıkar.
- `switch`: Bir ana bağlantı (`trunk`) ve iki alternatif kol (`A`/`B`). Makas tek seferde bir kola açıktır.
- `signal`: Bu düğümde bekleyen trenin çıkışına izin veren kırmızı/yeşil kontrol.
- `goal`: Belirli trenin ulaşması gereken hedef istasyon.
- `terminal`: Hedef olmayan ve çıkmaz oluşturan ray ucu (zor seviyeler için).

Ray bağlantısı `Edge` iki düğümü birleştirir; MVP'de hareket süresi her bağlantı için **tam 1 pulse**. Çizimde eğri olabilir ama süre değişmez. Başlangıçta köprü/alt geçit gibi kesişen çizgiler **aktarma yaratmaz**; ancak araya gerçek `Node` konulursa bağlantı vardır.

Tren verileri:
- Benzersiz `id`, renk **ve simge**, mevcut `nodeId`, en son geldiği `incomingEdgeId` (depo başlangıcında `null`), hedef `goalNodeId`, `status` (`waiting`, `delivered`).
- Normalde tüm trenler başlangıçta tahtadadır. **Zamanlanmış geç gelen tren** özelliği yalnızca ileri Moskova bonus sürümü için öneri; ilk 30 bölümün motorunu buna bağımlı yapma.
- Bir düğümde en fazla bir hareketli tren olabilir.
- Trenler otomatik ilerler; kullanıcı sürükleyip bir istasyondan ötekine tren taşımaz.

### 3.2 NIGHT PULSE — bir turdaki tam işlem

**Aşama A: PLANLAMA (oyuncunun ekranı)**

1. Oyuncu **tek bir** kontrol noktası seçebilir: bir makası `A↔B` yapmak **veya** sinyali `kırmızı↔yeşil` yapmak. `Kontrol hakkı: 1/1`.
2. İsterse **hiçbir kontrol değiştirmeden** pulse geçirebilir; bazen doğru strateji beklemektir.
3. Seçili müdahale `pendingAction` olarak ekranda tutulur; **henüz tren veya oyun durumu değişmez**.
4. Yanlış kontrolü seçtiyse `İptal` ederek pendingAction'ı kaldırabilir ve başka seçim yapabilir. Bu nedenle istemsiz dokunma kalıcı hata yaratmaz.
5. Seçilen makas yönü canlı önizlemede gösterilir. En fazla **bir sonraki pulse** için yarı saydam “hayalet tren” noktaları çizilebilir; tam çözüm otomatik gösterilmez.
6. Oyuncu alttaki büyük **`1 DAKİKA İLERLET ▶`** düğmesine basar.

**Aşama B: UYGULAMA (atomik oyun motoru)**

1. `pendingAction` varsa ilgili switch/signal durumu değiştirilir.
2. Bütün aktif trenlerin **eş zamanlı** bir sonraki hedef düğümü hesaplanır. Bu hesaplama güncel durumdan başlar; başka trenin aynı pulse'daki kararından etkilenmez.
3. Hareket edebilen tren bir bağlantı ilerler; sinyal kırmızıysa veya geçerli açık yol yoksa yerinde bekler.
4. Bütün hedefler belli olduktan sonra çarpışma/yanlış hedef/son dakika denetimi yapılır.
5. Her şey geçerliyse sonuç tek işlemde commit edilir, `pulse += 1`, trenler **aynı anda animasyonla** hareket eder.
6. Bir tren **kendi** `goal` istasyonuna girince hedefe ulaşmış sayılır; 250 ms ışık/park animasyonundan sonra ray üstü doluluğundan çıkar, tabloda ✓ görünür.
7. Tüm trenler doğru hedeflere ulaşırsa seviye biter.

**Çarpışma kuralları (kritik):**
- İki tren **aynı boş düğüme** hareket etmeye çalışıyorsa çarpışma.
- İki tren aynı bağlantı üzerinde **birbirlerinin konumlarına karşılıklı geçiş yapıyorsa** kafa kafaya çarpışma.
- Bir trenin hedeflediği düğümde duran tren **bu pulse ayrılmıyorsa** çarpışma.
- Zaten boşaltılacak bir düğüme girme, başka kural bozulmuyorsa mümkündür; eş zamanlı zincir hareketi bu yüzden anlamlıdır.
- Bir tren yanlış renk/simge hedef istasyonuna girerse **yanlış hat** hatası.
- Bir tren hedef olmayan çıkmazda mahsur kalırsa motor bunu otomatik kayıp saymak zorunda değil; kalan pulse hakkı bitince kayıp olur. Çözücünün bu durumu dead-end olarak tanıması gerekir.
- Pulse sırasında hata çıkarsa **hiçbir kısmi durum commit edilmez**. Kısa kırmızı titreşim/çarpışma animasyonu göster, aynı planlama durumuna geri dön, kullanıcı kontrolü düzeltsin. Gereksiz can/kalp harcama.

**Makas kuralı:** Switch'in üç kenarı `trunk`, `branchA`, `branchB` olarak seviyede sabittir. Aktif bağlantı yalnızca `trunk ↔ seçili branch` çiftidir. Tren trunk'tan geliyorsa seçili kola; aktif koldan geliyorsa trunk'a çıkabilir. Pasif koldan gelmişse makas yeniden yönlendirilene kadar **bekler**. Hiçbir tren teleport olmaz veya kapalı rayın içinden geçmez.

**Sinyal kuralı:** Sinyal `signal` düğümündedir. Kırmızıysa **orada duran tren çıkamaz**, yeşilse diğer ray kuralları geçerlidir. Oyuncu o pulse'da sinyali değiştirmeyi seçebilir; switch'e ayrıca müdahale edemez. Sinyaller ilk Ankara/Bakü bölümlerinde görünmez; Paris'te açılır.

**Limit:** `maxPulses` bulunan seviyelerde oyuncu bu sayıda geçerli pulse içinde bütün trenleri hedeflere ulaştırmalıdır. **Gerçek zamanlı geri sayım yoktur**; oyuncu metroda oyunu bırakabilir. Süre bitiminde oyunu durdur, `Geri Al` veya `Tekrar Oyna` sun. `Undo` son başarılı pulse'ın tüm durumunu (konumlar + gelen raylar + switch/signal durumları + teslimler + sayaç) geri yükler. Başarısız denemeler pulse harcamaz.

### 3.3 Ödül ve skor

- **3 yıldız:** doğrulanmış en iyi pulse sayısı (`parPulses`) veya ona çok yakın.
- **2 yıldız:** `parPulses + 1–2`.
- **1 yıldız:** `maxPulses` içinde başarı.
- Optimum sayısı solver tarafından biliniyorsa onu kullan; bilinmiyorsa uydurma "optimum" etiketi kullanma. `parPulses` insan tarafından doğrulanmış önerilen iyi çözüm olabilir.
- İlk 2 öğretici bölümde yıldız baskısı yok; eğitici başarı hissi var.
- Reklam izlemek, para ödemek veya şans mekanikleri olmadan bütün bölümler kazanılabilir.

### 3.4 Neden strateji var?

Örnek: Mavi ve kırmızı tren bir dar boğaza yaklaşıyor. Bu pulse'da makası maviye açarsan mavi kurtulur ama kırmızı gelecek pulse'da aynı düğüme sıkışır. Önce kırmızıyı bir pulse bekletip maviye yol verirsen ikisi de geçebilir. **Bir sonraki değil, iki–üç sonraki tren pozisyonunu düşünmek** kazandırır.

---

## 4. Oyunun gerçekten nasıl oynandığını gösteren 2 sahne

### Örnek 1 — Ankara / Level 01 “İlk Sefer”

```text
                                     [C: KIRMIZI HEDEF ★]
                                    /
[A: KIRMIZI TREN] ─── [B: MAKAS]
                                    \
                                     [D: KAPALI HAT]
```

Başlangıçta B makası D'ye açık. Oyuncu:
- `1 DAKİKA İLERLET` → tren A'dan B'ye gelir.
- B'ye dokunur, C yönünü seçer → `1 DAKİKA İLERLET`.
- Tren C'ye gider. İki pulse, ilk başarı animasyonu. Tutorial 30 saniyeyi geçmez.

Buradaki istasyon ve ray yerleşimi **temsili bulmaca şemasıdır**, Ankara metrosunun birebir haritası değildir.

### Örnek 2 — Bakü / “28 May Darboğazı”

```text
       R tren ──┐              ┌── R hedef
                ├── [ORTAK İSTASYON] ── [MAKAS]
       B tren ──┘              └── B hedef

     Aynı istasyonu aynı anda iki tren kullanamaz.
```

Oyuncunun **hangi treni önce geçirip hangisini sinyalle bekleteceğini** düşünmesi gerekir. Ancak Bakü'nün ilk altı bölümünde sinyal mekaniği kullanılmayacağından başlangıçta bu fikir **iki farklı giriş kolundan farklı pulse'larda geliş** ve makas kontrolüyle tasarlanacak; *sinyalli varyantı ileride bonus bölüm* olabilir. İlk prototipe şematik çizim koymak yetmez: gerçek graf verileriyle çözülebilir sahne oluştur.

---

## 5. Şehir sistemi — gerçek haritadan esinlenen 5 özgün dünya

**DİKKAT — TELİF VE DOĞRULUK:** Aşağıdaki resmî haritalar yalnızca **araştırma referansı**dır. Harita PDF'lerini, logoları, tipografilerini, ayırt edici tasarım düzenlerini veya resmî ikonlarını oyuna gömmek **yasak**; açık lisans veya yazılı izin gerektirir. Özellikle TfL, Tube haritasının ticari çoğaltılması için lisans istemektedir. İstasyon adları/hat bağlantıları bilgi olarak incelenebilir; ticari ürünün görseli **bağımsız olarak çizilmiş oyun diyagramı** olacak. Şirketlerden onay varmış gibi davranma. OSM kullanılırsa ODbL yükümlülükleri ve atıf ayrıca incelenecek.

### 5.1 Ankara — Başlangıç şehri / ★☆☆☆☆

**Resmî ağ referansı:** https://www.ego.gov.tr/tr/sayfa/1075/rayli  
**İlham:** Ankaray A1 (AŞTİ–Dikimevi); M1 Batıkent–Kızılay; M2 Çayyolu–Kızılay; M3 Batıkent–Törekent; M4 Keçiören–AKM. Gerçek bağlantılar yalnızca EGO haritasıyla teyit edilirse temsil edilir.  
**İkonografi:** Kızılay kent merkezi; sade kırmızı-altın vurgu; yeraltı istasyonunda loş sabah öncesi hava.  
**Geometri:** 6–7 düğüm, 1–2 tren, 1–2 makas; halka yok.  
**Öğrettiği:** Pulse, makas, karşılıklı hareket, undo.  
**Şehir bitiş animasyonu:** Kızılay merkezinden dış hatlara ışık yayılır, “ANKARA SON SEFERİ TAMAMLANDI” damgası.

### 5.2 Bakü / ★★☆☆☆

**Resmî ağ haritası PDF:** https://metro.gov.az/storage/files/file/6683/KQryEyShr7RYJFPIh5slWi55a8BeVmezYd4an3Yq.pdf  
**Resmî hat bilgisi:** https://metro.gov.az/en/page/xetlerimiz/umumi-melumat  
**İlham:** Kırmızı, Yeşil, Mor hatlar; `28 May` (kırmızı/yeşil ortak kullanım), `Memar Əcəmi` aktarma fikri. Gerçek Bakü metrosunda kırmızı ve yeşil hatların 28 May'daki birleşimi özellikle ayırt edici.  
**İkonografi:** Hazar gecesi, deniz yansıması, kumtaşı ve koyu lacivert. İstasyon adlarında Azerbaycan Türkçesindeki diakritikleri koru.  
**Geometri:** 7–9 düğüm, 2 tren, 1–2 makas, **ortak ray/boğaz**.  
**Öğrettiği:** Aynı dar boğaza iki treni aynı anda sokmama; hareket sırası.

### 5.3 Paris / ★★★☆☆

**Resmî RATP metro haritası:** https://www.ratp.fr/en/plan-metro  
**Resmî RATP hat planları:** https://www.ratp.fr/en/plans  
**İlham:** Paris metrosunun merkezde sıklaşan aktarmaları ve farklı hatların kesişimi. `Châtelet`, `République`, `Bastille` ve `Gare du Nord` gibi isimler yalnızca tematik referans olarak kullanılabilir; **oyundaki ray topolojisi resmî RATP planının kopyası olmayacak**. Özellikle aynı aktarma düğümüne farklı kollardan yaklaşan trenlerin zamanlamasına odaklan.  
**İkonografi:** Seine Nehri'nin kıvrımı yalnızca arka plan grafiği, uzakta stilize gece silüeti, amber ışıklar, koyu indigo ve krem tonları. RATP işaretlerini, resmî Paris metro şemasının ayırt edici tipografisini/ikonlarını ve logolarını kopyalama.  
**Geometri:** 9–11 düğüm, 2–3 tren, 2 makas, **ilk sinyal**; merkezi bir ortak aktarma düğümü ile alternatif iki giriş kolu. Halka mekanikleri **ilk kez Londra'da** öğretilir.  
**Öğrettiği:** Bir treni sinyalle geçici bekletmek; paylaşılan aktarmayı çarpışmadan boşaltmak; iki hat arasında doğru pulse zamanlaması.  
**Özel görsel:** Pulse sonrasında merkezi düğümün ışığının çevredeki hatlara yayılması; Seine çizgisi yalnızca dekorasyon, gerçek ulaşım planı değil.

### 5.4 Londra / ★★★★☆

**Resmî TfL PDF:** https://content.tfl.gov.uk/standard-tube-map.pdf  
**TfL ticari harita lisansı:** https://tfl.gov.uk/info-for/business-and-advertisers/map-licensing  
**İlham:** Circle benzeri halkasal dolaşım, Central/Northern/Victoria gibi birden fazla hat arasında aktarma. Gerçek Tube haritasının ikonik çizim dilini veya logosunu birebir taklit etme.  
**İkonografi:** Yağmurlu gece, taş istasyon, zarif sarı/bordo vurgular (resmî renk paletini kopyalama).  
**Geometri:** 10–13 düğüm, 3 tren, 2–3 makas, en az bir küçük halka/alternatif yol.  
**Öğrettiği:** Halka içinde çevrim planlama, yanlış turdan kaçınma, iki pulse sonrası sonuçları düşünme.

### 5.5 Moskova — SON ŞEHİR / ★★★★★

**Moskova Ulaşım Portalı resmî şema:** https://transport.mos.ru/metro/map  
**İlham:** Radyal hatların merkezde kesişmesi; iç dairesel hat ve daha geniş halka yapısından esinlenerek **iç içe iki halka** oluşturma. Gerçek ağda büyük dairesel metro hattı (Big Circle Line/BKL) vardır; oyun haritası birebir kopyalanmayacak.  
**İkonografi:** Karlı gece, istasyon lambaları, koyu kırmızı/soğuk mavi alt tonlar, halka boyunca ilerleyen ışık izleri.  
**Geometri:** 12–16 düğüm, 3–4 tren, 3–4 makas, 1–2 sinyal, iç+dış halka, birkaç paylaşılan düğüm.  
**Öğrettiği:** 3 adım sonrası planlama, sinyal ile geçiş sırası, iki halka arasında rota seçimi.  
**Final:** Üç–dört trenin art arda kurtulduğu, 1–2 saniyelik görsel açıdan tatmin edici “tüm ağ yeşile döndü” final animasyonu.

**Neden Moskova en zor?** Yalnızca düğüm sayısı değil; **aynı zamanda hareket eden tren sayısı, iç/dış halkalar, kısıtlı sinyal/makas hakkı ve paylaşılmış darboğazlar** nedeniyle daha yüksek stratejik derinlik.

### Sonraki sürüm şehirleri (ilk 30 bölüme EKLEME)

- **Berlin:** https://www.bvg.de/en/connections/network-maps-and-routes — U/S-Bahn ayrımı ve çapraz bağlantılar.
- **Tokyo:** https://www.tokyometro.jp/en/subwaymap/index.html — kodlanmış istasyonlar ve çoklu aktarmalar.

**Not:** İnternette resmî PDF bulmak, o PDF'yi ücretli bir oyuna koymaya izin verildiği anlamına gelmez.

---

## 6. Seviye planı — 30 bulmaca, BASİTTEN ZORA

Her şehrin altı bölümü olacak. Bu tablo `assets/levels` veri dosyalarını tasarlamak için **tasarım hedefidir**; gerçek seviyeler solver ve insan testiyle doğrulanmadan “hazır” kabul edilemez. `N` düğüm sayısı, `T` tren sayısı.

| ID | Şehir | İsim | Hedef mekanik | Yaklaşık tahta |
|---|---|---|---|---|
| ANK-01 | Ankara | İlk Sefer | 1 tren, 1 makas, iki pulse | 4–5 N / 1 T |
| ANK-02 | Ankara | Kızılay Yönü | Makas yanlış kolu kapatıyor | 5 N / 1 T |
| ANK-03 | Ankara | İki Vagon | İki tren aynı anda hareket eder | 6 N / 2 T |
| ANK-04 | Ankara | Son Aktarma | Önce kimin geçeceğini bul | 6–7 N / 2 T |
| ANK-05 | Ankara | Bir Dakika Daha | maxPulses ilk kez tanıtılır | 7 N / 2 T |
| ANK-06 | Ankara | Başkent Finali | 2 makas, tek müdahale hakkı | 7–8 N / 2 T |
| BAK-01 | Bakü | Hazar Gecesi | İki güzergâhı çakıştırma | 7 N / 2 T |
| BAK-02 | Bakü | 28 May | Ortak hat darboğazı | 8 N / 2 T |
| BAK-03 | Bakü | Memar Əcəmi | Aktarmadan önce makas seçimi | 8 N / 2 T |
| BAK-04 | Bakü | Kırmızı mı Yeşil mi? | İki makas zamanlaması | 8–9 N / 2 T |
| BAK-05 | Bakü | Kapanan Koridor | Beklemek ilerleme sağlar | 9 N / 2 T |
| BAK-06 | Bakü | Son Bakı Seferi | İki tren, dar pulse limiti | 9 N / 2 T |
| PAR-01 | Paris | Gece Aktarması | 2 tren, iki giriş kolu, ortak aktarma | 9 N / 2 T |
| PAR-02 | Paris | Kırmızı Sinyal | İlk `signal`: bir treni beklet | 9 N / 2 T |
| PAR-03 | Paris | Châtelet Kavşağı | Aynı düğüme farklı pulse'larda ulaş | 10 N / 2 T |
| PAR-04 | Paris | République Önceliği | 3 tren; sinyal + makas eşgüdümü | 10 N / 3 T |
| PAR-05 | Paris | Üç Son Sefer | Bir pulse'da yalnız bir kontrol değiştirerek 3 tren yönet | 11 N / 3 T |
| PAR-06 | Paris | Paris Gece Finali | Merkez aktarmada gecikme ve eşzamanlı geçiş | 11 N / 3 T |
| LON-01 | Londra | Ring Entrance | Halka rota fikrini öğret | 10 N / 2 T |
| LON-02 | Londra | One More Loop | Fazladan tur zararlı olabilir | 11 N / 3 T |
| LON-03 | Londra | Last Transfer | Halka + giriş/çıkış makası | 11 N / 3 T |
| LON-04 | Londra | Parallel Lines | 3 tren, iki alternatif koridor | 12 N / 3 T |
| LON-05 | Londra | Signal at Midnight | Sinyal ve halkayı birlikte kullan | 12 N / 3 T |
| LON-06 | Londra | Final Circle | Küçük optimum pulse aralığı | 13 N / 3 T |
| MOS-01 | Moskova | Soğuk Başlangıç | 3 tren; çift halka tanıtımı | 12 N / 3 T |
| MOS-02 | Moskova | İç Halka | Doğru halka girişini seç | 13 N / 3 T |
| MOS-03 | Moskova | Dış Halka | İki halkayı farklı zamanda kullan | 13 N / 3 T |
| MOS-04 | Moskova | Merkez Kilidi | 3–4 tren, ortak düğüm | 14 N / 4 T |
| MOS-05 | Moskova | Son Sinyal | 4 makas + sinyal, dar hamle | 15 N / 4 T |
| MOS-06 | Moskova | LAST TRAIN | 16 N, 4 tren, 2 halka, final | 16 N / 4 T |

**Önemli:** Bu 30 satır *test edilip çözümlenmiş* seviye değildir; isim ve tasarım brifidir. Claude veriyi üretirken en az bir gerçek, kayıtlı çözüm bulmalı; mümkünse otomatik solver ile doğrulamalıdır. Yalnızca rengini değiştirip aynı haritayı altı kez sunma.

### Şehirler arası mekanik büyüme

- Ankara: `pulse`, basit `switch`, `undo`, `maxPulses`.
- Bakü: ortak ray kullanımı ve geçiş sırası; **yeni UI kontrolü yok**, zorluk mantıktan doğuyor.
- Paris: yeni **signal** kontrolü; merkez aktarma düğümünde zamanlama.
- Londra: yeni **loop/ring** harita geometrisi, aynı kurallar.
- Moskova: **iki ring + çok sayıda eş zamanlı tren**; yeni kontrol öğretme, mevcut kuralları ustaca birleştir.

---

## 7. Ekran tasarımı ve animasyon dili

### Görsel stil: “Midnight Transit”

- Kullanılacak çizim: özgün 2D vektör/spline ray yolları, yuvarlatılmış düğümler, küçük tren kapsülleri, hafif neon istasyon ışıkları.
- Koyu gece zemininde kontrastı yüksek raylar; her şehir **ayrı genel atmosfer** taşımalı.
- Gerçek metro haritalarının kendine özgü fontlarını, renk kombinasyonlarını veya logolarını taklit etme; özgün tasarım sistemi kur.
- Çizimde `CustomPainter`, `Path`, `Canvas`, Flutter `AnimationController` tercih edilir. Fizik motoru gerekmez. Ağır sprite sistemi/Flame bağımlılığı zorunlu değil.
- Düğümlerde isim **yalnızca seçili veya kritik istasyonlarda** gözüksün; 16 düğümlü Moskova küçük ekranda okunabilmeli.
- Renk körlüğü için trende ve hedefte **hem renk hem sembol** (`●`, `▲`, `■`, `◆`) olsun.

### Oyun ekranı taslağı

```text
┌────────────────────────────────┐
│ 🌙 LAST TRAIN       MOSKOVA 05 │
│ 23:54 · 7/10 PULSE · 🚆 2/4   │
│ Kontrol: 1/1                  │
│                                │
│       (özgün, animasyonlu)      │
│       ─── ● ──╮               │
│      ◇       ◎    ▲            │
│       ╲  ✦───╯   ╱             │
│        ○───────○               │
│                                │
│ [ ↻ MAKAS 2 ] [ 🟥 SİNYAL 1 ] │
│                                │
│  [ ↶ Geri Al ] [ ⟳ Baştan ]   │
│ ┌────────────────────────────┐ │
│ │  ▶  1 DAKİKA İLERLET       │ │
│ └────────────────────────────┘ │
└────────────────────────────────┘
```

### Animasyon zamanları ve davranışı

| Olay | Hedef animasyon | Süre |
|---|---|---|
| Ekran açılışı | Şehir ışıkları yumuşak açılır, hatlar sırayla çizilir | 350–600 ms |
| Makas dokunuşu | Seçili ray aydınlanır, kol 1 konumdan 2'ye yumuşak döner | 140–220 ms |
| Sinyal değişimi | Kırmızı/yeşil ışık fade + hafif titreşim | 120–180 ms |
| `Pulse` basışı | Ray üzerinden kısa ışık dalgası geçer | 80–120 ms |
| Tüm trenlerin hareketi | Trenler aynı anda düğümden düğüme ilerler | 350–500 ms |
| Duruş | Tren durak merkezine kısa ease-out ile yerleşir | 80–120 ms |
| Tren hedefe varışı | İstasyon halkası parlar; tren ✓ simgesine dönüşür | 260–400 ms |
| Çarpışma | Kısa kırmızı flash + iki trenin geri alınması | 250–400 ms |
| Bölüm bitişi | Tüm çözülmüş güzergâhlar ışıkla sırayla belirir, 3 yıldız | 500–850 ms |
| Şehir tamamlama | Stilize genel metro ağında hat ışıkları domino gibi yanar | 900–1500 ms |

**Animasyon prensibi:** İş mantığı **animasyondan bağımsız** saf Dart durum değişimidir. Ekranda `tickStateBefore` ve `tickStateAfter` arasında tween uygula. Animasyon sürerken ikinci komut alma. Oyun arka plana geçerse deterministik tamamlanan duruma yerleş; yarım animasyon ve bozuk kayıt bırakma.

### Küçük dokunuşlar

- Pulse başında uzak istasyon anonsu gibi kısa **özgün sentetik** bir ses; resmî metro anonslarının kaydını izinsiz kullanma.
- 1–2 farklı titreşim paterni: geçerli seçim, başarılı teslim, hata.
- `Reduced Motion` seçeneği: animasyon hızını kısaltır veya geçişleri kapatır.
- Ses kapalı oynanabilmeli; metroda kulaklık gerektirmesin.
- `High Contrast` tema; buton dokunma alanı erişilebilir büyüklükte.
- Moskova'nın kar/ışık efekti sadece dekoratif; FPS bozarsa ilk kapatılacak efekt bu.

---

## 8. Seviye veri formatı — JSON örneği

Her seviye tek JSON dosyası. Örnek yalnızca **ANK-01 eğitici haritası**dır. Düğüm koordinatları temsili; `stationLabel` gerçek bağlantı iddiası değildir.

```json
{
  "id": "ANK-01",
  "city": "ankara",
  "title": {"tr": "İlk Sefer", "en": "First Departure"},
  "maxPulses": 5,
  "parPulses": 2,
  "maxChangesPerPulse": 1,
  "nodes": [
    {"id": "A", "kind": "depot", "x": 0.13, "y": 0.50},
    {"id": "B", "kind": "switch", "x": 0.48, "y": 0.50},
    {"id": "C", "kind": "goal", "x": 0.84, "y": 0.25},
    {"id": "D", "kind": "terminal", "x": 0.84, "y": 0.76}
  ],
  "edges": [
    {"id": "AB", "a": "A", "b": "B"},
    {"id": "BC", "a": "B", "b": "C"},
    {"id": "BD", "a": "B", "b": "D"}
  ],
  "switches": [
    {"nodeId": "B", "trunkEdge": "AB", "branchAEdge": "BC", "branchBEdge": "BD", "selectedBranch": "B"}
  ],
  "signals": [],
  "trains": [
    {"id": "red_1", "startNode": "A", "goalNode": "C", "symbol": "circle", "style": "coral"}
  ],
  "tutorialSteps": [
    {"tr": "Trenler her dakikada bir durak ilerler.", "en": "Trains move one stop each minute."},
    {"tr": "Makası doğru raya çevir.", "en": "Switch to the correct track."}
  ]
}
```

**Şema gereksinimleri:**
- `nodes` ve `edges` referansları benzersiz, geçerli ve sınırlar içinde.
- Normal düğümde hareketin hangi yöne devam edeceği belirsizse validator hata vermeli; rastgele bir yol seçilmemeli.
- `switch` için `trunk`, `branchA`, `branchB` üçü de aynı düğüme bağlı ayrı edge olmalı.
- `signal` yalnızca mevcut `signal` düğümüne referans verebilmeli.
- Tren başlangıç düğümleri ve hedefleri geçerli olmalı; hedefler tren başına benzersiz olmalı (aksi bilinçli tasarlanmadıkça).
- `parPulses <= maxPulses` olmalı ve gerçek çözümle doğrulanmalı.
- Seviye amaç, par ve sınırları açık olmalı; çözülemeyen veya sonsuza kadar beklenen seviyeyi yayımlama.
- Bir de `assets/levels/index.json` veya eşdeğer manifest ile şehir ve sıralama bilgileri tanımlanmalı.

---

## 9. Çözücü, testler ve bölüm kalitesi

**En kritik ürün kuralı: BÖLÜMLER GERÇEKTEN ÇÖZÜLEBİLİR OLMALI.** Bir AI'nın keyfine göre 30 JSON üretmesi oyun geliştirmek değildir.

### Oyun motorunu UI'dan ayır

```text
lib/
  app/                # router, theme, localization
  game/domain/        # graph, node, edge, switch, signal, train, game state
  game/engine/        # Pure Dart tick reducer, collision checker, undo, solver
  game/data/          # level JSON loader, progress persistence
  game/presentation/  # CustomPainter board, animations, controls
  worlds/             # city cards, themes, world progression
assets/
  levels/             # ANK-01.json ... MOS-06.json
  sounds/             # original, licensed SFX only
  images/             # own original city backdrops (if any)
test/
  engine/
  levels/
  widgets/
docs/
  GAME_DESIGN_V2.md
  LEVEL_FORMAT.md
  ART_DIRECTION.md
  SOURCE_MAPS_AND_LICENSES.md
  PROGRESS.md
```

### Motor sözleşmesi

```text
GameState applyAction(GameState state, PendingControlAction? action)
PulseResult simulatePulse(GameState state, PendingControlAction? action)
GameState undoPulse(GameState state)
ValidationResult validateLevel(LevelDefinition level)
SolveResult solveLevel(LevelDefinition level, {int maxExploredStates})
```

`simulatePulse` saf/tekrarlanabilir olmalı. Aynı seed ve aynı hareket dizisi **daima aynı sonucu** vermeli. İlk 30 bölümde rastgelelik gerekmez.

**Solver:** BFS veya A*; state anahtarı `train positions + incoming edges + delivered bits + switch states + signal states + current pulse`. Her pulse için eylem seçenekleri: `none`, her switch toggle, her signal toggle (toplamda bir tanesi). Büyük Moskova bulmacalarında patlamayı önlemek için durum sınırı koy; arama sınırına takılırsa **çözüldü diye rapor verme**, bilinen insan/elle tasarlanmış çözüm dizisini replay test et. Mümkünse optimum pulse sayısı hesapla; değilse yalnız doğrulanmış `parPulses` tut.

**Zorunlu testler:**

1. Tek tren tek edge üzerinde pulse ile hareket eder.
2. Doğru ayarlanmış makas üzerinden geçer; yanlış ayarda hedefe yanlış yönlenir veya bekler.
3. Bir turda iki kontrolü değiştirmek yasaktır; pendingAction değiştirmek ücretsizdir.
4. İki tren aynı boş düğüme gitmeye çalışınca başarısız olur; state kısmen değişmez.
5. Karşılıklı yer değiştiren iki tren (head-on swap) çarpışır.
6. Hedef düğümde bekleyen tren varken giriş çarpışır; hedefe ulaşan tren bir sonraki pulselarda doluluk oluşturmaz.
7. Sinyal kırmızıysa tren bekler, yeşilse ilerleyebilir.
8. `maxPulses` dolunca sonuç fail; undo ile kurtarılabilir.
9. Undo, switch ve sinyalleri de trenlerle birlikte geri getirir.
10. Kayıt kapatılıp açılınca güncel **tam pulse sonrası** state geri yüklenir; yarım animasyon yüklenmez.
11. Her seviye için en az bir **replay edilen bilinen çözüm** vardır.
12. 30 bölümün tamamı JSON/schema validasyondan geçer; hedefi olmayan tren olmaz.
13. Türkçe ve İngilizce metinler taşmadan gösterilir.
14. 16 düğümlü Moskova tahtası küçük ekranda okunabilir; frame drop gözlenirse grafik sadeleştirilir.

---

## 10. Proje takvimi — uygulanabilir öncelik sırası

### İlk 2 gün — fikir doğrulama, sadece motor ve 2 bölüm
- Flutter proje iskeleti, router, tema, CustomPainter statik graph render.
- Saf Dart graph + train + switch + pendingAction + pulse + win/fail + undo.
- ANK-01 ve ANK-02 gerçekten oynanır. Testler başlar.
- İlk demo **görsel olarak kaba olabilir**, ama mekanik net olmalı.

### Gün 3–5 — his ve kontrol testi
- Pulse animasyonu, seçilen makasın okunurluğu, iki trenin eş zamanlı hareketi.
- ANK-03 ... ANK-06; 5–10 dış oyuncuya kontrol anlatmadan denettirme.
- Oyuncular ilk 20–30 saniyede sistemi anlamıyorsa **mekaniği sadeleştir**; içerik üretmeye devam etme.

### Gün 6–10 — Bakü ve bütün oyun kabuğu
- Bakü 6 bölüm, şehir seçimi, level seçimi, ilerleme kaydı.
- 12 toplam seviye; en az bir insan tarafından her biri çözülmüş.
- TR/EN yerelleştirme, gerekli ses/haptic, erişilebilirlik ayarları.

### Gün 11–16 — Paris ve Londra
- Paris 6: signal ve merkezi aktarma; Londra 6: loop. Şehir temaları.
- Level solver/validator sertleştirme; düzenli dış test.
- Toplam 24 oynanabilir seviye hedefi. Kalitesiz düzey varsa sayıyı artırma.

### Gün 17–22 — Moskova ve son cilalama
- Moskova 6 ileri seviye, 30 bölüm hedefi.
- Performans, test, grafik, ses, açıklamalar, ekran görüntüsü çekimi.
- iOS/Android yerel release hazırlığı. Cloud Xcode imzası yapmış gibi davranma.

### Gün 23–30 (varsa) — yayın penceresi
- iPhone üzerinde manual QA, Play Store closed testing veya TestFlight beta.
- Gerçek geri dönüşleri düzeltme; mağaza incelemesi için zaman payı.
- “30 bölüm yetişsin” diye kırık veya kolayca tekrar eden içerik yayınlama.

**Gerçekçi risk:** Tek başına Claude'un kesintisiz kod yazdığı varsayımıyla 30 seviye + 5 şehir + cilalı grafik + mağaza onayını 20 günde **garanti edemezsin**. Asgari yayın adayı: Ankara + Bakü + Paris'ten **12–18 kusursuz bölüm**, özgün grafik, offline kayıt, stabil motor. Londra/Moskova içerikleri bu ana motor hazırsa veri olarak hızla eklenir ama mutlaka test edilir.

---

## 11. Claude Code'un ilk çalıştırmada yapacağı işler

1. Mevcut repo'yu, `git status`, `git remote -v`, `flutter --version`, `dart --version` denetle. Hangi ortamda hangi aracın gerçekten kurulu olduğunu yaz.
2. Repo oyuna ayrılmış değilse **yanlış projeyi değiştirme**. Yeni Flutter projesi ve dokümanlar için güvenli yol öner; yetki varsa uygulamayı kur.
3. Bu belgeyi **aynen** `docs/GAME_DESIGN_V2.md` olarak kopyala, önceki belge ile çakışan kısımları `docs/DECISIONS.md` içinde belirt.
4. `CLAUDE.md` oluştur: Kullanıcıyla Türkçe konuş, dokümanları her oturumda oku, küçük görev seç, çalışan kod üret, `flutter test`/`flutter analyze` sonuçlarını açıkça raporla.
5. `docs/SOURCE_MAPS_AND_LICENSES.md` içinde yukarıdaki resmî URL'leri ve **referans ile ticari yeniden kullanım arasındaki farkı** yaz.
6. `docs/LEVEL_FORMAT.md` içinde JSON şeması, örnek, validator kuralları ve çözüm replay formatını belgele.
7. `docs/ART_DIRECTION.md` içinde 5 şehrin görsel paletini, CustomPainter bileşenlerini, animasyon zamanlarını ve görsel kabul kriterlerini yaz.
8. `TASKS.md` dosyasına tüm işleri `P0 / P1 / P2`, tahmini efor, bağımlılık ve kabul kriteriyle koy. `PROGRESS.md` günlük sonuçları tut.
9. İLK GERÇEK KOD: Graph modeli, `simulatePulse`, collision checker ve ANK-01'i çalışan ekran haline getir. İlk iki seviyenin kontrolü oyun üzerinde yapılabilsin.
10. Testleri çalıştır; geçmeyenleri saklama. Yetkin varsa güvenli `claude/...` branch üzerinde commit/PR oluştur, `main`'e otomatik merge yapma.
11. **Bir sonraki görevi net tanımla.** Her gece oturum aynı dosyaları okuyarak ilerleyebilsin.

### Gece otomasyonu / Cloud gerçekliği

- Kullanıcı gündüz HeirLoam ile çalışacak; bu oyun tamamen ayrı repoda olmalı.
- Claude Code **Cloud scheduled task** özelliği kullanıcı hesabında kullanılabilir ve ayarlanmışsa Mac kapalıyken uzak ortamda çalışabilir; otomatik olarak kendini etkinleştirdiğini varsayma.
- GitHub bağlama, depoya erişim verme, schedule kurma, oturum başlatma işlemleri kullanıcı onayı gerektirebilir. Eksikleri Türkçe, tıklanacak adımlarla açıkla.
- Her gece oturumun işi: `CLAUDE.md`, `TASKS.md`, `PROGRESS.md`, bu V2 ve son commit'leri oku → bir P0/P1 görev tamamla → test et → ilerleme yaz → feature branch/PR hazırla.
- GitHub PR beklerken varsayılan olarak `main` kodunu otomatik merge etme; `pending` işi varsa başka bağımsız göreve geç.
- SDK/Flutter ortamı bulutta kurulu değilse testlerin geçmiş olduğunu söyleme; kurulumu dene ve blokeri belgele.
- Xcode ve Apple signing işlemleri yerel Mac'te yapılır. **Asla Apple Developer hesap erişimi ve mağaza yayını için kullanıcı onayı olmadan işlem yapma.**
- Max plan limitleri ve görev süreleri sınırsız değildir. Bir gecelik çalışmanın 8 saat kesintisiz sürmesi veya bütün oyunun otomatik bitmesi garanti değil.

---

## 12. Yayın kalitesi kontrol listesi

- [ ] İlk 15 saniyede oyuncu treni nasıl hareket ettireceğini (pulse) anlıyor.
- [ ] Yanlış seçim geri alınabiliyor; UI dokunuş hatası oyun kaybettirmiyor.
- [ ] Bütün trenler gözle ayırt ediliyor; renk tek ayıraç değil.
- [ ] Oyuncu 2–5 dakikalık molada ilerleme kaydedebiliyor.
- [ ] Şehir seçimi kullanıcıyı yanlış yönlendirmiyor; kurgusal harita ibaresi var.
- [ ] Kullanılan hiçbir resmî metro haritası, logo veya anons lisanssız kopyalanmıyor.
- [ ] Her şehrin en az bir **bambaşka mantık problemi** var; yalnız zemin resmi değişmiyor.
- [ ] Her oyun levelinin geçerli çözüm yolu replay testinde çalışıyor.
- [ ] Flutter analyze ve test sonuçları gerçekten kaydediliyor.
- [ ] Gerçek cihazda ekran taşması, dokunma gecikmesi, ısı/pil sorunu kontrol edildi.
- [ ] Offline açılış ve offline kayıt sorunsuz.
- [ ] iOS App Store ve Google Play metadata/gizlilik/yaş derecelendirme kontrolleri yapılmış.
- [ ] Geliştirme bitse bile App Store/Play Store incelemesi için süre ayrılmış.

---

## 13. Resmî harita kaynakları — erişim tarihi 05.11.2026

**Bunlar araştırma ve tasarım referanslarıdır; ticari yeniden kullanım izni değildir.** Linkler yayından önce tekrar kontrol edilmelidir.

1. Ankara EGO raylı sistem haritası ve hatlar: https://www.ego.gov.tr/tr/sayfa/1075/rayli
2. Bakü Metropoliteni resmî hat haritası (PDF): https://metro.gov.az/storage/files/file/6683/KQryEyShr7RYJFPIh5slWi55a8BeVmezYd4an3Yq.pdf
3. Bakü Metropoliteni hatların işletimi (28 May/3 hat): https://metro.gov.az/en/page/xetlerimiz/umumi-melumat
4. Paris RATP resmî metro haritası ve planlar: https://www.ratp.fr/en/plan-metro ve https://www.ratp.fr/en/plans
5. Londra Transport for London resmî Tube map (Mart 2026): https://content.tfl.gov.uk/standard-tube-map.pdf
6. Londra TfL ticari map licensing: https://tfl.gov.uk/info-for/business-and-advertisers/map-licensing
7. Moskova resmî metro + MCC + MCD haritası: https://transport.mos.ru/metro/map
8. Berlin BVG ağı: https://www.bvg.de/en/connections/network-maps-and-routes
9. Tokyo Metro PDF ve hatlar: https://www.tokyometro.jp/en/subwaymap/index.html
10. OpenStreetMap telif/ODbL açıklaması: https://www.openstreetmap.org/copyright
11. OSM lisans SSS, oyunlar: https://osmfoundation.org/wiki/Licence_and_Legal_FAQ

**Gerçek harita verisini kullanma kararı** verilirse kaynak başına izin/lisans incelemesi yap; lisans belirsizse sadece gerçek dünya bağlantı örüntülerinden ilham alarak **bağımsız kurgu** üret. Oyun içindeki harita “gerçek zamanlı/gerçek güzergâh bilgisi” diye sunulmayacak.

---

## 14. İlk Claude Code oturumu için başlangıç komutu

> **Bu bölüm kopyalanıp Claude Code'a direkt verilebilir.**

**Görev:** Bu mesajla birlikte sağlanan `SwipeOut_Last_Train_Game_Design_V2_Claude.md` belgesini oku. Belgede belirlenen `NIGHT PULSE` kuralını, beş şehirli zorluk sırasını, özgün metro haritalarını ve kalite sınırlarını **tek doğru ürün tanımı** olarak uygula. Varsa eski SwipeOut master promptundaki “oyuncu treni tek tek swipe ile sürer” mekaniğini **değiştir**: artık trenler kendi kendine, `1 DAKİKA İLERLET` eylemiyle **aynı anda** ilerliyor. Her pulse öncesinde oyuncu en fazla **bir switch veya signal** değiştirebilir. Türkçe konuş. Önce repo ve araçları incele; ardından `docs/GAME_DESIGN_V2.md`, `CLAUDE.md`, `TASKS.md`, `PROGRESS.md`, `docs/LEVEL_FORMAT.md`, `docs/ART_DIRECTION.md`, `docs/SOURCE_MAPS_AND_LICENSES.md` dosyalarını oluştur. Flutter uygulamasında `simulatePulse` motorunu, undo'yu, çarpışma kurallarını, ANK-01 oynanabilir grafiğini ve bir unit testini gerçekten geliştir. Yaptığın her işi test sonuçlarıyla bildir, eksikleri saklama. HeirLoam'a dokunma. Kullanıcıdan onay almadan mağazaya yayınlama, ücretli servis açma veya `main`'e otomatik merge yapma.

---

**Başarı tanımı:** Kullanıcı treni her saniye elle sürmek zorunda kalmadan, tek bir makas kararının birden fazla trenin rotasını etkilediği **anlaşılır, tatmin edici, özgün çizimli bir metro oyunu** oynayabilmeli. Başlangıçta Ankara'da rahat öğrenmeli; finalde Moskova'da “Bu dört treni 9 pulse içinde nasıl kurtaracağım?” diye gerçekten düşünmeli.
