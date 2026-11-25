# vLLM-Omni #11004: Stage only MiniMax-H3 audio-encoder weights during reference encoding

Public-safe archive for
[vllm-project/vllm-omni#11004](https://github.com/vllm-project/vllm-omni/pull/11004),
which keeps only the audio-VAE weight groups that reference encoding uses on the
device and leaves the audio decoder groups on the host.

## Summary

- Public base: `085d7dba33eca00f44753f8c4a5e11bd7c669f38`
- Validated candidate: `dc6cb7c1255160f0b236d0351be91f291491b8e2`
- State at archive time: open, draft
- Result: on a real checkpoint the encode scope stages only `encoder`,
  `pre_block` and `mean_proj`, while `decoder`, `dec_in_proj` and `logs_proj`
  stay on CPU; six paired 50 NFE reference-to-video requests are bit-identical
  (pixel, PCM and both audio latents, PSNR infinite, SSIM 1.0); the isolated
  load+encode window is 17.7% faster and its allocator peaks drop by 25.5%
  allocated and 29.9% reserved; the full 50 NFE request peak is unchanged.
- Scope: one Ascend 950PR host, eight cards, one public Ref2VA fixture. See
  [validation-and-benefit.md](validation-and-benefit.md) for parameters, limits
  and non-claims.

## Public references

- PR: [vllm-project/vllm-omni#11004](https://github.com/vllm-project/vllm-omni/pull/11004)
- Base commit: [`085d7dba3`](https://github.com/vllm-project/vllm-omni/commit/085d7dba33eca00f44753f8c4a5e11bd7c669f38)
- Candidate commit: [`dc6cb7c1`](https://github.com/cflin27/vllm-omni/commit/dc6cb7c1255160f0b236d0351be91f291491b8e2)
- Implementation:
  `vllm_omni/diffusion/models/minimax_h3/vae.py` and
  `vllm_omni/diffusion/models/minimax_h3/pipeline_minimax_h3.py`
- Tests: `tests/diffusion/models/minimax_h3/test_minimax_h3_audio_split_residency.py`
- Documentation: `recipes/MiniMaxAI/MiniMax-H3-NPU.md`
- Public input fixture at the base commit (`REF2VA_PROMPT`,
  `REF2VA_INPUT_VIDEO_URL`, `REF2VA_INPUT_AUDIO_URL`). [the public Ref2VA accuracy test](https://github.com/vllm-project/vllm-omni/blob/085d7dba33eca00f44753f8c4a5e11bd7c669f38/tests/e2e/accuracy/minimax_h3/test_minimax_h3_i2va_ref2va_similarity.py)

## Files

- [rfc-design.md](rfc-design.md): problem, design, flow, compatibility, risks.
- [validation-and-benefit.md](validation-and-benefit.md): environment,
  correctness, precision, performance, reproduction, limits.
- [review-response.md](review-response.md): pre-submission review themes,
  resolution, and reply policy.

## Evidence Boundary

The archive summarizes measurements taken in a disposable eight-device
container. It does not include raw logs, container images, model weights,
checkpoint files, unpublished patches, private media or private host details.
The PR description is the location for the side-by-side precision video.

This change moves where weights are staged; it does not change the arithmetic
of the audio encoder, so the expected precision difference is exactly zero. The
performance result is a stage-scoped allocator saving, not a full-request peak
reduction, and the end-to-end confidence intervals include zero.
