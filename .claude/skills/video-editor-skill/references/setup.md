# Setup: installing the toolchain by hand, and troubleshooting

`scripts/install.sh` handles macOS and Linux automatically. This file is for Windows, for
locked-down machines, and for when one step fails.

## What gets installed, and why

| Key | Component | Why | Size |
|---|---|---|---|
| node | Node.js LTS (≥ 20) → `~/.local/share/node` | runs HyperFrames, Remotion, Motion Canvas, the skills installer | ~90 MB |
| ffmpeg | ffmpeg + ffprobe static builds → `~/.local/bin` | probing, cutting, encoding alpha clips, mixing, contact sheets | ~150 MB |
| uv | uv → `~/.local/bin` | installs the Python tools in isolated envs | ~30 MB |
| hyperframes | HyperFrames CLI (npm global) + headless Chrome | compose, snapshot and render the edits | ~250 MB |
| skills | official agent skills: HyperFrames, Remotion, GSAP | load in Claude's next session; deep docs for each engine | small |
| vendor | GSAP, anime.js, three.js pinned copies → `~/.local/share/video-editor-skill/vendor` | loaded locally in compositions (no CDN at render time) | ~40 MB |
| transcribe | mlx-whisper (+ parakeet-mlx) on Apple Silicon, whisper-ctranslate2 elsewhere | word-level timestamps for captions and beat timing | tools ~200 MB, model 1.5–3 GB on first use |
| cutout | macOS: Vision cut-out tool compiled with swiftc · others: rembg | person mattes for text-behind-subject | small / ~200 MB |

Motion Canvas and Remotion are not installed globally. They are scaffolded inside a project
when a video needs them (see their guides).

## Windows (PowerShell)

```powershell
winget install OpenJS.NodeJS.LTS
winget install Gyan.FFmpeg
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
npm install -g hyperframes
hyperframes browser ensure
npx -y skills@latest add heygen-com/hyperframes --all -g -a claude-code -y
npx -y skills@latest add remotion-dev/skills --all -g -a claude-code -y
npx -y skills@latest add greensock/gsap-skills --all -g -a claude-code -y
uv tool install whisper-ctranslate2 --python 3.12
uv tool install "rembg[cpu,cli]" --python 3.12      # optional cut-out
```
Then run the bash scripts with Git Bash or WSL (`bash scripts/doctor.sh`). If neither is
available, run the equivalent ffmpeg commands directly. For the vendor files:
`npm pack gsap@3.15.0 animejs@4.5.0 three@0.186.1`, then extract and copy the files listed in
`install.sh` → `install_vendor`.

## macOS notes

- No Homebrew needed. If the user has Homebrew and prefers it, `brew install node ffmpeg uv` is
  fine. The scripts find tools on PATH.
- The cut-out tool needs the Xcode Command Line Tools (`xcode-select --install`, a one-time ~1 GB
  download that opens a system dialog the **user** must confirm) and macOS 14 or newer.
- mlx-whisper / parakeet-mlx need Apple Silicon (M1 or newer). Intel Macs use
  whisper-ctranslate2.

## Linux notes

- Static ffmpeg from johnvansickle.com (x64 and arm64). The headless Chrome that HyperFrames
  downloads needs the usual shared libraries. On a minimal server, install
  `libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libasound2`
  with the system package manager. That needs sudo, so ask the user to run it.

## PATH

All scripts source `scripts/env.sh`, which prepends `~/.local/share/video-editor-skill/bin`,
`~/.local/share/node/bin` and `~/.local/bin`. `install.sh` adds one marked line
(`# video-editor-skill`) to the login profile (`~/.zprofile`, `~/.bash_profile` or `~/.bashrc`)
so new terminals see the tools. In Claude's Bash tool, prefix commands with
`source SKILL_DIR/scripts/env.sh &&` if a tool isn't found.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `hyperframes render` fails to launch Chrome | `hyperframes browser ensure --force`; on Linux install the libraries above |
| Fonts render as fallback in snapshots | font files must be inside the project (`assets/fonts`) and loaded with `document.fonts.load` before building DOM |
| `npm install -g` permission error | `install.sh` falls back to `--prefix ~/.local`; or use the user-space Node from `install.sh node` |
| Agent skills not visible | they load in the **next** Claude session; check `~/.claude/skills/` |
| `claude plugin install` unavailable | use `npx -y skills@latest add heygen-com/hyperframes --all -g -a claude-code -y` |
| mlx-whisper first run is slow | it downloads the model once (~3 GB for large-v3) |
| Wrong words in a dialect / mixed language | pass `--prompt` with names and dialect spellings; compare large-v3 against turbo; proofread by hand |
| zsh: a variable holding several args doesn't split | use `${=var}`, or run the script with bash |
| ffmpeg ≥ 8 says `-filter_complex_script` unknown | use `-/filter_complex file.txt` |
| drawtext with `:` in text breaks | escape colons (`\:`) or write the filter graph to a file from Python |
