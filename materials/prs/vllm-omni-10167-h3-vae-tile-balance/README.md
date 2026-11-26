# vLLM-Omni #10167: Balance MiniMax-H3 video VAE encode tiles across temporal clips

Public-safe archive for
[vllm-project/vllm-omni#10167](https://github.com/vllm-project/vllm-omni/pull/10167),
an opt-in scheduler that distributes complete reference-video clip/tile tasks
across the video-VAE parallel ranks instead of processing temporal clips one at
a time in rank-local order.

## Summary

- Public base: `b7bbfbdb4f2b3c070d9632043ea6cd2b1c601270`
- Validated candidate: `bc70adc0509f2b05832389e529b8f8082e88f358`
- PR state at publication: open, Draft. See the PR description for the validation
  results and side-by-side comparison.
- Result: the balance path executes on all eight native Stage0 ranks, the
  formal VAE stage drops from 4177.600 to 3669.504 ms (paired median −12.1474%,
  95% CI [−12.2274%, −12.1153%]), the production 50 NFE guard passes at
  −0.1047% with a confidence interval that includes zero, and six formal
  baseline/candidate pairs are bitwise identical after decoding.
- Evidence: the formal 50 NFE machine-readable results are in
  [evidence/pr10167](evidence/pr10167/); the synchronized comparison GIF is in
  [assets/pr10167-ref2va-formal-comparison.gif](assets/pr10167-ref2va-formal-comparison.gif).
  The early 39/156/312-frame component A/B is documented from the public frozen
  reproduction tree. The two measurement sets are not interchangeable.
- Scope: one Ascend 950PR host, eight cards, one public Ref2VA fixture. No claim
  about other shapes, other hardware, decode performance or long-video quality.
  See [validation-and-benefit.md](validation-and-benefit.md) for parameters,
  statistics and non-claims.

## Public references

- PR: [vllm-project/vllm-omni#10167](https://github.com/vllm-project/vllm-omni/pull/10167)
- Base commit: [`b7bbfbdb4`](https://github.com/vllm-project/vllm-omni/commit/b7bbfbdb4f2b3c070d9632043ea6cd2b1c601270)
- Candidate commit: [`bc70adc05`](https://github.com/cflin27/vllm-omni/commit/bc70adc0509f2b05832389e529b8f8082e88f358)
- Implementation: `vllm_omni/diffusion/models/minimax_h3/vae_tile_balance.py` (new),
  `vae.py`, `pipeline_minimax_h3.py`, `encoder.py`
- Tests: `tests/diffusion/models/minimax_h3/test_minimax_h3_vae_tile_balance.py` (new),
  `tests/model_executor/models/test_minimax_h3_encoder_payload.py`
- Documentation: `recipes/MiniMaxAI/MiniMax-H3-NPU.md` at the candidate commit
  ([pinned recipe](https://github.com/cflin27/vllm-omni/blob/bc70adc0509f2b05832389e529b8f8082e88f358/recipes/MiniMaxAI/MiniMax-H3-NPU.md))
- Public input fixture:
  [`tests/e2e/accuracy/minimax_h3/test_minimax_h3_i2va_ref2va_similarity.py`](https://github.com/cflin27/vllm-omni/blob/085d7dba33eca00f44753f8c4a5e11bd7c669f38/tests/e2e/accuracy/minimax_h3/test_minimax_h3_i2va_ref2va_similarity.py)
  at the pinned input-definition commit (`REF2VA_PROMPT`, `REF2VA_INPUT_VIDEO_URL`,
  `REF2VA_INPUT_AUDIO_URL`)
- Public model: `MiniMaxAI/MiniMax-H3` at
  [`42ed227ee`](https://huggingface.co/MiniMaxAI/MiniMax-H3/tree/42ed227ee7df40d41602854ae760620d6eb651fe)
- Early component reproduction tree:
  [`cflin27/vllm-omni@0b6381b67`](https://github.com/cflin27/vllm-omni/tree/0b6381b673d47c58c8e8ad04a8cbfa1543f9c273).
  It holds the two fixed early arms, the encoder-only harness and exact
  commands, and the public QSA compatibility patch. It is not the formal 50 NFE
  service harness.
- Formal 50 NFE evidence: [evidence/pr10167](evidence/pr10167/) (this
  repository). It contains the selected per-request statistics, per-pair
  precision records, input manifest and identity records needed to review the
  public claims. The full formal harness commands and machine-specific
  execution records are retained internally and are not part of the public
  archive.

## Files

- [rfc-design.md](rfc-design.md): problem, scheduling design, flow, fallback
  matrix, compatibility and risks.
- [validation-and-benefit.md](validation-and-benefit.md): environment, public
  input, functional coverage, early component A/B, formal precision,
  performance, lifecycle evidence, reproduction and limits.
- [review-response.md](review-response.md): review state and prepared answers
  to likely maintainer questions.
- [evidence/pr10167/](evidence/pr10167/): machine-readable formal results,
  per-pair precision and input identity, with provenance and checksums.
- [assets/](assets/): synchronized baseline/candidate comparison GIF, its
  metadata and the transcode command.

## Evidence Boundary

The archive summarizes measurements taken in disposable eight-card containers
and publishes the selected machine-readable records that support the stated
claims. It does not include raw machine logs, container images, checkpoint
files, unreleased patches, private media, host names, local paths, process IDs
or device assignments. The comparison GIF is a presentation copy; every
reported RGB, PSNR, SSIM and PCM value was measured on the original decoded
outputs at their original resolution. Formal precision was measured on the six
accepted 50 NFE pairs only; a 1 NFE smoke output is never presented as formal
precision evidence.
