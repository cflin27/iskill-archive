# PR Archives

Create one directory per public PR or topic:

```text
materials/prs/<repo-or-pr-id>/
├── README.md
├── rfc-design.md
├── validation-and-benefit.md
└── review-response.md
```

## Current Public Archives

- [vllm-omni-h3-ascend-prs-20261112](vllm-omni-h3-ascend-prs-20261112/):
  public-safe archive for six cflin27 MiniMax-H3 Ascend PRs in
  `vllm-project/vllm-omni`.
- [vllm-omni-11005-h3-audio-overlap](vllm-omni-11005-h3-audio-overlap/):
  public-safe archive for
  [vllm-project/vllm-omni#11005](https://github.com/vllm-project/vllm-omni/pull/11005),
  overlapping MiniMax-H3 CPU audio preprocessing with visual encoding on the
  Ascend encoder leader.

`_example-public-pr/` is a skeleton only, not validation evidence.

Add real entries only after confirming that every input, branch, model, metric,
and discussion link is public.
