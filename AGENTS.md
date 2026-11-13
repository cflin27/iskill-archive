# iskill-archive

This repository archives reusable agent skills and public contribution material.
It is fully open-source. Keep this file short and maintain it as the primary
human entry point.

## Safety Rules

- Include only public, reusable workflows.
- Use public/open-source inputs, models, branches, PR links, and issue links.
- Do not commit local private patches, unpublished code, private benchmark
  cases, credentials, internal hostnames, tokens, raw logs, or full local
  environment dumps.
- Rewrite machine-local commands into portable procedures before archiving them.
- Prefer templates and summarized evidence over copied raw experiment trees.
- When in doubt, leave the item out and note which public source would be needed
  to publish it.

## Repository Map

- [skills/](skills/README.md): reusable TRAE-style skills.
- [materials/](materials/README.md): public PR/RFC/validation archive templates.
- [PUSH_PREVIEW.md](PUSH_PREVIEW.md): current staged content awaiting approval.

## Current Skills

- [Ascend Profile Analysis](skills/ascend-profile-analysis/SKILL.md): plan,
  collect, validate, and summarize Ascend/vLLM profiling evidence. Public source
  basis: [Ascend/MindIE-SD `.agents/skills`](https://github.com/Ascend/MindIE-SD/tree/dev/.agents/skills).
- [Performance Experiment Lifecycle](skills/performance-experiment-lifecycle/SKILL.md):
  run public-safe optimization experiments through agile screening, formal
  timing, and independent Profile.
- [Open Omni Inference](skills/open-omni-inference/SKILL.md): validate public
  Omni inference changes in an isolated, reproducible environment.
- [Open PR Maintenance](skills/open-pr-maintenance/SKILL.md): review, revise,
  validate, and reply on open-source PRs.

## Material Archive Policy

Each PR or RFC archive should live under `materials/prs/<public-id-or-topic>/`
and contain only public-safe files:

- `README.md`: what changed, public links, and evidence index.
- `rfc-design.md`: design sketch or Mermaid diagram using public names.
- `validation-and-benefit.md`: environment, inputs, metrics, and conclusion.
- `review-response.md`: maintainer comments, changes made, and reply draft.

Use [materials/templates/](materials/templates/) when creating a new archive.

## Maintenance Checklist

Before publishing an update:

1. Read this file first.
2. Confirm every artifact is public-safe and source-attributable.
3. Add or update source links when a skill or material is distilled from a
   public repository, PR, RFC, or discussion.
4. Prefer links or distilled summaries to copied raw logs.
5. Run a text scan for private paths, tokens, hostnames, and local case names.
6. Update [PUSH_PREVIEW.md](PUSH_PREVIEW.md) with a short human summary.
