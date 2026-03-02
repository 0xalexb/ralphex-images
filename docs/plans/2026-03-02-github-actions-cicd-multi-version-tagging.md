# GitHub Actions CI/CD with Multi-Version Image Tagging

## Overview

Add a GitHub Actions workflow that builds and publishes Docker images to GHCR. Images are tagged with three version dimensions: this repo's release version, upstream ralphex version, and Python version. The workflow triggers on this repo's GitHub releases and on new upstream umputun/ralphex releases (via scheduled check).

## Context

- Files involved: `.github/workflows/build-publish.yml` (create), `.github/workflows/check-upstream.yml` (create), `Dockerfile` (modify), `Makefile` (modify), `README.md` (modify)
- Related patterns: existing Makefile build matrix over PYTHON_VERSIONS (3.11, 3.12, 3.13)
- Registry: ghcr.io/0xalexb/ralphex-python
- Base image: ghcr.io/umputun/ralphex (currently pinned to :latest, will be parameterized)
- Triggers: (1) this repo's GitHub release published, (2) scheduled check for new umputun/ralphex releases

## Tag Scheme

For repo release `v1.0.0`, ralphex version `v0.5.2`, Python versions 3.11/3.12/3.13 (3.13 is latest):

| Tag                          | Meaning                                       |
|------------------------------|-----------------------------------------------|
| `1.0.0-r0.5.2-py3.13`       | Fully pinned: repo + ralphex + python         |
| `1.0.0-r0.5.2-py3.12`       | Fully pinned: repo + ralphex + python         |
| `1.0.0-r0.5.2-py3.11`       | Fully pinned: repo + ralphex + python         |
| `r0.5.2-py3.13`             | Floating repo: latest repo for this ralphex+python |
| `r0.5.2-py3.12`             | Floating repo: latest repo for this ralphex+python |
| `r0.5.2-py3.11`             | Floating repo: latest repo for this ralphex+python |
| `py3.13`                     | Floating: latest repo + latest ralphex        |
| `py3.12`                     | Floating: latest repo + latest ralphex        |
| `py3.11`                     | Floating: latest repo + latest ralphex        |
| `latest`                     | Latest everything (python 3.13)               |

## Development Approach

- No application code or unit tests (infrastructure/CI only)
- Verification by reviewing generated workflow syntax and local Makefile targets
- Complete each task fully before moving to the next

## Implementation Steps

### Task 1: Parameterize Dockerfile for ralphex version

**Files:**
- Modify: `Dockerfile`

- [x] Add `ARG RALPHEX_VERSION=latest` build arg
- [x] Change base image from `ghcr.io/umputun/ralphex:latest` to `ghcr.io/umputun/ralphex:${RALPHEX_VERSION}`

### Task 2: Create main build-publish workflow

**Files:**
- Create: `.github/workflows/build-publish.yml`

- [x] Define workflow triggers:
  - `release: types: [published]` for this repo's releases
  - `workflow_dispatch` with optional `ralphex_version` input (for upstream-triggered rebuilds)
- [x] Extract this repo's version from the release tag (strip `v` prefix); for dispatch triggers, fetch latest release tag via GitHub API
- [x] Resolve ralphex version: use `workflow_dispatch` input if provided, otherwise fetch latest release from `umputun/ralphex` via GitHub API
- [x] Set up matrix strategy for Python versions: [3.11, 3.12, 3.13]
- [x] Use `docker/login-action` to authenticate with GHCR using `GITHUB_TOKEN`
- [x] Use `docker/setup-buildx-action` for buildx
- [x] Use `docker/build-push-action` to build and push with build args (`PYTHON_VERSION`, `RALPHEX_VERSION`)
- [x] Generate tags per matrix entry: fully pinned `<ver>-r<ralphex>-py<python>`, floating `r<ralphex>-py<python>`, floating `py<python>`
- [x] For the latest Python (3.13), also tag `latest`
- [x] Set GHCR package permissions in workflow (`packages: write`)

### Task 3: Create upstream release check workflow

**Files:**
- Create: `.github/workflows/check-upstream.yml`

- [x] Define schedule trigger (e.g., daily cron `0 6 * * *`)
- [x] Also allow `workflow_dispatch` for manual triggering
- [x] Fetch latest release tag from `umputun/ralphex` via GitHub API
- [x] Compare against last known version (stored as a repository variable or file)
- [x] If new version detected, trigger the build-publish workflow via `workflow_dispatch` with the new ralphex version
- [x] Update the stored version to the new release

### Task 4: Update Makefile with version-aware tags

**Files:**
- Modify: `Makefile`

- [ ] Add optional `VERSION` variable for local versioned builds
- [ ] Add optional `RALPHEX_VERSION` variable (default: latest)
- [ ] Pass `RALPHEX_VERSION` as build arg in build targets
- [ ] When VERSION is set, also tag images as `$(DOCKER_IMAGE):<version>-r<ralphex>-py<python>`
- [ ] Update `push` target to push versioned tags when VERSION is set

### Task 5: Update README

**Files:**
- Modify: `README.md`

- [ ] Update Available Tags table to show the three-dimensional tag scheme
- [ ] Add a "CI/CD" section explaining: auto-build on repo release, auto-rebuild on upstream ralphex release
- [ ] Document the tag format and how to pick the right tag

### Task 6: Verify

- [ ] Validate workflow YAML syntax (manual review)
- [ ] Confirm tag generation logic handles `v` prefix stripping correctly for both repo and ralphex versions
- [ ] Review that GHCR permissions and login are correctly configured
- [ ] Review upstream check workflow logic for correctness
- [ ] Move this plan to `docs/plans/completed/`
