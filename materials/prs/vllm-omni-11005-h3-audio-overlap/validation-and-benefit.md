# Validation and Benefit

## Summary

- Public PR:
  [vllm-project/vllm-omni#11005](https://github.com/vllm-project/vllm-omni/pull/11005)
- Public baseline: `085d7dba33eca00f44753f8c4a5e11bd7c669f38` (no-overlap
  commit, verified parent of the original PR head `2132f8b9`).
- Candidate: `80d6b6fc200be3b7499a2e6d7113d75261c2bdd6`.
- Target-branch control: `9b753874d73fb40204418a457d22d802b731d19f`.
- Result: component `encode_media` wall time -1.202%; end-to-end mean latency
  -0.092% (within noise, no E2E speedup claimed); on the synthetic benchmark
  pair, output bit-identical across 107 frames, audio and the encoded MP4.
- Demonstration: on a 10.000-13.000 s excerpt of public CC0 creek footage, one
  request per arm also decoded bit-identically (107/107 frames, max RGB
  difference 0, PSNR inf, SSIM 1.000000, identical PCM and MP4 hashes), with two
  CPU 44.1 -> 32 kHz resampler calls per arm observed. No timing number comes
  from this pair.

## Environment

- Repository: public `vllm-project/vllm-omni`.
- Model or workload: `MiniMaxAI/MiniMax-H3` Ref2VA (reference video and audio
  conditioning).
- End-to-end timing input: FFmpeg `testsrc2` 256x256 24 fps 3 s video with
  48 kHz stereo sine audio (`reference.mp4`), plus a 44.1 kHz stereo sine file
  (`reference.wav`); both reproduced from the recipes in `evidence/` with
  matching SHA-256. Every **end-to-end** latency number in this file comes from
  this input.
- Component-stage timing input: public PyTorch ops only — 25 synthetic
  128x128 RGB frames and 15 s of 44.1 kHz stereo sine audio
  (`evidence/stage_synthetic_input.py`). The **component-stage and host
  call-interval** numbers come from this input, not from the FFmpeg media.
- Demonstration input: a 10.000-13.000 s excerpt of the public CC0 1.0 clip
  [StreamOfFlowingWater.webm](https://commons.wikimedia.org/wiki/File:StreamOfFlowingWater.webm)
  by Patjos.scot, rebuilt by `evidence/stream-demo/stream-inputs.sh`. The demo
  contributes the accuracy record below and no performance number.
- Hardware: Ascend 950PR, 8 NPUs for end-to-end (USP8, text-encoder TP8), one
  NPU for the component stage.
- Runtime: vLLM 0.34.0, CANN 9.3.0, torch/torchaudio 2.10.0,
  torch_npu 2.10.0.post7, Python 3.12.13, ffmpeg 4.4.2; public A5 image digest
  `sha256:43a87842...` built from `3c885f434`.
- Configuration: MXFP8 + RainFusion, sparse window 8-12, 12 denoising steps,
  distributed layerwise offload off, single-device VAE decoding.
- Timing: 3 rounds x 20 formal requests per arm; 3 warmups per service start
  excluded from statistics; profiler and stage tracing off for formal runs.

## Correctness

The baseline column is the no-overlap commit `085d7dba` and the candidate column
is `80d6b6fc` unless a cell names a different commit. Every row in this table and
every latency number in this file comes from the synthetic inputs described under
Environment; the demonstration subsection below names its own input and
contributes no latency number.

| Check | Baseline | Candidate | Result |
| --- | --- | --- | --- |
| Waveform preparation samples, 16/32/44.1 kHz x 1/2/3 channels | synchronous path | worker path | sample-exact against `torchaudio` reference |
| Conditioning tensors (visual `[112, 96]`, audio `[1200, 32]`, lengths `[600]`, `ref_blocks`) | recorded | same | bit-identical across baseline, PR and original head |
| 8-NPU decoded RGB SHA-256 | `c9522da4...3d64` | same | identical for all 140 outputs |
| Decoded PCM s16le SHA-256 | `4089f1e9...7874` | same | identical |
| Comparison pair MP4 SHA-256 | `6b7fc2c2...2005` | same | byte-identical files |
| 107-frame RGB24 comparison (189,333,504 components) | - | - | max absolute difference 0 |
| FFmpeg PSNR / SSIM (YUV444P) | - | - | PSNR inf; SSIM 1.000000 |
| Media metadata | 768x768, 107 frames, 24 fps, 4.458333 s | same | timestamps identical |
| CPU unit tests, five files | original PR head `2132f8b9`: 70 passed, 1 failed | candidate `80d6b6fc`: 70 passed, 1 failed | the same failure also reproduces on target `main` (single-case check); the performance baseline `085d7dba` predates the new test file and did not run the five-file set |

The single unit-test failure is
`test_make_omni_output_mixed_warmup_and_real_request_metadata`, failing at
`vllm_omni/model_executor/models/minimax_h3/encoder.py:216` on
`torch.accelerator.empty_cache()` with
`Allocator for npu is not a DeviceAllocator.` in a no-device container. The same
case fails on target `main` and on the original PR head with identical
encoder/test hashes; the case's later assertions did not run and it is not
counted as passing. Failure-path coverage (visual-encode error cancels queued
work and joins the worker; preparation error propagates after join) and
fallback coverage (non-leader, native rate, audio-only, CPU autocast) are CPU
unit tests; no NPU failure injection was run.

### Natural-scene demonstration pair

One Ref2VA request per arm on the public CC0 excerpt; source, excerpt window,
input hashes, prompt, seed, resampler records and the full comparison are in
`evidence/stream-demo/`.

| Check | Result |
| --- | --- |
| Inputs (both arms) | `reference.mp4` SHA-256 `c76e0b6d...c36b9`, `reference.wav` `9b758de4...bfd2`; prompt and seed 3101 identical |
| Output media | 768x768, 107 frames, 24 fps, 4.458333 s; identical on both arms |
| Max absolute RGB difference | 0 on all 107 frames (MSE 0) |
| FFmpeg PSNR / SSIM (YUV444P) | PSNR inf; SSIM 1.000000, all channels |
| Decoded PCM s16le | identical; maximum sample difference 0 |
| Original MP4 files | byte-identical, SHA-256 `154337ac...f9f9` |
| Actual resampling coverage | two CPU 44.1 -> 32 kHz calls per arm, stereo, 132,300 -> 96,000 samples; baseline on the main thread in `encode_waveform`, PR on the audio-preparation worker in `_prepare_waveform` |

The pair is a correctness demonstration, not a timing sample: the demo request
was not measured and adds no latency number to this file. Byte-level PCM and RGB
hashes depend on the FFmpeg build; the invariant asserted here is that both arms
are identical. The recorded hashes use the validation environment's FFmpeg 4.4.2.

## Performance

End-to-end, 8 NPUs, fixed public synthetic request (FFmpeg `testsrc2`/`aevalsrc`
reference video and audio; 768x768, 24 fps, 4 s, seed 3101):

| Round | Arm | n | Mean (s) | p50 (s) | p90 (s) | Effective req/s |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 1 | baseline | 20 | 13.218 | 13.178 | 13.379 | 0.075656 |
| 1 | PR | 20 | 13.267 | 13.212 | 13.481 | 0.075377 |
| 2 | baseline | 20 | 13.255 | 13.235 | 13.290 | 0.075445 |
| 2 | PR | 20 | 13.193 | 13.192 | 13.211 | 0.075799 |
| 3 | baseline | 20 | 13.215 | 13.210 | 13.237 | 0.075673 |
| 3 | PR | 20 | 13.191 | 13.190 | 13.231 | 0.075808 |

| Metric | Baseline | PR | Delta | Notes |
| --- | ---: | ---: | ---: | --- |
| Mean latency (3-round mean) | 13.229 s | 13.217 s | -0.092% | within round-to-round spread |
| p50 latency | 13.208 s | 13.198 s | -0.073% | |
| p90 latency | 13.302 s | 13.308 s | +0.042% | largest round-level change +0.76% (round-1 p90, +0.764775% by linear interpolation over the 20 raw requests per arm) |
| Effective throughput | 0.075591 req/s | 0.075661 req/s | +0.092% | 1 / request latency |
| HTTP/decode errors | 0/60 | 0/60 | - | per-round gate 3% not exceeded |

Component stage, one NPU with real weights, public PyTorch synthetic input
(25 frames of 128x128 video and 15 s of 44.1 kHz stereo audio, seed 3101),
30 timed calls per version:

| Version | Mean encode_media (ms) | Round means (ms) | vs baseline |
| --- | ---: | --- | ---: |
| `085d7dba` | 155.998 | 156.193 / 155.838 / 155.962 | - |
| `80d6b6fc` | 154.123 | 154.176 / 154.160 / 154.033 | -1.202% |
| `2132f8b9` | 154.085 | 154.332 / 154.147 / 153.777 | -1.226% |

Host call intervals (5 runs, not NPU kernel time): CPU waveform preparation
`3.003 -> 4.523 ms` (**+50.596%**, with 4.336 ms overlapped by visual encoding),
visual encoding `84.070 -> 84.422 ms`, audio encoding incl. preparation
`71.929 -> 68.670 ms`. The preparation interval grows because the candidate
counts both the worker-thread preparation and the short in-call preparation of
already-resampled waveforms; it is a scheduling result, not CPU-operator
speedup.

The natural-scene demonstration pair is a correctness demonstration, not a
timing sample, and contributes no number to the tables above.

## Reproduction

Public-only commands. Two directories are used: the `vllm-omni` source tree for
the CPU unit tests, and this archive's
`materials/prs/vllm-omni-11005-h3-audio-overlap/` directory for the public input
recipes and the comparison scripts.

```bash
# 1) Source tree: CPU regression only.
git clone https://github.com/vllm-project/vllm-omni
cd vllm-omni
git checkout 80d6b6fc200be3b7499a2e6d7113d75261c2bdd6
pytest -q \
  tests/model_executor/models/test_minimax_h3_audio_preprocessing.py \
  tests/model_executor/models/test_minimax_h3_audio_overlap.py \
  tests/diffusion/models/minimax_h3/test_minimax_h3_audio_vae.py \
  tests/model_executor/models/test_minimax_h3_encoder_payload.py \
  tests/diffusion/models/minimax_h3/test_minimax_h3_timeline_guides.py
# No-device allocator caveat: see Limits.

# 2) Archive directory: rebuild the public reference inputs.
git clone https://github.com/cflin27/iskill-archive
cd iskill-archive/materials/prs/vllm-omni-11005-h3-audio-overlap
bash evidence/ref2va-inputs.sh
```

Start one compatible service from baseline `085d7dba` and one from candidate
`80d6b6fc` with the same image, weights and parameters; each must expose
`/v1/videos/sync`. Run the next block in the archive directory created by step 2:
it first exports both base URLs, then sends the same request and the same
`reference.mp4`/`reference.wav` to each arm and saves one MP4 per arm in that
directory.

```bash
# 3) Set both service base URLs (replace the example hosts, no trailing slash).
export BASELINE_API_URL='http://baseline-host:8000'
export CANDIDATE_API_URL='http://candidate-host:8000'

for arm in baseline candidate; do
  case "$arm" in
    baseline) api_url="${BASELINE_API_URL}" ;;
    candidate) api_url="${CANDIDATE_API_URL}" ;;
  esac
  curl -fsS "${api_url}/v1/videos/sync" \
    -F 'prompt=Preserve the motion in the reference video and match the audio.' \
    -F 'width=768' -F 'height=768' -F 'fps=24' \
    -F 'num_inference_steps=12' -F 'flow_shift=12' -F 'seed=3101' \
    -F 'extra_params={"task":"ref2va","duration":4.0,"audio_flow_shift":3.0}' \
    -F 'input_references=@reference.mp4;type=video/mp4' \
    -F 'input_references=@reference.wav;type=audio/wav' \
    -o "${arm}.mp4"
done
```

Then compare the two saved outputs from the same archive directory:

```bash
bash evidence/ref2va-compare.sh   # reads baseline.mp4 and candidate.mp4
```

Step 4 covers the natural-scene demonstration pair (accuracy only, not timed).
It lives in its own directory with its own inputs and prompt, so it cannot
overwrite the synthetic `reference.mp4`/`reference.wav`:

```bash
# 4) Natural-scene demonstration pair: same two services, demo inputs.
cd evidence/stream-demo
curl -fL -o StreamOfFlowingWater.webm \
  'https://upload.wikimedia.org/wikipedia/commons/e/e0/StreamOfFlowingWater.webm'
sha256sum StreamOfFlowingWater.webm   # 26e471fd...4e96f
bash stream-inputs.sh StreamOfFlowingWater.webm .
# Send stream-prompt.txt and reference.mp4/reference.wav to each exported base
# URL as in step 3, saving baseline.mp4 and candidate.mp4 in this directory.
bash stream-comparison.sh baseline.mp4 candidate.mp4 stream-baseline-vs-pr.mp4
```

The Ascend environment follows the public MindIE-SD H3 recipe
([infer.md](https://github.com/Ascend/MindIE-SD/blob/dev/examples/minimax-h3/infer.md)).

## Limits

- Not measured: HTTP TTFT (the sync endpoint exposes only complete-request
  latency), 50-NFE quality, long-run stability, multi-reference contention on a
  busy host, 8-NPU distributed layerwise offload, 8-NPU VAE decode.
- The E2E delta is within round-to-round noise; the supported benefit is the
  component-level `encode_media` reduction, not an end-to-end speedup.
- Results are specific to the recorded request, quantization (MXFP8 +
  RainFusion) and device configuration; precision is asserted only against the
  no-overlap baseline at the same settings, not against BF16.
- The natural-scene demonstration is a single pair on public CC0 footage and is
  not a timing sample; it adds no latency claim and does not extend the result to
  other inputs. Byte-level PCM and RGB hashes depend on the FFmpeg build; the
  asserted invariant is that both arms are identical.
- CPU unit-test coverage is CPU-only; on a device-capable runner the allocator
  case may behave differently, so the recorded pass/fail split is specific to
  the no-device container.
- Unsupported claim: none of the archived numbers are a serving throughput
  benchmark, and effective throughput is `1 / request latency`.
