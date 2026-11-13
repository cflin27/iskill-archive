---
name: open-pr-maintenance
description: Maintain open-source pull requests through review, revision, validation, and maintainer replies. Use when auditing PR feedback, checking CI, updating a branch after comments, writing a concise response, or archiving PR validation and benefit material for public consumption.
---

# Open PR Maintenance

## Overview

Use this skill to keep public PR work tidy and auditable. It covers the loop
from review intake through code changes, validation, public evidence updates,
and maintainer replies.

## Source

Source basis: public-safe workflow distillation from open-source PR maintenance
practice. This skill is not tied to a single upstream file yet. When archiving a
concrete PR, add the public PR, review comment, CI/check, and discussion links
in `materials/prs/<topic>/README.md`.

## Workflow

1. Read the latest PR state: description, diff, CI, review comments, and
   maintainer replies.
2. Classify comments as correctness, API behavior, tests, docs, style, or
   question-only.
3. Audit the current branch against the latest public base before changing it.
4. Make the smallest public-safe change that answers the review.
5. Run relevant tests or explain why they were not run.
6. Update the PR description or evidence material when behavior, validation, or
   tradeoffs changed.
7. Reply briefly: what changed, what was validated, and any remaining limit.
8. Archive only public-safe RFC, validation, and benefit material under
   `materials/prs/`.

## Communication Rules

- Lead with facts and links to public evidence.
- Do not paste noisy logs; summarize the key failing or passing lines.
- Do not mention private branches, internal case IDs, private model paths, or
  local-only patches in public replies.
- If validation did not prove a speedup or correctness claim, say so directly.
- Avoid reopening resolved threads unless the new change materially affects
  that thread.

## References

- Use [review-loop.md](references/review-loop.md) for a compact PR maintenance
  checklist.
- Use [../../materials/templates/review-response.md](../../materials/templates/review-response.md)
  when archiving review replies.
