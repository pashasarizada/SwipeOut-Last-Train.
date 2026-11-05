# CLAUDE CODE ANA GÖREV PROMPTU — SWIPEOUT: LAST TRAIN

> Bu dosyanın içeriğini Claude Code'un **Cloud/Remote** oturumuna gönder. Bu metin bir görev tanımıdır. Claude, bu metni yalnızca açıklamakla yetinmemeli; dosyaları ve çalışan Flutter projesini gerçekten oluşturmalıdır.

## 0. Rolün, dilin ve çalışma prensibin

Sen deneyimli bir **Flutter oyun geliştiricisi, game designer, QA mühendisi ve teknik proje liderisin**. Sıfırdan, üretime aday, mobil ve offline çalışan küçük bir bulmaca oyunu geliştiriyorsun. Oyunun adı: **SwipeOut: Last Train**.

**Kullanıcıyla daima Türkçe konuş.** Plan, günlük ilerleme, teknik kararlar, hatalar, commit/PR özetleri, sonuç raporları ve soru-cevaplar Türkçe olacak. Kod içindeki sınıf, fonksiyon ve değişken isimleri İngilizce ve anlamlı olacak. Teknik dokümanlar Türkçe; gerekli yerlerde İngilizce terimleri parantezle açıklayabilirsin. Oyundaki ilk diller İngilizce ve Türkçe olacak.

Görev sadece bir konsept üretmek değil: **gerçek Flutter uygulamasını yaz, test et, GitHub'a güvenli şekilde sun, ilerleme dosyalarını tut.** Anlamadığın bir ayrıntı varsa en düşük karmaşıklığı getiren sürdürülebilir varsayımı yap; `docs/DECISIONS.md` içerisine yaz. İşe yarayan bir MVP üretmeden görsel maketlere takılıp kalma. **Bitmeyen bir özellik listesi yerine çalışan küçük oyun** hedefimiz.

Proje ve otomasyon işlemlerinde erişim izinlerini sahte biçimde varsayma. Hiçbir zaman 'GitHub bağlandı', 'PR açıldı', 'iOS derlendi', 'testler geçti', 'gece görevi kuruldu' gibi iddiaları doğrulamadan yazma. Kısıt varsa açıkça bildir ve kalan işlere devam et. Gerekli kullanıcı onayı varsa bunun için bekle; başka bağımsız işleri yap.

## 1. Birinci adım: Çalışma ortamını denetle ve projeyi başlat

1. `pwd`, `ls -la`, `git status`, `flutter --version`, `dart --version`, `git remote -v` çalıştır; mevcut araç, izin ve dizini raporla.
2. Çalışma alanında mevcut bir Git deposu varsa **başka projeyi silme veya üzerine yazma**. Repo yalnızca SwipeOut için ayrılmışsa mevcut kökten ilerle.
3. Uygun repo/çalışma klasörü mevcut değilse erişimin varsa `swipeout_last_train` adlı Flutter projesini oluştur. İlk geliştirme için geçici örnek organizasyon tanımlayıcısı kullan; üretim bundle ID'sini kullanıcı onayı olmadan şirket adına uydurma. Örnek: `flutter create --project-name swipeout_last_train --org com.example .` (yalnızca boş ve doğru klasörde).
4. GitHub remote henüz yoksa **GitHub'da özel `swipeout-last-train` deposunun kullanıcı tarafından oluşturulması ve Anthropic GitHub bağlantısının onaylanması gerektiğini** belirt; mevcut yerel dosyaları hazırlamaya devam et. Yetkili entegrasyon varsa mevcut özel repoda feature branch kullan. Asla yanlış repo üzerinde işlem yapma.
5. Flutter SDK / pub paketleri bulutta mevcut değilse bunun için ortam kurulum yönergeleri ve bir `scripts/bootstrap.sh` hazırlayıp imkân varsa test et; ortamın sınırlarını belgede ayır. Desteklenmeyen iOS/Xcode derlemesini başarılmış gibi gösterme.
6. Varsa mevcut kodu önce incele. Hiçbir mevcut kullanıcı dosyasını veya çalışan kodu gerekçesiz değiştirme.

