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

## Allocator Peak Scope

Fill one row per runner and stage. Record the collection window as well as the
number: where statistics reset, whether the framework or a deferred library
resets a nested counter inside the window, which execution branches allocate
inside it, where the peak is read, and whether the window adds a
synchronization. Report allocated and reserved separately, and state the
aggregation (for example, per request the maximum across the calls on one card,
then the mean of those per-request peaks over the formal requests). This is not
necessarily device HBM usage, and it excludes initialization unless the window
covers it.

| Runner / stage | Window: reset / nested reset / read | Branches covered | Added sync | Aggregate | Baseline allocated / reserved | Candidate allocated / reserved | Gate |
| --- | --- | --- | --- | --- | --- | --- | --- |

A component peak, a full-request peak, and a fixed offload residue are separate
rows and separate claims. A component result does not replace the full-request
number.

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

| Device (raw query) | Gate | Installs | Calls by scope and request shape | Parity vs baseline | Install side effects | Verdict | Timing applicability |
| --- | --- | ---: | --- | --- | --- | --- | --- |

Before formal timing, record the actual candidate call count for each timed
scope and request shape. Record `not collected` when the counter is missing.
For confirmed zero calls, mark the fast-path performance gate `not applicable`.
A verified fallback row completes its smoke checks without a performance block.

## Media Output Contract

Read the pipeline's alignment rule before predicting the output shape. A
requested duration and frame rate can be rounded up to a native frame boundary,
so `duration * fps` is not the expected frame count. Compare arms at the same
aligned index.

| Requested duration / fps | Aligned frames | Output fps / duration | Latent temporal extent | Warmup exports | Formal exports | Comparison basis |
| --- | --- | --- | --- | --- | --- | --- |

## Generated Output Identity

Keep the raw generated tensor, the raw container, and any re-encoded display
copy as separate artifacts, and name which one each parity claim used. A
converted convenience export is a derived artifact, not the raw tensor. Pair by
request index and reported request ID, not by content hash alone.

| Request index | Request ID (baseline / candidate) | Artifact | Shape / dtype | File hash | Content hash | Comparison basis |
| --- | --- | --- | --- | --- | --- | --- |

## Correctness

| Check | Baseline | Candidate | Result |
| --- | --- | --- | --- |
| Output parity on formal requests | | | |
| Request-ID pairing (both arms) | | | |
| Raw tensor file hash / content hash | | | |
| Container hashes | | | |
| Decoded RGB24 / PCM max difference | | | |
| PSNR / SSIM (from raw output) | | | |
| Warmup versus formal (same arm, same seed) | | | Shared observation if identical in both arms |

Decoded metrics and container hashes are different comparisons: byte-identical
containers imply identical decoded bytes, but equal decoded metrics do not imply
identical containers. If arrays were exported only in warmup, the array parity
claim covers warmup only, and the formal outputs are covered by the decoded
comparison alone. Tensor or media export is a separate block from formal timing;
name the block that supplied the parity artifacts and the block that supplied
the timing samples.

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

The exit code authority is the parent's or supervisor's OS wait record. Capture
those records in whichever process actually reaps each child — the in-container
parent, or a host supervisor when that supervisor owns the wait — and have that
reaper persist each record before it exits; a record not captured then is
`not retained`. Decide `not retained` per rank from whether that rank's own
record was retained: a group record, a covered count, or a matching warning
count does not recover a rank whose record is missing. Quote the shutdown
warning with its count next to this table, and reconcile the count against the
`not retained` rows as a separate check; a matching count does not recover a
missing code.

## Device Occupancy

| Device group | First confirmed task ownership (time and evidence) | Confirmed release (time and evidence) | Unfinished blocks and stop reasons | Proven occupancy duration |
| --- | --- | --- | --- | --- |
| | | | | |

Use a lower bound from an interval with evidence of continuous ownership.
Write `unknown` when the evidence cannot establish such an interval. Retain
the process exit table independently.

## Limits

- Not run: include any target device family for a gated fast path that was not
  reached, and state which fallback status the other rows support.
- Parity source: warmup exports, formal outputs, or both, and which claim each
  supports.
- Known caveats:
- Evidence that should not be generalized:
