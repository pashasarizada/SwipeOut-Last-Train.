# Tahta Okunurluğu (Paket A + B) — Tasarım

**Tarih:** 06.11.2026 · **Durum:** onay bekliyor · **Bağlam:** `docs/GAME_DESIGN_V2.md` §3.2, `docs/UI_UX_GUIDELINES.md`

## Neden

Simülatörde oynarken gözlenenler:

- Makasın hangi kola açık olduğu neredeyse görünmüyor. Kapalı kol, açık koldan yalnızca biraz daha koyu.
- Hayalet halkalar soluk. Çarpışma olacağı zaman hiç çizilmiyorlar, yani uyarı vermeleri gereken anda kayboluyorlar.
- Kola basıp çarpışma olduğunda tahta "hiçbir şey olmadı" gibi görünüyor.
- Ekranda oyuncunun bilmediği jargon var: "PULSE", "Kontrol 1/1", "Makas M". Kurallar tahtanın üstünde iki satır yazıyla anlatılıyor.

Mağaza yorumları araştırmasından (Railbound, Mini Metro, Into the Breach, Hitman GO, Two Dots…) çıkan ders: oyuncular, **ne olacağını olmadan önce gördükleri** ve kaybedince "hata bendeydi" diyebildikleri oyunları seviyor.

**Amaç:** Oyuncu kola basmadan önce, yazı okumadan şunları bir bakışta görsün:
- hangi trenin gideceğini, nereye gideceğini;
- hangi trenin kalacağını;
- çarpışma olup olmayacağını.

## Hedefler

1. Makasın açık kolu açıkça belli olsun.
2. Hareket edecek her trenin, bir sonraki durağına uzanan kendi renginde bir ok çizilsin. Kalacak trenlerin üstünde bir "bekliyor" işareti olsun.
3. Bir sonraki dakika başarısız olacaksa bu, kola basmadan önce tahtada ve kolda görünsün.
4. Bir sonraki dakikada hedefine girecek trenin istasyonu parlasın.
5. Üst bilgide yazı yerine simgeler kullanılsın: tren jetonları ve hamle noktaları, yıldız sınırları işaretli.
6. Kural yazısı tahtadan kalksın. Öğretici bölümlerde (ANK-01/02) çizilmiş bir el ne yapılacağını göstersin.
7. "Makas M" bileti kalksın. Seçili kontrol tahtada zaten parlıyor; iptal için kontrole tekrar dokunmak yetiyor.

## Hedef dışı

- İpucu düğmesi, ses, günün bulmacası, ek görevler. Bunlar Paket C.
- Oyun kuralı, bölüm veya `par`/`max` değişikliği.

## Kaçınılacaklar (yapılırsa başarısızlık sayılır)

- Bir dakikadan fazlasını göstermek. Önizleme yalnız **bir sonraki dakika** için olur (V2 §3.2/5). Çözüm asla gösterilmez.
- Tahtaya yeni açıklama yazısı eklemek.
- Material bileşen veya emoji kullanmak.
- Yalnız renge dayanan uyarı. Çarpışma işaretinin hem rengi hem şekli olmalı (çarpı), çünkü renk körü oyuncular da var.
- 44 pt dokunma kuralını bozmak (D-029, `level_layout_test`).

## Nasıl

### Motor — saf Dart, `engine` katmanı

Yeni `PulseEngine.forecast(GameState, ControlAction?) → PulseForecast` eklenir. Bu, mevcut `simulatePulse` ile aynı hesabı yapar, ama başarısız dakikada da her trenin **niyetini** döndürür.

- **`PulseForecast`** (domain, `final class`):
  - `moves`: her aktif tren için `TrainMove`.
  - `conflict`: `PulseFailed?`. Mevcut `_conflict` mantığı yeniden kullanılır; ayrı bir kopya yazılmaz (DRY).
  - `delivers`: bu dakika hedefine girecek tren id'leri, yalnız `conflict == null` ise.
- **`TrainMove`**: `trainId`, `from`, `to` (`null` = kalıyor).
- `simulatePulse` içeride aynı niyet hesabını kullanır, böylece iki yol ayrışamaz. Testlerle sabitlenir: `forecast` ve `simulatePulse` her zaman aynı sonucu verir.
- `GameSession.forecast(action)` motoru sarar.
- `PulseController.forecast` mevcut `ghost`'un yerini alır. Kurallar aynı kalır: animasyon sırasında ya da oyun bitmişken `null` döner.

