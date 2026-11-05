# SwipeOut: Last Train

Gecenin son metro seferinde renkli trenleri birbirine çarptırmadan kendi renkli istasyonlarına ulaştırdığın, tek parmakla oynanan, sıra tabanlı (turn-based), offline bir bulmaca oyunu. Flutter ile iOS öncelikli, Android ve Web'de de çalışır.

## Çalıştırma

```bash
flutter pub get
flutter run
```

## Kalite kontrolü

```bash
scripts/check.sh
```

`dart format` + `flutter analyze` + `flutter test` sırayla çalışır; ilk hatada durur.

## Dokümanlar

- `CLAUDE.md` — geliştirme kuralları ve oturum akışı
- `GAME_DESIGN.md` — oyun kuralları
- `TASKS.md` / `PROGRESS.md` — iş listesi ve ilerleme kaydı
- `docs/ARCHITECTURE.md`, `docs/LEVEL_FORMAT.md`, `docs/DECISIONS.md`
