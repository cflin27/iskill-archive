# Validation and Benefit

## Summary

- Public PR: [vllm-project/vllm-omni#9468](https://github.com/vllm-project/vllm-omni/pull/9468)
- Public base commit: `b7bbfbdb4f2b3c070d9632043ea6cd2b1c601270`
- Candidate commit: `16c3a32b4ce083bf53df0c15b821276e2061dae7`
- Result: exact paired outputs at 1 and 50 NFE for image and video conditioning
  on the current candidate's eight-card fallback path, with zero fusion installs
  or calls. An earlier Ascend910B4 component run measured a small fused-path
  saving. Current-head 910B fusion and 910C / 910_93 real-device fallback are
  deferred.

## Environment

- Repository: `vllm-project/vllm-omni`, base and candidate as above.
- Model: `MiniMaxAI/MiniMax-H3@42ed227ee7df40d41602854ae760620d6eb651fe`
  (81/81 files hash-verified in the campaign report).
- Public inputs are documented in the [frozen image protocol](https://github.com/cflin27/vllm-omni/tree/9483ed912963662b7a9d5220a0d200e2060c6761)
  for the six frames and image prompt, and in the [fixed upstream Ref2VA case](https://github.com/vllm-project/vllm-omni/blob/b7bbfbdb4f2b3c070d9632043ea6cd2b1c601270/tests/e2e/accuracy/minimax_h3/test_minimax_h3_i2va_ref2va_similarity.py)
  for the video, independent audio and video prompt.
- Hardware: eight Ascend NPUs per arm. Separate service processes ran
  sequentially in one container per order block.
  Runtime: vLLM 0.33.0+empty, Python 3.12.16, torch 2.10.0+cpu,
  torch-npu 2.10.0.post7, CANN 9.2.1, driver 25.9.rc1.6.
- Request settings: seed 0, 832×480, 24 fps, 5.0 s (124 frames); image and video
  conditioning at 1 and 50 NFE; profiler off; one warmup plus three measured
  requests per case per arm.

## Correctness

Decoded frame and audio metrics cover the first measured pair per case.
Original MP4 hashes cover all measured and warmup pairs.

| Check | Baseline | Candidate | Result |
| --- | --- | --- | --- |
| CPU test suite | 398 passed / 3 skipped | 413 passed / 3 skipped | pass, 15 new branch tests |
| Two-rank Gloo | exit 0 / 0 | exit 0 / 0 | pass |
| Paired end-to-end precision, image 1 NFE | — | — | 3/3 measured pairs byte-identical; RGB24 and PCM max abs diff 0; per-frame RGB PSNR ∞; raw YUV SSIM 1.000000; 124 frames |
| Paired end-to-end precision, video 1 NFE | — | — | same |
| Paired end-to-end precision, image 50 NFE | — | — | same |
| Paired end-to-end precision, video 50 NFE | — | — | same |
| Warmup-captured video/audio latents | — | — | 8 pairs finite, max abs diff 0 |
| Original MP4 hashes including warmups | — | — | 16/16 pairs identical |
| Fused-path component arrays (earlier revision) | — | — | 30/30 images and 5/5 video arrays exact |

Device coverage for the final campaign:

| Device class | Gate | Installs | Fused calls (image / video / decoder) | Verdict |
| --- | ---: | ---: | --- | --- |
| Ascend device outside the 910B family | false | 0 | 0 / 0 / 0 | fallback verified (outputs exact, no marker or private `forward` bound) |
| 910B family | — | — | — | not covered |
| `910_93` / `910C` | — | — | — | not covered |

## Performance

Fused-path component A/B measured at the earlier revision `9323191e`, before the
device gate was added. The [public component results](https://github.com/cflin27/vllm-omni/tree/4a4017db17710f2ce297d5b7f4ca640c3b44e0b4)
cover Ascend910B4, with one NPU per arm, separate processes, two warmups and
three unprofiled measurements. Video component timing includes CPU latent
processing.

| Metric | Baseline | Candidate | Delta | Notes |
| --- | ---: | ---: | ---: | --- |
| Six public images, encoder wall time | 2561.902 ms | 2539.494 ms | −0.875% | 30/30 arrays exact, 1800 fused calls per component trial |
| Public video, encoder wall time | 7975.716 ms | 7925.052 ms | −0.635% | 5/5 arrays exact, 900 fused calls per component trial |

The fusion performance gate was inapplicable on the fallback device because
fusion was inactive. The fallback-path observations use the earlier 3%
threshold for context.

| Case (candidate first) | Baseline mean (range) s | Candidate mean (range) s | Latency delta |
| --- | --- | --- | ---: |
| Image 1 NFE | 5.756 (5.620–5.972) | 6.392 (6.353–6.449) | +11.04% |
| Video 1 NFE | 27.759 (27.614–27.835) | 27.757 (27.606–27.918) | −0.01% |
| Image 50 NFE | 69.523 (69.456–69.581) | 69.659 (69.594–69.774) | +0.20% |
| Video 50 NFE | 347.374 (347.039–347.663) | 347.647 (347.235–348.044) | +0.08% |

A separate image 1-NFE block with the baseline started first measured 5.753 s
against 5.870 s, i.e. +2.03%, with no round over +3%. The two blocks are not
pooled; the first block's delta did not reproduce under reversed order, so the
cause is undetermined and no end-to-end speedup or regression is claimed.

## Precision comparison

The GIFs show synchronized frames with the baseline on the left and candidate
on the right. Each GIF preserves all 124 frames in a resized, silent display.
The precision measurements use the original MP4s, including PCM audio.

- Image conditioning at [1 NFE](assets/pr9468-images-nfe1-baseline-candidate.gif)
  and [50 NFE](assets/pr9468-images-nfe50-baseline-candidate.gif)
- Video conditioning at [1 NFE](assets/pr9468-video-nfe1-baseline-candidate.gif)
  and [50 NFE](assets/pr9468-video-nfe50-baseline-candidate.gif)

## Reproduction

Public steps only. Paths are placeholders.

```bash
git clone https://github.com/vllm-project/vllm-omni
cd vllm-omni
git fetch origin refs/pull/9468/head
git checkout --detach 16c3a32b4ce083bf53df0c15b821276e2061dae7
python -m pytest tests/diffusion/models/minimax_h3/test_npu_image_norm.py
```

The end-to-end campaign needs an Ascend host, the eight-NPU deployment used by
the PR's fixed image, and the public inputs from artifact `9483ed9`. The
campaign's raw per-run JSON is not published in this archive.

## Limits

- Not measured: the 910B-family fast-path hit, the `910_93` / `910C` real-device
  fallback, 50-NFE quality metrics against a reference video, throughput/TTFT,
  long-running stability, and any target-device profile.
- The component saving is small and does not imply a full-request speedup.
- The cause of the image 1 NFE timing variation remains undetermined.
- The encoder manager exited `-9` on both revisions. Logs record forced
  termination after the grace period. Encoder rank OS exit codes are
  unavailable. DiT and decoder ranks exited 0, and resources were released.
- Within an arm, warmup and measured media differ in the same way on both arms at
  1 NFE; paired precision and self-repeat are reported separately.
