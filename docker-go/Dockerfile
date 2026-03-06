ARG RALPHEX_GO_VERSION=latest

FROM ghcr.io/umputun/ralphex-go:${RALPHEX_GO_VERSION}

# install jq
RUN apk add --no-cache jq

# install claude code and codex
ARG CLAUDE_CODE_VERSION=latest
ARG CODEX_VERSION=latest
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} @openai/codex@${CODEX_VERSION}

# verify installations
RUN jq --version && claude --version && codex --version
