---
name: accelerator-process-safety
description: Audit accelerator device, port, and process ownership before launching, reusing, or stopping workloads. Use when a task may occupy GPUs/NPUs, start a service, clean up a failed run, inspect a busy device group, or decide whether a process belongs to the current experiment.
---

# Accelerator Process Safety

## Overview

Use this skill to avoid corrupting shared accelerator environments. The core
rule is simple: prove ownership before acting, and prefer stopping early over
touching an unrelated workload.

## Source

Source basis: public-safe workflow distillation from shared accelerator
experiment practice. Do not encode internal daemon names, private user paths, or
cluster-specific policies in this skill. Put site-specific protected processes
in the consuming repository's own `AGENTS.md`.

## Launch Gate

Before starting a workload:

1. Record the intended device group, ports, output directory, and service name.
2. Check device occupancy with the platform's supported tools.
3. Check listening ports and identify existing owners.
4. Confirm that any reusable service has the expected model/workload identity.
5. If ownership is unclear, choose another verified-free resource or stop.

Do not launch a baseline and candidate on the same physical device group at the
same time unless the experiment explicitly requires and records that layout.

## Ownership Evidence

Use multiple signals before stopping or reusing a process:

- PID, parent PID, process group, and session.
- Command line and working directory.
- Start time, output/log directory, lock file, or state file.
- Open accelerator device files.
- Listening port and bound address.
- Service metadata endpoint, when available.

One signal is rarely enough. A stale PID file, zombie process, or reused port
can mislead cleanup logic.

## Cleanup Rules

- Stop only process groups created by the current run or proven to belong to the
  current workspace/task.
- Exclude protected services described by the local repository policy.
- Treat zombie processes as already exited; do not report them as live work.
- Do not delete locks, state, traces, or cache directories unless they are tied
  to the current run and no writer remains.
- After cleanup, verify that ports, devices, and child processes were released.

## Shutdown Audit

A successful request and an exit-0 launcher do not prove that the workers shut
down cleanly. After stopping any multi-process service:

- Record the exit code of the launcher, each stage manager, and each rank.
- Read a negative code as a signal termination, and a grace-period timeout plus
  force-kill log as the same ungraceful condition seen in another layer.
- Keep `atexit` or equivalent end-of-run markers for ranks whose numeric code was
  not captured, and state that the numeric code is missing instead of implying a
  clean exit.
- Report the configuration the clean exit covers. A single-stage smoke does not
  certify a staged service.
- If the control shows the same shutdown behavior, report it as shared and still
  leave the unresolved shutdown gap in the acceptance result.
- Verify resource release after the stop: no listener on the task ports, no
  remaining task child processes, and the devices at their idle baseline.

## References

- Use [ownership-checklist.md](references/ownership-checklist.md) before any
  cleanup or reuse decision.
- Use [shutdown-audit.md](references/shutdown-audit.md) to collect exit and
  resource-release evidence after a stop.
