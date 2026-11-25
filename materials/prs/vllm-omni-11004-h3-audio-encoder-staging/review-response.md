# Review Response: MiniMax-H3 audio-encoder staging

## PR

- Link: [vllm-project/vllm-omni#11004](https://github.com/vllm-project/vllm-omni/pull/11004)
- Public base: `085d7dba33eca00f44753f8c4a5e11bd7c669f38`
- Updated commit: `dc6cb7c1255160f0b236d0351be91f291491b8e2`

## Comments Addressed

At this head the PR has no upstream review comments and no open review threads.
The items below come from the project's pre-submission code review and are
recorded so the reasoning is inspectable. No public reply was required.

| Review theme | Change or response | Validation |
| --- | --- | --- |
| [Major] `encode_waveform` picked the device from the model's first registered parameter, which can disagree with the actual encoder group when staging is split or a decoder is registered first | The waveform now follows `next(self.model.encoder.parameters()).device` | Real-checkpoint residency plus a decoder-first same-weight reorder; whole-component and adapter paths unchanged |
| [Minor] Whole-component fallback had no diagnostic and an independent empty buffer could be mistaken for shared storage | Each fallback reason is logged at debug level; a zero storage address is combined with object identity, while a zero-length view of a real backing tensor still counts as shared; three regression cases added | CPU cases for independent, same-object and zero-length-view buffers |
| [Minor] The split staging was only reasoned about statically; `preprocess` is checkpoint remote code and its device use was unverified | Handed to the server round with explicit assertions: split hit, per-child placement during encode, decoder on CPU, bit-identical end-to-end output, lower encoding-stage peak HBM, release after an injected exception, sequential-offload path | Real checkpoint, HTTP/AsyncOmni 1 NFE, six paired 50 NFE requests, eight-rank production hit records and single-card offload checks |
| [Simplification] Merge the empty audio proxy subclass and tighten `named_children()` handling | `_VideoVAEPartProxy` is generalized to `_VAEPartProxy`; the old name stays as an alias for video-side callers and the pipeline type check; audio and video mixins keep their own implementations | Existing callers and the new audio tests pass; type check is the same class |
| [nit, not adopted] The `_VideoVAEPartProxy` alias is only kept for old import names and could be removed | Kept intentionally to keep the diff small; removing it would add test-only churn | No runtime impact |
| Interaction with [#11005](https://github.com/vllm-project/vllm-omni/pull/11005) at [`80d6b6fc`](https://github.com/vllm-project/vllm-omni/commit/80d6b6fc200be3b7499a2e6d7113d75261c2bdd6), which changes the same audio path | Merge-tree against base `085d7dba3` shows exactly one text conflict in `encode_waveform`; the recipe file merges automatically; the two changes can coexist | Merge-tree inspection |

## Reply Draft

No reply was drafted or sent: no upstream comment or review thread exists at
this head. When a maintainer does comment, replies must reuse the measured
values in [validation-and-benefit.md](validation-and-benefit.md) and keep the
stated limits: stage-scoped allocator saving rather than a full-request peak
reduction, a neutral end-to-end confidence interval, one hardware and input
scope, and a checkpoint revision that was hash-recorded but not independently
verified.

In `encode_waveform`, use #11005's
`waveform, _ = self._prepare_waveform(waveform, sample_rate)` followed by
`device = next(self.model.encoder.parameters()).device` from this PR.
The second merge can apply this resolution.

## Non-Claims

- The change is not presented as a full-request memory-peak or an end-to-end
  speed-up.
- Allocator allocated and reserved values are reported separately and are not
  described as device HBM peaks.
- Results are not generalized beyond one Ascend 950PR host, eight cards, the
  public Ref2VA fixture and the recorded request parameters.
- The 1 NFE runs are not used as performance evidence.
