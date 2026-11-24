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
- Model hierarchy the task loader actually constructs, not only the model alias
  or run label.
- Checkpoint or weight revision/hash, and expected versus present shard count.
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
5. Resolve the model class the loader actually builds. A task entry can name one
   variant while the loader resolves a different hierarchy (base versus
   distilled, dense versus sparse, language versus omni wrapper). Record the
   resolved class, module path, and launch arguments.
6. Confirm checkpoint identity: revision or hash, and that the expected number of
   shards is present and non-empty. A directory that exists is not a checkpoint
   that matches.
7. Check that editable installs and overlays resolve to the intended checkout.
8. Record evidence before running the experiment or PR validation.

## Red Flags

- `git` commands in a nested snapshot report the parent repository.
- `pip show` or package metadata points to a different checkout than expected.
- A generated `_version.py` or equivalent file is missing and import fallback
  loads another installation.
- The model name matches, but the loader resolves a different model hierarchy or
  a different wrapper class.
- The checkpoint directory exists, but the expected shard count is short or a
  shard is empty.
- Baseline and candidate use different wheels, overlays, dependency lanes, or
  checkpoint revisions.
- A public PR branch carries unrelated local changes.

## References

- Use [identity-record.md](references/identity-record.md) as a compact evidence
  template.
