# Request Timeline Attribution

## Scope

Diagnose a per-request latency regression that the engine's own stage timers do
not explain. The goal is not a better profile; it is to decide whether the
excess belongs to the candidate's production code at all, while keeping the
unexplained remainder visible.

Process and device ownership is a prerequisite: a timeline from an arm that
shared a card with a process outside the run is not attributable to either arm.
The ownership evidence for the measurement window is the host-card occupancy and
PID reconciliation taken while the first public request is executing or at a
request checkpoint the harness can synchronize with — not the before-launch or
after-cleanup endpoints. Read the timeline from that checkpoint first: when the
reconciliation cannot be made, the affected result is **attribution
undetermined**, not attributable to an arm.

- Record the grant before launch as the set the later reconciliation is checked
  against: the host physical card and the container device node for every device
  the block may use. The grant is a precondition for the window evidence, not a
  substitute for it.
- While the first public request is executing, or at a request checkpoint the
  harness can synchronize with — for example a named barrier between request
  entry and media packaging — take a host-side snapshot of every process holding
  a compared card. Map each process to its physical card and retain its host
  PID, start time, command or role, and the checkpoint marker in the private run
  record. Reconcile on two axes: the card and container device node against the
  granted set, and the holder's PID and start time against this arm's process
  identity. Matching card numbers alone does not exclude an outside process that
  happens to hold the same granted card.
- Repeat the snapshot at a second checkpoint, such as the packaging barrier or
  the end of the block. That adds one observation point, not continuous coverage:
  each snapshot proves only its own sampling instant, so a process that starts
  and exits entirely between the two points can still be missed. Before-launch
  and after-cleanup snapshots are endpoints only: they cannot show a holder that
  occupied a compared card for part of the request and then exited. That
  coverage limit stays a limitation.
- Publish only the role-level mapping; keep host PIDs and paths in the private
  run record.

If no in-request checkpoint can be synchronized, the host process-to-card
mapping cannot be confirmed for the measured window, a snapshot shows a holder
outside this arm's process identity, or either reconciliation — card and device
node against the grant, PID and start time against this arm's process identity —
lacks evidence, write **attribution undetermined** for the affected block, pair,
or failing row and keep that row.
Do not attribute the excess to either arm, and do not drop or clear the row
because its ownership was not established. The field-level host, namespace, and
device-table checks are in
[device-numbering-and-ownership.md](device-numbering-and-ownership.md); this
lesson owns the measurement-window checkpoint, the evidence to retain, and the
undetermined verdict when ownership is unconfirmed.

## Symptom

A hypothesis example, with no measured values attached: a candidate fails the
per-pair latency gate in one arm-order block and passes in the reversed block.
Stage timers inside the engine are flat while the request wall time moves.
Re-running the whole matrix produces another block that is expensive to obtain
and still does not say which part of the request carried the difference.

## Host Interval Accounting

- Decompose each measured request into **mutually exclusive host intervals with
  named owners**: request entry, input preparation and dependency resolution,
  engine serving (enqueue, stages, result delivery), response delivery, and
  media packaging or muxing. Give each interval its first and last event.
  Anything outside the instrumented spans goes into an explicit
  `unattributed` bucket; do not stretch an interval to absorb it.
- Verify the shared monotonic clock per arm and per container or namespace
  before and after the block, and keep the readings. A per-arm clock check is
  part of the timeline evidence, not setup log noise.
- Check arithmetic closure per request: the sum of intervals plus the
  unattributed remainder equals the measured wall time, and publish the closure
  error next to the remainder. Closure error near zero proves the bookkeeping;
  it does not prove the attribution is complete. Keep the two numbers as
  separate columns so a closed sum is never read as a finished explanation.
- Name an interval after the code path that owns it (engine, API input
  handling, media muxing), not after a suspected cause. An interval label such
  as "candidate overhead" pre-assigns the conclusion.
