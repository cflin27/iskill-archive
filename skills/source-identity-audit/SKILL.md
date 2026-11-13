---
name: source-identity-audit
description: Verify code, import, wheel, and vendored source identity before trusting results or publishing claims. Use when comparing baseline and candidate runs, working from expanded source snapshots, editable installs, overlays, built wheels, or public PR validation environments.
---

# Source Identity Audit

## Overview

Use this skill when a result depends on exactly which code ran. It prevents the
common failure mode where a directory name, package version string, or parent
repository HEAD is mistaken for executed source identity.

## Source

Source basis: public-safe workflow distillation from source and runtime audit
practice. This skill is generic and should be paired with public repository,
wheel, PR, and commit links in concrete archives.

## Identity Layers

Record identity at each layer that can affect behavior:

- Public repository URL, branch, commit, and dirty status.
- Submodules or vendored source commit/blob hash.
- Built wheel filename, version, and hash.
- Editable install or overlay path.
- Runtime import path and module `__file__`.
- Service binary or entry point.
- Container image, package lock, or dependency versions when relevant.

Do not use a version label by itself as proof that the expected code ran.

## Audit Workflow

1. Find the repository root for each source tree with the VCS tool, not by
   assuming from the current directory.
2. Verify the target commit exists in that repository or remote.
3. For expanded source snapshots without `.git`, hash key files or compare them
   to a public blob.
4. Verify package imports at runtime from inside the same environment that will
   execute the workload.
5. Check that editable installs and overlays resolve to the intended checkout.
6. Record evidence before running the experiment or PR validation.

## Red Flags

- `git` commands in a nested snapshot report the parent repository.
- `pip show` or package metadata points to a different checkout than expected.
- A generated `_version.py` or equivalent file is missing and import fallback
  loads another installation.
- Baseline and candidate use different wheels, overlays, or dependency lanes.
- A public PR branch carries unrelated local changes.

## References

- Use [identity-record.md](references/identity-record.md) as a compact evidence
  template.
