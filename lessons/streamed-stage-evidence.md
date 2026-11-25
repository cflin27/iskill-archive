# Streamed Stage Evidence

Short public-safe lesson for proving a streaming or staged input change on a
shared accelerator host: uploading tiles, clips or shards instead of a whole
tensor. It complements
[experiment-methodology.md](experiment-methodology.md) (how to measure) and
[validation-evidence-discipline.md](validation-evidence-discipline.md) (how to
prove what executed).

## Scope

Changes that keep the same arithmetic but move where an input tensor is built,
normalized or uploaded, for example per-rank tile or per-clip preparation before
a VAE encode.

## Symptom

A streamed path can look beneficial and still be wrong on three independent
axes:

- the fast path is enabled but not actually taken, so the comparison measures
  two identical ordinary runs;
- the reported "peak memory" is an allocator high-water mark, while the reader
  assumes it is device HBM;
- a lower stage latency is reported as an end-to-end speed-up.

Per-rank logging and fallback expectations are a fourth trap: a skip reason that
looks absent on one rank may be deduplicated by scope, not missing.

## Root Cause

- Eligibility gates are conservative by design, so configuration alone does not
  prove the branch ran.
- Allocator peak, device HBM, and host-side call interval are different
  quantities with different collection boundaries.
- Noise calibrated at one stage does not calibrate a different stage or the full
  request.
- `info_once` scope and effective log level depend on the runtime and the
  distributed world size.

## Next Time

1. Instrument an explicit hit counter and require a hit on every rank before
   timing. A flag value is not evidence; a counter is.
2. Compare output content, not only shape: encoder rows or latent hashes against
   the ordinary path, per input variant, including the fallback geometry.
3. Exercise each fallback on purpose (legacy flag, unsupported layout, missing
   sampler, unsupported device) and assert both output equality and a single
   one-time reason line.
4. Name the memory metric precisely. Allocator high-water mark is not device
   HBM; if device HBM is sampled at request start, say so and do not present it
   as a full-request peak. If an earlier measurement is reused in documentation,
   keep its candidate SHA and collection boundary; never relabel an allocator
   figure as device HBM after the fact.
5. Apply each gate at its own layer: stage device-event latency and stage
   allocator peak against stage A/A noise, full-request wall time and
   full-request allocator peak against a matching full-request calibration.
   Never reuse one layer's A/A for another.
6. When a confidence interval includes zero, report the change as neutral. Do
   not turn a favorable point estimate into a speed-up claim.
7. Verify the logging contract in the real distributed runtime: signature,
   default scope, effective level, and the observed line count across ranks.
   Repeated calls should not repeat the reason.
8. Record concurrent workloads on co-assigned devices with the snapshot time,
   and keep that interference in the conclusion. A request-start snapshot is an
   observation, not continuous occupancy.
9. In unprivileged containers built from shared images, the runtime user needs
   system user/group entries, a writable HOME, and ownership checks on inference
   libraries. When a same-byte copy in an isolated directory is required, record
   `cmp`/hash equality and the actual import path.

## Public Sources

- [vllm-project/vllm-omni#11003](https://github.com/vllm-project/vllm-omni/pull/11003)
  and its archive in
  [materials/prs/vllm-omni-11003-h3-stream-tile](../materials/prs/vllm-omni-11003-h3-stream-tile/README.md).
- Stage and request gating practice:
  [performance-experiment-lifecycle](../skills/performance-experiment-lifecycle/SKILL.md).
- Execution identity and device probes:
  [source-identity-audit](../skills/source-identity-audit/SKILL.md).
