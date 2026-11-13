# Open PR Review Loop

## Intake

- Fetch latest PR metadata and review comments.
- Confirm the branch still targets the intended public base.
- Identify whether each comment requires code, tests, docs, or explanation.

## Revision

- Keep commits focused on the PR topic.
- Avoid carrying unrelated local edits.
- Prefer upstream project patterns over new abstractions.
- Update tests near the changed behavior.

## Validation

- Run the narrowest meaningful tests first.
- Add broader tests when the change touches shared behavior.
- Record commands, exit status, and important output.
- Keep private logs out of public artifacts.

## Reply

Use this shape:

1. Acknowledge the review point.
2. State the change or reason no change was needed.
3. State validation.
4. Mention remaining limitations only if they matter to merge safety.

## Archive

Archive a distilled public record after the PR is updated:

- PR link and public base commit.
- Design summary or RFC sketch.
- Validation and benefit summary.
- Review comments addressed.
- Links to public commits, checks, and discussion.
