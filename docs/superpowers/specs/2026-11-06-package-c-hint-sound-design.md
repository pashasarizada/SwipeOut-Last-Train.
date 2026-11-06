# Paket C — İpucu, Ses, Teslim Kutlaması — Tasarım

**Tarih:** 06.11.2026 · **Durum:** kullanıcı onayladı ("Evet, C'ye geç")
**Bağlam:** `2026-11-06-board-readability-design.md` (Paket A+B) · `docs/UI_UX_GUIDELINES.md` §9 · `docs/GAME_DESIGN_V2.md` "Küçük dokunuşlar"

## Neden

Mağaza yorumları araştırmasından iki ders çıktı:

- **İpucu yoksa oyuncu takılır ve oyunu bırakır** (Railbound Android yorumları).
- **İpucu parayla satılırsa oyuncu kızar** (Hitman GO).

Bunun yanında oyunun henüz hiç sesi yok. Teslim anı da küçük bir titreşim dışında kutlanmıyor.

## Hedefler

1. **İpucu düğmesi.** Oyuncu düğmeye basınca bir sonraki doğru hamle gösterilir: çizilmiş el o makası, sinyali ya da kolu gösterir.
   - Ücretsizdir ve sınırsızdır.
   - Tek bedeli: o koşuda ipucu kullanılırsa en fazla 2 yıldız alınır.
2. **Ses efektleri.** Hepsi özgün ve sentetik (kendimiz üretiyoruz):
   - makas/sinyal "klak";
   - dakika "tık";
   - teslim "çan";
   - çarpışma "bzzt";
   - bölüm bitti "fanfar";
   - damga "küt".
3. **Ses ayarı.** Ayarlar ekranına bir ses anahtarı eklenir, varsayılanı açık. Ses kapalıyken de oyun tam anlaşılır.
4. **Teslim kutlaması.** Tren hedefine girince, o trenin renginde kısa bir parçacık patlaması çıkar. Aynı dakikada iki ya da daha fazla tren teslim edilirse kutlama daha büyük olur.

## Hedef dışı

- Günün bulmacası ve ek görevler (sonraya kalıyor).
- Müzik.
- Şehre özel sesler.

## Kaçınılacaklar

- Ücretli ipucu, günlük ipucu sınırı, reklam izleyerek ipucu almak.
- Çözümün tamamını göstermek. İpucu yalnız **bir** hamle gösterir.
- Resmî metro anonslarını, kayıtlarını ya da lisansı belirsiz ses dosyalarını kullanmak.
- Telefonun sessiz düğmesini ezen ya da kullanıcının çaldığı müziği kesen ses.
- Ses kapalıyken çalışmayan bir oyun.

## Nasıl (kararlar — Claude'un kararı)

### İpucu

**Hamleyi bulma:** Saf Dart bir `HintFinder` hamleyi şu sırayla arar:
1. Koşu, bölümün kayıtlı çözümünün başlangıcıyla aynıysa, kayıtlı çözümdeki sıradaki hamle verilir.
2. Değilse çözücü (`PulseSolver`, 200 bin durum sınırı) şimdiki durumdan çalıştırılır ve planının ilk hamlesi verilir.
3. Çözücü bir çözüm bulamazsa, ya da çözülemez veya sınıra takıldı derse, cevap **Geri Al** olur.

Çözücü `Isolate.run` ile arka planda çalışır, böylece oyun ekranı takılmaz. Sonuç gelene kadar ipucu düğmesi "düşünüyor" durumunda kalır.

**Gösterme:** `TutorialHand` yeniden kullanılır.
- Hedef bir kontrolse el o düğümü gösterir.
- Hedef bekleme ise el kolu gösterir.
- Hedef Geri Al ise el Geri Al düğmesini gösterir.
- Oyuncu bir hamle yapınca (dakika ilerletir ya da seçimi değiştirir) ipucu kaybolur.

**Bedel:** `PulseController.hintUsed`, o koşu boyunca bir kez kullanılınca açık kalır. Bölüm kazanılırsa sonuç en fazla gümüş olur.
- Geri Al bu bedeli kaldırmaz; Baştan kaldırır.
- `ProgressStore` en iyi sonucu zaten saklıyor, bu yüzden daha önce kazanılmış bir altın yıldız kaybolmaz.

