# Staged Native Execution Evidence

Short public-safe lessons from validating an opt-in scheduler inside a two-stage
inference service. The exit-audit procedure lives in
[shutdown-and-exit-audit.md](shutdown-and-exit-audit.md) and the peak/timing
rules in [experiment-methodology.md](experiment-methodology.md); this lesson
records six checks that were easy to miss in practice.

## First Native Operator Call

A successful import and a constructed model do not prove that the native runtime
dependency is complete. A source-only install, a missing compiled extension, a
download that fell back to a different URL, or a stale wheel can all survive
initialization and fail only at the first real operator call. In one campaign a
source-only Ascend install constructed all eight model ranks and then failed at
the first RMSNorm call because the compiled `vllm_ascend` extension was absent.

Add a rung between "model constructed" and "full request": execute the target
native operator once, on the real device, with a small input, and check the
result. Fix environment and harness problems identically in both arms and
classify them as environment fixes, not candidate regressions — but keep the
first raw error.

## Instrumentation Must Preserve Signatures

When a measurement hook wraps a class constructor or a module function, keep the
original signature, including keyword-only parameters and defaults. Loaders that
introspect parameters, or call with keyword-only arguments, otherwise drop
configuration silently or fail with an error that looks unrelated to the
instrumentation. After installing the hook, assert in both arms that the
instrumented object received the configuration the launch intended; a hook that
runs is not the same as a hook that received the same inputs.

## Measurement Hooks Are Part of the Guard

Identical hooks installed in both arms still add overhead, so an instrumented
request interval is not an uninstrumented user-facing number. State whether the
reported full-request guard includes the hooks, keep hash/export work outside
the synchronized stage window, and do not mix a stage interval measured around
the encode with a request interval measured around the whole service. This
distinction matters most when the end-to-end confidence interval includes zero:
the stage result and the guard are different claims.

## One Stage May Exit by Signal on a Clean Shutdown

In a two-stage service, the stage terminated by SIGTERM during normal shutdown
legitimately reports a negative reaper value while the other stage reports 0.
Record each layer separately: request result, API/supervisor, per-stage manager,
per-worker OS wait, then resource release. Report coverage as a fraction and
keep missing rows unfilled. Do not treat a negative value as a crash on an
interface that encodes signals that way, and do not let a stage with a signal
exit invalidate a request-level result. A historical block with partial wait
coverage stays a gap; never upgrade it to a clean exit in a summary table.

## Peak Scope Is Part of the Claim

State the memory kind (allocator allocated, allocator reserved, or device HBM)
and the measurement window. When stages run in separate processes, a
per-process peak sum is a conservative bound over process lifetimes, not a
simultaneous device peak: label it that way, exclude initialization and driver
memory, and gate a small increase with both a relative and an absolute
criterion.

## Warmup Versus Formal Output

Check whether the warmup output equals the first formal output **within each
arm** before trusting cross-arm parity. In one campaign both arms showed a
warmup/first-formal difference (decoded pixel and PCM maxima) whose cause was not
isolated, while every formal pair matched bitwise. Report the within-arm
difference as an open observation, and never use a warmup output as formal
precision evidence.

## Public Sources

- [vllm-project/vllm-omni#10167](https://github.com/vllm-project/vllm-omni/pull/10167)
  and its frozen reproduction tree
  [cflin27/vllm-omni@0b6381b67](https://github.com/cflin27/vllm-omni/tree/0b6381b673d47c58c8e8ad04a8cbfa1543f9c273).
- Case archive:
  [materials/prs/vllm-omni-10167-h3-vae-tile-balance](../materials/prs/vllm-omni-10167-h3-vae-tile-balance/README.md),
  including its
  [formal evidence records](../materials/prs/vllm-omni-10167-h3-vae-tile-balance/evidence/pr10167/).
- Related lessons:
  [validation-evidence-discipline.md](validation-evidence-discipline.md),
  [shutdown-and-exit-audit.md](shutdown-and-exit-audit.md),
  [experiment-methodology.md](experiment-methodology.md).
