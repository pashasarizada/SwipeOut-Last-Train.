# Seviye Formatı (V2 — NIGHT PULSE)

Her seviye tek dosya: `assets/levels/<ID>.json` (örn. `ANK-01.json`). Sıra ve şehir bilgisi `assets/levels/index.json`'da. Çözümleme `LevelJsonCodec` (yalnız yapı), kural denetimi `LevelValidator` (kurallar + çözücü + kayıtlı çözüm replay'i).

## Örnek — ANK-01 "İlk Sefer"

```json
{
  "id": "ANK-01",
  "city": "ankara",
  "number": 1,
  "tutorial": true,
  "title": {"tr": "İlk Sefer", "en": "First Departure"},
  "maxPulses": 5,
  "parPulses": 2,
  "maxChangesPerPulse": 1,
  "nodes": [
    {"id": "A", "kind": "depot", "x": 0.13, "y": 0.50},
    {"id": "B", "kind": "switch", "x": 0.48, "y": 0.50},
    {"id": "C", "kind": "goal", "x": 0.84, "y": 0.25},
    {"id": "D", "kind": "terminal", "x": 0.84, "y": 0.76}
  ],
  "edges": [
    {"id": "AB", "a": "A", "b": "B"},
    {"id": "BC", "a": "B", "b": "C"},
    {"id": "BD", "a": "B", "b": "D"}
  ],
  "switches": [
    {"nodeId": "B", "trunkEdge": "AB", "branchAEdge": "BC", "branchBEdge": "BD", "selectedBranch": "B"}
  ],
  "signals": [],
  "trains": [
    {"id": "red_1", "startNode": "A", "goalNode": "C", "symbol": "circle", "style": "coral"}
  ],
  "tutorialSteps": [
    {"tr": "Trenler her dakikada bir durak ilerler.", "en": "Trains move one stop each minute."},
    {"tr": "Makası doğru raya çevir.", "en": "Switch to the correct track."}
  ],
  "solution": ["wait", "switch:B"]
}
```

## Alanlar

| Alan | Tip | Açıklama |
|---|---|---|
| `id` | string | `ANK-01` … `MOS-06` |
| `city` | `ankara` \| `baku` \| `paris` \| `london` \| `moscow` | |
| `number` | int | Şehir içi sıra (1–6) |
| `tutorial` | bool? | `true` → yıldız gösterilmez (varsayılan `false`) |
| `title` | `{tr, en}` | |
| `maxPulses` | int | Bu sayıda pulse içinde çözülmeli |
| `parPulses` | int | 3 ★ eşiği; `1 ≤ par ≤ max`, kayıtlı çözüm uzunluğuna eşit, çözücü optimumundan büyük olamaz |
| `maxChangesPerPulse` | int | Şimdilik hep 1 (okunur ama motor sabit 1 uygular) |
| `nodes` | liste | `id`, `kind`, `x`, `y` (0.0–1.0), `label?` |
| `edges` | liste | `id`, `a`, `b` — her kenar 1 pulse |
| `switches` | liste? | `nodeId`, `trunkEdge`, `branchAEdge`, `branchBEdge`, `selectedBranch` (`A`/`B`, varsayılan `A`) |
| `signals` | liste? | `nodeId`, `initial` (`red`/`green`, varsayılan `red`) |
| `trains` | liste | `id`, `startNode` (depot), `goalNode` (goal), `symbol` (`circle`/`triangle`/`square`/`diamond`), `style` (`coral`/`azure`/`lime`/`amber`) |
| `tutorialSteps` | liste? | `{tr, en}`, en fazla iki satır |
| `solution` | liste | Pulse başına bir adım: `wait` · `switch:<nodeId>` · `signal:<nodeId>` |

## Düğüm türleri ve hareket

| `kind` | Kenar sayısı | Davranış |
|---|---|---|
| `depot` | 1 | Tren başlangıcı; tek kenardan çıkar |
| `track` | 2 | Gelinen kenar dışındaki kenardan çıkar |
| `switch` | 3 | trunk → seçili kol; seçili kol → trunk; pasif koldan gelen bekler |
| `signal` | 2 | Kırmızıysa bekletir; yeşilse `track` gibi |
| `goal` | 1 | Kendi treni girerse teslim; başka tren girerse **yanlış hat** |
| `terminal` | 1 | Çıkmaz; tren orada kalır |

Trenler geri dönmez. Çarpışma (aynı düğüm), kafa kafaya geçiş, duran trene giriş ve yanlış hedef pulse'ı iptal eder (durum değişmez).

## Doğrulama (`LevelValidator`)

**Format hataları** (`LevelFormatException(levelId, message)`): eksik alan, yanlış tip, bilinmeyen `kind`/şehir/sembol/stil/sinyal, tekrar eden düğüm veya kenar id'si, geçersiz `selectedBranch`, bilinmeyen çözüm adımı.

**Yapısal kurallar** (biri bile varsa çözücü çalışmaz):
`duplicateId` (tren) · `unknownReference` · `positionOutOfRange` · `ambiguousTrack` (track/signal ≠ 2 kenar) · `badDegree` (depot/goal/terminal ≠ 1, switch ≠ 3) · `invalidSwitch` (switch kaydı yok / düğüm switch değil / 3 farklı ve bağlı kenar değil) · `signalOnNonSignalNode` · `trainNotOnDepot` · `goalNotGoalNode` · `sharedGoalOrStart` · `parExceedsMax`

**Çözüm kuralları:**
- `solutionFails` — kayıtlı çözüm replay'de başarısız bir pulse içeriyor, çözmüyor veya uzunluğu `parPulses` değil.
- `parAboveOptimum` — çözücü daha kısa çözüm buldu; `parPulses` düşürülmeli.
- `unsolvable` — çözücü `maxPulses` içinde çözüm yok dedi. Çözücü durum sınırına takılırsa hata **değildir**; kayıtlı çözüm kanıttır (D-017).

## Yeni seviye eklemek
1. `assets/levels/<ID>.json` yaz, `index.json`'da şehrin listesine ekle.
2. `dart run tool/solve_levels.dart` → optimum ve sorunlar; sorun varsa çıkış kodu 1.
3. `scripts/check.sh`.
