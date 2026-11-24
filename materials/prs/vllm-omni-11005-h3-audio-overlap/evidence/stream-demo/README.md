# Natural-scene demo evidence (public CC0 creek footage)

Demonstration pair for
[vllm-project/vllm-omni#11005](https://github.com/vllm-project/vllm-omni/pull/11005):
one Ref2VA request per arm on one excerpt of a public real-footage clip. It adds
no performance number, and no timing number is taken from it. The timing tables
in [../../validation-and-benefit.md](../../validation-and-benefit.md) keep their
own inputs: the eight-NPU end-to-end timing uses the FFmpeg `testsrc2`/`aevalsrc`
synthetic reference, and the single-NPU `encode_media` stage timing uses public
PyTorch synthetic tensors.

This directory contains no media binary: it keeps the public source, the exact
excerpt recipe, the request identity, the measured comparison and the recorded
hashes. The only presentation file published with the PR description is the
synchronized GIF in [`assets/`](../../assets/), transcoded from the two original
outputs. The trimmed inputs (`reference.mp4`, `reference.wav`) and the two
original output MP4s are not published there; their hashes are below, and the
scripts in this directory rebuild and compare them. `demo-media-source.md` is
the delivered evidence note; this README indexes it.

## Source and excerpt

| Item | Value |
| --- | --- |
| File | [`StreamOfFlowingWater.webm`](https://commons.wikimedia.org/wiki/File:StreamOfFlowingWater.webm) |
| Author | Patjos.scot |
| License | [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) (attribution not required; credited anyway) |
| Source size | 14,825,892 bytes |
| Commons SHA-1 | `373afa93e8f271a91a3675d978fce507f8fd386a` |
| Source SHA-256 | `26e471fdcd86dc91d4aa2a9a1eca0733b1761cad3c86d94196e3c6b60de4e96f` |
| Source streams | VP8 1440x1080 30 fps; Vorbis 48 kHz stereo |
| Excerpt | 10.000-13.000 s (3 s) of the 55.747 s source |
| Transform | Short edge scaled to 256 px, center-cropped 256x256, 24 fps; the excerpt's real audio kept as 48 kHz stereo AAC, and the same audio also supplied as 44.1 kHz stereo PCM |

Both inputs are rebuilt by `stream-inputs.sh`:

| Input | SHA-256 |
| --- | --- |
| `reference.mp4` | `c76e0b6de38411fc1bca13ef12d93a2e9e85e886ba1480f335a6128e594c36b9` |
| `reference.wav` | `9b758de40e81d5ff5b27fb5b73fbff88bfc8eae23c8eb3a6e2bf8de67e98bfd2` |

The recorded hashes were produced with FFmpeg 4.4.2. Encoders and resamplers
change bytes between FFmpeg versions: re-running `stream-inputs.sh` with FFmpeg
9.0.2 reproduced the identical excerpt window and geometry (3.000 s, 72 frames,
256x256, 24 fps, AAC 48 kHz stereo, PCM 44.1 kHz stereo) but different file
hashes. When the toolchain differs, compare the window, the geometry and the
per-arm invariants rather than an absolute hash.

## Request, identical on both arms

Ref2VA, 768x768, 24 fps, 4 s, 12 inference steps, flow_shift 12,
audio_flow_shift 3, seed 3101. Prompt, also in `stream-prompt.txt`:

> A steady close-up of a flowing stream. Preserve the natural water movement and the original scene, with realistic continuous flowing-water sounds and a steady camera.

Baseline `085d7dba33eca00f44753f8c4a5e11bd7c669f38`, PR
`80d6b6fc200be3b7499a2e6d7113d75261c2bdd6`, same 8-NPU Ascend 950PR
configuration as the benchmark run (USP8, text-encoder TP8, MXFP8 + RainFusion,
sparse window 8-12, distributed layerwise offload off, single-device VAE decode).

## Actual CPU resampling coverage

Runtime observation confirmed **two CPU 44.1 -> 32 kHz resampler calls per arm**,
stereo, 132,300 input and 96,000 output samples per call, with both input tensors
and filter kernels on CPU. The baseline calls ran in `encode_waveform` on the
main thread; the PR calls ran in `_prepare_waveform` on the audio-preparation
worker. The observation records metadata around the unchanged resampler call; it
is not a timing measurement. The full-clip input probe includes AAC padding, so
its sample count exceeds the runtime three-second reference span.

## Original output comparison

Compared on the unmodified original files, before any presentation encode.

| Check | Result |
| --- | --- |
| Original decoded video | 768x768, 107 frames, 24/1 fps, 4.458333 s; all frame timestamps identical |
| Per-frame maximum absolute RGB difference | 0 on every one of the 107 frames; MSE 0 |
| FFmpeg PSNR on decoded YUV444P | inf, all channels |
| FFmpeg SSIM on decoded YUV444P | 1.000000, all channels |
| Complete decoded PCM s16le | identical; maximum sample difference 0 |
| Original MP4 file | byte-identical |

Both original MP4 hashes:
`154337acbe94a294f8c8d1fd98adf21d137e2b53471c02b28e3cb86a15c7f9f9`.

Both decoded RGB24 hashes:
`c185218fcae50f16b2d8046a539a1bc0174402a1efea69128e2f41b0d0f8c4fd`.

Both decoded PCM s16le hashes:
`dd9f6433dc742fdd0614d15086cd024e4ef532e733725cf7bdf5e67d11ff5f6b`
(573,440 bytes at 32 kHz stereo, including decoder padding).

## Presentation comparison

`stream-baseline-vs-pr.mp4` is built from those originals by
`stream-comparison.sh`: 6,823,142 bytes, 1536x816, 107 frames, 24 fps,
4.458333 s, left **Baseline** and right **PR**, each side keeping the original
768x768 under a 48-pixel label strip, with the identical audio shared as one AAC
track. SHA-256
`92221fca6c878bb121f28bc228d59cf793e53413d1ee0992e2a0eb0a6cab6d61`;
libx264 medium, CRF 18, High@4.1, yuv420p, maxrate/bufsize 12M, faststart. The
MP4 itself is not published with the PR description.

The published presentation file is the silent GIF
[`assets/stream-baseline-vs-pr.gif`](../../assets/stream-baseline-vs-pr.gif),
transcoded from that MP4 by
[`assets/stream-gif.sh`](../../assets/stream-gif.sh): 9,861,406 bytes, 512x292,
107 frames, 4.460 s, infinite loop, left **Baseline** / right **PR**, SHA-256
`78bba61543bc75cbb46a619f70b4ef9cede4d3e9aedc8700a99d4fe029792dbe`.
GIF frame delays have 10 ms granularity; the recorded maximum timestamp rounding
difference from the MP4 is 5 ms, and both views always show the same paired
frame. [`assets/README.md`](../../assets/README.md) records the full identity and
transcode parameters. Every accuracy value above comes from the unmodified
original files, never from the MP4 or the GIF.

## Reproduction

Run from this directory with FFmpeg 4.4.2 for the recorded hashes:

```bash
curl -fL -o StreamOfFlowingWater.webm \
  'https://upload.wikimedia.org/wikipedia/commons/e/e0/StreamOfFlowingWater.webm'
sha256sum StreamOfFlowingWater.webm   # 26e471fd...4e96f
bash stream-inputs.sh StreamOfFlowingWater.webm .
```

Start one compatible service from baseline `085d7dba` and one from candidate
`80d6b6fc`, each exposing `/v1/videos/sync`, then send the same request to both
and compare the two saved outputs:

```bash
export BASELINE_API_URL='http://baseline-host:8000'
export CANDIDATE_API_URL='http://candidate-host:8000'
for arm in baseline candidate; do
  case "$arm" in
    baseline) api_url="${BASELINE_API_URL}" ;;
    candidate) api_url="${CANDIDATE_API_URL}" ;;
  esac
  curl -fsS "${api_url}/v1/videos/sync" \
    -F "prompt=$(cat stream-prompt.txt)" \
    -F 'width=768' -F 'height=768' -F 'fps=24' \
    -F 'num_inference_steps=12' -F 'flow_shift=12' -F 'seed=3101' \
    -F 'extra_params={"task":"ref2va","duration":4.0,"audio_flow_shift":3.0}' \
    -F 'input_references=@reference.mp4;type=video/mp4' \
    -F 'input_references=@reference.wav;type=audio/wav' \
    -o "${arm}.mp4"
done
bash stream-comparison.sh baseline.mp4 candidate.mp4 stream-baseline-vs-pr.mp4
```

`stream-metrics.json` records the per-frame differences, frame timestamps, hashes
and the resampler calls; `stream-source.json` records the source metadata, the
excerpt window, the prompt and the request. Input transformations use the
documented FFmpeg [fps](https://ffmpeg.org/ffmpeg-filters.html#fps),
[scale](https://ffmpeg.org/ffmpeg-filters.html#scale),
[crop](https://ffmpeg.org/ffmpeg-filters.html#crop),
[hstack](https://ffmpeg.org/ffmpeg-filters.html#hstack) and
[drawtext](https://ffmpeg.org/ffmpeg-filters.html#drawtext) filters.
