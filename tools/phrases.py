# energy-based phrase finder: split audio16k at pauses > GAP, print phrases
import wave, numpy as np, sys, json
w = wave.open(sys.argv[1]); sr = w.getframerate()
a = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16).astype(np.float32) / 32768
step = int(0.01 * sr); n = len(a) // step
rms = np.sqrt((a[:n*step].reshape(n, step) ** 2).mean(1)); db = 20 * np.log10(rms + 1e-9)
THR = float(sys.argv[2]) if len(sys.argv) > 2 else -40; GAP = float(sys.argv[3]) if len(sys.argv) > 3 else 0.45
on = db > THR; ph = []; i = 0
while i < n:
    if on[i]:
        j = i
        while j < n and on[j]: j += 1
        if ph and (i - ph[-1][1]) * 0.01 <= GAP: ph[-1][1] = j
        else: ph.append([i, j])
        i = j
    else: i += 1
ph = [[s*0.01, e*0.01] for s, e in ph if (e - s) * 0.01 >= 0.12]
json.dump(ph, open(sys.argv[4] if len(sys.argv) > 4 else 'phrases.json', 'w'))
for k, (s, e) in enumerate(ph): print(k, f"{s:.2f}-{e:.2f}", f"{e-s:.2f}")
print("noise floor p10:", np.percentile(db, 10), "speech p90:", np.percentile(db, 90))
