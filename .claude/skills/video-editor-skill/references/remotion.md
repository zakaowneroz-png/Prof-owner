# Remotion: when and how

Remotion (React) renders videos from components. The official Remotion agent skills
(`remotion-best-practices`, `remotion-create`, `remotion-render`, `remotion-captions`, …) are
installed in Phase 1 and cover the API in depth. Load them when you work in Remotion.

## When to pick Remotion over HyperFrames

- The user already works in React / Remotion, or wants templates driven by data (batch variants,
  personalised videos, many languages from one JSON).
- Reusable components with props (lower thirds, end cards) shared across many videos.
- Server-side or cloud rendering pipelines (Remotion Lambda).

For a single hand-crafted edit of a talking-head video, HyperFrames is usually faster to
iterate. Both can share the same scene math: write `sceneAt(frame)` in a plain JS module and
render it from React (`useCurrentFrame()`) or from the HyperFrames proxy tween.

## Start a project

```bash
npx create-video@latest --yes --blank --no-tailwind remotion-lab
cd remotion-lab && npx remotion studio            # http://localhost:3000
npx remotion render src/index.ts Main out.mp4 --codec=h264 --crf=18
```
- Fonts: `@remotion/fonts` (`loadFont`) with files in `public/`.
- Footage: `<OffthreadVideo src={staticFile('source.mp4')} />` for frame-accurate decoding.
- Transparent clips for the HyperFrames edit: `--codec=vp9 --pixel-format=yuva420p`, or a PNG
  sequence → the ffmpeg alpha encode in `motion-canvas.md`.
- 4K: `--scale=2` on a 1080×1920 composition.

## Licence

Remotion is free for individuals and companies of up to 3 people. Larger companies need a
company licence (remotion.dev/license). Mention this when a business user picks Remotion.
