---
version: 1.0
status: "provisional"
name: "Prof Zakaria Faykhi: video frame system"
description: >
  Bac lessons (Arabic, Islamic education, philosophy) explained in Moroccan Darija to Moroccan
  students, filmed at the studio desk. The edit should feel confident and expert:
  clear, warm, modern, never noisy.
unit: "1080×1920 @ 30fps"
platforms: ["instagram reels", "tiktok", "youtube shorts"]
length: "the full lesson, with silences and mistakes cut out (no hard target)"
language: "ar (Moroccan Darija), Arabic captions"
direction: "rtl"
digits: "western"
principles:
  - "The teacher is the anchor; graphics support the explanation, never replace the face for long."
  - "One idea, one yellow word: the highlighter marks the key term the way a student marks a notebook."
  - "Every entrance lands on a spoken word."
  - "Brand identity first, adapted to the studio's warm black, shelf green and wood."

colors:
  ground: "#0E0D0C"
  surface: "#173029"   # dark green cards, ~15% of frame
  green: "#1F3A33"
  line: "rgba(245,243,238,.14)"
  text: "#F5F3EE"
  text-2: "#A9A6A0"
  accent: "#FFC400"
  accent-2: "#FFD84D"
  paper: "#F5F3EE"
  ink: "#0B0B0C"
  rule: "one saturated accent only (yellow). No red, blue or extra colours. No emoji."

backgrounds:
  footage: "the studio footage, cinematic dark grade: deeper shadows, slightly reduced saturation, skin kept natural"
  dark: "flat #0E0D0C, optional #1F3A33 panel; no gradients, no texture"
  light: "paper #F5F3EE for a rare full-screen definition card"

typography:
  caption: { family: "Alexandria", weight: 800, size: 76, lineHeight: 1.3, case: "as spoken" }
  caption-accent: { family: "Alexandria", weight: 900, size: 92, color: "ink #0B0B0C on yellow box" }
  title: { family: "Alexandria", weight: 900, size: 120, lineHeight: 1.2 }
  body: { family: "IBM Plex Sans Arabic", weight: 600, size: 44 }
  numbers: { family: "Alexandria", weight: 900, tabular: true }
  latin-in-rtl: "Latin words (1ère BAC, 20/20) in their own dir=ltr box, Alexandria"
  fonts-files: "brand/fonts/ (Alexandria, IBM Plex Sans Arabic: SIL Open Font License)"

captions:
  style: "word by word + yellow highlighter on the key word"
  position: "chest height above the desk (top ≈ 1120 px)"
  lines: "1 line, 2–4 words"
  emphasis: "1 key word per caption: yellow #FFC400 box (radius 8) wipes in right→left behind it, word turns ink #0B0B0C"
  entrance: "each word pops in (scale .85→1, 0.18 s, back.out(1.4)) 2 frames before it is spoken"
  exit: "whole group fades up 12 px in 0.15 s, finished before the next group starts"
  legibility: "tight dark edge + small soft shadow (--cap-edge)"
  never: "no boxes, no big soft shadows, no emoji, no letter-spacing, never per-letter animation"
  fillers: "drop fillers (آ، إيه، يعني when filler)"

motion:
  energy: "balanced"
  ease-enter: "back.out(1.4)"
  ease-move: "power3.inOut"
  spring: "subtle: ≤ 6% overshoot"
  dur-enter: 0.35
  dur-move: 0.6
  word-lead: "2 frames before word start"
  camera: "punch-in zoom ~12% on each new idea (every 8–12 s), also hides jump cuts; ease power2.out 0.25 s"
  max-still: "12 s without a zoom change or graphic"

transitions:
  allowed: ["yellow highlighter wipe (signature)", "card slide (footage shrinks to a card and slides away to reveal a graphic scene)"]
  never: ["glitch", "light leaks", "spins"]
  rule: "alternate; never the same twice in a row; start between words, never inside one"
  speed: "0.45 s"
  sound: "soft whoosh on transitions"

layouts:
  full: "DEFAULT: teacher full frame, captions at chest height"
  cards: "step / term cards over the footage, top area (y 300–900) so the face and hands stay clear"
  full-graphic: "full-screen explanation scene on dark ground (like the carousel slides), voice continues"
  behind-subject: "big title behind the teacher (needs cut-out): 1–2 times per video"
  explain: "teacher footage as a rounded card in the TOP half (x 72–1008, y 330–870, captions on the chest inside it), explanation below on black with green cards. Never move the teacher to the bottom."

