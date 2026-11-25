# Motion Canvas: explainer clips

Motion Canvas (TypeScript, generator-based) is the best engine for **standalone explainer
clips**: equations, diagrams, flowcharts, code walkthroughs, process animations. You render the
clip with transparency and drop it into the HyperFrames edit as a video layer. Note: Motion
Canvas has had no release since late 2024 (3.17.2). It still works well, so pin it.

## Create the project (once per workspace)

```bash
npx -y @motion-canvas/create@3.17.2 --name motion-canvas-lab --path motion-canvas-lab --language ts --plugins ffmpeg
cd motion-canvas-lab && npm install
```

Settings that matter, in `src/project.meta` (or the editor's Video Settings panel):
- size = the composition size (1080×1920 for 9:16), `background: null` (transparent)
- rendering: fps 30, `resolutionScale: 2` (→ 2160×3840 for 4K), exporter **Image sequence**, PNG

Fonts: put the files in `public/fonts/`, declare `@font-face` in `src/global.css`, import that
CSS in `src/project.ts`, and **await the fonts before the project is created**. Canvas text is
shaped at draw time, so a missing font silently falls back:
```ts
import './global.css';
await Promise.all([document.fonts.load('700 72px "Your Display Font"')]);
export default makeProject({ scenes: [scene] });
```

## Scene pattern: an absolute cue list synced to the transcript

Write cues in **comp time** (the edit's word timestamps) and convert them to scene time with one
offset, so retiming is just editing numbers:
```tsx
const OFF = 30.4;                      // comp time where the clip starts
const at = (comp: number) => comp - OFF;
const cues: [number, () => ThreadGenerator][] = [];
const cue = (t: number, fn: () => ThreadGenerator) => cues.push([t, fn]);
cue(0.1, () => all(title().opacity(1, 0.45), title().position.y(-360, 0.8, easeOutExpo)));
cue(at(31.06), enter(card1, [220, -90]));
// … then play them in order, letting overlapping animations run in parallel:
cues.sort((a, b) => a[0] - b[0]);
let now = 0;
for (const [t, fn] of cues) { if (t > now) { yield* waitFor(t - now); now = t; } spawn(fn()); }
yield* waitFor(DUR - now);
```
- Blur entrances: `filters={[blur(() => b())]}` with a signal tweened 12→0.
- RTL text: `<Txt textDirection={'rtl'} …>`.
- Icons drawn with `Circle`/`Line`/`Path` and `end` signals give "drawn on" entrances for free.
- Composition: keep the clip's content inside the area the edit leaves free (caption zone,
  chip). Design the clip at the composition size so positions match 1:1.

## Render and encode

Motion Canvas renders from its editor UI (there is no headless CLI):
1. `npm start` (Vite, usually http://localhost:9000). Open it in the browser pane.
2. Click **Render** in the Video Settings tab. PNGs land in `output/project/000000.png …`.
   Move old frames away first so a shorter render doesn't leave stale frames behind.
3. Encode to an alpha WebM and put it in the edit:
```bash
ffmpeg -framerate 30 -i output/project/%06d.png -c:v libvpx-vp9 -pix_fmt yuva420p -b:v 0 -crf 30 \
  -row-mt 1 -tile-columns 2 -deadline good -cpu-used 4 -metadata:s:v:0 alpha_mode=1 -an ../edits/<name>/comp/assets/clip.webm
```
4. In the composition: `<video src="assets/clip.webm" data-start="<OFF>" data-duration="<frames/30>" muted playsinline>`
   in a layer **under** the footage, shown only inside its window. The footage transitions
   (sheet rise, iris) reveal it.

## When not to use it

Short UI moments, captions, icons and anything that has to interact with the footage belong in
HyperFrames directly. Use Motion Canvas when the explainer is its own self-contained scene.
