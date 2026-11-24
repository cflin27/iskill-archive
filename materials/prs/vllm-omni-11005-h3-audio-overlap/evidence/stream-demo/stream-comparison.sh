#!/usr/bin/env bash
set -euo pipefail
# Encode paired original outputs without dropping frames.
baseline=${1:-baseline.mp4}
candidate=${2:-candidate.mp4}
output=${3:-stream-baseline-vs-pr.mp4}
font_file=${FONT_FILE:-/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf}
temporary=$(mktemp -d)
trap 'rm -rf "$temporary"' EXIT
ffmpeg -hide_banner -loglevel error -y \
  -i "$baseline" -i "$candidate" -filter_complex_threads 1 \
  -filter_complex "[0:v]setpts=PTS-STARTPTS,pad=iw:ih+48:0:48:color=black,drawtext=fontfile=${font_file}:text='Baseline':fontcolor=white:fontsize=28:x=(w-tw)/2:y=(48-th)/2[left];[1:v]setpts=PTS-STARTPTS,pad=iw:ih+48:0:48:color=black,drawtext=fontfile=${font_file}:text='PR':fontcolor=white:fontsize=28:x=(w-tw)/2:y=(48-th)/2[right];[left][right]hstack=inputs=2:shortest=1[video]" \
  -map '[video]' -an -map_metadata -1 -vsync 0 -frames:v 107 \
  -c:v libx264 -preset medium -crf 18 -profile:v high -level:v 4.1 \
  -pix_fmt yuv420p -maxrate 12M -bufsize 12M "$temporary/video.mp4"
# The original decoded audio is identical in both arms; preserve one AAC track.
ffmpeg -hide_banner -loglevel error -y \
  -i "$temporary/video.mp4" -i "$baseline" \
  -map 0:v:0 -map 1:a:0 -c copy -map_metadata -1 -movflags +faststart "$output"
