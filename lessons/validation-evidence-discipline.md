# Validation Evidence Discipline

Short public-safe lessons for validating a candidate on shared accelerator
hosts. These complement the performance lessons in
[experiment-methodology.md](experiment-methodology.md): that file is about
measuring, this one is about proving that the measured thing was the intended
thing and that a failure belongs to the candidate. Generated artifact identity
is covered in [generated-output-identity.md](generated-output-identity.md).

## Execution Identity

A run label, model alias, or task-loader entry point is not proof of what
executed. A loader can resolve a different model hierarchy than the label
suggests, a directory can exist while containing fewer shards than expected, and
an import can come from another checkout or overlay.

Record, per arm and before timing:

- the repository commit and dirty status,
- the Python interpreter path that will spawn workers, and whether the launcher
  is a shell alias or wrapper instead of an executable,
- the resolved import path and module `__file__` for the framework and the
  vendor SDK, not only the intended source tree,
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

Keep the actual import paths in the experiment identity as well. A read-only
source checkout can be correct while the service imports the framework or the
vendor SDK from an overlay, a different site-packages, or a container layer.
Record the path the process resolves, not the path it was meant to use, and
never run the service with the read-only source tree as its current working
directory: point the working, cache, and output directories at writable
locations. A missing SDK path on the worker interpreter is a launch-environment
fix; record it as such, next to the first failure.

## Container Input Accessibility

- Verify the read-only source mount and the input directory separately inside
  the container before the first request. A host absolute symlink can resolve on
  the host and resolve to nothing inside the container; the first error is a
  missing path that exists outside.
- Prefer an independent copy of the public inputs in the run's writable
  directory over a symlink to a host path. Hash the copied inputs against the
  public manifest and record the result.
- When the container cannot see the inputs and the check falls back to the
  network, a name-resolution or download failure is an environment failure, not
  a validation result. Finish the identity check against the fixed public
  manifest, and record the fallback together with the first original error.
- A corrected pre-check is an environment fix, not an experimental variable.
  Keep the first failure and the fix next to the arm identity.

## Stage Scope of a Claim

Accelerator collectives, component-level parity, and full request generation are
different validation stages. A passing collective probe or a matching
conditioning array proves that stage only.

- Report each stage's completion separately, including which device group and
  which backend was exercised.
- Component timing is not full-request latency, and component output parity is
  not media or response equivalence. Both can pass while the full pipeline still
  needs its own correctness and timing evidence.
- A passing all-reduce does not prove the collective the model actually uses, and
  a passing collective does not prove the service starts, serves, and shuts
  down.

## Coverage Ledger

A passing check covers the units it actually observed. Record the denominator
and the covered subset for every claim, not only the failures:

- Process exits: how many of the run's processes have an independent OS wait
  record, which groups have none, and whether the API or supervisor returned
  `0` (scoped to itself). See
  [shutdown-and-exit-audit.md](shutdown-and-exit-audit.md).
- Import identity: which processes resolved the intended source tree and Python
  interpreter, and whether any worker's `__file__` was never exported. A
  collector's own hash evidence does not cover the workers it did not inspect.
- Counters and hooks: which counters existed in this run. An absent counter is
  `not collected`, not zero, and an earlier run's hook output cannot supply this
  run's zero-call count.
- Request reconciliation: client, server, and engine identifiers per request,
  one terminal state each, and the number of dropped events.
- Device occupancy: which compared cards had a host process-to-card snapshot
  taken during the first public request or at a named sync point inside the
  measured window, whether each holder's card and container device node were
  reconciled against the granted set and its PID and start time against this
  arm's process identity, whether any outside holder appeared, and which
  intervals are covered only by before-launch and after-cleanup endpoint checks.
  A window without a synchronized snapshot, either reconciliation, or a
  confirmed PID mapping leaves the affected row at attribution undetermined; it
  neither clears nor convicts the candidate. Two snapshots cover only their
  sample points, so a short-lived process between them can be missed.

Publish the ledger beside the passing table. "All processes exited cleanly" is
false when only a subset has a record, and "zero fast-path calls" is unproven
when no count was collected in the run. Do not fill a gap with a value inferred
from the code path, and do not let a coverage gap clear or condemn the
candidate: it limits the claim.

## Request Contracts Before Calling a Failure

Read the public input contract before running, then classify each case.

- Some pipelines require at least one image or video reference and must reject an
  audio-only or no-reference request with a documented error. A negative case
  that returns the documented rejection is a pass, not a regression.
- An extracted audio track paired with a reference frame is not the same request
  shape as an audio-only request. Label derived inputs by how they were produced
  and keep them separate from the original public input.
- After a rejection, prove recovery by sending a valid request to the same
  service. A rejection that leaves the service unusable is a real failure.
- Measure latency and throughput only on the positive cases that are expected to
  generate output.

## Full-Repository Checks

- Whole-repo formatter and lint hooks need the complete git tree. A sparse
  checkout can miss first-party packages, producing errors the full tree does
  not have; check out fully, or label the check as partial.
- Confirm the hook version pinned in the repository configuration matches the
  binary that ran, and report whether any hook auto-fixed files so the final tree
  is clean or the diff is known.
- On an unstable network, install the pinned versions from public registries with
  hash verification inside the disposable container. Do not replace a required
  whole-repo check with a sampled file list.

## CPU Communication Tests Versus Accelerator-Backed Tests

- A CPU collective test and an accelerator-backed test need different resources.
  Record the actual device mapping and the communication backend for each run.
- An accelerator initialization or pinning error in a CPU-only regression is an
  environment setup failure, not a candidate regression; confirm it on the
  control before spending a run on it.
- Check the interpreter that spawned workers actually use. Describe the launch
  path by the launcher's own conditions: a shell alias, function, or wrapper
  that is not an executable on PATH can reach the child launch with no usable
  executable, and an empty executable field is one manifestation rather than the
  only one. Pass the interpreter path explicitly, keep it in the arm identity,
  and confirm the vendor SDK imports on that interpreter.

## Public Sources

- Public PR and validation links are added per case in
  `materials/prs/<topic>/`, after the case evidence is accepted for publication.
- Generic ladder and identity discipline: see
  [source-identity-audit](../skills/source-identity-audit/SKILL.md) and
  [open-omni-inference](../skills/open-omni-inference/SKILL.md).
