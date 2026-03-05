# Add Go Image and Restructure Repository

## Overview

Restructure the repository to support multiple Docker images. Move the existing Python Dockerfile into a subdirectory, add a new Go image based on umputun/ralphex-go with jq, remove the `latest` tag from the Python image (highest floating tag becomes `py3.13`), and update CI/CD workflows to build and publish both images to separate GHCR repos.

## Context

- Files involved: Dockerfile, Makefile, .github/workflows/build-publish.yml, .github/workflows/check-upstream.yml, README.md, CLAUDE.md
- Related patterns: existing Dockerfile build-arg pattern, Makefile tag matrix, CI matrix strategy
- Dependencies: umputun/ralphex-go upstream image (ghcr.io/umputun/ralphex-go)
- Image repos: ghcr.io/0xalexb/ralphex-python (existing), ghcr.io/0xalexb/ralphex-go (new)

## Development Approach

- No tests in this repo; verification is via Dockerfile RUN steps that check tool versions
- Complete each task fully before moving to the next

## Implementation Steps

### Task 1: Restructure directories for Python image

**Files:**
- Move: `Dockerfile` -> `docker-python/Dockerfile`

- [x] Create `docker-python/` directory
- [x] Move `Dockerfile` to `docker-python/Dockerfile` (no content changes)

### Task 2: Create Go image Dockerfile

**Files:**
- Create: `docker-go/Dockerfile`

- [x] Create `docker-go/Dockerfile` based on `ghcr.io/umputun/ralphex-go:${RALPHEX_GO_VERSION}` with `RALPHEX_GO_VERSION` build arg (default: `latest`)
- [x] Install `jq` via apk (Alpine package manager, consistent with ralphex base)
- [x] Add verification RUN step: `jq --version`

### Task 3: Update Makefile for both images

**Files:**
- Modify: `Makefile`

- [x] Rename `DOCKER_IMAGE` to `PYTHON_IMAGE`, add `GO_IMAGE` variable (`ghcr.io/0xalexb/ralphex-go`)
- [x] Add `RALPHEX_GO_VERSION` variable (default: `latest`)
- [x] Update Python build context from `.` to `docker-python/`
- [x] Remove `latest` tag from Python build (`py3.13` is the highest floating tag)
- [x] Add `build-go` target: builds `docker-go/` with Go tag scheme (`r<ralphex_go_ver>`, `latest`)
- [x] Add `push-go` target
- [x] Rename existing `build`/`push` to `build-python`/`push-python`
- [x] Add `build` and `push` top-level targets that build/push both images

### Task 4: Update build-publish.yml

**Files:**
- Modify: `.github/workflows/build-publish.yml`

- [x] Add `ralphex_go_version` workflow_dispatch input
- [x] Add resolve step for ralphex-go version (from `umputun/ralphex-go` releases)
- [x] Update Python build job: context to `docker-python/`, remove `latest` tag from tag generation
- [x] Add `build-go` job: builds `docker-go/`, pushes to `ghcr.io/0xalexb/ralphex-go`
- [x] Go tag scheme: `<repo_ver>-r<ralphex_go_ver>`, `r<ralphex_go_ver>`, `latest`
- [x] Add update step for `RALPHEX_GO_UPSTREAM_VERSION` repo variable

### Task 5: Update check-upstream.yml

**Files:**
- Modify: `.github/workflows/check-upstream.yml`

- [x] Add parallel check for `umputun/ralphex-go` latest release
- [x] Add `RALPHEX_GO_UPSTREAM_VERSION` comparison logic
- [x] Trigger build-publish with appropriate version inputs when either upstream changes
- [x] Pass both ralphex versions (changed and stored) so unchanged image can still build against its current upstream

### Task 6: Update documentation

**Files:**
- Modify: `README.md`
- Modify: `CLAUDE.md`

- [x] Rewrite README.md: add project-level overview covering both images, separate sections for Python and Go images with their own tag tables, usage examples for both
- [x] Note that `latest` is on the Go image; Python's highest floating tag is `py3.13`
- [x] Update Go image usage examples (pull, run, base image)
- [x] Update CLAUDE.md: project overview, build commands, architecture, tag scheme, conventions

### Task 7: Verify and complete

- [x] Verify Dockerfiles have correct syntax (visual review)
- [x] Verify Makefile targets work with `make build-python`, `make build-go`, `make build`
- [x] Verify workflow YAML is valid
- [x] Move this plan to `docs/plans/completed/`
