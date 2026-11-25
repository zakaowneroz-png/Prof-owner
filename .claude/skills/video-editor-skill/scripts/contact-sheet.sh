#!/usr/bin/env bash
# Frames at given times → one labelled review image.
# Usage: bash contact-sheet.sh <video> <out.jpg> t1 t2 t3 …   (or --every 2.0 for one frame every 2 s)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/env.sh"
IN="${1:?usage: contact-sheet.sh <video> <out.jpg> t1 t2 … | --every N}"; OUT="${2:?out.jpg}"; shift 2
TMP="$(mktemp -d "${TMPDIR:-/tmp}/ves-sheet.XXXXXX")"; trap 'rm -rf "$TMP"' EXIT
if [ "${1:-}" = "--every" ]; then
  DUR="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$IN")"
  set -- $(python3 -c "import sys; d=float('$DUR'); s=float('$2'); print(' '.join(str(round(i*s,2)) for i in range(int((d-0.05)//s)+1)))")
fi
i=0
for t in "$@"; do i=$((i+1))
  ffmpeg -v error -y -ss "$t" -i "$IN" -frames:v 1 -vf "scale=360:-2" "$TMP/$(printf %03d $i).png"
done
n=$i; cols=$(( n < 5 ? n : 5 )); rows=$(( (n + cols - 1) / cols ))
ffmpeg -v error -y -pattern_type glob -i "$TMP/*.png" -vf "pad=iw+8:ih+8:4:4:color=0x222222,tile=${cols}x${rows}" -frames:v 1 "$OUT"
echo "sheet ($n frames at: $*) → $OUT"
