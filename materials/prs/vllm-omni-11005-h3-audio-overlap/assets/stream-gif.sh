#!/usr/bin/env bash
set -euo pipefail
source_file=${1:-stream-baseline-vs-pr.mp4}
output_file=${2:-stream-baseline-vs-pr.gif}
font_file=${FONT_FILE:-/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf}
# Keep every paired frame. Rebuild the accepted labels at the display size.
ffmpeg -hide_banner -loglevel error -y -i "$source_file" -filter_complex_threads 1 \
  -filter_complex "[0:v]crop=1536:768:0:48,scale=512:256:flags=lanczos,pad=iw:ih+36:0:36:color=black,drawtext=fontfile=${font_file}:text='Baseline':fontcolor=white:fontsize=20:x=(256-tw)/2:y=7,drawtext=fontfile=${font_file}:text='PR':fontcolor=white:fontsize=20:x=256+(256-tw)/2:y=7,split=2[palette_input][gif_input];[palette_input]palettegen=max_colors=256:stats_mode=full[palette];[gif_input][palette]paletteuse=dither=bayer:bayer_scale=4[gif]" \
  -map '[gif]' -an -map_metadata -1 -metadata comment= \
  -vsync 0 -frames:v 107 -loop 0 "$output_file"
