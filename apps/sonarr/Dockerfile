

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:6064d5af956ed39456b8c643d6434d9d5331f4d77c08230a413f6a1b253a1408
ARG TARGETARCH
ARG VENDOR
ARG VERSION

ENV DOTNET_EnableDiagnostics=0 \
    SONARR__UPDATE__BRANCH=develop \
    SONARR__SERVER__PORT=8989

USER root
WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sqlite3 \
    & \
    mkdir -p /app/bin && \
    curl -fsSL "https://services.sonarr.tv/v1/update/${SONARR__UPDATE__BRANCH}/download?version=${VERSION}&os=linux&runtime=netcore&arch=${TARGETARCH/amd64/x64}" \
        | tar xzf - -C /app/bin --strip-components=1 && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[%s](https://github.com/%s)\n" \
        "${SONARR__UPDATE__BRANCH}" "${VERSION}" "${VENDOR}" "${VENDOR}" > /app/package_info && \
    chown -R root:root /app && chmod -R 755 /app && \
    rm -rf /var/lib/apt/lists/* /tmp/* /app/bin/Sonarr.Update

COPY . /

USER apps
WORKDIR /config

HEALTHCHECK CMD curl --connect-timeout 15 --max-time 100 --silent --show-error --fail "http://localhost:${SONARR__SERVER__PORT}/"
