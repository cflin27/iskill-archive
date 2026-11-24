# Device Gating Evidence

A change that adds an optional device-specific fast path (fused operator,
vendor kernel, specialized layout) protected by a capability check is two
claims, not one: the fast path is entered on the intended device, and every
other device keeps the original path with the original output. Validate and
report them separately.

## Evidence Per Device Arm

Record, for each tested device group:

- the raw device query result exactly as returned, not a normalized label or the
  device type the report assumed;
- the capability check or gate predicate and the branch it selected;
- the install or registration count returned by the install routine, meaning
  how many modules or submodules were actually replaced;
- per-consumer call counts of the fast path, one row per scope (for example
  single-frame, multi-frame, decoder). Write `0` as `0`; do not omit a scope;
- output parity against the baseline on the same device (maximum absolute
  difference, hashes, or the media metrics the pipeline supports);
- on the fallback arm, the side-effect checks described in the next section,
  reported separately from the counts.

Keep the raw query output, the install counters, and the call counters with the
private run evidence; publish only the summarized table.

## Zero Fast-Path Activity Proves Routing, Not the Fallback

An install count of `0` and zero fast-path calls show only that the gate did not
select the fast path. That is a routing fact for one process on one device. It
does not show that the fallback kept the original behavior, and it is not by
itself a fallback verdict.

Accept the fallback arm only when the same run also reports:

- output parity against the baseline on the same device, input, seed, and
  parameters, using the same difference or media metrics as the rest of the
  report;
- a side-effect check of the module tree after the install call: no marker set,
  no private `forward` bound, no replaced or derived weights left behind.
  Record how the check was made (for example a before/after `__dict__` or
  attribute count), not only its result.

The two parts answer different questions. Zero hits answer "was the fast path
chosen"; parity plus the side-effect check answer "is the original path still
intact". A row that has only the first is `fallback selected`, not
`fallback verified`.

## A Fallback Run Is Not a Fast-Path Qualification

If the only reachable device is one the gate excludes, the run reaches the
fallback branch on that device; it becomes `fallback verified` only after the
parity and side-effect checks above. It says nothing about the fast path on the
intended device. State the claim at that scope:

> On the tested device the gate returned false, the install count was 0, and the
> fused calls were 0; the outputs matched the baseline, and the module tree
> showed no marker, no bound `forward`, and no replaced weights. The fast-path
> hit on the target device remains `not covered`.

Do not summarize that result as "fusion validated", "the optimization works",
or under the target device's name. Once parity and the side-effect check are in
place, the fallback result is the regression-safety evidence for the devices
tested, and it should be reported as such rather than discarded.

## Do Not Bridge Device Families

A gate keyed on a name prefix or a capability flag does not transfer between
device families or runtime versions. A query string from one family does not
predict another, and a capability flag observed false on one SoC says nothing
about a different SoC. Keep one row per family, with the runtime and driver
versions, and never fill the target row from an adjacent family's run.

When a device capability is reported as unsupported, record it as an observed
fact about that device, not as a pass for the intended one.

## Stubbed Backends Test Branches, Not Decisions

Unit tests with a stubbed device query cover the gate's branches: the target
installs, and an unknown or empty name, a missing interface, or a raising query
falls back before any marker is set. They cannot show what a real device
returns. Keep both the branch tests and real-device query records, and label the
tests as branch coverage rather than hardware qualification.

## Reporting

- Use one table: device (raw query string) | gate | installs | fast-path calls
  by scope | parity versus baseline | fallback side effects | verdict.
- Use a fixed verdict vocabulary and do not blur it:
  - `fast path hit`: gate true, installs above zero, calls above zero on the
    intended device;
  - `fallback selected`: gate false, installs zero, calls zero, and no parity or
    side-effect result yet;
  - `fallback verified`: `fallback selected` plus baseline parity and a clean
    side-effect check;
  - `not covered`: no run on that device.
- If the intended device was not available, say so in the acceptance section and
  record who owns the rerun, instead of leaving the gap implied by a green
  table.
- Scope any sentence that says "supported", "validated", or "still correct" to
  the devices actually tested, and list the untested families next to it.

## Public Sources

- Public PR and validation links are added per case in
  `materials/prs/<topic>/` after the case evidence is accepted for publication.
