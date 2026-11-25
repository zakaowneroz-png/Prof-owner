#!/usr/bin/env python3
"""Dominant colours from raw RGB24 pixels on stdin (used by analyze-reference.sh).
Writes <outdir>/palette.txt (hex + share of frame + accent candidates) and <outdir>/palette.ppm (swatch strip)."""
import sys, colorsys
data = sys.stdin.buffer.read(); out = sys.argv[1]; bins = {}
for i in range(0, len(data) - 2, 3):
    r, g, b = data[i], data[i + 1], data[i + 2]; k = (r >> 4, g >> 4, b >> 4)
    c = bins.setdefault(k, [0, 0, 0, 0]); c[0] += r; c[1] += g; c[2] += b; c[3] += 1
total = sum(c[3] for c in bins.values()) or 1
cols = sorted(([c[0] / c[3], c[1] / c[3], c[2] / c[3], c[3]] for c in bins.values()), key=lambda c: -c[3])
merged = []
for c in cols:
    for m in merged:
        if sum((m[i] - c[i]) ** 2 for i in range(3)) < 34 ** 2:
            n = m[3] + c[3]; m[:3] = [(m[i] * m[3] + c[i] * c[3]) / n for i in range(3)]; m[3] = n; break
    else: merged.append(c[:])
merged.sort(key=lambda c: -c[3])
hexs = lambda c: "#%02X%02X%02X" % tuple(int(round(v)) for v in c[:3])
top = merged[:10]
acc = [c for c in merged if c[3] / total >= 0.01 and colorsys.rgb_to_hsv(*[v / 255 for v in c[:3]])[1] > 0.45 and max(c[:3]) > 90][:4]
lines = [f"{hexs(c)} {100 * c[3] / total:.1f}%" for c in top]
open(f"{out}/palette.txt", "w").write("\n".join(lines) + "\naccent candidates: " + (" ".join(hexs(c) for c in acc) or "none") + "\n")
# swatch strip (PPM → PNG by the caller): width ∝ share
W, H = 800, 80; row = []
for c in top:
    w = max(8, int(W * c[3] / sum(t[3] for t in top))); row += [tuple(int(v) for v in c[:3])] * w
row = (row + [row[-1]] * W)[:W]
with open(f"{out}/palette.ppm", "wb") as f:
    f.write(b"P6 %d %d 255\n" % (W, H)); f.write(bytes(v for _ in range(H) for px in row for v in px))
print(" ".join(lines[:6]))
