# Skills

This directory stores reusable TRAE-style skills distilled from public-safe
workflow knowledge.

## Index

- [ascend-profile-analysis](ascend-profile-analysis/SKILL.md): profiling
  workflow, evidence gates, and report shape for Ascend/vLLM investigations.
  Source basis: [Ascend/MindIE-SD `.agents/skills`](https://github.com/Ascend/MindIE-SD/tree/dev/.agents/skills).
- [performance-experiment-lifecycle](performance-experiment-lifecycle/SKILL.md):
  public-safe experiment lifecycle for agile screening, profiler-disabled
  formal timing, and independent profiling. Source basis: distilled local
  experiment workflow; add concrete public source links when archiving a
  specific case.
- [accelerator-process-safety](accelerator-process-safety/SKILL.md): device,
  port, and process ownership checks before launch, reuse, or cleanup. Source
  basis: distilled shared accelerator workflow.
- [source-identity-audit](source-identity-audit/SKILL.md): verify repository,
  wheel, import, overlay, and vendored source identity. Source basis: distilled
  source audit workflow.
- [public-artifact-archive](public-artifact-archive/SKILL.md): produce
  public-safe validation and PR evidence archives. Source basis: distilled
  artifact archival workflow.
- [open-omni-inference](open-omni-inference/SKILL.md): public Omni inference
  validation using isolated environments and public inputs. Source basis:
  distilled public Omni/vLLM contribution workflow; add concrete public PR links
  when archiving a specific case.
- [open-pr-maintenance](open-pr-maintenance/SKILL.md): PR audit, review-response,
  validation, and maintainer communication workflow. Source basis: distilled
  open-source PR maintenance workflow; add concrete public PR/review links when
  archiving a specific case.

## Publishing Standard

Skills should describe reusable procedures, not private deployments. Replace
local paths, internal cases, private checkpoints, and unpublished patches with
portable placeholders or public references.

Every skill should include a `Source` section. If there is no single upstream
source, state that the skill is a public-safe workflow distillation and require
specific public source links in any material archive that uses it.
