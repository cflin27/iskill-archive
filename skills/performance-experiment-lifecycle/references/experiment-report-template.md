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

## Correctness

| Check | Baseline | Candidate | Result |
| --- | --- | --- | --- |
| | | | |

## Independent Profile

| Arm | Scope | Profile settings | Key finding |
| --- | --- | --- | --- |
| | | | |

## Limits

- Not run:
- Known caveats:
- Evidence that should not be generalized:
