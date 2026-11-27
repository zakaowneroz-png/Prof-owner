# frame-exact video (from SRC) + sample-exact voice (from orig48k) for projects/tawsi3/cuts.json
import json, subprocess, sys, wave, numpy as np, os
P = 'projects/tawsi3/'; SRC = sys.argv[1] if len(sys.argv) > 1 else 'work/proxy.mp4'
cuts = json.load(open(P + 'cuts.json')); os.makedirs('work/segs', exist_ok=True); L = open('work/segs/list.txt', 'w')
G = open(P + 'grade.txt').read().strip()
for i, (a, b, _) in enumerate(cuts):
    a0 = round(a * 30) / 30; n = round((b - a) * 30); o = f'work/segs/s{i:02d}.mp4'
    subprocess.run(['ffmpeg','-nostdin','-v','error','-y','-ss',f'{a0:.4f}','-i',SRC,'-t',f'{n/30+0.1:.3f}','-an',
      '-vf',f'fps=30,tpad=stop_mode=clone:stop=2,{G},format=yuv420p','-frames:v',str(n),'-c:v','libx264','-preset','veryfast','-crf','15','-g','30',o], check=True)
    L.write(f"file 's{i:02d}.mp4'\n")
L.close()
subprocess.run(['ffmpeg','-nostdin','-v','error','-y','-f','concat','-i','work/segs/list.txt','-c','copy','work/roughcut-video.mp4'], check=True)
w = wave.open('work/orig48k.wav'); sr = w.getframerate()
A = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16).reshape(-1, 2).astype(np.float32); out = []
for a, b, _ in cuts:
    a0 = round(a * 30) / 30; N = round((b - a) * 30) * 1600; s = int(round(a0 * sr)); seg = A[s:s + N].copy()
    if len(seg) < N: seg = np.vstack([seg, np.zeros((N - len(seg), 2), np.float32)])
    fi, fo = int(.012 * sr), int(.015 * sr); seg[:fi] *= np.linspace(0, 1, fi)[:, None]; seg[-fo:] *= np.linspace(1, 0, fo)[:, None]; out.append(seg)
V = np.vstack(out).clip(-32768, 32767).astype(np.int16)
o = wave.open('work/voice-true.wav', 'wb'); o.setnchannels(2); o.setsampwidth(2); o.setframerate(sr); o.writeframes(V.tobytes()); o.close()
nf = sum(round((b - a) * 30) for a, b, _ in cuts)
print('voice s', len(V) / sr, 'video frames expected', nf, nf / 30)
