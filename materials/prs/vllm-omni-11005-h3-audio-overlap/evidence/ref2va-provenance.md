# MiniMax-H3 Ref2VA comparison for PR #11005

This document covers the **synthetic benchmark pair** that produced the timing
numbers and the paired accuracy comparison recorded here. No natural-scene or
private media is part of this evidence.

The synchronized comparison is built from the first timed request of formal
round 1: left is the baseline without CPU audio-preparation overlap, right is
the candidate. Both original outputs were generated with the same synthetic
reference media, prompt, seed 3101 and parameters. The comparison reuses the
saved formal outputs; it does not add inference runs or change the performance
samples. Presentation media is not committed here; this document records the
method, inputs and hashes.

Baseline commit: `085d7dba33eca00f44753f8c4a5e11bd7c669f38`.
Candidate commit: `80d6b6fc200be3b7499a2e6d7113d75261c2bdd6`.
Both arms used eight Ascend950PR devices, USP8, text-encoder TP8, the same
MXFP8/RainFusion configuration, no distributed layerwise offload and single-device
VAE decoding. The comparison evaluates the PR's scheduling change under that
shared configuration; quantization relative to BF16 is outside this comparison.

## Original output comparison

All accuracy checks ran on original decoded media before scaling, labels or GIF
palette conversion. Video was decoded to 8-bit RGB24 without frame-rate conversion;
all 107 frames and all 189,333,504 RGB components were compared. Every frame's
maximum absolute difference was zero, and all frame timestamps matched.

| Metric | Baseline | Candidate / comparison |
| --- | --- | --- |
| Original decoded video | 768×768, 107 frames, 24/1 fps | Identical dimensions, count, rate and timestamps |
| Encoded video stream duration | 4.458333 s | 4.458333 s |
| Maximum RGB absolute difference | — | **0**, across all original frames |
| Different RGB components / MSE | — | **0 / 0** |
| FFmpeg PSNR after decoding to YUV444P | — | **∞**, all channels |
| FFmpeg SSIM after decoding to YUV444P | — | **1.000000**, all channels |
| Audio stream | Stereo, 32 kHz, 4.450000 s | Same stream metadata |
| Complete decoded PCM s16le | 573,440 bytes | Identical SHA-256 |

Both original MP4 file hashes:
`6b7fc2c238eb89310d26c105a1851bd38f1bdfa6014e7695026d24b4fc4e2005`.

Both decoded RGB24 hashes:
`c9522da42854108496eeb0a6b5abfd1438b11af6cd30f78cb433659fc7383d64`.

Both complete decoded PCM s16le hashes:
`4089f1e925262b2ae9cde8aee194ad211fac99184a19ac3d2e623ff3d6377874`.
PCM hashing preserves the decoder's complete output, including codec padding.

`ref2va-baseline-vs-candidate.gif` keeps all 107 paired frames. Each side is
displayed at 384×384 below a 36-pixel label strip; the composite is 768×420.
The GIF loops, lasts 4.46 s and shows **Baseline** on the left and **Candidate**
on the right. GIF frame delays have 10 ms granularity; both arms share each
composite frame. Accuracy values above come from the original media.

## Public input provenance

The reference video and audio are synthesized solely from publicly documented
FFmpeg source filters. No prerecorded private media or private dataset is used.
The current input files matched the recorded manifest. Regenerating the recipe
with FFmpeg `4.4.2-0ubuntu0.22.04.1` reproduced **both complete file hashes exactly**:

| File | Public synthesis recipe | SHA-256, recorded = current = regenerated |
| --- | --- | --- |
| `reference.mp4` | `testsrc2`, 256×256, 24 fps, 3 s; stereo 440/523 Hz sine audio at 48 kHz; libx264 + AAC | `854513a1611c5357192fa3ee0eea8d75af8271b345afcb0c8094d3ab9404aba4` |
| `reference.wav` | Stereo 523/659 Hz sine audio, 44.1 kHz, 3 s | `f2aa72c0412df1fd17350152ea4c7652803ad399d455627906c22a7d81752eeb` |

The archived HTTP synthesis harness, stage synthesis harness and request launcher
also matched their recorded hashes. This handoff includes verified synthetic media,
portable recipes and summarized evidence.

Official FFmpeg sources:

