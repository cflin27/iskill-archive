# Review Response: Cross-Clip Video VAE Tile Balance

## PR

- Link: [vllm-project/vllm-omni#10167](https://github.com/vllm-project/vllm-omni/pull/10167)
- Public base: `b7bbfbdb4f2b3c070d9632043ea6cd2b1c601270`
- Updated commit: `bc70adc0509f2b05832389e529b8f8082e88f358`
- PR state at publication: open, Draft. The PR description links to the formal
  validation evidence and side-by-side comparison.

## Comments Addressed

No maintainer review comments were open at archive time. The only PR comment is
the contributor's agent-assisted self-check, which already recorded 46 passing
CPU tests, the matched public eight-rank encoder comparison, and that
full-pipeline validation was still pending. This revision supplies that pending
full-pipeline evidence; it does not change the code under review.

| Reviewer comment | Change | Validation |
| --- | --- | --- |
| None outstanding | PR body revised with production native evidence | Six formal 50 NFE pairs, formal VAE performance, Stage0 hit/fallback and explicit limits |

The code candidate is unchanged since the revision that removed unused
scheduling state and checked the fallback matrix. If a maintainer asks for a
code change, it should be made as a new commit and the affected rows above
updated.

## Reply Draft

Use when the updated body is published. Keep it short; the body carries the
numbers.

> Updated the description with the full-pipeline validation that was pending in
> the previous revision. On one eight-card Ascend 950PR host, the native
> two-stage Ref2VA service now shows:
>
> - the balance path executed on all eight Stage0 ranks with
>   `h3_vae_encode_tile_balance_max_tasks=168` (full window 0–168, tail
>   168–224, 28 forwards per rank instead of 32/32/32/32/24/24/24/24);
> - the formal VAE stage is 12.15% faster (device-synchronized, 95% CI
>   [−12.23%, −12.12%]) with a +41.3 MiB allocator peak that stays inside the
>   documented gate;
> - the production 50 NFE request guard passes at −0.10% (95% CI [−0.23%,
>   +0.25%], default 3% gate) — the interval includes zero, so this is a guard,
>   not an end-to-end speedup claim;
> - six formal baseline/candidate pairs are bitwise identical after decoding
>   (latent, RGB and PCM maximum difference 0; PSNR ∞; SSIM 1);
> - the public negative input falls back on every rank, returns HTTP 200 with
>   the original audio retained and matches bitwise; the no-audio variant
>   returns HTTP 500 in both arms from the same pre-existing Stage1
>   `ref_audio_t` error.
>
> The comparison GIF is embedded in the description (baseline left, candidate
> right); its pixels are a display copy and the reported accuracy numbers come
> from the original outputs. Known limits, the public fixture sources, the
> machine-readable evidence and the statistical boundaries are linked there and
> in the public archive.

## Prepared Answers

**Why does VAE allocated memory increase by 41 MiB?**
The scheduler retains encoded tiles until the window gather. The measured VAE
allocated peak rises from 5109.351 to 5150.659 MiB (+41.308594 MiB, +0.81%),
inside the declared 3% **and** 256 MiB gate; reserved falls by 4 MiB. The window
size bounds how much is retained, so it is a tunable trade-off rather than an
unbounded cost.

**Why is the end-to-end request not faster if the VAE stage is 12% faster?**
The 50 NFE request is dominated by the diffusion stages. The measured change is
−0.10% with a CI that includes zero. The PR therefore claims only the stage
improvement plus a passing end-to-end guard; it does not claim a user-facing
speedup. The HTTP interval includes the identical light measurement and
parity-export hooks installed in both arms, so it is a guard under the recorded
setup, not an uninstrumented user-facing number.

**Why do Stage0 workers exit with −15?**
They are native workers terminated by SIGTERM during normal service shutdown and
reaped by the workload parent. Stage1 exits 0 and the API/workload/container
exits 0. Every accepted block has an independent OS wait for all 16 workers;
earlier smoke runs without full Stage0 wait coverage are retained as a gap and
never reported as clean exits.

**Why does the no-audio negative return HTTP 500 in both arms?**
The fallback path itself works, but the downstream reference output requires an
audio stream and rejects the derived fixture with
`ref_blocks[0].ref_audio_t must be an integer`. The same input with its original
public audio returns HTTP 200 in both arms, completes the output chain and
matches bitwise, so the fallback claim rests on that case.

**Is the checkpoint fully verified?**
The public model is `MiniMaxAI/MiniMax-H3`; the VAE weight hash matches public
revision `42ed227ee` and the frozen public record. The complete checkpoint
revision was not independently verified: transformer 13/13 and text-encoder
14/14 non-empty shards, their indices and configurations were checked, but not
every large shard was byte-hashed. The public identity record states that
boundary.

**Why does warmup differ from the first formal output?**
A within-arm warmup/first-formal difference exists in both arms (maximum decoded
RGB difference 43, PCM 5500) and its cause was not isolated. Formal precision is
computed only between formal outputs of the two arms, which matches bitwise.

**Is the comparison GIF the accuracy source?**
No. It is a 672×192, 24 fps, silent presentation copy derived from the original
562,319-byte comparison MP4, with baseline on the left and candidate on the
right. The reported RGB, PSNR, SSIM and PCM values were measured on the original
decoded outputs before GIF encoding.

**Is any input private?**
No. The prompt, reference video and audio come from the public Ref2VA test
definition, pinned by commit and SHA-256; the model is a public checkpoint
revision; the negative is a derivative of the same public video. No internal
case, host name, local path, process ID or raw log is included.

## Review Checklist

- Option is default-off and rejects invalid values instead of silently
  degrading.
- Native temporal/spatial blend and padding order are reused, not
  reimplemented.
- Fallbacks cover non-NPU, decode-only, unsupported shapes, single clip/rank and
  fewer tiles than ranks.
- The Stage0 encoder role forwards the resolved value; image and control-latent
  paths stay inactive.
- Formal precision is exact on all tested pairs, and the performance claim is
  limited to the measured stage and configuration.
- The two evidence sets are labeled separately: the early frozen tree covers the
  component harness, the public `evidence/pr10167/` records cover the formal
  50 NFE trial, and the full formal harness commands remain internal.
