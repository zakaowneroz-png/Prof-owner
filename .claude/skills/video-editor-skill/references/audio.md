# Audio: transcripts, timing, mix

## Transcription

```bash
bash SKILL_DIR/scripts/transcribe.sh footage/x.mp4 edits/<name>/work --lang en --prompt "Claude, HyperFrames, Midjourney"
```
- Engines: Apple Silicon → mlx-whisper `large-v3` (default), parakeet-mlx for very fast English
  (`--engine parakeet`, English only). Other machines → whisper-ctranslate2 `large-v3`.
- `--prompt` (initial prompt) with names, brand terms and dialect spellings strongly improves the
  output. For dialects or mixed languages (e.g. Arabic dialects with English tech words), run
  `large-v3` and a turbo model (`--model mlx-community/whisper-large-v3-turbo`) and compare: one
  tends to get the timing right, the other the spelling. Merge by hand.
- `words.json` gives every word with start/end/probability. The script lists low-confidence
  words. **Proofread every word that will appear on screen**, and ask the user about the
  uncertain ones in the script breakdown.
- Whisper word timestamps can be 50–150 ms late on the first word after silence. For hard sync,
  check the waveform (`npx hyperframes audio <file>` reports onsets) and nudge.

## Sync rules

- Entrances land ~2 frames before the word's start. Exits finish before the next caption.
- Cuts in the source (the user's own jump cuts or inserts) can be found exactly with
  `ffmpeg -vf "select='gt(scene,0.3)',showinfo"`. Pin carousel shifts or transitions to them.

## The mix (`scripts/mix.py`)

```bash
# voice only (the user adds music / SFX themselves)
python3 -I SKILL_DIR/scripts/mix.py --voice comp/assets/source.mp4 --out audio/voice-only.wav --duration 74.36
# voice + ducked music bed + SFX cue sheet
python3 -I SKILL_DIR/scripts/mix.py --voice comp/assets/source.mp4 --music audio/track.wav --bed-db -27 --sfx audio/cues.json --out audio/mix.wav --duration 74.36
```
- Voice chain: high-pass 70 Hz + gentle compressor. Then the full mix is loudness-normalised to
  −14 LUFS (true peak −1.5). That's the default for social platforms.
- Music: start offset, a bed level (−24…−30 dB before ducking, depending on how loud the raw voice
  is; measure it first with `ffmpeg -af ebur128`), and sidechain ducking keyed by the voice
  (ratio 3, attack 40 ms, release 450 ms). Fade in 0.6 s, fade out over the last ~1.8 s.
- SFX cue sheet: `[{"t": 3.66, "file": "sfx/whoosh-soft.wav", "gain": -6, "pitch": 1.0}]`. Each
  file is peak-normalised, and its loudest moment is aligned to `t`. Keep to at most 1 SFX per
  second, vary the files, and pitch repeats slightly (0.94–1.06).
- Mux: `ffmpeg -i render.mp4 -i mix.wav -map 0:v -map 1:a -c:v copy -c:a aac -b:a 256k -shortest -movflags +faststart final.mp4`.
- Verify: `ffmpeg -i final.mp4 -af ebur128 -vn -f null - 2>&1 | grep -A1 Integrated`.

## Music and SFX sources

The user decides where music comes from: their own licensed library (Epidemic Sound, Artlist,
Musicbed…), royalty-free files they provide, or none. If they have a library account connected
to Claude (e.g. a music connector), you may search it. Show 3 options with title, artist, BPM and
mood, and **ask before downloading**. Never rip audio from videos. Many creators prefer to add
music and SFX in their own editor. Then deliver a voice-only master and write the track name,
artist, source and start offset in the delivery message, plus the SFX cue sheet with timestamps
if one was planned.
