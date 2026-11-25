# Shutdown and Exit Audit

## Scope

Shutdown evidence for multi-process accelerator services: an API or supervisor
process, per-stage manager processes, and per-rank workers. This lesson covers
what counts as proof that a run ended cleanly, and how to report the cases where
it did not.

## Symptom

A service answers every request correctly, the API process exits `0`, and the
run is reported as a clean exit. The shutdown log for the same run shows a
grace-period timeout and a force-kill of one stage's workers. In another
configuration one stage manager exits `-9` (killed by signal) while two other
rank groups exit `0`. The two reports disagree because they are describing
different layers of one lifecycle.

## Root Cause

Exit evidence is layered, and a lower layer's success does not imply a higher
one:

1. Request result: the API returned a successful response.
2. Supervisor return: the process that launched the service returned `0`.
3. Per-process exit: each manager and each rank exited with a numeric code.
4. Shutdown trace: grace-period timeouts, `SIGTERM`, force-kill, and `atexit`
   markers.
5. Resource release: devices, ports, and child processes are released.

A server can return success as soon as the last request completes, so its exit
code describes the serving loop, not the teardown of stage workers. A negative
exit code is a signal termination, not a crash with a normal exit status. A
grace-period timeout with a force-kill is the same ungraceful shutdown observed
in the log instead of the exit code.

The same shutdown defect can exist in the baseline. When both arms show the same
timeout and force-kill, treat it as a shared observation whose root cause is
unknown; matching symptoms alone do not show the candidate introduced it, and a
shared gap does not clear the candidate's own shutdown evidence.

The OS exit status of a process belongs to the parent that reaped it. A worker's
own status line and the API reply are separate observations, not substitutes.

## Per-Rank Capture and Unretained Rows

- Take each stage manager's and each rank's exit code from its parent. The
  launcher or supervisor that reaped the child records the OS wait status per
  process; that record is the authority. A worker's own status file, log line,
  or "exited cleanly" message is self-reported: keep it in a separate column and
  never use it as the exit code.
- Persist each wait record in the process that actually obtains the child's OS
  wait, after that wait has completed and before that reaper exits. Do not tie
  the capture deadline to the launcher or container exit: a host supervisor that
  takes over an orphan after the launcher exits first still obtains that rank's
  wait and is the reaper that must persist the record. Once that reaper is gone
  an unreaped record cannot be recovered, and the end-of-run markers a worker
  left behind are supplementary evidence, not a late exit code.
- A supervisor that re-adopts descendants, or a small reaper parent started
  before the launcher, can retain wait records for ranks the launcher did not
  reap. Decide this before launch, keep the parent alive through teardown, and
  have the actual reaper persist each wait record after it completes that wait
  and before it exits. Decide
  `not retained` per rank from whether that rank's own OS wait record was
  retained: a group record, a covered count, or a worker self-report does not
  replace a rank whose record is missing. The value is still the reaping
  parent's OS wait status, not a worker self-report.
- A task-runner success state, a container exit status, an API reply, or the
  supervisor's own return value is not a rank exit code.
- A manager killed by signal can take its children's records with it. When the
  parent has no wait record for a worker, write `not retained` in that row.
  Never infer `0` from the manager, the launcher, the worker's self-report, or
  the service.
- Report the exit table exactly as observed: which ranks returned which code,
  which manager exited by signal, and which rows are missing. Scope the
  acceptance line to that table, for example "two rank groups returned 0; the
  manager of one stage exited by signal; that stage's ranks are `not retained`;
  therefore not all ranks can be claimed to have exited cleanly".
- Quote the shutdown warning verbatim with its count, for example
  `workers still running after grace period; sending SIGTERM count=<n>`. Do not
  paraphrase it into "shutdown timed out".
- Check the warning count and the missing exit codes separately. Reconcile the
  count against the rows that have no OS record, and report both lists; a
  matching count is a consistency observation, not a recovered exit code, and a
  mismatch means the gap is not fully explained, so both the count and the
  unexplained rows stay open.
- When both arms print the same warning, judge each arm against the exit
  requirement fixed before the run, for example every manager and rank has an OS
  record and exited `0`. A shared warning does not waive that requirement for
  either arm; it is reported as a limitation of both arms.

## Next Time

- Capture per-process exit codes from the parent's wait status for the
  supervisor, each stage manager, and each rank. Do not derive child health from
  the API or supervisor return value, and do not record a worker's self-report
  as its exit code.
- Read the shutdown log for grace-period timeouts, `SIGTERM` counts, and
  force-kill lines. Keep the `atexit` or equivalent markers for the ranks whose
  numeric code was not captured, as supplementary evidence only.
- When a manager exits by signal, report the signal for the manager, then fill
  each rank's row from that rank's own retained OS wait record. Do not infer
  from the manager's signal that its child ranks have no reliable numeric code:
  a supervisor or reaper parent can still hold their records, so write
  `not retained` only for the ranks whose own record is missing.
- Compare shutdown behavior across arms in the same environment before assigning
  the failure. Report a shared shutdown problem as a limitation of both arms.
- Keep the claim scoped to the configuration observed. A single-stage smoke whose
  workers all exit `0` does not certify a staged service, and a staged service
  whose ranks of one stage were killed is not "all ranks exited normally".
- Write the shutdown result in the acceptance section next to the passing
  numbers, so a graceful-shutdown gap is not hidden under a successful
  performance table.
- Keep the raw shutdown logs and the PID/exit audit with the private run
  evidence; publish only the summarized exit audit.
- Judge clean exit and resource release separately: a cleanup step can remove
  containers, free ports, and return devices to idle while a rank exited by
  signal or has no record. Report both verdicts on separate lines, and never let
  a successful resource release stand in for a clean exit.

## Public Sources

- [vllm-project/vllm-omni#9467](https://github.com/vllm-project/vllm-omni/pull/9467):
  its public deterministic request check is a generic single-stage 1 NFE
  request: the two arms produced byte-identical outputs, while termination
  emitted finalizer errors after the last successful request and native clean
  shutdown was not established. A staged service's native shutdown remains
  unverified in that material. The public page does not publish per-process exit
  codes, so cite it only as a case where request success and a complete shutdown
  are separate claims, not as a per-rank exit table. Public request inputs and
  examples:
  [cflin27/vllm-omni@9483ed9](https://github.com/cflin27/vllm-omni/tree/9483ed912963662b7a9d5220a0d200e2060c6761).
- [cflin27 comment on vllm-project/vllm-omni#9494, 2026-10-28](https://github.com/vllm-project/vllm-omni/pull/9494#issuecomment-6459234160):
  eight-NPU A/B runs produced outputs but failed native worker teardown, with the
  underlying cause unproven; the comment therefore does not show a PR regression
  or a clean baseline.
