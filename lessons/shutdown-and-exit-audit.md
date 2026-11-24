# Shutdown and Exit Audit

## Scope

Shutdown evidence for multi-process accelerator services: an API or supervisor
process, per-stage manager processes, and per-rank workers. This lesson covers
what counts as proof that a run ended cleanly, and how to report the cases where
it did not.

## Symptom

A service answers every request correctly, the API process exits `0`, and the
run is reported as a clean exit. The shutdown log for the same run shows a
grace-period timeout and a force-kill of the encoder workers. In another
configuration the stage manager exits `-9` (killed by signal) while the diffusion
and decoder ranks exit `0`. The two reports disagree because they are describing
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
timeout and force-kill, treat it as likely pre-existing; matching symptoms alone
do not show the candidate introduced it, and a shared gap does not clear the
candidate's own shutdown evidence.

## Next Time

- Capture per-process exit codes for the supervisor, each stage manager, and each
  rank. Do not derive child health from the API or supervisor return value.
- Read the shutdown log for grace-period timeouts, `SIGTERM` counts, and
  force-kill lines. Keep the `atexit` or equivalent markers for the ranks whose
  numeric code was not captured.
- When a manager is killed, say that the manager exited by signal and that the
  child ranks do not have a reliable numeric code, instead of quietly reporting
  the missing layer.
- Compare shutdown behavior across arms in the same environment before assigning
  the failure. Report a shared shutdown problem as a limitation of both arms.
- Keep the claim scoped to the configuration observed. A single-stage smoke whose
  workers all exit `0` does not certify a staged service, and a staged service
  whose encoder ranks were killed is not "all ranks exited normally".
- Write the shutdown result in the acceptance section next to the passing
  numbers, so a graceful-shutdown gap is not hidden under a successful
  performance table.
- Keep the raw shutdown logs and the PID/exit audit with the private run
  evidence; publish only the summarized exit audit.

## Public Sources

- [cflin27 comment on vllm-project/vllm-omni#9494, 2026-10-28](https://github.com/vllm-project/vllm-omni/pull/9494#issuecomment-6459234160):
  eight-NPU A/B runs produced outputs but failed native worker teardown, with the
  underlying cause unproven; the comment therefore does not show a PR regression
  or a clean baseline.
