# Device Numbering and Ownership

## Scope

Accelerator runs on a shared host, inside a container, and across several
process roles, where one physical card is referenced by more than one number.
This lesson covers proving which physical cards an experiment actually used and
which host processes held them.

## Symptom

The container sees the expected number of devices, the service starts, and the
run completes, but the cards the workload actually occupies may still not be the
ones the operator reserved. Two failure modes are plausible as soon as more than
one numbering domain exists, and neither is excluded by a passing run:

- A subset of cards is mounted into the container while the launch keeps the
  original host indices, and the process ends up with an empty device set and
  fails at context creation.
- The stated cards look right, but the access policy still permits opening a
  wider set than the run was granted, or the selector resolves to a different
  node, so a rank occupies a card nobody assigned to it.

Both are hypotheses about a numbering model, not reported findings from the
public case cited below. The observable that separates them is the recorded
mapping, not the visible count: a count can match while the cards differ.

## Root Cause

Four numbering or authorization layers are in play, and none of them is another:

1. Host physical index, as shown by the platform tool on the host.
2. Container device node: which device nodes the container runtime creates for
   the mounted devices, and which device number those nodes carry. A subset
   mount commonly renumbers them.
3. Index accepted by the installed runtime's visibility selector: the value the
   stack's own selector consumes before it builds the process's visible set.
   This is not necessarily the host index and not necessarily the container
   node number.
4. Framework-visible index after masking: the enumeration the framework reports
   once the visibility set and any remapping have been applied.

Access authorization sits above all four, and neither it nor visibility replaces
the other:

- Device access isolation decides what the process may open. Container device
  mounts, a devices cgroup allow/deny list, file permissions, or an equivalent
  platform mechanism define which device nodes exist and are accessible. It is
  the authorization boundary.
- Runtime visibility decides which devices the process selects for use from the
  set it can open. The visibility value narrows the working set inside the
  accessible set; it cannot grant access to a device that was not made
  available.

A correct visible count only proves the count. It does not prove which physical
cards the container may open, which index the selector accepts, or which ones
the workers use. Because visibility selects within the accessible set, a subset
mount combined with the original host indices is a candidate failure mode: it
can produce an empty visible set if the container renumbers the mounted nodes.
Some stacks instead retain the host enumeration for mounted devices, so the
original host indices may still resolve. Treat retained host enumeration as a
stack-specific compatibility behavior, not as the default: verify it on the
installed runtime and record the index the processes actually report.

## Rules

- Record each layer separately before launch: the intended host physical cards,
  the container device node mapping, the exact visibility value and the selector
  that accepts it, the index the framework reports after masking, and the
  stage-to-card mapping in the service's own log.
- Run the access authorization check before any device probe. Confirm which
  device nodes the container presents and the policy that governs opening them:
  a devices cgroup allow/deny list, file permissions, or the platform's
  equivalent ([OCI devices](https://github.com/opencontainers/runtime-spec/blob/v1.3.0/config-linux.md#devices)
  and [allowed device list](https://github.com/opencontainers/runtime-spec/blob/v1.3.0/config-linux.md#allowed-device-list)
  are a portable container example). If the effective access scope cannot be
  confirmed — the node mapping is unknown, the policy cannot be read, or the run
  may open nodes it was not granted — the launch pre-check fails: do not probe,
  and do not treat a successful allocation or a matching visible count as
  authorization.
- Treat access authorization and runtime visibility as two checks. First confirm
  that the container presents and permits only the device nodes the run may
  open. Then confirm the selector accepts the intended index and the framework
  reports the intended cards after masking. Neither check stands in for the
  other.
- Default to the index the installed runtime's selector accepts, not the host
  index. Record the container node mapping separately: a device node number is
  not automatically the selector index and not automatically the framework
  index. If the stack retains the host enumeration as a compatibility case, that
  is a property of that stack; verify it before relying on it, and do not assume
  it on another runtime or driver version.
- Verify ownership from the host, not only from inside the container: snapshot
  the processes that hold each reserved card and map every one to its physical
  card. A process can see the right count while two ranks share one card.
- Check that each intended card is idle before launch, using the platform tool's
  supported flags for the installed driver, and recheck the same fields after
  cleanup. The query syntax differs by driver version; read the tool's help
  instead of assuming a flag.
- When a probe or launch reports an empty visible set, an authorization error, or
  a context initialization error, stop and re-derive the node mapping, the
  access policy, and the selector index. Do not retry the same indices with a
  longer timeout.
- Publish only the role-level device group; keep host indices, host paths, and
  host process identifiers in the private run record.

## Next Time

- Build a four-column device table before the run: host physical card, container
  device node, index accepted by the installed runtime's selector, and the
  framework index after masking. Confirm the mapping from a process inside the
  container and from the host.
- Keep the access authorization record with the run identity: the node set the
  container presented, the policy that governed it, and the devices the run
  could actually open.
- Save the per-card process snapshot taken before launch and after cleanup.
- Put the interpreter path, the exact visibility variable and selector, and the
  device access or mount rule in the arm identity, next to the image digest and
  driver version.
- Report the device group by role (encoder, denoising, decoder) rather than by
  host position when publishing.

## Public Sources

- [vllm-project/vllm-omni#9467](https://github.com/vllm-project/vllm-omni/pull/9467):
  its public page and frozen input package document the runtime visibility
  variable used per launch, an isolated NPU runtime with matching dependencies,
  and one physical NPU per component arm. They do not publish a host-side
  process snapshot, a staged service's device mapping, a device-node or access
  policy record, or a reproduction of the wrong-card and empty-set failure
  modes, so the authorization, mapping, and ownership checks above are general
  method rather than a published per-case record. Public request inputs and
  examples:
  [cflin27/vllm-omni@9483ed9](https://github.com/cflin27/vllm-omni/tree/9483ed912963662b7a9d5220a0d200e2060c6761).
