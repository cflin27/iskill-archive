# Experiment Methodology Lessons

Short public-safe lessons for performance experiments. For evidence identity,
device probes, and failure triage, see
[validation-evidence-discipline.md](validation-evidence-discipline.md).

## Cache

- Separate cold-cache, warm-cache, and repeated-input results.
- Do not reuse the same content for warmup and formal measurement unless the
  benchmark explicitly targets cache hits.

## Cold Requests Versus Steady State

- Record the first request after each process start separately from the measured
  repeats. Keep its value, and the arm order of the startup it came from.
- A single cold request per arm cannot establish a regression, and it cannot be
  explained away either. When both blocks start the candidate first, startup
  order, page cache, and first-time offload or reload remain confounded.
- Decide causality with independent startups, repeated cold samples, and both
  execution orders. Until that exists, report the cold difference as an open
  limitation, not as a source-level regression.
- Do not let the steady-state mean absorb a slow cold request, and do not quote a
  steady-state improvement as a cold-start improvement. They answer different
  questions.

## Order-Confounded Cells and Independent Blocks

- A fixed arm order inside a matrix (candidate always second) leaves every cell
  ambiguous: warmup state, page cache, allocator growth, background load, and
  thermal drift all follow order. Name arm order as one possible contributing
  factor, not as the cause; a single regressed cell is order-confounded, not yet
  a proven regression.
- When one cell regresses, rerun that cell alone in a separate block with the
  arm order reversed. Give the block its own warmup, samples, and gate
  decision; do not merge, pool, or average it with the original matrix.
- Report the original regression row unchanged even when the new block is
  inside the gate. Say the effect did not reproduce under the reversed order and
  that causality remains undetermined. A non-reproduction does not show that
  order caused the original cell, and it does not show the candidate is free of
  a regression; do not upgrade it to "no regression".
- Reversal changes arm order together with every other factor that follows arm
  position, so one reversed block cannot separate order from those factors.
  Unless the other factors are controlled independently, keep order as a
  possible factor and keep the causal question open.
- Compare each arm with itself across blocks before attributing a difference to
  order. If the baseline mean and range hold in both blocks while the candidate
  mean moves between them, arm order alone does not explain the difference.
  Keep causality undetermined, name the arm that moved, and do not promote the
  difference to a source regression or close it as a no-regression result.
- Fix the decision rule before running: which block decides promotion, which
  threshold applies, and how many blocks are allowed. Rerunning a cell until one
  block passes is block selection, not evidence. Report every block that ran.
- Keep input, seed, parameters, and warmup count identical between the blocks;
  only arm order should differ. If anything else changed it is a new
  experiment, not an order control. Record the arm isolation as well: one shared
  service start or container (and which arm ran first), or one container,
  process, and cache per arm. A shared startup carries page-cache, compile, and
  allocator state from the first arm to the second.
- Apply the same per-round gate to the order-swapped block. Passing it shows the
  original cell did not reproduce under that order; it does not show the
  candidate is faster, and it does not resolve what produced the original cell.

## Request Timeline Attribution

- When a per-request gate fails while the engine's stage timers are flat,
  decompose the request wall time into mutually exclusive host intervals with
  named owners, keep an explicit unattributed remainder, and report the
  arithmetic closure error separately. Closure proves the bookkeeping, not the
  completeness of the explanation.
- Run an equal number of blocks in each arm order, AB and BA, so each arm runs
  first and second equally often. Report the two orders separately with their
  own counts, means, and ranges; do not pool them into one mean. An excess inside
  candidate-owned intervals with the same direction under order reversal supports
  a targeted follow-up, not a causal conclusion; a causal conclusion needs a
  control that isolates the code difference. When the excess lies in packaging or
  API preparation intervals and flips with arm order, write attribution
  undetermined, name the intervals that carried it, and keep the original
  failing row.
- Reconcile cards and processes at a sync point inside the measured window: take
  the host process-to-card snapshot during the first public request, or at a
  named barrier between the request and its packaging, and retain the checkpoint
  marker with each holder's PID, start time, and role in the private record.
  Reconcile the card and container device node against the grant, and the holder
  PID and start time against this arm's process identity; a matching card number
  alone does not exclude an outside holder. The before-launch grant and the
  after-cleanup check are endpoints only and do not replace that in-window
  evidence; record the grant only as the set the reconciliation is checked
  against. Two snapshots prove only their sample points, so a short-lived process
  between them may still be missed. If the in-request checkpoint, a reconciliation
  axis, or the PID mapping cannot be confirmed, or a snapshot shows an outside
  holder, record attribution undetermined for the affected row instead of
  assigning the excess to an arm.
