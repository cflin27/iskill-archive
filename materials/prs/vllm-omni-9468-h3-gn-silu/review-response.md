# Review Response

Public review record for
[vllm-project/vllm-omni#9468](https://github.com/vllm-project/vllm-omni/pull/9468).
It summarizes the maintainer and bot threads, what changed, and the reply
status; it is not a verbatim copy of the discussion.

## Comments Addressed

| Public thread | Review item | Change or response | Status |
| --- | --- | --- | --- |
| [discussion_r4411020000](https://github.com/vllm-project/vllm-omni/pull/9468#discussion_r4411020000) | Three new NPU image environment switches were missing from the reviewed inventory, which fails the repository's AST drift check. | Removed the switches and the inventory changes entirely; the optimization is automatic on supported devices. The pre-change file no longer exists. | Addressed in an earlier revision; replied in-thread |
| [discussion_r4481052203](https://github.com/vllm-project/vllm-omni/pull/9468#discussion_r4481052203) | A module-level benchmark script does not belong in `vllm_omni/benchmarks`; remove it. | File removed. | Addressed; replied "Done." |
| [discussion_r4481079200](https://github.com/vllm-project/vllm-omni/pull/9468#discussion_r4481079200) | Do not add new environment variables or a long section to the general recipe. | Recipe section removed; no new variables remain. | Addressed; replied "Done." |
| [discussion_r4481200232](https://github.com/vllm-project/vllm-omni/pull/9468#discussion_r4481200232) | The fusion needs no new environment variables; remove the inventory entry. | Inventory entry removed with the feature switches. | Addressed; replied "Done." |
| [discussion_r4481300281](https://github.com/vllm-project/vllm-omni/pull/9468#discussion_r4481300281) | Follow the integration design of `ops/vae/qk_norm_rope.py`; the previous installer name was awkward. | Refactored into `vllm_omni/diffusion/models/minimax_h3/ops/vae/group_norm_silu.py` with an `install_npu_group_norm_silu` entry point. | Addressed; replied in-thread |
| [discussion_r4481346654](https://github.com/vllm-project/vllm-omni/pull/9468#discussion_r4481346654) | Show end-to-end accuracy validation before and after the integration. | Extended from one 1-NFE image case to image and video conditioning at 1 and 50 NFE, three measured pairs per case, with exact paired outputs. Target-device coverage is still open. | Fallback precision published. [Published accuracy reply](https://github.com/vllm-project/vllm-omni/pull/9468#discussion_r4690654154) |
| [issuecomment-7019886817](https://github.com/vllm-project/vllm-omni/pull/9468#issuecomment-7019886817) | Automated stale check: confirm the current plan and next step. | Current-head evidence and deferred device runs. | [Published plan update](https://github.com/vllm-project/vllm-omni/pull/9468#issuecomment-7153513868) |
| [issuecomment-6519544981](https://github.com/vllm-project/vllm-omni/pull/9468#issuecomment-6519544981) | Author self-review is expected before reviewer assignment. | Current-head agent-assisted self-check included in the plan update. | See plan update above |
