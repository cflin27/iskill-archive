# vLLM-Omni #11003: Stream rank-local MiniMax-H3 reference-video tiles

Public-safe archive for
[vllm-project/vllm-omni#11003](https://github.com/vllm-project/vllm-omni/pull/11003),
an opt-in path that uploads only each rank's spatial tiles of the reference
video instead of materializing the whole normalized video on the device before
the MiniMax-H3 video VAE encode.

## Summary

- Public base: `085d7dba33eca00f44753f8c4a5e11bd7c669f38`
- Validated candidate: `5e4f260d5d716774fc88ea7219c31728239b8131`
- State at archive time: open, draft. This archive update and the PR body
  revision are not yet published.
- Result: the streamed path is hit on eight ranks, encoder rows are
  bit-identical to the baseline, HTTP and AsyncOmni reference-to-video outputs
  are bit-identical at 50 NFEs, VAE latency stays inside the 3% gate
  (confidence interval includes zero), and the reference-encode allocator peak
  drops by about 32% for the public 124x768x1344 request.
- Scope: one Ascend 950PR host, eight cards, one public Ref2VA fixture. See
  [validation-and-benefit.md](validation-and-benefit.md) for parameters, limits
  and non-claims.

## Public references

- PR: [vllm-project/vllm-omni#11003](https://github.com/vllm-project/vllm-omni/pull/11003)
- Base commit: [`085d7dba3`](https://github.com/vllm-project/vllm-omni/commit/085d7dba33eca00f44753f8c4a5e11bd7c669f38)
- Candidate commit: [`5e4f260d5`](https://github.com/cflin27/vllm-omni/commit/5e4f260d5d716774fc88ea7219c31728239b8131)
- Implementation: `vllm_omni/diffusion/models/minimax_h3/vae.py`
- Tests: `tests/diffusion/models/minimax_h3/test_minimax_h3_video_tile_input.py`
- Documentation: `recipes/MiniMaxAI/MiniMax-H3-NPU.md` at the base commit
  ([pinned recipe](https://github.com/vllm-project/vllm-omni/blob/085d7dba33eca00f44753f8c4a5e11bd7c669f38/recipes/MiniMaxAI/MiniMax-H3-NPU.md))
- Public input fixture:
  [`tests/e2e/accuracy/minimax_h3/test_minimax_h3_i2va_ref2va_similarity.py`
  at the base commit](https://github.com/vllm-project/vllm-omni/blob/085d7dba33eca00f44753f8c4a5e11bd7c669f38/tests/e2e/accuracy/minimax_h3/test_minimax_h3_i2va_ref2va_similarity.py)
  (`REF2VA_PROMPT`, `REF2VA_INPUT_VIDEO_URL`, `REF2VA_INPUT_AUDIO_URL`)
- Reproducible synthetic frames and fixed two-arm checkouts:
  [validation-and-benefit.md](validation-and-benefit.md#reproduction)

## Files

- [rfc-design.md](rfc-design.md): problem, design, flow, compatibility, risks.
- [validation-and-benefit.md](validation-and-benefit.md): environment,
  correctness, precision, performance, reproduction, limits.
- [review-response.md](review-response.md): review themes and reply policy.

## Evidence Boundary

The archive summarizes measurements taken in a disposable eight-device
container. It does not include raw logs, container images, model weights,
checkpoint files, unreleased patches, private media or private host details.
The [side-by-side comparison GIF](assets/ref2va-comparison.gif) shows the baseline
on the left and the candidate on the right. It was generated from the silent
comparison and contains 124 frames at 672 × 192 pixels. The reported accuracy
metrics use the original outputs at the original resolution.