**Asıl ilk somut teslim:** `README.md`, `CLAUDE.md`, `GAME_DESIGN.md`, `TASKS.md`, `PROGRESS.md`, `docs/ARCHITECTURE.md`, `docs/LEVEL_FORMAT.md`, `docs/DECISIONS.md`, `docs/AUTOMATION_SETUP.md` ve çalıştırılabilir bir Flutter iskeleti.

## 2. Oyun vizyonu ve sınırları

**Bir cümlelik tanım:** Gecenin son metro seferinde, küçük ray ağlarında farklı renkli trenleri birbirine çarptırmadan doğru renkli istasyonlarına ulaştır; ray makaslarını aç-kapa, trenlerin hareket sırasını planla.

Oyun bir metro yönetim simülatörü değil; **tek parmakla oynanan, sıra tabanlı (turn-based), kısa, taktiksel bir bulmaca**. Hedef deneyim: Metroda 2–5 dakikalık oturum; internetsiz; dilediği an çıkıp sonra devam edebilen kullanıcı. Hız, gerçek zamanlı trafik, fizik, gerçek ray geometrisinin birebir kopyalanması ve çok oyunculu sistem YOK.

Oyuncu vaadi: **"Tek bir makası çevirmek, üç trenin kaderini değiştirir."**

**MVP'de olacaklar:**
- Dikey ekran (portrait), iPhone öncelikli; Android cihazlarda da çalışan Flutter kodu.
- Başlangıç/oyna ekranı, şehir seçimi, bölüm seçim haritası, oyun tahtası, bölüm sonuç ekranı; ayarlar ve yardım küçük sayfa/bottom sheet olabilir.
- İlk oynanabilir şehir **İstanbul'dan esinlenen ÖZGÜN bir gece metrosu haritası**. Resmî metro logosunu, kurum adını veya resmî harita tasarımını birebir kopyalama. İstanbul atmosferi bir arka plan ve ilerleme temasıdır; seviyeler gerçek ağ şeması değildir.
- Londra/Tokyo seçeneklerini gelecekteki içerik olarak yalnızca gerekiyorsa `Yakında` şeklinde, satın alınabilir gibi göstermeden sergile. İlk sürümün bir şehirle tam oynanabilir olması daha önemli.
- Hedef 30 **elle tasarlanmış ve çözümü doğrulanmış** kısa seviye. Öncelik: 12 kaliteli ve test edilmiş bölüm; ancak bunlar bittiğinde 30'a ilerle. Asla tamamlanmamış bölümleri çalışıyor diye göstermeyin.
- 2–4 farklı renkli tren, 1–3 makas, çıkış istasyonları, birbirini engelleyen trenler, geri al, yeniden başlat, ipucu veya ipucu için güvenilir çözüm göstergesi.
- Türkçe ve İngilizce temel çeviri, titreşim ayarı, ses ayarı, renklerle birlikte sembol/harf ikonları.
- Offline yerel ilerleme, bölüm yıldızları ve kullanıcı ayarları.

**MVP'de OLMAYACAKLAR:** internet zorunluluğu, kullanıcı kaydı, Firebase, Laravel, sunucu, canlı leaderboard, multiplayer, gerçek zamanlı fizik, harici ücretli API, reklam SDK'sı, ödeme ekranı, rastgele çözülemez bulmaca, karmaşık parçacık sistemi, 3D, resmî harita lisansı olmayan görseller, otomatik App Store/Play Store yayını.

## 3. Kesin oyun kuralları — belirsizlik bırakma

Bu kuralları **önce saf Dart game engine** olarak, Flutter arayüzünden bağımsız geliştir.

### 3.1 Tahta
- Her bölüm 5x5 ile 7x7 arasında dikdörtgen bir **kare ızgara** (grid) kullanır. Raylar kareler arasında bağlanan yollar olarak gösterilir.
- Hücre türleri: `empty`, `trackStraight`, `trackCorner`, `switch`, `depot`, `station`, gerekirse `blocked`.
- Her rayın N/E/S/W yönlerinden hangilerine bağlandığı deterministik olarak tutulur. Komşu iki hücre arasında hareket için karşılıklı portlar eşleşmelidir.
- Her istasyon belirli bir tren rengine veya sembolüne aittir. Görsel erişilebilirlik için renk **tek başına bilgi kaynağı olmasın**; istasyon/tringe R, B, G gibi işaretler de koy.
- Her karede aynı anda en çok bir tren bulunur. Trenler ve istasyonlar seviyenin başlangıç durumunda veridir.

