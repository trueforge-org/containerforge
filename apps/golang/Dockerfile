


FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:63879ad04337bfb36d309809a30de1522a0ac4ab22b117d727c6fef598d41321 AS build

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

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:63879ad04337bfb36d309809a30de1522a0ac4ab22b117d727c6fef598d41321

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
