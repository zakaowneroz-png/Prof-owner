import subprocess, sys
G = [("G1",[(8.0,10.75),(13.3,22.25)]),("G2",[(22.2,25.55),(27.0,30.75)]),("G3",[(61.0,63.6),(65.3,68.35),(69.5,73.9)]),
     ("G4",[(91.3,94.65),(95.0,98.9)]),("G5",[(132.75,135.8),(135.85,144.7)]),
     ("G6",[(178.3,183.0),(184.0,195.5),(197.35,202.6),(207.7,219.3)]),("G7",[(226.4,231.45),(233.2,234.75),(235.3,241.7)])]
F = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"; L = open("review/list.txt", "w"); i = 0
for g, takes in G:
    for k, (a, b) in enumerate(takes, 1):
        o = f"review/{i:02d}.mp4"; i += 1
        lab = f"{g}  TAKE {k}"; tc = f"{int(a//60)}\\:{a%60:05.2f}"
        vf = (f"scale=540:960,drawbox=y=0:w=iw:h=120:color=0x0B0B0C@0.85:t=fill,"
              f"drawtext=fontfile={F}:text='{lab}':fontcolor=0xFFC400:fontsize=54:x=(w-tw)/2:y=18,"
              f"drawtext=fontfile={F}:text='{tc}':fontcolor=white:fontsize=30:x=(w-tw)/2:y=80")
        subprocess.run(["ffmpeg","-nostdin","-v","error","-y","-ss",str(a),"-i","proxy.mp4","-t",f"{b-a:.2f}","-vf",vf,"-r","30",
            "-c:v","libx264","-preset","veryfast","-crf","26","-c:a","aac","-b:a","128k","-ar","48000","-ac","2",o], check=True)
        L.write(f"file '{i-1:02d}.mp4'\n")
L.close()
subprocess.run(["ffmpeg","-nostdin","-v","error","-y","-f","concat","-i","review/list.txt","-c:v","libx264","-preset","veryfast","-crf","26","-c:a","aac","-b:a","128k","-movflags","+faststart","review-takes.mp4"], check=True)
