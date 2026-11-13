# Allocator Isolation

Allocator and memory-pool state can make one arm inherit work already paid by
another arm.

## Hazards

- Baseline and candidate run in the same long-lived service.
- The first arm expands pools or compiles kernels, and the second arm reuses the
  state.
- Profile runs change allocation behavior.
- Device memory appears free to a coarse tool while a process still owns files
  or context.

## Rules

- Prefer independent services or reset conditions for baseline and candidate.
- If using one service, run both orders and record the limitation.
- Separate warmup, formal timing, and profile runs.
- Record allocator-sensitive setup, such as preallocation, cache reset, or pool
  warmup.
- Treat single profile differences as diagnostic until confirmed by formal
  timing.

## Report Phrase

Use language like:

```text
This comparison used independent services for baseline and candidate to avoid
allocator-pool inheritance between arms.
```
