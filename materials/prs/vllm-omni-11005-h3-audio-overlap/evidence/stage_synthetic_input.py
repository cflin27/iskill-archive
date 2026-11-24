# SPDX-License-Identifier: Apache-2.0
"""Synthetic stage input recipe built only from public PyTorch operations.

The recorded stage harness sets CPU and NPU seeds to 3101, constructs the
encoder-only video/audio VAEs, and then runs the operations below. Preserve
that order when reproducing the recorded RNG sequence.

Sources:
https://docs.pytorch.org/docs/stable/generated/torch.randint.html
https://docs.pytorch.org/docs/stable/generated/torch.arange.html
https://docs.pytorch.org/docs/stable/generated/torch.sin.html
"""

import torch


def make_stage_inputs_after_vae_initialization():
    frames = torch.randint(0, 256, (25, 128, 128, 3), dtype=torch.uint8)
    axis = torch.arange(44100 * 15, dtype=torch.float32) / 44100
    waveform = torch.stack(
        (
            0.2 * torch.sin(2 * torch.pi * 440 * axis),
            0.1 * torch.sin(2 * torch.pi * 523 * axis),
        )
    )
    return frames, waveform, 44100
