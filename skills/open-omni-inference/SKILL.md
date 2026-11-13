---
name: open-omni-inference
description: Validate open-source Omni inference changes with public inputs and isolated environments. Use when preparing or reviewing an Omni/vLLM-style PR, checking service health, running a public inference smoke test, comparing base and candidate behavior, or deciding whether performance evidence is strong enough to publish.
---

# Open Omni Inference

## Overview

Use this skill to validate an Omni inference change without leaking private
data or mixing environments. It favors public examples, isolated checkouts, and
clear promotion gates from smoke tests to performance claims.

## Source

Source basis: public-safe workflow distillation from Omni/vLLM open-source
contribution practice. This skill is not tied to a single upstream file yet.
When archiving a concrete validation, add the public repository, PR, issue, RFC,
or discussion links in `materials/prs/<topic>/README.md`.

## Workflow

1. Audit upstream first. Check whether the latest public main branch already
   contains an equivalent fix.
2. Create an isolated public checkout and record the base commit.
3. Use the release lane declared by the public project. Do not swap framework
   versions only because another component has a verified commit.
4. Verify imports and service object construction before occupying accelerator
   devices.
5. Start a service only after checking ports, device ownership, and environment
   identity.
6. Run a public request that can be decoded and independently inspected.
7. Compare base and candidate with the same public model, input, request order,
   environment, and switches.
8. Promote evidence gradually: unit/CPU checks, service health, public request,
   agile A/B, then formal timing and profile if the earlier gates pass.

## Public-Safe Rules

- Use public model identifiers and public sample media.
- Do not copy private prompts, private case files, private weights, internal
  paths, raw logs, or local patches into the public checkout.
- Record actual module paths and versions. If a dependency is loaded from the
  wrong checkout or overlay, stop and fix the environment.
- Treat HTTP 200 and `/health` as service evidence only, not as performance or
  correctness proof.
- Keep base and candidate pipelines symmetric. Temporary compatibility patches
  used only for local diagnosis should not be committed unless they are the
  reviewed public change.

## References

- Use [public-validation-ladder.md](references/public-validation-ladder.md) to
  decide how far a candidate should be promoted.
