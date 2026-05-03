# deep-live-cuda-nix

A Nix flake for [Deep-Live-Cam](https://github.com/hacksider/Deep-Live-Cam) on Nvidia hardware.

## Prerequisites

- Nix with flakes enabled
- Nvidia GPU with drivers installed

## Usage

Clone the repo and pull the submodule:

```bash
git clone --recurse-submodules https://github.com/atcol/deep-live-cuda-nix
cd deep-live-cuda-nix
```

Run Deep-Live-Cam (installs Python deps on first run via uv, then launches with CUDA):

```bash
nix run
```

Or enter the dev shell for manual usage:

```bash
nix develop
uv run python Deep-Live-Cam/run.py --execution-provider cuda
```

## How dependencies work

Python dependencies are declared in `pyproject.toml` and managed by [uv](https://github.com/astral-sh/uv). Entering the dev shell runs `uv sync`, which creates a `.venv` and installs everything. Subsequent entries are a fast no-op if deps haven't changed.
