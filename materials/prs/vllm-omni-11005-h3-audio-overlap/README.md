# vLLM-Omni PR #11005: Overlap MiniMax-H3 CPU audio preprocessing with visual encoding

Public-safe archive for
[vllm-project/vllm-omni#11005](https://github.com/vllm-project/vllm-omni/pull/11005).
It distills the public PR description, the public validation summary and the
public input recipes. It is not a copy of local logs, environment dumps or
private media.

## At a glance

- **Change**: on the MiniMax-H3 encoder leader, CPU waveform preparation for
  references that need resampling runs in a single request-local worker thread
  while the NPU visual encoder runs; the audio encode consumes the prepared
  waveforms. Audio-only, native-rate, CPU-autocast and non-leader requests keep
  the synchronous path, and failures cancel queued work and join the worker.
- **PR head**: `80d6b6fc200be3b7499a2e6d7113d75261c2bdd6`.
- **No-overlap baseline**: `085d7dba33eca00f44753f8c4a5e11bd7c669f38`.
- **Component result**: `encode_media` wall time `155.998 -> 154.123 ms`
  (**-1.202%**) on one Ascend 950PR with real weights, measured on public
  PyTorch synthetic input.
- **End-to-end result**: 8-NPU Ref2VA mean latency `13.229 -> 13.217 s`
  (**-0.092%**, within round-to-round noise; no end-to-end speedup claimed),
  p90 `+0.042%`, effective throughput `+0.092%`, 120/120 requests successful,
  measured on the FFmpeg `testsrc2`/`aevalsrc` synthetic reference.
- **Accuracy**: bit-identical output on the synthetic benchmark pair. 107/107
  frames compared at original 768x768 RGB24: maximum absolute difference 0,
  PSNR inf, SSIM 1.000000, identical decoded PCM SHA-256 and identical MP4
  SHA-256.
- **Demonstration pair**: one request per arm on a 10.000-13.000 s excerpt of the
  public CC0 creek footage `StreamOfFlowingWater.webm`, also bit-identical —
  107/107 frames, maximum absolute RGB difference 0, PSNR inf, SSIM 1.000000,
  identical decoded PCM and identical output MP4 hashes, with two CPU
  44.1 -> 32 kHz resampler calls per arm observed. The demo is a correctness
  demonstration, not a timing sample.

## Public validation contract

| Item | Public value |
| --- | --- |
| Repository | `vllm-project/vllm-omni` |
| PR | [#11005](https://github.com/vllm-project/vllm-omni/pull/11005) |
| Candidate commit | `80d6b6fc200be3b7499a2e6d7113d75261c2bdd6` |
| Baseline commit | `085d7dba33eca00f44753f8c4a5e11bd7c669f38` |
| Target-branch control | `9b753874d73fb40204418a457d22d802b731d19f` (`main` at validation time) |
| Public model | `MiniMaxAI/MiniMax-H3` Ref2VA task |
| Public inputs | End-to-end: FFmpeg `testsrc2` + `aevalsrc` synthesized reference video/audio. Component stage: public PyTorch synthetic tensors. Demonstration: 10.000-13.000 s excerpt of the CC0 1.0 Wikimedia Commons clip `StreamOfFlowingWater.webm`. Unit tests: public test sources |
| Hardware | Ascend 950PR, 8 NPUs (USP8, text-encoder TP8) |
| Runtime | vLLM 0.34.0, CANN 9.3.0, torch/torchaudio 2.10.0, torch_npu 2.10.0.post7, Python 3.12.13 |
| Image | public A5 image digest `sha256:43a87842...`, built from `3c885f434` |
| Request | ref2va, 768x768, 24 fps, 4 s, 12 steps, flow_shift 12, audio_flow_shift 3, seed 3101 |
| Quantization/attention | MXFP8 + RainFusion, sparse window 8-12, DLO off, single-device VAE decode |

## Files

- [rfc-design.md](rfc-design.md): problem, design, flow, compatibility, risks.
- [validation-and-benefit.md](validation-and-benefit.md): environment,
  correctness, performance tables and reproduction.
- [review-response.md](review-response.md): review state, internal iteration
  commits and reply shape.
- `evidence/`: input recipes, prompt, stage synthetic recipe, provenance and
  metrics JSON (`SHA256SUMS` included).
- `evidence/stream-demo/`: the natural-scene demonstration pair — public CC0
  source record, excerpt window and input hashes, prompt, metrics, and the
  `stream-inputs.sh` / `stream-comparison.sh` reproduction scripts.

## Media

No video or audio files are committed here. The accuracy evidence for the
synthetic benchmark pair — the per-frame comparison record plus the decoded
PCM/MP4 hashes — is in `evidence/`, next to the scripts that rebuild the public
inputs and recompute the comparison. The natural-scene demonstration pair is
recorded the same way in `evidence/stream-demo/`, together with its public
source, excerpt window and input hashes. Accuracy numbers are always computed
from the original decoded media, never from a presentation file, so this archive
keeps the evidence and not the presentation media; the comparison videos and the
paired outputs are delivered with the PR description rather than committed here,
and raw experiment logs are not committed here either.

## Security review

This archive contains no private prompts, media, datasets or checkpoints, no
hostnames or machine-local paths, no credentials, and no raw run logs or
environment dumps. Inputs are either public repository sources or recipes built
from documented public tools, and their hashes are recorded in `evidence/`.
