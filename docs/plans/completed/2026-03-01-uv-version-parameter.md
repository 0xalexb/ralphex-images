# Make UV version a build parameter

## Overview

Make the UV version configurable as a Docker build argument instead of being hardcoded, following the same pattern already used for PYTHON_VERSION.

## Context

- Files involved: `Dockerfile`, `Makefile`, `README.md`
- Related patterns: existing `PYTHON_VERSION` ARG in Dockerfile and Makefile
- Dependencies: none

## Development Approach

- **Testing approach**: Manual verification via `make build-one`
- Complete each task fully before moving to the next
- No automated tests applicable (Docker image build)

## Implementation Steps

### Task 1: Parameterize UV version in Dockerfile

**Files:**
- Modify: `Dockerfile`

- [x] Add `ARG UV_VERSION=0.10.6` before the COPY line
- [x] Update the `COPY --from=` line to use `ghcr.io/astral-sh/uv:${UV_VERSION}` (removing the sha256 digest pin since it is version-specific)

### Task 2: Pass UV_VERSION through Makefile

**Files:**
- Modify: `Makefile`

- [x] Add `UV_VERSION ?= 0.10.6` variable at the top alongside existing variables
- [x] Add `--build-arg UV_VERSION=$(UV_VERSION)` to the `build` target's docker build command
- [x] Add `--build-arg UV_VERSION=$(UV_VERSION)` to the `build-one` target's docker build command

### Task 3: Update documentation

**Files:**
- Modify: `README.md`

- [x] Add UV_VERSION to the "Build" section showing how to override it (e.g., `make build UV_VERSION=0.10.6`)
- [x] Note the default UV version in the "What's Included" section
- [x] Move this plan to `docs/plans/completed/`
