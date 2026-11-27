import json, sys, numpy as np, wave
from faster_whisper import WhisperModel
w = wave.open(sys.argv[1]); sr = w.getframerate()
a = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16).astype(np.float32) / 32768
ph = json.load(open(sys.argv[2]))
m = WhisperModel("large-v3", device="cpu", compute_type="int8", cpu_threads=4)
out = []
for k, (s, e) in enumerate(ph):
    seg = a[max(0, int((s - 0.15) * sr)):int((e + 0.15) * sr)]
    r, _ = m.transcribe(seg, language="ar", word_timestamps=True, condition_on_previous_text=False, vad_filter=False, beam_size=5)
    words = [{"w": x.word.strip(), "s": round(x.start + s - 0.15, 2), "e": round(x.end + s - 0.15, 2)} for sg in r for x in sg.words]
    txt = " ".join(x["w"] for x in words)
    out.append({"k": k, "s": s, "e": e, "text": txt, "words": words}); print(k, f"{s:.2f}-{e:.2f}", txt, flush=True)
json.dump(out, open(sys.argv[3], "w"), ensure_ascii=False, indent=0)
