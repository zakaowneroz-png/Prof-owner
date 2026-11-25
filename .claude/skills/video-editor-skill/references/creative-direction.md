# Phase 2: Creative direction (build the user's own brand guideline)

Goal: a written, approved `brand/frame.md` that describes **this user's** look and motion
precisely enough that every future edit follows it without asking again. You learn it from
their references and a structured interview. You never impose a house style. When the user
has no opinion, offer 2–3 concrete options taken from their references and recommend one.

Output files (project root):

```
references/                 what the user uploads (videos, photos, screenshots)
references/analysis/<name>/ analyze-reference.sh output per file
brand/reference-notes.md    what you observed, with timestamps (evidence for each decision)
brand/frame.md              the guideline (from assets/frame.template.md)
brand/tokens.css            colours / fonts / sizes as CSS variables (from assets/tokens.template.css)
brand/brand-book.html       one visual page: palette, type, caption mock, layouts, transitions
brand/fonts/                font files the user chose (with their licences)
```

## Step 1: Ask for references

Say what you need and why, in one message:

> To build your editing style I need examples. Drop them in the `references/` folder (or send
> paths):
> - **2–5 videos**: your own past videos, and/or videos by others whose editing you want to
>   recreate. Short clips are fine.
> - **Photos / screenshots** (optional): thumbnails, brand colours, fonts you like, a mood board.
> - For each one, a line on **what you like** (captions? transitions? colours? pacing?) and
>   anything you **don't** want.
> - If you have **brand assets** (logo, colour codes, font files), add those too.

If they have no references, skip to *Quick start* below, or ask them to name creators or channels
and describe the style in words. Don't download other people's videos yourself.

## Step 2: Study every reference

For each file: `bash SKILL_DIR/scripts/analyze-reference.sh references/<file> references/analysis/<name>`

Then look, don't guess: Read `shots.jpg`, `timeline.jpg` and a few full frames in `frames/`.
For videos, also transcribe a 20–30 s sample (`scripts/transcribe.sh`) to compare caption timing
with speech. Note in `brand/reference-notes.md`:

| Aspect | What to record (with timestamps) |
|---|---|
| Format | aspect ratio, resolution, length, fps; face-cam vs. voice-over vs. screen recording |
| Pacing | cuts/min, average shot length, jump cuts in the talking head, zoom punch-ins (how often, how much) |
| Captions | position (centre / chest / bottom), lines, words per line, font family style (serif / grotesk / rounded / handwritten), weight, case, size relative to frame, colour of normal vs. emphasis words, outline / shadow / box, animation (pop, word-by-word, karaoke highlight, slide), how they exit |
| Colour | palette.txt plus your read of it: dark / light / saturated, one accent or many, warm / cool; is the footage graded? |
| Graphics | full-screen graphic scenes, split screen, picture-in-picture, text behind the subject, numbers, icons/logos, UI recreations, emojis, stickers, b-roll inserts, 3D |
| Transitions | list each one with timestamp: hard cut, zoom/whip, wipe, iris/shape reveal, morph into a card, light leak, glitch, flip |
| Motion feel | snappy vs. smooth, bouncy vs. calm springs, camera always moving or locked |
| Sound | music genre/energy, loudness, SFX on every cut or rare, risers, silence used for punch |

Then summarise the **shared DNA** across references in 5–8 bullets, and list the conflicts you
spotted ("ref A has bottom karaoke captions, ref B big centred headlines: which one?").

## Step 3: Interview in rounds

Use the AskUserQuestion tool. Per round: at most 4 questions, 2–4 options each, the recommended
option first and marked "(Recommended)". "Other" lets them type anything. Use `preview` on options
to show a mini mock (ASCII layout, colour codes, a caption sample) wherever it helps. Ground every
question in the evidence ("Both refs cut every ~1.5 s…"). Skip questions the references already
answered beyond doubt, but **state** what you assumed so they can correct it.

Before rounds 3 and 5, open the live example gallery so they can point at numbers:
`cd SKILL_DIR/assets && python3 -m http.server 4410 --bind 127.0.0.1` (background), then open
`http://127.0.0.1:4410/style-picker.html` in the browser pane. It shows numbered transitions (T1…),
caption styles (C1…) and motion feels (M1…), each looping live.

**Round 1: Format & audience**
- Where it's posted and the main aspect ratio (9:16 reels/shorts · 16:9 YouTube · 1:1 · several)
- Typical length (≤30 s · 30–60 s · 1–3 min · long-form)
- Language(s) of speech and captions; right-to-left script? (Arabic, Hebrew, Persian, Urdu)
- Content type & audience (education, business, lifestyle, comedy…), and the feeling a viewer
  should leave with (trust / energy / calm / fun / premium)

**Round 2: Look & colour**
- Background world when the subject isn't on screen (dark stage · light paper · bold colour
  fields · keep it all footage)