### 3.2 Oyuncu etkileşimi
- Bir trene **dokununca** tren seçilir ve vurgulanır.
- Oyuncu seçilmiş tren üzerinde veya oyun alanında **yukarı/aşağı/sağa/sola kaydırınca** tren, o yöndeki bitişik ray karesine **tam bir kare** ilerlemeye çalışır. *Bir swipe = bir geçerli tren adımı.* Yeni bir hamle anında gerçek zamanlı başka tren hareket etmez.
- Adım ancak mevcut hücre ile hedef hücrenin karşılıklı açık ray portları varsa, hedef hücre geçerliyse ve hedef başka trenle dolu değilse uygulanır.
- Hedef hücre **başka renkte istasyonsa**, geçiş engellenir ve kısa bir anlaşılır görsel geri bildirim verilir. Doğru istasyona giren tren teslim edilmiş sayılır; durumu tabloda kaybolmuş/istasyonda park etmiş şeklinde net göster ve artık hareket ettirilmez.
- Hareket geçerli değilse hamle sayılmaz, oyun durumunu değiştirme.
- Boş bir makasa dokununca iki geçerli bağlantı durumundan ötekine geçer. **Makas değiştirmek de 1 hamle sayılır.** Tren makasın üzerindeyken makas döndürülmez.
- Makasın bir `common` girişi ve iki `branch` çıkışı vardır; aktif konum, `common + selectedBranch` bağlantısını açar. N/E/S/W içinden seçilecek yönler seviye verisinde tanımlanır; ray bağlantı mantığını testlerle doğrula.
- Makasa yanlış yönden girmenin neye izin verdiğini aynı port kuralı belirler; bir tren bir makasa girince oradan çıkmak için aktif portların tutarlı olması gerekir. Ani dönme veya ışınlanma yok.
- Aynı anda yalnızca seçili bir tren yönetilir. Tren hareketleri ve switch animasyonları bitmeden yeni komut işlenmez; çakışan gesture kabul edilmez.
- **Undo:** son geçerli tren hareketini veya makas değişimini bütünüyle geri alır; teslim edilen tren de geri gelir. Geri alma sınırsızdır (yalnızca ilgili bölümün geçmişi kadar).
- **Restart:** seviyeyi başlangıç durumuna döndürür.

### 3.3 Kazanma ve puan
- Tüm trenler kendi istasyonlarına teslim edilirse seviye tamamlanır.
- Oyuncu dilediği kadar deneyebilir; yanlış hamlede aniden oyunu kaybettiren zaman baskısı yoktur.
- Her seviye için doğrulanmış **optimal hamle sayısı** vardır. Altın: optimum veya +1; gümüş: optimum +2...+4; bronz: her türlü başarılı çözüm. Bunu test ve seviye üretim sonucuna göre esnek ayarla.
- İlerleme: Seviye bitince sonraki seviye açılır, yıldızlar yerel olarak kaydedilir. Aynı seviye tekrar oynanabilir.
- Hangi treni önce hareket ettirdiğin, birbirine giren raylar ve sınırlı manevra alanı zorluğun kaynağıdır; sadece butona gelişigüzel basmak yeterli olmamalı.

### 3.4 Öğretici bölüm akışı
- Bölüm 1: tek tren, düz bir yol, seç ve swipe.
- Bölüm 2: tek makası dokunarak çevir, doğru çıkışı aç.
- Bölüm 3: iki tren, iki hedef, birbirinin yolunu kesen konumlar.
- Bölüm 4–5: undo ve yeniden başlat, sıkışmanın çözümü.
- Bölüm 6–15: artan makas/engel sayısı; plan yapma.
- Bölüm 16–25: 3 renkli tren ve birden çok kavşak.
- Bölüm 26–30: 3–4 tren, maksimum 3 makas, kısa ama dikkatli planlama.
- Yeni oyuncu ilk 30 saniyede ne yapacağını anlamalı; tutorial yazıları iki satırı aşmasın.

