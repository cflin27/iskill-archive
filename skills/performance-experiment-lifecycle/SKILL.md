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
- Prefer paired A/B runs over isolated absolute timings.
- Stop early when correctness fails, timing moves the wrong way, or evidence is
  too noisy to justify promotion.

Agile screening can prove that a mechanism works. It does not by itself prove a
headline speedup.

## Phase 2: Formal Timing

Promote only one selected candidate to formal timing.

- Disable profilers and heavy tracing.
- Use a fixed warmup sequence and exclude warmup from the mean.
- Run repeated measured requests using the same sequence for baseline and
  candidate.
- Report raw samples, arithmetic mean, units, and sample count.
- For distributed stages, state the aggregation rule before averaging, such as
  per-request maximum across ranks.
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

## Method References

- [cache-methodology.md](references/cache-methodology.md): avoid mistaking
  repeated-input cache hits for general speedups.
- [async-overlap-validation.md](references/async-overlap-validation.md): prove
  useful overlap before promoting asynchronous changes.
- [allocator-isolation.md](references/allocator-isolation.md): keep baseline and
  candidate allocator state comparable.
- [precision-determinism.md](references/precision-determinism.md): keep
  precision, determinism, and performance modes separate.
