# Stage-Scoped Residency Evidence

Short public-safe lesson for changing which weight groups a module keeps
resident in one stage. See [experiment-methodology.md](experiment-methodology.md)
for the measurement protocol.

## Scope

Changes that split one module's weights into residency groups and stage only the
group a stage actually uses, for example loading an encoder half while leaving a
decoder on the host. The arithmetic is unchanged; the change is where weights
live and when.

## Symptom

A split-residency patch can look correct on paper and still fail on four
independent axes:

- the device is chosen from the module's first registered parameter, which is
  not necessarily in the group that runs;
- the split silently falls back to whole staging, so the comparison measures the
  old behavior;
- independent empty tensors are mistaken for shared storage, forcing a
  needless fallback, or a genuinely shared zero-length view is missed;
- a later stage reuses the same record name and overwrites the earlier stage's
  memory or timing window.

## Root Cause

- Registration order and execution order are separate facts. A model can
  register its decoder before its encoder, and with partial staging the first
  parameter may still be on the host.
- A partition rule is a claim about a checkpoint layout. Without an explicit
  placement snapshot and a fallback-reason log, a whole-staging fallback is
  invisible.
- Distinct empty tensors all report a zero storage address, while a zero-length
  view of a real tensor reports its backing address. One key cannot separate
  these cases.
- Stage windows are often recorded by component name only. Encoding and decoding
  may both enter the same module, and the later entry replaces the earlier
  record.
- `allocated` returning to zero after an exception does not mean the allocator
  has returned all capacity; `reserved` can keep a cached block.

## Next Time

1. Choose the device from the parameters of the submodule that actually runs,
   not from the module's first parameter. Test a same-weight reorder where the
   unused half is registered first, in addition to the real checkpoint order.
2. Prove the split hit before timing: record each child group's placement inside
   the stage, assert the group stagers are the ones loaded, and assert the
   fallback log did not fire. A flag or a code path is not evidence.
3. Exercise every fallback on purpose: missing child, unexpected remote layout,
   root parameters or buffers, tied storage. Assert whole staging and identical
   output for each.
4. Build the storage key carefully: combine a zero address with object identity
   for independent empty tensors, but keep a zero-length view of a real backing
   tensor as shared. Cover independent, same-object and shared-backing cases.
5. Key stage windows by stage and call index, not by module name. If a later
   stage overwrote an earlier window, keep the raw record, mark the metric
   incomplete, and use only independently preserved metrics for the comparison.
6. After an injected failure, report `allocated` and `reserved` separately,
   record the cache-release return value, and prove recovery with a bit-identical
   rerun. Do not describe a cached reserved block as a full release.
7. Keep the stage saving and the full-request peak in separate rows. A stage
   allocator saving is not a full-request peak reduction, and a full-request
   delta inside the noise band is neutral.
8. Verify that the public whole-component load contract and the decode path still
   stage both groups, so a split added for one stage does not change the others.

## Public Sources

- [vllm-project/vllm-omni#11004](https://github.com/vllm-project/vllm-omni/pull/11004)
  and its archive in
  [materials/prs/vllm-omni-11004-h3-audio-encoder-staging](../materials/prs/vllm-omni-11004-h3-audio-encoder-staging/README.md).
- The public split-residency tests in
  `tests/diffusion/models/minimax_h3/test_minimax_h3_audio_split_residency.py`
  at the candidate commit.
- Related measurement guidance:
  [experiment-methodology.md](experiment-methodology.md).
