#!/usr/bin/env bash
set -euo pipefail
source_file=${1:-StreamOfFlowingWater.webm}
output_dir=${2:-.}
mkdir -p "$output_dir"
ffmpeg -hide_banner -loglevel error -y -ss 10 -i "$source_file" -t 3 \
  -map 0:v:0 -map 0:a:0 -vf 'fps=24,scale=-2:256,crop=256:256' \
  -c:v libx264 -threads 8 -pix_fmt yuv420p -c:a aac -ar 48000 -ac 2 \
  -map_metadata -1 "$output_dir/reference.mp4"
ffmpeg -hide_banner -loglevel error -y -ss 10 -i "$source_file" -t 3 \
  -map 0:a:0 -vn -c:a pcm_s16le -ar 44100 -ac 2 -map_metadata -1 \
  "$output_dir/reference.wav"
