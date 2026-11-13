# Cache Methodology

Caching can be a real optimization, but it is easy to measure the wrong thing.

## Required Distinctions

- Cold cache: first request for a new input or workload.
- Warm cache: repeated request where the cache is expected to hit.
- Production-like traffic: inputs vary according to the target workload.
- Repeated-input benchmark: useful for mechanism testing, not automatically a
  production speedup.

## Rules

- Report cold-cache and warm-cache behavior separately when both can occur.
- Do not use the same content for warmup and measured requests unless the
  experiment is explicitly about repeated-input caching.
- Record the cache key, invalidation rule, and hit condition.
- Verify correctness for both hit and miss paths.
- Avoid headline claims that generalize warm-cache data to new-input traffic.

## Report Phrase

Use language like:

```text
This result measures repeated-input warm-cache behavior. It should not be
interpreted as a new-input production speedup without a separate cold-cache or
traffic-shaped experiment.
```
