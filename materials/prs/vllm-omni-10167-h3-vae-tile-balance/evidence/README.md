# Public evidence records: vLLM-Omni #10167

These are the machine-readable records that support the formal 50 NFE claims in
the [PR archive](../README.md) and in the PR description. They are the selected
public members of the validation run's public results archive; the JSON files
below are copied unmodified.

## Provenance

- Source artifact: `pr10167-public-results.tar.gz`, 15,607 bytes, SHA-256
  `791f9a0cca5c2423b26ef6a4816d26d8d53a3c4ed283aa01cac63c83f375cfc1`.
- The archive's own `README.md` is not copied here; its environment and
  reproduction narrative is carried by
  [`../validation-and-benefit.md`](../validation-and-benefit.md), and the
  measured boundaries are stated there.
- The results were produced for candidate `bc70adc0509f2b05832389e529b8f8082e88f358`
  against base `b7bbfbdb4f2b3c070d9632043ea6cd2b1c601270` on one eight-card
  Ascend 950PR host with the public Ref2VA fixture. See
  [`../validation-and-benefit.md`](../validation-and-benefit.md) for the full
  configuration.

## Files

| File | What it supports |
| --- | --- |
| `e2e-performance.json` | 50 NFE paired HTTP timings, six pairs, ABBA/order records, the 48 per-rank latent comparisons and per-pair latent hashes |
| `formal-precision.json` | six formal output pairs: per-frame RGB maxima, decoded PCM maxima, output container hashes and stream metadata |
| `vae-performance.json` | VAE device-event and synchronized-call samples, allocator allocated/reserved peaks, A/A noise and ABBA statistics, paired rank-0 latent comparisons |
| `negative-precision.json` | the audio-retained fallback pair (both arms HTTP 200, bitwise equal) |
| `warmup-formal-observations.json` | the within-arm warmup-versus-first-formal output difference |
| `native-public-frames.json` | the native uint8 encoder input: shape, dtype and content SHA-256, plus the preparation path |
| `public-input-manifest.json` | input-definition commit, prompt SHA-256, public CDN video/audio URLs and their SHA-256 values, and the request parameters |
| `model-and-input-identity.json` | public model revision, VAE weight SHA-256, component file hashes and shard/index coverage |
| `smoke-precision.json` | the 1 NFE smoke pair only; never used as formal precision evidence |

The retained-audio negative derivative is a 256×256, H.264, 24 fps, 2.125 s
file with SHA-256
`e848be8f9bda9317824e671c881af002a99614c1b042de015aeba246bc6257ed`. That hash
comes from the formal validation summary; `public-input-manifest.json` lists only
the original public video and audio, not this derivative.

## Verify

From this directory:

```bash
sha256sum -c SHA256SUMS
# macOS:
# shasum -a 256 -c SHA256SUMS
```

## Boundary

The records contain public input URLs and hashes, run parameters, case labels,
output and latent hashes, and timing/allocator statistics. They do **not**
contain raw logs, container images, checkpoint files, host names, local paths,
process IDs, device assignments, private media or private cases. The run's
internal execution records are not part of this archive and are not needed to
review any public claim above.
