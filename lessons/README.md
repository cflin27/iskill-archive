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
  layers, timing hygiene, device time and retained capacity (per-card interval
  union under stable anonymous card labels kept across groups, overlapping
  requests counted once instead of adding group products, continuous occupancy
  required across the whole interval rather than two holder samples, one
  comparable clock for each start/end difference and for cross-arm merges with
  wall clock kept as a separate audit column, the formal-request, reservation,
  and launch-to-idle windows recorded as three start/end rows, preparation and
  cleanup excluded, an unobserved first allocation left missing), and per-round
  promotion gates.
- [request-timeline-attribution.md](request-timeline-attribution.md):
  host interval decomposition with named owners, an explicit unattributed
  remainder and separate arithmetic closure error, per-arm clock verification,
  a first-public-request or sync-point host process-to-card snapshot with the
  checkpoint marker and holder PID, start-time, and role retained, card and
  device node reconciled against the grant and holder PID with start time against
  this arm's process identity (the before-launch grant and after-cleanup check
  are endpoints only, and two snapshots cover only their sample points),
  attribution undetermined when either reconciliation or an outside holder leaves
  the window unconfirmed, equal numbers of AB and BA
  blocks reported separately by order,
  per-arm pre-packaging RGB24/PCM hashes with a fixed encoding configuration and
  a saved read-only raw-byte payload for replays whose per-arm read-back hashes
  are each checked against the saved payload hash, the rule that a candidate-owned
  excess whose direction holds under reversal only supports a targeted follow-up
  and that a causal conclusion needs a control isolating the code difference, an
  order-flipped excess written as attribution undetermined, controlled replay of
  the suspect interval with equal AB/BA interleaved units and a fixed-process
  rule covering one shared process or one resident process per arm that reports
  only the arm difference and run-position association, and
  the coverage ledger that keeps `not collected` distinct from zero.
- [same-version-noise-baseline.md](same-version-noise-baseline.md): a
  same-version control with its protocol scope kept attached (steps, input set,
  CPU affinity, diagnostics), per-start samples with the request, pair, and block
  counts and the between-start mean difference, named percentage denominators
  with version-order and run-order rows kept side by side, the absolute envelope
  and absolute difference used to judge resolution while the signed range checks
  direction, `not applicable` for a gate whose fast path was not hit (install
  counts, per-scope call counts, and a missing count kept apart) and
  `undetermined` when the path was hit but the same protocol's band covers the
  delta, the A/A magnitude as this measurement's resolution limit with stopping
  set by the pre-agreed rule, and the exit and resource boundary kept separate
  from the timing entry.
- [validation-evidence-discipline.md](validation-evidence-discipline.md):
  execution and checkpoint identity including the worker interpreter and the
  resolved import paths, a per-claim coverage ledger (process exits, resolved
  imports, counters present in the run), device probe ladder, runtime parameter
  ranges, non-reproduction
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
  first, worker self-reports kept separate, `not retained` rows,
  covered-versus-total process coverage, signal exits, grace-period force-kill
  with its warning count checked independently of missing codes, control
  comparison, resource release as a verdict separate from clean exit, and how to
  report a shutdown gap next to passing request results.
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
- [stage-scoped-residency-evidence.md](stage-scoped-residency-evidence.md):
  changing which weight groups stay resident in one stage — device selected from
  the running submodule rather than the first parameter, split-hit proof and
  fallback coverage, empty-tensor storage aliasing, stage-keyed windows that a
  later stage cannot overwrite, allocated versus reserved release after a
  failure, and stage saving versus full-request peak.
- [templates/lesson.md](templates/lesson.md): lesson entry template.

## Promotion Rule

Add a lesson only when it is:

- confirmed by evidence,
- likely to recur,
- not obvious from public docs alone,
- safe to publish after removing private context.
