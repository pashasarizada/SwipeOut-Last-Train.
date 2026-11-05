# PROGRESS

## 2026-11-05 — branch `claude/bootstrap-swipeout`

**Ortam:** macOS (Darwin 25.6), Flutter 3.32.8 stable, Dart 3.8.1, Xcode 26.4.1. `gh` CLI kurulu değil. Remote `origin` = `https://github.com/pashasarizada/SwipeOut-Last-Train..git` (oturum başında boş repo).

**Tamamlanan işler (Faz 0 + Faz 1, T1–T12):**
- Flutter iskeleti (ios/android/web), portrait kilidi, TR/EN gen-l10n, lint ayarları, `scripts/check.sh`, `scripts/bootstrap.sh`.
- Saf Dart domain + engine: ray port kuralları, makas, teslim, sınırsız undo/restart, deterministik BFS çözücü (`maxStates` sınırlı), seviye doğrulayıcı.
- JSON seviye formatı + codec + `docs/LEVEL_FORMAT.md`; çözücüyle doğrulanmış Bölüm 1–3 (optimum 4 / 5 / 8); `tool/solve_levels.dart`.
- UI: ana ekran, bölüm listesi, oyun ekranı (HUD, öğretici, CustomPainter tahta, animasyonlu trenler, Undo/Restart/Hint), sonuç sayfası (yıldızlar).
- İpucu arka isolate'ta (`compute`) çalışır.
- Simülatör bulgusu üzerine düzeltme: giriş kilidi yalnız tren hareket ettiğinde (D-014).

**Çalıştırılan komutlar ve gerçek sonuçları:**
- `scripts/check.sh` → format: 63 dosya, 0 değişiklik · `flutter analyze`: No issues found! · `flutter test`: +99 All tests passed!
- `dart run tool/solve_levels.dart` → 3 bölüm, `issues=0`, çıkış kodu 0.
- `flutter build web --release` → ✓ Built build/web (iOS build değildir).
- `flutter build ios --simulator --debug` → ✓ Built Runner.app.
- iOS Simülatör (iPhone 16e, iOS 26.4) elle: ana ekran → bölüm listesi → Bölüm 1 uçtan uca (3 yıldız) → Next → Bölüm 2; ipucu halkası, ret mesajları, makas port kuralı gözlendi.

**Bilinen hatalar / blokerler:**
- İlerleme/yıldızlar henüz kaydedilmiyor; uygulama kapanınca yarım seviye geri yüklenmiyor (Faz 2, P1).
- Fiziksel iPhone'da ve Android'de test edilmedi.
- Bundle id'ler geçici: iOS `com.example.swipeoutLastTrain`, Android `com.example.swipeout_last_train`.

**Sıradaki küçük görev:** Faz 2 planı — önce `shared_preferences` ile ilerleme/yıldız kalıcılığı (P1), sonra bölüm 4–12.

**Kullanıcıdan gereken onaylar:**
- `claude/bootstrap-swipeout` branch'ini GitHub'a push etmek; PR'ı web arayüzünden açmak (veya `brew install gh`).
- Cloud/gece görevi için `docs/AUTOMATION_SETUP.md` adımları.
