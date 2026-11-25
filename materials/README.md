# Materials

This directory archives public-safe PR, RFC, validation, and benefit material.

Do not store private raw logs or local experiment trees here. Prefer concise
Markdown summaries with public links and reproducible public inputs.

## Layout

- `templates/`: reusable public-safe templates.
- `prs/`: one subdirectory per public PR, RFC, or topic.
  `prs/_example-public-pr/` is a skeleton only.

## Current Archives

- [prs/vllm-omni-h3-ascend-prs-20261112](prs/vllm-omni-h3-ascend-prs-20261112/):
  six public cflin27 MiniMax-H3 Ascend PRs for `vllm-project/vllm-omni`.
- [prs/vllm-omni-9468-h3-gn-silu](prs/vllm-omni-9468-h3-gn-silu/):
  public-safe archive for
  [vllm-project/vllm-omni#9468](https://github.com/vllm-project/vllm-omni/pull/9468):
  device-gated GroupNorm + SiLU fusion for MiniMax-H3 reference encoding.
- [prs/vllm-omni-11005-h3-audio-overlap](prs/vllm-omni-11005-h3-audio-overlap/):
  public-safe archive for
  [vllm-project/vllm-omni#11005](https://github.com/vllm-project/vllm-omni/pull/11005):
  overlapping MiniMax-H3 CPU audio preprocessing with visual encoding.

## New Archive Checklist

1. Start from the templates.
2. Replace local names with public repository, PR, branch, and model names.
3. Include only public inputs and public reproduction steps.
4. Summarize raw logs into tables or key excerpts.
5. State what was not measured.
