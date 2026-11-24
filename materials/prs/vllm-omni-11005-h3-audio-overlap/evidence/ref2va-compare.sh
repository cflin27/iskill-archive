#!/usr/bin/env bash
set -euo pipefail
# Inputs: baseline.mp4 and candidate.mp4, paired from the same formal request.
# FFmpeg drawtext requires a readable font; this is the standard DejaVu path.
# Accuracy checks use full-resolution decoded frames, before GIF processing.
for arm in baseline candidate; do
  ffprobe -v error -count_frames -select_streams v:0 \
    -show_entries stream=width,height,r_frame_rate,avg_frame_rate,nb_read_frames,duration \
    -of json "$arm.mp4"
  ffmpeg -v error -xerror -y -i "$arm.mp4" -map 0:v:0 \
    -pix_fmt rgb24 -vsync 0 -f rawvideo "$arm.rgb"
  ffmpeg -v error -xerror -y -i "$arm.mp4" -map 0:a:0 \
    -f s16le -acodec pcm_s16le "$arm.pcm"
done
# For this pair, byte equality proves maximum RGB absolute difference is zero.
cmp baseline.rgb candidate.rgb
sha256sum baseline.rgb candidate.rgb baseline.pcm candidate.pcm
ffmpeg -hide_banner -i baseline.mp4 -i candidate.mp4 -filter_complex_threads 1 \
  -lavfi '[0:v]format=yuv444p,setpts=PTS-STARTPTS[b];[1:v]format=yuv444p,setpts=PTS-STARTPTS[c];[b][c]psnr' \
  -an -f null -
ffmpeg -hide_banner -i baseline.mp4 -i candidate.mp4 -filter_complex_threads 1 \
  -lavfi '[0:v]format=yuv444p,setpts=PTS-STARTPTS[b];[1:v]format=yuv444p,setpts=PTS-STARTPTS[c];[b][c]ssim' \
  -an -f null -

font_file=${FONT_FILE:-/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf}
ffmpeg -hide_banner -loglevel error -y \
  -i baseline.mp4 -i candidate.mp4 -filter_complex_threads 1 \
  -filter_complex "[0:v]setpts=PTS-STARTPTS,scale=384:384:flags=lanczos,pad=iw:ih+36:0:36:color=black,drawtext=fontfile=${font_file}:text='Baseline':fontcolor=white:fontsize=20:x=(w-tw)/2:y=7[left];[1:v]setpts=PTS-STARTPTS,scale=384:384:flags=lanczos,pad=iw:ih+36:0:36:color=black,drawtext=fontfile=${font_file}:text='Candidate':fontcolor=white:fontsize=20:x=(w-tw)/2:y=7[right];[left][right]hstack=inputs=2:shortest=1,split=2[palette_input][gif_input];[palette_input]palettegen=stats_mode=full[palette];[gif_input][palette]paletteuse=dither=bayer:bayer_scale=3[gif]" \
  -map '[gif]' -an -map_metadata -1 -metadata comment= \
  -vsync 0 -frames:v 107 -loop 0 ref2va-baseline-vs-candidate.gif
