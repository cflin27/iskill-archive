# Experiment Methodology Lessons

Short public-safe lessons for performance experiments. For evidence identity,
device probes, and failure triage, see
[validation-evidence-discipline.md](validation-evidence-discipline.md).

## Cache

- Separate cold-cache, warm-cache, and repeated-input results.
- Do not reuse the same content for warmup and formal measurement unless the
  benchmark explicitly targets cache hits.

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
