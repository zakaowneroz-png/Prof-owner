#!/usr/bin/env bash
# Video Editor Skill: install the toolchain into the user's home folder (no sudo).
# Usage: bash install.sh [--dry-run] (--all | node ffmpeg uv hyperframes skills vendor transcribe cutout)
# Each key is idempotent: already-installed pieces are skipped. Run doctor.sh afterwards.
# VES_NO_PROFILE=1 skips adding the PATH line to the shell profile; VES_HOME=… installs elsewhere.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/env.sh"
OS="$(ves_os)"; ARCH="$(ves_arch)"
DRY=0; KEYS=()
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --all) KEYS=(node ffmpeg uv hyperframes skills vendor transcribe cutout) ;;
    node|ffmpeg|uv|hyperframes|skills|vendor|transcribe|cutout) KEYS+=("$a") ;;
    *) echo "unknown key: $a"; exit 2 ;;
  esac
done
[ ${#KEYS[@]} -gt 0 ] || { echo "usage: install.sh [--dry-run] --all | <keys…>"; exit 2; }
if [ "$OS" = windows ] || [ "$OS" = other ]; then
  echo "This installer covers macOS and Linux. On Windows follow references/setup.md (winget commands)."; exit 3
fi

say() { printf '\n▸ %s\n' "$*"; }
run() { if [ $DRY = 1 ]; then echo "  [dry-run] $*"; else eval "$@"; fi; }
TMP="$(mktemp -d "${TMPDIR:-/tmp}/ves-install.XXXXXX")"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$HOME/.local/bin" "$VES_HOME/bin"
sha256() { if ves_has shasum; then shasum -a 256 "$1" | awk '{print $1}'; else sha256sum "$1" | awk '{print $1}'; fi; }

add_to_profile() { # one PATH line, added once, in the login profile of the user's shell
  local line='export PATH="$HOME/.local/share/video-editor-skill/bin:$HOME/.local/share/node/bin:$HOME/.local/bin:$PATH"  # video-editor-skill'
  local prof
  case "${SHELL:-}" in */zsh) prof="$HOME/.zprofile" ;; */bash) prof="$HOME/.bash_profile"; [ "$OS" = linux ] && prof="$HOME/.bashrc" ;; *) prof="$HOME/.profile" ;; esac
  [ "${VES_NO_PROFILE:-0}" = 1 ] && return
  if ! grep -q 'video-editor-skill' "$prof" 2>/dev/null; then run "printf '%s\n' '$line' >> '$prof'"; [ $DRY = 1 ] || echo "  PATH line added to $prof (new terminals pick it up)"; fi
}

install_node() {
  if ves_has node && [ "$(node -v | sed 's/^v//; s/\..*//')" -ge 20 ]; then echo "  node $(node -v) already installed"; return; fi
  local V plat file
  V="$(curl -fsSL https://nodejs.org/dist/index.json | tr '{' '\n' | grep '"lts":"' | head -1 | sed -E 's/.*"version":"([^"]+)".*/\1/')"
  [ "$OS" = mac ] && plat="darwin" || plat="linux"
  file="node-$V-$plat-$ARCH.tar.gz"
  echo "  Node.js $V LTS → $NODE_HOME"
  run "curl -fsSL -o '$TMP/$file' 'https://nodejs.org/dist/$V/$file'"
  run "curl -fsSL -o '$TMP/SHASUMS256.txt' 'https://nodejs.org/dist/$V/SHASUMS256.txt'"
  if [ $DRY = 0 ]; then
    [ "$(sha256 "$TMP/$file")" = "$(grep " $file\$" "$TMP/SHASUMS256.txt" | awk '{print $1}')" ] || { echo "  checksum mismatch for $file"; exit 1; }
    rm -rf "$NODE_HOME"; mkdir -p "$NODE_HOME"; tar xzf "$TMP/$file" -C "$NODE_HOME" --strip-components 1
  fi
}

install_ffmpeg() {
  if ves_has ffmpeg && ves_has ffprobe; then echo "  ffmpeg already installed ($(command -v ffmpeg))"; return; fi
  if [ "$OS" = mac ]; then
    local a; [ "$ARCH" = arm64 ] && a=arm64 || a=amd64
    for b in ffmpeg ffprobe; do  # static builds by Martin Riedl (signed, notarized)
      run "curl -fsSL -o '$TMP/$b.zip' 'https://ffmpeg.martin-riedl.de/redirect/latest/macos/$a/release/$b.zip'"
      run "unzip -o -q '$TMP/$b.zip' -d '$TMP/$b' && install -m 755 '$TMP/$b/$b' '$HOME/.local/bin/$b'"
    done
  else
    local a; [ "$ARCH" = arm64 ] && a=arm64 || a=amd64
    run "curl -fsSL -o '$TMP/ff.tar.xz' 'https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-$a-static.tar.xz'"
    run "tar xJf '$TMP/ff.tar.xz' -C '$TMP' && install -m 755 \"\$(ls -d '$TMP'/ffmpeg-*-static)/ffmpeg\" \"\$(ls -d '$TMP'/ffmpeg-*-static)/ffprobe\" '$HOME/.local/bin/'"
  fi
}

install_uv() {
  if ves_has uv; then echo "  uv already installed"; return; fi
  run "curl -LsSf https://astral.sh/uv/install.sh | env INSTALLER_NO_MODIFY_PATH=1 sh"
}

