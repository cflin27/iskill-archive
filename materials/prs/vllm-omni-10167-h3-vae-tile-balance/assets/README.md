# Presentation media

One file is published from this directory:
`pr10167-ref2va-formal-comparison.gif`, the synchronized comparison pair for
[vllm-project/vllm-omni#10167](https://github.com/vllm-project/vllm-omni/pull/10167),
left **Baseline** and right **Candidate**. It is the presentation copy delivered
with the PR description; the accuracy evidence stays in
[`../evidence/`](../evidence/).

| Item | Value |
| --- | --- |
| File | `pr10167-ref2va-formal-comparison.gif` |
| Bytes | 7,017,781 |
| SHA-256 | `272b0c9e0ab0866db3d4b57691773d078547a414498b8d264df9a0871011a24f` |
| Geometry | 672×192; each view 336×192; the `Baseline` / `Candidate` labels are part of the source frames |
| Frames / duration | 124 frames (every paired frame) / 5.170 s, 24/1 nominal |
| Playback | infinite loop; no audio track |
| Source MP4 | `pr10167-ref2va-formal-comparison.mp4`, 562,319 bytes, SHA-256 `681c8c2fd50b51f986a8cfd61a791a1e898e1660e60ffd7679c93167f14731ac`, 1344×384, 124 frames at 24 fps, AAC 32 kHz stereo (not published in this repository) |
| Source frames | the first formal 50 NFE output pair: same public prompt, reference video, audio and seed 0; left baseline, right candidate |
| Transcode | `gif.sh`: FFmpeg 9.0.2, Lanczos scale to 672×192, one shared 256-color palette with Bayer dither 4, every one of the 124 frames, audio stripped, metadata stripped |

GIF frame delays have 10 ms granularity; the recorded maximum timestamp rounding
difference from the source MP4 is 5 ms, and both views always show the same
paired frame. The GIF is presentation-only: every RGB, PSNR, SSIM and PCM value
in `../evidence/` was measured on the original decoded outputs, never on this
file.

Rebuild it from the accepted MP4:

```bash
bash gif.sh pr10167-ref2va-formal-comparison.mp4 pr10167-ref2va-formal-comparison.gif
```

The formal comparison MP4 contains stereo AAC audio. The GIF export strips the audio track. The
paired original outputs are not published here; the public input sources and the
measured setup are recorded in [`../validation-and-benefit.md`](../validation-and-benefit.md).
