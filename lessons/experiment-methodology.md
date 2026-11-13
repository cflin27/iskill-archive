# Experiment Methodology Lessons

Short public-safe lessons for performance experiments.

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
