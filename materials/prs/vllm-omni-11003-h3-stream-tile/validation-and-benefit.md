# Validation and Benefit: MiniMax-H3 streamed reference-video tiles

## Summary

- Public PR: [vllm-project/vllm-omni#11003](https://github.com/vllm-project/vllm-omni/pull/11003)
- Public base commit: `085d7dba33eca00f44753f8c4a5e11bd7c669f38`
- Candidate commit: `5e4f260d5d716774fc88ea7219c31728239b8131`
- Result: streamed upload is hit on eight ranks, encoder rows and end-to-end
  media are bit-identical to the baseline, VAE latency stays inside the 3%
  gate with a confidence interval that includes zero, and the reference-encode
  allocator peak is about 32% lower for the public 124x768x1344 request.

## Environment

- Repository: `vllm-project/vllm-omni`, MiniMax-H3 reference-to-video.
- Model: public MiniMax-H3 checkpoint; reference-to-video pipeline with eight
  workers, USP 8, ring 1, text-encoder TP 8, tiled VAE parallel size 8, eager
  execution and layer offload.
- Public inputs: the constant prompt, reference video and reference audio in
  [`tests/e2e/accuracy/minimax_h3/test_minimax_h3_i2va_ref2va_similarity.py`
  at the base commit](https://github.com/vllm-project/vllm-omni/blob/085d7dba33eca00f44753f8c4a5e11bd7c669f38/tests/e2e/accuracy/minimax_h3/test_minimax_h3_i2va_ref2va_similarity.py).
  Video SHA-256
  `d6edc20ac82aa980c9cbd0b05b371f60d12dc8d018492e571b42de0086819c41`;
  audio SHA-256
  `2a48d447b343b38a2c504d5281a0c97c688db0ba87931ed9282c598bd6752454`.
- Synthetic frames, no media files: the CPU tests use
  `numpy.random.default_rng(123).integers(0, 256, (length, *size, 3), dtype=numpy.uint8)`
  at 11x15 and 9x11, lengths 1, 4, 7 and 13. The eight-rank functional A/B uses
  `numpy.random.default_rng(42).integers(0, 256, size=(frames, height, width, 3), dtype=numpy.uint8)`
  at 450x710 (33, 34 and 50 frames) and 256x256 (33 frames).
- Runtime recipe: the [MiniMax-H3 NPU recipe at the base
  commit](https://github.com/vllm-project/vllm-omni/blob/085d7dba33eca00f44753f8c4a5e11bd7c669f38/recipes/MiniMaxAI/MiniMax-H3-NPU.md)
  is the public environment entry point; pin that revision rather than following
  a moving branch.
- Request: 1344x768, 24 fps, 5 s, 124 frames, seed 0, flow shift 12, audio flow
  shift 3, VAE preparation seed 42, 50 inference steps for end-to-end
  performance.
- Hardware: one Ascend 950PR host, eight assigned cards, HCCL, 128 GiB HBM per
  card.
- Runtime: `vllm-omni` image digest
  `sha256:43a878423c5ac2cf1984405433fb6c0c7b1777084517cb951ccffa89e279725b`,
  driver 25.9.rc1.6, Python 3.12.13, torch-npu 2.10.0.post7. Formal timing ran
  with the profiler disabled; service CPUs 0-31, client CPUs 32-35.
- Identity: the executed vLLM-Omni source was verified by file hashes and import
  paths for both arms. The underlying vLLM and vLLM-Ascend Git identities were
  not readable from the image. VAE config and weight hashes were verified;
  transformer and text-encoder shard indexes were checked for completeness and
  recorded by size, not hashed byte-for-byte, and no checkpoint revision was
  claimed beyond those indexes.

## Correctness

| Check | Baseline | Candidate | Result |
| --- | --- | --- | --- |
| Eight-rank stream hit | n/a | `stream_hits=1`, one collective round per clip | hit confirmed |
| Rows, 33/34/50 frames at 450x710 | SHA-256 prefix `0573a215...` / `1a6f2a9d...` | same SHA-256 prefix, `torch.equal` | identical, max diff 0 |
| Rows, 33 frames at 256x256, rank-local | SHA-256 prefix `c17e1efd...` | same SHA-256 prefix, no collectives | identical, max diff 0 |
| Flag values | n/a | `1`, `True`, `on` enable; `0`, `off`, empty disable | pass |
| Legacy preparation plus stream flag | ordinary path | stream attempt 0 | legacy wins, output identical |
| Missing posterior sampler | ordinary path | one stream attempt, no hit | safe fallback, output identical |
| HTTP 50 NFE, six paired requests | reference output | same decoded output | RGB max diff 0, PSNR infinite, SSIM 1.0, PCM max diff 0 |
| AsyncOmni 1 and 50 NFE | reference output | same raw arrays | RGB and float audio bit-identical |
| CPU regression, same container | 130 shared tests pass | 159 tests pass | exit 0 |

The rows hashes shown above are 16-hex-character prefixes. The CPU counts were
recorded in an earlier disposable-container run at the same two commits and are
reused; the eight-rank round did not repeat them. The recorded test set is
`test_minimax_h3_video_tile_input.py` plus
`test_minimax_h3_vae_encode_prep.py` and related VAE regression cases; a broad
`pytest` directory command is only an independent reproduction entry, not the
exact recorded set.

The streamed path is not an approximation: it changes where the normalized tile
tensor is built, not the arithmetic or the order of tile encode, blend, crop and
posterior sampling. The expected precision difference is exactly zero.

## Performance

Eight ranks, public Ref2VA request, 124 frames at 1344x768. Per-request device
events and allocator peaks are the maximum across the eight ranks; paired
differences are `(candidate - baseline) / baseline`, with 10,000 bootstrap
resamples, median and percentile 95% confidence interval.

| Metric | Baseline median | Candidate median | Delta | 95% CI | Gate | Verdict |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| VAE encode, device event | 4235.195 ms | 4188.633 ms | -1.2940% | [-1.4557%, +0.5577%] | 3% | pass |
| VAE encode, synchronized call | 4235.331 ms | 4188.732 ms | -1.2936% | [-1.4557%, +0.5572%] | 3% | pass |
| VAE allocator peak, allocated | 5109.351 MiB | 3482.141 MiB | -31.8477% | [-31.8477%, -31.8477%] | >3% and >256 MiB | pass |
| VAE allocator peak, reserved | 7070.000 MiB | 4778.000 MiB | -32.4187% | [-32.4187%, -32.4187%] | >3% and >256 MiB | pass |
| HTTP E2E wall time, 50 NFE | 297.638 s | 297.425 s | -0.1917% | [-0.2271%, +0.0443%] | 3% | pass |
| Full-request allocator peak, allocated | 20518.944 MiB | 20518.944 MiB | +0.0000% | [+0.0000%, +0.0000%] | 1% guard | pass |
| Full-request allocator peak, reserved | 21946.000 MiB | 21898.000 MiB | -0.2187% | [-0.2187%, -0.1641%] | 1% guard | pass |

Noise calibration: four same-version A/A blocks, one warm-up plus five formal
samples per block, 20 formal samples in total. Device-event sigma was 5.156 ms
(0.122%) and the maximum absolute block-mean difference 0.064%, so the latency
gate is `max(3%, 2 x 0.064%) = 3%`. The ABBA phase used four blocks, again one
warm-up plus five formal samples per block, so each arm contributed ten formal
samples. The HTTP phase used four blocks, one warm-up plus three formal requests
per block, six formal requests per arm. Both VAE timing confidence intervals
include zero; the change passes the 3% regression guard, is latency-neutral and
no VAE speed-up is claimed. The benefit is the allocator high-water mark of the
reference-encode stage: about 1.6 GiB less allocated and about 2.2 GiB less
reserved, while the full-request allocated peak is unchanged and the reserved
peak is 0.2187% lower.

## Reproduction

Use the public recipe to build the environment and the public fixture constants
for the request. The host-side A/B harness used for this run was experimental
and is not published as a script; the PR description records the public inputs,
metrics and collection boundaries.

```bash
git clone https://github.com/vllm-project/vllm-omni
cd vllm-omni
git fetch https://github.com/cflin27/vllm-omni.git h3/video-tile-stream

# Baseline arm (exact public commit).
git checkout 085d7dba33eca00f44753f8c4a5e11bd7c669f38
# Candidate arm (exact public commit from the fork above).
git checkout 5e4f260d5d716774fc88ea7219c31728239b8131

# Independent reproduction entry. The recorded run used the targeted test set
# (test_minimax_h3_video_tile_input.py, test_minimax_h3_vae_encode_prep.py and
# related VAE regression cases): candidate 159 passed, baseline shared set 130
# passed. The broader directory command below is not that exact recorded set.
pytest -q tests/diffusion/models/minimax_h3/

# Serve each arm with the version-pinned public recipe
# https://github.com/vllm-project/vllm-omni/blob/085d7dba33eca00f44753f8c4a5e11bd7c669f38/recipes/MiniMaxAI/MiniMax-H3-NPU.md
# and send the public Ref2VA request from the fixture at the base commit.
# Baseline: VLLM_OMNI_H3_VAE_STREAM_TILE=0
# Candidate: VLLM_OMNI_H3_VAE_STREAM_TILE=1
```

## Limits

- The VAE latency confidence interval includes zero; this is not a latency
  improvement claim. The change only clears the 3% regression guard.
- The comparison clip, once published, is a silent display copy with no audio
  track. Audio and PCM precision were measured on the original independently
  captured outputs, not on that clip.
- Allocator high-water marks are `torch`/NPU allocator peaks, not device HBM
  peaks. Device HBM was sampled only as discrete request-start snapshots; no
  full-request device HBM peak was collected.
- 14 of 16 HTTP request-start snapshots observed another assigned card group
  running a different PR's container. The per-sample effect is unknown, and the
  VAE A/A and ABBA blocks did not retain per-sample records of that workload.
- The E2E wall-time gate used the default 3% without a matching full-E2E A/A
  calibration; VAE A/A noise is not a substitute. The E2E confidence interval
  upper bound is below the gate, so no regression is indicated.
- Results cover one Ascend 950PR host, eight cards, one public Ref2VA fixture
  and the parameters above. Single-card performance, other NPU models, CUDA
  performance, multi-node collectives, long-run stability and device profiling
  were not measured.
- 1 NFE served only smoke and precision coverage; performance was judged at
  50 NFEs.
