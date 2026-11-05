# CLAUDE.md — SwipeOut: Last Train

## İletişim
- Kullanıcıyla **daima Türkçe** konuş: plan, ilerleme, hatalar, commit/PR özetleri.
- Kod tanımlayıcıları İngilizce ve anlamlı. Dokümanlar Türkçe.
- Oyundaki metinler yalnızca ARB dosyalarından gelir (`lib/l10n/app_en.arb`, `app_tr.arb`); sabit string yok.

## Her oturumun başında okuma sırası
1. `CLAUDE.md` (bu dosya)
2. `GAME_DESIGN.md`
3. `TASKS.md`
4. `PROGRESS.md`
5. `docs/DECISIONS.md`
6. `git log -5 --oneline`

Sonra en yüksek öncelikli **tek küçük görevi** seç, gerekiyorsa önce testini yaz, kodla, `scripts/check.sh` çalıştır, `TASKS.md` ve `PROGRESS.md`'yi güncelle, odaklı bir commit at.

## Komutlar
- Kalite kapısı: `scripts/check.sh` (format → analyze → test)
- Seviye doğrulama/optimum: `dart run tool/solve_levels.dart`
- Web derleme (iOS build değildir): `flutter build web --release`

## Mimari kuralları (SOLID / KISS / DRY)
- Katmanlar: `lib/game/domain` → `engine` → `data` → `ui`. Bağımlılık yalnız bu yönde.
- `domain` ve `engine` saf Dart: `package:flutter` veya `dart:ui` importu yasak (`test/architecture_test.dart` zorlar).
- Bağımlılıklar constructor ile verilir; service locator, global singleton yok.
- State management paketi yok: `ChangeNotifier` + `ListenableBuilder`.
- Varsayılan `final class`; varyantlar `sealed class`. Dosya başına tek sorumluluk, ~200 satırı geçen dosya bölünür.
- İzinli paketler: `flutter_localizations`, `intl`, dev: `flutter_lints`, `fake_async`. Yeni paket = `docs/DECISIONS.md`'ye gerekçe.

## Güvenlik sınırları
- `main`'e doğrudan commit/merge yok; her iş `claude/<konu>` branch'i. Force push yok.
- Gizli anahtar/token commit'leme veya stdout'a yazma yok.
- Store'a sürüm gönderme, ödeme, abonelik, API anahtarı üretme, veri silme — kullanıcı onayı olmadan asla.
- Firebase, sunucu, reklam, analytics, ağ isteği yok (MVP).
- `--dangerously-skip-permissions` veya güvenlik bariyerini kapatan ayar önerme.
- Kullanıcının başka projelerine (ör. HeirLoam) dokunma.

## Doğrulamadan iddia etme
"Testler geçti", "PR açıldı", "iOS derlendi" gibi cümleler ancak komut gerçekten çalıştırılıp çıktısı okunduktan sonra yazılır. Engel varsa `PROGRESS.md`'ye **BLOCKED** ve sebebiyle yazılır.
