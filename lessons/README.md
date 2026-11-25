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
  allocator peak scope (per-runner reset/read boundary, aggregation, component
  versus full-request versus offload residue, warmup export separation), native
  output alignment (frame-count alignment, decoded metrics versus container
  hashes, warmup-versus-formal differences), precision/determinism, measurement
  layers, timing hygiene, and per-round promotion gates.
- [validation-evidence-discipline.md](validation-evidence-discipline.md):
  execution and checkpoint identity including the worker interpreter and the
  resolved import paths, device probe ladder, runtime parameter ranges,
  non-reproduction
  versus a fix, candidate failure triage, read-only source with a writable work
  directory, container input accessibility (host symlinks, input copies, offline
  manifest check), stage scope of a claim, request contracts, whole-repository
  checks, and CPU versus accelerator test resources.
- [generated-output-identity.md](generated-output-identity.md): the three
  artifact layers (raw tensor with original dtype, raw container, re-encoded
  display copy), pairing by request index and reported request ID instead of a
  content-hash set, file hash versus content hash, the scope of a warmup export,
  and the minimum per-request parity rows for tensor and decoded media.
- [shutdown-and-exit-audit.md](shutdown-and-exit-audit.md): exit evidence layers,
  per-rank OS exit capture from the wait record persisted by the process that
  actually obtains that OS wait, after the wait completes and before that reaper
  exits, including a host supervisor that takes over when the launcher exits
  first, worker self-reports kept separate, `not retained`
  rows, signal exits, grace-period force-kill with its warning count checked
  independently of missing codes, control comparison, resource release as a
  verdict separate from clean exit, and how to report a
  shutdown gap next to passing request results.
- [device-numbering-and-ownership.md](device-numbering-and-ownership.md): device
  access authorization as a pre-probe gate (device node presentation and
  mapping, devices cgroup or permission policy, failed pre-check when the
  effective access scope is unconfirmed), the index the installed runtime's
  selector accepts versus the framework index after masking versus the host
  physical card, device access isolation versus runtime visibility as separate
  controls, why a correct visible count does not prove physical ownership,
  wrong-card and empty-set failure modes as hypothesis examples, retained host
  enumeration as a stack-specific compatibility case, host-side process-to-card
  snapshots, idle checks before launch and after cleanup, and reporting devices
  by role.
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
