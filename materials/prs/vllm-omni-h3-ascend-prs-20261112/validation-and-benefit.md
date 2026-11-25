# Validation and Benefit

## Summary

All results below are public-safe summaries from cflin27 public PR material and
sanitized publication summaries. They are not raw local logs.

| PR | Main public result | Correctness | Promotion boundary |
| --- | --- | --- | --- |
| [#9235](https://github.com/vllm-project/vllm-omni/pull/9235) | 1-NFE native HTTP mean `10027.756 -> 7039.348 ms`, **29.801% lower** | MP4/RGB/PCM paired precision **1/1 exact**, **2/2 including warmup** | This is a 1-NFE public request result; no 50-NFE quality, throughput, profile, or long-run stability claim. |
| [#9280](https://github.com/vllm-project/vllm-omni/pull/9280) | 832x480 decoder component **3.53% lower latency**; 1344x768 effectively unchanged | Exported tensors **10/10 exact**, max diff 0 | Component geometry validation only; no current-head HTTP/E2E speedup claim. |
| [#9467](https://github.com/vllm-project/vllm-omni/pull/9467) | Repeat frozen component run **35.29% lower latency** | Component arrays **30/30 exact**; public deterministic HTTP 1-NFE check **8/8 MP4 exact** | Initial 64.83% run kept separate and not generalized; no formal E2E speedup/profile claim. |
| [#9468](https://github.com/vllm-project/vllm-omni/pull/9468) | Image/video component reductions **0.875% / 0.635%** | Component arrays **35/35 exact**; native 1-NFE paired MP4/RGB/PCM **1/1 exact** | Small component saving only; deterministic HTTP times excluded from performance claims. |
| [#9494](https://github.com/vllm-project/vllm-omni/pull/9494) | Media component mean `4144.515 -> 2550.478 ms`, **38.46% lower** | Visual conditioning arrays **5/5 exact**, decoder load count `1/1 -> 1/0` | Component result only; no current-head E2E, profile, throughput, or long-run claim. |
| [#10167](https://github.com/vllm-project/vllm-omni/pull/10167) | 39/156/312-frame component reductions **12.03% / 20.70% / 21.21%** | Exported latent arrays **15/15 exact**, all rank hashes match | Component scheduling validation only; no full-pipeline/HTTP speedup or 50-step quality claim. |

## Public Environment

- Public model revision:
  `MiniMaxAI/MiniMax-H3@42ed227ee7df40d41602854ae760620d6eb651fe`.
- Public validation inputs:
  official public Ref2VA video-derived six images, 39-frame public video
  snippets or loops, and open synthetic latents for decoder geometry tests.
- Runtime family:
  Ascend NPU, CANN 9.1.0 lane, Python 3.12, vLLM 0.33, public vLLM-Ascend
  build.
- Validation mode:
  base/candidate paired public environments; warmups excluded from headline
  timing; correctness and timing claims kept separate.

## Limitations

- Component wins do not automatically imply complete request speedups.
- #9235 and #9468 native precision runs observed equal within-arm warmup to
  measure media changes; paired base/candidate exactness is reported separately
  from self-repeat behavior.
- #9467 initial and repeated component measurements differ in magnitude; the
  repeated 35.29% result is the headline component number.
- Native precision checks are 1-NFE public cases and do not claim 50-NFE quality.
- #9468 has a dedicated archive at
  [../vllm-omni-9468-h3-gn-silu/](../vllm-omni-9468-h3-gn-silu/). The row above
  describes its earlier 1-NFE evidence; the newer paired image/video x 1/50-NFE
  campaign, the per-device-class coverage table and the device-gating limits are
  recorded there.
- No private cases, private prompts, or private checkpoints are used or archived.
