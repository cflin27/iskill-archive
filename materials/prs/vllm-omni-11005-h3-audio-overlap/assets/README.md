# Presentation media

One file is published from this archive:
`stream-baseline-vs-pr.gif`, the synchronized natural-scene demonstration pair of
[vllm-project/vllm-omni#11005](https://github.com/vllm-project/vllm-omni/pull/11005),
left **Baseline** and right **PR**. It is the only presentation media delivered
with the PR description; the accuracy evidence stays in
[`../evidence/`](../evidence/).

| Item | Value |
| --- | --- |
| File | `stream-baseline-vs-pr.gif` |
| Bytes | 9,861,406 |
| SHA-256 | `78bba61543bc75cbb46a619f70b4ef9cede4d3e9aedc8700a99d4fe029792dbe` |
| Geometry | 512x292; each scene 256x256 under a 36-pixel label strip |
| Frames / duration | 107 frames (every paired frame) / 4.460 s, 24/1 nominal |
| Playback | infinite loop; no audio track |
| Source MP4 | `stream-baseline-vs-pr.mp4`, 6,823,142 bytes, SHA-256 `92221fca6c878bb121f28bc228d59cf793e53413d1ee0992e2a0eb0a6cab6d61` (not published) |
| Source frames | the two original 768x768, 107-frame outputs of the CC0 creek excerpt in `../evidence/stream-demo/`, byte-identical |
| Transcode | `stream-gif.sh`: FFmpeg 4.4.2, DejaVu Sans, crops the accepted MP4's 48-pixel label strip, Lanczos-scales each scene to 256x256, redraws the `Baseline` / `PR` labels, one shared 256-color palette with Bayer dither 4, keeps all 107 frames, strips metadata |

GIF frame delays have 10 ms granularity; the recorded maximum timestamp rounding
difference from the accepted MP4 is 5 ms, and both views always show the same
paired frame. The GIF is presentation-only: every RGB, PSNR, SSIM and PCM value
in `../evidence/` was measured on the original decoded outputs, never on this
file.

Rebuild it from the two-arm outputs:

```bash
# From the paired outputs: comparison MP4 first, then the GIF.
bash ../evidence/stream-demo/stream-comparison.sh baseline.mp4 candidate.mp4 stream-baseline-vs-pr.mp4
bash stream-gif.sh stream-baseline-vs-pr.mp4 stream-baseline-vs-pr.gif
```

The paired outputs and the trimmed inputs are not published here; rebuild them
with `../evidence/stream-demo/stream-inputs.sh` and send the same request to both
arms as documented in
[`../evidence/stream-demo/README.md#reproduction`](../evidence/stream-demo/README.md#reproduction).
