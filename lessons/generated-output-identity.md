# Generated Output Identity

## Scope

Parity evidence for a pipeline that returns a generated tensor and a packaged
media file, and whose review material also includes a re-encoded side-by-side
copy. This lesson is about proving which artifacts were compared and that each
pair belongs to one request.

## Three Artifact Layers

Keep these three layers separate, and name the layer every parity claim used:

1. **Raw generated tensor** exported straight from the pipeline, with its
   original dtype and shape. A converted copy (for example a float32 convenience
   export) is a derived artifact, not the raw tensor.
2. **Raw container or media file** emitted by the pipeline, without decoding,
   cropping, or re-encoding. Decoded metrics computed from this file describe
   this file.
3. **Display copy** that is re-encoded, cropped, slowed down, compressed, or
   paired side-by-side for review. It can look identical while its bytes differ.
   Never compute precision metrics from it and never report it as the raw
   output.

A byte-identical raw container already implies identical decoded bytes, but
equal decoded metrics do not imply identical containers: encoding and packaging
metadata can still differ. Report both comparisons and say which one supports
the parity claim.

## Pairing by Request Identity

Pair outputs by request index **and** by the request ID that the service reports
in its start and end events for that request. A content-hash set is not a
pairing key: two requests with the same input and seed can produce identical
outputs, so a hash-set match cannot say which artifact belongs to which request.

- Record the request ID next to every exported file: index, request ID, shape,
  dtype, file hash, content hash, and path.
- Drop a pair whose request ID does not appear in that request's event records,
  even when its content hash matches the other arm.
- Carry the request index through the comparison script; do not let a directory
  glob or a hash sort choose the pairs.

## Hash Types

Record two hashes separately:

- the **file hash** of the exported artifact, which also covers serialization
  metadata, and
- the **content hash** of the tensor or of the decoded bytes.

Storing the same tensor in another format can produce a different file with the
same content: identical files imply identical content, but identical content
does not imply identical files. When a second format is exported, treat it as a
derived artifact and keep the raw-dtype export as the reference.

## Scope of a Warmup Export

A warmup request and a later request with the same seed can still differ.
Export and compare the post-warmup requests that the parity claim covers; a
warmup export certifies the warmup request only. See
[experiment-methodology.md](experiment-methodology.md) for warmup-versus-formal
behavior and
[validation-evidence-discipline.md](validation-evidence-discipline.md) for the
run identity that makes the comparison attributable.

## Minimum Report Rows

| Request index | Request ID (both arms) | Artifact | Shape / dtype | Finite | Element-wise equal | Max abs diff | File hash | Content hash |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |

For media, add the decoded comparison in its own row: byte-identical container,
RGB24 and PCM maximum difference, PSNR, and SSIM computed from the raw output.
An infinite PSNR on an exact match is the analytic limit, not a measured
floating-point value, and metrics taken from the re-encoded display copy are not
precision evidence.

## Public Source

- [vllm-project/vllm-omni#9467](https://github.com/vllm-project/vllm-omni/pull/9467)
  and its frozen input package
  ([cflin27/vllm-omni@9483ed9](https://github.com/cflin27/vllm-omni/tree/9483ed912963662b7a9d5220a0d200e2060c6761)):
  the public package fixes the request inputs and parameters that a paired
  comparison uses. This lesson generalizes the artifact-identity checks; the
  local per-process exit records and host-side ownership snapshots are not part
  of the public page and are not included here.
