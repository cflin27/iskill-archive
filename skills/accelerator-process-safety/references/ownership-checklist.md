# Ownership Checklist

## Before Launch

- Intended devices by role:
- Host physical cards:
- Device nodes the container presents, and their node-to-mount mapping:
- Effective access policy and its source (devices cgroup allow/deny list, file
  permissions, platform equivalent):
- Devices the run can actually open; effective access scope confirmed (yes/no):
- Index accepted by the installed runtime's visibility selector:
- Framework index after masking:
- Host physical card for each selector and framework index:
- Retained host enumeration verified on this stack (yes/no/not used):
- Stage-to-card mapping and its source (native log, deployment file):
- Interpreter path that will launch the workers:
- Intended ports:
- Output/state directory:
- Existing device users, with the host process that holds each card:
- Existing port listeners:
- Reason resource is safe to use:

If the effective access scope or the selector-to-host mapping cannot be
confirmed, the launch pre-check fails. Do not run device probes and do not
record the resource as safe to use.

## Before Cleanup

- PID and process group:
- Parent process and session:
- Command line:
- Working directory:
- Start time:
- Physical card each process holds, verified from the host:
- Open device files:
- Output/log/state files:
- Why this belongs to the current task:
- Protected-process exclusions checked:

## After Cleanup

- Process group stopped or exited:
- Zombie status handled:
- Ports released:
- Per-card occupancy and idle baseline (HBM and power) rechecked:
- Devices released:
- State files retained or removed with reason:
