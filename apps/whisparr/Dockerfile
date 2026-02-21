

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:63879ad04337bfb36d309809a30de1522a0ac4ab22b117d727c6fef598d41321
ARG TARGETARCH
ARG VENDOR
ARG VERSION

ENV COMPlus_EnableDiagnostics=0 \
    WHISPARR__UPDATE__BRANCH=eros \
    WHISPARR__SERVER__PORT=6969

USER root
WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sqlite3 \
    && \
    mkdir -p /app/bin && \
    curl -fsSL "https://whisparr.servarr.com/v1/update/${WHISPARR__UPDATE__BRANCH}/updatefile?version=${VERSION}&os=linux&runtime=netcore&arch=${TARGETARCH/amd64/x64}" \
        | tar xzf - -C /app/bin --strip-components=1 && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[%s](https://github.com/%s)\n" \
        "${WHISPARR__UPDATE__BRANCH}" "${VERSION}" "${VENDOR}" "${VENDOR}" > /app/package_info && \
    chown -R root:root /app && chmod -R 755 /app && \
    rm -rf /var/lib/apt/lists/* /tmp/* /app/bin/Whisparr.Update


USER apps
COPY --chmod=0755 . /
WORKDIR /config

