


FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:b1fa023ff8e056bfe31075b3cfec6a5de5572e1eee730d1365d3893243d7163c as build

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

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:b1fa023ff8e056bfe31075b3cfec6a5de5572e1eee730d1365d3893243d7163c

USER root

ARG VERSION
ENV GOTOOLCHAIN=local
ENV GOPATH=/config/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

COPY --from=build --link /target/ /

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
