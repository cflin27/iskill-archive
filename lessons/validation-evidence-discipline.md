# Validation Evidence Discipline

Short public-safe lessons for validating a candidate on shared accelerator
hosts. These complement the performance lessons in
[experiment-methodology.md](experiment-methodology.md): that file is about
measuring, this one is about proving that the measured thing was the intended
thing and that a failure belongs to the candidate.

## Execution Identity

A run label, model alias, or task-loader entry point is not proof of what
executed. A loader can resolve a different model hierarchy than the label
suggests, a directory can exist while containing fewer shards than expected, and
an import can come from another checkout or overlay.

Record, per arm and before timing:

- the repository commit and dirty status,
- the runtime import path and module `__file__`,
- key source file hashes,
- container image digest, driver/runtime/CANN or CUDA versions,
- the model class the loader actually constructs, not only its alias,
- checkpoint revision or hash, plus expected versus present shard count,
- the full launch arguments.

If the checkpoint identity is unavailable, mark the result as
identity-unverified instead of assuming the intended weights loaded.

## Device Probe Ladder

Raise the rung only after the previous one passes, and record each rung:

1. Device enumeration and context creation.
2. A real tensor operation followed by synchronization.
3. A collective primitive across the exact target device group, with a checked
   result value.
4. The collective the target model path actually uses (for example all-gather or
   all-to-all). A passing all-reduce does **not** prove a different collective
   used later by the model.
5. Service health, then one request whose output can be decoded or parsed with
   an independent tool.

A missing or failed rung is a stop condition. Do not spend a full formal run to
discover a rung that a two-minute probe would have caught.

## Runtime Parameter Ranges

Validate timeout, retry, and resource parameters against the range the runtime
library actually accepts before launch. Units and limits are often documented in
code rather than in prose, and a value chosen "long enough" can be rejected at
initialization or fail later with an unrelated-looking error.

Keep the first rejection and the corrected command. When a parameter is narrowed
during setup, record it as an environment fix, not as an experimental variable.

## Non-Reproduction Is Not a Fix

If a failure seen in an earlier, different configuration does not reproduce in
the configuration you chose, report exactly that: "not observed with this
configuration". Do not report the failure as fixed.

To claim a fix you need a targeted run of the failing path itself, on the same
configuration that failed before. Keep the earlier failure record and say which
variable changed.

## Candidate Failure Triage

Record each candidate failure with the failing check, location, and first error.
Repeat the same check on the control in the same environment and report its
outcome alongside the candidate result.

- If the control passes, report a candidate-only failure and investigate its
  cause before attributing it to the change.
- If the control fails in the same way, report a shared failure. Assess whether
  both arms still produce the valid outputs and samples the comparison requires.
  The failure blocks the comparison if either arm lacks required evidence.
- If the control retest is incomplete or fails differently, record what happened
  and leave attribution unresolved.
- A unit test that needs an accelerator allocator context can fail outside a
  device context. Check the same path on the control before attributing the
  failure to the environment.

## Read-Only Source, Writable Work Directory

For validation runs, mount or check out the source read-only and give the job a
separate writable working directory for reports, caches, and generated inputs.

Tools that auto-write a report, profile, or cache next to the source will fail
initialization or modify the tree when the source is read-only; with a shared
tree they can also leave state that the next arm inherits. Keeping source
read-only makes the tree clean at the end and makes "which code ran" auditable.

## Public Sources

- Public PR and validation links are added per case in
  `materials/prs/<topic>/`, after the case evidence is accepted for publication.
- Generic ladder and identity discipline: see
  [source-identity-audit](../skills/source-identity-audit/SKILL.md) and
  [open-omni-inference](../skills/open-omni-inference/SKILL.md).