### 3.5 Seviyelerin kalitesi zorunlu
- Seviyeleri ayrı veri dosyalarında, örneğin `assets/levels/level_001.json` biçiminde tut.
- `LevelDefinition` biçimi ve doğrulama kuralları `docs/LEVEL_FORMAT.md` içinde dokümante edilsin.
- Her level için otomatik doğrulamalar: en az bir tren; her trene karşılık hedef; benzersiz tren konumu; sınırların dışına taşmama; ray port tutarlılığı; switch tanımlarının geçerli olması; çözülebilirlik.
- Bulmaca motoruyla **BFS/A* tabanlı, uygun durum sınırına sahip deterministik bir çözücü** oluştur; switch durumları, tren konumları ve teslim bitleri state'e dahil edilsin. Seviye üretirken her bölümü çöz ve optimum veya bilinen çözüm sayısını sakla.
- Test edilemeyen ya da çözülemeyen seviyeleri gösterme. Geliştirmeyi basitleştirmek gerekirse hedef bölüm sayısını değil kaliteyi öncele.

## 4. Görsel kimlik ve kullanıcı deneyimi

- Atmosfer: **gece yarısı metrosu**, lacivert/kömür zemin, net ray hatları, turkuaz/kırmızı/amber vurgular, trenlerde sade ve okunaklı geometrik şekiller.
- Üstte `LAST TRAIN / ISTANBUL · LEVEL 07` ve hamle sayacı; ortada ana ray alanı; altta `Undo`, `Restart`, `Hint` ve gerektiğinde `Pause` düğmeleri.
- Minimal hareketler: tren bir kare ilerlerken 120–250 ms animasyon; switch dönme animasyonu; doğru teslimde hafif haptik/başarı efekti. Ağır parçacık efektleri yok.
- Flutter `CustomPainter` veya mümkün olduğunca sade widget'larla çizim yap. Bağımlılıkları küçük tut; Flame yalnızca teknik gerekçe varsa kullan.
- iPhone SE büyüklüğünden büyük ekranlara kadar güvenli alanları/screen size'ları ele al. Dikey mod ve tek elle oynama öncelikli.
- 60 FPS hedefi; gizlenmiş gereksiz `setState` zinciri ve per-frame karmaşık hesaplardan kaçın.
- Bölüm aralarında reklam gösterme, internet isteme veya e-posta toplama. Para kazanma entegrasyonunu yayın öncesi ayrıca kararlaştıracağız.
- Oyuncu ekranı kapatıp döndüğünde **mevcut seviye durumu** ve ilerlemesi geri yüklenebilsin.

## 5. Kod mimarisi

Flutter stable + Dart stable kullan. Gereksiz state management çatısı kurma; oyun motorunu immutable state/reducer yaklaşımıyla veya net bir controller üzerinden modelle. Önerilen modüller:

- `lib/game/domain/`: `LevelDefinition`, `BoardState`, `Train`, `Station`, `SwitchState`, `Move`, `LevelResult`.
- `lib/game/engine/`: ray bağlantı doğrulayıcısı, `GameEngine`, `UndoHistory`, `LevelSolver`, `LevelValidator`.
- `lib/game/data/`: JSON level loader, ilerleme repository ve local persistence.
- `lib/game/ui/`: şehir seçim, bölüm haritası, game board widget/custom painter, level complete, settings/tutorial.
- `lib/l10n/`: TR/EN yerelleştirme.
- `test/`: motor, switch, undo, save, seviye doğrulama, temel widget testleri.

`shared_preferences` gibi küçük bir kalıcılık paketi uygun olabilir; gerekirse sürümü ve nedenini belgeleyin. Oyun motoru Flutter UI'dan bağımsız test edilebilmeli. Asset ve paket lisanslarını not edin; ücretli kaynak kullanmayın.

## 6. Kalite ve test — yapılmış gibi gösterme

Her anlamlı aşamadan sonra mümkünse şunları çalıştır:

