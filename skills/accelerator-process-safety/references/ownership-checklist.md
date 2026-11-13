# Ownership Checklist

## Before Launch

- Intended devices:
- Intended ports:
- Output/state directory:
- Existing device users:
- Existing port listeners:
- Reason resource is safe to use:

## Before Cleanup

- PID and process group:
- Parent process and session:
- Command line:
- Working directory:
- Start time:
- Open device files:
- Output/log/state files:
- Why this belongs to the current task:
- Protected-process exclusions checked:

## After Cleanup

- Process group stopped or exited:
- Zombie status handled:
- Ports released:
- Devices released:
- State files retained or removed with reason:
