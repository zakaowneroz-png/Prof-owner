#!/usr/bin/env bash
# Study a reference video (or a folder of photos) for the creative-direction interview.
# Usage: bash analyze-reference.sh <video|image|folder> <outdir> [--scene 0.3]
# Writes to <outdir>:
#   info.txt          duration, size, fps, audio loudness, shot count, cuts/min, average shot length
#   shots.txt         timestamp of every detected cut
#   shots.jpg         contact sheet: one frame per shot (first 48 shots), labelled with its time
#   timeline.jpg      contact sheet: one frame every N s across the whole video (pacing at a glance)
#   palette.png       dominant colours as a swatch strip; palette.txt = hex + share of frame + accent candidates
#   frames/           full-size frames at each cut (zoom in on captions, transitions, graphics)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/env.sh"
IN="${1:?usage: analyze-reference.sh <video|image|folder> <outdir>}"; OUT="${2:?outdir}"; SCENE="0.3"
[ "${3:-}" = "--scene" ] && SCENE="${4:-0.3}"
mkdir -p "$OUT/frames"

# dominant colours with their share of the frame, from tiny RGB frames (no extra libraries):
# bins of 16 levels per channel → merge near-identical bins → top 10, accents = saturated colours ≥ 1 %
palette() { # $1 = ffmpeg input args (quoted string), $2 = outdir
  eval ffmpeg -v error $1 -vf "scale=48:-2" -f rawvideo -pix_fmt rgb24 - | python3 "$HERE/palette.py" "$2"
  ffmpeg -v error -y -i "$2/palette.ppm" "$2/palette.png" && rm -f "$2/palette.ppm"
}
tile() { # $1 = frame count → "COLSxROWS" (≤ 8 columns, no empty rows)
  local n="$1" c; c=$(( n < 8 ? (n < 1 ? 1 : n) : 8 )); echo "${c}x$(( (n + c - 1) / c ))"
}

# --- photos / image folders: palette + contact sheet only ---
if [ -d "$IN" ] || [[ "$IN" =~ \.(jpe?g|png|webp|heic)$ ]]; then
  LIST="$OUT/images.txt"; : > "$LIST"
  if [ -d "$IN" ]; then find "$IN" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort > "$LIST"; else echo "$IN" > "$LIST"; fi
  i=0; while read -r f; do i=$((i+1)); ffmpeg -v error -y -i "$f" -vf "scale=360:640:force_original_aspect_ratio=decrease,pad=360:640:(ow-iw)/2:(oh-ih)/2:color=0x111111" "$OUT/frames/img-$(printf %03d $i).jpg"; done < "$LIST"
  ffmpeg -v error -y -pattern_type glob -i "$OUT/frames/img-*.jpg" -vf "tile=$(tile "$i"):padding=6:color=0x222222" -frames:v 1 "$OUT/shots.jpg"
  P="$(palette "-pattern_type glob -i '$OUT/frames/img-*.jpg'" "$OUT")"
  { echo "images: $i"; echo "palette: $P"; grep accent "$OUT/palette.txt"; } | tee "$OUT/info.txt"
  exit 0
fi

# --- video ---
DUR="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$IN")"
VS="$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate -of csv=p=0 "$IN")"
ffmpeg -v info -i "$IN" -vf "select='gt(scene,$SCENE)',showinfo" -an -f null - 2>&1 | grep -o 'pts_time:[0-9.]*' | cut -d: -f2 > "$OUT/shots.txt" || true
N="$(wc -l < "$OUT/shots.txt" | tr -d ' ')"
python3 - "$DUR" "$N" "$OUT/shots.txt" > "$OUT/pace.txt" <<'PY'
import sys
dur, n = float(sys.argv[1]), int(sys.argv[2]); cuts = [float(x) for x in open(sys.argv[3]) if x.strip()]
edges = [0.0] + cuts + [dur]; lens = [b - a for a, b in zip(edges, edges[1:]) if b - a > 0.05]
print(f"shots {len(lens)} · cuts/min {60 * n / max(dur, 1):.1f} · avg shot {sum(lens) / len(lens):.2f}s · shortest {min(lens):.2f}s · longest {max(lens):.2f}s")
PY
LOUD="n/a"
if ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$IN" | grep -q .; then
  LOUD="$(ffmpeg -hide_banner -nostats -i "$IN" -vn -af ebur128 -f null - 2>&1 | awk '/Integrated loudness/{f=1} f&&/I:/{print $2" LUFS"; exit}')"
fi
{ echo "file: $IN"; echo "duration: ${DUR}s · video: $VS"; echo "loudness: $LOUD"; cat "$OUT/pace.txt"; } | tee "$OUT/info.txt"

# one frame per shot (just after each cut, so transitions show their landing frame), labelled
k=0; for t in 0 $(head -47 "$OUT/shots.txt"); do k=$((k+1)); tt="$(python3 -c "print(round(min($t+0.25,$DUR-0.05),2))")"
  ffmpeg -v error -y -ss "$tt" -i "$IN" -frames:v 1 -vf "scale=360:-2" "$OUT/frames/shot-$(printf %03d $k)-${tt}s.jpg"; done
ffmpeg -v error -y -pattern_type glob -i "$OUT/frames/shot-*.jpg" -vf "scale=240:-2,pad=iw+8:ih+8:4:4:color=0x222222,tile=$(tile "$k")" -frames:v 1 "$OUT/shots.jpg" || true
# evenly spaced timeline (pacing + caption rhythm)
STEP="$(python3 -c "print(max(0.5, round($DUR/40, 2)))")"
ffmpeg -v error -y -i "$IN" -vf "fps=1/$STEP,scale=200:-2,tile=8x5:padding=4:color=0x222222" -frames:v 1 "$OUT/timeline.jpg"
P="$(palette "-i '$IN' -r 1" "$OUT")"
{ echo "palette: $P"; grep accent "$OUT/palette.txt"; } | tee -a "$OUT/info.txt"
echo "timeline step: ${STEP}s (timeline.jpg)" >> "$OUT/info.txt"
echo "→ read $OUT/shots.jpg and $OUT/timeline.jpg; zoom into $OUT/frames/ for captions and transitions"
