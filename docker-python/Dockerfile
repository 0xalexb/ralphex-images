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

# ensure uv/python env vars survive login shell PATH reset (su - app sources /etc/profile.d/)
RUN printf 'export UV_LINK_MODE=copy\nexport UV_PYTHON=%s\nexport UV_TOOL_BIN_DIR=/home/app/.local/bin\nexport UV_TOOL_DIR=/home/app/.local/share/uv/tools\nexport UV_PYTHON_INSTALL_DIR=/home/app/.local/share/uv/python\nexport PATH="/home/app/.local/bin:${PATH}"\n' \
    "${PYTHON_VERSION}" > /etc/profile.d/python-tools.sh

# install uv (copied from official image, no remote script execution at build time)
COPY --from=uv-source /uv /uvx /home/app/.local/bin/

# install target python version
RUN uv python install ${PYTHON_VERSION}

# install ruff globally
RUN uv tool install ruff==${RUFF_VERSION}

# install claude code and codex
ARG CLAUDE_CODE_VERSION=latest
ARG CODEX_VERSION=latest
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} @openai/codex@${CODEX_VERSION}

# install jq
RUN apk add --no-cache jq

# verify installations
RUN jq --version && uv --version && ruff --version && uv run python --version && claude --version && codex --version
