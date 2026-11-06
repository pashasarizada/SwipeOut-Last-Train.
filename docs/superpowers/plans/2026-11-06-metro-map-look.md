# Metro Haritası Görünümü — Uygulama Planı

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Tahtayı metro haritası diline çevirmek. İçerik dört parça: renkli hat şeritleri, 0°/45°/90° yollar, durak işaretleri ve hedef istasyon isimleri. Trenler ve oklar bu yolları izler.

**Architecture:** Yeni saf geometri katmanı `presentation/board` altında yer alır: `RailGeometry` (her ray için `dart:ui` Path + PathMetric) ve `MetroLines` (hatlara ayırma ve renk). Ray, tren, ok ve kapalı kol boşluğu tek bir yol kaynağını paylaşır. Bölüm mantığı ve düğüm konumları değişmez.

**Tech Stack:** Flutter 3.32.8 · CustomPainter · `dart:ui` Path/PathMetric · mevcut test altyapısı.

**Spec:** `docs/superpowers/specs/2026-11-06-metro-map-look-design.md`

## Global Constraints

- `domain` ve `engine` değişmez. Yeni kod yalnız `lib/game/presentation/board`, `city/city_theme.dart` ve `assets/levels/*.json` (yalnız `label`) içinde.
- Material yok, emoji yok. Dosya başına ~200 satır.
- Resmî hat renk düzenleri, logolar ve fontlar kullanılmaz. İsimler gerçek istasyon ya da semt adlarıdır, yalnız hedef düğümlerde bulunur ve Moskova için Latin harfle yazılır.
- Dokunma hedefleri (44 pt) ve `level_layout_test` değişmez.
- Her commit'ten önce `scripts/check.sh`; zincir `&&` ile, ardından `git push origin main`.

## Review Focus

1. Animasyon ortasında tren yolun üstünde kalmalı, düz çizgiye "kısa yol" atmamalı. Bu, yönü ve çarpışma sarsıntısını (lurch) da kapsar.
2. Makas dalları aynı yönde çıkıp üst üste binerse oyuncu makasın hangi yöne açık olduğunu göremez (D-030).
3. 320×568 ekranda etiket bir sinyal lambasını, hedef halkasını ya da makası örtmemeli.
4. High Contrast açıkken hat renkleri değil, beyaz kalın raylar çizilmeli.
5. Önizleme oku ve çarpı, yol eğilince doğru yere düşmeli. Çarpı, işgal edilmiş düğümün önünde ve yol üstünde olmalı.

---

### Task 1 — `RailGeometry`: metro açılı yollar

- **Create:** `lib/game/presentation/board/rail_geometry.dart`
- **Test:** `test/game/presentation/rail_geometry_test.dart`
- **Produces:**
  - `final class RailPath`, alanları:
    - `List<Offset> corners`: uçlar dahil köşe noktaları;
    - `Path path`: köşeleri 14 pt yarıçapla yuvarlatılmış;
    - `double length`;
    - `bool straightFallback`.
  - `RailPath` metotları:
    - `Offset pointAt(double distance)`;
    - `double headingAt(double distance)` (radyan, `headingOf` ile aynı kural);
    - `Path segment(double from, double to)`.
  - `final class RailGeometry`:
    - `RailGeometry(LevelDefinition level, BoardLayout layout)`;
    - `RailPath pathOf(String edgeId)`: `edge.a`'dan `edge.b`'ye;
    - `RailPath from(String nodeId, String edgeId)`: o düğümden başlayacak şekilde, gerekirse ters çevrilmiş;
    - `int get fallbackCount`;
    - `operator ==` ve `hashCode` (level + layout ile).
- **Algoritma:**
  - Adaylar sırasıyla: düz–çapraz–düz, çapraz–düz, düz–çapraz. Zaten 0°, 45° ya da 90° olan ray tek parça kalır.
  - Bir aday şu durumlarda reddedilir: ilk ya da son parçasının yönü, aynı düğümdeki daha önce kabul edilmiş bir rayın o düğümdeki çıkış yönüyle aynıysa; ya da köşe çizgisi, uç olmayan bir düğüme 20 pt'den fazla yaklaşıyorsa.
  - Raylar `level.edges` sırasıyla işlenir.
  - Hiçbir aday uymazsa tek düz parça kullanılır ve `straightFallback = true` olur.
