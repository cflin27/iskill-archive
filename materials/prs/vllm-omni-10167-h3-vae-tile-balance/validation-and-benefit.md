# Validation and Benefit: Cross-Clip Video VAE Tile Balance

## Summary

- Public PR: [vllm-project/vllm-omni#10167](https://github.com/vllm-project/vllm-omni/pull/10167)
- Public base: `b7bbfbdb4f2b3c070d9632043ea6cd2b1c601270`
- Candidate commit: `bc70adc0509f2b05832389e529b8f8082e88f358`
- Result: the opt-in balance path executed on all eight native Stage0 ranks; the
  formal VAE stage dropped from 4177.600 to 3669.504 ms (paired median
  −12.1474%, 95% CI [−12.2274%, −12.1153%]); the production 50 NFE request
  guard passed at −0.1047% with a confidence interval that includes zero; all
  six formal pairs are bitwise identical after decoding.
- Evidence boundary: one public Ref2VA fixture, one eight-card Ascend 950PR
  host. The VAE speedup is a device-synchronized stage measurement, not a
  user-facing end-to-end speedup claim.

Two measurement sets are reported and are **not interchangeable**:

1. **Early component-level A/B**: encoder-only processes, 39/156/312 raw
   frames, recorded in the public frozen reproduction tree. It exercised task
   scheduling and window boundaries, not the full pipeline.
2. **Formal production native trial**: the real two-stage Ref2VA service,
   Stage0 TP8 encoder plus Stage1 USP8 decoder, complete 50 NFE HTTP requests,
   the instrumented VAE interval, decoded media and allocator peaks. Only this
   set supports the end-to-end guard and formal precision claims.

## Environment

| Item | Value |
| --- | --- |
| Repository | `vllm-project/vllm-omni`, base and candidate as above |
| Early component tree | [cflin27/vllm-omni@0b6381b67](https://github.com/cflin27/vllm-omni/tree/0b6381b673d47c58c8e8ad04a8cbfa1543f9c273) (encoder harness, exact commands, public QSA patch) |
| vLLM source | `4ba787ec9959e566d3b587a796dff07673324da5` (0.33) |
| vLLM-Ascend source | `e617b709ff0a21fba34659f4f2f203b54699b236` plus the public QSA compatibility patch from the early tree |
| Catlass | `41bf90da655bba3c66d0acd7e00abe33960ecfd6` |
| Container | `quay.nju.edu.cn/ascend/vllm-omni@sha256:43a878423c5ac2cf1984405433fb6c0c7b1777084517cb951ccffa89e279725b` |
| Formal runtime | Python 3.12.13, torch 2.10.0+cpu, torch-npu 2.10.0.post7, CANN 9.3.0, driver 25.9.rc1.6 |
| Early component runtime | CANN 9.1.0, driver 25.5.0, as recorded in the early frozen tree; not re-measured in the formal campaign |
| Both arms | Same compiled Ascend wheel `514d465e7e8310529921a976773575c6aebf234d934b94fb58a99100b7e31942`; server CPUs 0–31 and HTTP client CPUs 32–35 fixed in both arms |
| Topology | Stage0 TP8, video patch parallel 8, encoder role; Stage1 USP8, VAE patch parallel 8; layerwise offload for DiT and all-gather, eager, streaming tile off |
| Output request | 1344×768, 24 fps, 5 s requested, seed 0, flow shift 12, audio flow shift 3, 50 NFE |
| VAE workload | Native 124×768×1344 contiguous uint8 input, SHA-256 `454d6f42e876604bff528cacc0f8075adf680d5f62601fb2e5d11d29eff7f558`, seed 42 |
| Candidate option | `additional_config={"h3_vae_encode_tile_balance_max_tasks":168}`; baseline `{}` |

Both arms enabled the same light measurement and parity-export hooks. The
formal 50 NFE HTTP guard values include those hooks' overhead; VAE hash/export
work ran outside the synchronized VAE encode window.

## Public Input

| Input | Public source | SHA-256 |
| --- | --- | --- |
| Prompt, video URL, audio URL | `tests/e2e/accuracy/minimax_h3/test_minimax_h3_i2va_ref2va_similarity.py` at `085d7dba33eca00f44753f8c4a5e11bd7c669f38` | prompt `91c1340ea893aede82312dec30a6ae8c975c1def921348fc1cc45ccc86b315dd` |
| Reference video | public CDN URL named by that test file | `d6edc20ac82aa980c9cbd0b05b371f60d12dc8d018492e571b42de0086819c41` |
| Reference audio | public CDN URL named by that test file | `2a48d447b343b38a2c504d5281a0c97c688db0ba87931ed9282c598bd6752454` |
| Native encoder input | derived by the native video preparation helpers | `454d6f42e876604bff528cacc0f8075adf680d5f62601fb2e5d11d29eff7f558` |
| Negative derivative | same public video, 256×256, 51 frames, original public audio retained | `e848be8f9bda9317824e671c881af002a99614c1b042de015aeba246bc6257ed` |
| VAE checkpoint | `MiniMaxAI/MiniMax-H3@42ed227ee7df40d41602854ae760620d6eb651fe` | VAE weights `5f0c2e161d895a9fee7645ca32d4a7e3a22b90cacfcbeba62ec999cdbbefe0d3` |

No private or internal case is used. The public input manifest
(`evidence/pr10167/public-input-manifest.json`) lists the original public video
and audio only. The retained-audio negative derivative hash is taken from the
formal validation summary, not from that manifest. The complete checkpoint
revision was not independently verified; shard counts, indices and
configurations were checked for the transformer and text-encoder components,
and the VAE weight hash matches the public revision above.

## Correctness

| Check | Baseline | Candidate | Result |
| --- | --- | --- | --- |
| CPU tests | 37 existing tests | 46 tests | Both pass |
| Eight-card preflight | enumerate 8/8, init, sync, AllReduce=36, AllGather=`[0…7]`, exit 0 | same | Pass |
| Native Stage0 routing | option absent | option installed and executed on eight ranks | Hit |
| Positive request | 8 clips × 28 tiles, pad 12, forwards 32/32/32/32/24/24/24/24 | windows 0–168 and 168–224, 28 forwards per rank | Pass |
| Audio-retained negative | fallback, 3 forwards per rank, **HTTP 200** | balance hits 0, 3 forwards per rank, **HTTP 200** | Fallback pass, bitwise equal |
| No-audio negative | fallback, then Stage1 rejects the missing audio stream, **HTTP 500** | fallback, then the same Stage1 rejection, **HTTP 500** | Pre-existing limit, both arms |
| Encoder latent, 39/156/312 frames | 8/8 ranks | 8/8 ranks, maximum absolute difference 0 | Pass |
| Encoder latent, 6 formal pairs | 48 arrays | 48 arrays, maximum absolute difference 0 | Pass |
| Decoded RGB | 6 videos | per-frame maximum difference 0, PSNR ∞, SSIM 1 | Pass |
| Decoded PCM | 6 videos | maximum sample difference 0 | Pass |

The no-audio negative returns **HTTP 500** in both arms. It fails in Stage1 with
`ValueError: ref_blocks[0].ref_audio_t must be an integer` on both arms; that is
a pre-existing output-chain limitation, not a candidate regression. The
audio-retained derivative of the same public video falls back on every rank and
returns **HTTP 200** in both arms with bitwise-equal output, so the scheduling
fallback is proven by that case. The 256×256 negative configuration is not used
for performance claims.

## Early Component-Level A/B

Separate baseline/candidate processes, eight rank workers, encoder-only loading,
FP32, expandable segments on, deterministic algorithms off. Two warmups plus
three unprofiled requests per length; each sample is the eight-rank maximum and
the table uses the three-sample arithmetic mean. The wall timer covers model and
input load, frame preparation and encode, CPU latent processing, offload and
synchronization. The 39-frame case was produced from the public reference video
by resampling and then looping it to 39 raw frames.

| Raw frames | Baseline mean ms | Candidate mean ms | Reduction | Forwards per rank, before → after |
| ---: | ---: | ---: | ---: | --- |
| 39 | 1831.271 | 1610.962 | 12.03% | 6/6/6/6/3/3/3/3 → 5/5/5/5/4/4/4/4 |
| 156 | 4408.921 | 3496.448 | 20.70% | 18/18/18/18/9/9/9/9 → 14/14/14/14/13/13/13/13 |
| 312 | 8676.279 | 6836.269 | 21.21% | 38/38/38/38/19/19/19/19 → 29/29/29/29/28/28/28/28 |

All 15 requests exported latent arrays that were bitwise identical, maximum
absolute difference 0. The 312-frame case exercises multiple task windows. This
campaign validates scheduling and window boundaries, not the full pipeline. The
early environment (CANN 9.1.0 / driver 25.5.0) matches the early frozen tree
record and is not the formal campaign runtime.

## Precision

Formal production trial: six 50 NFE pairs, 48 per-rank latent arrays. Every
latent array, every decoded RGB frame and every decoded PCM sample matches
bitwise. The common latent SHA-256 is
`041964e42d4082bc928390c7e4d7ab73f3b8e2e5d197267c2375bf16f97ef0eb`. Both arms
produce 124 frames (5.166667 s) at 1344×768, 24 fps, and 5.175 s of AAC audio.

The archive publishes a synchronized side-by-side comparison GIF
([`assets/pr10167-ref2va-formal-comparison.gif`](assets/pr10167-ref2va-formal-comparison.gif)):
baseline on the left, candidate on the right, 672×192, 124 frames at 24 fps,
7,017,781 bytes, SHA-256
`272b0c9e0ab0866db3d4b57691773d078547a414498b8d264df9a0871011a24f`. It was
derived from the 562,319-byte silent comparison MP4 (SHA-256
`681c8c2fd50b51f986a8cfd61a791a1e898e1660e60ffd7679c93167f14731ac`) and has no
audio track. The GIF is presentation-only: the reported RGB, PSNR, SSIM and PCM
values were measured on the original decoded outputs, never on this file. See
[assets/README.md](assets/README.md) for the transcode record.

Machine-readable precision records:

- `evidence/pr10167/formal-precision.json`: six paired outputs with per-frame
  RGB maxima, decoded PCM maxima and output container hashes.
- `evidence/pr10167/e2e-performance.json`: the 48 per-rank latent comparisons,
  per-pair hashes and per-request timings.
- `evidence/pr10167/negative-precision.json`: the audio-retained fallback pair.
- `evidence/pr10167/warmup-formal-observations.json`: the within-arm
  warmup-versus-first-formal difference.

## Formal VAE Performance

Per-request maximum across eight ranks; one warmup per block excluded; ten
formal pairs from two independent launches per arm in ABBA order.

| Metric | Baseline median (range) | Candidate median (range) | Paired median change | 95% CI | Gate | Result |
| --- | ---: | ---: | ---: | --- | --- | --- |
| VAE device event | 4177.600 (4174.876–4181.345) ms | 3669.504 (3665.887–3676.220) ms | −12.1474% | [−12.2274%, −12.1153%] | 3.00% | Pass |
| VAE synchronized encode call | 4177.702 (4175.037–4181.496) ms | 3669.630 (3665.980–3676.314) ms | −12.1469% | [−12.2270%, −12.1151%] | 3.00% | Pass |
| VAE allocated peak | 5109.351 MiB | 5150.659 MiB | +0.8085% (+41.308594 MiB) | [+0.8085%, +0.8085%] | 3% and 256 MiB | Pass |
| VAE reserved peak | 7070.000 MiB | 7066.000 MiB | −0.0566% (−4 MiB) | [−0.0566%, −0.0566%] | 3% and 256 MiB | Pass |

Statistics: fresh matching A/A with four blocks and 20 formal same-version
samples gives device-event sigma 15.682117 ms (0.374473%) and maximum absolute
block-mean difference 0.823764%; the gate is max(3%, 2×that difference) = 3%,
fixed before the comparison. The ABBA arm uses two independent blocks per arm,
each with one warmup and five formal samples. Each request takes the eight-rank
maximum before pairing; the 95% CI is a 10,000-resample paired median bootstrap
(percentile 95%, RNG 0). Every candidate formal sample records exactly one
actual balance execution; all formal latent hashes are identical and every
paired rank-0 array was independently compared bitwise.

Memory scope: these are **allocator** peaks (allocated and reserved), not device
HBM. The allocated delta is +41.309 MiB, inside both the 3% and 256 MiB gate; no
profiler diagnostic was started because no gate failed. The numbers are in
`evidence/pr10167/vae-performance.json`.

## Production 50 NFE Guard

Four independent launches in ABBA order, one warmup and three formal requests
per block, six formal pairs. Warmups, the intentionally stopped attempt and
incomplete requests are excluded; no tail samples were dropped.

| Metric | Baseline median (range) | Candidate median (range) | Paired median change | 95% CI | Gate | Result |
| --- | ---: | ---: | ---: | --- | --- | --- |
| 50 NFE HTTP request | 299.057 (298.446–300.233) s | 299.003 (298.200–299.988) s | −0.1047% | [−0.2326%, +0.2466%] | 3.00% | Pass |
| Stage1 allocated peak | 19468.125 MiB | 19468.125 MiB | +0.0000% | [+0.0000%, +0.0000%] | 1.00% (supporting) | Pass |
| Stage1 reserved peak | 20428.000 (20208.000–20428.000) MiB | 20428.000 (20208.000–20428.000) MiB | +0.0000% | [+0.0000%, +0.0000%] | 1.00% (supporting) | Pass |
| Stage0 + Stage1 allocated bound | 65934.077 (65927.827–66001.629) MiB | 65972.260 (65969.135–66039.812) MiB | +0.0603% | [+0.0579%, +0.0627%] | 1.00% (supporting) | Pass |
| Stage0 + Stage1 reserved bound | 66910.000 (66830.000–66950.000) MiB | 66906.000 (66826.000–66946.000) MiB | −0.0060% | [−0.0060%, −0.0060%] | 1.00% (supporting) | Pass |

The CI includes zero: this is a guard pass, not an end-to-end speedup claim.
There is no matching E2E A/A in this campaign, so the default 3% gate applies
and no calibration was used. Both arms enabled identical light measurement and
parity-export hooks; the HTTP interval includes their overhead, while VAE
hash/export work ran outside the synchronized encode window.

The two-stage bound is a conservative allocator bound: per-process Stage0 and
Stage1 request peaks are summed per logical card and the largest card is
reported. It is not a simultaneous device HBM peak. Initialization, driver
memory and uninstrumented allocations are excluded. The 1% bound is supporting
evidence, not a measured device-HBM gate. The numbers are in
`evidence/pr10167/e2e-performance.json`.

## Lifecycle Evidence

All four accepted production blocks have an independent OS wait record for all
16 native model workers (64/64). Stage1 workers exit 0. Stage0 workers exit by
SIGTERM during normal service shutdown (`exit=-15`) and are reaped by the
workload parent. API server, workload, container and launcher exit 0; containers
and assigned devices and ports are released.

All 64 accepted workers also exported resolved model-module import paths and
file hashes matching the two arms' public source. Earlier 1 NFE smoke runs had
external-wait records for 8 of 16 workers; the Stage0 half was missing. That gap
is retained as-is and never reported as exit 0. The first production attempt
was stopped for this audit gap and excluded from the statistics.

## Reproduction

Early component-level A/B: use the public frozen tree
`0b6381b673d47c58c8e8ad04a8cbfa1543f9c273`. It contains the two fixed arms, the
encoder-only harness, the exact commands and the public QSA compatibility patch.

Formal 50 NFE trial: check out base `b7bbfbdb4`, candidate `bc70adc05`, and the
pinned dependencies above in two fresh disposable containers with an explicit
eight-card grant. Replace any user-local paths with your own work directory.

```bash
git clone https://github.com/cflin27/vllm-omni.git
cd vllm-omni
git checkout bc70adc0509f2b05832389e529b8f8082e88f358   # or the base for the control arm
```

Protocol:

1. Install the same compiled vLLM-Ascend wheel in both arms and map each
   visible-device selector to the granted cards 0–7. Fix the service/client CPU
   affinity for both arms.
2. Start native Stage0 TP8 / video patch parallel 8 and Stage1 USP8 / VAE patch
   parallel 8 with the pinned model and output parameters.
3. Send the fixed multipart request to `/v1/videos/sync` with the public video,
   audio and quoted parameters. Run baseline→candidate→candidate→baseline with
   one warmup per block and keep every request timing and allocator peak.
4. For the VAE interval, pass the native uint8 input helper output, synchronize
   each rank around the encode, take the eight-rank maximum, and collect one
   warmup plus five formal samples per block after the four matching A/A blocks.
5. Compare per-rank latent arrays, decoded RGB and decoded PCM independently.

The selected per-request statistics, per-pair precision records and input
manifest are published in [evidence/pr10167](evidence/pr10167/). The full
formal harness commands and machine-specific execution records are retained
internally and are not part of the public archive; the public records identify
the measured configuration, inputs and outputs without machine-local details.

## Limits

- Not measured: other input shapes, other hardware, other batch sizes, decode
  performance, throughput, long-video content quality, non-Ref2VA tasks.
- The complete checkpoint revision was not independently verified; the VAE
  weight hash was matched against the public revision.
- Warmup and first formal outputs differ within both arms (RGB maximum 43, PCM
  maximum 5500, cause not isolated). Formal precision comes from formal outputs
  only.
- The VAE speedup is a synchronized stage metric. The full 50 NFE request change
  is −0.10% with a CI that includes zero, so no user-facing end-to-end claim is
  made.
- Allocator peaks are not device HBM; the two-stage bound is a conservative sum
  of per-process request peaks.
- The early 39/156/312-frame component numbers come from a different runtime
  lane and are not directly comparable with the formal production trial.
- The no-audio negative returns HTTP 500 in both arms because of the
  pre-existing Stage1 audio requirement; only the scheduling fallback claim is
  made for it, supported by the HTTP 200 audio-retained derivative.
- The lossless conclusion is limited to the tested samples (six formal 50 NFE
  pairs and the early component lengths). No claim is made outside those inputs.
