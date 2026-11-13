---
name: public-artifact-archive
description: Prepare public-safe experiment, validation, and PR evidence archives with concise indexes, manifests, configuration records, reproduction notes, and local-artifact boundaries. Use when publishing validation material, organizing PR evidence, or converting local experiment outputs into an open-source archive.
---

# Public Artifact Archive

## Overview

Use this skill to turn local evidence into a readable public archive without
leaking private data. Publish summaries, manifests, reproduction notes, and
public links; keep raw private logs and large local artifacts out of Git.

## Source

Source basis: public-safe workflow distillation from experiment archival
practice. Concrete archives must cite public repositories, PRs, commits, models,
inputs, and discussions.

## Archive Shape

Use a shallow, human-readable structure:

```text
<topic>/
├── README.md
├── manifest.json
├── config.md
├── reproduce.md
├── validation.md
├── code-index.md
└── local-artifacts.md
```

For PR material, prefer the repository templates under `materials/templates/`.

## What To Publish

- Public problem statement and decision.
- Public source identity and candidate diff link.
- Public model/workload/input identity.
- Timing and correctness summaries with units and sample counts.
- Reproduction commands that use placeholders for user-local paths.
- Hashes of public or locally retained artifacts when useful.
- Limitations and not-run items.

## What Not To Publish

- Private prompts, datasets, media, checkpoints, credentials, hostnames, or
  user-specific paths.
- Full raw logs that include environment dumps or service internals.
- Large profiler dumps or generated media unless they are explicitly approved
  for public release.
- Local private patches or unpublished source snapshots.

## Validation

Before publishing:

1. Check links and relative paths.
2. Verify that sample counts and means match the raw public-safe records.
3. Confirm that every claim has a public source or is marked as local-only.
4. Scan for credentials, private paths, internal hostnames, and local case names.
5. Keep large or private files listed in `local-artifacts.md`, not committed.

## References

- Use [archive-checklist.md](references/archive-checklist.md) before committing.
