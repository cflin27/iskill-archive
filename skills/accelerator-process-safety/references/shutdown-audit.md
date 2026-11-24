# Shutdown Audit Checklist

Use after stopping a multi-process accelerator service, before writing the
acceptance result. Record the layers separately; do not collapse them into one
"exit 0" line.

## Layer 1: Request Result

- [ ] The final valid request completed and its output is decodable.
- [ ] Any expected-rejection request was rejected as documented and a later valid
      request still succeeded.

This layer says the serving path worked. It says nothing about teardown.

## Layer 2: Launcher or Supervisor

- [ ] Exit code and signal of the process that launched the service recorded.
- [ ] If it returned `0` while shutdown logs show force-kill, do not report a
      clean exit.

## Layer 3: Per-Process Exit

- [ ] Each stage manager's exit code recorded from the parent or supervisor that
      reaped it.
- [ ] Each rank or worker's exit code recorded from its parent's OS wait status.
- [ ] Worker self-reported status (status file, log line, "exited cleanly"
      message) kept on a separate line and not used as the exit code.
- [ ] Where a worker exited by signal (negative code), the signal and the
      preceding log lines are recorded.
- [ ] Where the parent has no reliable OS record for a child, that gap is written
      down explicitly as `not retained`, never filled in from the manager,
      launcher, worker self-report, or task-runner state.
- [ ] The grace-period warning is quoted verbatim with its count, and the count
      is reconciled against the set of ranks with no OS record as a separate
      check. A matching count does not recover a missing code; a mismatch leaves
      both the count and the rows open.

## Layer 4: Shutdown Trace

- [ ] Grace-period timeout, `SIGTERM`, and force-kill lines extracted from the log.
- [ ] `atexit` or equivalent end-of-run markers kept for the stages that have
      them.
- [ ] The same trace captured for the control arm in the same environment.

## Layer 5: Resource Release

- [ ] No task process remains on the devices.
- [ ] Task ports are released.
- [ ] Devices are back at the idle baseline, and any residual task container is
      removed.

## Reporting

- [ ] The acceptance result states which stages exited cleanly and which did not.
- [ ] The acceptance line lists the ranks with an OS record of `0` and the rows
      marked `not retained`; it never claims that every rank exited cleanly, and
      worker self-reports are not counted as exits.
- [ ] A gap shared with the control is labelled a shared observation with root
      cause unknown, and each arm is judged against the exit requirement fixed
      before the run; a shared warning does not waive that requirement for
      either arm, and the gap stays listed as unresolved.
- [ ] Clean exits observed in a different configuration (for example a
      single-stage smoke) are not used as evidence for this configuration.
