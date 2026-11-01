FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:205c6561352214872c61edea4909f29afe9be1eee6c61430ce627ca757c137ed

ARG TARGETARCH
ARG VERSION
ARG MONGOSH_VERSION

USER root

# hadolint ignore=DL3008,DL3015,SC2086,DL4006
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) server_arch=x86_64; shell_arch=x64 ;; \
        arm64) server_arch=aarch64; shell_arch=arm64 ;; \
        *) echo "Unsupported architecture ${TARGETARCH}"; exit 1 ;; \
    esac; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl libcurl4t64; \
    server_url="https://fastdl.mongodb.org/linux/mongodb-linux-${server_arch}-ubuntu2404-${VERSION}.tgz"; \
    curl -fsSL -o /tmp/mongodb.tgz "${server_url}"; \
    echo "$(curl -fsSL "${server_url}.sha256" | cut -d ' ' -f 1)  /tmp/mongodb.tgz" | sha256sum -c -; \
    tar -xzf /tmp/mongodb.tgz -C /usr/local/bin --strip-components=2 --wildcards '*/bin/mongod'; \
    curl -fsSL -o /tmp/mongosh.tgz "https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-${shell_arch}.tgz"; \
    tar -xzf /tmp/mongosh.tgz -C /usr/local/bin --strip-components=2 --wildcards '*/bin/*'; \
    mongod --version; \
    mongosh --version; \
    apt-get purge -y --auto-remove; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 27017
VOLUME /config
WORKDIR /config
