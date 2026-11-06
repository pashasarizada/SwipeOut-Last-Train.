# Metro Haritası Görünümü — Tasarım

**Tarih:** 06.11.2026 · **Durum:** kullanıcı onayladı ("Evet, başla"), uygulandı — D-036
**Kullanıcı isteği:** "metro hatlarını gerçek metroların hatlarına benzetecektik" → seçim: **Metro haritası görünümü** (bölüm topolojisi değişmez).
**Bağlam:** `docs/GAME_DESIGN_V2.md` §5 (gerçek haritadan *esinlenen* özgün dünya) · `docs/UI_UX_GUIDELINES.md` · D-030 (makas yönü yazısız) · D-034 (High Contrast) · `docs/SOURCE_MAPS_AND_LICENSES.md`

## Neden

Tahta bugün soyut bir graf gibi görünüyor: gri çizgiler, rastgele açılar, isimsiz noktalar. Oyuncu bunun bir metro ağı olduğunu, şehir temasından başka bir yerden anlamıyor. Metro haritalarının herkesin tanıdığı dili var:
- kalın renkli hatlar;
- yalnız yatay, dikey ve 45° çizgiler ve yumuşak dönüşler;
- durak çentikleri;
- uç istasyonların isimleri.

Bu dil oyunun "metro bulmacası" kimliğini ilk bakışta verir.

## Hedefler

1. **Renkli hatlar.**
   - Raylar hatlara ayrılır, her hat kendi renginde kalın bir şerit olarak çizilir.
   - Şeridin çevresinde koyu bir kenar olur, böylece kesişmeler okunur.
2. **Metro açıları.** Her ray parçası yalnız 0°, 45° ve 90° doğrularından oluşur, dönüşleri yuvarlaktır. Düğümlerin yeri değişmez; değişen, iki düğüm arasındaki çizginin şeklidir.
3. **Durak dili.**
   - Ara duraklar (`track`) hattın yanında kısa bir çentik olarak çizilir.
   - Depolar, hat renginde "son durak" işaretiyle çizilir.
   - Makaslar ve sinyaller oynanan kontroller olduğu için bugünkü görünür hâlinde kalır.
4. **İstasyon isimleri.** Yalnız **hedef** istasyonların (trenlerin gideceği son durakların) yanında küçük bir isim etiketi durur. İsimler o şehrin gerçek istasyon ya da semt adlarıdır ve yalnız tema içindir; güzergâh iddiası taşımaz.
5. **Trenler ve oklar şekli izler.** Tren, yeni çizilen yolun üstünde ilerler ve yönünü yola göre çevirir. Önizleme okları (D-030) da aynı yolu izler.

## Hedef dışı

- Bölümlerin ağ yapısını (düğümler, raylar, çözümler) değiştirmek. 30 bölümün mantığı ve testleri olduğu gibi kalır.
- Şehir haritası ekranının (bölüm seçimi) yeniden çizimi. Bu iş sonraya kalır.
- Hat isimleri ve numaraları ("M1", "Kırmızı hat"), hat lejantı.
- Kiril yazı. Moskova isimleri Latin harfleriyle yazılır.

## Kaçınılacaklar (yasal ve okunurluk)

- **Resmî hat renk düzenleri** (ör. Londra'da Circle için sarı, Moskova'da halka için kahverengi), resmî haritanın düzeni, logolar, resmî fontlar. Renkler şehir paletinden bizim seçimimiz olur.
- **Tren renkleriyle karışan hat rengi.** Trenler mercan, mavi, yeşil ve kehribar renginde; hedefler de trenin renginde. "Yeşil hat mavi trenin hedefine gidiyor" yanılgısı oyunu bozar. Bu yüzden hat renkleri bu tonlardan ve önizleme turkuazından açıkça ayrılır: mor, pembe, kum ve çelik gibi tonlar.
- **Makasın ya da sinyalin bir isim etiketinin veya çentiğin altında kalması.** Dokunma hedefleri (44 pt) değişmez.
- **Kalabalık.** Ara duraklara ve makaslara isim yazılmaz.

## Nasıl (kararlar — Claude'un kararı)

### Hatları ayırma (otomatik)

JSON'a hat bilgisi eklenmez; hatlar ağdan otomatik çıkarılır, saf Dart ile ve `presentation/board` altında:
- İki rayı olan düğümde (ara durak, sinyal) iki ray aynı hattır.
- Makasta ana gövde (`trunkEdge`), yönü en az kırılan dala devam eder. Öteki dal yeni bir hat başlatır.
- Renkler şehrin hat paletinden açgözlü boyamayla (greedy) dağıtılır: her hat, kendisiyle bir düğümde buluşan hatların kullanmadığı ilk rengi alır. Böylece aynı düğümde buluşan iki hat aynı rengi almaz. 30 bölümün hepsi 3 renkle boyanabiliyor (okuyucu kontrolünde 2–9 hatla doğrulandı); boyanamayan durumda test kırılır.