npm_global() { # install a global npm package; falls back to ~/.local when the npm prefix isn't writable
  local prefix; prefix="$(npm config get prefix 2>/dev/null || echo /nonexistent)"
  if [ -w "$prefix" ] || [ -w "$prefix/lib" ]; then run "npm install -g $*"; else run "npm install -g --prefix '$HOME/.local' $*"; fi
}

install_hyperframes() {
  ves_has npm || { echo "  needs Node.js first (key: node)"; [ $DRY = 1 ] || exit 1; }
  if ves_has hyperframes; then echo "  hyperframes $(hyperframes --version 2>/dev/null | head -1) already installed"; else npm_global "hyperframes@$VES_HYPERFRAMES"; fi
  run "hyperframes browser ensure"   # downloads the headless Chrome used for rendering (~150 MB)
}

install_skills() {
  ves_has npx || { echo "  needs Node.js first (key: node)"; [ $DRY = 1 ] || exit 1; }
  if ves_skill_present hyperframes || (ves_has claude && claude plugin list 2>/dev/null | grep -qi hyperframes); then echo "  HyperFrames skills already installed"
  elif ves_has claude; then run "claude plugin marketplace add heygen-com/hyperframes && claude plugin install hyperframes@hyperframes"
  else run "npx -y skills@latest add heygen-com/hyperframes --all -g -a claude-code -y"; fi
  if ves_skill_present remotion-; then echo "  Remotion skills already installed"; else run "npx -y skills@latest add remotion-dev/skills --all -g -a claude-code -y"; fi
  if ves_skill_present gsap-; then echo "  GSAP skills already installed"; else run "npx -y skills@latest add greensock/gsap-skills --all -g -a claude-code -y"; fi
  echo "  (agent skills load in the next Claude session)"
}

install_vendor() {
  if [ -f "$VES_HOME/vendor/VERSIONS.md" ]; then echo "  vendor files already in $VES_HOME/vendor"; return; fi
  ves_has npm || { echo "  needs Node.js first (key: node)"; [ $DRY = 1 ] || exit 1; }
  run "cd '$TMP' && npm pack gsap@$VES_GSAP animejs@$VES_ANIME three@$VES_THREE --silent >/dev/null"
  [ $DRY = 1 ] && return
  local V="$VES_HOME/vendor"; rm -rf "$V"; mkdir -p "$V/three"
  for f in "$TMP"/*.tgz; do d="$TMP/x-$(basename "$f" .tgz)"; mkdir -p "$d"; tar xzf "$f" -C "$d"; done
  local G="$TMP/x-gsap-$VES_GSAP/package" A="$TMP/x-animejs-$VES_ANIME/package" T="$TMP/x-three-$VES_THREE/package"
  cp "$G"/dist/{gsap,SplitText,MorphSVGPlugin,DrawSVGPlugin,CustomEase,MotionPathPlugin,Flip,TextPlugin}.min.js "$V/"
  cp "$A/dist/bundles/anime.umd.min.js" "$V/"; cp "$A/LICENSE.md" "$V/anime.LICENSE.md" 2>/dev/null || true
  cp "$T/build/three.module.js" "$T/build/three.core.js" "$V/three/"; cp -R "$T/examples/jsm" "$V/three/jsm"; cp "$T/LICENSE" "$V/three/LICENSE"
  cat > "$V/VERSIONS.md" <<EOF
# Pinned animation libraries (copied by install.sh — do not edit)

| Library | Version | License | Files |
|---|---|---|---|
| GSAP | $VES_GSAP | GSAP Standard "no charge" license (all plugins free) | gsap.min.js + SplitText, MorphSVG, DrawSVG, CustomEase, MotionPath, Flip, Text |
| anime.js | $VES_ANIME | MIT | anime.umd.min.js (global \`anime\`: anime.animate / anime.createTimeline / anime.stagger) |
| three.js | $VES_THREE | MIT | three/three.module.js + three.core.js, three/jsm (addons) |

Copy into a project with: bash <skill>/scripts/vendor.sh <project>/assets/vendor
EOF
  echo "  vendor files → $V"
}

install_transcribe() {
  ves_has uv || { echo "  needs uv first (key: uv)"; [ $DRY = 1 ] || exit 1; }
  if ves_apple_silicon; then
    ves_has mlx_whisper || run "uv tool install mlx-whisper --python 3.12"
    ves_has parakeet-mlx || run "uv tool install parakeet-mlx --python 3.12"   # fast English path
  else
    ves_has whisper-ctranslate2 || run "uv tool install whisper-ctranslate2 --python 3.12"
  fi
  echo "  (the first transcription downloads the model, ~1.5–3 GB for large-v3)"
}

install_cutout() {
  if [ "$OS" = mac ]; then
    if [ -x "$VES_HOME/bin/cutout-video" ]; then echo "  cutout-video already built"; return; fi
    ves_has swiftc || { echo "  needs Xcode Command Line Tools: run  xcode-select --install  then re-run this key"; [ $DRY = 1 ] || exit 1; }
    run "swiftc -O '$HERE/cutout-video.swift' -o '$VES_HOME/bin/cutout-video'"
  else
    ves_has rembg || run "uv tool install 'rembg[cpu,cli]' --python 3.12"
  fi
}

for k in "${KEYS[@]}"; do
  say "$k"
  "install_$k"
  hash -r 2>/dev/null || true
done
add_to_profile
say "done. Run: bash $HERE/doctor.sh"
