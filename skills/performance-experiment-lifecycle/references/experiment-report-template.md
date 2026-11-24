# Experiment Report Template

## Decision

- Question:
- Decision: promote / reject / needs more evidence
- Reason:

## Contract

- Public repository and base commit:
- Baseline:
- Candidate:
- Public model/workload:
- Public input sequence:
- Device and runtime:
- Device capability gates and the expected fallback behavior:
- Fixed switches and parameters:

## Agile Screening

| Candidate | Scope | Correctness | Timing signal | Decision |
| --- | --- | --- | --- | --- |
| | | | | |

## Formal Timing

Profiler disabled. Warmup excluded. Host parallelism fixed across arms.

| Arm | Warmup | Measured requests | Raw samples | Mean | Range | Notes |
| --- | --- | ---: | --- | ---: | --- | --- |
| Baseline | | | | | | |
| Candidate | | | | | | |

Per-round gate check:

| Round | Metric | Baseline | Candidate | Delta | Gate |
| --- | --- | ---: | ---: | ---: | --- |
| | | | | | |

## Order Blocks

Cells that regressed in the main matrix and were rerun alone with the arm order
reversed. Report each block on its own; never pool it with the matrix. Record
both arms' statistics in the same row so the blocks can be compared arm by arm.

| Cell | Block | Arm order | Arm isolation | Warmup | Samples | Baseline mean / range | Candidate mean / range | Delta | Gate | Verdict |
| --- | --- | --- | --- | --- | ---: | --- | --- | --- | --- | --- |

`Arm isolation` records how the two arms were started and separated: one shared
service start or container (and which arm ran first), or one container, process,
and cache per arm. A shared startup carries page-cache, operator-compilation,
and allocator state from the first arm to the second, so record it in the row
instead of leaving it in the run notes.

Verdict wording: `did not reproduce`, `reproduced`, `inconclusive`. List arm
order as one possible factor, not as the cause. Keep the original regression row
and state that causality remains undetermined even when the effect does not
reproduce: the reversed block changes arm order together with the other factors
that follow arm position, and `did not reproduce` does not mean `no regression`.

Compare each arm with itself across blocks before attributing the difference to
arm order. If the baseline mean and range hold in both blocks while the
candidate mean moves between them, arm order alone does not explain the
difference; keep causality undetermined, state which arm moved, and do not
report the result as either a confirmed source regression or a no-regression
pass.

Pooled-sample statistics (report separately from per-round results):

| Arm | Samples | p50 | p90 | Mean | Range |
| --- | ---: | ---: | ---: | ---: | --- |
| Baseline | | | | | |
| Candidate | | | | | |

## Measurement Layers

| Layer | Metric | Baseline | Candidate | Notes |
| --- | --- | ---: | ---: | --- |
| Sub-stage | | | | |
| Host call interval | | | | Diagnostic; not kernel time |
| Full request | | | | Promotion decision |

## Capability Gating

Fill this in only for a change whose optimized path depends on a device
capability check. Zero installs and zero calls show only that the gate selected
the fallback (`fallback selected`). The row becomes `fallback verified` only
with parity against the baseline and a clean install side-effect check. Fill one
row per device class: the intended device and each excluded device family.
`not covered` means no run on that device; a row that ran but still lacks parity
or the side-effect check stays `fallback selected`.

| Device (raw query) | Gate | Installs | Fast-path calls by scope | Parity vs baseline | Install side effects | Verdict |
| --- | --- | ---: | --- | --- | --- | --- |

## Correctness

| Check | Baseline | Candidate | Result |
| --- | --- | --- | --- |
| | | | |

## Independent Profile

| Arm | Scope | Profile settings | Key finding |
| --- | --- | --- | --- |
| | | | |

## Process Exit

| Layer | Process | Exit code | Recorded from | Evidence |
| --- | --- | --- | --- | --- |
| Launcher | | | supervisor wait record | |
| Stage manager | | | parent or supervisor wait record | |
| Rank | | | parent wait record | Mark `not retained` when no OS record exists |
| Worker self-report (separate) | | | worker status file or log | Not an exit code |

The exit code authority is the parent's or supervisor's OS wait record. Quote the
shutdown warning with its count next to this table, and reconcile the count
against the `not retained` rows as a separate check; a matching count does not
recover a missing code.

## Limits

- Not run: include any target device family for a gated fast path that was not
  reached, and state which fallback status the other rows support.
- Known caveats:
- Evidence that should not be generalized:
