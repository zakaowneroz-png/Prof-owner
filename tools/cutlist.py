# energy-based cuts at 10 ms. KEEP = chosen takes; inside them drop pauses > MAXGAP.
import wave, numpy as np, json, sys
KEEP = [(13.3,22.25,'P0 hook'),(27.0,30.75,'P0 مهارة'),(32.0,56.7,'P1 تعريف+مقدمة'),(69.5,73.9,'P1 تمهيد'),(77.5,89.45,'P1 إشكالية'),
 (95.0,108.2,'P2 العرض'),(135.85,144.7,'P2 الأسئلة'),(148.1,159.7,'P3 الدعم'),(165.2,167.1,'P3 مقارنة'),(207.7,219.3,'P4 الخاتمة'),
 (235.3,241.7,'P5 recap مقدمة'),(252.4,263.2,'P5 recap عرض'),(264.4,268.2,'P5 recap خاتمة'),(270.9,277.2,'P6 CTA')]
THR, STEP, MAXGAP, PAD = -40.0, 0.01, 0.16, 0.05
w = wave.open('work/audio16k.wav'); sr = w.getframerate()
A = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16).astype(np.float32)
def frames(a, b):
    x = A[int(a*sr):int(b*sr)]; k = int(STEP*sr); n = len(x)//k
    return 20*np.log10(np.sqrt((x[:n*k].reshape(n,k)**2).mean(1))/32768+1e-9)
out = []
for a, b, lab in KEEP:
    on = list(frames(a, b) > THR); runs, i = [], 0
    while i < len(on):
        j = i
        while j < len(on) and on[j] == on[i]: j += 1
        runs.append([on[i], i, j]); i = j
    for r in runs:
        if not r[0] and (r[2]-r[1])*STEP <= MAXGAP and r[1] > 0 and r[2] < len(on): r[0] = True
    sp = []
    for v, s, e in runs:
        if v:
            if sp and sp[-1][1] == s: sp[-1][1] = e
            else: sp.append([s, e])
    for s, e in sp:
        if (e-s)*STEP < 0.06: continue
        out.append([round(max(a, a+s*STEP-PAD),3), round(min(b, a+e*STEP+PAD),3), lab])
m = []
for s in out:
    if m and s[0] <= m[-1][1] + 0.001: m[-1][1] = max(m[-1][1], s[1])
    else: m.append(s)
# pass 2: split inside segments at softer pauses/breaths (< INNER dB for > MAXGAP)
INNER = -32.0; m2 = []
for s0, e0, lab in m:
    db = frames(s0, e0); on = db > INNER; cur = s0; i = 0
    while i < len(on):
        if not on[i]:
            j = i
            while j < len(on) and not on[j]: j += 1
            if (j-i)*STEP > MAXGAP and i > 0 and j < len(on):
                a = s0 + i*STEP + PAD; b = s0 + j*STEP - PAD
                if b - a > 0.04: m2.append([round(cur,3), round(a,3), lab]); cur = b
            i = j
        else: i += 1
    m2.append([round(cur,3), round(e0,3), lab])
m = [x for x in m2 if x[1]-x[0] >= 0.1]
json.dump(m, open('projects/tawsi3/cuts.json','w'), ensure_ascii=False)
t=0; marks={}
for s,e,l in m: marks.setdefault(l, round(t,2)); t += round((e-s)*30)/30
print(len(m), 'segments, total', round(t,2), 's'); print(marks)
