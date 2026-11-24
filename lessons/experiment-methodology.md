# Experiment Methodology Lessons

Short public-safe lessons for performance experiments. For evidence identity,
device probes, and failure triage, see
[validation-evidence-discipline.md](validation-evidence-discipline.md).

## Cache

- Separate cold-cache, warm-cache, and repeated-input results.
- Do not reuse the same content for warmup and formal measurement unless the
  benchmark explicitly targets cache hits.

## Cold Requests Versus Steady State

- Record the first request after each process start separately from the measured
  repeats. Keep its value, and the arm order of the startup it came from.
- A single cold request per arm cannot establish a regression, and it cannot be
  explained away either. When both blocks start the candidate first, startup
  order, page cache, and first-time offload or reload remain confounded.
- Decide causality with independent startups, repeated cold samples, and both
  execution orders. Until that exists, report the cold difference as an open
  limitation, not as a source-level regression.
- Do not let the steady-state mean absorb a slow cold request, and do not quote a
  steady-state improvement as a cold-start improvement. They answer different
  questions.

## Order-Confounded Cells and Independent Blocks

- A fixed arm order inside a matrix (candidate always second) leaves every cell
  ambiguous: warmup state, page cache, allocator growth, background load, and
  thermal drift all follow order. Name arm order as one possible contributing
  factor, not as the cause; a single regressed cell is order-confounded, not yet
  a proven regression.
- When one cell regresses, rerun that cell alone in a separate block with the
  arm order reversed. Give the block its own warmup, samples, and gate
  decision; do not merge, pool, or average it with the original matrix.
- Report the original regression row unchanged even when the new block is
  inside the gate. Say the effect did not reproduce under the reversed order and
  that causality remains undetermined. A non-reproduction does not show that
  order caused the original cell, and it does not show the candidate is free of
  a regression; do not upgrade it to "no regression".
- Reversal changes arm order together with every other factor that follows arm
  position, so one reversed block cannot separate order from those factors.
  Unless the other factors are controlled independently, keep order as a
  possible factor and keep the causal question open.
- Compare each arm with itself across blocks before attributing a difference to
  order. If the baseline mean and range hold in both blocks while the candidate
  mean moves between them, arm order alone does not explain the difference.
  Keep causality undetermined, name the arm that moved, and do not promote the
  difference to a source regression or close it as a no-regression result.
- Fix the decision rule before running: which block decides promotion, which
  threshold applies, and how many blocks are allowed. Rerunning a cell until one
  block passes is block selection, not evidence. Report every block that ran.
- Keep input, seed, parameters, and warmup count identical between the blocks;
  only arm order should differ. If anything else changed it is a new
  experiment, not an order control. Record the arm isolation as well: one shared
  service start or container (and which arm ran first), or one container,
  process, and cache per arm. A shared startup carries page-cache, compile, and
  allocator state from the first arm to the second.
- Apply the same per-round gate to the order-swapped block. Passing it shows the
  original cell did not reproduce under that order; it does not show the
  candidate is faster, and it does not resolve what produced the original cell.

## Component-Level A/B

- Run the component comparison in both execution orders and report the blocks
  separately instead of pooling them.
- Record the actual work the component performs per arm (for example how many
  times each stage loads) and the peak allocator usage. The counts show the
  mechanism; they do not turn component timing into full-request latency.
- Keep per-round samples, warmup, output parity, and an independent process exit
  record for the component run. Component parity is evidence for that stage only.

## Async Overlap

- Prove the target interval overlaps before claiming an async speedup.
- Use full request wall time to decide promotion.

## Allocator State

- Avoid serial baseline/candidate comparisons that inherit allocator pools.
- Use independent services, reset state, or run both orders and report the
  limitation.

## Precision and Determinism

- Keep verification/deterministic flags out of formal performance timing unless
  the claim targets that mode.
- Pair outputs by request order and input identity before judging differences.

## Measurement Layers

- Host-side call interval, kernel/device time, and end-to-end wall time are three
  different quantities. A wider call interval can coexist with unchanged kernel
  time and unchanged request latency when the extra time overlaps another call.
- Report the stage, the call interval, and the full request separately. Only the
  full request supports a user-facing speedup claim.
- Before calling an async change promoted, show the overlap as the intersection
  of producer and consumer intervals inside one request, and show that it
  shortens a critical-path interval. Total overlapped duration is not a saving.
- A wider host call interval is diagnostic, not evidence of a CPU kernel
  regression. Check kernel time before reporting one.

## Timing Hygiene

- Separate warmup, formal timing, and method tracing into distinct runs. Never
  mix trace overhead into formal samples.
- Fix host-side parallelism (thread count, affinity) across arms when timing a
  CPU-side stage; otherwise the arms measure different machines.
- Warm up each version independently before its measured repeats.
- Keep tail samples. Report the sample range and count as well as the mean so
  slow-tail behavior stays visible.
- Percentiles from a handful of samples are interpolations of the same data, not
  stable tail estimates. Use them to screen, not to settle a marginal gate.

## Promotion Gates

- Apply the regression gate per round and per metric, not only to the arithmetic
  mean across rounds.
- Report pooled-sample statistics separately from per-round statistics; pooling
  can hide a single-round regression.
- State before the run which metrics feed the gate and which are diagnostic, so
  a favorable metric cannot be chosen after the fact.
- A regression recorded in one block is never deleted by a later block. Report
  every block, mark whether the effect reproduced, and keep the promotion
  decision in one place that names the evidence it used.
