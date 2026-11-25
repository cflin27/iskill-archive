# Same-Version Noise Baseline

## Scope

A same-version control — the same build measured twice under the same protocol —
estimates the drift the protocol itself produces. It answers one question: how
large a difference can this protocol produce when nothing in the code changed. It
is not an A/B result, and by itself it says nothing about a candidate.

Record the protocol an entry describes, and keep that scope attached wherever the
entry is reused: the public input set and its size, requests per arm, generation
steps (for example 1 NFE), warmup and formal counts, whether every arm gets an
independent service start, container, and cache, whether CPU affinity or a cpuset
was bound, whether stage timers, device synchronization, or a profiler were
attached, and which work sits inside the end-to-end span.

An entry measured under one protocol does not calibrate another. A single-step
image run without CPU affinity binding does not calibrate a 50 NFE workload, a
fused-operator timing, a stage-only component measurement, or a protocol that adds
stage synchronization or profiling. Importing it there is a mis-scoped comparison,
not a conservative choice. When steps, input set, affinity, or diagnostics change,
take a new control under the new protocol, or mark the metric as having no valid
noise reference — do not reuse the old band.

## The Control

- Run the same build in independent service starts, and keep each start separate:
  its warmup, formal samples, range, standard deviation, and pairing by request
  index. Do not present a pooled statistic as the entry's result: a pooled
  deviation mixes within-start spread with start-to-start drift, so it represents
  neither and can sit above or below any single start's spread. Two starts whose
  samples are `[1, 1]` and `[3, 3]` each have zero sample spread, while their
  pooled sample spread (n − 1) is about 1.155. Keep the per-start statistics and
  report the between-start mean difference separately.
- Report at least the formal request count, the pair count, the block count, the
  deviation and whether it is within starts or includes restarts, each block-mean
  difference with its sign, the paired range, and the maximum block-mean
  magnitude. State the sign convention, for example "later start minus earlier
  start". Label the sample unit of every statistic: a pooled standard
  deviation's `N` is a request count, not a pair count, so it cannot be read as
  pair-level dispersion.
- Run the control on the protocol, device set, and window the candidate will use.
  A control from another machine, software stack, or load condition describes that
  environment, not this protocol.
- Do not attach diagnostics to the control protocol that the candidate protocol
  does not carry, and vice versa; the band must describe the protocol being gated.

## Percentages and Their Denominators

- Name the denominator of every percentage: which arm's mean and which metric. A
  run-order difference ("later start minus earlier start") uses the earlier
  start's mean; a candidate-minus-baseline difference uses the baseline arm's
  mean. The same millisecond gap produces two different percentages, and neither
  may be quoted with the other's denominator.
- Throughput percentages come from the same end-to-end mean (completed requests
  over elapsed time), so a latency percentage and its throughput percentage are
  one observation, not two independent ones. Report them as one row.
- When converting a historical row from version order to run order, keep the
  original percentage and the converted percentage side by side. A percentage
  whose denominator changed cannot be compared against an absolute envelope
  computed from the original denominator; put the same denominator on both sides
  of any comparison.
- Percentages do not transfer across metrics: a stage percentage is not a request
  percentage, and a component percentage is not a full-request percentage.

## Magnitude Versus Signed Direction

- An absolute-magnitude envelope (zero to the largest observed magnitude) and the
  observed signed range are different summaries. Judge whether this measurement
  can resolve a difference from the absolute difference between the two values
  compared at the same level and that level's absolute envelope; check direction
  from the signed range. A historical difference smaller than the envelope
  maximum is inside the magnitude envelope; it is not necessarily inside the
  measured range, and it is not automatically reproduced.
- A signed range carries direction. If every same-version block-mean difference
  was positive (a later start was slower), a historical negative difference does
  not lie in that signed range even when its magnitude is smaller. Comparable
  magnitude is not evidence that a run-position effect reproduced; direction
  agreement across independent controls is what such an explanation would need.
- Keep the historical row (candidate minus baseline) unchanged and put the
  converted order difference in a separate column. The conversion is a descriptive
  re-expression, not a replacement for the original row or its verdict.
- Magnitude agreement also does not establish code causality. A same-version
  control shows the protocol moved while the code was held fixed, so it can show
  that fixed code also produces differences of this size. Under that protocol the
  candidate effect cannot be distinguished from the protocol's own drift: the
  control cannot exclude a candidate contribution from a historical A/B
  difference, and it cannot prove which factor produced either delta.
- Treat the observed range as a descriptive band, not a confidence interval and
  not a universal normal bound. Do not loosen or tighten a threshold because a
  small-sample range happens to be wide, and do not read a value inside the band
  as "no effect".

## Gate Applicability and Stopping

- Decide before the run what the same-version band is for: qualifying a gate
  verdict, declaring the protocol unable to resolve an effect, or both. Put that
  verdict next to the numeric gate, not in a footnote.
