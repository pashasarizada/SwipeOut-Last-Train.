"""Synthesises the game's original sound effects (no samples, no recordings).

Run: python3 tool/make_sounds.py  ->  assets/sounds/*.wav (22.05 kHz mono).
Every sound is built from sine/square waves and seeded noise, so the files
are our own work (docs/SOURCE_MAPS_AND_LICENSES.md).
"""
import math
import random
import struct
import wave
from pathlib import Path

RATE = 22050
OUT = Path(__file__).resolve().parent.parent / "assets" / "sounds"


def tone(freq, dur, amp=0.5, decay=8.0, shape="sine"):
    n = int(RATE * dur)
    out = []
    for i in range(n):
        t = i / RATE
        phase = 2 * math.pi * freq * t
        v = math.sin(phase) if shape == "sine" else (1.0 if math.sin(phase) >= 0 else -1.0)
        attack = min(1.0, i / (RATE * 0.004))
        out.append(amp * v * attack * math.exp(-decay * t))
    return out


def noise(dur, amp=0.4, decay=40.0, seed=1):
    rnd = random.Random(seed)
    n = int(RATE * dur)
    return [amp * (rnd.random() * 2 - 1) * math.exp(-decay * i / RATE) for i in range(n)]


def mix(*parts):
    n = max(len(p) for p in parts)
    return [sum(p[i] for p in parts if i < len(p)) for i in range(n)]


def seq(*parts, gap=0.0):
    out = []
    for p in parts:
        out += p + [0.0] * int(RATE * gap)
    return out


def write(name, samples):
    peak = max(1e-9, max(abs(s) for s in samples))
    scale = 0.8 / peak if peak > 0.8 else 1.0
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / f"{name}.wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(
            struct.pack("<h", int(max(-1, min(1, s * scale)) * 32767)) for s in samples
        ))


# Switch: a short metal "klak" — noise click over a low knock.
write("switch_clack", mix(noise(0.05, 0.5, 70, seed=3), tone(180, 0.07, 0.5, 45)))
# Pulse: a soft clock tick.
write("pulse_tick", mix(tone(1600, 0.035, 0.35, 90), noise(0.02, 0.15, 150, seed=5)))
# Delivery: a bright two-note chime.
write("delivery", mix(tone(880, 0.35, 0.35, 9), tone(1320, 0.35, 0.25, 11)))
# Crash: a low square buzz.
write("crash", mix(tone(98, 0.22, 0.35, 10, "square"), noise(0.08, 0.25, 30, seed=7)))
# Level won: a rising four-note arpeggio.
write("level_won", seq(*(tone(f, 0.16, 0.4, 7) for f in (523, 659, 784)), tone(1046, 0.4, 0.45, 5)))
# Stamp: a felt "thud".
write("stamp", mix(tone(80, 0.18, 0.6, 20), noise(0.06, 0.3, 50, seed=9)))