**Yer:** Geri Al | İpucu | Baştan, üç küçük düğme tek satırda.
- İpucu öğretici bölümlerde görünmez, çünkü orada el zaten var.
- İkon olarak yeni, çizilmiş bir `GameIconKind.bulb` kullanılır.

**Kayıt:** Yarım kalan koşu kaydedilirken ipucu bilgisi saklanmaz. Uygulama kapatılıp açılırsa bedel düşer. Bu bilerek kabul edildi: basitlik için ve offline, tek oyunculu bir oyun olduğu için.

### Ses

**Paket:** `audioplayers` (MIT lisanslı, iOS ve Android destekli). `docs/DECISIONS.md`'ye D-032 olarak yazılır.
- iOS ses kategorisi `ambient` olur: sessiz düğmesine uyar, kullanıcının müziğiyle karışır, onu kesmez.

**Ses dosyaları:** `tool/make_sounds.py` ile saf Python (`wave` modülü) kullanılarak sentezlenir.
- Kısa WAV dosyaları, 22 kHz mono, her biri 0,3 saniyeden kısa, fanfar en fazla 0,9 saniye.
- Yer: `assets/sounds/`.
- Lisans: kendi üretimimiz, `SOURCE_MAPS_AND_LICENSES.md`'ye yazılır.

**Mimari:**
- `SoundCue` enum'u: `switchClack`, `pulseTick`, `delivery`, `crash`, `levelWon`, `stamp`.
- Soyut bir `GameSounds` arabirimi: `play(SoundCue)`.
- İki gerçekleme:
  - `AudioGameSounds`: oyuncu havuzu kullanır, aynı ses üst üste çalabilir.
  - `SilentGameSounds`: testler için.
- Sesler `GameHaptics` ile aynı kapıdan çalar: yeni `GameFeedback`, ayar kapalıysa susar. Oyundaki her ses, aynı yerdeki titreşimin yanında tetiklenir.

**Ayar:** `GameSettings.sound`, varsayılanı `true`.
- Ayarlar ekranında yeni bir `SignalToggle` satırı.
- Yeni ARB anahtarı `sound`: TR "Ses", EN "Sound".

### Teslim kutlaması

- `BoardView` içinde yeni bir `CelebrationPainter`, 600 ms sürer.
- `PulseCommitted.delivered` içindeki her tren için, hedef istasyonunda o trenin renginde 10 parçacık dışarı saçılır.
- Aynı dakikada 2 ya da daha fazla teslim varsa parçacık sayısı iki katına çıkar, ayrıca beyaz bir halka dalgası ve daha uzun bir çan sesi (`delivery` sesi iki kez, 90 ms arayla) eklenir.
- Reduced Motion açıksa yalnız kısa bir halka çizilir, parçacık olmaz.

## Testler

- **`HintFinder`:**
  - koşu kayıtlı çözümün başındaysa kayıtlı hamleyi veriyor;
  - çözümden sapılmış ama hâlâ çözülebilir bir durumda çözücünün hamlesini veriyor;
  - çözümsüz bir durumda Geri Al veriyor;
  - verdiği hamle uygulandıktan sonra durum hâlâ çözülebilir kalıyor (birkaç bölümde).
- **Controller:**
  - ipucu kullanılınca kazanılan yıldız en fazla gümüş;
  - Baştan bedeli sıfırlıyor, Geri Al sıfırlamıyor.
- **Ekran:**
  - öğretici bölümlerde ipucu düğmesi yok;
  - basınca el bir hedefi gösteriyor;
  - ilk hamlede el kayboluyor.
- **Ses:** sahte bir `GameSounds` ile:
  - makasa dokununca `switchClack`, dakika ilerleyince `pulseTick`, teslimde `delivery`, çarpışmada `crash` çalıyor;
  - ses ayarı kapalıyken hiçbiri çalmıyor.
- **Ayarlar:** ses anahtarı kaydediliyor.
- **Kutlama:** teslimden sonra `CelebrationPainter` çiziliyor; Reduced Motion açıkken parçacık yok.
- **Mevcut kapılar:** `level_layout_test` (44 pt, 320×568 dahil) ve `ui_rules_test` geçmeye devam ediyor.
