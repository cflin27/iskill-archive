# Push Preview: Initial iskill-archive Draft

Status: not pushed. Awaiting user approval.

## Purpose

Initialize `cflin27/iskill-archive` as an open repository for reusable skills
and public contribution material. The repository is designed around
`AGENTS.md` as the only required human entry point.

## Content To Push

- `AGENTS.md`: concise repository policy, navigation, and publication checklist.
- `README.md`: minimal pointer to `AGENTS.md`.
- `skills/ascend-profile-analysis/`: public-safe profiling workflow distilled
  from reusable Ascend/vLLM profiling practice, with source basis linked to
  [Ascend/MindIE-SD `.agents/skills`](https://github.com/Ascend/MindIE-SD/tree/dev/.agents/skills).
- `skills/performance-experiment-lifecycle/`: public-safe experiment lifecycle
  for agile screening, formal profiler-disabled timing, and independent
  profiling.
- `skills/accelerator-process-safety/`: public-safe ownership checks for
  accelerator devices, ports, services, and cleanup.
- `skills/source-identity-audit/`: source, package, import, wheel, and overlay
  identity audit workflow.
- `skills/public-artifact-archive/`: public-safe archive workflow for
  validation and PR evidence.
- `skills/open-omni-inference/`: public Omni inference validation workflow using
  isolated environments and public inputs; marked as public workflow
  distillation until concrete public PR archives provide per-case source links.
- `skills/open-pr-maintenance/`: PR review, revision, validation, reply, and
  archive workflow for open-source PRs; marked as public workflow distillation
  until concrete public PR archives provide per-case source links.
- `lessons/`: public-safe lesson index and reusable lesson template.
- `materials/`: public-safe PR/RFC/validation archive policy and templates.

## Explicitly Excluded

- Local private patches and unpublished source changes.
- Private prompts, datasets, cases, checkpoints, or media.
- Raw local experiment logs, profiler dumps, videos, or internal output trees.
- Credentials, tokens, cookies, hostnames, ports, personal paths, and complete
  environment dumps.
- Claims that depend on private-only validation.

## Source Distillation Notes

The initial skills are distilled from local workflow patterns, not copied from
private project-specific skills. Project-specific names, fixed paths, internal
case identifiers, and private runtime assumptions were replaced by portable
public rules and templates. The profile skill includes an explicit public
source basis. The experiment lifecycle skill captures the generic local
agile/formal/profile method without private cases or paths. Future skills and
material archives should carry source links at the skill or per-archive level.

## Approval Gate

After approval, push this draft to:

```text
https://github.com/cflin27/iskill-archive
```

Suggested commit message:

```text
Initialize public skill archive
```
