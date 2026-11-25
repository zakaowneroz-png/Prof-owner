# Shared environment for the Video Editor Skill scripts (source it, don't run it).
# Everything installs into the user's home: no sudo, no system folders.
export VES_HOME="${VES_HOME:-$HOME/.local/share/video-editor-skill}"
export NODE_HOME="${NODE_HOME:-$HOME/.local/share/node}"
export PATH="$VES_HOME/bin:$NODE_HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# Pinned versions (tested together). Override with env vars if you need newer ones.
export VES_GSAP="${VES_GSAP:-3.15.0}"
export VES_ANIME="${VES_ANIME:-4.5.0}"
export VES_THREE="${VES_THREE:-0.186.1}"
export VES_MOTION_CANVAS="${VES_MOTION_CANVAS:-3.17.2}"
export VES_HYPERFRAMES="${VES_HYPERFRAMES:-latest}"   # tested with 0.8.174

ves_os() { case "$(uname -s)" in Darwin) echo mac ;; Linux) echo linux ;; MINGW*|MSYS*|CYGWIN*) echo windows ;; *) echo other ;; esac; }
ves_arch() { case "$(uname -m)" in arm64|aarch64) echo arm64 ;; x86_64|amd64) echo x64 ;; *) uname -m ;; esac; }
ves_has() { command -v "$1" >/dev/null 2>&1; }
ves_apple_silicon() { [ "$(ves_os)" = mac ] && [ "$(ves_arch)" = arm64 ]; }
ves_skill_present() { # $1 = skill folder name prefix, looked up in the user's Claude skill / plugin folders
  ls -d "$HOME/.claude/skills/$1"* >/dev/null 2>&1 && return 0
  ls -d "$HOME/.claude/plugins/cache/"*/"$1"* >/dev/null 2>&1 && return 0
  return 1
}
