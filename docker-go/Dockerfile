ARG RALPHEX_GO_VERSION=latest

FROM ghcr.io/umputun/ralphex-go:${RALPHEX_GO_VERSION}

# install jq
RUN apk add --no-cache jq

# verify installations
RUN jq --version
