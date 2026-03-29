


FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:1685c0f458568fddff62e0fe0f0804de9d13469bd9fc967bc8c7bde606166969 AS build

ENV PATH=/usr/local/go/bin:$PATH

ARG VERSION
ARG TARGETARCH

USER root

RUN set -eux; \
    url="https://dl.google.com/go/go${VERSION}.linux-${TARGETARCH}.tar.gz"; \
    wget -O go.tgz "$url"; \
    wget -O go.tgz.asc "$url.asc"; \
    GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
    wget -O go.gpg https://dl.google.com/linux/linux_signing_key.pub; \
    gpg --import go.gpg; \
    gpg --batch --verify go.tgz.asc go.tgz; \
    rm -rf "$GNUPGHOME" go.tgz.asc go.gpg; \
    tar -C /usr/local -xzf go.tgz; \
    rm go.tgz; \
    mkdir -p /target/usr/local; \
    mv /usr/local/go /target/usr/local/go; \
    ln -svfT /target/usr/local/go /usr/local/go; \
    go version; \
    apt-get purge -y --auto-remove gnupg; \
    rm -rf /var/lib/apt/lists/*

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:1685c0f458568fddff62e0fe0f0804de9d13469bd9fc967bc8c7bde606166969

USER root

ENV GOTOOLCHAIN=local
ENV HOME=/config
ENV GOPATH=/config/go
ENV GOCACHE=/tmp/go-build
ENV PATH=/usr/local/go/bin:$GOPATH/bin:$PATH

COPY --from=build --link /target/ /

# Fix /config permission issues
RUN install -d -o apps -g apps /config

USER apps
COPY --chmod=0755 . /

WORKDIR /config
