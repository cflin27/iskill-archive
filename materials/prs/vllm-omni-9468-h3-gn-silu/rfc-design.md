# RFC Design: H3 GroupNorm + SiLU Fusion on Ascend

## Problem

The MiniMax-H3 reference-media encoder runs GroupNorm followed by SiLU on every
residual block for image and video conditioning. On Ascend NPUs the vendor stack
already provides a fused GroupNorm plus SiLU operator, so the unfused pair does
two passes where one is available. The fused operator's support matrix is not
uniform across device families, so an unconditional swap would silently move
devices without validated parity onto an unvalidated kernel.

Public context:
[vllm-project/vllm-omni#9468](https://github.com/vllm-project/vllm-omni/pull/9468).

## Proposal

Keep the checkpoint implementation as the source of truth and install a private
fast path in the encoder only:

1. When the encoder is constructed, first require a callable
   `torch_npu.npu_group_norm_silu` operator. Then query the target device with
   `torch_npu.npu.get_device_name(device)` and require the normalized name to
   start with `ascend910b`. If either check fails, the installer returns 0 and
   preserves the checkpoint `forward` and install markers.
2. On the accepted device, mark the encoder's GroupNorm instances as
   fusion-capable and bind per-instance `forward` methods whose globals resolve
   to the fused `norm_silu` while leaving the remote-code module globals and the
   decoder path unchanged.
3. Fuse eligible contiguous FP32 tensors in the image (`T == 1`) or video
   (`T > 0`) encode scope when gradients are disabled and GroupNorm is in eval
   mode. A conditioning argument, hook, per-instance `forward` override,
   spatial-parallel wrapper or active compilation makes the call ineligible.
   The bound private forward routes ineligible calls to the original
   `norm_silu`.
4. Preserve the checkpoint's temporal semantics: the temporal-isolated norm
   merges time into the batch before normalization and splits it back after,
   exactly as the checkpoint does around the fused call.

The fusion is automatic when the device qualifies; no configuration switch is
added.

## Flow

```mermaid
flowchart TD
    enc[Encoder built with target device] --> sym{npu_group_norm_silu callable?}
    sym -- no --> original["Keep checkpoint forward and install markers as they were"]
    sym -- yes --> gate{Target device name starts with ascend910b?}
    gate -- no --> original
    gate -- yes --> bind[Bind private forward, mark norms]
    bind --> call[Encode call]
    call --> elig{"Eligible scope, tensor, and execution state?"}
    elig -- no --> fallback["Bound private forward calls original norm_silu"]
    elig -- yes --> fused[Fused GroupNorm+SiLU, temporal merge/split]
```

## Compatibility

- Public API impact: none. No new arguments, switches or configuration keys.
- Runtime or dependency impact: none beyond an existing `torch_npu` operator;
  the installer is a no-op when `torch_npu` is unavailable.
- A rejected installation preserves the checkpoint forward and install markers.
  After installation, the bound private forward delegates ineligible calls to
  the original `norm_silu`.
- Decoder path and remote-code module globals are not modified.

## Validation scope

- Component arrays matched exactly on Ascend910B4 at historical candidate
  `9323191e`. That experiment exercised the fused operator.
- Current candidate `16c3a32b` has exact paired end-to-end output on the
  eight-card fallback path. Fusion installs and calls were zero, so the
  fusion performance gate was inapplicable on that hardware.
- The 3% threshold is a historical reference for the fallback timing records.
  The cause of the image 1 NFE launch-order variation remains undetermined.
- Both arms recorded encoder manager exit `-9`. Encoder rank logs show forced
  termination and the per-rank OS exit codes are unavailable.

## Deferred hardware coverage

Current-head 910B fusion and 910C / 910_93 real-device fallback are deferred.
The [validation records](validation-and-benefit.md) give the evidence for each
device and revision.
