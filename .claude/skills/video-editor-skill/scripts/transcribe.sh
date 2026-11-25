#!/usr/bin/env bash
# Word-level transcript of a video/audio file → <outdir>/words.json + transcript.txt + raw engine JSON.
# Usage: bash transcribe.sh <media> <outdir> [--lang xx] [--prompt "names, jargon, dialect words"] [--engine auto|mlx|ct2|parakeet] [--model …]
#   auto: Apple Silicon → mlx-whisper large-v3 (parakeet for English if --lang en and --engine parakeet)
#         elsewhere      → whisper-ctranslate2 large-v3
# words.json = [{"w": "word", "start": 1.23, "end": 1.50, "p": 0.91}, …]  (times in seconds)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/env.sh"
IN="${1:?usage: transcribe.sh <media> <outdir> [--lang xx] [--prompt …] [--engine …]}"; OUT="${2:?outdir}"; shift 2
LANG_CODE=""; PROMPT=""; ENGINE=auto; MODEL=""
while [ $# -gt 0 ]; do case "$1" in
  --lang) LANG_CODE="$2"; shift 2 ;; --prompt) PROMPT="$2"; shift 2 ;;
  --engine) ENGINE="$2"; shift 2 ;; --model) MODEL="$2"; shift 2 ;; *) echo "unknown option $1"; exit 2 ;; esac; done
mkdir -p "$OUT"
WAV="$OUT/audio16k.wav"
ffmpeg -v error -y -i "$IN" -vn -ac 1 -ar 16000 -c:a pcm_s16le "$WAV"

if [ "$ENGINE" = auto ]; then
  if ves_apple_silicon && ves_has mlx_whisper; then ENGINE=mlx
  elif ves_has whisper-ctranslate2; then ENGINE=ct2
  elif ves_has parakeet-mlx; then ENGINE=parakeet
  else echo "no transcription engine; run: bash $HERE/install.sh transcribe"; exit 1; fi
fi
echo "engine: $ENGINE"
case "$ENGINE" in
  mlx)
    args=(--model "${MODEL:-mlx-community/whisper-large-v3-mlx}" --word-timestamps True --output-format json --output-dir "$OUT" --output-name raw)
    [ -n "$LANG_CODE" ] && args+=(--language "$LANG_CODE"); [ -n "$PROMPT" ] && args+=(--initial-prompt "$PROMPT")
    mlx_whisper "$WAV" "${args[@]}" ;;
  ct2)
    args=(--model "${MODEL:-large-v3}" --word_timestamps True --output_format json --output_dir "$OUT")
    [ -n "$LANG_CODE" ] && args+=(--language "$LANG_CODE"); [ -n "$PROMPT" ] && args+=(--initial_prompt "$PROMPT")
    whisper-ctranslate2 "$WAV" "${args[@]}"; mv "$OUT/audio16k.json" "$OUT/raw.json" ;;
  parakeet)   # English only (no Arabic etc.); very fast on Apple Silicon
    parakeet-mlx "$WAV" --output-format json --output-dir "$OUT" ${MODEL:+--model "$MODEL"}; mv "$OUT/audio16k.json" "$OUT/raw.json" ;;
  *) echo "unknown engine $ENGINE"; exit 2 ;;
esac

python3 - "$OUT/raw.json" "$OUT" <<'PY'
import json, sys, os
raw, out = sys.argv[1], sys.argv[2]
d = json.load(open(raw, encoding="utf-8"))
words = []
if "segments" in d:                       # whisper family
    for s in d["segments"]:
        for w in s.get("words", []):
            t = w["word"].strip()
            if t: words.append({"w": t, "start": round(w["start"], 3), "end": round(w["end"], 3), "p": round(w.get("probability", 1.0), 3)})
elif "sentences" in d:                    # parakeet: sub-word tokens, a leading space starts a new word
    for s in d["sentences"]:
        for tok in s["tokens"]:
            txt = tok["text"]
            if txt.startswith(" ") or not words:
                if txt.strip(): words.append({"w": txt.strip(), "start": tok["start"], "end": tok["end"], "p": tok.get("confidence", 1.0)})
            else:
                words[-1]["w"] += txt; words[-1]["end"] = tok["end"]
json.dump(words, open(os.path.join(out, "words.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=0)
open(os.path.join(out, "transcript.txt"), "w", encoding="utf-8").write(" ".join(w["w"] for w in words) + "\n")
low = [w for w in words if w["p"] < 0.5]
print(f"{len(words)} words → {out}/words.json")
if low: print("low-confidence words to proofread:", ", ".join(f'{w["w"]}@{w["start"]}' for w in low[:40]))
PY
