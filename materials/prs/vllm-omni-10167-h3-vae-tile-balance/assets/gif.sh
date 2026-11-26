#!/usr/bin/env bash
set -euo pipefail

# Derive the silent presentation GIF from the accepted side-by-side MP4.
# The source already carries the "Baseline" (left) / "Candidate" (right)
# labels. Keep every paired frame and strip audio and container metadata.
source_file=${1:-pr10167-ref2va-formal-comparison.mp4}
output_file=${2:-pr10167-ref2va-formal-comparison.gif}

# Prefer -fps_mode and fall back to -vsync on older FFmpeg builds.
fps_mode=(-fps_mode passthrough)
if ! ffmpeg -hide_banner -h full 2>/dev/null | grep -- '-fps_mode' >/dev/null; then
  fps_mode=(-vsync 0)
fi

ffmpeg -hide_banner -loglevel error -y -i "$source_file" \
  -filter_complex_threads 1 \
  -filter_complex "[0:v]scale=672:192:flags=lanczos,split=2[palette_input][gif_input];[palette_input]palettegen=max_colors=256:stats_mode=full[palette];[gif_input][palette]paletteuse=dither=bayer:bayer_scale=4[gif]" \
  -map '[gif]' -an -map_metadata -1 "${fps_mode[@]}" -loop 0 "$output_file"
