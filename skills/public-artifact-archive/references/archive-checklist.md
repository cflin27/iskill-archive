# Public Archive Checklist

## Required

- README explains the public purpose and conclusion.
- Manifest indexes all public files.
- Config records public source, model/workload, input, and runtime identity.
- Reproduce notes distinguish executed commands from templates.
- Validation summary states timing, correctness, profile, and limitations.
- Code index links to public commits, PRs, or source files.
- Local artifacts are listed separately and not committed.

## Safety Scan

- No credentials or tokens.
- No private hostnames or absolute private paths.
- No private prompts, datasets, media, or checkpoints.
- No raw logs with full environment dumps.
- No unpublished source patches.

## Consistency

- Units are explicit.
- Warmup, formal timing, profile, and correctness modes are separated.
- Missing evidence is marked as not run or unavailable.
- Links and relative paths resolve.
