# vLLM-Omni #9468: H3 GroupNorm + SiLU Fusion on Ascend

Public-safe archive for
[vllm-project/vllm-omni#9468](https://github.com/vllm-project/vllm-omni/pull/9468),
which fuses the MiniMax-H3 reference-media encoder's GroupNorm and SiLU into the
vendor operator `torch_npu.npu_group_norm_silu`, gated to the 910B device family.

## Public Identity

| Item | Value |
| --- | --- |
| PR | [vllm-project/vllm-omni#9468](https://github.com/vllm-project/vllm-omni/pull/9468) |
| Public base | `b7bbfbdb4f2b3c070d9632043ea6cd2b1c601270` |
| Candidate head | `16c3a32b4ce083bf53df0c15b821276e2061dae7` |
| Candidate parent | `9323191e5305d66ef57ca73b049a65c5917756bb` |
| Model | `MiniMaxAI/MiniMax-H3@42ed227ee7df40d41602854ae760620d6eb651fe` |
| Public input and request protocol | [fork artifact `9483ed9`](https://github.com/cflin27/vllm-omni/tree/9483ed912963662b7a9d5220a0d200e2060c6761) |
| Earlier component artifact (previous revision) | [fork artifact `4a4017db`](https://github.com/cflin27/vllm-omni/tree/4a4017db17710f2ce297d5b7f4ca640c3b44e0b4) |

Candidate files:

- `vllm_omni/diffusion/models/minimax_h3/ops/vae/group_norm_silu.py` (new):
  device gate, image/video encode scopes, eligibility predicate, private
  `forward` binding.
- `vllm_omni/diffusion/models/minimax_h3/vae.py`: install once with the target
  device and wrap the two encode call sites in their scopes.
- `tests/diffusion/models/minimax_h3/test_npu_image_norm.py` (new): 15 CPU
  branch tests for install, fallback, binding scope, temporal isolation and
  decoder isolation.

No new configuration switches, dependencies, or recipe/benchmark changes.

## Evidence Index

- [rfc-design.md](rfc-design.md): problem, install/eligibility design, fallback
  flow, risks.
- [validation-and-benefit.md](validation-and-benefit.md): CPU regression,
  device-coverage table, paired end-to-end precision, earlier-revision component
  A/B, end-to-end latency observations, limits.
- [Side-by-side GIFs](validation-and-benefit.md#precision-comparison): the four
  image and video cases at 1 and 50 NFE.
- [review-response.md](review-response.md): public review threads, changes made,
  and links to the published accuracy and status replies.

## Headline

- CPU regression: **398 passed / 3 skipped** on the base, **413 passed / 3
  skipped** on the candidate (15 new tests).
- Paired end-to-end precision on the device used for this campaign: original
  MP4s **byte-identical** in all 12 measured pairs and all 4 warmup pairs, RGB24
  and PCM maximum absolute difference **0**, per-frame RGB PSNR **∞**, and raw YUV
  SSIM **1.000000** on the first measured pair per case.
- Fused-path component A/B (earlier revision): arrays **35/35 exact**, encoder
  wall time **0.875%** lower on six images and **0.635%** lower on video.
- Device coverage: the campaign device is outside the 910B family, so the fused
  operator was **not installed and not called** (0 installs, 0/0/0 calls per
  scope). The 910B fast-path hit and the `910_93` / `910C` real-device fallback
  are **not covered** and this archive makes no target-device speedup claim.