1. `dart format --output=none --set-exit-if-changed .`
2. `flutter pub get`
3. `flutter analyze`
4. `flutter test`
5. Flutter Web hedefi kuruluysa `flutter build web --release` (bu iOS build değildir).

Test başlıkları:
- Kaydırma ve ray portu uygunluğu, dolu kareye girememe, farklı renkte istasyonu reddetme.
- Makasın doğru iki hali ve üzerinde tren varken değiştirememe.
- Her geçerli işlemde hamle sayısının doğru artması, geçersiz işlemde artmaması.
- Undo sonrası aynı durumun birebir geri gelmesi, teslim edilen trenin geri dönmesi.
- Level çözümünün tekrar üretilebilir olması.
- App yeniden açıldığında ilerlemenin kalıcılığı.
- En az bir widget smoke testi.

Bulut ortamında Flutter SDK yoksa `testler geçiyor` deme. Kurulum dene veya `BLOCKED` diye belgele, kurulması gereken aracı yaz. iOS IPA/testflight için yerel macOS + Xcode ve kod imzalama gerekir; bulutta Flutter Web testinin geçmesi iOS yayına hazır demek değildir.

## 7. Çalışma takvimi ve öncelikler

**Faz 0 — Başlangıç:** ortam/repo kontrolü, `flutter create`, dokümanlar, temel mimari, ilk commit.

**Faz 1 — Oynanabilir çekirdek:** saf Dart engine, raylar, hareket, switch, hedef, undo; otomatik unit testler; çalışan ilk 3 öğretici bölüm.

**Faz 2 — Ürünleştirme:** 12 doğrulanmış bölüm, şehir ekranı, bölüm seçimi, lokal kayıt, TR/EN, responsive UI.

**Faz 3 — Kalite/İçerik:** 30 doğrulanmış bölüm hedefi, mini animasyonlar, ses, erişilebilirlik, işlevsel tutorial, testler.

**Faz 4 — Yayına hazırlık:** README, lisans/asset kontrolü, iOS/Android yerel doğrulama checklist'i, ikon ve App Store ekran görüntüsü için tasarım talimatları; **otomatik yayınlama veya ücretli servis kullanma yok**.

İlk iki faz bitmeden AdMob, analytics, IAP, online servis, leaderboard veya ekstra şehir ekleme. Başlangıçta oyun eğlencesini ispatlamak en önemli hedef.

## 8. Proje yönetimi ve uzun süreli otonom çalışma

Her oturumda şu sırayı uygula:

1. `CLAUDE.md`, `GAME_DESIGN.md`, `TASKS.md`, `PROGRESS.md`, `docs/DECISIONS.md` ve son 5 commit'i oku.
2. Var olan işleri bozmadan bitirilecek en yüksek öncelikli **tek küçük görevi** seç.
3. Gerekirse testini önce yaz, kodla, kontrol et.
4. `TASKS.md` checkbox ve `PROGRESS.md` içine tamamlananları, test sonuçlarını, bir sonraki adımı ve varsa engeli yaz.
5. En fazla bir odaklanmış küçük commit/PR serisi üret; günün görevini tanımlamadan rastgele refactor yapma.
6. İşe ara vermek zorundaysan devam edecek Claude oturumunun yalnızca bu dosyaları okuyarak ilerleyebilmesini sağla.

`PROGRESS.md` formatı:
- Tarih/saat ve branch
- Tamamlanan işler
- Çalıştırılan komutlar ve gerçek sonuçları
- Bilinen hatalar/blokerler
- Bir sonraki küçük görev
- Kullanıcıdan gerçekten gereken onaylar

`TASKS.md` içinde öncelik sınıfları `P0/P1/P2` olsun ve her işin *kabul kriteri* yazılsın. `CLAUDE.md` içinde Türkçe iletişim, dosya okuma sırası, test komutları ve güvenlik sınırları mutlaka yer alsın.

## 9. GitHub, Cloud ve gece otomasyonu

Hedef iş akışı: **kullanıcının Mac'i kapalıyken Anthropic Claude Code Cloud üzerinde kod geliştirme, sonunda GitHub'da `claude/...` feature branch + Pull Request veya gözden geçirilebilir değişiklikler.**

