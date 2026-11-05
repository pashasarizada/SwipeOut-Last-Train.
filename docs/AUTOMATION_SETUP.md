# Otomasyon Kurulumu (Claude Code Cloud + gece görevi)

Hedef: Mac kapalıyken Claude Code Cloud'da küçük, test edilmiş adımlarla ilerlemek; her işi `claude/<konu>` branch'i + Pull Request olarak gözden geçirmeye sunmak.

> Bu belgedeki adımlar **kullanıcı tarafından** yapılır. Bu oturumda GitHub App yetkisi, cloud ortamı veya zamanlanmış görev **kurulmadı**; yalnızca yerel `git remote` ayarlandı.

## 1. GitHub erişimi
1. `https://claude.ai/code` → GitHub bağlantısı → Claude GitHub App'i yetkilendir.
2. Erişimi **yalnızca** `pashasarizada/SwipeOut-Last-Train.` deposuna ver (tüm depolara değil).
3. Alternatif: terminalde `gh auth login` (bu makinede `gh` şu an kurulu değil: `brew install gh`).

## 2. Cloud ortamı
- Cloud oturumunda yerel Mac dosyaları, iOS simülatörü, Xcode ve Keychain **yoktur**. Cloud işleri kod/test/doküman odaklıdır.
- Oturum başında `scripts/bootstrap.sh` çalıştırılır. Flutter yoksa script `BLOCKED` mesajı ve kurulum komutlarını basar.
- `flutter build web --release` cloud'da doğrulama için kullanılabilir; **iOS derlemesi değildir**.

## 3. Gece görevi (Routine / Scheduled Task)
1. `https://claude.ai/code/routines` (bazı arayüzlerde *Scheduled Tasks* / *Routines*) → **New task**.
2. Ortam: **Cloud**. Depo: `SwipeOut-Last-Train.`.
3. Zaman: her gün **01:07 (Türkiye saati, UTC+3)**.
4. Prompt (öneri):
   ```
   CLAUDE.md'deki okuma sırasını uygula (CLAUDE.md → GAME_DESIGN.md → TASKS.md → PROGRESS.md → docs/DECISIONS.md → git log -5).
   TASKS.md'deki en yüksek öncelikli, tamamlanmamış TEK küçük görevi seç.
   Önce testini yaz, kodla, scripts/check.sh çalıştır.
   TASKS.md ve PROGRESS.md'yi gerçek komut çıktılarıyla güncelle.
   claude/<konu> branch'ine commit et ve PR aç. main'e merge etme, force push yapma.
   Engel varsa PROGRESS.md'ye BLOCKED olarak yaz ve dur.
   ```
5. Kaydet → **Run now** ile bir kez dene → oluşan PR'ı incele.

## 4. Sınırlar
- Plan (ör. Max) kullanım limitleri gece görevini yarıda kesebilir; her gece büyük bir iş bitecek garantisi yoktur.
- Store'a yükleme, imzalama, ödeme, API anahtarı üretimi otomasyona **dahil değildir**.
- `--dangerously-skip-permissions` veya eşdeğer ayarlar kullanılmaz.
