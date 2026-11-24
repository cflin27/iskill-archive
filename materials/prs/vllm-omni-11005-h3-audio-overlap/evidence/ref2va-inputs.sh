#!/usr/bin/env bash
set -euo pipefail
# FFmpeg 4.4.2-0ubuntu0.22.04.1 was used for the recorded file hashes.
ffmpeg -hide_banner -loglevel error -y \
  -f lavfi -i 'testsrc2=size=256x256:rate=24:duration=3' \
  -f lavfi -i 'aevalsrc=0.2*sin(2*PI*440*t)|0.1*sin(2*PI*523*t):s=48000:d=3' \
  -map 0:v -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a aac reference.mp4
ffmpeg -hide_banner -loglevel error -y \
  -f lavfi -i 'aevalsrc=0.2*sin(2*PI*523*t)|0.1*sin(2*PI*659*t):s=44100:d=3' \
  reference.wav
