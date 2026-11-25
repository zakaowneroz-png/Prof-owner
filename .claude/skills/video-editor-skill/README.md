# Video Editor Skill — by OTHMANZR

A Claude skill that turns Claude into your video editor: captions timed to every word, motion
graphics, transitions, 3D moments and explainer animations, rendered up to 4K. It learns
**your** style from videos you like before it edits anything.

## What it does

1. **Sets everything up.** On first use it checks your computer and, with your OK, installs the
   tools it needs: HyperFrames, Remotion, Motion Canvas, GSAP, anime.js, three.js, ffmpeg, Whisper
   transcription and a subject cut-out tool. Everything goes into your home folder (no admin
   password).
2. **Builds your creative direction.** You upload your own videos, or videos you'd love to
   recreate, plus any photos or brand assets. It studies their pacing, captions, colours and
   transitions. It shows you a gallery of live examples, asks clear questions round by round, and
   writes **your brand guideline** (`brand/frame.md` + a visual brand book).
3. **Edits your videos with approval gates.** Every video goes:
   - plan
   - script breakdown, where you choose per paragraph: your idea, Auto, or no graphics
   - still previews
   - 1080p draft
   - 4K final

   Nothing renders before you approve.

## Install the skill

**Claude Code (terminal or the Code tab of the Claude desktop app). Recommended.** It needs a
terminal to install and run the tools:

```bash
mkdir -p ~/.claude/skills
unzip video-editor-skill.zip -d ~/.claude/skills/
```

Start a new Claude Code session in the folder where you keep your videos. Then say:

> Use the video editor skill, set me up.

**Claude.ai / desktop chat:** Settings → Capabilities → Skills → upload `video-editor-skill.zip`.
Chat can use the guidance and the style interview, but installing and rendering need Claude Code.

## Requirements

- macOS (Apple Silicon is best: fastest transcription and cut-out), Linux, or Windows (manual
  install steps in `references/setup.md`).
- ~5 GB free disk space for the tools and transcription models. A 4K render of a 1-minute video
  takes about 5 minutes on a recent laptop.

## What's inside

```
SKILL.md        what Claude follows (setup → creative direction → editing)
scripts/        installer, checker, transcription, captions, reference analysis, cut-out, mix, contact sheets
references/     detailed guides Claude reads when needed
assets/         brand guideline template, style-picker gallery, HyperFrames starter project
```

## Notes

- No API keys and no paid AI generation are part of this skill. If you want AI-generated
  b-roll or images, connect your own tool. Claude will ask before using it and confirm the cost.
- Music and sound effects: use your own licensed library, or ask for a voice-only master and
  add them in your own editor.
- Third-party tools keep their own licences (e.g. Remotion is free for individuals and
  companies of up to 3 people; GSAP is free under its standard licence).

Made by **OTHMANZR**.
