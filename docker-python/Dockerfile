ARG UV_VERSION=0.10.6
ARG RALPHEX_VERSION=latest

FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv-source
FROM ghcr.io/umputun/ralphex:${RALPHEX_VERSION}

ARG PYTHON_VERSION=3.13
ARG RUFF_VERSION=0.15.3

ENV UV_LINK_MODE=copy
ENV UV_PYTHON=${PYTHON_VERSION}
ENV UV_TOOL_BIN_DIR=/home/app/.local/bin
ENV UV_TOOL_DIR=/home/app/.local/share/uv/tools
ENV UV_PYTHON_INSTALL_DIR=/home/app/.local/share/uv/python
ENV PATH="/home/app/.local/bin:${PATH}"

# install uv (copied from official image, no remote script execution at build time)
COPY --from=uv-source /uv /uvx /home/app/.local/bin/

# install target python version
RUN uv python install ${PYTHON_VERSION}

# install ruff globally
RUN uv tool install ruff==${RUFF_VERSION}

# verify installations
RUN uv --version && ruff --version && uv run python --version