- Keep two no-verdict outcomes apart, and fix which one applies before looking at
  the result:
  - `not applicable` — the run did not hit the gated fast path. Say which hit
    evidence supports the miss, because the three kinds prove different things
    (see [device-gating-evidence.md](device-gating-evidence.md)):
    - an install count of `0` means the install routine replaced nothing, so the
      fast path was never registered in that process. It is a registration fact,
      never a call count;
    - a measured call count of `0` on a representative request scope — the input
      shape and routing the gated metric uses — means the fast path did not
      execute in that scope, and only in that scope. Write it as `0`, and do not
      carry one scope's zero into another scope;
    - a call count that was not collected is neither `0` nor a miss. Leave it
      `not measured` or `not retained`, collect it before the scope is promoted
      to formal timing, and do not record `not applicable` on its basis.
    A confirmed miss states scope, not effect: it does not mean zero cost, and it
    is not a pass.
  - `undetermined` — the path was hit, but the candidate-versus-baseline
    difference is no larger than what the same protocol produces with the code
    held fixed, so this protocol cannot resolve the effect. Compare like with
    like: a block-mean difference against the band's block-mean range, a single
    pair against the band's single-pair range, and the magnitude against that
    level's absolute envelope. It is neither pass nor fail, and it does not
    license calling the candidate faster.
  Do not label a path that ran `not applicable`, and do not label a path that
  never ran `undetermined`. Do not read an install count as a call count, one
  scope's counted zero as another scope's zero, or a missing count as either.
- Keep the numeric threshold and its historical marker for description, but do
  not derive a new regression decision from it.
- The measured A/A magnitude describes the resolution limit of this measurement
  only. It does not by itself authorize stopping or re-scoping a gated metric.
  Stop sampling when the rule agreed before the run is met, and record that rule,
  the value that triggered it, and why sampling stopped — not only how many
  samples ran. When the pre-agreed rule calls for it, change the measurement
  rather than adding runs: lengthen the workload, isolate the stage the change
  affects, bind host resources the protocol left free, or move to a
  component-level comparison. More runs at the same protocol do not create
  resolution the protocol lacks.
- Do not let an inapplicable performance gate stand in for a benefit claim
  elsewhere. State which metrics had a resolvable signal, which were inside the
  band, and which were not measured.

## Exit and Resource Boundary

- A noise entry covers the timed requests only. Do not reuse it as evidence about
  shutdown, exit status, or resource release.
- Take each process's exit evidence from the per-process record the actual reaper
  wrote after it obtained that process's OS wait — the process that reaped the
  child, not a launcher, a container exit, or a group summary. One row per
  process; a row without its own record stays `not retained`.
- Read a negative value as a signal exit only on interfaces whose contract
  encodes a signal as a negative return code, and only on the platforms where
  that contract holds. On POSIX, Python's `subprocess.Popen.returncode` and
  `os.waitstatus_to_exitcode()` both report `-N` when a signal `N` terminated the
  child, so there the negative value is the signal exit.
- A raw wait status is not that interface, and a status is not a negative code.
  Use `WIFSIGNALED(status)` only to test whether a signal terminated the process,
  and `WTERMSIG(status)` to obtain that signal's number, which is a positive
  value. Decode the status first, then record both facts: the predicate's answer
  and, when it holds, the signal number. Do not present a status as if it were an
  exit code, and do not read `WTERMSIG` as a negative value.
- On interfaces that encode a signal another way — a shell `$?` or a container
  exit status reported as `128 + signal`, or a runtime that reports an unsigned
  value — record that interface's own value and name the encoding; do not
  translate it into a negative code or the reverse. A manager, launcher, API, or
  container return of zero does not override the reaper's per-process record.
- Report coverage as a fraction with the groups named: how many of the run's
  processes have an independent OS record out of the total, and which groups do
  not. A row without a record stays `not retained`; never fill it with zero.
- Resource release is a verdict separate from clean exit. A run can release its
  cards, ports, and remaining children while at least one process exited by
  signal. Report "resources released" and "clean exit not claimed" as two
  statements, and keep the force-kill warning and its count verbatim.
- A matched same-version result is no exception: it does not certify the shutdown
  behavior of either arm.

## Public Sources

- General method guidance distilled from same-version and order-swapped controls
  on vLLM-Omni Ascend runs. The related public context is
  [vllm-project/vllm-omni#9468](https://github.com/vllm-project/vllm-omni/pull/9468).
- Two public artifacts are cited separately and are not interchangeable:
  - [cflin27/vllm-omni@9483ed9](https://github.com/cflin27/vllm-omni/tree/9483ed912963662b7a9d5220a0d200e2060c6761)
    provides the shared Ref2VA input and request protocol for this batch of runs.
    The comparison records already in that commit tree were built for #9467 and
    #9494, so they are comparison records for those PRs, not a noise reference
    for this entry.
  - [cflin27/vllm-omni@4a4017db](https://github.com/cflin27/vllm-omni/tree/4a4017db17710f2ce297d5b7f4ca640c3b44e0b4)
    is the public reproduction bundle that the #9468 PR body links for the
    historical revision's Ascend910B4 component measurements. The same frozen
    commit also carries a `pr9468-native/` single public image-condition 1 NFE
    precision case; any citation of that case names the subdirectory and its
    precision scope.
  Both artifacts have public provenance. Neither supplies a noise reference for
  the other's scope, and this entry is not derived from the `4a4017db` component
  measurements.
- The specific same-version control run's raw evidence is not published; this
  entry is general method and carries no case-specific numbers, hosts, logs,
  paths, or device assignments.
