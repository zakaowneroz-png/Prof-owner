# HyperFrames: how edits are built

HyperFrames renders an HTML page frame by frame in headless Chrome. It seeks a paused GSAP
timeline and captures each frame. Anything the page draws can be in the video: footage, DOM
text, SVG, canvas, three.js, alpha video clips. The official HyperFrames agent skills
(`/hyperframes…`, installed in Phase 1) document the CLI in depth. This file is the
**architecture that holds up on real edits**.

## Starting a project

```bash
cd edits/<name>
npx hyperframes init comp --example blank --resolution portrait --non-interactive --skip-transcribe
cp -R SKILL_DIR/assets/starter/. comp/            # index.html + assets/{kit,edit,captions}.js
bash SKILL_DIR/scripts/vendor.sh comp/assets/vendor
cp brand/tokens.css comp/assets/ ; cp -R brand/fonts comp/assets/fonts
ln footage/source.mp4 comp/assets/source.mp4      # hard link (or copy) — keep media inside the project
python3 SKILL_DIR/scripts/captions.py work/words.json > comp/assets/captions.js
cd comp && npx hyperframes lint && npx hyperframes snapshot . --at 1,3,5 --no-end -o ../previews/smoke
```

The starter already wires everything below. Edit `assets/edit.js` (scene math) and the layers in
`index.html`. Keep `hyperframes.json` / `meta.json` from `init`.

## The five rules of the architecture

1. **One paused root timeline.** `window.__timelines["main"] = gsap.timeline({paused:true})` with
   one proxy tween over the full duration, whose `onUpdate` calls `render(frame)`. HyperFrames
   seeks this timeline; nothing else drives time.
2. **The scene is a pure function of time.** `EDIT.sceneAt(frame)` returns plain numbers (positions,
   opacities, clip paths) for every element. `render()` only writes styles. No `Date`, no
   `Math.random` (use the seeded `mulberry32`), no CSS animations or transitions, no
   `requestAnimationFrame` loops. Snapshots then match renders exactly, and any frame can be
   checked alone.
3. **Media are declared, not played.** Every `<video>` has `data-start`, `data-duration` (seconds),
   and `muted` (except the one carrying the voice, which gets `data-has-audio="true"`). HyperFrames
   seeks them. Use the same `data-start` for footage and its cut-out so they stay frame-locked.
4. **Load before building.** Wait for `document.fonts.load(...)` for every face you use *before*
   creating caption DOM (text measured with a fallback font shifts later). Preload stills once;
   never create elements inside `render()`. Build pools up front and toggle `display`.
5. **Author at the base resolution** (1080×1920 for 9:16). `--resolution portrait-4k` renders the
   same page at 2× pixel density → 2160×3840. Canvas layers (three.js) should be sized 2160×3840
   so they stay crisp.

## Layer stack (back → front)

```
#cam (camera transform: punch-ins, zoom-blur pushes — scale/blur/transform-origin)
  backgrounds (dark / light / colour fields, rotated per scene)
  explainer clips (Motion Canvas alpha WebM)          ← behind the footage
  three.js canvas
  footage wrapper  → <video id="foot"> + dim overlay
  still wrapper    → <img> (freeze frames, light-leak covers)
  "behind" graphics (numbers, titles that sit behind the subject)
  cut-out wrapper  → <video id="subj"> (alpha WebM of the person)
  stage UI (cards, icons, connectors, particles)
captions (outside #cam so camera blur never softens them)
chips / lower thirds / end card
```

A new element that must stay *under* another needs its own stacking context
(`z-index:0` on its container). Otherwise children with z-index escape and draw on top.

## Placing footage: two modes

- **img mode**: the wrapper stays full-frame and gets a `clip-path`. The `<video>` inside is
  translated/scaled (`translate`, `scale`, origin 0 0). Use it for punch-ins, split screens
  (clip to a card shape), and iris / wipe reveals (clip-path polygon or inset).
- **wrap mode**: the whole wrapper is transformed: `translate · perspective · rotateY · rotate ·
  scale` around a centre, with a local `clip-path: inset(t r b l round R/s)`. Use it when the
  footage becomes an object: a 16:9 band, a card in a carousel, a card that flips in 3D. Lerp
  between two wrap states for morphs (band → card → full).

Keep both as data in `sceneAt` (`{mode:'img', img:{x,y,s}, clip}` /
`{mode:'wrap', wrap:{crop,c,at,s,rot,ry,rad,dim}}`). `render()` has one `place()` function.

## Transition recipes (all pure functions of t)

| Transition | Recipe |
|---|---|
| **Zoom-blur match cut** | `#cam` scale 1→1.9 + blur 0→26 px on easeInCubic over ~0.3 s into the cut. The next scene starts at scale 1.35 + blur 16 and settles on a spring (freq 1.4, damping 0.75). Put the next focal element where the face was. |
| **Shape iris** | footage clip-path = diamond/circle polygon from a point, radius 0→2600 px (easeInCubic, ~0.5 s). Draw an accent outline polygon on the edge (fade it out past r≈500). Start it from empty space, never inside a word, or it reads as a blob. |
| **Sheet rise** | footage `clip-path: inset(0 0 ${1920·p}px 0)` (the next background is revealed from the bottom up). The footage sinks back (scale 1→0.9, dim to 0.5, blur 6) with a soft shadow strip on the sheet edge. Start it after the outgoing caption has gone. |
| **Band / card morph** | lerp wrap params from full → band/card while a background colour floods in (opacity 0→1). |
| **Card flip** | wrap mode, `rotateY` −88°→0 on a calm spring, perspective 2200 px. |
| **Carousel** | live card in the centre, stills of other clips as side cards (z-index under the live card). On each cut in the inserted footage, slide all cards one slot. |
| **Light-leak / glitch cover** | when the source has its own effect you're asked to remove: freeze the clean frame just before it, as a still, through the effect, plus a quick zoom-blur cut into the clean frame after. |
| **Number roll** | a numeral inside an overflow-hidden matte translates up by one line height while the next rises in. |

