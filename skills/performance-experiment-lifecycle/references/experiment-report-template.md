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
reversed. Report each block on its own; never pool it with the matrix. Run an
equal number of blocks in each order, AB and BA, and report the AB rows and the
BA rows separately; do not pool the two orders into one row or one mean. `Arm
order` records which arm ran first in that block. Per-arm statistics — each
arm's mean and range, whether read within a block or compared across blocks —
apply only when each block starts a new independent process for each arm, so
those blocks can be compared arm by arm. When the process is held fixed — one
process serving both arms, or each arm bound to its own resident process (a
dedicated process per arm is still a fixed-process arrangement) — the comparison
is limited to the arm-to-arm difference and its association with run position:
record the arrangement under `Arm isolation`, fill only `Delta` with the signed
arm-to-arm difference and put the position association in `Notes`, leave
`Baseline mean / range` and `Candidate mean / range` blank instead of reporting
absolute per-arm timings, and do not derive a speedup from that block. A per-arm
mean or range, and a cross-block summary built from them, is not reported for a
fixed-process block, including the one-resident-process-per-arm arrangement. The
row keeps its verdict and gate; the blank statistics are an applicable-scope
limit, not a missing measurement.

| Cell | Block | Arm order | Arm isolation | Warmup | Samples | Baseline mean / range | Candidate mean / range | Delta | Gate | Verdict | Notes |
| --- | --- | --- | --- | --- | ---: | --- | --- | --- | --- | --- | --- |

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
arm order, only for blocks that each started a new independent process for each
arm. If the baseline mean and range hold in both blocks while the candidate mean
moves between them, arm order alone does not explain the difference; keep
causality undetermined, state which arm moved, and do not report the result as
either a confirmed source regression or a no-regression pass. For a
fixed-process block, report only that block's `Delta` with its run-position
association in `Notes`; do not build a per-arm statistic or a cross-block
summary from fixed-process rows.

Pooled-sample statistics (report separately from per-round results; only for
blocks that started a new independent process for each arm):

| Arm | Samples | p50 | p90 | Mean | Range |
| --- | ---: | ---: | ---: | ---: | --- |
| Baseline | | | | | |
| Candidate | | | | | |

## Request Timeline Breakdown

Use this when a per-request gate fails while engine-stage timers are flat, or
when the excess sits outside the measured stages. Anchor the window's ownership
first, at the first public request or at a named sync point inside the measured
window: take a host process-to-card snapshot there, record the checkpoint marker
with the block, retain each holder's PID, start time, and role in the private run
record, and reconcile the card and container device node against the grant and
the holder PID and start time against this arm's process identity. The
before-launch grant and the after-cleanup check are endpoints only; the grant is
the set the in-window holders are checked against, not a substitute for that
reconciliation. Then
define mutually exclusive host
intervals with named owners (request entry, input preparation and dependency
resolution, engine serving, response delivery, media packaging, and an explicit
unattributed remainder), and name each interval after the code path that owns
it. Verify the shared monotonic clock per arm and per container, and report the
arithmetic closure error separately from the remainder: closure describes the
bookkeeping, not completeness. Run an equal number of blocks in each order, AB
and BA, so each arm runs first and second equally often, record which order each
block used, and report the two orders as separate rows rather than one pooled
row.

| Block / pair | Interval | Owner | Baseline | Candidate | Delta | Notes |
| --- | --- | --- | ---: | ---: | ---: | --- |

Device and process reconciliation at the sync point:

| Checkpoint | Card | Processes holding it (pid / role) | Holder start time | Granted to this block | Matches this arm's process identity | Verdict |
| --- | --- | --- | --- | --- | --- | --- |

Reconcile on two axes: the card and container device node against the grant, and
the holder PID and start time against this arm's process identity. A matching
card number alone does not exclude an outside process holding the same granted
card. If no in-request checkpoint could be synchronized, a snapshot shows a
holder outside this arm's process identity, or either reconciliation lacks
evidence, write `attribution undetermined` for the affected block and keep its
failing row; do not assign the excess to either arm. Two snapshots prove only
their sample points; a short-lived process that starts and exits entirely
between them can still be missed.

Closure check:

| Block | Requests | Dropped events | Intervals + unattributed vs full request | Closure error |
| --- | ---: | ---: | --- | --- |

Attribution verdict per failing row: `candidate-owned interval, follow-up
supported` / `order-confounded or shared` / `attribution undetermined` (name the
intervals that carried the excess) / `unresolved`. A packaging or
API-preparation delta that flips sign between AB and BA takes `attribution
undetermined`, not `order-confounded or shared`, matching the lesson and skill.
A candidate-owned interval whose direction holds under reversal supports a
targeted follow-up, not a causal conclusion; causality needs a control that
isolates the code difference. Keep the failing row with its verdict; no verdict
clears the candidate or closes the gate.

Controlled replay: record the suspect interval, the public input bytes, the
fixed thread and CPU configuration, the pre-packaging RGB24/PCM hashes collected
separately from each arm before the shared encoding and packaging step, the
saved read-only raw-byte payload (one copy of the verified RGB24 frames and PCM
samples, not their hash) handed to both arms with each arm's independent
read-back hash checked against the payload hash saved with the payload (matching
each other alone is not enough), the fixed encoding or muxing configuration, the
equal number of AB and BA units run with their results recorded separately by
order, and the finer markers added to the suspect path. Report the replay in its own block; do
not average it with the original samples. When the process is held fixed — one
process serving both arms, or each arm bound to its own resident process —
report only the arm-to-arm difference and whether it follows run position, not
absolute per-arm timings. A replay that moves the excess out of the
candidate-owned interval is interval evidence, not a clearance, and a replay in
which the excess does not reproduce supports only that statement under those
replay conditions.

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

Hash the RGB24 frames and PCM samples before container muxing, per request and
separately for each arm at the point where that arm hands the media to the
shared encoder or container writer: that pair is the correctness evidence, while
the container hash also covers the encoding layer. Compare the two arms' hashes
and require equality before comparing packaging time; do not substitute one
arm's hash for the other. For a replay, save the verified raw bytes once — one
copy of the RGB24 frames and PCM samples — as a read-only payload, hand the same
byte payload to both arms, and have each arm independently re-hash what it read
and check that read-back hash against the payload hash recorded when it was
saved (matching each other alone would accept a shared wrong payload); the hash
verifies the shared payload and does not replace it. Record the encoder
configuration (codec, quality or bitrate setting, pixel and sample format,
container options) next to the comparison and hold it fixed across arms and
blocks, and keep the packaging interval's timing separate from the byte-parity
verdict.

| Pre-packaging RGB24 hash (baseline / candidate) | Pre-packaging PCM hash (baseline / candidate) | Saved raw-byte payload hash and each arm's independent read-back check | Encoder configuration | Packaging interval timing | Notes |
| --- | --- | --- | --- | --- | --- |

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

- Coverage ledger: processes with an independent OS exit record out of the run's
  total (list the uncovered groups), workers whose resolved import path was
  exported, and counters or hooks present in this run. `not collected` is not
  zero and does not supply a value.
- Not run: include any target device family for a gated fast path that was not
  reached, and state which fallback status the other rows support.
- Parity source: warmup exports, formal outputs, or both, and which claim each
  supports.
- Known caveats:
- Evidence that should not be generalized:
