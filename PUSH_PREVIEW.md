# Push Preview: iskill-archive Content

This update builds on the experiment, device, and exit-audit lessons. It adds
guidance on device numbering, allocator-peak scope, native output alignment, and
generated-output identity.

## Current Update: Generated Output Identity and Container Input Access

Adds one lesson and updates nine documents, ten files in total. The related
public case is
[vllm-project/vllm-omni#9467](https://github.com/vllm-project/vllm-omni/pull/9467),
whose frozen input package
([cflin27/vllm-omni@9483ed9](https://github.com/cflin27/vllm-omni/tree/9483ed912963662b7a9d5220a0d200e2060c6761))
fixes the request inputs and parameters used by a paired comparison. Citations
stay within what those public pages state: local per-process exit records,
host-side ownership snapshots, and raw run artifacts are not published and are
not included; the exit guidance remains general method.

- `lessons/generated-output-identity.md` (new): the three artifact layers (raw
  tensor with original dtype, raw container, re-encoded display copy), pairing
  by request index and reported request ID instead of a content-hash set, file
  hash versus content hash, the scope of a warmup export, and minimum
  per-request parity rows for tensor and decoded media.
- `lessons/validation-evidence-discipline.md`: adds container input
  accessibility — the read-only source mount and the input copy checked
  separately, host absolute symlinks that fail inside the container, an
  independent input copy hashed against the public manifest, and a network
  fallback recorded as an environment failure.
- `lessons/experiment-methodology.md`: adds tensor/media export as a separate
  block from formal timing and requires naming which block supplied the parity
  artifacts and which supplied the timing samples.
- `lessons/shutdown-and-exit-audit.md`: adds wait records persisted by the
  actual reaper after it completes each OS wait and before its own exit,
  including descendants it re-adopts after the launcher exits, a per-rank
  `not retained` decision taken from whether that rank's own OS wait record was
  retained, and resource release as a verdict separate from clean exit. Also
  drops the earlier claim that a manager killed by signal leaves its child ranks
  without a usable code: their rows follow their own records.
- `lessons/README.md`: index updated.
- `skills/accelerator-process-safety/SKILL.md`: the shutdown audit persists each
  parent's OS wait record in the actual reaper after the wait completes and
  before that reaper exits, with a host supervisor that takes over an orphan
  after the launcher exits still owning the wait.
- `skills/accelerator-process-safety/references/shutdown-audit.md`: reaper-parent
  coverage with records persisted before exit, the per-rank `not retained` rule,
  and the separate resource-release verdict.
- `skills/open-omni-inference/references/public-validation-ladder.md`: raw tensor
  dtype, request-ID pairing, raw versus display media at the public-request
  rung; export versus timing at the formal-evidence rung; reaper-persisted waits
  and the per-rank `not retained` rule, plus resource release as a separate
  verdict, at the exit rung.
- `skills/performance-experiment-lifecycle/references/experiment-report-template.md`:
  a generated-output-identity table, request-ID pairing and raw-output media
  rows in the correctness table, the export-versus-timing note, and the exit
  paragraph's reaper persistence and per-rank `not retained` rule.
- `PUSH_PREVIEW.md`: preview section updated for this ten-file update.

## Previous Update: Device Numbering, Peak Scope and Output Alignment

Adds one lesson and updates twelve documents, thirteen files in total. The
related public case is
[vllm-project/vllm-omni#9467](https://github.com/vllm-project/vllm-omni/pull/9467),
whose page and frozen input package
([cflin27/vllm-omni@9483ed9](https://github.com/cflin27/vllm-omni/tree/9483ed912963662b7a9d5220a0d200e2060c6761))
publish the component boundary, the public inputs, and a deterministic request
check. Citations in this update stay within what those pages state: per-process
exit rows, host-side ownership snapshots, staged-run peaks, and a device-node or
access-policy record are not published there, so they appear only as general
method. No private paths, hosts, logs, device assignments, or raw artifacts are
included.

- `lessons/device-numbering-and-ownership.md` (new): the numbering layers (host
  physical card, container device node, index accepted by the installed
  runtime's visibility selector, framework index after masking), device access
  authorization as a pre-probe gate (device node presentation and mapping, a
  devices cgroup or permission policy, and a failed pre-check when the effective
  access scope cannot be confirmed) kept separate from runtime visibility (which
  devices it selects within the accessible set), why a correct visible count is
  not ownership evidence, the wrong-card and empty-set failure modes written as
  hypothesis examples rather than reported cases, retained host enumeration as a
  stack-specific compatibility case rather than a general rule, host-side
  process-to-card snapshots, idle checks before launch and after cleanup, and
  reporting devices by role.
- `lessons/experiment-methodology.md`: adds allocator peak scope (per-runner
  reset, nested reset, and read boundary; branches covered; per-request
  aggregation; allocated versus reserved; component versus full-request versus
  offload residue; warmup exports separated from formal timing) and native
  output alignment (frame-count rounding, latent extent check, decoded metrics
  versus container hashes, shared warmup-versus-formal differences), with source
  notes that stay within the published component record.
- `lessons/validation-evidence-discipline.md`: adds the worker interpreter path
  and alias check, resolved framework and SDK import paths, and the rule that a
  read-only source tree is never the runtime working directory.
- `lessons/shutdown-and-exit-audit.md`: adds capture of the parent's wait record
  by the process that actually reaps the child, persisted after that OS wait
  completes and before the reaper exits, and cites
  the public #9467 note that matched request outputs came with finalizer errors
  and no established clean shutdown, without per-process detail. That public
  check is a generic single-stage 1 NFE request, so a staged service's native
  shutdown stays unverified there.
- `lessons/README.md`: index updated.
- `skills/accelerator-process-safety/SKILL.md` and its references: device access
  authorization before probes (node mapping plus the effective access policy,
  failing the pre-check when unconfirmed) and then numbering in the launch gate
  and ownership evidence, per-card idle recheck after cleanup, wait-record
  capture location, and checklist fields for authorization, selector and
  framework indices, host process-to-card mapping, and interpreter path.
- `skills/performance-experiment-lifecycle/SKILL.md` and
  `references/experiment-report-template.md`: allocator peak scope in formal
  timing and reporting, an allocator-peak-scope table, a media output contract
  table, decoded metrics versus container hashes, warmup-versus-formal rows, and
  a parity-source limit.
- `skills/open-omni-inference/SKILL.md` and
  `references/public-validation-ladder.md`: device access authorization before
  the probe rung, the container device node to host card mapping resolved
  separately from the selector and masked-framework indices (the installed
  selector's index is authoritative, and host numbering is reusable only after
  that mapping is verified on the implementation), interpreter and resolved
  import paths at construction, recorded output alignment at the public-request
  rung, and allocator peak scope plus warmup-export parity at the
  formal-evidence rung.

## Previous Update: Device-Gating, Order-Block and Exit-Authority Rules

Adds one lesson and updates eight documents, nine files in total. Distilled from
internal validation review of a capability-gated optimization; that evidence is
not public yet, so no per-case source link is cited here and the rules stay
general. A public case link is added in `materials/prs/<topic>/` only after the
evidence is accepted for publication. No case-specific paths, hosts, logs,
commits, device assignments, or unpublished source are included.

The review revision records the intended and the excluded device classes as
separate rows, reserves `not covered` for a device that was not run, reports
each order block with both arms' mean and range plus the arms' startup and
container isolation, keeps causality undetermined when only one arm moves, and
labels a warning shared by both arms as a shared observation with an unknown
root cause.

- `lessons/device-gating-evidence.md` (new): the two claims of a
  capability-gated fast path, one row per device class (intended device versus
  excluded families), per-device evidence (raw query string, gate decision,
  install count, per-scope call counts, parity, side effects), the rule that
  zero fast-path activity proves routing only and that fallback acceptance needs
  baseline parity plus an install side-effect check, no bridging across device
  families, stubbed-backend tests versus real decisions, and the fixed verdict
  vocabulary in which `not covered` means only that the device was not run.
- `lessons/experiment-methodology.md`: adds order-confounded cells and
  independent order-swapped blocks (own warmup and gate, never pooled, arm order
  listed as one possible factor, original regression retained, non-reproduction
  kept causal-undetermined, block-selection guard, pre-registered decision rule,
  recorded arm isolation, and the same-arm comparison across blocks that keeps
  causality undetermined when only one arm moves) and the rule that a later
  block never deletes an earlier regression.
- `lessons/shutdown-and-exit-audit.md`: adds exit codes taken from the parent or
  supervisor wait record, worker self-reports kept in a separate column, `not
  retained` rows, scoped acceptance wording, a warning count checked separately
  from the missing codes, and shared-warning handling (a shared observation with
  an unknown root cause) judged against the pre-fixed exit requirement.
- `lessons/README.md`: index updated.
- `skills/accelerator-process-safety/references/shutdown-audit.md`: parent wait
  records versus worker self-reports, `not retained` rows, the shared-observation
  wording, and the separate warning-count check in the per-process and reporting
  checklists.
- `skills/open-omni-inference/SKILL.md` and
  `references/public-validation-ladder.md`: capability-gated paths recorded per
  device class at the agile A/B rung, with fallback acceptance split from routing
  and `not covered` reserved for an untested device; device-family scoping of
  every number at the formal evidence rung, and parent-recorded exit rows at the
  exit rung.
- `skills/performance-experiment-lifecycle/references/experiment-report-template.md`:
  a capability-gating table with a side-effect column, an order-block table with
  per-arm mean and range plus an arm-isolation column and the causal-undetermined
  verdict wording, and a process-exit table that records the source of each exit
  code and keeps worker self-reports separate.

## Previous Update: Experiment and Exit-Audit Lessons

Adds one lesson and one skill reference, and updates six documents, eight files
in total. Derived from a public PR thread and internal validation; no
case-specific paths, hosts, logs, commits, or unpublished source are included.

- `lessons/shutdown-and-exit-audit.md` (new): the five exit evidence layers
  (request result, supervisor return, per-process code, shutdown trace, resource
  release), signal exits such as `-9`, grace-period timeout plus force-kill,
  control comparison, claim scope per configuration, and reporting the shutdown
  gap beside the passing numbers.
- `lessons/experiment-methodology.md`: adds cold-request versus steady-state
  discipline (separate startup blocks, both execution orders, no causal claim
  from order-confounded samples) and component-level A/B rules (both orders
  reported separately, actual component load counts, parity and exit records).
- `lessons/validation-evidence-discipline.md`: adds stage scope of a claim
  (collectives, component parity, full request are separate stages), request
  contracts and expected-rejection cases, whole-repository hook checks with a
  complete git tree, and CPU communication tests versus accelerator-backed tests.
- `lessons/README.md`: index updated.
- `skills/accelerator-process-safety/SKILL.md` and
  `references/shutdown-audit.md`: shutdown audit after stopping any multi-process
  service, with a per-process exit and resource-release checklist.
- `skills/open-omni-inference/references/public-validation-ladder.md`: adds a
  final rung for exit and resource release.

## Previous Update: vLLM-Omni PR #11005 audio-overlap archive

Adds `materials/prs/vllm-omni-11005-h3-audio-overlap/`, a public-safe archive
for [vllm-project/vllm-omni#11005](https://github.com/vllm-project/vllm-omni/pull/11005),
which overlaps MiniMax-H3 CPU audio preprocessing with visual encoding on the
Ascend encoder leader. It records:

- the public commits (`80d6b6fc` candidate, `085d7dba` no-overlap baseline,
  `9b753874` target-branch control) and the fixed Ref2VA request;
- the 8-NPU end-to-end contract (120/120 formal requests on the FFmpeg
  `testsrc2`/`aevalsrc` synthetic reference, within-noise latency deltas, no
  end-to-end speedup claim) and the single-NPU `encode_media` component result on
  the public PyTorch synthetic tensors;
- bit-exact 107-frame precision evidence on the public synthetic benchmark pair
  (max absolute RGB difference 0, PSNR inf, SSIM 1.000000, identical PCM and MP4
  hashes);
- a natural-scene demonstration pair on a 10.000-13.000 s excerpt of the public
  CC0 1.0 Commons clip `StreamOfFlowingWater.webm`: source SHA-1/SHA-256, excerpt
  window and input hashes, prompt, seed 3101, observed two-call-per-arm CPU
  44.1 -> 32 kHz resampling coverage, and an identical 107-frame/PCM/MP4
  comparison. It adds no timing number. The only published presentation file
  is the synchronized GIF under `assets/` (left Baseline, right PR); the trimmed
  inputs and the two original output MP4s are not published;
- `assets/stream-baseline-vs-pr.gif`: 512x292, 107 frames, 4.460 s, infinite
  loop, silent, 9,861,406 bytes, transcoded from the accepted comparison MP4 by
  the included `assets/stream-gif.sh`. `assets/README.md` records the identity and
  transcode parameters; `assets/SHA256SUMS` covers the three asset files;
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

## Previous Update: Validation Evidence Lessons

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

Commit subjects for this update, oldest first

```text
Document device gates, run order, and process exit evidence
Clarify device coverage and A/B reporting
Document device numbering, peak scope, and native output alignment
```

## vLLM-Omni PR #9468 precision comparison GIFs

Adds four 124-frame, silent side-by-side animations under
`materials/prs/vllm-omni-9468-h3-gn-silu/assets/` for
[vLLM-Omni PR #9468](https://github.com/vllm-project/vllm-omni/pull/9468).
They show the baseline on the left and the candidate on the right for image
and video conditioning at 1 and 50 NFE, using the
[public Ref2VA inputs](https://github.com/cflin27/vllm-omni/tree/9483ed912963662b7a9d5220a0d200e2060c6761).
The animations are resized for display. The precision measurements use the
original output files.
