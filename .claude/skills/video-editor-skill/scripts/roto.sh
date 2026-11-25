#!/usr/bin/env bash
# Subject cut-out → VP9-alpha WebM that HyperFrames plays as a second <video> above "behind" graphics.
# Usage: bash roto.sh <in.mp4> <out.webm> [--masks DIR] [--windows "0-11.8,25-29"] [--erode N] [--crf 28]
#   --windows  only these time ranges keep the cut-out (everything else is blacked out → tiny file, faster)
#   --erode N  shrink the matte by N px (removes a coloured fringe picked up from the background)
# Matte: macOS Vision (cutout-video, ~0.05–0.1 s/frame at 4K) or rembg elsewhere (much slower).
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/env.sh"
IN="${1:?usage: roto.sh <in.mp4> <out.webm> [--masks DIR] [--windows a-b,c-d] [--erode N]}"; OUT="${2:?out.webm}"; shift 2
MASKS=""; WINDOWS=""; ERODE=0; CRF=28
while [ $# -gt 0 ]; do case "$1" in
  --masks) MASKS="$2"; shift 2 ;; --windows) WINDOWS="$2"; shift 2 ;; --erode) ERODE="$2"; shift 2 ;; --crf) CRF="$2"; shift 2 ;;
  *) echo "unknown option $1"; exit 2 ;; esac; done
MASKS="${MASKS:-$(dirname "$OUT")/masks}"
FPS="$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0 "$IN")"

if ! ls "$MASKS"/00001.png >/dev/null 2>&1; then
  mkdir -p "$MASKS"
  if [ -x "$VES_HOME/bin/cutout-video" ]; then "$VES_HOME/bin/cutout-video" "$IN" "$MASKS"
  elif ves_has rembg; then
    FR="$(dirname "$MASKS")/frames"; mkdir -p "$FR"
    ffmpeg -v error -y -i "$IN" "$FR/%05d.png"
    rembg p -om "$FR" "$MASKS"      # -om = write the mask only (check `rembg p --help` if flags changed)
  else echo "no cut-out tool; run: bash $HERE/install.sh cutout"; exit 1; fi
fi

# enable expression: inside any window → keep, outside → black (matte 0)
EN=""; ER=""
if [ -n "$WINDOWS" ]; then
  terms=""; IFS=',' read -ra W <<<"$WINDOWS"
  for w in "${W[@]}"; do a="${w%-*}"; b="${w#*-}"; terms="${terms:+$terms+}between(t,$a,$b)"; done
  EN="drawbox=enable='not($terms)':c=black:t=fill"
fi
for _ in $(seq 1 "$ERODE"); do ER="$ER,erosion"; done
# tmix smooths the per-frame matte (no flicker), the lut "chokes" the soft edge, gblur feathers it
# both branches restart at t=0: a source with an offset start time (e.g. a timecode track from a .mov) would
# otherwise pair every video frame with the last matte frame → an empty cut-out
MATTE="setpts=PTS-STARTPTS,format=gray,tmix=frames=3,lut=y='clip((val-56)*1.4,0,255)'$ER,gblur=sigma=0.6${EN:+,$EN}"
VID="setpts=PTS-STARTPTS${EN:+,$EN}"
ffmpeg -v error -y -i "$IN" -framerate "$FPS" -i "$MASKS/%05d.png" -dn \
  -filter_complex "[0:v]$VID[v];[1:v]$MATTE[m];[v][m]alphamerge,format=yuva420p[o]" \
  -map "[o]" -c:v libvpx-vp9 -pix_fmt yuva420p -b:v 0 -crf "$CRF" -row-mt 1 -tile-columns 2 -deadline good -cpu-used 5 \
  -metadata:s:v:0 alpha_mode=1 -an "$OUT"
echo "cut-out → $OUT  (play it muted, same data-start/duration as the footage, above the 'behind' layer)"
