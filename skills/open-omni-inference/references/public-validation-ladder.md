# Public Omni Validation Ladder

Use the lowest sufficient rung. Do not promote a change only because an earlier
rung passed.

## Rung 1: Source Audit

- Latest upstream main checked.
- Pending PRs or equivalent implementations checked.
- Base commit recorded.
- Candidate diff contains only the intended public feature or fix.

## Rung 2: Import and Construction

- Public environment and package paths recorded.
- Target service classes import successfully.
- Abstract methods and constructor requirements are satisfied.
- Mock or no-device construction passes where the project supports it.

## Rung 3: Service Health

- Port and device group are free.
- Service starts from the isolated public checkout.
- `/health` and model listing match the expected public model identity.

## Rung 4: Public Request

- Public input request returns successfully.
- Output is decodable or parseable with independent tools.
- Model identity and request configuration are recorded.

## Rung 5: Agile A/B

- Base and candidate share the same public environment.
- Only the tested switch or diff changes.
- Timing and behavior move in the expected direction on a small public case.

## Rung 6: Formal Evidence

- Profiler-disabled repeated timing is collected.
- Correctness or media equivalence is checked.
- Independent profile is collected only after timing warrants it.
- The report states limitations and non-promoted findings plainly.
