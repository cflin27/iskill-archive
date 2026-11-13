# RFC Design

## Problem

Describe the public issue or PR motivation.

## Proposal

Explain the public change and link to public source files or commits.

## Flow

```mermaid
flowchart TD
    request[Public request] --> baseline[Baseline path]
    request --> candidate[Candidate path]
    candidate --> checks[Correctness and timing checks]
    checks --> decision[PR decision]
```

## Compatibility

- Public API impact:
- Runtime impact:
- Fallback behavior:

## Risks

- Correctness:
- Performance:
- Maintenance:
