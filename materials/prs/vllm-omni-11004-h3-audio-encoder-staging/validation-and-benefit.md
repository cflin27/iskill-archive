# Validation and Benefit: MiniMax-H3 audio-encoder staging

## Summary

- Public PR: [vllm-project/vllm-omni#11004](https://github.com/vllm-project/vllm-omni/pull/11004)
- Public base commit: `085d7dba33eca00f44753f8c4a5e11bd7c669f38`
- Candidate commit: `dc6cb7c1255160f0b236d0351be91f291491b8e2`
- Result: the split encode scope is hit on the real checkpoint, end-to-end
  media is bit-identical at 50 NFE, the isolated load+encode window is 17.66%
  shorter and its allocator peaks are 25.52% (allocated) and 29.91% (reserved)
  lower; the full 50 NFE request peak is unchanged and the end-to-end
  confidence interval includes zero.

## Environment

- Repository: `vllm-project/vllm-omni`, MiniMax-H3 reference-to-video.
- Model: public [MiniMaxAI/MiniMax-H3 checkpoint](https://huggingface.co/MiniMaxAI/MiniMax-H3) (Ref2VA pipeline). File hashes
  for all 81 checkpoint files were collected; the download revision was not
  independently verified.
- The base commit supplies the prompt, reference video and reference audio.
  [the public Ref2VA accuracy test](https://github.com/vllm-project/vllm-omni/blob/085d7dba33eca00f44753f8c4a5e11bd7c669f38/tests/e2e/accuracy/minimax_h3/test_minimax_h3_i2va_ref2va_similarity.py). Video SHA-256
  `d6edc20ac82aa980c9cbd0b05b371f60d12dc8d018492e571b42de0086819c41`;
  audio SHA-256
  `2a48d447b343b38a2c504d5281a0c97c688db0ba87931ed9282c598bd6752454`.
- Request: Ref2VA, 124 frames at 1344x768, 24 fps, 5 s, seed 0, 50 inference
  steps, flow shift 12, audio flow shift 3, eight workers, USP 8, text-encoder
  TP 8, ring 1, VAE tile parallel 8, distributed layerwise offload.
- Hardware: one Ascend 950PR host, eight assigned cards.
- Runtime: disposable container, image digest
  `sha256:6df205d61e10e2c06cc27b0da7ec228bcec2e02faa5de94215f54b0191965315`,
  Python 3.12.13, torch 2.10.0+cpu, torch-npu 2.10.0.post7, vLLM 0.34.0,
  MindIE-SD 3.2.0. Formal timing ran with the profiler disabled; both arms and
  the client were CPU-pinned.
- Identity: each arm was imported from its own source checkout at the commit
  above, verified by import path and source-file hashes.

## Correctness

| Check | Base `085d7dba3` | Candidate `dc6cb7c1` | Result |
| --- | --- | --- | --- |
| Real checkpoint, split staging | whole component | `encoder`, `pre_block`, `mean_proj` on NPU; `decoder`, `dec_in_proj`, `logs_proj` on CPU | hit confirmed |
| After encode | all children CPU | all children CPU | released |
| Decoder-first same-weight reorder | n/a | max abs diff 0 | identical |
| Whole-component `load_to_device()` | full contract | full contract, max abs diff 0 | unchanged |
| Sequential offload, public reference audio | pass | pass, rows `[682, 32]`, `encoded_t` 341 | unchanged |
| Sequential offload, silence | pass | pass, rows `[682, 32]`, `encoded_t` 341 | unchanged |
| Injected encode failure, then recovery | pass | all children CPU, `allocated = 0`, rerun bit-identical | pass |
| Encoded latent SHA-256 | `37ff982f...` | `37ff982f...` | identical |
| HTTP and AsyncOmni, 1 NFE | reference | same decoded pixels and raw float32 PCM hash | identical |
| CPU regression, same container | 39 passed, 0 failed or skipped | 53 passed, 0 failed or skipped | 14 new cases |

The 14 new candidate cases cover: split load preserving decoder storage;
whole-component load contract; fallback for root state, partial adapters and
tied storage; independent versus shared empty buffers; exception releasing the
encoder group; sequential offload unwrapping to the hooked module; resident
scope keeping placement; proxy and cache ownership; unknown part failing before
load.

The split is not an approximation: it changes which weights are staged during
encoding, not the arithmetic or the order of the encoder calls. The expected
precision difference is exactly zero.

## Precision

Six paired 50 NFE HTTP requests (one warmup plus three formal samples per block,
two ABBA blocks combined). Every pair was compared frame by frame and sample by
sample:

| Check | Result (all six pairs) |
| --- | --- |
| Decoded pixel maximum absolute difference | 0 |
| Decoded PCM maximum absolute difference | 0 |
| Audio latent maximum absolute difference, both streams | 0 |
| PSNR | infinite |
| SSIM | 1.0 |
| MP4 SHA-256, base versus candidate | identical |

The side-by-side video uses the last formal sample of the second block, with
the baseline on the left and the candidate on the right.

The numeric comparisons use the original paired outputs. The display MP4
re-encodes the side-by-side video with H.264 and carries the baseline audio
as one AAC track.

## Performance

Eight ranks; allocator peaks are the maximum across ranks where noted. Paired
difference is `(candidate - base) / base`; the 95% CI is a paired percentile
bootstrap of the median, 20,000 resamples, seed 0. Positive means a regression.

Isolated audio load+encode window, one active audio rank:

| Metric | Base mean | Candidate mean | Paired median delta | 95% CI | Gate | Verdict |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| Load+encode synchronized window (ms) | 71.953 | 59.240 | -17.662% | [-17.804, -17.540]% | 3% | pass |
| Encode-call interval (ms) | 58.672 | 56.939 | -3.144% | [-3.604, -2.104]% | 3% | pass |
| Window allocated peak (MiB) | 990.315 | 737.594 | -25.519% | [-25.519, -25.519]% | 3% | pass |
| Window reserved peak (MiB) | 1110 | 778 | -29.910% | [-29.910, -29.910]% | 3% | pass |

Production 50 NFE request:

| Metric | Base mean | Candidate mean | Paired median delta | 95% CI | Gate | Verdict |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| Two encode sync times, sum (ms) | 51.190 | 50.407 | -0.330% | [-4.193, +0.143]% | 3% | pass |
| Pipeline device-sync time, rank max (ms) | 304386.539 | 304394.802 | +0.011% | [-0.064, +0.061]% | 3% | pass |
| 50 NFE HTTP E2E guard (ms) | 305030.487 | 305161.787 | +0.051% | [-0.145, +0.223]% | 3% | pass |
| Allocated after second encode (MiB) | 3574.639 | 3324.682 | -6.993% | [-6.993, -6.993]% | 3% | pass |
| Full-request allocated peak, rank max (MiB) | 19236.047 | 19236.047 | 0% | [0, 0]% | 3% | pass |
| Full-request reserved peak, rank max (MiB) | 20636 | 20636 | 0% | [0, 0]% | 3% | pass |

Sample ranges: isolated window base 71.771-72.246 ms, candidate 59.088-59.365 ms;
50 NFE E2E base 304.656-305.255 s, candidate 304.501-305.877 s.

Noise calibration: a same-version isolated A/A at the same workload gives a
load+encode window sigma of 0.106115% and a maximum absolute block-mean
difference of 0.158733%; the encode-call interval gives 0.339789% and
0.165065%; the isolated allocated and reserved peaks are exactly repeatable.
The staging-window gate is `max(3%, 2 x 0.158733%) = 3%`. The production and
E2E rows use the default 3%; the isolated A/A does not calibrate a full request.

## Benefit

- The isolated staging window allocates 252.721 MiB less and reserves 332 MiB
  less during reference encoding.
- In the full request, the allocated value after the second encode is 249.957
  MiB lower.
- The full-request peak is unchanged: allocated 19236.047 MiB and reserved
  20636 MiB on both arms (rank maximum).
- The 50 NFE E2E and pipeline confidence intervals include zero. The
  measured device-memory benefit applies during media preparation.

## Reproduction

```bash
git clone https://github.com/vllm-project/vllm-omni
cd vllm-omni
git fetch origin refs/pull/11004/head
git checkout 085d7dba33eca00f44753f8c4a5e11bd7c669f38
pytest -q \
  tests/diffusion/models/minimax_h3/test_minimax_h3_audio_vae.py \
  tests/diffusion/models/minimax_h3/test_minimax_h3_vae_split_residency.py \
  tests/diffusion/models/minimax_h3/test_streaming_decoder_residency.py \
  tests/diffusion/offloader/test_sequential_backend.py

# Switch to the validated candidate and add its new suite to the same command.
git checkout dc6cb7c1255160f0b236d0351be91f291491b8e2
pytest -q \
  tests/diffusion/models/minimax_h3/test_minimax_h3_audio_vae.py \
  tests/diffusion/models/minimax_h3/test_minimax_h3_vae_split_residency.py \
  tests/diffusion/models/minimax_h3/test_streaming_decoder_residency.py \
  tests/diffusion/offloader/test_sequential_backend.py \
  tests/diffusion/models/minimax_h3/test_minimax_h3_audio_split_residency.py

# Serve each arm with the public MiniMax-H3 NPU recipe and send the public
# Ref2VA request defined by the accuracy test at the base commit.
```

The public recipe in `recipes/MiniMaxAI/MiniMax-H3-NPU.md` describes the image,
device setup and serving command. The host-side A/B harness used for this run was
experimental and is not published as a script; the PR description records the
public inputs, metrics and collection boundaries.

## Limits

- **Production staging window not measured.** The baseline observer used one
  record name for the encoding and the following decoding component scopes, so
  the decode overwrote the encode window. The records are kept but are not
  compared. The staging-window claim is the complete isolated A/A and ABBA; the
  production table uses independently timed encode calls, the allocator value
  after the second encode, and the full-request peak.
- **Some production samples shared the host.** Part of the production sampling
  overlapped a concurrent Ref2VA HTTP E2E run on a separate device group. Best-effort launch and request gating was recorded; the E2E row is a
  guard only.
- **Checkpoint revision not independently verified.** File hashes for all 81
  checkpoint files were collected (tree
  `87b06a379593488fba21ab04b572c06244ad93ed6faf8882ffa50215b6a7a900`), but the
  download revision was not independently confirmed.
- **Exception release leaves a cached block.** After an injected encode failure
  both arms return all children to CPU with `allocated = 0`, but `reserved`
  stays at 20 MiB. The bounded-cache release call returns `True`, and a
  recovery run reproduces the latent bit-for-bit.
- **One hardware and input scope.** Other NPU models, CUDA, multi-node
  collectives, long-run stability and device profiling were not measured. The
  1 NFE runs cover smoke and precision only; performance was judged at 50 NFE.
- **Unit tests are CPU-only.** The 53/39 counts are the CPU regression suite in
  the validation container; accelerator behavior is covered by the residency,
  HTTP, AsyncOmni and paired E2E checks.