- Palette: 2–3 options built from palette.txt and their brand colours (show hex chips in previews).
  Ask for one main accent; agree on "never more than one saturated accent on screen" or not.
- Footage treatment (untouched · light grade to match the palette · stylised)
- Texture (clean flat · subtle grid/dots · grain · gradients)

**Round 3: Typography & captions** (show the C-gallery)
- Caption style number(s) from the gallery, or "like ref X at 0:12"
- Position (chest-height centre · lower third · top · follows the layout)
- Emphasis: which words get the accent (1–2 key words per caption · every noun · none), and how
  (bigger · colour · highlight box · underline)
- Legibility treatment: thin outline/edge · soft shadow · background box · none. Warn that big
  soft shadows show as dark blobs on light clothing, and recommend a tight edge.
- Font family for captions and titles (offer 3 that fit; check language coverage; for RTL offer
  fonts that actually contain the script). Digits: Western or native?
- Words per line / lines per caption, and whether filler words are dropped

**Round 4: Motion feel** (show the M-gallery)
- Overall energy (calm · balanced · punchy)
- Springs (no overshoot · subtle · bouncy) for icons and text
- Camera (locked · slow drift · punch-in zooms on key words: how strong, how often)
- Is anything allowed to sit perfectly still? Max still time.

**Round 5: Transitions** (show the T-gallery)
- Which numbers they like (multi-select), and which they never want
- One signature transition used throughout, or rotate a set (recommend: rotate, never the same
  twice in a row)
- Speed (fast 0.3 s · normal 0.5 s · slow 0.8 s+)
- Should transitions carry sound (whoosh) or stay silent?

**Round 6: Graphics & layouts**
- Which layouts are allowed and how often: full footage · full-screen graphic scenes · split
  (graphic + footage) · footage band/card on a background · text/numbers behind the subject (needs
  cut-out) · picture-in-picture
- Icons & logos (real brand logos when a tool/brand is named · simple line icons · none)
- 3D (never · 1–2 hero moments per video · often)
- Lists, numbers, step badges, progress/chapter markers, call-to-action end card (follow / save /
  comment keyword)
- B-roll / inserts: provided by them, recreated as graphics, or none

**Round 7: Sound**
- Do you want music and SFX baked into the final, or delivered voice-only so you add them?
- If baked in: music mood/genre and source (their library account, royalty-free files they give
  you); SFX density (every transition · key moments only · none)
- Target loudness (default −14 LUFS for social)

**Round 8: Workflow & delivery**
- Approval gates (recommend: plan → script breakdown → stills → 1080p draft → 4K final)
- Final resolution and fps (1080p · 4K; 30 · 60 fps), file naming, and where finals go
- Anything that must always or never happen (e.g. "never cover my face", "always end on CTA")

After each round, reflect back a 2–3 line summary of what you understood before moving on.

## Step 4: Write the guideline

1. Copy `SKILL_DIR/assets/frame.template.md` to `brand/frame.md` and fill **every** token with a
   concrete value (hex codes, px sizes at the composition's base resolution, easing names, seconds).
   Replace every `{{…}}` placeholder, and delete sections they opted out of.
2. Copy `assets/tokens.template.css` to `brand/tokens.css` and fill it from the same values.
3. Fonts: ask the user to provide font files, or point them to the font's official download page
   and ask before downloading anything. Put them in `brand/fonts/` with their licence.
4. Build `brand/brand-book.html`, one scrollable page that shows:
   - palette chips
   - type scale
   - a caption mock over a still from their footage (normal and accent words)
   - each allowed layout as a small 9:16 wireframe
   - the chosen transitions by number
   - a do/don't list
   Serve it locally and open it in the browser pane.
5. Ask for approval: "Approve the guideline, or tell me what to change." Iterate. When approved,
   write `status: approved YYYY-MM-DD` in frame.md's front matter and `"brand": "brand/frame.md"`
   in `video-editor.json`.

## Quick start (no references, or "just start")

Offer one round of 4 questions: platform/aspect, energy (calm/balanced/punchy), light or dark
world, and caption style number from the gallery. Fill the template with neutral defaults:
- **Palette:** near-black ground `#0B0F15`, off-white text `#F4F5F7`, one accent of their choice.
- **Captions:** sans bold, 2 lines at chest height, 1–2 accent words.
- **Motion:** expo-out entrances, power3 moves, calm springs.
- **Transitions:** rotate zoom-blur match cut, shape iris and card morph.
Mark the guideline `status: provisional`. Refine it after the first video's notes.

## Keeping it alive

Every preference the user gives during edits ("captions too big", "no SFX", "I don't like
cut-outs for explainers") is a **rule**. Add it to `brand/frame.md` at once (with the date and the
reason) so it holds for every future video, and tell the user you saved it.