- **Testler** (30 bölüm × 390×844, 375×667, 320×568):
  - `every segment is octilinear unless a straight fallback`;
  - `paths start and end on their nodes`;
  - `no two rails leave a node in the same direction`;
  - `paths keep 20 pt from other nodes`;
  - `fallbacks stay rare` (her bölümde `fallbackCount / edges ≤ 0.25`; aşılırsa test, bölüm adını basar);
  - `pointAt and headingAt follow the path` (çapraz–düz bir yolda orta nokta ve yön);
  - `from() reverses the path`.
- [ ] Testi yaz, kırmızıyı gör → uygula → yeşile çek → `scripts/check.sh` → commit `feat(board): octilinear rail geometry` → push.

### Task 2 — `MetroLines` ve şehir hat paleti

- **Create:** `lib/game/presentation/board/metro_lines.dart`
- **Modify:** `lib/game/presentation/city/city_theme.dart`: `final List<Color> lines`, şehir başına 3 renk; ilk ikisi mor–eflatun bandından ve şehre göre farklı, üçüncüsü sönük şehir tonu. Yanına "resmî düzen değil" notu düşülür.
- **Test:** `test/game/presentation/metro_lines_test.dart`
- **Produces:**
  - `final class MetroLines`, `MetroLines(LevelDefinition level, RailGeometry geometry)`;
  - `int lineOf(String edgeId)`, `int get lineCount`, `int colorOf(String edgeId)` (0..2).
- **Kurallar:**
  - İki raylı düğümde iki ray aynı hattır.
  - Makasta `trunkEdge`, düğümdeki çıkış yönü en az kırılan dalla aynı hattır.
  - Renk açgözlü boyamayla verilir: bir düğümde buluşan hatlardan farklı ilk renk.
- **Testler:**
  - `a switch trunk continues into its straightest branch`;
  - `lines meeting at a node have different colours` (30 bölüm);
  - `every level colours with three colours`;
  - `line palette contrasts 3:1 with the city background`;
  - `saturated line colours keep 30° hue from train, signal and preview colours`.
- [ ] TDD → check → commit `feat(board): metro lines and city line palettes` → push.

### Task 3 — Raylar, trenler ve oklar yolu izler

- **Modify:**
  - `network_painter.dart`: `geometry`, `lines` ve `theme` parametreleri;
  - `train_layer.dart`: `geometry` parametresi;
  - `forecast_painter.dart` + `forecast_marks.dart`: `geometry` parametresi;
  - `board_view.dart`: `RailGeometry` ve `MetroLines` yerleşim değişince bir kez kurulur ve aktarılır.
- **Çizim:**
  - Önce koyu kenar (`theme.background`, genişlik +4), sonra hat rengi (6 pt).
  - Kapalı kol: hat rengi, %35 opak, 4 pt; yolun makas ucundan `closedGap` (30) kadar kırpılır.
  - Seçili makasın yeni kolunda turkuaz parıltı yol boyunca çizilir.
  - Dakika dalgası, hat rengini `textPrimary`'ye doğru açar.
  - High Contrast: bugünkü `railStyle` beyaz/kalın renkleri kullanılır, yol yine metro açılıdır.
- **Tren:**
  - Hareket eden trenin konumu `geometry.from(from, edge).pointAt(t * length)`, yönü `headingAt` ile bulunur. `from`/`to` arasındaki ray, `level.edgesOf(from)` içinde `other == to` olan raydır.
  - Bekleyen trenin yönü, geldiği rayın düğüm ucundaki teğetidir.
  - Kafa kafaya takas sarsıntısı (lurch) ve teslimde küçülme bugünkü gibi kalır.
- **Ok:**
  - `arrowFor` artık yol üstünde `arrowFrom`/`arrowTo` oranlarındaki iki noktayı döndürür.
  - Şaft `segment()` ile çizilir, uç son teğete göre yönlenir.
  - `crossPoint`, işgal edilmiş düğümde yol boyunca `crossShift` kadar geride durur.
