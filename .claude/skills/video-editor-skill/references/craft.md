# Craft: principles, checklist, hard-won pitfalls

These hold for any style. The user's `brand/frame.md` decides colours, fonts and which moves are
allowed. These rules decide whether those moves *work*.

## Principles

1. **The person is the anchor.** Graphics serve what's being said. Never cover the face, and
   never let a graphic compete with the eyes at the moment of a key sentence.
2. **Timed to the word.** Every entrance lands ~2 frames before its word. Nothing appears before
   it's said; if the guideline wants suspense, show it concealed (blurred, pixelated, "?") and
   reveal it on the word.
3. **One focal element per beat.** It is clearly dominant (≈3× its neighbours); everything else is
   quieter.
4. **Momentum.** Exits carry into the next entrance (same direction and speed). Nothing just
   vanishes or pops in from nowhere. Things travel, emerge from another element, or assemble.
5. **Anticipation and settle.** A tiny counter-move before big moves. Springs settle calmly
   (overshoot ≤ 4 % for icons unless the guideline wants bounce).
6. **Never frozen (unless the guideline says so).** Slow camera drift or a gentle breath keeps
   held frames alive. Punch-ins (2–4 %) on beats.
7. **Variety.** Rotate transitions, caption entrances, icon containers and backgrounds. Never the
   same move twice in a row.
8. **Real things.** When a tool or brand is named, show its real logo or UI. Never invent
   numbers; every figure comes from the script.
9. **Restraint.** One saturated accent on screen, one glow per frame at most, particles only
   where they carry meaning (data along a line, a burst on a reveal). No particles or glows over
   the person.

## Composition

- Safe areas for vertical social video: top ~190 px (status/profile chrome), bottom ~330 px
  (caption + buttons), right ~150 px below mid-height (like/comment rail). No load-bearing text
  there.
- Margins ≥ 64 px. Place focal elements on thirds unless the beat is one symmetric object, which
  is centred on purpose.
- Group related items into one cluster with even spacing. No orphan elements.
- Full-screen graphic scenes: the content block spans 60–80 % of the width and sits optically
  centred with the caption under it. Don't leave an empty half.
- Logos fill 55–60 % of their tile. Tiles ≥ 140–170 px at 1080 width.

## Pre-show checklist (run on every contact sheet)

- [ ] No caption overlaps another caption, a graphic, the chip, or the face.
- [ ] Captions are legible on every background they cross, including light clothing and paper.
- [ ] Every transition reads as intentional in its middle frame: no blobs, no half-revealed
      words, no ghost duplicates of the person.
- [ ] Nothing sits in the platform safe areas.
- [ ] Each beat has one clear focal element. Colours follow the guideline.
- [ ] RTL text is joined correctly and isn't clipped (dots/diacritics), and Latin words are in the
      right order.
- [ ] The first and last frames are clean (no half-faded element at 0 s or at the end).
- [ ] Audio: integrated loudness on target, no clipping, music under the voice.

## Pitfalls learned on real edits

| Problem | Cause | Fix |
|---|---|---|
| Caption pops on top of the previous one | exits computed per caption | exit precompute: finish each exit before the next caption's first word |
| Big dark smudge behind captions on a white shirt | radial scrim / 18 px soft shadow | tight edge shadow only (1.5 px + 3 px) |
| Dark smudge on a paper background during a transition | the outgoing footage caption's scrim/shadow rides over the new background | start the transition after the caption has left, or fade its scrim with the transition |
| Person appears twice | footage slid away while the cut-out stayed | keep footage still; reveal by clipping, not moving |
| Coloured rim around the cut-out on white | matte edge carries the room's colour | erode 2–3 px in that window, or despill |
| Iris looks like a brown blob in a word | iris starts inside text | start from empty space and give the shape an accent outline |
| Side cards draw over the centre card | children z-index escape | `z-index:0` on the container (own stacking context) |
| A 3D ring reads as a flat line | camera level with the ring | raise the camera, billboard the tiles toward it |
| 3D tiles edge-on in a tunnel | default orientation | `lookAt` a point ahead of the camera so faces read |
| Thin 3D lines invisible | WebGL line width is always 1 px | `TubeGeometry` + `setDrawRange` |
| Fonts wrong in renders | font not loaded when DOM built | `document.fonts.load` for every face before building |
| Arabic letters break apart | per-letter animation / letter-spacing | animate per word; never letter-space Arabic |
| Dots/descenders cut off on gradient text | `background-clip:text` crops at the box | pad the word box, keep line-height ≥ 1.2 |
| Stale frames at the end of a re-render | old PNG sequence left in the output folder | move old frames away before rendering |
| Music drowns the voice | raw voice much quieter than the track | measure the voice LUFS; bed at −27 dB, sidechain ratio 3, then normalise the sum |
| A whoosh feels late | SFX starts on the cut | align the SFX's peak to the cut (mix.py does this) |
| The user's own light-leak / glitch looks cheap | baked into the rough cut | cover it: freeze the clean frame as a still through the effect, then cut with a zoom-blur |
