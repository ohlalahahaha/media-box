#!/bin/bash
# build-vertical.sh — parametric 9:16 luxury vertical video builder (media-box kit)
# One command: real photos + verbatim copy -> 1080x1920 mp4 with serif overlays,
# wordmark kickers, varied layouts (A: lower scrim / B: upper third), animated gold
# rule end card, synthesized 4-chord music bed. $0, royalty-free, no publishing.
#
# Usage:
#   OUT=file.mp4 BRAND="Y O U R   B R A N D" TAG1="Tag line" TAG2="Second line" \
#   SITE=yoursite.com PHONE="+61 ..." PHOTOS=/path/to/photos COPY=/path/to/copy.tsv \
#   ./build-vertical.sh
#
# copy.tsv format (tab-separated, one shot per line, in play order):
#   <image-path>|<A|B|END|TEAM3|BRAND>|<line1>|<line2>
#   A      = lower scrim band, gold serif headline (2 lines)
#   B      = upper-third ivory headline + gold wordmark kicker + slow drift
#   TEAM3  = three vertical photo strips side by side (img|img|img in line1, split by +)
#   BRAND  = opening brand card (img + wordmark + tag)
#   END    = ink end card: animated gold rule, wordmark, tag, site, phone
set -euo pipefail
cd "$(dirname "$0")"

OUT="${OUT:-out.mp4}"
BRAND="${BRAND:-B R A N D}"
SITE="${SITE:-example.com}"
PHONE="${PHONE:-}"
PHOTOS="${PHOTOS:-.}"
COPY="${COPY:-copy.tsv}"
FONTB="${FONTB:-/usr/share/fonts/opentype/ebgaramond/EBGaramond12-Bold.otf}"
FONTI="${FONTI:-/usr/share/fonts/opentype/ebgaramond/EBGaramond12-Italic.otf}"
GOLD="${GOLD:-0xE7C869}"; IVORY="${IVORY:-0xFAF7EF}"; INK="${INK:-0x16130E}"; RULE="${RULE:-0xB69A52}"
D=150; FPS=25; SEG=6
FADE="if(lt(t,0.7),t/0.7,if(gt(t,5.3),(6-t)/0.7,1))"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

enc() { echo "$1" | sed "s/'/\\\\'/g"; }
p() { [ "${1:-}" = "${1:-}" ] && echo "$PHOTOS/${1##*/}"; }

