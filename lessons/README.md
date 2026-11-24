# Lessons

This directory stores short, public-safe lessons distilled from repeated agent
work. Lessons complement skills:

- Skills describe how to perform a workflow.
- Lessons capture sharp edges that are easy to forget.

Keep lessons concise and source-attributable. Do not include private paths,
internal service names, raw logs, credentials, unpublished patches, or private
datasets.

## Index

- [experiment-methodology.md](experiment-methodology.md): cache, cold requests
  versus steady state, order-confounded cells and independent order-swapped
  blocks (arm order as one possible factor, arm isolation recorded, same-arm
  comparison across blocks, non-reproduction and single-arm movement kept
  causal-undetermined), component-level A/B, async overlap, allocator state,
  precision/determinism, measurement layers, timing hygiene, and per-round
  promotion gates.
- [validation-evidence-discipline.md](validation-evidence-discipline.md):
  execution and checkpoint identity, device probe ladder, runtime parameter
  ranges, non-reproduction versus a fix, candidate failure triage, read-only
  source with a writable work directory, stage scope of a claim, request
  contracts, whole-repository checks, and CPU versus accelerator test resources.
- [shutdown-and-exit-audit.md](shutdown-and-exit-audit.md): exit evidence layers,
  per-rank OS exit capture from the parent's wait record, worker self-reports
  kept separate, `not retained` rows, signal exits, grace-period force-kill with
  its warning count checked independently of missing codes, control comparison,
  and how to report a shutdown gap next to passing request results.
- [device-gating-evidence.md](device-gating-evidence.md): evidence for a
  capability-gated fast path per device class (intended device versus excluded
  families), why zero fast-path activity proves routing only and a fallback needs
  baseline parity plus side-effect checks, no bridging across device families,
  stubbed-backend tests versus real decisions, and the fixed verdict vocabulary
  in which `not covered` means only that the device was not run.
- [templates/lesson.md](templates/lesson.md): lesson entry template.

## Promotion Rule

Add a lesson only when it is:

- confirmed by evidence,
- likely to recur,
- not obvious from public docs alone,
- safe to publish after removing private context.