Never use the same transition twice in a row. Each one gets a whoosh only if the guideline
wants SFX.

## Captions

- Build caption DOM once from `window.CAPTIONS` (`scripts/captions.py` output):
  `{l1:[words], t1:[starts], l2:[…], t2:[…], out}`. A `*` prefix marks an accent word (bigger,
  accent colour).
- Each word is its own `inline-block` span and animates on its own timestamp minus 2 frames
  (rise from below with blur, slide in the reading direction, or drop with a small squash).
- **Exit precompute**: each caption's exit must finish before the next caption's first word:
  ```js
  const firstOf = (c) => (c.t1.length ? c.t1[0] : c.t2[0]);
  const EXIT = CAPS.map((c, i) => {
    const next = CAPS[i + 1] ? firstOf(CAPS[i + 1]) - 2 / FPS - 0.02 : Infinity, last = c.t2.length ? c.t2.at(-1) : c.t1.at(-1);
    const a = Math.max(last + 0.2, Math.min(c.out, next - 0.24));
    return { a, b: Math.max(a + 0.16, Math.min(a + 0.3, next)) };
  });
  ```
- Zones: each layout has a caption top (full footage ≈ chest height, graphic scenes under the
  graphic, cards under the card). Choose per caption, not globally.
- Legibility: a tight dark edge (`text-shadow: 0 0 1.5px rgba(0,0,0,.95), 0 1px 3px rgba(0,0,0,.75)`)
  beats big soft shadows and radial scrims, which show as dark blobs on light clothing.
  Dark-on-light scenes use dark ink with no shadow.
- RTL: `direction: rtl` on the caption, every Latin word in `<span dir="ltr">`, animate per word,
  never letter-space.

## anime.js inside HyperFrames

```js
const atl = anime.createTimeline({ autoplay: false, defaults: { ease: "outCubic" } });
atl.add(".tool", { opacity: [0, 1], translateY: [60, 0], duration: 620, delay: anime.stagger(150) }, 50980); // ms, absolute
window.__hfAnime = window.__hfAnime || []; window.__hfAnime.push(atl);
```
v4 API: `anime.createTimeline`, `anime.animate`, `anime.stagger`, ease names like `"outCubic"`,
`"inOutCubic"`. The GSAP root timeline must still exist (the linter checks it). anime.js owns
those elements; don't also write their transform from `render()`.

## three.js inside HyperFrames

```html
<script type="importmap">{ "imports": { "three": "./assets/vendor/three/three.module.js", "three/addons/": "./assets/vendor/three/jsm/" } }</script>
<canvas id="three-layer" width="2160" height="3840" style="position:absolute;inset:0;width:1080px;height:1920px"></canvas>
<script type="module" src="assets/three-scene.js"></script>
```
```js
import * as THREE from "three";
const renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: true, preserveDrawingBuffer: true });
renderer.setPixelRatio(1); renderer.setSize(2160, 3840, false); renderer.setClearColor(0x000000, 0);
window.__hf = window.__hf || {}; window.__hf.buildReady = window.__hf.buildReady || {};
window.__hf.buildReady["my-3d"] = loadTextures().then(() => { ready = true; renderAt(window.__hfThreeTime || 0); });
window.addEventListener("hf-seek", (e) => renderAt(e.detail.time));   // render from HyperFrames time, never a clock
```
- Logos on 3D tiles: draw the SVG into a 512² canvas → `CanvasTexture` (colorSpace sRGB).
  Billboard tiles toward the camera (`quaternion.copy(camera.quaternion)`) so they read.
  Thin 3D lines: `TubeGeometry` with `setDrawRange` for draw-on, since `Line` widths are always 1 px.
- Show the canvas only inside its beats (toggle `display` from `render()`), and `renderer.clear()`
  when leaving.

## Pre-rendered clips (Motion Canvas, Remotion, AE exports)

Render with transparency → VP9 alpha WebM
(`-c:v libvpx-vp9 -pix_fmt yuva420p -metadata:s:v:0 alpha_mode=1`). Then
`<video src="assets/clip.webm" data-start="30.40" data-duration="7.633" muted playsinline>` in
the layer where it belongs. Show it only inside its window.

## Commands

```bash
npx hyperframes lint                     # structure checks (root timeline, media attributes)
npx hyperframes check                    # lint + runtime validation + layout inspection
npx hyperframes snapshot . --at 1.2,3.4 --no-end --timeout 60000 -o ../previews/x   # PNGs + contact-sheet.jpg
npx hyperframes render . -o ../renders/draft.mp4 --resolution portrait --fps 30 --quality looks
npx hyperframes render . -o ../renders/final.mp4 --resolution portrait-4k --fps 30 --quality delivery
npx hyperframes preview                  # studio in the browser for scrubbing
```
Pin the CLI version in `package.json` scripts once a project works (`npx hyperframes@x.y.z …`).

## Performance notes

- Precompute everything per-caption or per-path once (lookup tables for path points, exit times).
- Write a style only when it changes if the page is heavy. Pool particles and dots.
- 4K renders take roughly 4–6 min per minute of video on a recent laptop. Run them in the
  background.