- Host intervals are not kernel or device time. A packaging span that grows
  does not prove GPU-side work changed, and a flat device interval does not
  prove the host path is unchanged; report the layer you measured.

## Media Packaging Boundary

- Hash the decoded media before packaging: the RGB24 frames and PCM samples each
  arm produced, taken per request at the point where that arm hands them to the
  shared encoder or container writer, before the shared encoding and packaging
  step begins. Collect the hash from each arm separately so a mismatch is caught
  before the encoder can obscure it. Those pre-packaging hashes are the
  correctness evidence. A container hash also covers the muxing layer, so it can
  differ while the decoded bytes are identical, and an identical container hash
  is not needed to claim media parity of the decoded output.
- Compare the two arms' per-request pre-packaging hashes and require equality
  before comparing packaging time; do not substitute one arm's hash for the
  other. For a replay, save the verified raw bytes once — one copy of the
  pre-packaging RGB24 frames and PCM samples — as a single read-only payload,
  hand that same byte payload to both arms, and have each arm independently
  re-hash the bytes it read before packaging. Each arm's read-back hash must
  match the payload hash recorded when the payload was saved; comparing the two
  read-back values only with each other is not enough, because it would accept
  both arms reading the same wrong payload. The hash identifies and verifies the
  shared payload; it does not stand in for the payload. A replay whose arms read
  different bytes describes a different input, so its packaging time is not
  comparable. Record the payload hash as saved, how it was mounted or copied
  read-only, and each arm's read-back hash checked against that saved value.
- Hold the encoding or muxing configuration fixed across arms and blocks —
  codec, quality or bitrate setting, pixel and sample format, container
  options — and record it with the comparison. A changed encoder setting makes a
  size, hash, or timing difference uninterpretable.
- Report the packaging interval's timing and the media parity verdict as separate
  statements: a pre-packaging byte match does not explain a changed packaging
  span, and a longer packaging span does not invalidate a byte match.

## Order-Reversed Blocks and Attribution

- Run each arm order as its own block with its own warmup, formal samples, and
  gate; use one container, process, and writable cache per arm. Run an equal
  number of blocks in each order, AB and BA, so each arm runs first and second
  equally often. Record every block under the order it used, and report the AB
  and BA results separately with their own counts, means, and ranges; do not
  pool the two orders into one mean. Do not pool blocks, and do not mix blocks
  that used different sample counts or event coverage. Keep every earlier block
  that failed, including one measured with a different protocol, as its own row;
  do not trim slow samples or discard a failing block because a later block
  passed.
- Keep the per-pair gate and the mean gate, and report every pair, including the
  ones that pass. A per-pair failure that the mean hides stays a failure.
- Apply the attribution rule before writing a conclusion. An excess inside the
  intervals the candidate's code owns, with the same direction under arm-order
  reversal, is **consistent with a candidate effect and supports a targeted
  follow-up**; it is not a causal conclusion. A causal conclusion needs a
  control that isolates the code difference: the same tree or build with only
  that change toggled, and inputs, thread count, CPU configuration, and
  packaging path held fixed.
- When the excess lands in packaging or API preparation and dependency
  intervals and the sign flips with the order, write **attribution
  undetermined**, keep the original failing row, and name the intervals that
  carried the excess. Do not write "not attributable to the candidate": a flip
  leaves the cause open rather than clearing or convicting either arm.
- Keep the unattributed remainder as a limitation. Do not allocate it to the
  candidate to make the accounting end at zero.
- Compare each arm with itself across the two blocks. If both arms move between
  blocks, arm order is not isolated and the difference is not a clean
  candidate-versus-baseline effect.

## Controlled Replay of the Suspect Interval

- Replace "run the matrix again" with a replay of only the interval that carried
  the excess: same public input bytes, fixed thread count and CPU or affinity
  configuration, a fixed encoding or muxing configuration, and the packaging or
  muxing step inside the measured span.
