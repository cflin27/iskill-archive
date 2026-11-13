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

## Report Phrase

Use language like:

```text
The asynchronous path executed and overlapped the intended interval, but the
full request wall-time improvement was not proven, so this remains mechanism
evidence rather than a promoted optimization.
```
