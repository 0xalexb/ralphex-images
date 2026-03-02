# ralphex-python

Python development image extending the [ralphex](https://github.com/umputun/ralphex) base image with [UV](https://docs.astral.sh/uv/) (fast Python package manager) and [ruff](https://docs.astral.sh/ruff/) (linter/formatter). Each image variant includes a specific Python version installed and managed via UV.

## Available Tags

Images are tagged across three dimensions: this repo's release version, the upstream ralphex version, and the Python version.

| Tag Pattern                     | Example               | Description                                           |
|---------------------------------|-----------------------|-------------------------------------------------------|
| `<ver>-r<ralphex>-py<python>`   | `1.0.0-r0.5.2-py3.13`| Fully pinned: repo + ralphex + Python version         |
| `r<ralphex>-py<python>`         | `r0.5.2-py3.13`      | Floating repo version: latest repo for this ralphex + Python |
| `py<python>`                    | `py3.13`              | Floating: latest repo + latest ralphex for this Python |
| `latest`                        | `latest`              | Latest everything (Python 3.13)                       |

### How to pick a tag

- Use a fully pinned tag (`1.0.0-r0.5.2-py3.13`) for reproducible builds where you need exact versions.
- Use `r<ralphex>-py<python>` to track this repo's updates while staying on a specific ralphex + Python combination.
- Use `py<python>` to always get the latest versions of everything for a given Python version.
- Use `latest` to always get the newest image with Python 3.13.

## What's Included

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

## CI/CD

Docker images are built and published to GHCR automatically:

- On repo release: when a new GitHub release is published for this repository, images are built for all Python versions and pushed with the full set of tags.
- On upstream ralphex release: a daily check runs against the [umputun/ralphex](https://github.com/umputun/ralphex) repository. When a new ralphex version is detected, a rebuild is triggered automatically using the latest repo release and the new ralphex version.

Both triggers produce the same tag set, ensuring images stay current with upstream changes without manual intervention.

CI builds use the Dockerfile default versions for UV and ruff. To change these, update the default `ARG` values in the Dockerfile and create a new release. The upstream check workflow stores the last-seen ralphex version in a GitHub Actions repository variable (`RALPHEX_UPSTREAM_VERSION`), which is created automatically on the first run.

Both workflows can be triggered manually from the GitHub Actions UI. The build-publish workflow accepts an optional `ralphex_version` input to override the upstream ralphex version.

### Required Secrets

| Secret | Purpose |
|--------|---------|
| `ACTIONS_VARS_TOKEN` | PAT with `repo` scope (or fine-grained `variables:write`). Used to update the `RALPHEX_UPSTREAM_VERSION` repository variable and to trigger the build-publish workflow from the upstream check. |

## Usage

Pull a specific Python version:

```
docker pull ghcr.io/0xalexb/ralphex-python:py3.13
```

Run interactively:

```
docker run --rm -it ghcr.io/0xalexb/ralphex-python:py3.13 bash
```

Use as a base for your own image:

```dockerfile
FROM ghcr.io/0xalexb/ralphex-python:py3.13
COPY . /workspace
RUN uv sync
```

## Build

Build all variants:

```
make build
```

Build a single variant:

```
make build-one PYTHON_VERSION=3.13
```

Push all variants:

```
make push
```

Override the UV version:

```
make build UV_VERSION=0.9.0
```

Override the ruff version:

```
make build RUFF_VERSION=0.14.0
```

Build with a specific ralphex base version:

```
make build RALPHEX_VERSION=0.5.2
```

Build with versioned tags (produces `<ver>-r<ralphex>-py<python>` tags):

```
make build VERSION=1.0.0 RALPHEX_VERSION=0.5.2
```

Override the image name:

```
make build DOCKER_IMAGE=my-registry/my-image
```