- Replace a full matrix rerun with a controlled replay of the suspect interval:
  same public input bytes, fixed thread and CPU configuration, fixed encoding or
  muxing configuration, an equal number of AB and BA interleaved units recorded
  separately by order, and packaging inside the measured span. Collect each
  arm's pre-packaging RGB24/PCM hash per request before the shared encoding and
  packaging step, require the two arms' hashes to match, then save the verified
  raw bytes once as a single read-only payload, hand that byte payload to both
  arms, and have each arm independently re-hash what it read and match its
  read-back hash against the payload hash recorded when it was saved; matching
  the two arms only with each other would accept a shared wrong payload. The
  hash verifies the shared payload rather than replacing it. A fixed A-then-B
  repetition is
  still AB and moves the version together with the run position. When the process
  is held fixed — one process serving both arms, or each arm bound to its own
  resident process — report only the arm-to-arm difference and its association
  with run position, not absolute per-arm timings. Split the suspect path into
  finer mutually exclusive markers only where the replay needs it, and do not
  average the replay with the original samples. If the excess does not reproduce,
  limit the statement to those replay conditions.
- Keep the coverage ledger next to the result: which processes have an
  independent OS exit record, which workers exported their resolved import path,
  which cards had a process-to-card snapshot inside the measured window, and
  which counters existed in this run. `not collected` is not zero.
- See [request-timeline-attribution.md](request-timeline-attribution.md).

## Component-Level A/B

- Run the component comparison in both execution orders and report the blocks
  separately instead of pooling them.
- Record the actual work the component performs per arm (for example how many
  times each stage loads) and the peak allocator usage. The counts show the
  mechanism; they do not turn component timing into full-request latency.
- Keep per-round samples, warmup, output parity, and an independent process exit
  record for the component run. Component parity is evidence for that stage only.

## Allocator Peak Scope

- A peak is a scope, not a number. Record, per runner, where statistics are
  reset, where the framework or a deferred library may reset a nested counter
  inside that scope, where the peak is read, and whether the window adds a
  synchronization. Compare only numbers collected over the same boundary.
- Every execution branch that allocates must sit inside some collection window;
  an uncovered branch makes the reported peak a lower bound. State which
  branches and which runners the number covers.
- Aggregate explicitly. One common rule is the maximum across the calls inside
  one request per card, then the mean of those per-request peaks over the formal
  requests. State whether the published value is a single peak, a per-request
  peak averaged across requests, or a mean of samples.
- Report allocated and reserved separately. The allocator peak is not
  necessarily device HBM usage, and it excludes initialization unless the window
  covers it; label which of those the number is.
- A component-level peak, a full-request peak, and a fixed offload residue are
  three observations. A component result does not replace the full-request
  number, and a residue that persists after an operation is a separate defect
  from a peak shift during it.
- Export tensors, latents, or arrays in warmup or in a separate validation
  request, not inside the timed formal requests. If the formal run did not
  export them, say the parity claim covers the warmup request only.

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

## Native Output Alignment

- Read the pipeline's output contract before predicting a response shape. A
  request in seconds at a fixed frame rate can be rounded up to the model's
  native frame alignment (for example a `17n+5` boundary), so the returned frame
  count and duration legitimately differ from `duration * fps`. Do not report
  the difference as dropped or extra frames.
- Record the requested duration and frame rate, the aligned frame count, the
  output frame rate and duration, and the generated latent's temporal extent.
  Check that the latent extent is consistent with the aligned frame count, and
  compare outputs at the same aligned index across arms.
- Keep decoded metrics and container hashes separate: byte-identical containers
  imply identical decoded bytes, while equal decoded metrics do not imply
  identical containers, because encoding and packaging can still differ.
- A warmup request and a formal request with the same seed can still differ
  slightly in rendering. When both arms show the same warmup-versus-formal
  difference, treat it as a shared observation with an unknown cause, not as a
  candidate regression, and do not use warmup latent equality to claim formal
  latent equality.

## Measurement Layers

- Host-side call interval, kernel/device time, and end-to-end wall time are three
  different quantities. A wider call interval can coexist with unchanged kernel
  time and unchanged request latency when the extra time overlaps another call.
- Report the stage, the call interval, and the full request separately. Only the
  full request supports a user-facing speedup claim.
