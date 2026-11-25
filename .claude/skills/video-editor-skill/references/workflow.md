# Phase 3: Editing a video, step by step

Nothing renders until the user has approved the plan and the stills. Each gate ends your turn.
Wait for their answer.

## 0. Intake

- Ask for the footage (path or drop it in `footage/`), plus any inserts, logos or screenshots.
  If it's a rough cut with their own transitions, inserts or effects already in it, find those
  first. Detect cuts with `analyze-reference.sh`, check frame differences around suspicious
  moments, and ask whether to keep, cover or replace them.
- Probe it: `ffprobe -v error -show_entries stream=width,height,r_frame_rate,codec_name:format=duration -of compact <file>`.
  Use the original 4K file as the source when there is one; never upscale a 1080p proxy for a
  4K final if the 4K exists.
- Create the project: `edits/<name>/` with `work/`, `comp/` (HyperFrames), `audio/`, `previews/`,
  `renders/`.

## 1. Plan preview (gate)

A few lines: length, structure (hook → points → CTA), which layouts and backgrounds from the
guideline, where the hero beats are (3D / explainer clip), and the overall feel. Ask: "Go ahead
with the breakdown?"

## 2. Script breakdown (gate)

1. Transcribe: `bash SKILL_DIR/scripts/transcribe.sh footage/x.mp4 edits/<name>/work --lang xx --prompt "<names, jargon>"`.
   Low-confidence words are listed. For dialects or mixed languages, run a second pass with a
   different model or prompt and compare. Proofread every word that will be shown, and mark the
   ones you're unsure of.
2. Split into paragraphs (one idea each) with start–end times. Write `edits/<name>/script.md`:
   paragraph · time · text · proposed graphic / layout / background / transition / engine.
3. Ask, per paragraph: **your idea, Auto (I decide), or no graphics?** Also ask for the engine
   (2D / 3D / Motion Canvas) where it matters. Best as an interactive form (a widget with a text
   box per paragraph), or AskUserQuestion in batches of 4. Also list the uncertain words for
   confirmation, music/SFX intent (if the guideline doesn't settle it) and how to handle any rough-
   cut effects. Treat unanswered items as Auto, and say so.

## 3. Build + stills (gate)

1. Scaffold the composition (see `hyperframes.md` → *Starting a project*). Vendor the libraries
   (`scripts/vendor.sh comp/assets/vendor`), copy fonts and tokens from `brand/`.
2. Build beat by beat from `script.md`. Pin every entrance to a word timestamp.
3. Snapshot one frame per beat, plus the middle of every transition:
   `npx hyperframes snapshot . --at 1.2,3.4,… --no-end --timeout 60000 -o ../previews/stills-v1`.
   Read the contact sheet yourself and fix everything on the craft checklist (`craft.md`) before
   showing anything.
4. Show the sheet (labelled by paragraph), ask: "Approve the stills, or send changes?" Apply notes
   and re-snapshot only the affected beats.

## 4. Draft render (gate)

- `npx hyperframes render . -o ../renders/<name>-draft-raw.mp4 --resolution portrait --fps 30 --quality looks`
  (1080p, about 3–5 min for a minute of video).
- Mix the audio as the guideline says (`scripts/mix.py`) and mux. Check frames at the beats and
  loudness, then send the draft. Ask: "Notes, or render the 4K final?"

## 5. Final

- `npx hyperframes render . -o ../renders/<name>-4k-raw.mp4 --resolution portrait-4k --quality delivery --fps 30`
  (the same 1080×1920 composition rendered at 2× pixel density → 2160×3840). Landscape:
  `landscape-4k`.
- Mux the mix: `ffmpeg -i raw.mp4 -i mix.wav -map 0:v -map 1:a -c:v copy -c:a aac -b:a 256k -shortest -movflags +faststart final.mp4`.
- Verify: ffprobe (size, duration, codecs), a contact sheet across the video, integrated loudness.
  Send the file. In the message, list what's done, what is still a guess (unconfirmed words), and
  where the extras are (stems, music name, SFX cue sheet).

## Revisions

- Small notes (a shadow, a colour, a timing): fix → snapshot the affected frames → re-render.
  Keep earlier deliveries; write new versions next to them (`-v2`), never overwrite a delivered
  file without asking.
- If a note is a lasting preference, add it to `brand/frame.md` (see creative-direction.md →
  *Keeping it alive*).
- Long renders run in the background. Tell the user roughly how long, and keep working on
  something else meanwhile.

## Paragraph proposal vocabulary (use the guideline's own names)

For each paragraph, propose concretely: layout (full footage / full-screen graphic / split / band /
behind-subject), background, the focal element (number, list, logo row, UI recreation, diagram,
3D object), its entrance, the transition out, the engine, and the hero word(s) that trigger each
move. One focal element per paragraph. Never put a graphic on screen before its word is said.