### Tahta — `presentation/board`, yalnız `CustomPainter`

**A1 · Makas yönü** (`NetworkPainter`)
- Açık kol tam parlak ray rengiyle çizilir.
- Kapalı kol hem soluk çizilir hem de makas merkezinden ~14 pt önce **kesilir**. Bu boşluk, raylar arasında gerçek bir açıklık gibi görünür.
- Bekleyen bir makas seçimi varsa açılacak kol turkuaz (mevcut davranış), kapanacak kol kesik çizilir. Önizleme, kola basınca olacak durumu gösterir.

**A2 · Hareket okları** (yeni `ForecastPainter`, `GhostPainter`'ın yerine)
- Hareket eden her tren için, kendi renginde, kenarın %30'undan %85'ine kadar uzanan kalın bir ok çizilir. Ok ucu `to` düğümünü gösterir.
- Reduced Motion kapalıyken okun içinde ileri akan noktalar olur. Bunları yeni `_idle` controller çalıştırır (aşağıdaki karar 1).
- Kalacak trenlerin yanında, trenin sağ üstünde, iki dikey çubuklu küçük gri bir **"bekliyor" rozeti** çizilir. Yazı kullanılmaz.

**A3 · Çarpışma önizlemesi**
- `conflict` varsa:
  - ilgili trenlerin okları kırmızıya döner;
  - çarpışma düğümüne kırmızı, nabız gibi atan bir **çarpı** çizilir (`GameIcon` cross yeniden kullanılır).
- Kol (`AdvanceLever`) yeni bir `warning` durumuna geçer: rengi uyarı rengine döner, saat simgesinin yerine çarpı gelir.
- Kol **basılabilir kalır**. Basılırsa mevcut sarsıntı ve anons çalışır. Oyuncunun denemesi engellenmez, sadece önceden uyarılır.

**A4 · Teslim parıltısı**
- `delivers` içindeki trenin hedef istasyonunun çevresinde, o trenin renginde parlayan bir halka belirir.

### Platform — `presentation/widgets`

**B5 · Üst bilgi** (`PulseHud`)
- Kalkış tabelası iki satıra iner:
  - `BAKÜ 02 · 28 May`;
  - saat `23:51`.
- Tabelanın altına yeni bir `RunMeter` widget'ı gelir:
  - **Solda tren jetonları:** her tren için kendi renk ve simgesinde küçük bir vagon. Teslim edilince dolu, edilmemişse içi boş çizilir.
  - **Sağda hamle noktaları:** her nokta bir dakika ve toplam `maxPulses` kadar nokta var. Kullanılanlar dolu çizilir. `par` ve `par+2`'den sonra küçük çizilmiş yıldız ayraçları gelir, böylece "bu noktayı geçersem yıldız düşer" görünür.
  - Sığmazsa (`maxPulses` > 16 ya da kompakt ekran) noktalar yerine tek bir dolan çubuk ve aynı yıldız ayraçları gösterilir.
- Erişilebilirlik: `RunMeter`'ın `Semantics` etiketi mevcut ARB metinlerinden gelir (`pulseCounter`, `trainsDelivered`). Ekran okuyucu bilgiyi kaybetmez.
- "Kontrol 1/1" satırı kalkar. Ekranda yer almayan ARB anahtarları silinir.

**B6 · Kural yazısı ve öğretici el**
- `tutorialSteps` metni tahtadan kalkar. Bölüm açılınca mevcut `PlatformAnnouncement` ile tahtanın üstünde gösterilir. Oyuncunun ilk dokunuşunda ya da 4 sn sonra kaybolur.
- **Öğretici bölümlerde** (`level.tutorial == true`) çizilmiş bir **el** (`CustomPainter`, emoji yok) ne yapılacağını gösterir:
  - El, kayıtlı `solution` dizisini izler.
  - Sıradaki adım bir kontrolse el o düğüme dokunur gibi hareket eder. Kontrol seçildiyse ya da adım "bekle" ise kolu gösterir.
  - Oyuncu çözümden saparsa el, düzeltmek için dokunması gereken yeri gösterir (aşağıdaki karar 5).
- Reduced Motion açıkken el hareketsiz durur.

**B7 · Bilet**
- `ControlTicket` oyun ekranından kalkar. Kazanılan yükseklik tahtaya verilir.
- Kit bileşeni kit testlerinde kalır.

### Kararlar

`docs/DECISIONS.md`'ye iki karar yazılır:
- **D-030:** Bir sonraki dakika için tahminin ve çarpışmanın gösterilmesi. Hâlâ yalnız bir dakika ileri, V2 §3.2/5 ile uyumlu.
- **D-031:** Üst bilgide yazı yerine simgeler; kural yazısının tahtadan kalkması; öğretici el.

### Testler (TDD)

- **Motor:**
  - `forecast` hareket, bekleme (kırmızı sinyal, çıkmaz, pasif kol) ve dört çatışma türünü doğru bildiriyor.
  - Her bölümün kayıtlı çözümünün her adımında `forecast.conflict == null` ve `forecast` ile `simulatePulse` aynı durumu veriyor.
- **Controller:**
  - Animasyon sırasında ve bitmiş oyunda `forecast` boş.
  - Bekleyen kontrol değişince `forecast` da değişiyor.
- **Tahta:**
  - `ForecastPainter` doğru `forecast`'u alıyor.
  - Çarpışmada kol `warning` durumunda.
- **HUD:**
  - Ekranda "PULSE" ya da "Kontrol" metni yok.
  - Jeton ve nokta sayıları doğru, `Semantics` etiketi var.
- **Öğretici:**
  - ANK-01/02'de el doğru hedefi gösteriyor.
  - Sapınca seçili düğümü ya da Geri Al'ı gösteriyor.
- **Mevcut kapılar:** `level_layout_test` (44 pt) ve `ui_rules_test` geçmeye devam ediyor.
- **Görsel kontrol:** her parça iPhone 16e simülatöründe ekran görüntüsüyle doğrulanır, görüntüler `docs/images/v2-ux/`'e eklenir.

## Okuyucu kontrolünden sonra verilen kararlar (Claude'un kararı)

Bu kararları bağımsız okuyucunun sorularına göre ben verdim, kullanıcıya sorulmadı.

1. **Bekleme animasyonu.** `wave`, yalnız bir dakika oynarken çalışıyor. Bu yüzden tahtaya yeni bir `_idle` `AnimationController` eklenir. Bu controller:
   - 1,6 sn'lik bir döngüyle tekrar eder;
   - yalnız tahta boştayken, `forecast` varken ve Reduced Motion kapalıyken çalışır;
   - uygulama arka plandayken durur.

   Okların içindeki akan noktalar, çarpışma çarpısının nabzı ve öğretici el bu controller'ı kullanır. `pumpAndSettle` kullanan testler, `CityBackdrop` testlerinde olduğu gibi `MotionSettings(reduced: true)` ile sarılır.
2. **Kural yazısı.**
   - `PlatformAnnouncement`'a nötr bir `info` tonu eklenir: kırmızı kenar, korna simgesi ve sarsıntı olmadan.
   - İki satır tek mesajda birleşir.
   - Kalkış tabelasına dokununca mesaj yeniden gösterilir.
   - Çarpışma anonsu kural mesajının yerine geçer, çünkü daha önemlidir.
3. **Ekran okuyucu.**
   - Kolun `Semantics` etiketi şunları söyler: "1 dakika ilerlet", seçili kontrol (`pendingLabel`) ve varsa uyarı (yeni `forecastWarning` anahtarı).
   - `pendingLabel` ve `cancel` anahtarları **silinmez**.
   - Tahtanın kendi `Semantics` desteği zaten yoktu. Bu, bu paketin dışında bir eksik olarak kaydedilir.
4. **Jargon.** Bu pakette oyuncunun gördüğü veya duyduğu bütün "pulse" metinleri "dakika" olur (TR: "{current}/{max} DAKİKA", "{count} dakika"; EN: "MIN", "{count} min"). ARB'deki anahtar adları değişmez.
5. **Öğretici el.**
   - Seçili kontrol çözümdeki sıradaki adım değilse el o düğümü gösterir. Ona tekrar dokununca seçim iptal olur.
   - Yapılmış bir dakika çözümden saptıysa el Geri Al düğmesini gösterir.
   - Böylece el hiç kaybolmaz; her zaman bir sonraki doğru dokunuşu gösterir.

## Uygulayıcıya bırakılanlar

Okun kalınlığı, rozet ve el çizim ayrıntıları, animasyon süreleri, renk tonları. Hepsi `AppColors` ve `motion.dart` içinde, mevcut tarzda olacak.
