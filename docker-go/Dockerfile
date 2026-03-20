ARG RALPHEX_VERSION=latest

FROM ghcr.io/umputun/ralphex:${RALPHEX_VERSION}

LABEL org.opencontainers.image.description="Autonomous plan execution with Claude Code - Go development"

# install go from official binaries
ARG GO_VERSION=1.26.1
RUN ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/') && \
    wget -qO- "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" | tar -xz -C /usr/local

ENV GOROOT=/usr/local/go
ENV GOPATH=/home/app/go
ENV PATH="${PATH}:${GOROOT}/bin:${GOPATH}/bin"

# ensure go env vars survive login shell PATH reset (su - app sources /etc/profile.d/)
RUN printf 'export GOROOT=/usr/local/go\nexport GOPATH=/home/app/go\nexport PATH="${PATH}:/usr/local/go/bin:/home/app/go/bin"\n' \
    > /etc/profile.d/go-env.sh

# install go dev tools (golangci-lint, moq, goimports)
RUN wget -qO- https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh | sh -s -- -b /usr/local/bin && \
    GOBIN=/usr/local/bin go install github.com/matryer/moq@latest && \
    GOBIN=/usr/local/bin go install golang.org/x/tools/cmd/goimports@latest

# install jq
RUN apk add --no-cache jq

# install claude code and codex
ARG CLAUDE_CODE_VERSION=latest
ARG CODEX_VERSION=latest
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} @openai/codex@${CODEX_VERSION}

# verify installations
RUN go version && golangci-lint --version && moq --help 2>&1 | head -1 && goimports --help 2>&1 | head -1 && jq --version && claude --version && codex --version