- Cloud'un gerçekten mevcut olup olmadığını, GitHub erişimini, şube yazma iznini ve scheduled-task özelliğini **mevcut oturumundan doğrula**. Bir entegrasyon izni gerekiyorsa bunu kullanıcının yapacağı adımlarla Türkçe açıkla; yapmadığın işlemi olmuş gösterme.
- GitHub bağlantısı için kullanıcıyı mümkünse `https://claude.ai/code` üzerinden GitHub App yetkilendirmesine yönlendir. Sadece bu projeye erişim ver. Alternatif olarak kurulum dokümanında desteklenen terminal bağlantısını belirt.
- İlk kodu doğrudan `main` üzerine otomatik birleştirme. Her iş için `claude/<konu>` branch ve PR tercih et.
- Cloud ortamında **yerel Mac'in dosyaları, iOS simülatörü, Xcode ve Keychain bilgileri bulunmayabilir**. Bu nedenle cloud görevleri kod/test/dokümantasyon odaklı olacak; imzalama ve iOS release işlemleri kullanıcının Mac'inde elle yapılacak.
- Eğer cloud scheduled task kurmaya gerekli erişimin/araçların yoksa `docs/AUTOMATION_SETUP.md` belgesine **manuel kurulum** adımlarını yaz: `https://claude.ai/code/routines` (bazı arayüzlerde Scheduled Tasks/Routines), `New task`, `Cloud`, repo seçimi, gece `01:07` Türkiye saati, prompt, ortam, tetikleyici, son olarak `Run now` ile deneme.
- Asla hesap erişimini, ücretli plan değişikliğini veya API kullanımını sen yapmış gibi gösterme. Max plan limitlerinin çalışmayı durdurabileceğini belirt.
- Gece görevinin her gün büyük bir işi bitirmesi garantisi yok; yalnızca güvenli, küçük hedefler ve testlerle ilerlesin.

## 10. Güvenlik sınırları

- Kullanıcıdan onay almadan App Store / Play Store'a sürüm gönderme, reklam kampanyası başlatma, ödeme yapma, abonelik alma, API anahtarı üretme, gizli anahtarları repoya commit etme veya bir sistemden veri silme.
- `--dangerously-skip-permissions`, sınırsız yetki, shell üzerinden sınırsız dış komut çalıştırma veya güvenlik bariyerlerini devre dışı bırakmayı önermeyin.
- `main` üzerinde otomatik merge yapma, force push yapma, gizli tokenları stdout'a yazma.
- Ücretli/markalı varlıkları lisanssız kullanma.
- Tek başına oyun SDK'sını kurabilmek başka, release için Apple sertifikasına sahip olmak başkadır. Bunları ayır.
- Kullanıcının HeirLoam işlerine dokunma; bu repo bağımsız olacak.

## 11. İlk oturumda senden beklenen gerçek çıktı

1. Mevcut ortamı ve repo yetkilerini kısa Türkçe raporla.
2. Dosyaları **gerçekten oluştur**: `CLAUDE.md`, `GAME_DESIGN.md`, `TASKS.md`, `PROGRESS.md`, `docs/ARCHITECTURE.md`, `docs/LEVEL_FORMAT.md`, `docs/DECISIONS.md`, `docs/AUTOMATION_SETUP.md`, `docs/RELEASE_CHECKLIST.md`.
3. Flutter iskeletini ve çalışan ilk menüyü oluştur; zaman ve araçlar elveriyorsa ilk oynanabilir motor ve tutorial bölümü geliştir.
4. Uygun erişim varsa `claude/bootstrap-swipeout` branch'e commit et ve review amaçlı PR aç; erişim yoksa bunu açıkça belirt.
5. Gerçek test sonuçlarını ver; neyin eksik olduğunu saklama.
6. Son mesajın **Türkçe ve kısa** olsun: `Yapılanlar / Testler / GitHub bağlantısı / Engel / Sıradaki görev / Benim yapmam gereken tek şey`.

**Şimdi yalnızca bir plan anlatmakla yetinme: ortamı denetleyerek işe başla ve dosyaları/kodu üret.**
