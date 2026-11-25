---
# Brand guideline: written by the Video Editor Skill from the user's references and interview.
# Replace every {{…}}. Delete any section the user opted out of. Values are px at the base resolution.
version: 1.0
status: "{{provisional | approved YYYY-MM-DD}}"
name: "{{Channel / brand name}}: video frame system"
description: >
  {{2–3 sentences: what the videos are, who they're for, and the feeling of the edit.}}
unit: "{{1080×1920 @ 30fps}}"          # base composition; 4K = same at 2× density
platforms: ["{{reels}}", "{{shorts}}", "{{tiktok}}"]
length: "{{30–60 s}}"
language: "{{en}}"                     # caption language(s)
direction: "{{ltr | rtl}}"
digits: "{{western | native}}"
principles:                            # 3–5, in the user's words where possible
  - "{{e.g. the person is always the anchor}}"
  - "{{e.g. every entrance lands on a spoken word}}"
  - "{{…}}"

colors:
  ground: "{{#0B0F15}}"                # base background, dark scenes
  surface: "{{#161C26}}"               # cards, panels
  line: "{{rgba(255,255,255,.12)}}"    # borders, dividers
  text: "{{#F4F5F7}}"                  # primary text
  text-2: "{{#A9B2C2}}"                # secondary text
  accent: "{{#…}}"                     # THE accent: emphasis words, highlights, active states
  accent-2: "{{#…}}"                   # lighter/softer accent (lines, glows)
  paper: "{{#F2F3F5}}"                 # light scenes (omit if never light)
  ink: "{{#1B2430}}"                   # text on light scenes
  rule: "{{e.g. never more than one saturated accent on screen}}"

backgrounds:                           # the worlds a scene can live in; rotate per scene
  footage: "{{the person's footage, untouched | light grade: …}}"
  dark: "{{gradient + texture}}"
  light: "{{paper + texture}}"
  color: "{{bold colour field for big moments}}"

typography:
  caption: { family: "{{Font}}", weight: {{700}}, size: {{72}}, lineHeight: {{1.25}}, case: "{{as spoken | UPPER}}" }
  caption-accent: { family: "{{Font}}", weight: {{800}}, size: {{104}}, color: "{{accent}}" }
  title: { family: "{{Font}}", weight: {{800}}, size: {{160}}, lineHeight: {{1.1}} }
  body: { family: "{{Font}}", weight: {{500}}, size: {{40}} }
  numbers: { family: "{{Font}}", weight: {{800}}, tabular: true }
  latin-in-rtl: "{{Latin words keep their own family at 0.9em, own ltr box}}"   # RTL only
  fonts-files: "brand/fonts/ ({{licence notes}})"

captions:
  style: "{{gallery number(s), e.g. C2 + C5}}"
  position: "{{chest-height centre (top ≈ 1110) | lower third | per layout}}"
  lines: "{{2 lines, 2–4 words each}}"
  emphasis: "{{1–2 key words per caption: bigger + accent colour}}"
  entrance: "{{rise from below with blur, 2 frames before each word}}"
  exit: "{{accelerate up + blur, always finished before the next caption}}"
  legibility: "{{tight dark edge: text-shadow 0 0 1.5px rgba(0,0,0,.95), 0 1px 3px rgba(0,0,0,.75); dark ink, no shadow on light scenes}}"
  never: "{{e.g. no big soft shadows, no boxes, no emojis}}"

motion:
  energy: "{{calm | balanced | punchy}}"
  ease-enter: "{{expo.out}}"
  ease-move: "{{power3.inOut}}"
  spring: "{{damping ≥ 0.8 (≤ 4% overshoot) | bouncy: damping 0.4}}"
  dur-enter: {{0.55}}
  dur-move: {{0.8}}
  word-lead: "2 frames before word start"
  camera: "{{slow drift + 2–4% punch-in on key words | locked}}"
  max-still: "{{0.6 s}}"

transitions:
  allowed: ["{{T1 zoom-blur match cut}}", "{{T3 shape iris}}", "{{…}}"]   # style-picker numbers + names
  never: ["{{…}}"]
  rule: "{{rotate; never the same twice in a row}}"
  speed: "{{0.3 | 0.5 | 0.8 s}}"
  sound: "{{whoosh on transitions | silent}}"

layouts:                               # allowed layouts and how often
  full: "{{DEFAULT: the person full-frame, captions at chest height}}"
  full-graphic: "{{full-screen graphic scene on a background, voice continues}}"
  split: "{{rare | never}}"
  band: "{{footage as a 16:9 band/card over a background, graphic above}}"
  behind-subject: "{{numbers/titles behind the person (needs cut-out): rare | never}}"
  pip: "{{picture-in-picture: …}}"

graphics:
  logos: "{{real brand logos when a tool/brand is named, in their own colours}}"
  icons: "{{line icons 2px | filled | none}}"
  containers: "{{rounded square | circle | diamond | squircle: rotate}}"
  numbers: "{{big numerals behind/next to the person when a number is spoken}}"
  lists: "{{one row per spoken item}}"
  3d: "{{never | 1–2 hero beats per video}}"
  particles: "{{only along connector lines / small burst on reveal | none}}"
  chapter-marker: "{{numbered chip top-right | none}}"
  end-card: "{{follow / save CTA | none}}"
  b-roll: "{{provided by user | recreated as graphics | none}}"

sound:
  deliver: "{{voice only (user adds music + SFX) | full mix}}"
  voice: "-14 LUFS integrated, true peak -1.5 dBTP"
  music: "{{genre/mood, source; bed ducked under voice}}"
  sfx: "{{density, palette}}"

workflow:
  gates: ["plan preview", "script breakdown (your idea / Auto / no graphics)", "stills", "1080p draft", "4K final"]
  delivery: "{{H.264 2160×3840 30fps, filename pattern}}"
  always: ["{{…}}"]
  never: ["{{…}}"]
---

# {{Brand name}}: frame system

## Overview
{{One paragraph: the world of these videos and what makes them recognisable. Cite the
references that shaped it (file + timestamp).}}

## Reference DNA
{{5–8 bullets from brand/reference-notes.md: the shared traits of the references the user liked.}}

## Captions
{{Prose version of the captions block, with one example caption written out (normal + accent words).}}

## Motion
{{How things arrive, move and leave; the camera; what "energy" means here in numbers.}}

## Transitions
{{Each allowed transition with when to use it. Note the ones that are banned and why.}}

## Layouts
{{Each layout with a small ASCII 9:16 wireframe and when to use it.}}

## Do / Don't
- Do: {{…}}
- Don't: {{…}}

## Decisions log
| Date | Decision | Why (user's words) |
|---|---|---|
| {{YYYY-MM-DD}} | {{e.g. captions: tight edge, no soft shadow}} | {{"the shadow shows on my white shirt"}} |
