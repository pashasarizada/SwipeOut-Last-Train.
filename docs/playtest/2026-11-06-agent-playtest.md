# Oyun Testi — Last Train (2026-11-06, AI ajan)

Cihaz: iOS Simulator, iPhone 16 (393×852). Kurulum: sıfır ilerlemeyle temiz kurulum. Dil: Türkçe (sonra kısa süre İngilizce denendi).
Oynama biçimi: Yalnızca ekrana dokunarak, oyuncu gibi. Kaynak kod, bölüm dosyası, çözücü veya doküman açılmadı.

**Kapsam:** 30 bölümün **20'si** oynandı: Ankara 6/6, Bakü 6/6, Paris 6/6, Londra 2/6. Londra 03 açıldı ve incelendi ama oynanmadı. Moskova (0/6) hiç açılmadı. Bunun nedeni oyun değil, benim çalışma bütçem doldu. Kalan bölümler için yorum yazmadım.

> Not: Ankara ve Bakü bölümleri için tuttuğum notlar daha az ayrıntılı. O bölümlerde deneme ve yıldız sayılarını yaklaşık verdim ("~" işaretli). Paris 05–06 ile Londra 01–02'de ekranda gördüğüm sonuçları birebir yazdım.

---

## 1. Özet

Last Train, "makas çevir, saati 1 dakika ilerlet" fikri üzerine kurulu, sıra tabanlı bir tren yönlendirme bulmacası. Görselliği ve atmosferi (LED tabela, şehir silüetleri, Metro Passport damgaları) türün ortalamasının açıkça üstünde, ilk izlenim çok iyi. Çekirdek döngü ise şu an fazla sığ: her bölüm 2–3 tren, 3–5 makas ve 10 dakikalık bir pencereden oluşuyor. Sınırsız "Geri Al" ve adım adım çözümü gösteren ipucu yüzünden oyun kolayca deneme-yanılmaya dönüyor. Yıldız sistemi oyuncuya ne istediğini anlatmıyor: ekranda gördüğüm hiçbir bölümde 3 yıldız alamadım ve neden alamadığımı da anlayamadım. Ödül olarak yalnızca damga var. Londra 03'ün Londra 02 ile aynı haritayı kullanması "içerik az" hissini güçlendiriyor. Kısacası güzel bir vitrin, ama uzun süre oynatacak derinlik henüz yok.

| Kriter | Puan (10 üzerinden) |
|---|---|
| Anlaşılırlık | 6 |
| Eğlence | 6 |
| Zorluk dengesi | 5 |
| Yaratıcılık / özgünlük | 7 |
| Görsel / his | 8 |
| "Bırakamama" (bağımlılık) | 4 |
| **Genel** | **6** |

---

## 2. İlk 5 dakika

- **Açılış:** Ana menü şık. Uygulama ikonu büyük gösteriliyor, "LAST TRAIN" başlığı ve altında "SON SEFER 23:59" yazan LED tabela var. Butonlar: DEVAM ET, ŞEHİR SEÇ, METRO PASSPORT, sağ üstte dişli. Alttaki "Gerçek şehirlerden esinlenen kurgusal metro bulmacaları." cümlesi oyunun ne olduğunu iyi anlatıyor.
- **İlk bölümde anladıklarım:**
  - Turuncu halkalı noktalar makas. Dokununca tren yolunun yönü değişiyor ve ileriyi gösteren renkli bir ok çıkıyor. Bu çok net.
  - "1 DAKİKA İLERLET" butonu saati bir dakika ileri alıyor ve tüm trenler bir adım gidiyor. Tabeladaki saat 23:50'den başlıyor.
  - Trenin üstündeki sembol (daire, kare, üçgen) aynı sembollü istasyona gitmesi gerektiğini gösteriyor. Renk ve sembol eşlemesi anlaşılır.
