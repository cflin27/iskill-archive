# Public Omni Validation Ladder

Use the lowest sufficient rung. Do not promote a change only because an earlier
rung passed.

## Rung 1: Source Audit

- Latest upstream main checked.
- Pending PRs or equivalent implementations checked.
- Base commit recorded.
- Candidate diff contains only the intended public feature or fix.
- Model hierarchy and checkpoint identity recorded: the class the loader
  resolves, the checkpoint revision or hash, and the expected shard count.

## Rung 2: Import and Construction

- Public environment and package paths recorded.
- Target service classes import successfully.
- Abstract methods and constructor requirements are satisfied.
- Mock or no-device construction passes where the project supports it.

## Rung 3: Device Probes

Check port availability, device access authorization, and device ownership
before running probes on the exact device group intended for the run. Stop at
the first failed rung.

- The device nodes the container presents and the effective access policy are
  recorded, and the run can open only the intended nodes. If the effective
  access scope cannot be confirmed, this rung fails and no probe runs; a
  successful allocation or a matching visible count is not authorization.
- The numbering is resolved in separate steps, not one combined check: map each
  container device node to its host physical card, then record the index the
  installed runtime's visibility selector accepts and the framework index after
  masking, and map each of those to a host card. The index the installed
  selector accepts is the authoritative one for launch, and host numbering may
  be reused only after the mapping is verified on that implementation. The
  visible count alone is not ownership evidence.
- Ownership is verified from the host before any probe: snapshot the processes
  that hold each intended card, map every process to its physical card, and
  reconcile those holders against the granted set. An intended card held by a
  process not registered for the run, or an ownership state that cannot be
  confirmed, fails this rung and no probe runs. This before-probe check does not
  replace the recheck immediately before service startup.
- Device enumeration and context creation.
- Real tensor operation followed by synchronization.
- Cross-device collective with a checked result value.
- The collective the target model path actually uses. A passing all-reduce does
  not prove a different all-gather or all-to-all path.

## Rung 4: Service Health

- Port availability and device ownership are rechecked immediately before
  service startup.
- Service starts from the isolated public checkout with the intended launch
  arguments.
- `/health` and model listing match the expected public model identity.
- Timeout and resource parameters are within the range the runtime library
  accepts; the first rejection and the corrected command are recorded.

## Rung 5: Public Request

- Public input request returns successfully.
- Output is decodable or parseable with independent tools.
- Model identity and request configuration are recorded.
- The output shape is recorded: requested duration and frame rate, aligned frame
  count, output frame rate and duration, and the generated latent's temporal
  extent, with the native alignment rule that explains any difference from
  `duration * fps`.
- The raw generated tensor is exported with its original dtype and shape; a
  converted convenience copy is a derived artifact, not the raw tensor.
- Request index and reported request ID pair the arms; a content-hash set is not
  a pairing key.
- The raw container and any re-encoded display copy are recorded separately, and
  decoded metrics are computed from the raw output.

## Rung 6: Agile A/B

- Base and candidate share the same public environment.
- Only the tested switch or diff changes.
- Timing and behavior move in the expected direction on a small public case.
- For a capability-gated path, record per arm the raw device query string, the
  gate decision, the install count, and the fast-path call count per scope. Keep
  one row for the intended device and one per excluded device family, and report
  them separately. Zero installs and zero calls show only that the gate selected
  the fallback; accept the fallback only with baseline output parity and a clean
  install side-effect check. Until both exist that row stays `fallback
  selected`. `not covered` means the device was not run at all; a missing
  fallback check does not turn the intended-device row into `not covered`.

## Rung 7: Formal Evidence

- Profiler-disabled repeated timing is collected.
- Warmup, formal timing, and method tracing are separate runs; host parallelism
  is fixed across arms.
- Per-round results and pooled statistics are both reported, and the regression
  gate is applied per round.
- Correctness or media equivalence is checked.
- Allocator peaks are reported with the per-runner collection boundary (reset,
  nested reset, read, added synchronization), the branches covered, the
  aggregation rule, and the allocated/reserved distinction. A component peak
  does not replace the full-request peak, and neither is a fixed offload
  residue.
- Parity evidence states whether it came from warmup exports or formal outputs;
  warmup-exported arrays certify the warmup request only.
- Tensor or media export is a separate block from formal timing; the report names
  which block supplied the parity artifacts and which supplied the timing
  samples.
- Independent profile is collected only after timing warrants it.
- The report states limitations and non-promoted findings plainly. A failure
  that does not reproduce under the chosen configuration is "not observed", not
  "fixed".
- Every timing and correctness number is reported with the device family it came
  from. Do not carry a fast-path hit or a fallback verdict across device
  families or runtime versions.

## Rung 8: Exit and Resource Release

- Launcher, each stage manager, and each rank have recorded OS exit codes taken
  from the parent or supervisor wait record; a worker's self-reported status is
  kept separately and is not an exit code.
- A rank whose code was never captured is marked `not retained`, and the
  grace-period warning is quoted with its count and reconciled against those
  rows as a separate check; a matching count does not replace the missing code.
- The actual reaper persists each wait record before it exits, and `not retained`
  is decided per rank from whether that rank's own record was retained; a group
  record or a covered count does not stand in for a missing rank row.
- A negative code or a grace-period force-kill log is reported as an ungraceful
  shutdown, not smoothed over by a successful API or launcher exit.
- A shared shutdown warning is judged against the exit requirement fixed before
  the run; it does not waive that requirement for either arm.
- The control's shutdown trace is compared before the failure is assigned to the
  candidate.
- Task ports, child processes, and devices are back at their idle baseline.
- Resource release is a separate verdict from clean exit: a successful cleanup
  is not an exit record for any rank.
- The acceptance result scopes the clean exits to the configuration actually
  observed; a single-stage smoke does not certify a staged service.