shot_a() { img="$TMP/$1" out="$TMP/$2" zin="$3" l1="$4" l2="$5"
  if [ "$zin" = "1" ]; then Z="min(1.12,1+0.0008*on)"; else Z="max(1.0,1.12-0.0008*on)"; fi
  ffmpeg -y -loglevel error -i "$img" -filter_complex "[0:v]scale=1620:2880:force_original_aspect_ratio=increase,crop=1620:2880,zoompan=z='$Z':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=$D:s=1080x1920:fps=$FPS,drawbox=x=0:y=1210:w=1080:h=410:color=$INK@0.5:t=fill,drawtext=fontfile=$FONTB:text='$(enc "$l1")':fontcolor=$GOLD:fontsize=68:x=(w-text_w)/2:y=h-560:borderw=5:bordercolor=$INK@0.9:alpha='$FADE',drawtext=fontfile=$FONTB:text='$(enc "$l2")':fontcolor=$GOLD:fontsize=68:x=(w-text_w)/2:y=h-480:borderw=5:bordercolor=$INK@0.9:alpha='$FADE',drawbox=x=(w-120)/2:y=h-400:w=120:h=2:color=$RULE@0.9:t=fill,format=yuv420p" -t $SEG -r $FPS -c:v libx264 -preset veryfast -crf 20 "$out"
}
shot_b() { img="$TMP/$1" out="$TMP/$2" zin="$3" l1="$4" l2="$5"
  if [ "$zin" = "1" ]; then Z="min(1.10,1+0.0007*on)"; else Z="max(1.0,1.10-0.0007*on)"; fi
  ffmpeg -y -loglevel error -i "$img" -filter_complex "[0:v]scale=1620:2880:force_original_aspect_ratio=increase,crop=1620:2880,zoompan=z='$Z':x='iw/2-(iw/zoom/2)+18*sin(on/60)':y='ih/3-(ih/zoom/3)':d=$D:s=1080x1920:fps=$FPS,drawtext=fontfile=$FONTB:text='$BRAND':fontcolor=$GOLD:fontsize=26:x=(w-text_w)/2:y=400:alpha='$FADE',drawbox=x=(w-60)/2:y=448:w=60:h=2:color=$RULE@0.9:t=fill:enable='between(t,0.5,5.5)',drawtext=fontfile=$FONTB:text='$(enc "$l1")':fontcolor=$IVORY:fontsize=72:x=(w-text_w)/2:y=500:borderw=5:bordercolor=$INK@0.85:alpha='$FADE',drawtext=fontfile=$FONTB:text='$(enc "$l2")':fontcolor=$IVORY:fontsize=72:x=(w-text_w)/2:y=585:borderw=5:bordercolor=$INK@0.85:alpha='$FADE',format=yuv420p" -t $SEG -r $FPS -c:v libx264 -preset veryfast -crf 20 "$out"
}
shot_team3() { # l1 = img1+img2+img3
  IFS='+' read -r i1 i2 i3 <<< "$1"
  ffmpeg -y -loglevel error -i "$PHOTOS/$(basename "$i1")" -i "$PHOTOS/$(basename "$i2")" -i "$PHOTOS/$(basename "$i3")" -filter_complex "[0:v]scale=540:2880:force_original_aspect_ratio=increase,crop=540:2880,zoompan=z='min(1.08,1+0.0005*on)':x='iw/2-(iw/zoom/2)':y='ih/3-(ih/zoom/3)':d=$D:s=360x1920:fps=$FPS[a];[1:v]scale=540:2880:force_original_aspect_ratio=increase,crop=540:2880,zoompan=z='min(1.08,1+0.0005*on)':x='iw/2-(iw/zoom/2)':y='ih/3-(ih/zoom/3)':d=$D:s=360x1920:fps=$FPS[b];[2:v]scale=540:2880:force_original_aspect_ratio=increase,crop=540:2880,zoompan=z='min(1.08,1+0.0005*on)':x='iw/2-(iw/zoom/2)':y='ih/3-(ih/zoom/3)':d=$D:s=360x1920:fps=$FPS[c];[a][b][c]hstack=3,drawbox=x=0:y=1210:w=1080:h=410:color=$INK@0.5:t=fill,drawtext=fontfile=$FONTB:text='$(enc "$3")':fontcolor=$GOLD:fontsize=62:x=(w-text_w)/2:y=h-560:borderw=5:bordercolor=$INK@0.9:alpha='$FADE',drawtext=fontfile=$FONTB:text='$(enc "$4")':fontcolor=$GOLD:fontsize=62:x=(w-text_w)/2:y=h-485:borderw=5:bordercolor=$INK@0.9:alpha='$FADE',format=yuv420p" -t $SEG -r $FPS -c:v libx264 -preset veryfast -crf 20 "$TMP/$2"
}
shot_brand() {
  ffmpeg -y -loglevel error -i "$1" -filter_complex "[0:v]scale=1620:2880:force_original_aspect_ratio=increase,crop=1620:2880,eq=brightness=-0.17:saturation=0.93,zoompan=z='min(1.06,1+0.0004*on)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=$D:s=1080x1920:fps=$FPS,drawbox=x=0:y=560:w=1080:h=640:color=$INK@0.55:t=fill,drawtext=fontfile=$FONTB:text='$BRAND':fontcolor=$GOLD:fontsize=76:x=(w-text_w)/2:y=660:borderw=6:bordercolor=$INK@0.95:alpha='$FADE',drawbox=x=(w-340)/2:y=780:w=340:h=3:color=$RULE@1:t=fill,drawtext=fontfile=$FONTB:text='$(enc "$2")':fontcolor=$IVORY:fontsize=40:x=(w-text_w)/2:y=820:alpha='$FADE',drawtext=fontfile=$FONTI:text='$(enc "$3")':fontcolor=$IVORY:fontsize=52:x=(w-text_w)/2:y=950:borderw=4:bordercolor=$INK@0.9:alpha='$FADE',drawtext=fontfile=$FONTI:text='$(enc "$4")':fontcolor=$IVORY:fontsize=52:x=(w-text_w)/2:y=1020:borderw=4:bordercolor=$INK@0.9:alpha='$FADE',format=yuv420p" -t $SEG -r $FPS -c:v libx264 -preset veryfast -crf 20 "$TMP/$2"
}
shot_end() {
  ffmpeg -y -loglevel error -f lavfi -i "color=c=$INK:s=1080x1920:d=$SEG:r=$FPS" -filter_complex "drawtext=fontfile=$FONTB:text='$BRAND':fontcolor=$GOLD:fontsize=58:x=(w-text_w)/2:y=690:alpha='$FADE',drawbox=x=(w-300)/2:y=800:w='min(300,t*80)':h=3:color=$RULE@1:t=fill,drawtext=fontfile=$FONTI:text='$(enc "$2")':fontcolor=$IVORY:fontsize=40:x=(w-text_w)/2:y=860:alpha='$FADE',drawtext=fontfile=$FONTB:text='$SITE':fontcolor=$IVORY:fontsize=46:x=(w-text_w)/2:y=1010:alpha='$FADE',drawtext=fontfile=$FONTB:text='$PHONE':fontcolor=$GOLD:fontsize=46:x=(w-text_w)/2:y=1090:alpha='$FADE',format=yuv420p" -t $SEG -r $FPS -c:v libx264 -preset veryfast -crf 20 "$TMP/$1"
}

