# syntax=docker/dockerfile:1

FROM ghcr.io/trueforge-org/ubuntu:24.04.0@sha256:665ed0fd948cf3c093cb8e3fbf7f3add2a14915814322a302bb6bb3f4e25726a
ARG TARGETARCH
ARG VENDOR
ARG VERSION

ENV COMPlus_EnableDiagnostics=0 \
    READARR__UPDATE__BRANCH=develop

USER root
WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sqlite3 \
    && \
    mkdir -p /app/bin && \
    curl -fsSL "https://readarr.servarr.com/v1/update/${READARR__UPDATE__BRANCH}/updatefile?version=${VERSION}&os=linux&runtime=netcore&arch=${TARGETARCH/amd64/x64}" \
        | tar xzf - -C /app/bin --strip-components=1 && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[%s](https://github.com/%s)\n" \
        "${READARR__UPDATE__BRANCH}" "${VERSION}" "${VENDOR}" "${VENDOR}" > /app/package_info && \
    chown -R root:root /app && chmod -R 755 /app && \
    rm -rf /var/lib/apt/lists/* /tmp/* /app/bin/Readarr.Update

COPY . /

USER nobody:nogroup
WORKDIR /config
