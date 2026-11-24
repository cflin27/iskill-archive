# Async Overlap Validation

Asynchronous execution can make a sub-stage earlier without improving end-to-end
latency. Validate overlap before promoting the change.

## Required Evidence

- A timeline showing producer and consumer intervals.
- The target interval where overlap is expected to reduce wall time.
- Full request wall time for baseline and candidate.
- Correctness evidence for outputs produced through the async path.

## Promotion Rules

- Mechanism evidence is not enough: an async task finishing earlier only proves
  scheduling changed.
- Promote only when the target interval or full wall time improves under paired
  conditions.
- If only media-ready, prefetch-ready, or sub-stage timing improves, label the
  result as not promoted until full impact is measured.
- Check synchronization points. A misplaced wait can serialize the path or wait
  on the wrong stream/event.

## Call Interval vs Kernel Time

A host-side call interval measures when a function was entered and exited. It
includes waiting, interpreter overhead, and time spent overlapped with other
work. It is not CPU kernel time.

A candidate can widen a host call interval while shortening the critical path,
because the added work overlaps an accelerator call. The reverse is also
possible: two calls can appear to "overlap" while the request gets slower.
Therefore:

- Measure overlap as the intersection of producer and consumer intervals within
  one request, not as the sum of both durations.
- Confirm the overlapped work lies on the request's critical path before claiming
  a saving.
- Report the call interval as a diagnostic; report kernel time separately; make
  the promotion decision from full request wall time.

## Measurement Setup

- Fix host thread count and affinity across arms for CPU-side stages.
- Warm up each version independently before its measured repeats.
- Keep tail samples; report the range and count next to the mean.
- Trace a small separate sample set for mechanism evidence and keep it out of
  formal timing.

## Report Phrase

Use language like:

```text
The asynchronous path executed and overlapped the intended interval, but the
full request wall-time improvement was not proven, so this remains mechanism
evidence rather than a promoted optimization.
```