- [testsrc2](https://ffmpeg.org/ffmpeg-filters.html#testsrc2)
- [aevalsrc](https://ffmpeg.org/ffmpeg-filters.html#aevalsrc)
- [hstack](https://ffmpeg.org/ffmpeg-filters.html#hstack),
  [drawtext](https://ffmpeg.org/ffmpeg-filters.html#drawtext),
  [palettegen](https://ffmpeg.org/ffmpeg-filters.html#palettegen),
  [paletteuse](https://ffmpeg.org/ffmpeg-filters.html#paletteuse)

Minimal input generation and GIF/accuracy commands are in `ref2va-inputs.sh` and
`ref2va-compare.sh`. Run them in the material directory:

```bash
bash ref2va-inputs.sh
bash ref2va-compare.sh
```

The exact original prompt, also supplied in `ref2va-prompt.txt`, is:

> Preserve the motion in the reference video and match the audio.

The original request used width/height 768, fps 24, 12 inference steps,
flow_shift 12, audio_flow_shift 3, task ref2va, requested duration 4 s and seed 3101.
For a locally started compatible service, the original request fields are:

```bash
curl -fsS "${API_URL}/v1/videos/sync" \
  -F 'prompt=Preserve the motion in the reference video and match the audio.' \
  -F 'width=768' -F 'height=768' -F 'fps=24' \
  -F 'num_inference_steps=12' -F 'flow_shift=12' -F 'seed=3101' \
  -F 'extra_params={"task":"ref2va","duration":4.0,"audio_flow_shift":3.0}' \
  -F 'input_references=@reference.mp4;type=video/mp4' \
  -F 'input_references=@reference.wav;type=audio/wav' -o output.mp4
```

### Stage synthetic inputs

The separate stage experiment generated 25 uint8 RGB frames of shape 128×128×3
using `torch.randint(0, 256, ...)`, plus 15 s of 44.1 kHz stereo float audio:
left `0.2*sin(2*pi*440*t)`, right `0.1*sin(2*pi*523*t)`.
It used CPU/NPU seed 3101, set before constructing the encoder-only VAEs, and
sampled frames after their construction. This ordering is part of the recorded
RNG sequence. The minimal input operations are in `stage_synthetic_input.py`.
They are an authored synthetic recipe using public PyTorch APIs, rather than a
downloaded image/video dataset.

Public API sources: [manual_seed](https://docs.pytorch.org/docs/stable/generated/torch.manual_seed.html),
[randint](https://docs.pytorch.org/docs/stable/generated/torch.randint.html),
[arange](https://docs.pytorch.org/docs/stable/generated/torch.arange.html),
[sin](https://docs.pytorch.org/docs/stable/generated/torch.sin.html).

### Unit-test inputs and source

The existing unit corpus is public repository source pinned to original PR head
`2132f8b9c02f973d7041daab01c55e0e4fa6bacc`:

- [audio overlap](https://github.com/vllm-project/vllm-omni/blob/2132f8b9c02f973d7041daab01c55e0e4fa6bacc/tests/model_executor/models/test_minimax_h3_audio_overlap.py)
- [audio preprocessing](https://github.com/vllm-project/vllm-omni/blob/2132f8b9c02f973d7041daab01c55e0e4fa6bacc/tests/model_executor/models/test_minimax_h3_audio_preprocessing.py)
- [encoder payload](https://github.com/vllm-project/vllm-omni/blob/2132f8b9c02f973d7041daab01c55e0e4fa6bacc/tests/model_executor/models/test_minimax_h3_encoder_payload.py)
- [audio VAE](https://github.com/vllm-project/vllm-omni/blob/2132f8b9c02f973d7041daab01c55e0e4fa6bacc/tests/diffusion/models/minimax_h3/test_minimax_h3_audio_vae.py)
- [timeline guides](https://github.com/vllm-project/vllm-omni/blob/2132f8b9c02f973d7041daab01c55e0e4fa6bacc/tests/diffusion/models/minimax_h3/test_minimax_h3_timeline_guides.py)

Audio-preprocessing tests synthesize a 440 Hz sine via
`torch.sin((torch.arange(rate*seconds)/rate)*880*torch.pi)` and zero video tensors.
The candidate's channel-order check adapts that public synthetic recipe to distinct
channel amplitudes `(channel_index+1)/channels`; sample rates are 16/32/44.1 kHz,
with 1/2/3 channels. This adaptation introduces no external data.

The allocator follow-up used the same
[encoder-payload case at target main](https://github.com/vllm-project/vllm-omni/blob/9b753874d73fb40204418a457d22d802b731d19f/tests/model_executor/models/test_minimax_h3_encoder_payload.py).
That file and the encoder file matched between target main, original PR head and
candidate. The case's allocator failure is retained in the validation record.

## Comparison media names

- `ref2va-baseline-vs-candidate.gif`: synchronized comparison built from the
  paired formal outputs (presentation media, not committed here).
- `ref2va-provenance.md`: public input sources, prompt, comparison method and
  limits.
- `ref2va-metrics.json`: per-frame differences, timestamps and hashes.
- `ref2va-inputs.sh`, `ref2va-compare.sh`, `ref2va-prompt.txt`: minimal
  reproduction inputs.
- `stage_synthetic_input.py`: stage synthetic input operations and source
  references.
- `baseline.mp4`, `candidate.mp4`: the paired outputs the reproduction section
  produces and compares (not committed here).
- `reference.mp4`, `reference.wav`: public inputs rebuilt by
  `ref2va-inputs.sh` (not committed here).

## Reusable observation

Verify media provenance by regenerating public synthesis recipes and matching
recorded hashes. Compare original decoded frames before presentation transforms,
then keep paired frames in one labeled composite so playback stays synchronized.
