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
2. Create an isolated public checkout and record the base commit. Keep the
   source read-only and give the job a separate writable working directory for
   reports, caches, and generated inputs, so tools that auto-write cannot block
   initialization or dirty the tree.
3. Use the release lane declared by the public project. Do not swap framework
   versions only because another component has a verified commit.
4. Verify imports, model hierarchy, and checkpoint identity before occupying
   accelerator devices. Record the resolved model class, not only the alias.
5. Verify port availability, device ownership, and environment identity before
   running probes. Confirm that timeout and resource parameters are within the
   runtime library's accepted ranges.
6. Run the device probes on the intended device group in order. Check
   enumeration, a real tensor operation with synchronization, a cross-device
   collective, and the collective the target model path uses.
7. After the required probes pass, recheck port availability and device
   ownership immediately before starting the service. Verify service health.
8. Run a public request that can be decoded and independently inspected.
9. Compare base and candidate with the same public model, input, request order,
   environment, and switches.
10. Promote evidence gradually: unit/CPU checks, device probes, service health,
    public request, agile A/B, then formal timing and profile if the earlier
    gates pass.

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
- If an earlier failure does not reproduce under the configuration you chose,
  say "not observed with this configuration". Do not call it fixed without a
  targeted run of the failing path.
- Report every candidate test failure with its first error. Repeat the check on
  the control in the same environment and record whether it passed, failed in
  the same way, failed differently, or was not completed. Assess whether a
  shared failure blocks the comparison based on the required outputs and samples.

## References

- Use [public-validation-ladder.md](references/public-validation-ladder.md) to
  decide how far a candidate should be promoted.
