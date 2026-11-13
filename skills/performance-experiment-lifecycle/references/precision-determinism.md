# Precision and Determinism

Precision checks, determinism checks, and performance timing often require
different runtime modes. Keep them separate.

## Rules

- Use production-like defaults for formal performance timing unless the public
  claim is specifically about deterministic mode.
- Enable deterministic or verification flags only for correctness checks.
- Pair outputs by request order and input identity; do not mix hash sets across
  repeated runs.
- When a final media hash differs, localize the difference by stage before
  blaming encoding, packaging, or model semantics.
- Record exactness, tolerance, sample count, and comparison target.

## Debug Order

1. Confirm input, seed, model, and request order.
2. Compare intermediate tensors or structured outputs at stage boundaries.
3. Compare final artifacts with hashes and independent decoders/parsers.
4. Separate self-reproduction noise from baseline/candidate differences.
5. Report the first stage where divergence appears.

## Report Phrase

Use language like:

```text
Correctness was checked in verification mode. Formal timing was collected
separately in the default performance mode, so the timing result does not include
verification overhead.
```
