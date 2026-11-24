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
  versus steady state, component-level A/B, async overlap, allocator state,
  precision/determinism, measurement layers, timing hygiene, and per-round
  promotion gates.
- [validation-evidence-discipline.md](validation-evidence-discipline.md):
  execution and checkpoint identity, device probe ladder, runtime parameter
  ranges, non-reproduction versus a fix, candidate failure triage, read-only
  source with a writable work directory, stage scope of a claim, request
  contracts, whole-repository checks, and CPU versus accelerator test resources.
- [shutdown-and-exit-audit.md](shutdown-and-exit-audit.md): exit evidence layers,
  signal exits, grace-period force-kill, control comparison, and how to report a
  shutdown gap next to passing request results.
- [templates/lesson.md](templates/lesson.md): lesson entry template.

## Promotion Rule

Add a lesson only when it is:

- confirmed by evidence,
- likely to recur,
- not obvious from public docs alone,
- safe to publish after removing private context.
