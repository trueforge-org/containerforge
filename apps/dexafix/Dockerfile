# For CI, tests and automation (the compose example in deploy/, split-mode tests, agents): it is NOT
# part of the release, which publishes archives only. The prebuilt static binary is copied in (no Go
# build stage). To build by hand:
#   CGO_ENABLED=0 go build -trimpath -o dexafix . && docker build -f Dockerfile.ci -t dexafix .
# The final image is `scratch`: the binary embeds its own time zones (time/tzdata) and CA roots
# (x509roots/fallback), so no OS files are needed. There is no shell: use `docker run ... <command>`
# instead of `docker exec`. Pinned by digest; the docker Dependabot ecosystem keeps it current.

# Build-only helper stage (ContainerForge's Ubuntu, like the other images of this stack): creates the
# /config directory with the right owner (scratch has no mkdir/chown).
# /secrets/<name> are the mount points of the volumes `secrets init` fills (deploy/): a new named
# volume copies the owner of its mount point, so the processes can read what init puts there.
FROM --platform=$BUILDPLATFORM ghcr.io/trueforge-org/ubuntu:26.04@sha256:a3ec289cfc10acc23a20cfb4fe5033c944ce3073dc4a53157c093ffb52f983b1 AS data

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN mkdir -p /out/config /out/secrets/api /out/secrets/web /out/secrets/worker /out/secrets/body \
    /out/secrets/db /out/secrets/dbsetup /out/secrets/valkey /out/app

RUN echo "**** install DexaFix ****" && \
    cd /out/app && \
    curl -o \
        /tmp/dexafix.tar.gz -L \
        "https://github.com/trueforge-org/dexafix/archive/v${VERSION}.tar.gz" && \
    tar xf \
        /tmp/dexafix.tar.gz -C \
        /out/app --strip-components=1 && \
    chown -R apps:apps /app && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/*


FROM scratch

COPY --from=data --chown=568:568 /out/app /app

# The app runs as uid/gid 568. The /config volume (the ContainerForge convention) must be writable
# by that user: with a bind mount run `chown 568:568 <dir>`; named volumes copy the image ownership.
COPY --from=data --chown=568:568 /out/config /config
COPY --from=data --chown=568:568 /out/secrets /secrets
COPY --chmod=0755 . /
USER 568:568
WORKDIR /config
VOLUME /config

ENV DEXAFIX_LISTEN=:8080 \
    DEXAFIX_INTERNAL_LISTEN=:8081 \
    DEXAFIX_DSN=file:/config/dexafix.db \
    DEXAFIX_ENCRYPTION_KEY_FILE=/config/dexafix.key

# 8080 is plain HTTP. HTTPS (and HTTP/3 on UDP) listen on the port set on the Admin page, 8443 by
# default, once a certificate is configured; publish it with -p 8443:8443 -p 8443:8443/udp.
#
# Separate processes instead of one: run the image with `serve api` (the database; public API on 8080
# and the internal API on 8081), with `serve web` (the pages and the public listeners, no database)
# and with `serve worker` (talks to Withings and Strength Level for the api, no database). The
# readings, scans and estimates can run as `serve body` too (8082), with a database of its own.
# 8081 is the internal API and 8082 the body service: never publish them, keep them on a private
# network. 8081 is only used by `serve api`, 8082 only by `serve body`, see
# docs/15-split-deployment.md, docs/16-workers.md and docs/17-body-service.md.
EXPOSE 8080 8081 8082 8443 8443/udp
CMD ["serve"]

