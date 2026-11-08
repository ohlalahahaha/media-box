#!/usr/bin/env python3
"""YD-60s v3 music bed — ambient luxury pad, royalty-free (synthesized, no samples).
4-chord loop Am -> F -> C -> G, 1.2s equal-power crossfade between chords,
soft-attack pad envelope, gentle sub pulse, air layer. 16-bit 44.1k mono WAV.
Usage: python3 music-bed.py out.wav [duration_s]"""
import sys, wave, math

out_path = sys.argv[1]
DUR = float(sys.argv[2]) if len(sys.argv) > 2 else 58.5
SR = 44100

# chords as (root, fifth, octave, third) Hz — voicings kept low & warm
CHORDS = [
    (110.00, 164.81, 220.00, 261.63),  # Am: A2 E3 A3 C4
    (87.31, 130.81, 174.61, 220.00),   # F:  F2 C3 F3 A3
    (130.81, 196.00, 261.63, 329.63),  # C:  C3 G3 C4 E4
    (98.00, 146.83, 196.00, 246.94),   # G:  G2 D3 G3 B3
]
AMP = (0.16, 0.11, 0.08, 0.07)         # per-voice amplitude
XF = 1.2                               # crossfade seconds between chords
CH_LEN = 8.0                           # chord slot length
SWELL = 14.0                           # pad swell period (s)

def chord_at(t):
    """(chord_index, weight) with crossfade: returns list of (idx, w)."""
    pos = t % (len(CHORDS) * CH_LEN)
    i = int(pos / CH_LEN) % len(CHORDS)
    frac = (pos - i * CH_LEN) / CH_LEN
    nxt = (i + 1) % len(CHORDS)
    if frac > 1.0 - XF / CH_LEN:       # crossfade tail
        w = (frac - (1.0 - XF / CH_LEN)) / (XF / CH_LEN)
        return [(i, 1.0 - w), (nxt, w)]
    return [(i, 1.0)]

n = int(SR * DUR)
samples = bytearray(n * 2)
phase = 0.0
for k in range(n):
    t = k / SR
    v = 0.0
    for idx, w in chord_at(t):
        c = CHORDS[idx]
        for j, f in enumerate(c):
            v += w * AMP[j] * math.sin(2 * math.pi * f * t)
    # sub pulse: slow heartbeat at 0.33 Hz on root octave below
    pulse = max(0.0, math.sin(2 * math.pi * 0.33 * t)) ** 3
    v += 0.10 * pulse * math.sin(2 * math.pi * 55.0 * t)
    # evolving air: soft high partial with slow LFOs of different periods
    air_lfo = 0.5 + 0.5 * math.sin(2 * math.pi * t / 11.0)
    v += 0.020 * air_lfo * math.sin(2 * math.pi * 659.26 * t)
    # global swell + soft-attack envelope + gentle fade-out at tail
    sw = 0.72 + 0.28 * math.sin(2 * math.pi * t / SWELL)
    env = min(1.0, t / 3.0)
    tail = min(1.0, (DUR - t) / 3.5) if t > DUR - 3.5 else 1.0
    s = v * sw * env * tail
    s = max(-0.92, min(0.92, s))
    x = int(s * 32767)
    samples[2 * k] = x & 0xFF
    samples[2 * k + 1] = (x >> 8) & 0xFF

with wave.open(out_path, "wb") as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(bytes(samples))
print(f"music-bed: {out_path} {DUR}s written")
