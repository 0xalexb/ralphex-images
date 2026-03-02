# ralphex-python Docker Image (Multi-Version)

## Overview

Create a Dockerfile extending the ralphex base image with UV (fast Python package manager) and ruff (linter/formatter). Build multiple image variants, one for each recent Python version (3.11, 3.12, 3.13), with Python installed via UV rather than the system package manager.

## Context

- Base image: ghcr.io/umputun/ralphex:latest (Alpine Linux)
- Base already includes: system Python 3, pip, Node.js, npm, make, gcc, musl-dev, git, bash, ripgrep, fzf, Claude Code, Codex
- This image adds: UV, a specific Python version (installed via `uv python install`), ruff (via `uv tool install`)
- Python versions managed via Docker build arg, producing separate tags: `3.11`, `3.12`, `3.13`
- Files involved: Dockerfile, Makefile, README.md
- Dependencies: ralphex base image

## Development Approach

- Straightforward Docker image build - no application code or unit tests
- Verification is done by building the image and checking tool availability
- Single Dockerfile with `PYTHON_VERSION` build arg for all variants
- Complete each task fully before moving to the next

## Implementation Steps

### Task 1: Create Dockerfile

**Files:**
- Create: `Dockerfile`

- [x] Use `ghcr.io/umputun/ralphex:latest` as base
- [x] Define `ARG PYTHON_VERSION=3.13` (default to latest)
- [x] Install UV by copying binaries from the official `ghcr.io/astral-sh/uv` image (version-pinned, no remote script execution)
- [x] Add UV binary location to PATH (`/home/app/.local/bin`)
- [x] Set `UV_LINK_MODE=copy` env var (avoids hard-link issues in Docker layers)
- [x] Install the target Python version via `uv python install ${PYTHON_VERSION}`
- [x] Set the installed Python as default via `UV_PYTHON` env var
- [x] Install ruff globally via `uv tool install ruff`
- [x] Add verification step: `RUN uv --version && ruff --version && uv run python --version`
- [x] Keep WORKDIR as /workspace (inherited from base)

### Task 2: Create Makefile

**Files:**
- Create: `Makefile`

- [x] Define `DOCKER_IMAGE` variable for image name
- [x] Define `PYTHON_VERSIONS` list: `3.11 3.12 3.13`
- [x] Add `build` target that loops over `PYTHON_VERSIONS` and builds each with `--build-arg PYTHON_VERSION=X.Y`, tagging as `$(DOCKER_IMAGE):X.Y`
- [x] Add `build-one` target for building a single version (accepts `PYTHON_VERSION` variable)
- [x] Add `push` target that pushes all version tags
- [x] Tag the latest Python version additionally as `latest`

### Task 3: Update README.md

**Files:**
- Modify: `README.md`

- [x] Add description of what the image provides (UV, ruff, specific Python versions)
- [x] Document available tags (3.11, 3.12, 3.13, latest)
- [x] Add build and usage instructions
- [x] List what is included from the base image

### Task 4: Verify

- [x] Build at least one variant locally (`make build-one PYTHON_VERSION=3.13`)
- [x] Run the image and confirm `uv --version`, `ruff --version`, and `uv run python --version` all report correct versions
- [x] Verify the Python version matches the build arg

### Task 5: Update documentation

- [x] Update README.md if user-facing changes
- [x] Update CLAUDE.md if internal patterns changed
- [x] Move this plan to `docs/plans/completed/`
