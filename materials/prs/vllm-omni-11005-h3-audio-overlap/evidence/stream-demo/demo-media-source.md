# Natural stream demonstration for MiniMax-H3 PR #11005

The comparison uses one real-footage demonstration request per arm. Both requests
returned HTTP 200 and their video and audio decoded successfully. The synthetic
benchmark remains the source of the existing performance numbers.

## Source and excerpt

- Original: [StreamOfFlowingWater.webm](https://commons.wikimedia.org/wiki/File:StreamOfFlowingWater.webm).
- Creator/publisher: **Patjos.scot**; source license: **CC0 1.0**
  ([public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/)).
- Commons original identity: 14,825,892 bytes,
  SHA-1 `373afa93e8f271a91a3675d978fce507f8fd386a`.
- Original SHA-256:
  `26e471fdcd86dc91d4aa2a9a1eca0733b1761cad3c86d94196e3c6b60de4e96f`.
- Source media: VP8, 1440×1080, 30 fps; Vorbis, 48 kHz stereo; 55.747 s per Commons metadata.
- Excerpt: **10.000–13.000 s**, 3 s. Scale the short edge to 256 and center-crop
  256×256; convert to 24 fps. The reference MP4 retains the excerpt's real audio
  as 48 kHz stereo AAC. A second reference WAV contains the same excerpt's
  original sound at 44.1 kHz stereo PCM.

Input SHA-256:

| Input | SHA-256 |
| --- | --- |
| `reference.mp4` | `c76e0b6de38411fc1bca13ef12d93a2e9e85e886ba1480f335a6128e594c36b9` |
| `reference.wav` | `9b758de40e81d5ff5b27fb5b73fbff88bfc8eae23c8eb3a6e2bf8de67e98bfd2` |

The exact shared prompt is:

> A steady close-up of a flowing stream. Preserve the natural water movement and the original scene, with realistic continuous flowing-water sounds and a steady camera.

Both arms used seed **3101**, requested output 768×768, 24 fps, 4 s, 12 inference
steps, flow_shift 12 and audio_flow_shift 3. Hardware/configuration remained
8×Ascend 950PR, USP8, text-encoder TP8, MXFP8 and RainFusion with sparse window
8–12, distributed layerwise offload disabled, single-device VAE decoding.

Baseline: `085d7dba33eca00f44753f8c4a5e11bd7c669f38`.
PR: `80d6b6fc200be3b7499a2e6d7113d75261c2bdd6`.

## Actual CPU resampling coverage

The reference loader converts embedded audio to 44.1 kHz; the standalone WAV is
also 44.1 kHz. Runtime observation confirmed **two CPU 44.1→32 kHz resampler
calls per arm**, each with two channels and 132,300 input / 96,000 output samples.
Both input tensors and filter kernels were on CPU. The baseline calls occurred
in `encode_waveform` on the main thread; the PR calls occurred in
`_prepare_waveform` on the audio preparation worker. The observation only records
metadata around the unchanged resampler call. This demonstration is not a timing
benchmark. The full-clip input probe includes AAC padding; the runtime reference
span is three seconds.

## Original output comparison

Compare all original decoded frames before presentation encoding: 8-bit RGB24,
768×768, **107 frames at 24 fps**, video duration **4.458333 s**. All frame
timestamps match. Each of the 107 per-frame maximum absolute RGB differences is
zero. FFmpeg PSNR/SSIM compare decoded YUV444P from those same original files.

| Measure | Result |
| --- | --- |
| Original frame alignment | All 107 timestamps identical |
| Maximum absolute RGB difference / MSE | **0 / 0** |
| FFmpeg PSNR | **∞**, all channels |
| FFmpeg SSIM | **1.000000**, all channels |
| PCM s16le comparison | Identical, maximum sample difference **0** |
| Original MP4 file comparison | Identical SHA-256 |

Both original MP4 hashes:
`154337acbe94a294f8c8d1fd98adf21d137e2b53471c02b28e3cb86a15c7f9f9`.

Both decoded RGB24 hashes:
`c185218fcae50f16b2d8046a539a1bc0174402a1efea69128e2f41b0d0f8c4fd`.

Both complete decoded PCM s16le hashes:
`dd9f6433dc742fdd0614d15086cd024e4ef532e733725cf7bdf5e67d11ff5f6b`.
PCM contains 573,440 bytes at 32 kHz stereo, including decoder padding.

## Comparison MP4 and reproduction

`stream-baseline-vs-pr.mp4`: **6,823,142 bytes**, 1536×816, 107 frames,
24 fps, 4.458333 s. Left **Baseline**, right **PR**. Each side retains the
original 768×768 with a 48-pixel label strip. The identical baseline AAC audio
is copied as a shared track; the comparison's decoded PCM matches the originals.

Comparison MP4 SHA-256:
`92221fca6c878bb121f28bc228d59cf793e53413d1ee0992e2a0eb0a6cab6d61`.

Encoding: libx264 medium, CRF 18, High@4.1, YUV420P, maxrate/bufsize 12M,
faststart. The MP4 is a presentation encode; accuracy values above refer to the
unmodified original outputs. Video decoding and the label preview were checked.

With FFmpeg 4.4.2, prepare the excerpt using `stream-inputs.sh` and create the
comparison using `stream-comparison.sh`:

```bash
curl -fL 'https://upload.wikimedia.org/wikipedia/commons/e/e0/StreamOfFlowingWater.webm' -o StreamOfFlowingWater.webm
bash stream-inputs.sh StreamOfFlowingWater.webm .
bash stream-comparison.sh baseline.mp4 candidate.mp4 stream-baseline-vs-pr.mp4
```

Input transformations use publicly documented FFmpeg
[fps](https://ffmpeg.org/ffmpeg-filters.html#fps),
[scale](https://ffmpeg.org/ffmpeg-filters.html#scale),
[crop](https://ffmpeg.org/ffmpeg-filters.html#crop),
[hstack](https://ffmpeg.org/ffmpeg-filters.html#hstack) and
[drawtext](https://ffmpeg.org/ffmpeg-filters.html#drawtext).
The original inputs are real Commons footage and sound; FFmpeg is the preparation
tool. Detailed source/request metadata, timestamps and actual resampling evidence
are in `stream-source.json` and `stream-metrics.json`.

Keep this material in a separate `evidence/stream-demo/` directory so the existing
synthetic benchmark inputs and statistics remain identifiable.