- Before calling an async change promoted, show the overlap as the intersection
  of producer and consumer intervals inside one request, and show that it
  shortens a critical-path interval. Total overlapped duration is not a saving.
- A wider host call interval is diagnostic, not evidence of a CPU kernel
  regression. Check kernel time before reporting one.

## Timing Hygiene

- Separate warmup, formal timing, method tracing, and any tensor or media export
  into distinct runs. Never mix trace overhead into formal samples, and never
  fold export I/O into them.
- Name which block produced the timing samples and which produced the parity
  artifacts. An export phase that follows the timed requests does not repair a
  sample that already includes it; keep the two blocks separate.
- Fix host-side parallelism (thread count, affinity) across arms when timing a
  CPU-side stage; otherwise the arms measure different machines.
- Warm up each version independently before its measured repeats.
- Keep tail samples. Report the sample range and count as well as the mean so
  slow-tail behavior stays visible.
- Percentiles from a handful of samples are interpolations of the same data, not
  stable tail estimates. Use them to screen, not to settle a marginal gate.

## Same-Version Noise Baseline

- A same-version control measures what a protocol produces with the code held
  fixed. Keep the entry's protocol scope (generation steps, input set, CPU
  affinity, attached diagnostics) attached, and take a new control when the
  protocol changes instead of importing the old band.
- Name every percentage's denominator, and keep version-order and run-order
  percentages side by side. A magnitude envelope is not a signed range, so a
  smaller historical difference does not mean the same direction reproduced.
- Keep the two no-verdict outcomes apart. Write `not applicable` only when the
  run did not hit the gated fast path; write `undetermined` when the path was hit
  but the delta is inside the same protocol's band, so the protocol cannot
  resolve the effect. Neither is a pass or a fail, and neither supports a speed
  claim. Support a miss with the evidence kind it actually has: an install count
  of `0` is a registration fact, a measured `0` call count covers only the scope
  and request shape observed, and a call count never collected stays
  `not measured` instead of becoming a zero or a miss.
- The measured A/A magnitude describes this measurement's resolution limit only.
  Stop sampling when the rule agreed before the run is met, record that rule and
  its trigger, and change the measurement rather than adding runs that cannot
  resolve the effect. See
  [same-version-noise-baseline.md](same-version-noise-baseline.md).

## Device Time and Retained Capacity

- A device-time figure means nothing without its window, its clock, and its
  device count. Three common figures measure different things and cannot
  replace one another:
  - a lower bound of retained capacity — the device time actually held by
    completed formal requests. Identify each physical card with an anonymous
    but stable label that stays fixed across the groups being merged, for
    example an ordinal from one retained host enumeration. Take the union of
    the evidenced intervals card by card, sum the per-card seconds, and divide
    by 3600 for card hours. Count an overlap once on the shared card instead of
    adding group products. It is a floor over completed formal requests with
    occupancy evidence, not a claim that every device core was busy throughout
    the run;
  - a reservation window — from the acknowledgement that the devices are
    assigned after warmup to the return of the last formal request. It may
    include gaps between requests. Compare it with the floor only under the
    containment and device-set rule below;
  - a launch-to-idle window — from this arm's launch to the check that every
    card this arm used is idle again. It includes CPU setup, probing, load,
    warmup, and cleanup, so it bounds device context from outside instead of
    measuring device busy time.
- Recompute the floor from per-card rows before reporting it: the card label,
  each interval's start and end, the clock domain, the evidence reference, and
  the union length per card, plus the device set, the summed product, and what
  the figure excludes. A per-group product is a shortcut only when every merged
  interval has the same device membership and no card is shared with a group
  whose interval overlaps; state that condition when using it. Otherwise the
  group product double-counts a shared card, and merging the time before
  multiplying by the union of the members counts a card that was not held for
  the merged span. Two groups, `{A,B} × [0,10)` and `{B,C} × [5,15)` in
  seconds, hold A for 10, B for 15, and C for 10 — 35 card-seconds; adding the
  group products gives 40 and the merged-time product gives 45, so both
  shortcuts are wrong here.
- An interval enters the floor only when occupancy of the card is evidenced
  across the whole interval, by an exclusive lease that covers it, a gap-free
  allocation and release event record, or evidence of equal strength that
  excludes a release or transfer inside it. Request start and end records
  bracketed by two holder records are two sample points, not continuous
  holding: the same holder can release and reacquire the card between them, and
  finite-rate sampling proves only its sample points. A report that took its
  holding from discrete checkpoints keeps that coverage limit when its formal
  request intervals are used. An interval with a gap in the evidence, or whose
  holding is only assumed, stays out of the floor and is listed as excluded or
  `not measured`; it does not become a zero. Failed preparation rounds,
  CPU-only regression, probes, model load, warmup, and cleanup do not belong in
  the formal floor either; list them as excluded instead of dropping them
  silently.
