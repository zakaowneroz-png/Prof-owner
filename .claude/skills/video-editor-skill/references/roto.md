# Subject cut-out (roto)

Use a cut-out when something must sit **behind** the person: a giant number, a title tucked
behind the head, icons passing behind the shoulders. It's an effect for a few hero beats, not a
default. Ask the user before building a whole scene around it. Some people dislike seeing
themselves cut out on a flat background.

## Pipeline

```bash
bash SKILL_DIR/scripts/roto.sh comp/assets/source.mp4 comp/assets/subject.webm --windows "0-11.8,25-29" --erode 1
```
1. **Matte**: macOS: `cutout-video` (Vision foreground-instance mask; it keeps held objects like
   a mic; ~0.05–0.1 s per 4K frame). Elsewhere: rembg (slower; check `rembg p --help`).
   Masks go to `masks/00001.png …`, one per source frame.
2. **Clean**: `tmix=frames=3` (temporal smoothing, no flicker) → choke
   `lut=y='clip((val-56)*1.4,0,255)'` (tightens the soft edge) → optional `erosion` ×N (removes a
   coloured fringe picked up from the background) → `gblur=sigma=0.6` (feather).
3. **Windows**: `drawbox=enable='not(between(t,a,b)+…)':c=black:t=fill` blacks out time ranges
   where no cut-out is needed. The file gets small and the encode fast.
4. **Encode**: `alphamerge` → VP9 `yuva420p` with `-metadata:s:v:0 alpha_mode=1` (Chrome needs
   that flag to read the alpha).

## In the composition

```html
<div id="footWrap"><video id="foot" src="assets/source.mp4" data-start="0" data-duration="74.37" data-has-audio="true"></video></div>
<div id="behind"> … numbers / titles … </div>
<div id="subjWrap"><video id="subj" src="assets/subject.webm" data-start="0" data-duration="74.37" muted></video></div>
```
- The cut-out gets **the same transform** as the footage every frame (same `translate`/`scale`)
  and the same clip-path during reveals (iris, split). Otherwise it floats.
- Show the cut-out layer only inside its windows (`display:none` elsewhere).

## Pitfalls

- **Ghost copy**: if you move the footage (slide it away) while the cut-out stays, the person
  appears twice. Keep the footage still and reveal the background by clipping
  (`clip-path: inset(...)`) instead.
- **Fringe on light backgrounds**: a cut-out from a blue/green room shows a coloured rim on paper
  white. Erode 2–3 px inside that window, or despill (`despill=type=blue`/`green`) before
  alphamerge. Check at 100 % zoom in motion.
- **Empty cut-out (alpha 0 everywhere)**: the source had an offset start time or a timecode/data track (common with
  ProRes .mov → mp4). `roto.sh` resets timestamps on both inputs; when converting a .mov yourself, use
  `-map 0:v:0 -map 0:a:0 -dn -write_tmcd 0` and check `ffprobe -show_entries stream=start_time` is 0. Chrome can't
  decode ProRes, so always convert .mov sources to H.264 for the composition (keep the original audio for the mix).
- **Fast hands** blur and smear in the matte. Prefer beats where the person is relatively still.
- **Caption legibility** over the cut-out on a light background: switch captions to dark ink for
  that scene instead of adding a big shadow.