# --- read copy.tsv, build segments
N=0
while IFS='|' read -r img typ l1 l2; do
  [ -z "${img:-}" ] && continue
  N=$((N+1))
  seg=$(printf "seg%02d" $N)
  case "$typ" in
    BRAND) shot_brand "$PHOTOS/$(basename "$img")" "$seg.mp4" "$(echo "$l1"|tr -d '\r')" "$(echo "$l2"|tr -d '\r')" "";;
    TEAM3) shot_team3 "$(echo "$l1"|tr -d '\r')" "$seg.mp4" "$(echo "$l1"|tr -d '\r')" "" "$(echo "$l2"|tr -d '\r')" "$(echo "${3:-}")";;
    A)     shot_a "$PHOTOS/$(basename "$img")" "$seg.mp4" $((N%2)) "$(echo "$l1"|tr -d '\r')" "$(echo "$l2"|tr -d '\r')";;
    B)     shot_b "$PHOTOS/$(basename "$img")" "$seg.mp4" $((N%2)) "$(echo "$l1"|tr -d '\r')" "$(echo "$l2"|tr -d '\r')";;
    END)   shot_end "$seg.mp4" "$(echo "$l1"|tr -d '\r')";;
    *) echo "unknown type $typ" >&2; exit 1;;
  esac
  echo "built $seg ($typ)"
  IN="${IN:-}"; IN="$IN -i $TMP/$seg.mp4"
done < "$COPY"

# --- music bed
python3 "$(dirname "$0")/music-bed.py" "$TMP/music.wav" 58.5
IN="$IN -i $TMP/music.wav"

# --- xfade concat (0.75s crossfade at each 6s boundary) + audio map
OFF=5.25; CH="[0:v]"; PREV="[v0]"
for i in $(seq 1 $((N-1))); do
  CH="$CH;[$PREV][$i:v]xfade=transition=fade:duration=0.75:offset=$OFF[v$i]"
  PREV="[v$i]"; OFF=$(python3 -c "print($OFF+5.25)")
done
ffmpeg -y -loglevel error $IN -filter_complex "$CH" -map "$PREV" -map $N:a -c:v libx264 -preset veryfast -crf 20 -c:a aac -b:a 128k -af "afade=t=in:d=2,afade=t=out:st=55:d=3.5,alimiter=limit=0.89" -movflags +faststart "$OUT"
echo "=== VERIFY ==="
ffprobe -v error -show_entries format=duration,size -show_entries stream=width,height -of default=noprint_wrappers=1 "$OUT"
ffmpeg -i "$OUT" -af volumedetect -f null - 2>&1 | grep -E "max_volume|mean_volume" || true
echo "DONE: $OUT"