- **Testler:**
  - `board_view_test`: `trains stay on the rail path mid-pulse` (yarım ilerlemede tren merkezi `pointAt(length/2)`'ye 1 pt yakın);
  - `forecast arrow ends lie on the rail path`;
  - `closed arm gap is measured along the path`;
  - `high contrast draws white rails`.
  - Mevcut forecast, contrast, celebration ve screens testleri geçmeye devam etmeli.
- [ ] TDD → check → commit `feat(board): rails, trains and arrows follow metro paths` → push.

### Task 4 — Durak işaretleri ve hedef istasyon isimleri

- **Create:** `lib/game/presentation/board/station_labels.dart`
  - `StationLabels(level, geometry, layout, {required TextStyle style})`;
  - `Map<String, Rect> get placed`: düğüm kimliğinden etiket kutusuna.
- **Modify:**
  - `station_marks.dart`:
    - ara durak: dik çentik 10×4;
    - depo: hat renginde dolu yuvarlak kare (r 16, köşe 6);
    - `terminal`: dik tampon 14×5;
    - etiket çizimi; High Contrast'ta beyaz yazı ve koyu zemin.
  - `assets/levels/*.json`: her hedef düğüme `"label"`.
- **Etiket yerleşimi:**
  - Düğüm çevresinde 8 aday: sağ, sol, üst, alt, sonra köşeler; 6 pt boşluk.
  - Etiket, board karesi dışına taşıyamaz.
  - Kaçınılacak alanlar:
    - tüm düğümlerin 22 pt çevresi;
    - hedef parıltısı (r 29);
    - sinyal lambası kutusu (`signalLampOffset` çevresinde 18×26 + 4);
    - bekliyor rozeti yeri (`badgeOffset`, r 12);
    - ray yolları (6 pt kalınlık + 3);
    - önceden yerleşmiş etiketler.
  - Uyan yer yoksa etiket atlanır.
- **İsim verisi:** Gerçek istasyon ya da semt adları kullanılır.
  - Bölüm başlığında istasyon adı varsa, ilk hedefe o isim verilir.
  - Bir bölüm içinde tekrar olmaz.
  - Ankara: Kızılay, Batıkent, Çayyolu, Keçiören, AŞTİ, Dikimevi, Ulus, Sıhhiye, Koru, Törekent, Emek, Kolej…
  - Bakü: 28 May, İçərişəhər, Nərimanov, Gənclik, Sahil, Koroğlu, Memar Əcəmi, Nizami, Elmlər Akademiyası, Xətai, Avtovağzal, Dərnəgül…
  - Paris: Châtelet, République, Bastille, Gare du Nord, Nation, Opéra, Montparnasse, Pigalle, Odéon, Belleville…
  - Londra: Paddington, Angel, Bank, Euston, Victoria, Brixton, Camden Town, Moorgate, Holborn, Aldgate…
  - Moskova: Arbatskaya, Sokolniki, Kurskaya, Belorusskaya, Kievskaya, Taganskaya, Paveletskaya, Park Kultury, Lubyanka, Novoslobodskaya…
- **Testler:**
  - `level_assets_test`: `every goal has a station name, unique within its level`;
  - `station_labels_test`:
    - `labels stay inside the board and clear of nodes, signal heads, badges and each other` (30 bölüm × 3 ekran);
    - `at least 90% of labels are placed at 390×844`.
- [ ] TDD → check → commit `feat(board): metro stops and goal station names` → push.

### Task 5 — Simülatör, belgeler, inceleme

- Simülatörde ekran görüntüsü alınır ve `docs/images/v2-ux/19-…` adlarıyla kaydedilir:
  - Ankara 03, Bakü 02, Paris 04, Londra 03, Moskova 06;
  - bir High Contrast ekranı.
- Kayıtlar:
  - `DECISIONS.md`: D-036, metro haritası görünümü (renk kuralı, yalnız hedef isimleri, düğümler taşınmaz);
  - `SOURCE_MAPS_AND_LICENSES.md`: istasyon adı notu;
  - `PROGRESS.md` ve `TASKS.md`.
- `superpowers:requesting-code-review` ile bağımsız inceleme. Önemli bulgular RED→GREEN ile düzeltilir. Push.
