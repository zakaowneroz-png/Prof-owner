#!/usr/bin/env bash
# Copy the pinned animation libraries into a project so compositions load them locally
# (never from a CDN at render time).
# Usage: bash vendor.sh <project>/assets/vendor [--no-three] [--no-anime]
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/env.sh"
DEST="${1:?usage: vendor.sh <dest-dir> [--no-three] [--no-anime]}"; shift || true
SRC="$VES_HOME/vendor"
[ -f "$SRC/VERSIONS.md" ] || { echo "vendor files missing; run: bash $HERE/install.sh vendor"; exit 1; }
THREE=1; ANIME=1
for a in "$@"; do case "$a" in --no-three) THREE=0 ;; --no-anime) ANIME=0 ;; esac; done
mkdir -p "$DEST"
cp "$SRC"/*.min.js "$SRC/VERSIONS.md" "$DEST/"
[ $ANIME = 1 ] || rm -f "$DEST/anime.umd.min.js"
[ $ANIME = 1 ] && cp "$SRC/anime.LICENSE.md" "$DEST/" 2>/dev/null || true
if [ $THREE = 1 ]; then rm -rf "$DEST/three"; cp -R "$SRC/three" "$DEST/three"; fi
echo "copied → $DEST"
echo 'three.js importmap: { "imports": { "three": "./assets/vendor/three/three.module.js", "three/addons/": "./assets/vendor/three/jsm/" } }'
