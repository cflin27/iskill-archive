# vLLM-Omni H3 Ascend PR Validation Archive

This archive summarizes public-safe validation material for six cflin27
`vllm-project/vllm-omni` PRs around MiniMax-H3 Ascend performance work.

It is a distilled public archive, not a copy of local raw logs. The source
material used here is limited to public PR descriptions, public fork
reproduction links, public model/input descriptions, and sanitized local
publication summaries. Local machine logs, private paths, credentials, private
cases, and unpublished patch stacks are not included.

## Public PRs

| PR | Topic | State at archive time | Public reproduction |
| --- | --- | --- | --- |
| [#9235](https://github.com/vllm-project/vllm-omni/pull/9235) | Parallel MiniMax-H3 video/audio decoder stages with DLO | Open, draft | [pr9235-native](https://github.com/cflin27/vllm-omni/tree/28f7bd36474eb8053b6a72fdc6f27563e201fef4/pr9235-native) |
| [#9280](https://github.com/vllm-project/vllm-omni/pull/9280) | Geometry-based VAE temporal scheduling | Open, draft | [public reproduction](https://github.com/cflin27/vllm-omni/tree/c46c8af9549658966dafbadd16b9fd77b84fcd36) |
| [#9467](https://github.com/vllm-project/vllm-omni/pull/9467) | Trim causal T1 Conv3D work in H3 image encoding | Open | [public artifact](https://github.com/cflin27/vllm-omni/tree/9483ed912963662b7a9d5220a0d200e2060c6761) |
| [#9468](https://github.com/vllm-project/vllm-omni/pull/9468) | Fuse GroupNorm and SiLU in H3 image/video reference encoding | Open | [public artifact](https://github.com/cflin27/vllm-omni/tree/4a4017db17710f2ce297d5b7f4ca640c3b44e0b4) |
| [#9494](https://github.com/vllm-project/vllm-omni/pull/9494) | Avoid decoder staging during H3 media encoding | Open | [public artifact](https://github.com/cflin27/vllm-omni/tree/9483ed912963662b7a9d5220a0d200e2060c6761) |
| [#10167](https://github.com/vllm-project/vllm-omni/pull/10167) | Balance video VAE encode tiles across temporal clips | Open, draft | [public reproduction](https://github.com/cflin27/vllm-omni/tree/0b6381b673d47c58c8e8ad04a8cbfa1543f9c273) |

## Shared Public Validation Contract

- Public upstream base: `vllm-project/vllm-omni` `main`.
- Public validation base used for the final isolated campaign:
  `b7bbfbdb4f2b3c070d9632043ea6cd2b1c601270`.
- Public model: `MiniMaxAI/MiniMax-H3@42ed227ee7df40d41602854ae760620d6eb651fe`.
- Public inputs: official public Ref2VA video-derived frames/video snippets, plus
  open synthetic Gaussian latent inputs where the PR validates decoder geometry.
- Hardware/runtime lane: Ascend NPU validation, CANN 9.1.0 lane, Python 3.12,
  vLLM 0.33, vLLM-Ascend public source build.
- Validation discipline: same public base/candidate environment, public inputs
  only, profiler-disabled formal or component timing, separate correctness
  checks, and explicit limits for non-promoted evidence.

## Files

- [rfc-design.md](rfc-design.md): public design map for the PR group.
- [validation-and-benefit.md](validation-and-benefit.md): measured public-safe
  results and limits.
- [review-response.md](review-response.md): review changes and public reply
  summaries.

## Security Review

The archive intentionally does not include:

- private prompts, benchmark cases, checkpoints, media, or datasets,
- raw local logs or environment dumps,
- private hostnames, absolute local paths, tokens, cookies, or SSH keys,
- private branch-only implementation details or unpublished local patches,
- performance claims that were not reproduced with public inputs and public code.
