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
   initialization or dirty the tree. Record the interpreter that launches
   workers and the resolved import paths the process actually uses; a shell
   alias or wrapper that is not an executable on PATH can leave a child launch
   with an empty executable.
3. Use the release lane declared by the public project. Do not swap framework
   versions only because another component has a verified commit.
4. Verify imports, model hierarchy, and checkpoint identity before occupying
   accelerator devices. Record the resolved model class, not only the alias.
5. Verify port availability, device access authorization, device ownership, and
   environment identity before running probes. First confirm which device nodes
   the container presents and the policy that governs opening them: a devices
   cgroup allow/deny list, file permissions, or the platform's equivalent.
   Confirm that the run can open only the granted nodes; if the effective access
   scope cannot be confirmed, stop and treat the pre-check as failed. Then
   resolve the numbering in separate steps instead of one combined check: map
   each container device node to its host physical card, then record the index
   the installed runtime's visibility selector accepts and the framework index
   after masking, and map each of those to a host card. The index the installed
   selector accepts is the authoritative one for launch, and host numbering may
   be reused only after the mapping has been verified on that implementation;
   do not assume it applies. A correct visible count does not prove physical
   ownership, and the visibility value only selects within the accessible set.
   Confirm that timeout and resource parameters are within the runtime library's
   accepted ranges.
6. Run the device probes on the intended device group in order. Check
   enumeration, a real tensor operation with synchronization, a cross-device
   collective, and the collective the target model path uses.
7. After the required probes pass, recheck port availability and device
   ownership immediately before starting the service. Verify service health.
8. Run a public request that can be decoded and independently inspected. Record
   the requested duration and frame rate, the actual frame count, frame rate,
   duration, and the generated latent's temporal extent. A pipeline can round
   the request to a native frame alignment, so the returned length may
   legitimately differ from `duration * fps`.
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
- State whether parity evidence came from warmup exports or from the formal
  outputs. Warmup-exported arrays certify the warmup request only; when both
  arms show the same warmup-versus-formal difference, report it as a shared
  observation with an unknown cause.
- Treat a capability-gated fast path as two claims: the fast path is entered on
  the intended device, and every other device keeps the original path with
  identical output. Report the two device classes as separate rows. Zero
  installs and zero calls only show that the gate did not select the fast path.
  Call the fallback verified only when the outputs also match the baseline and a
  side-effect check shows no marker, no bound `forward`, and no replaced
  weights; otherwise that row stays `fallback selected`. Reserve `not covered`
  for a device that was not run at all: a missing fallback check does not relabel
  the intended-device row.
- Confirm actual calls in each intended scope on the timed request shape
  before formal timing. A confirmed zero makes fast-path timing inapplicable
  for that scope. An excluded-device smoke check closes when routing, zero
  install and call counts, baseline parity, and clean side effects are all
  verified.

## References

- Use [public-validation-ladder.md](references/public-validation-ladder.md) to
  decide how far a candidate should be promoted.
