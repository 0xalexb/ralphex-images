# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker image repository that builds two images extending the [ralphex](https://github.com/umputun/ralphex) family of Alpine-based dev images:

- **ralphex-python** (`ghcr.io/0xalexb/ralphex-python`) - extends ralphex with UV, ruff, and multiple Python versions (3.11, 3.12, 3.13)
- **ralphex-go** (`ghcr.io/0xalexb/ralphex-go`) - extends ralphex-go with jq

## Build Commands

```bash
make build                              # Build both Python and Go images
make build-python                       # Build all Python variants (3.11, 3.12, 3.13)
make build-one PYTHON_VERSION=3.13      # Build a single Python variant
make build-go                           # Build Go image
make push                               # Push all images to GHCR

# Override defaults
make build-python UV_VERSION=0.9.0             # Custom UV version (default: 0.10.6)
make build-python RUFF_VERSION=0.14.0          # Custom ruff version (default: 0.15.3)
make build-python RALPHEX_VERSION=0.5.2        # Pin upstream ralphex version
make build-go RALPHEX_GO_VERSION=0.1.0         # Pin upstream ralphex-go version
make build VERSION=1.0.0 RALPHEX_VERSION=0.5.2 RALPHEX_GO_VERSION=0.1.0  # Fully-pinned tags
```

There are no tests or linters in this repo. Verification is done by each Dockerfile's final `RUN` step which checks tool versions.

## Architecture

- **docker-python/Dockerfile** - Multi-stage build: copies UV binaries from `ghcr.io/astral-sh/uv`, installs a Python version via UV, installs ruff globally via `uv tool install`. Build args: `UV_VERSION`, `RUFF_VERSION`, `RALPHEX_VERSION`, `PYTHON_VERSION`.
- **docker-go/Dockerfile** - Extends `ghcr.io/umputun/ralphex-go`, installs jq via apk. Build arg: `RALPHEX_GO_VERSION`.
- **Makefile** - Builds both images. Python: loops over `PYTHON_VERSIONS := 3.11 3.12 3.13`. Go: single build. Targets: `build-python`/`push-python`, `build-go`/`push-go`, `build`/`push` (both).
- **.github/workflows/build-publish.yml** - Triggered on GitHub release or manual dispatch. Resolves repo + both upstream versions, builds Python variants in parallel via matrix strategy and Go image, pushes to GHCR, updates `RALPHEX_UPSTREAM_VERSION` and `RALPHEX_GO_UPSTREAM_VERSION` repo variables.
- **.github/workflows/check-upstream.yml** - Daily cron (6 AM UTC) checks for new releases of both umputun/ralphex and umputun/ralphex-go. If either changes, triggers build-publish with both versions.

## Tag Scheme

**Python**: `<repo_ver>-r<ralphex_ver>-py<python_ver>` (e.g., `1.0.0-r0.5.2-py3.13`). Floating variants: `r<ralphex>-py<python>`, `py<python>`. No `latest` tag; highest floating is `py3.13`.

**Go**: `<repo_ver>-r<ralphex_go_ver>` (e.g., `1.0.0-r0.1.0`). Floating variants: `r<ralphex_go>`, `latest`.

## Conventions

- GitHub Actions use pinned commit SHAs for all third-party actions.
- `ACTIONS_VARS_TOKEN` secret (PAT with `repo` scope) is required for CI workflows.
- Completed plans go in `docs/plans/completed/`.
- UV and ruff default versions are set as `ARG` defaults in `docker-python/Dockerfile`; update them there for version bumps.
