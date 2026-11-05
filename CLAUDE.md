# CLAUDE.md — SwipeOut: Last Train

## İletişim
- Kullanıcıyla **daima Türkçe** konuş: plan, ilerleme, hatalar, commit/PR özetleri.
- Kod tanımlayıcıları İngilizce ve anlamlı. Dokümanlar Türkçe.
- Oyundaki metinler yalnızca ARB dosyalarından gelir (`lib/l10n/app_en.arb`, `app_tr.arb`); sabit string yok.

## Her oturumun başında okuma sırası
0. `docs/GAME_DESIGN_V2.md` — **bağlayıcı ürün tanımı (V2.1, NIGHT PULSE)**; eski belgelerle çelişirse bu geçerli
0b. `docs/UI_UX_GUIDELINES.md` — **bağlayıcı görsel/etkileşim kuralları**: Material/Flutter görünümü yok, emoji yok, şehir temaları, Metro Passport
1. `CLAUDE.md` (bu dosya)
2. `GAME_DESIGN.md` (V2 özeti)
3. `TASKS.md`
4. `PROGRESS.md`
5. `docs/DECISIONS.md`
6. `git log -5 --oneline`

Sonra en yüksek öncelikli **tek küçük görevi** seç, gerekiyorsa önce testini yaz, kodla, `scripts/check.sh` çalıştır, `TASKS.md` ve `PROGRESS.md`'yi güncelle, odaklı bir commit at ve `main`'e push et.

## Komutlar
- Kalite kapısı: `scripts/check.sh` (format → analyze → test)
- Seviye doğrulama/optimum: `dart run tool/solve_levels.dart`
- Web derleme (iOS build değildir): `flutter build web --release`

## Mimari kuralları (SOLID / KISS / DRY)
- Katmanlar: `lib/game/domain` → `engine` → `data` → `presentation`. Bağımlılık yalnız bu yönde.
- `domain` ve `engine` saf Dart: `package:flutter` veya `dart:ui` importu yasak (`test/architecture_test.dart` zorlar).
- Bağımlılıklar constructor ile verilir; service locator, global singleton yok.
- State management paketi yok: `ChangeNotifier` + `ListenableBuilder`.
- Varsayılan `final class`; varyantlar `sealed class`. Dosya başına tek sorumluluk, ~200 satırı geçen dosya bölünür.
- İzinli paketler: `flutter_localizations`, `intl`, `flutter_animate`, `animations`, dev: `flutter_lints`, `fake_async`. Flame yok (D-019). Yeni paket = `docs/DECISIONS.md`'ye gerekçe.
- Tahta animasyonları yalnız `AnimationController` + `CustomPainter`; iş mantığı animasyondan bağımsız saf Dart.

## UI kuralları (özet — tamamı `docs/UI_UX_GUIDELINES.md`)
- Oyuncuya görünen ekranlarda `AppBar`, `ListTile`, `Filled/Outlined/TextButton`, `Chip`, varsayılan bottom sheet/dialog/snackbar, ripple, sistem fontu **kullanılmaz**; oyun UI kiti (`GameButton`, `AdvanceLever`, `DepartureBoard`, `ControlTicket`, `SignalBackButton`…) kullanılır.
- **Emoji yok.** Trenler, ikonlar, damgalar kendi çizimimiz.
- Her şehir ekranı kendi `CityTheme`'ini (palet, desen, silüet, ortam, selamlama) gösterir.
- Resmî metro logoları, hat renk düzenleri, resmî fontlar/anonslar ve Eyfel gece ışık gösterisi yasak.
- Her yeni ekran iOS simülatörde ekran görüntüsüyle doğrulanır.

## Güvenlik sınırları
- Tek branch: `main` (D-028). Her küçük iş odaklı bir commit; `scripts/check.sh` geçmeden commit yok. Commit sonrası doğrudan `git push origin main` (kullanıcı kalıcı onay verdi). Force push, history yeniden yazma, branch silme yok.
- Gizli anahtar/token commit'leme veya stdout'a yazma yok.
- Store'a sürüm gönderme, ödeme, abonelik, API anahtarı üretme, veri silme — kullanıcı onayı olmadan asla.
- Firebase, sunucu, reklam, analytics, ağ isteği yok (MVP).
- `--dangerously-skip-permissions` veya güvenlik bariyerini kapatan ayar önerme.
- Kullanıcının başka projelerine (ör. HeirLoam, meet2be-app) dokunma; global Flutter'ı yükseltme (D-019).
- Resmî metro haritası/logo/font/anons kopyalama (bkz. `docs/SOURCE_MAPS_AND_LICENSES.md`).

## Doğrulamadan iddia etme
"Testler geçti", "PR açıldı", "iOS derlendi" gibi cümleler ancak komut gerçekten çalıştırılıp çıktısı okunduktan sonra yazılır. Engel varsa `PROGRESS.md`'ye **BLOCKED** ve sebebiyle yazılır.
