
# syntax=docker/dockerfile:1

FROM ghcr.io/trueforge-org/ubuntu:24.04.0@sha256:665ed0fd948cf3c093cb8e3fbf7f3add2a14915814322a302bb6bb3f4e25726a AS build

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

FROM ghcr.io/trueforge-org/ubuntu:24.04.0@sha256:665ed0fd948cf3c093cb8e3fbf7f3add2a14915814322a302bb6bb3f4e25726a

USER root

ARG VERSION
ENV GOTOOLCHAIN=local
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

COPY --from=build --link /target/ /

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
