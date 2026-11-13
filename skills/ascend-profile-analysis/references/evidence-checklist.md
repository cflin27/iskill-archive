# Ascend Profile Evidence Checklist

Use this checklist before trusting a profile comparison.

## Run Identity

- Public repository URL, branch, and commit are recorded.
- Baseline and candidate are built from the same public base except for the
  tested change.
- Model, tokenizer/processor, public input, seed, output shape, steps, batch,
  and parallelism are recorded.
- Device type, driver/CANN/runtime versions, framework versions, and profiler
  settings are recorded.

## Timing Integrity

- Warmup runs are listed separately and excluded from formal means.
- Formal timing is profiler-disabled and repeated enough for the claim.
- Profile runs are separate from formal timing.
- Per-rank distributed stage times use a stated rule, such as per-request
  maximum across ranks, before averaging requests.
- Units are checked for every CSV or profiler table.

## Profile Completeness

- Trace view, kernel table, operator statistics, and step summary exist.
- The profile time range matches the intended request and stage.
- The raw dump was exported or analyzed by a supported offline method.
- The report states whether stacks were collected.

## Comparison Hazards

- Allocator state was reset or the limitation is documented.
- Device group occupancy was checked before each run.
- Baseline and candidate were not run through different service pipelines.
- Exactness, numeric tolerance, or media equivalence was checked when behavior
  might change.