- **Anlamadıklarım / zorlandıklarım:**
  - Saatin 00:00 olunca biteceğini, yani toplam 10 dakikam olduğunu, ilk denemede ancak zaman dolunca anladım. Bu sınır baştan açıkça söylenmiyor.
  - Üst bardaki nokta dizisindeki **★ işaretlerinin** ne anlama geldiğini (örneğin Paris 05'te 9. ve 12. noktada) çözemedim. İlk tahminim "o dakikadan önce bitirirsem yıldız alırım" oldu. Ama Paris 05'i 8 dakikada bitirdim ve yine 2 yıldız aldım. Bu tahmin ya yanlış ya da ekran yanıltıcı.
  - Bazı trenlerde **"⏸" (bekle) rozeti** ve yanında küçük kırmızı/yeşil sinyal lambası var. Lambaya dokununca yeşile döndüğünü ve trenin yola çıktığını deneyerek buldum. Hiçbir yerde açıklama görmedim.
  - Çarpışmada kırmızı "X" çıkıyor ve İLERLET butonu kırmızıya dönüyor. Bu iyi bir uyarı ama oyunun bitip bitmediği, yani "Geri Al mı yapmam gerek, devam edebilir miyim" sorusu ilk seferde belirsizdi.
- **Öğretici:** Ayrı bir öğretici ekranı yok. Bazı bölümlerin üstünde turkuaz "Y" ikonlu tek satırlık ipucu kartları çıkıyor ("Halkada tren dönmeye devam eder…", "Fazladan bir tur dakika yer.", "Bazen hedef tam bir tur ötede."). Bu kartlar kısa ve iyi, ancak ilk dokunuşta kayboluyor ve sonra tekrar açılamıyor.

---

## 3. Bölüm bölüm notlar

| Bölüm | Deneme | İpucu | Yıldız | His |
|---|---|---|---|---|
| Ankara 01 | 1 | Yok | ~2 | Makas + İLERLET mantığı hemen oturuyor, rahat giriş. |
| Ankara 02 | ~1–2 | Yok | ~2 | Hâlâ çok kolay. |
| Ankara 03 | ~2 | Yok | ~2 | AŞTİ / Törekent / Koru adları güzel bir yerellik katıyor. |
| Ankara 04 | ~2–3 | Yok | ~2 | İki treni aynı makastan farklı yönlere geçirmek ilk "aha" anı. |
| Ankara 05 | ~2–3 | Yok | ~2 | Zamanlama önem kazanıyor. |
| Ankara 06 | ~3 | Yok | ~2 | Şehir finali, fazla zorlamadı. |
| Bakü 01 | ~1–2 | Yok | ~2 | Görsel tema değişimi hoş, mekanik aynı. |
| Bakü 02 | ~2 | Yok | ~2 | Sinyal (⏸) ilk kez dikkatimi çekti, deneyerek çözdüm. |
| Bakü 03 | ~2–3 | Yok | ~2 | Sahil vb. istasyon adları güzel. |
| Bakü 04 | ~3 | Yok | ~2 | Burada süreyi bilerek doldurup kaybetme ekranını gördüm. |
| Bakü 05 | ~3 | Yok | ~2 | Biraz tekrar hissi başladı. |
| Bakü 06 | ~3–4 | Yok | ~2 | Final ama Ankara 06'dan belirgin şekilde zor değil. |
| Paris 01 | ~2 | Yok | ~2 | Eyfel silüeti ve mor palet çok iyi. |
| Paris 02 | ~2 | Yok | ~2 | — |
| Paris 03 | ~3 | Yok | ~2 | — |
| Paris 04 | ~3–4 | Yok | ~2 | Sinyalleri doğru dakikada açmak gerekiyor. |
| Paris 05 "Üç Son Sefer" | ~5 | **Var** (3+ başarısızlıktan sonra, birkaç adım boyunca) | 2 (8 dk) | İpucu çözümü adım adım gösterdi. Kendi bulmuş gibi hissetmedim. |
| Paris 06 "Paris Gece Finali" | ~6 | **Var** (iki çarpışma ve Baştan'dan sonra; neredeyse her adımda) | 2 (10 dk, saat tam 00:00) | Dar zamanlama ve 4 makas. Son 2 dakikada iki kez çarpıştım. Zor ama "çözdüm" hissi ipucu yüzünden zayıf. |
| Londra 01 "Halka Girişi" | 3 | **Var** (iki çarpışmadan sonra) | 2 (5 dk) | Halka fikri yeni ve güzel. Ama mavi tren "⏸"da beklerken kırmızının ona çarpması sezgisel değil. |
| Londra 02 "Bir Tur Daha" | 3 | **Var** (bir çarpışmadan sonra; çözüm boyunca) | 2 (8 dk) | Halkada sırayı ayarlamak keyifli. Ancak bir trenin makas üstünde boşuna 1 dakika beklediğini fark etmedim (aşağıdaki hataya bakın). |
| Londra 03 "Son Aktarma" | açtım, oynamadım | — | — | **Londra 02 ile birebir aynı harita**, yalnız hedefler yer değiştirmiş. |
| Londra 04–06, Moskova 01–06 | oynanmadı | — | — | Benim bütçem yüzünden. Moskova kartında "NIGHTMARE NETWORK" yazıyor, ilerleme 0/6. Kilitli olup olmadığını gösteren bir işaret görmedim. |

**Bıraktığım nokta:** Yok. 12+ denemeye ulaşan bölüm olmadı. Bunun asıl nedeni zorluğun düşük olması değil, sınırsız Geri Al ile adım adım çözen ipucunun tıkanmayı hemen ortadan kaldırması. Gerçek bir oyuncu için en riskli yer **Paris 06**: iki çarpışma ve süre baskısı aynı anda geliyor.

**Hiçbir bölümde 3 yıldız göremedim.** Bitirdiğim tüm bölümlerde sonuç 2 yıldızdı. Neyin 3 yıldız getirdiği oyun içinde hiç söylenmiyor.

---

## 4. Neyi iyi yapıyor

- **Atmosfer ve marka:** LED tabela başlıkları ("PARİS 05 · Üç Son Sefer 23:51") ve "HAT TEMİZ" zafer ekranı tutarlı. Trafik lambası biçimli geri butonu ve şehirlere özel arka planlar (Paris'te Eyfel, Londra'da tuğla duvar, yağmur ve saat kulesi, Ankara'da Atakule) oyunu "jenerik bulmaca"dan ayırıyor.
- **Şehre göre selamlama:** "Bienvenue !", "Xoş gəlmisən!", "Hoş geldin, başkent!", "Добро пожаловать!" küçük ama sevimli dokunuşlar.
- **Metro Passport:** Şehir bitince çıkan damga (Eyfel), tarih ve "6/6" bilgisi çok iyi bir ödül anı. Kart sayfalarını kaydırarak gezmek tatmin edici.
- **Okunur tahta:** Seçili makas yönünü gösteren renkli ok ve trenin gideceği yolun önceden çizilmesi iyi. Çarpışmanın kırmızı X ve kırmızı İLERLET butonuyla gösterilmesi de anında anlaşılıyor.
- **Geri Al / Baştan:** Hızlı ve güvenilir. Çarpışmadan sonra bir adım geri almak akışı bozmuyor.
- **Ayarlar:** Titreşim, Ses, Hareketi azalt, Yüksek kontrast ve Dil (Telefon / Türkçe / English) var. Dil değişimi anında uygulanıyor, yeniden başlatma gerekmiyor.
- **Yeni mekanik girişi:** Londra'daki halka ("tren dönmeye devam eder") tek cümleyle ve tek bölümle öğretiliyor. Doğru bir yaklaşım.

---

## 5. Eksikler ve sınırlılıklar

- **Oynanış derinliği:** Her bölüm 10 dakikalık sabit bir pencere, 2–3 tren ve 3–5 makastan oluşuyor. Seçim alanı küçük. Sınırsız Geri Al ile oyuncu düşünmek yerine "dene, çarpış, geri al" yapabiliyor. Bulmaca çoğu zaman bir mantık sorusu gibi değil, sıralama denemesi gibi hissettiriyor.
- **İpucu çok cömert:** Ampul sonraki tek hamleyi el işaretiyle gösteriyor ve sınırsız gibi görünüyor (sayaç veya bekleme süresi görmedim). Art arda basınca bölümü tamamen çözüyor. Tıkanmayı çözüyor ama "ben çözdüm" duygusunu öldürüyor.
- **Yıldız ve ödül sistemi anlaşılmıyor:** 3 yıldızın koşulu (en az dakika mı, ipucu kullanmamak mı, Geri Al kullanmamak mı?) hiçbir yerde yazmıyor. Bitiş ekranında yalnızca "8 dakika" yazıyor, hedef gösterilmiyor. Toplanan yıldızların bir karşılığı da yok (kilit açma, kozmetik).
- **Çeşitlilik ve içerik miktarı:** Kesin gördüğüm mekanikler makas, sinyal (⏸ lamba) ve halka. Londra 03 haritası Londra 02'nin aynısı. 30 bölüm, tamamlayan biri için yaklaşık 1–1,5 saatlik içerik.
- **İlerleme hissi:** Şehirler arası zorluk artışı zayıf. Ankara 06 ile Bakü 06 arasında belirgin bir fark hissetmedim. Paris 05–06'da zorluk aniden arttı.
- **Tekrar oynanabilirlik:** Tekrar oynamak için tek neden yıldızlar, onların koşulu da belirsiz. Günlük bulmaca, süre/hamle sıralaması, meydan okuma modu yok.
- **Türde beklenen ama eksik özellikler:** 3 yıldızın hedef dakikasının bölüm başında gösterilmesi. Trenleri adım adım değil otomatik oynatan bir "Oynat / Hızlandır" modu. Bölüm seçiminde her bölümün yıldızının görünmesi: Paris haritasında düğümler yalnızca 1–6 numaralı, yıldız yok. "Son hamlede ne oldu" tekrarı. Gün içi ödül veya seri.

---

## 6. Hatalar ve görsel sorunlar

1. **Makas üstündeki trene dokunmak makası çevirmiyor (dokunma alanı sorunu).**
   Yer: Londra 02. Yeşil tren sol üst makasta "⏸" ile beklerken trenin üstüne (makas merkezinin yaklaşık 25 pt yukarısına) dokundum. Hiçbir şey olmadı. Ardından İLERLET'e bastım ve tren 1 dakika boşuna bekledi. Makasın tam merkezine dokununca çalıştı.
   Beklenen: Tren makasın üstündeyken trenin herhangi bir yerine dokunmak makası çevirmeli ya da en azından dokunuşun algılandığı geri bildirimle belli olmalı.
2. **Yıldız işaretleri ile kazanılan yıldız tutarsız görünüyor.**
   Yer: Paris 05. Üst bardaki ilk ★ 9. noktada. Bölümü 8 dakikada bitirdim ve 2 yıldız aldım. Paris 06'da ★ 11. noktada, 10 dakikada bitirdim, yine 2 yıldız.
   Ya ★'ların anlamı farklı ya da gösterim yanıltıcı. Her iki durumda da oyuncu hedefini anlayamıyor.
3. **"⏸" rozeti ve sinyal lambası iki ayrı simge gibi duruyor.**
   Yer: Paris 05–06, Londra 01. Trenin üstünde "⏸" rozeti ve yanında ayrı bir küçük trafik lambası var. Bir trenin neden beklediği (sinyal mi, makas yönü mü, önündeki tren mi) her zaman anlaşılmıyor. Londra 02'de rozet sinyal yüzünden değil, makas yanlış yöne baktığı için çıkmıştı.
4. **Şehir seçimi başlığındaki alt metin ilk açılışta kesiliyor.**
   Yer: Ana menü → ŞEHİR SEÇ. Alt satır "…kurgusal metro bul…" diye kesik başlıyor, sonra kayarak tamamlanıyor. Küçük ama ilk bakışta hata gibi görünüyor.
5. **Moskova kartında kilit durumu belirsiz.**
   Yer: ŞEHİR SEÇ → sona kaydır. Kartta "NIGHTMARE NETWORK", 0/6 ve 5 kırmızı nokta var. Kilitli mi açık mı, nasıl açılır, ekrandan anlaşılmıyor. Diğer kartlarda da kilit simgesi göremedim.
6. **İpucu kartı geri getirilemiyor.**
   Yer: Londra 01–03. Üstteki "Y" ikonlu ipucu kartı ilk dokunuşta kayboluyor. Okumadan dokunursanız tekrar açmanın yolu yok.

Çökme, donma veya ilerleme kaybı yaşamadım. İngilizce ↔ Türkçe dil değişimi sorunsuz çalıştı.

---

## 7. Oyun ne kadar sarıyor

Dürüst olmak gerekirse ilk 15–20 dakika keyifli: görseller merak uyandırıyor, Passport damgası küçük bir zafer hissi veriyor. Bakü'nün ortalarında **tekrar hissi** başladı: aynı tür harita, aynı 10 dakika, aynı 2 yıldız. Paris 05–06'da zorluk aniden arttı. Orada sinirlendim ve ipucuna başvurdum, ipucu da çözümü elime verdi. Bu iki uç, "çok kolay" ile "ipucu çözüyor", oyunu bırakmayı kolaylaştırıyor.

- Yarın tekrar açar mıyım? **Belki bir kez**, yeni şehri ve damgayı görmek için. Ama oyun beni geri çağıracak bir neden (günlük bulmaca, seri, net 3 yıldız hedefi) vermiyor.
- Tavsiye eder miyim? Görselliği seven, kısa ve sakin bulmaca isteyen birine "güzel ama kısa" diye tavsiye ederim. Bulmaca meraklısına şu haliyle etmem, derinlik yetersiz.
- En çok sıkıldığım yer: Bakü 03–05 (tekrar). En çok sinirlendiğim yer: Paris 06'nın son iki dakikasında art arda gelen çarpışmalar ve Londra 02'de dokunuşun algılanmaması yüzünden kaybedilen dakika.

---

## 8. En önemli 10 öneri (oyuncuyu tutma etkisine göre sıralı)

1. **3 yıldızın koşulunu görünür yap.** Bölüm başında ve bitiş ekranında "3★ için ≤ 6 dakika" gibi bir hedef göster, kaçırılan yıldızın nedenini yaz.
2. **İpucunu sınırla veya kademeli yap.** Önce yalnızca "hangi tren sorunlu" bilgisini ver, sonra makası göster. Ya da günlük ipucu hakkı tanı. İpucu kullanılan bölümde 3 yıldızı kapat.
3. **Bölüm haritalarını tekrar kullanma** (Londra 02 ve 03). Her bölüm yeni bir yerleşim veya yeni bir kısıt getirmeli.
4. **Zorluk eğrisini düzleştir.** Ankara ve Bakü sonlarına biraz zorluk ekle, Paris 05–06'daki ani sıçramayı ara bölümlerle yumuşat.
5. **Bölüm seçim ekranında her bölümün yıldızını göster** ve şehir toplamını (örneğin 12/18★) yaz. Eksik yıldız, oyuncuyu tekrar oynamaya çeker.
6. **Makas üstündeki trene dokunmayı makası çevirmeye yönlendir** ve her dokunuşa görsel ya da titreşimli geri bildirim ver (Hata 1).
7. **"Neden bekliyor?" netliği:** ⏸ rozetinin üstünde nedeni tek simgeyle göster (sinyal, makas veya önünde tren). Sinyal lambasını rozetle birleştir.
8. **Yeni mekanikleri daha sık getir** (her şehirde bir tane). Örnekler: tek yönlü hat, gecikmeli tren, kapanan istasyon, iki vagonlu tren. Bu, Bakü'de başlayan tekrar hissini kırar.
9. **Geri dönüş nedeni ekle:** Günlük "Son Sefer" bulmacası, damga koleksiyonuna bonus sayfalar ve seri sayacı.
10. **İpucu kartlarını tekrar açılabilir yap** (tabelaya dokununca yeniden gelsin) ve Moskova gibi kilitli şehirlerde açma koşulunu yaz.

---

## 9. Sınırlarım

- **Ses ve titreşim:** Simülatörde ses dinleyemedim ve titreşim hissedemedim. Ayarlarda açık olduklarını gördüm ama kalitelerini değerlendiremedim.
- **Gerçek parmak:** Tıklamalarım nokta hassasiyetinde koordinat tıklamasıydı. Gerçek parmakla küçük makasların ve sinyal lambalarının dokunma alanı daha da sorunlu olabilir (Hata 1). Bunu doğrulayamadım.
- **Süre baskısı:** Oyun sıra tabanlı ve ekran görüntüsü gecikmesiyle oynadım. Gerçek zamanlı stres hissini ölçemedim, oyun da zaten gerçek zamanlı değil.
- **Kapsam:** Londra 03–06 ve Moskova'yı (Nightmare Network) oynayamadım. Geç oyundaki zorluk ve çeşitlilik hakkındaki yargım eksik.
- **Ankara ve Bakü notları:** Bu iki şehirdeki deneme ve yıldız sayılarını yaklaşık verdim (~ ile işaretli).
- **Uzun vadeli tutunma:** Ertesi gün açma, bildirim veya seri gibi davranışları tek oturumda test edemedim.
- **Duygu:** "Sıkıldım" veya "sinirlendim" ifadeleri, bir insan oyuncunun ne zaman bırakacağına dair benim tahminim. Ölçülmüş bir veri değil.
