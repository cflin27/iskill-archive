---
name: ascend-profile-analysis
description: Plan, collect, validate, and summarize Ascend/vLLM profiling evidence for public performance investigations. Use when analyzing profiling databases or exports, comparing baseline and candidate runs, mapping hotspots to code, writing an optimization report, or deciding whether a result is strong enough for an open-source PR.
---

# Ascend Profile Analysis

## Overview

Use this skill to turn profiling data into a defensible public performance
story. The goal is not to rank operators mechanically; it is to tie timing,
hotspots, code paths, configuration identity, and validation evidence together.

## Source

Source basis:
[Ascend/MindIE-SD `.agents/skills`](https://github.com/Ascend/MindIE-SD/tree/dev/.agents/skills).

This archive keeps only public-safe, reusable profiling workflow guidance. It
does not copy private local cases, private runtime paths, raw profiler dumps, or
unpublished patches.

## Workflow

1. Fix the comparison contract: same public code base, model revision, input,
   device class, parallelism, warmup, request order, and profiler settings.
2. Separate timing layers: formal wall time, component timing, profile stage
   time, and kernel/operator duration are different evidence types.
3. Validate profile outputs before analysis. Require fresh trace files, kernel
   tables, step summaries, and a clear run identity.
4. Read top-level stage metrics first: Stage, Computing, exposed
   communication, Free, and kernel count.
5. Map hotspots to implementation sites using call counts, shapes, stack traces
   when available, and source inspection.
6. Classify each proposed optimization as exact, numerically equivalent but not
   bitwise guaranteed, or approximate.
7. Report only claims backed by paired evidence. Use "not measured" for missing
   data instead of filling gaps from another run.

## Evidence Rules

- Do not mix baseline and candidate results from different runtimes or inputs.
- Exclude warmup and profiler-enabled runs from formal timing means.
- Treat profile data as diagnostic evidence; use profiler-disabled repeated
  wall-time runs for headline speed.
- Verify CSV units before computing averages.
- When allocator state, process reuse, or device occupancy can affect results,
  reset the comparison or record the limitation.
- Keep raw logs private unless they are already public-safe; publish distilled
  tables and reproduction steps instead.

## References

- Read [evidence-checklist.md](references/evidence-checklist.md) before
  accepting a profile result.
- Use [public-report-template.md](references/public-report-template.md) when
  writing a PR-ready performance note.