- Derive each interval's length from its start and end on the same comparable
  clock, and compute the window the same way. Do not subtract a wall-clock end
  from a monotonic start, mix clocks across hosts or arms, or rebuild a
  duration from endpoints that belong to different domains; if only such
  endpoints exist, report the duration as unavailable instead of
  reconstructing it.
- Merge a shared card's intervals on one comparable timeline. With a verified
  mapping and bounded endpoint error, count only the guaranteed inner interval
  from the latest possible start to the earliest possible end. If the end is
  at or before the start, the mapping establishes no positive span to count.
  Retain the original endpoints, mapped endpoints, and error bounds. For
  example, a nominal mapped interval of `[5,15)` with an offset error of ±1 s
  contributes `[6,14)`. Its union with a known `[0,10)` is 14 s of guaranteed
  coverage.
- Per-arm monotonic durations that each start at zero can be computed separately.
  Sum those durations for a shared card only if independent evidence proves
  the relevant intervals were disjoint, for example a recorded release before
  reacquisition. Launch order alone is audit information and overlap remains
  possible. If neither a verified mapping nor proof of disjointness supports
  the merge, mark the cross-domain union duration `unavailable`. Keep the
  per-domain records and state the coverage of any partial floor reported.
- Report wall-clock timestamps separately as audit time, for correlating with
  external schedules or other systems' records, and keep them out of the
  retained-capacity arithmetic.
- Record each arm's windows in the table with the event and timestamp at each
  endpoint, the clock domain for each endpoint, and the device set. Keep the
  per-card interval records for the formal-request row and the per-card idle
  checks for the launch-to-idle row.

  | Window | Start event and timestamp | End event and timestamp | Clock domains (start / end) | Device set | Duration or status |
  | --- | --- | --- | --- | --- | --- |
  | Formal-request lower bound | Start of each formal interval with verified holding | End of each such interval | | | |
  | Reservation | Post-warmup ownership acknowledgement | Last formal request returns | | | |
  | Launch-to-idle | This arm launches | Idle verification has completed for every card used by this arm | | | |
  | Audit boundaries | First verified hold per card | Confirmed release per card | | | Audit only |

  Mark a window `unavailable` if a required endpoint is missing or its
  endpoints cannot be compared. Retain any verified partial coverage and its
  scope. Use the first verified hold and confirmed release only as audit
  boundaries. Record a missing actual allocation timestamp as missing.
- Compare reservation card-hours with the formal lower bound only when the
  reservation window is proven on a comparable timeline to fully contain every
  formal-request interval counted in the floor and both cover the same device
  set. With both conditions met, reservation card-hours equal the floor or
  exceed it if the reservation covers additional time. If either condition
  fails or is unknown, report that coverage verdict alongside the figures.
- A lower bound is a floor: do not quote it as total usage, as the cost of the
  change, or as evidence that the devices saturated.

## Promotion Gates

- Apply the regression gate per round and per metric, not only to the arithmetic
  mean across rounds.
- Report pooled-sample statistics separately from per-round statistics; pooling
  can hide a single-round regression.
- State before the run which metrics feed the gate and which are diagnostic, so
  a favorable metric cannot be chosen after the fact.
- A regression recorded in one block is never deleted by a later block. Report
  every block, mark whether the effect reproduced, and keep the promotion
  decision in one place that names the evidence it used.

## Public Sources

- The allocator-peak-scope entry is supported by the public component record for
  [vllm-project/vllm-omni#9467](https://github.com/vllm-project/vllm-omni/pull/9467),
  whose frozen input package
  ([cflin27/vllm-omni@9483ed9](https://github.com/cflin27/vllm-omni/tree/9483ed912963662b7a9d5220a0d200e2060c6761))
  reports per-trial peak allocated bytes for an isolated six-image encoder
  component run. That scope supports the component-versus-full-request
  distinction; it does not supply a full-pipeline peak.
- The native-output-alignment entry is general pipeline-contract guidance. The
  cited public pages do not publish aligned frame counts or latent extents, so
  the entry is not presented as a per-case finding from them.
- No private paths, hosts, logs, or device assignments are included.
