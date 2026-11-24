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

- [ ] Each stage manager's exit code recorded.
- [ ] Each rank or worker's exit code recorded.
- [ ] Where a worker exited by signal (negative code), the signal and the
      preceding log lines are recorded.
- [ ] Where no reliable numeric code exists for a child, that gap is written down
      explicitly.

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
- [ ] A gap shared with the control is labelled pre-existing, and the gap is
      still listed as unresolved.
- [ ] Clean exits observed in a different configuration (for example a
      single-stage smoke) are not used as evidence for this configuration.
