#!/usr/bin/env bash
# Video Editor Skill: check every component of the toolchain.
# Prints one line per component: OK / MISSING / OPTIONAL, with the install key for install.sh.
# Usage: bash doctor.sh [--json]
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/env.sh"

OS="$(ves_os)"; ARCH="$(ves_arch)"
rows=(); missing=()
row() { # status key name detail
  rows+=("$1|$2|$3|$4")
  [ "$1" = "MISSING" ] && missing+=("$2")
}
ver() { "$@" 2>/dev/null | head -1 | tr -d '\r'; }

# --- core runtimes ---
if ves_has node; then
  NV="$(node -v 2>/dev/null)"; major="${NV#v}"; major="${major%%.*}"
  if [ "${major:-0}" -ge 20 ]; then row OK node "Node.js" "$NV"; else row MISSING node "Node.js" "$NV found, need >= 20"; fi
else row MISSING node "Node.js" "not found"; fi

if ves_has ffmpeg && ves_has ffprobe; then row OK ffmpeg "ffmpeg + ffprobe" "$(ver ffmpeg -version | awk '{print $3}')"
else row MISSING ffmpeg "ffmpeg + ffprobe" "not found"; fi

if ves_has uv; then row OK uv "uv (Python tools)" "$(ver uv --version)"; else row MISSING uv "uv (Python tools)" "not found"; fi
if ves_has python3; then row OK python "Python 3" "$(ver python3 --version)"; else row MISSING uv "Python 3" "not found (install.sh uv provides one)"; fi

# --- HyperFrames + its render browser ---
if ves_has hyperframes; then
  row OK hyperframes "HyperFrames CLI" "$(ver hyperframes --version)"
  if hyperframes browser path >/dev/null 2>&1; then row OK hyperframes "Render browser (Chrome)" "$(hyperframes browser path 2>/dev/null | tail -1 | sed 's|.*/||')"
  else row MISSING hyperframes "Render browser (Chrome)" "run: hyperframes browser ensure"; fi
else row MISSING hyperframes "HyperFrames CLI" "not found"; fi

# --- agent skills (load in the next Claude session after install) ---
if ves_skill_present hyperframes || (ves_has claude && claude plugin list 2>/dev/null | grep -qi hyperframes); then row OK skills "HyperFrames agent skills" "installed"
else row MISSING skills "HyperFrames agent skills" "not found"; fi
if ves_skill_present remotion-; then row OK skills "Remotion agent skills" "$(ls -d "$HOME"/.claude/skills/remotion-* 2>/dev/null | wc -l | tr -d ' ') skills"
else row MISSING skills "Remotion agent skills" "not found"; fi
if ves_skill_present gsap-; then row OK skills "GSAP agent skills" "$(ls -d "$HOME"/.claude/skills/gsap-* 2>/dev/null | wc -l | tr -d ' ') skills"
else row MISSING skills "GSAP agent skills" "not found"; fi

# --- animation libraries, pinned copies ---
if [ -f "$VES_HOME/vendor/VERSIONS.md" ]; then row OK vendor "GSAP / anime.js / three.js files" "$VES_HOME/vendor"
else row MISSING vendor "GSAP / anime.js / three.js files" "not downloaded"; fi
row OK motioncanvas "Motion Canvas" "scaffolded per project with npm (needs Node)"
row OK remotion "Remotion" "scaffolded per project with npx create-video (needs Node)"

# --- transcription ---
if ves_has mlx_whisper; then row OK transcribe "Transcription (mlx-whisper)" "Apple Silicon"
elif ves_has whisper-ctranslate2; then row OK transcribe "Transcription (whisper-ctranslate2)" "CPU/GPU"
else row MISSING transcribe "Transcription (Whisper)" "not found"; fi
if ves_apple_silicon; then
  if ves_has parakeet-mlx; then row OK transcribe "English fast path (parakeet-mlx)" "installed"
  else row OPTIONAL transcribe "English fast path (parakeet-mlx)" "optional, English only"; fi
fi

# --- subject cut-out ---
if [ "$OS" = mac ]; then
  if [ -x "$VES_HOME/bin/cutout-video" ]; then row OK cutout "Subject cut-out (macOS Vision)" "$VES_HOME/bin/cutout-video"
  elif ves_has swiftc; then row MISSING cutout "Subject cut-out (macOS Vision)" "not built yet"
  else row MISSING cutout "Subject cut-out (macOS Vision)" "needs Xcode Command Line Tools: xcode-select --install"; fi
else
  if ves_has rembg; then row OK cutout "Subject cut-out (rembg)" "installed"; else row OPTIONAL cutout "Subject cut-out (rembg)" "optional, slower than macOS Vision"; fi
fi

if [ "${1:-}" = "--json" ]; then
  printf '{"os":"%s","arch":"%s","components":[' "$OS" "$ARCH"
  first=1
  for r in "${rows[@]}"; do IFS='|' read -r s k n d <<<"$r"; [ $first = 1 ] || printf ','; first=0
    printf '{"status":"%s","key":"%s","name":"%s","detail":"%s"}' "$s" "$k" "$n" "${d//\"/\'}"; done
  printf '],"missing":"%s"}\n' "$(printf '%s\n' "${missing[@]:-}" | sort -u | tr '\n' ' ' | sed 's/ *$//')"
  exit 0
fi

echo "Video Editor Skill: toolchain check ($OS/$ARCH)"
printf '%-8s %-13s %-38s %s\n' STATUS KEY COMPONENT DETAIL
for r in "${rows[@]}"; do IFS='|' read -r s k n d <<<"$r"; printf '%-8s %-13s %-38s %s\n' "$s" "$k" "$n" "$d"; done
keys="$(printf '%s\n' "${missing[@]:-}" | grep -v '^$' | sort -u | tr '\n' ' ' | sed 's/ *$//')"
if [ -n "$keys" ]; then echo; echo "Missing → bash $HERE/install.sh $keys"; exit 1; fi
echo; echo "Everything required is installed."
