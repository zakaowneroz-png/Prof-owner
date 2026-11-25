#!/usr/bin/env python3
"""Final audio mix: voice (from the footage) + optional music bed + optional SFX cue sheet.

  python3 -I mix.py --voice edit-source.mp4 --out mix.wav [--duration 74.36]
         [--music track.wav --music-start 0 --bed-db -27 --fade-in 0.6 --fade-out 1.8]
         [--sfx cues.json] [--lufs -14] [--no-voice-fx]

  * voice: high-pass 70 Hz + gentle compressor (skip with --no-voice-fx)
  * music: trimmed from --music-start, set --bed-db under the voice, then sidechain-ducked by the voice
  * sfx: cues.json = [{"t": 3.66, "file": "sfx/whoosh.wav", "gain": -6, "pitch": 1.0}, …]
         each file is normalised to −6 dBFS peak, then `gain` dB; its LOUDEST moment lands on `t`
         (a whoosh's peak hits the cut, not its first sample)
  * the sum is loudness-normalised to --lufs (default −14 LUFS, true peak −1.5 dBTP)
Leave out --music / --sfx for a voice-only master (many creators add music and SFX themselves).
"""
import argparse, math, os, shutil, struct, subprocess, sys

FF = shutil.which("ffmpeg") or os.path.expanduser("~/.local/bin/ffmpeg")
FP = shutil.which("ffprobe") or os.path.expanduser("~/.local/bin/ffprobe")


def pcm(path, rate=8000):
    raw = subprocess.run([FF, "-v", "error", "-i", path, "-ac", "1", "-ar", str(rate), "-f", "s16le", "-"], capture_output=True, check=True).stdout
    return struct.unpack(f"<{len(raw) // 2}h", raw)


def peak_info(path):
    s = pcm(path)
    win = 160  # 20 ms envelope at 8 kHz
    env = [max(abs(v) for v in s[i:i + win]) for i in range(0, max(1, len(s) - win), win)] or [0]
    k = max(range(len(env)), key=lambda i: env[i])
    return k * win / 8000, max(1, max(abs(v) for v in s)) / 32768


def duration(path):
    return float(subprocess.run([FP, "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", path], capture_output=True, text=True, check=True).stdout.strip())


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--voice", required=True, help="the edit's source footage or a voice file")
    ap.add_argument("--out", required=True)
    ap.add_argument("--duration", type=float, help="length of the edit (default: voice length)")
    ap.add_argument("--music"); ap.add_argument("--music-start", type=float, default=0.0)
    ap.add_argument("--bed-db", type=float, default=-27.0, help="music gain before ducking (−24…−30 sits under a voice)")
    ap.add_argument("--fade-in", type=float, default=0.6); ap.add_argument("--fade-out", type=float, default=1.8)
    ap.add_argument("--duck-ratio", type=float, default=3.0)
    ap.add_argument("--sfx", help="JSON cue sheet")
    ap.add_argument("--lufs", type=float, default=-14.0)
    ap.add_argument("--no-voice-fx", action="store_true")
    a = ap.parse_args()

    dur = a.duration or duration(a.voice)
    inputs, graph, mixes = ["-i", a.voice], [], []
    vfx = "highpass=f=70,acompressor=threshold=-20dB:ratio=2.5:attack=8:release=120" if not a.no_voice_fx else "anull"
    graph.append(f"[0:a]aresample=48000,{vfx}[voice]")
    if a.music:
        inputs += ["-i", a.music]
        graph.append("[voice]asplit=2[vmix][vkey]")
        graph.append(f"[1:a]aresample=48000,atrim=start={a.music_start}:duration={dur},asetpts=PTS-STARTPTS,volume={a.bed_db}dB,"
                     f"afade=t=in:st=0:d={a.fade_in},afade=t=out:st={max(0, dur - a.fade_out)}:d={a.fade_out}[bed]")
        graph.append(f"[bed][vkey]sidechaincompress=threshold=0.02:ratio={a.duck_ratio}:attack=40:release=450:makeup=1[music]")
        mixes += ["[vmix]", "[music]"]
    else:
        graph.append("[voice]anull[vmix]")
        mixes.append("[vmix]")

    if a.sfx:
        import json
        cues = json.load(open(a.sfx, encoding="utf-8"))
        base = os.path.dirname(os.path.abspath(a.sfx)); seen = {}
        for c in cues:
            path = c["file"] if os.path.isabs(c["file"]) else os.path.join(base, c["file"])
            if path not in seen: seen[path] = peak_info(path)
            at, peak = seen[path]; pitch = float(c.get("pitch", 1.0))
            norm = -6 - 20 * math.log10(peak)
            start = max(0.0, float(c["t"]) - at / pitch)
            idx = len(inputs) // 2; inputs += ["-i", path]
            chain = f"[{idx}:a]aresample=48000" + (f",asetrate={int(48000 * pitch)},aresample=48000" if pitch != 1.0 else "")
            chain += f",volume={norm + float(c.get('gain', -8)):.2f}dB,adelay={int(start * 1000)}|{int(start * 1000)}[s{idx}]"
            graph.append(chain); mixes.append(f"[s{idx}]")

    mixer = f"{''.join(mixes)}amix=inputs={len(mixes)}:normalize=0:duration=first," if len(mixes) > 1 else f"{mixes[0]}anull,"
    graph.append(mixer + f"atrim=duration={dur},loudnorm=I={a.lufs}:TP=-1.5:LRA=11[out]")
    cmd = [FF, "-v", "error", "-y", *inputs, "-filter_complex", ";".join(graph), "-map", "[out]", "-ar", "48000", "-ac", "2", a.out]
    subprocess.run(cmd, check=True)
    print("wrote", a.out, f"({dur:.2f}s, target {a.lufs} LUFS)")
    print("mux:  ffmpeg -i render.mp4 -i", a.out, "-map 0:v -map 1:a -c:v copy -c:a aac -b:a 256k -shortest -movflags +faststart final.mp4")


if __name__ == "__main__":
    main()
