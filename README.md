# ralphex-images

Docker images extending the [ralphex](https://github.com/umputun/ralphex) family of Alpine-based dev images. This repository builds and publishes two images:

| Image | Registry | Base | Adds |
|-------|----------|------|------|
| **ralphex-python** | `ghcr.io/0xalexb/ralphex-python` | [umputun/ralphex](https://github.com/umputun/ralphex) | UV, ruff, Python 3.11/3.12/3.13 |
| **ralphex-go** | `ghcr.io/0xalexb/ralphex-go` | [umputun/ralphex-go](https://github.com/umputun/ralphex-go) | jq |

## Python Image

Extends ralphex with [UV](https://docs.astral.sh/uv/) (fast Python package manager) and [ruff](https://docs.astral.sh/ruff/) (linter/formatter). Each variant includes a specific Python version installed and managed via UV.

### Tags

| Tag Pattern | Example | Description |
|---|---|---|
| `<ver>-r<ralphex>-py<python>` | `1.0.0-r0.5.2-py3.13` | Fully pinned: repo + ralphex + Python |
| `r<ralphex>-py<python>` | `r0.5.2-py3.13` | Floating repo version |
| `py<python>` | `py3.13` | Floating: latest repo + latest ralphex |

The highest floating tag is `py3.13`. There is no `latest` tag on the Python image.

### What's Included

From the base image (`ghcr.io/umputun/ralphex`):
- System Python 3, pip
- Node.js, npm
- make, gcc, musl-dev
- git, bash
- ripgrep, fzf
- Claude Code, Codex

Added by this image:
- UV (default: 0.10.6) - fast Python package manager
- ruff (default: 0.15.3) - Python linter and formatter
- Python version matching the image tag, installed and managed via UV

### Usage

```
docker pull ghcr.io/0xalexb/ralphex-python:py3.13
docker run --rm -it ghcr.io/0xalexb/ralphex-python:py3.13 bash
```

As a base image:

```dockerfile
FROM ghcr.io/0xalexb/ralphex-python:py3.13
COPY . /workspace
RUN uv sync
```

## Go Image

Extends ralphex-go with [jq](https://jqlang.github.io/jq/) for JSON processing.

### Tags

| Tag Pattern | Example | Description |
|---|---|---|
| `<ver>-r<ralphex_go>` | `1.0.0-r0.1.0` | Fully pinned: repo + ralphex-go |
| `r<ralphex_go>` | `r0.1.0` | Floating repo version |
| `latest` | `latest` | Latest everything |

### Usage

```
docker pull ghcr.io/0xalexb/ralphex-go:latest
docker run --rm -it ghcr.io/0xalexb/ralphex-go:latest bash
```

As a base image:

```dockerfile
FROM ghcr.io/0xalexb/ralphex-go:latest
COPY . /workspace
RUN go build ./...
```

## CI/CD

Docker images are built and published to GHCR automatically:

- **On repo release**: when a new GitHub release is published, both images are built and pushed with the full set of tags.
- **On upstream release**: a daily check (6 AM UTC) monitors both [umputun/ralphex](https://github.com/umputun/ralphex) and [umputun/ralphex-go](https://github.com/umputun/ralphex-go). When either upstream publishes a new version, a rebuild is triggered for both images.

Both workflows can be triggered manually from the GitHub Actions UI. The build-publish workflow accepts optional `ralphex_version` and `ralphex_go_version` inputs.

### Required Secrets

| Secret | Purpose |
|--------|---------|
| `ACTIONS_VARS_TOKEN` | PAT with `repo` scope (or fine-grained `variables:write`). Used to update upstream version repo variables and trigger build-publish from the upstream check. |

## Build

Build all images (Python + Go):

```
make build
```

Build only Python variants:

```
make build-python
```

Build a single Python variant:

```
make build-one PYTHON_VERSION=3.13
```

Build only the Go image:

```
make build-go
```

Push all images:

```
make push
```

Override defaults:

```
make build-python UV_VERSION=0.9.0
make build-python RUFF_VERSION=0.14.0
make build-python RALPHEX_VERSION=0.5.2
make build-go RALPHEX_GO_VERSION=0.1.0
make build VERSION=1.0.0 RALPHEX_VERSION=0.5.2 RALPHEX_GO_VERSION=0.1.0
```