- Hand the packaging step a single verified, read-only decoded-media payload
  saved from the raw pre-packaging bytes: one retained copy of the RGB24 frames
  and PCM samples, selected after the hashes collected separately from each arm
  are checked equal. The hashes identify and verify that payload; they are not
  the payload. Have each arm independently re-hash the bytes it read before
  packaging, record that read-back hash, and check it against the payload hash
  saved with the payload — each arm's match to the saved value is what proves it
  consumed the intended input; matching only each other would accept a shared
  wrong payload. Different decoded bytes would make a packaging difference
  uninterpretable.
- Interleave the arms per request rather than run them as blocks. Execute an
  equal number of AB and BA units, and record each unit under the order it used:
  keep the AB results and the BA results as separate rows with their own counts,
  means, and ranges, and do not report a pooled mean over the two orders.
  Repeating a fixed A-then-B pattern is still AB: the version and the run
  position move together, so a single order cannot separate the code difference
  from the position.
- If the replay holds the process fixed, the reporting restriction applies to
  both arrangements: both arms served from one long-lived process, and each arm
  bound to its own resident process. Report only the arm-to-arm difference and
  whether that difference follows the run position; do not report absolute
  per-arm timings or a speedup. With one shared process the state belongs to
  neither arm alone; with one resident process per arm, each process instance
  carries its own allocator and warm state, so an absolute per-arm time mixes the
  code difference with that process state and with run position. A difference
  that follows position, or that changes sign between the AB and BA units, is a
  position association, not an arm effect; keep it as evidence about the replay
  setup and do not attribute it to either arm.
- When the suspect is API input handling, split that path into finer, still
  mutually exclusive markers (for example form or upload parsing, dependency
  and reference resolution, route entry) and replay at that granularity.
- A replay that moves the excess out of the candidate-owned interval is evidence
  about the interval, not a clearance for the candidate. If the excess does not
  reproduce in the replay, report only that it did not reproduce under those
  replay conditions: keep the original failing block and do not generalize the
  result to the original protocol, other conditions, or a candidate clearance.
- Keep the original block, the replay block, and their different protocols
  separate; if the replay changes the measurement granularity, it cannot be
  averaged with the original samples.

## Evidence Coverage

- Keep a coverage ledger per claim: how many model processes have an
  independent OS exit record, how many workers exported the import path they
  actually resolved, and which counters existed in this run.
  `not collected` is not zero.
- Do not reuse a counter from an earlier run's hook and present it as this
  run's zero-call count. If the run had no counter, the count is unmeasured.
- Request-level reconciliation (client, server, and engine identifiers, one
  terminal state per request, dropped-event count) proves the sample is the
  intended request. It does not prove the interval attribution, and it does not
  prove the candidate owns the excess.

## Public Sources

- Related public source:
  [vllm-project/vllm-omni#9468](https://github.com/vllm-project/vllm-omni/pull/9468),
  an eight-card Ascend A/B. The lesson is distilled from an internal validation
  round whose evidence is not public yet; the linked PR is related context, not
  the source of these rules, and no case-specific numbers, hosts, logs, or
  device assignments are quoted here.
- The #9468-specific public reproduction bundle is
  [cflin27/vllm-omni@4a4017db](https://github.com/cflin27/vllm-omni/tree/4a4017db17710f2ce297d5b7f4ca640c3b44e0b4),
  referenced from that PR body; its `pr9468-native/` case covers public
  image-condition 1 NFE precision. It supplies no request-timeline or packaging
  measurement, so the attribution examples in this lesson stay hypothetical.
- The shared public Ref2VA material is
  [cflin27/vllm-omni@9483ed9](https://github.com/cflin27/vllm-omni/tree/9483ed912963662b7a9d5220a0d200e2060c6761).
  Its request examples were built for #9467 and #9494, not for #9468, so it
  traces the common inputs only and is not a #9468 case source.