### Şehir hat paleti

`CityTheme` yeni bir alan alır: `lines`, 3 renk.
- Her renk arka plana karşı en az 3:1 kontrastta olur (test edilir).
- Doygunluğu 0,35 ve üstünde olan renk, tren tonlarından, sinyal yeşilinden ve önizleme turkuazından renk tonu olarak en az 30° uzak durur (test edilir). Bu kural yalnız mor–eflatun (~250–330°) ve sarımsı yeşil (~70–110°) bantlarını bırakır.
- Doygunluğu 0,35'in altında olan renk (taş, kum, çelik grisi) ton kuralından muaftır; renkli bir tren tonu gibi okunmaz.
- Bu yüzden her şehrin paleti iki renkli hat (mor–eflatun bandından, şehre göre farklı) ve bir sönük şehir tonundan oluşur (ör. Bakü kum grisi, Londra taş grisi, Moskova buz grisi). Şehrin kendi rengi, sönük tonda ve arka plandaki çizimlerde yaşar.
- Kesin renkleri Claude seçer ve yanlarına "resmî düzen değil" notunu yazar.

### Metro açılı çizim

Her ray için üç aday şekil hesaplanır:
1. düz – çapraz – düz (simetrik);
2. önce çapraz, sonra düz;
3. önce düz, sonra çapraz.

Zaten 0°, 45° ya da 90° olan raylar düz kalır. İlk uyan aday seçilir. Bir aday şu durumlarda reddedilir:
- iki ucundan biri, aynı düğümdeki başka bir rayla aynı yönde çıkıyorsa (makasta dallar üst üste binmesin);
- ya da başka bir düğüme 20 pt'den fazla yaklaşıyorsa.

Hiçbiri uymazsa ray bugünkü gibi düz bir çizgi olarak kalır. Dönüşler 14 pt yarıçapla yuvarlanır.

