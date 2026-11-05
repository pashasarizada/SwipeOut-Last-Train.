# PROGRESS

## 2026-11-05 (2) — branch `claude/v2-night-pulse`

**Bağlam:** Kullanıcı V2.1 tasarım belgesini ekledi (NIGHT PULSE, graf, Paris). Plan: `docs/superpowers/plans/2026-11-05-v2-night-pulse-cekirdek.md`. Animasyon kararı: `flutter_animate` + `animations` (D-020). Flutter 3.32.8'de kalındı, Flame yok (D-019).

**Tamamlanan işler (V1–V12):**
- Izgara/swipe mekaniği ve İstanbul bölümleri tamamen kaldırıldı.
- Saf Dart graf modeli; `PulseEngine.simulatePulse` (tek kontrol + tüm trenler aynı anda; çarpışma, kafa kafaya, duran trene giriş, yanlış hedef → atomik iptal); makas pasif kol bekleme; kırmızı/yeşil sinyal.
- `GameSession` (undo makas/sinyal dahil, maxPulses kayıp), `PulseSolver` (BFS, üretimde hedef testi, durum sınırı).
- V2 JSON formatı + `ActionCodec` + `LevelValidator` (yapısal kurallar, kayıtlı çözüm replay'i, çözücü optimumu); `docs/LEVEL_FORMAT.md`.
- ANK-01 "İlk Sefer" (par 2) ve ANK-02 "Kızılay Yönü" (par 3), çözücüyle doğrulandı.
- `PulseController`, `NetworkPainter` + `TrainLayer` (400 ms eş zamanlı tween, ışık dalgası, çarpışma flaşı, arka plana geçince sona sarma).
- Ekranlar: ana menü, şehir seçimi (5 şehir, 4'ü "Yakında", OpenContainer), şehir bölümleri, oyun ekranı (HUD, bekleyen kontrol çipi, `▶ 1 DAKİKA İLERLET`, Geri Al/Baştan, geri düğmesi), sonuç sayfaları.
- Dokümanlar: `GAME_DESIGN_V2.md`, `ART_DIRECTION.md`, `SOURCE_MAPS_AND_LICENSES.md`, `DECISIONS.md` (V2 çatışmaları, D-015…D-020), `ARCHITECTURE.md`, `CLAUDE.md`, `TASKS.md`.

**Çalıştırılan komutlar ve gerçek sonuçları:**
- `scripts/check.sh` → format 69 dosya / 0 değişiklik · `flutter analyze`: No issues found! · `flutter test`: +109 All tests passed!
- `dart run tool/solve_levels.dart` → ANK-01 issues=0 optimal=2 par=2 · ANK-02 issues=0 optimal=3 par=3 · çıkış 0
- `flutter build web --release` → ✓ Built build/web
- `flutter build ios --simulator --debug` → ✓ Built Runner.app
- iOS Simülatör (iPhone 16e, iOS 26.4) elle: home → şehir → Ankara → ANK-01 uçtan uca → Next → ANK-02; iki görsel hata bulunup düzeltildi.

**Bilinen eksikler / blokerler:**
- İlerleme ve yarım pulse kaydı yok (V2-B, P1). "Devam Et" şimdilik ANK-01'i açar.
- Undo/Restart animasyonsuz (trenler zıplar).
- Fiziksel cihaz ve Android'de test edilmedi. Bundle id'ler geçici.
- Bu oturumda GitHub'a push yapılmadı.

**Sıradaki küçük görev:** V2-B planı → ANK-03 "İki Vagon" (iki tren eş zamanlı).

**Kullanıcıdan gereken onaylar:** `claude/bootstrap-swipeout` ve `claude/v2-night-pulse` branch'lerini push etmek; PR'ı web arayüzünden açmak.

---

## 2026-11-05 (1) — branch `claude/bootstrap-swipeout`

Izgara + swipe prototipi (V1 planı, artık yerini aldı). Ortam: Flutter 3.32.8, Dart 3.8.1, Xcode 26.4.1, `gh` yok, remote boş repo. Ayrıntı git geçmişinde.
