# media-box

Box C's toolkit — luxury vertical video from real photos + verbatim copy, one command, $0.

Part of the [hq estate](https://github.com/ohlalahahaha/hq). Box C = the media CloudBox
(chat.z.ai) that supplies the creative pass (storyboard critique, copy refinement,
captions, music mood); this repo is the executor the VPS runs to render what Box C
approves. Dispatch protocol: [`agent/box-c.md`](agent/box-c.md) via `boxsay`.

## What it builds

- **1080×1920 (9:16)** vertical mp4, ~58.5s, xfade crossfades, H.264 + AAC
- Serif luxury typography (EB Garamond; any `.otf` via env)
- Layout variety: `A` lower scrim + gold headline · `B` upper-third + wordmark kicker + drift
- `TEAM3` three-strip team shot · `BRAND` opening card · `END` card with animated gold rule
- **Synthesized royalty-free music bed** — 4-chord pad Am→F→C→G, 1.2s crossfades,
  sub pulse, evolving air (pure Python + wave, no samples, no licenses)

## Quick start

```bash
sudo apt-get install -y ffmpeg fonts-ebgaramond

OUT=yd-60s.mp4 \
BRAND="Y E L L O W   D I A M O N D" \
SITE="yellowdiamondproperty.com" \
PHONE="+61 430 751 028" \
PHOTOS=/path/to/photos \
COPY=copy.tsv \
bin/build-vertical.sh
```

`copy.tsv` — one shot per line, tab-separated:
```
photo1.jpg|BRAND|P R O P E R T Y|The Right Address
photo2.jpg|A|The Right Address|Changes Everything.
photo3.jpg|B|Find Your Next|Address.
team1.jpg+team2.jpg+team3.jpg|TEAM3|From First Hello|To Keys In Hand
|END|The Right Address Changes Everything.|
```

## Quality gate

Every render goes through the VPS `taste-gate` before anyone's eyes see it:
dimensions 1080×1920 · duration 60s±3s · audio never clips (max < 0dB) ·
per-frame OCR of key frames to catch broken text. Fail = never ships.

## Files

- `bin/build-vertical.sh` — parametric builder (env-configurable brand, colors, fonts)
- `bin/music-bed.py` — synthesized 4-chord ambient bed
- `agent/box-c.md` — boxsay dispatch protocol for the media box

Keywords: vertical video, 9:16, reels, tiktok, whatsapp status, zalo, luxury real estate,
ffmpeg, ken burns, zoompan, drawtext, xfade, royalty-free music, taste gate, media box.