graphics:
  icons: "line icons 2.5 px, paper white"
  containers: "rounded cards #1E1C1A radius 36, yellow chips for levels"
  lists: "one row per spoken item, numbered yellow chips"
  3d: "never"
  chapter-tabs: "row of numbered tabs at the top (1 الفرضية … 6 الأجوبة), active tab yellow"
  index-card: "after the hook: \"خطوة بخطوة\" card listing the 5 tips 01–05 (ref2)"
  annotations: "handwritten yellow scribbles (circle, arrow, underline) on key graphics (ref1)"
  kinetic-word: "one big word with yellow brush swoosh per video, e.g. «الجهوي» (ref3)"
  hook: "first 3 s: hook title with the yellow marker + level chip (e.g. 2ème BAC · اللغة العربية)"
  end-card: "احفظ وتابع + @zakaria.faykhi"
  b-roll: "none; recreated as graphics"

sound:
  deliver: "full mix"
  voice: "-14 LUFS integrated, true peak -1.5 dBTP, light denoise + EQ"
  music: "calm, focused bed (lo-fi / soft piano), ducked under voice; user supplies licensed track"
  sfx: "soft whoosh on transitions, light pop on cards; user supplies or approves files"

workflow:
  gates: ["plan preview", "script breakdown (your idea / Auto / no graphics)", "stills", "1080p draft", "final"]
  delivery: "H.264 1080×1920 30fps, renders/<slug>_v<n>.mp4"
  always: ["show options and let the user choose at every stage"]
  never: ["cover the face with graphics", "more than one yellow word on screen"]
---

# Prof Zakaria Faykhi: frame system

## Overview
Talking-head Bac lessons in Darija from a dark studio desk. The look extends the existing
visual identity (studio black, highlighter yellow, deep green, Alexandria titles) into motion:
the yellow highlighter stroke is the signature, on captions, hooks and the main transition.

## Captions
Word by word at chest height, Alexandria ExtraBold, paper white with a tight dark edge.
Example: «العلاقة بين **العنوان** والنص», where «العنوان» gets the yellow marker stroke.

## Motion
Balanced: quick pops with a slight bounce, smooth moves. The locked camera gets a 12% punch-in on
each new idea, which also hides the cuts where silences are removed.

## Transitions
- Highlighter wipe: a thick yellow stroke sweeps right→left and reveals the next scene.
- Card slide: the footage shrinks into a rounded card and slides out to reveal a graphic scene.
Alternate them; never the same one twice in a row.

## Layouts
```
 full          cards          graphic        behind
┌───────┐    ┌───────┐      ┌───────┐      ┌───────┐
│       │    │[1 ...]│      │ TITLE │      │ BIG ☺ │
│   ☺   │    │[2 ...]│      │ ▬▬▬▬  │      │ TXT|  │
│  /|\  │    │   ☺   │      │ • ... │      │  /|\  │
│ caps  │    │ caps  │      │ • ... │      │ caps  │
│═desk══│    │═desk══│      │       │      │═desk══│
└───────┘    └───────┘      └───────┘      └───────┘
```

## Do / Don't
- Do: one yellow word per caption; keep the face and hands clear; level chip in the hook.
- Don't: extra colours, emoji, glitch effects, per-letter Arabic animation.

## Decisions log
| Date | Decision | Why |
|---|---|---|
| 2026-11-25 | 9:16 reels, Arabic captions, educational/trust | round 1 |
| 2026-11-25 | Brand identity colours adapted to the studio | "استعن بهذه الهوية البصرية… غيير حسب الغرفة" |
| 2026-11-25 | Cinematic dark grade, flat clean graphics | round 2 |
| 2026-11-25 | Word-by-word + yellow marker, chest height, thin edge, 2–4 words | round 3 |
| 2026-11-25 | Punch-in zooms, balanced motion, marker wipe + card slide, full mix | round 4 |
| 2026-11-25 | Key word = full yellow box (stroke-under was unreadable on dark footage) | brand-book check |
| 2026-11-25 | From refs: chapter markers 01–05, index card, graphic-top/footage-bottom, circle PiP, yellow scribbles, kinetic word with swoosh | "استلهم من هذو" |
| 2026-11-25 | Cards/panels in dark green #173029 (~15%) | "اضف 15% من لون الأخضر الغامق" |
| 2026-11-25 | Explain layout = footage card on top half, black below; chapter tabs row | user mockup: "أفضل من أن تهبطني للتحت" |
| 2026-11-25 | Cut every pause and any no-speech opening | "أي فترة لا أتكلم فيها احذفها" |
| 2026-11-25 | Cards, full graphic scenes, text behind subject; hook + CTA; 1080p | round 5 |
