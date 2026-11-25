---
name: performance-experiment-lifecycle
description: Design, run, and report public-safe performance experiments that use agile screening, formal profiler-disabled timing, and independent profiling. Use when evaluating an optimization candidate, deciding whether to promote a change, comparing baseline and candidate runs, or preparing validation material for an open-source PR.
---

# Performance Experiment Lifecycle

## Overview

Use this skill to keep performance work honest and efficient: screen cheaply,
promote only valid candidates, time formally without profiler overhead, and
collect profile evidence in a separate run.

## Source

Source basis: public-safe workflow distillation from local experiment practice.
This skill intentionally keeps the method, not private cases, paths, switches,
model identities, raw logs, or unpublished source changes. When archiving a
concrete public result, add public repository, PR, model/workload, and input
links in `materials/prs/<topic>/README.md`.

## Experiment Contract

Before running anything, record:

- Question: what decision this experiment should answer.
- Baseline: public commit, public model/workload, and expected behavior.
- Candidate: the single intended variable.
- Fixed conditions: input sequence, seed, output shape, device type,
  parallelism, runtime versions, service pipeline, and environment switches.
- Promotion gates: correctness, timing direction, variance tolerance, and
  required evidence.

Do not compare runs that differ in unrecorded runtime, input, model, or request
order. Do not reuse an old baseline unless the contract still matches.

## Phase 1: Agile Screening

Use agile screening to reject weak ideas quickly.

- Run only the necessary stage or smallest public request that exercises the
  candidate.
- Keep baseline and candidate symmetric except for the tested variable.
- Check correctness at the same level as the screened stage: tensor, media,
  parser output, API response, or another domain-appropriate artifact.
- Screen optional fast paths by counting actual candidate calls for each
  scope on the workload shape and configuration planned for timing. Require a
  confirmed hit to promote the scope to paired timing with its baseline. A
  confirmed zero makes the fast-path performance gate not applicable. A
  missing count requires evidence before promotion.
- Prefer paired A/B runs over isolated absolute timings.
- Stop early when correctness fails, timing moves the wrong way, or evidence is
  too noisy to justify promotion.

Agile screening can prove that a mechanism works. It does not by itself prove a
headline speedup.

## Phase 2: Formal Timing

Promote only one selected candidate to formal timing.

- Disable profilers and heavy tracing.
- Use a fixed warmup sequence and exclude warmup from the mean.
- Warm up each version independently before its measured repeats.
- Run repeated measured requests using the same sequence for baseline and
  candidate.
- Fix host-side parallelism, thread count, and affinity across arms when the
  measured stage has CPU-side work.
- Report raw samples, arithmetic mean, sample range, units, and sample count.
  Keep tail samples; do not trim slow requests.
- Apply the regression gate per round and per metric, not only to the mean across
  rounds. Report pooled-sample statistics separately from per-round statistics.
- For distributed stages, state the aggregation rule before averaging, such as
  per-request maximum across ranks.
- When a per-request gate fails while engine-stage timers are flat, collect a
  request timeline instead of rerunning the matrix. Anchor ownership first: take
  a host process-to-card snapshot during the first public request or at a named
  sync point inside the window, retain the checkpoint marker and each holder's
  PID, start time, and role in the private record, and reconcile on two axes:
  the card and container device node against the grant, and the holder PID and
  start time against this arm's process identity. A matching card number alone
  does not exclude an outside holder. The before-launch grant and the
  after-cleanup check are endpoints only and do not replace that in-window
  evidence; two snapshots cover only their sample points, so a short-lived
  process between them may still be missed. When no in-request checkpoint can be
  synchronized, either reconciliation lacks evidence, or a snapshot shows a
  holder outside this arm's process identity, the affected row is attribution
  undetermined, not assignable to an arm. Then
  decompose the request into mutually exclusive host intervals with named
  owners, an explicit unattributed remainder, and the arithmetic closure error
  reported separately. Run an equal number of blocks in each arm order, AB and
  BA, and report them separately by order. An excess inside
  candidate-owned intervals with the
  same direction under reversal supports a targeted follow-up, not a causal
  conclusion; a causal conclusion needs a control that isolates the code
  difference. A packaging or API-preparation excess that flips with arm order is
  reported as attribution undetermined, not as a source regression or a
  clearance.
- For every allocator or memory peak, state the collection boundary per runner
  (where it resets, whether a nested library reset inside the window, where it
  reads), which execution branches it covers, how per-request values are
  aggregated, and whether the number is allocated or reserved. A component peak,
  a full-request peak, and a fixed offload residue are separate observations.
- Keep correctness or deterministic checks separate from performance mode when
  those checks require different runtime flags.

Headline performance claims should come from this phase, not from profile runs.

## Phase 3: Independent Profile

Collect profile evidence after formal timing warrants it.

- Start a separate baseline and/or candidate profile run with the same public
  contract.
- Warm up before collecting the profiled request.
- Profile only the necessary scope and ranks unless the question requires more.
- Validate the profile export before analyzing it.
- Use profile data to explain the timing result, not to replace the timing
  result.

If only one side is profiled, state that the profile is diagnostic rather than
a paired comparison.

## Reporting

Use [experiment-report-template.md](references/experiment-report-template.md).
The report must distinguish:

- screened candidates that were rejected,
- the selected candidate,
- formal timing evidence,
- profile explanation,
- correctness evidence,
- limitations and not-run items.

Keep three measurement layers apart in the report: the sub-stage, the host call
interval, and the full request. Only the full request supports a user-facing
speedup claim; a wider host call interval is diagnostic, not a kernel
regression. State which metrics fed the promotion gate and which were
diagnostic, and report per-round results next to any pooled aggregate.

Record the requested and the actual output shape together: requested duration,
frame rate, aligned frame count, output frame rate and duration, and the
generated latent's temporal extent. A pipeline can round the request to a
native frame alignment, so `duration * fps` is not the expected output count;
compare arms at the same aligned index and check the latent extent against it.

State whether parity evidence came from warmup exports or from the formal
outputs. Warmup-exported arrays cannot certify the formal requests. When both
arms show the same warmup-versus-formal difference, report it as a shared
observation with an unknown cause rather than a candidate regression.

When a gate failed, include the request interval table with the unattributed
remainder, closure error, and an attribution verdict per failing row:
`candidate-owned interval, follow-up supported`, `order-confounded or shared`,
`attribution undetermined` (name the intervals that carried the excess), or
`unresolved`. No verdict clears the candidate or closes the gate. Include the
coverage ledger beside
the passing table: processes with an independent OS exit record out of the run's
total, workers whose resolved import path was exported, and counters present in
this run. `not collected` is not zero.

## Method References

- [cache-methodology.md](references/cache-methodology.md): avoid mistaking
  repeated-input cache hits for general speedups.
- [async-overlap-validation.md](references/async-overlap-validation.md): prove
  useful overlap before promoting asynchronous changes.
- [allocator-isolation.md](references/allocator-isolation.md): keep baseline and
  candidate allocator state comparable.
- [precision-determinism.md](references/precision-determinism.md): keep
  precision, determinism, and performance modes separate.
