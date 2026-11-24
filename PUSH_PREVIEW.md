# Push Preview: iskill-archive Content

Status: initial archive, Omni PR materials and validation-evidence lessons are
pushed. Current pending update adds the vLLM-Omni PR #11005 audio-overlap
archive.

## Current Update: vLLM-Omni PR #11005 audio-overlap archive

Adds `materials/prs/vllm-omni-11005-h3-audio-overlap/`, a public-safe archive
for [vllm-project/vllm-omni#11005](https://github.com/vllm-project/vllm-omni/pull/11005),
which overlaps MiniMax-H3 CPU audio preprocessing with visual encoding on the
Ascend encoder leader. It records:

- the public commits (`80d6b6fc` candidate, `085d7dba` no-overlap baseline,
  `9b753874` target-branch control) and the fixed Ref2VA request;
- the 8-NPU end-to-end contract (120/120 formal requests, within-noise latency
  deltas, no end-to-end speedup claim) and the single-NPU component result;
- bit-exact 107-frame precision evidence on the public synthetic benchmark pair
  (max absolute RGB difference 0, PSNR inf, SSIM 1.000000, identical PCM and MP4
  hashes);
- public FFmpeg `testsrc2`/`aevalsrc` and PyTorch input recipes with SHA-256
  values, plus the no-device unit-test result and its pre-existing allocator
  failure;
- reproduction commands split into the source tree (CPU tests) and the archive
  directory (inputs, then one request per arm saved as `baseline.mp4` and
  `candidate.mp4` before comparison);
- the internal review iteration and unresolved limits (no TTFT, no 50-NFE
  quality run, fixed quantization/device lane).

It also adds the new entry to `materials/README.md` and `materials/prs/README.md`.
No private media, raw logs, hostnames, paths or credentials are included.

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
Add vLLM-Omni PR #11005 audio-overlap archive
```
