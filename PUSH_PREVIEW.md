# Push Preview: iskill-archive Content

Status: initial archive and Omni PR materials are pushed. Current pending
update adds validation-evidence lessons and tightens three existing skills.

## Current Update: Validation Evidence Lessons

Adds one lesson file and extends the skills it maps to. No case-specific paths,
hosts, logs, commits, or unpublished source are included.

- `lessons/validation-evidence-discipline.md` (new): execution identity
  including model hierarchy and checkpoint shards, the device probe ladder
  (enumeration, tensor plus synchronize, collective, target collective,
  decodable request), runtime parameter ranges, non-reproduction is not a fix,
  candidate failure triage, and read-only source with a separate writable
  work directory.
- `lessons/experiment-methodology.md`: adds measurement layers (sub-stage,
  host call interval, full request), timing hygiene (independent warmup, fixed
  host parallelism, kept tail samples, small-sample percentiles), and per-round
  promotion gates versus pooled statistics.
- `lessons/README.md`: index updated.
- `skills/performance-experiment-lifecycle/SKILL.md` and references:
  `references/async-overlap-validation.md` now separates host call interval from
  kernel time and requires overlap inside the critical path;
  `references/experiment-report-template.md` gains a per-round gate table and a
  measurement-layer table.
- `skills/source-identity-audit/SKILL.md` and
  `references/identity-record.md`: record the model class the loader resolves
  and checkpoint revision/shard count, with matching red flags.
- `skills/open-omni-inference/SKILL.md` and
  `references/public-validation-ladder.md`: read-only source plus writable work
  directory, device probes before service startup, runtime-accepted parameter
  ranges, non-reproduction wording, and candidate failure reporting.

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
  profiling, plus method references for cache, async overlap, allocator state,
  and precision/determinism.
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
- `lessons/`: public-safe lesson index, experiment-methodology lessons, and
  reusable lesson template.
- `materials/`: public-safe PR/RFC/validation archive policy and templates.
- `materials/prs/_example-public-pr/`: clearly labeled example skeleton for a
  future public PR archive; it is not real validation evidence.
- `materials/prs/vllm-omni-h3-ascend-prs-20261112/`: public-safe archive for
  six cflin27 MiniMax-H3 Ascend PRs in `vllm-project/vllm-omni`, summarizing
  public reproduction links, validation results, limits, and review responses.

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

## Push Target

Push updates to:

```text
https://github.com/cflin27/iskill-archive
```

Latest suggested commit message:

```text
Add validation evidence lessons and tighten skill gates
```