**Düğümler taşınmaz** (Claude'un kararı). Bu yüzden bazı raylar düz yedeğe düşebilir. Bu kabul edilir: bir bölümde rayların %25'inden fazlası düze düşerse sonuç raporunda belirtilir, ama düğüm taşımak ayrı ve sonraki bir iştir.

Bu yol tek bir yerde hesaplanır (yeni `RailGeometry`: bölüm + yerleşim → her ray için yol). Raylar, trenler, oklar ve kapalı kolun boşluğu bu yolu ortak kullanır. Böylece çizgi ile hareket ayrışamaz; bu, D-030'daki "önizleme = gerçek" ilkesinin görsel karşılığıdır.

### Çizim

**Ray:** Önce koyu kenar çizilir (arka plan rengi, genişlik +4), sonra hat rengi (6 pt).

**Kapalı makas kolu (D-030):** Hat renginde, %35 opak ve 4 pt çizilir. Makastan 30 pt önce kesilir; kesim yol boyunca ölçülür.

**Dakika dalgası:** Bugünkü gibi hat rengi açılır.

**Seçili makasın yeni kolu:** Turkuaz parıltı, bu kez yol boyunca çizilir.

**Durak işaretleri:**
- Ara durak: yola dik kısa bir çentik (hat renginde, 10×4 pt).
- Depo: hat renginde yuvarlatılmış, içi dolu bir "uç" işareti. Bugünkü kare çerçeve yerine geçer; boyutu aynı kalır, trenin altında da okunur.
- Çıkmaz uç (`terminal`): yola dik, hat renginde kalın bir tampon çizgisi (14×5 pt).
- Hedef, makas ve sinyal: bugünkü gibi.

**High Contrast (D-034):**
- Raylar hat rengini bırakıp bugünkü beyaz ve kalın çizime döner. Metro açılı yol kalır.
- İsimler beyaz olur ve arkalarına koyu bir zemin gelir.

### İstasyon isimleri

**Neden yalnız hedefler:** `GAME_DESIGN_V2.md` isimlerin yalnız "seçili ya da kritik" istasyonlarda görünmesini istiyor ki Moskova tahtaları küçük ekranda okunur kalsın. Hedefler bölümün kritik noktalarıdır: trenin gideceği son durak, tıpkı vagon tabelasındaki varış istasyonu gibi. Bu karar o kuralla uyumludur; kuralın değişmesi gerekmez.

**Veri:** Var olan `Node.label` alanı JSON'da doldurulur, yalnız hedef düğümlerde (bölüm başına tren sayısı kadar, toplam ~80 isim).
- Her şehir o şehrin gerçek istasyon ve semt adlarını kullanır: Ankara'da Kızılay, Batıkent, Çayyolu…; Bakü'de 28 May, İçərişəhər, Nərimanov…; Paris'te Châtelet, Bastille…; Londra'da Paddington, Angel…; Moskova'da Arbatskaya, Sokolniki…
- Bir bölüm içinde isimler tekrar etmez.
- Bölümün başlığı bir istasyon adı içeriyorsa ("28 May", "Châtelet Kavşağı"), o isim o bölümün merkezine en yakın uçta kullanılır.

**Çizim:**
- Board fontunda (IBM Plex Mono), 11 pt, şehrin `textSecondary` tonunda yazılır.
- Etiket için düğümün çevresinde 8 aday yer denenir. Board'un içinde kalan ve şunlarla çakışmayan ilk yer seçilir: başka bir düğüm, ray, başka bir etiket, sinyal lambası (`signalLampOffset`), bekliyor rozeti, hedef parıltısı (yarıçap 29) ve bir düğümün çarpı işaretinin yeri (`crossShift`).
- Hiçbiri uymazsa etiket çizilmez; oyun ona bağlı değildir.

**Erişilebilirlik:** Ekran okuyucu için tahtanın semantik açıklamasına isim eklenmez; bugünkü kontrol etiketleri kalır.

**Yazım:** İsimler özel addır, iki dilde aynı yazılır ve şehrin kendi yazımıyla girilir (İçərişəhər, Châtelet). Moskova için Latin harfli yazım kullanılır (Arbatskaya). `Node.label` yerelleştirilmez; bölüm başlıklarında olduğu gibi bölüm verisinin parçasıdır.

**Lisans:** İstasyon adları bilgi olarak kullanılır (tasarım belgesi §5'in izin verdiği "tematik referans"). `SOURCE_MAPS_AND_LICENSES.md`'ye bir not düşülür.

### Mimari

`domain` ve `engine` değişmez. Yeni dosyalar `presentation/board` altında:
- `rail_geometry.dart`: aday şekiller, seçim, yol üstünde bir noktanın konumu ve yönü;
- `metro_lines.dart`: hatlara ayırma ve renk dağıtma;
- `station_labels.dart`: etiket yerleştirme.

`NetworkPainter`, `ForecastPainter` ve `TrainLayer` düz çizgi yerine `RailGeometry`'yi kullanır. Her dosya ~200 satırın altında kalır.

## Testler

**Geometri (30 bölümün hepsinde, 390×844, 375×667 ve 320×568 ekranlarda):**
- Her yol parçası 0°, 45° ya da 90° açıda (ya da kayıtlı "düz yedek" listesinde).
- Yollar düğümlerde tam başlayıp bitiyor.
- Bir düğümden çıkan iki ray aynı yönde çıkmıyor.
- Hiçbir yol başka bir düğüme 20 pt'den fazla yaklaşmıyor.
- Yedeğe düşen ray sayısı raporlanıyor ve test bir üst sınırla bunu sabitliyor.

**Hareket:** Trenin `t` anındaki konumu yolun üstünde; yönü yolun teğetiyle aynı. Kapalı kolun boşluğu yol boyunca 30 pt.

**Hatlar:**
- Makasta ana gövde en düz dala gidiyor.
- Bir düğümde buluşan iki hat farklı renkte.
- Paletin kontrast ve renk tonu kuralları sağlanıyor.

**Etiketler:**
- 30 bölümde hedeflerin hepsinin ismi var.
- Bir bölüm içinde isimler tekrar etmiyor.
- Yerleşen etiketler board içinde ve düğümlerle ya da birbirleriyle çakışmıyor.
- 390×844'te etiketlerin en az %90'ı yerleşiyor.

**Mevcut kapılar:** `level_layout_test` (44 pt), `ui_rules_test`, `level_assets_test`, forecast testleri ve High Contrast testleri geçmeye devam ediyor.

**Simülatör:** Her şehirden bir bölümün ekran görüntüsü (Bakü 02 ve Moskova 06 dahil) ve bir High Contrast görüntüsü alınır, `docs/images/v2-ux/19+` olarak kaydedilir.

## Builder'a kalanlar

- Kenar ve çentik ölçüleri, yuvarlatma yarıçapının ince ayarı.
- Paletteki kesin renk kodları (yukarıdaki kurallar içinde).
- Etiketin 8 aday yerinin sırası.
- Yol hesabının önbelleklenmesi (bölüm + yerleşim anahtarıyla).
