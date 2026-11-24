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

Check port availability and device ownership before running probes on the exact
device group intended for the run. Stop at the first failed rung.

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

## Rung 6: Agile A/B

- Base and candidate share the same public environment.
- Only the tested switch or diff changes.
- Timing and behavior move in the expected direction on a small public case.

## Rung 7: Formal Evidence

- Profiler-disabled repeated timing is collected.
- Warmup, formal timing, and method tracing are separate runs; host parallelism
  is fixed across arms.
- Per-round results and pooled statistics are both reported, and the regression
  gate is applied per round.
- Correctness or media equivalence is checked.
- Independent profile is collected only after timing warrants it.
- The report states limitations and non-promoted findings plainly. A failure
  that does not reproduce under the chosen configuration is "not observed", not
  "fixed".

## Rung 8: Exit and Resource Release

- Launcher, each stage manager, and each rank have recorded exit codes.
- A negative code or a grace-period force-kill log is reported as an ungraceful
  shutdown, not smoothed over by a successful API or launcher exit.
- The control's shutdown trace is compared before the failure is assigned to the
  candidate.
- Task ports, child processes, and devices are back at their idle baseline.
- The acceptance result scopes the clean exits to the configuration actually
  observed; a single-stage smoke does not certify a staged service.
